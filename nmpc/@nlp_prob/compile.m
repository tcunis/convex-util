function h = compile(nlp,args,sz,gendir)
% Compile nonlinear problem into mex.
%

    if sz.nd == 0
        % no limits on input rates
        args.dlb = [];
        args.dub = [];
    end
    if sz.ny == 0
        % no limits on output
        args.ylb = [];
        args.yub = [];
    end
    if sz.nw == 0
        args.wlb = [];
        args.wub = [];
    end

	import casadi.*;
    
	% state estimates and target
	x0 = SX.sym('x0',sz.nx);
    u0 = SX.sym('u0',sz.nu);
    y0 = SX.sym('y0',sz.ny);

    xtrg = SX.sym('xt',sz.nx);
    utrg = SX.sym('ut',sz.nu);
    
    eps = SX.sym('eps',1);
    
	% initialize
	n = sz.nx*sz.N;
	m = sz.nu*sz.N;
    p = sz.ny*sz.N;

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

    z = SX.sym('z',sz.nz,1);
    l = SX.sym('l',sz.nl,1);
    v = SX.sym('v',sz.nv,1);
    s = SX.sym('s',1,1);
    
    ocp = [x0;u0;y0;xtrg;utrg;eps];

    problem = []; options = [];

    % nonlinear constraints & first order derivatives
    [g,gz] = nlp.eq_cstr(ocp,z);
    [h,hz] = nlp.ieq_cstr(ocp,z,wub,wlb,dub,dlb,yub,ylb);
    % ensure sparse matrizes
    g = sparsify(g); gz = sparsify(gz);
    h = sparsify(h); hz = sparsify(hz);
    
    ceq  = Function('ceq',{z,ocp},{g},{'z' 'ocp'},{'g'});
    ieq  = Function('ieq',{z,ocp},{h},{'z' 'ocp'},{'h'});

    cstr = Function('cstr',{z,ocp},{[ g; h]},{'z' 'ocp'}, {'gh'});
    cjac = Function('cjac',{z,ocp},{[gz;hz]},{'z' 'ocp'},{'dgh'});
    cjsp = structure([gz;hz]);
    
    problem.constraints = cstr;
    problem.jacobian    = cjac;
    
    cl = [zeros(nl,1);  -Inf(nv,1)];
    cu = [zeros(nl,1); zeros(nv,1)];
    
    problem.cbounds = Function('cbnd',{},{[cl, cu]},{},{'cl_cu'});

    problem.jacobianstructure = Function('cjsp',{},{cjsp},{},{'cjsp'});

    % cost function, gradient, & Hessian
    J  = nlp.cost(ocp,z,Q,R,Qf);
    dJ = nlp.cost_grad(ocp,z,Q,R,Qf);
    % ensure sparse matrizes
    J = sparsify(J); dJ = sparsify(dJ);

    func = Function('objective',{z,ocp},{J},{'z' 'ocp'}, {'J'});
    grad = Function('gradient',{z,ocp},{dJ},{'z' 'ocp'},{'dJ'});
    
    problem.objective = func;
    problem.gradient  = grad;
    
    % Langragian gradient & Hessian
    dL = nlp.lag_grad(ocp,z,l,v,Q,R,Qf,gamma,s);
    HL = nlp.lag_hess(ocp,z,l,v,Q,R,Qf,gamma,s);
    % ensure sparse matrizes
    dL = sparsify(dL); HL = sparsify(HL);
    
    hess = Function('hessian',{z,ocp,l,v,s},{HL},{'z' 'ocp' 'l' 'v' 's'},{'HL'});
    lagr = Function('laggrad',{z,ocp,l,v,s},{dL},{'z' 'ocp' 'l' 'v' 's'},{'dL'});
    hesp = structure(HL);
    
    problem.hessian = hess;
    problem.laggrad = lagr;

    problem.hessianstructure = Function('hesp',{},{hesp},{},{'hesp'});
    
    % state constraints
    lb = [
        repmat(ulb,N,1)
        repmat(xlb,N,1)
              -Inf(p,1)
            zeros(ns,1)
    ];
    ub = [
        repmat(uub,N,1)
        repmat(xub,N,1)
              +Inf(p,1)
             +Inf(ns,1)
	];

    problem.zbounds = Function('zbnd',{},{[lb, ub]},{},{'lb_ub'});
    
    % residuals
    zl   = SX.sym('zl',sz.nz,1);
    zu   = SX.sym('zu',sz.nz,1);
    o = [zl; zu];
    
    grad = lagr(z,ocp,l,v,1) - zl + zu;
    ceq2 =  ceq(z,ocp);
    ieq2 = [ieq(z,ocp); lb-z; z-ub];

    problem.ocp_res = Function('FRN',{z,ocp,l,v,o},{norm([grad; ceq2; min(-ieq2,[v; o])])},{'z' 'ocp' 'l' 'v' 'o'},{'ocp_res'});
    
    
    %% Code generation & mex compilation
    cd(gendir)
    fn = fieldnames(problem);
    
    % generate C++ code
    opts = struct('mex',true,'with_header',true);
    for i = 1:length(fn)
        problem.(fn{i}).generate([fn{i} '.cc'], opts);
    end
    
    % compile mex
    for i = 1:length(fn)
        mex([fn{i} '.cc'], '-DO0', '-g', '-largeArrayDims');
    end
    
end
