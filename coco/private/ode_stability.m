function [data, y] = ode_stability(prob, data, u)
% Computes number and position of unstable eigenvalues during continuation.
%
%% Usage and description
%   
% Let |dfds| be the partial derivative of the system function |ds = f(s,u)|
% with respect to the system states |s|, evaluated at the continuation
% states |x| and parameters |p|; use
%
%   PROB = coco_add_func(PROB, FID, @coco_anonym, {func}, ...)
%
% to compute number and position of the unstable eigenvalues of dfds(x, p)
% during the continuation.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2018-01-19
% * Changed:    2018-01-19
%
%% See also
%
% See COCO_ADD_FUNC.
%
%%
    
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
    y = 10.^(n-1:-1:0)*(eig(A)>=0);

end