function [u_nmpc,uopt,xopt,yopt,sopt,dopt,ocp_res,info] = nmpc_step(nlp,xhat,uhat,yhat,xtrg,utrg,eps,ukm1,xkm1,ykm1,skm1,dkm1,args,sz,opts)
% Find optimal NMPC feedback law
%

	import casadi.*;
    
	% update state estimate and target
	x0 = xhat;
    u0 = uhat;
    y0 = yhat;

	% initialize
	n = sz.nx*sz.N;
	m = sz.nu*sz.N;
    o = sz.ny*sz.N;

    Qf  = args.Qf;
    Q   = args.Q;
    R   = args.R;
    xlb = args.xlb;
    xub = args.xub;
    ulb = args.ulb;
    uub = args.uub;
    dlb = args.dlb;
    dub = args.dub;
    ylb = args.ylb;
    yub = args.yub;
    wlb = args.wlb;
    wub = args.wub;

    gamma = args.gamma;
    
    nz = sz.nz;
    ns = sz.ns;
    nw = sz.nw;
    nl = sz.nl;
    nv = sz.nv;
    
    N = sz.N;

    z = SX.sym('z',nz,1);
    l = SX.sym('l',nl,1);
    v = SX.sym('v',nv,1);
    s = SX.sym('s',1,1);
    
    ocp = [x0;u0;y0;xtrg;utrg;eps];


    problem = []; options = [];

    % nonlinear constraints & first order derivatives
    [g,gz] = nlp.eq_cstr(ocp,z);
    [h,hz] = nlp.ieq_cstr(ocp,z,wub,wlb,dub,dlb,yub,ylb);
    % ensure sparse matrizes
    g = sparsify(g); gz = sparsify(gz);
    h = sparsify(h); hz = sparsify(hz);
    
    ceq  = Function('ceq',{z},{g},{'z'},{'g'});
    ieq  = Function('ieq',{z},{h},{'z'},{'h'});

    cstr = Function('cstr',{z},{[ g; h]},{'z'}, {'gh'});
    cjac = Function('cjac',{z},{[gz;hz]},{'z'},{'dgh'});
    cjsp = structure([gz;hz]);
    
    problem.constraints = @(z)   full(cstr(z));
    problem.jacobian    = @(z) sparse(cjac(z));
    
    options.cl = [zeros(nl,1);  -Inf(nv,1)];
    options.cu = [zeros(nl,1); zeros(nv,1)];

    % warm start
    if ~isempty(dkm1)
        options.ipopt.warm_start_init_point = 'yes';
        
        options.lambda = [dkm1.l; dkm1.v];
        options.zl = dkm1.o(1:nz);
        options.zu = dkm1.o(nz+1:end);
    end
    
    problem.jacobianstructure = @() cjsp;

    % cost function, gradient, & Hessian
    J  = nlp.cost(ocp,z,Q,R,Qf);
    dJ = nlp.cost_grad(ocp,z,Q,R,Qf);
    % ensure sparse matrizes
    J = sparsify(J); dJ = sparsify(dJ);

    func = Function('objective',{z},{J},{'z'}, {'J'});
    grad = Function('gradient',{z},{dJ},{'z'},{'dJ'});
    
    problem.objective = @(z) full(func(z));
    problem.gradient  = @(z) full(grad(z));
    
    % Langragian gradient & Hessian
    dL = nlp.lag_grad(ocp,z,l,v,Q,R,Qf,gamma,s);
    HL = nlp.lag_hess(ocp,z,l,v,Q,R,Qf,gamma,s);
    % ensure sparse matrizes
    dL = sparsify(dL); HL = sparsify(HL);
    
    hess = Function('hessian',{z,l,v,s},{HL},{'z' 'l' 'v' 's'},{'HL'});
    lagr = Function('laggrad',{z,l,v,s},{dL},{'z' 'l' 'v' 's'},{'dL'});
    hesp = structure(HL);
    
    problem.hessian = @(z,s,lv) sparse(hess(z,lv(1:nl),lv(nl+1:end),s));
    problem.laggrad = @(z,s,lv)   full(lagr(z,lv(1:nl),lv(nl+1:end),s));

    problem.hessianstructure = @() hesp;
    
    % state constraints
    options.lb = [
        repmat(ulb,N,1)
        repmat(xlb,N,1)
              -Inf(o,1)
            zeros(ns,1)
    ];
    options.ub = [
        repmat(uub,N,1)
        repmat(xub,N,1)
              +Inf(o,1)
             +Inf(ns,1)
	];
    
    % initial guess
    z0 = [ukm1;xkm1;ykm1;skm1];
    
    % solve nonlinear problem
%     problem.solver = 'fmincon';
    options.ipopt.print_level = 0;
    options.ipopt.hessian_approximation = 'limited-memory';
%     problem.options = optimoptions('fmincon','SpecifyObjectiveGradient',true,opts{:});
%     [zopt,~,flag,info,dual,grad] = fmincon(problem);

    % copy options from input
    for fld = fieldnames(opts)'
        options.ipopt.(fld{:}) = opts.(fld{:});
    end
      
    % set environment variables for PARDISO
%     setenv('OMP_PLACES', 'cores');
%     setenv('OMP_NUM_THREADS', '2');

    tic
    
    try
        [zopt,info] = ipopt(z0,problem,options);
        
        info.message = [];
    catch ME
        zopt = z0;
        info.zl      = zeros(nz,1);
        info.zu      = zeros(nz,1);
        info.lambda  = zeros(nl+nv,1);
        info.message = ME.message;
        info.status  = -200;
    end

    % solver time & exit info
    info.time     = toc;
%     info.exitflag = flag;
        
    % extract the solution
    uopt = zopt(1:m);
    xopt = zopt(m+1:m+n);
    yopt = zopt(m+n+1:m+n+o);
    sopt = zopt(m+n+o+1:end);
    
    dopt.l = info.lambda(1:nl);
    dopt.v = info.lambda(nl+1:end);
    dopt.o = [info.zl; info.zu];

    % residuals
    dual = info.lambda;
    grad = problem.laggrad(zopt,1,dual) - info.zl + info.zu;
    ceq  = full(ceq(zopt));
    ieq  = [full(ieq(zopt)); options.lb-zopt; zopt-options.ub];
%     [eq,ieq] = cstr(zopt);
    ocp_res = norm(full([grad; ceq; min(-ieq,[dopt.v; dopt.o])]));

    % optimal control input
	u_nmpc = uopt(1:sz.nu);
end
