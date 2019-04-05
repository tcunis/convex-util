function [u_nmpc,uopt,xopt,yopt,sopt,lopt,vopt,oopt,res,info] = nmpc_call_mex(xhat,uhat,yhat,xtrg,utrg,eps,ukm1,xkm1,ykm1,skm1,lkm1,vkm1,okm1,opts)
% Find optimal NMPC feedback law from precompiled mex
%

    if isempty(opts)
        opts = struct;
    end
    if isempty(yhat)
        yhat = zeros(0,size(xhat,2));
    end
    
    % update state estimate and target
    x0 = xhat;
    u0 = uhat;
    y0 = yhat;
    
    n = length(xkm1);
    m = length(ukm1);
    o = length(ykm1);
    
    nl = length(lkm1);
    nv = length(vkm1);
    no = length(okm1);
    
    nu = length(utrg);
    
    ocp = [x0;u0;y0;xtrg;utrg;eps];
    
    problem = []; options = [];
    
    problem.constraints = @(z) full(constraints('cstr',z,ocp));
    problem.jacobian    = @(z)  sparse(jacobian('cjac',z,ocp));
    
    cbnds = full(cbounds('cbnd'));
    
    options.cl = cbnds(:,1);
    options.cu = cbnds(:,2);
    
    % warm start
    if all(~isnan(lkm1))
        options.iopt.warm_start_init_point = 'yes';
        
        options.lambda = [lkm1; vkm1];
        options.zl = okm1(1:no/2);
        options.zu = okm1(no/2+1:end);
    end
    
    cjsp = sparse(jacobianstructure('cjsp'));
    
    problem.jacobianstructure = @() cjsp;
    
    problem.objective = @(z) full(objective('objective',z,ocp));
    problem.gradient  = @(z) full( gradient('gradient',z,ocp));
    
    problem.hessian = @(z,s,lv) sparse(hessian('hessian',z,ocp,lv(1:nl),lv(nl+1:end),s));
    problem.laggrad = @(z,s,lv)   full(laggrad('laggrad',z,ocp,lv(1:nl),lv(nl+1:end),s));
    
    hesp = sparse(hessianstructure('hesp'));
    
    problem.hessianstructure = @() hesp;
    
    % state constraints
    zbnds = full(zbounds('zbnd'));
    
    options.lb = zbnds(:,1);
    options.ub = zbnds(:,2);
    
    % initial guess
    z0 = [ukm1;xkm1;ykm1;skm1];
    
    % solve nonlinear problem
    options.ipopt.print_level = 0;
    options.ipopt.hessian_approximation = 'limited-memory';
    
    for fld = fieldnames(opts)'
        options.ipopt.(fld{:}) = opts.(fld{:});
    end
    
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
    
    % extract the solution
    uopt = zopt(1:m);
    xopt = zopt(m+1:m+n);
    yopt = zopt(m+n+1:m+n+o);
    sopt = zopt(m+n+o+1:end);
    
    lopt = info.lambda(1:nl);
    vopt = info.lambda(nl+1:end);
    oopt = [info.zl; info.zu];
    
    % residuals
    res = full(ocp_res('FRN',zopt,ocp,lopt,vopt,oopt));
    
    % optimal control input
    u_nmpc = uopt(1:nu);
end
