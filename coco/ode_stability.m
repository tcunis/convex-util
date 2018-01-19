function [data, y] = ode_stability(prob, data, u)
    
    if isempty(u)
        y = NaN;
        return;
    end

    %else:
    fdata = coco_get_func_data(prob, 'ep', 'data');

    dfds = data{1};

    n = fdata.pr.xdim;
    r = fdata.pr.pdim;
    
    x = u(1:n);
    p = u(n+1:n+r);
    
    A = dfds(x, p);
    y = [1000 100 10 1]*(eig(A)>=0);

end