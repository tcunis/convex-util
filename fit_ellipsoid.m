function [p,Q,info] = fit_ellipsoid(xi,z,l,opts)
% Fits an ellipsoid p = z'*Q*z such that p(xi) = l(i) for each i.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2019-02-21
% * Changed:    2019-02-21
%
%%

if iscell(xi)
    xi = horzcat(xi{:});
end
if nargin < 2 || isempty(z)
    z = mpvar('x',size(xi,1),1);
end
if nargin < 3 || isempty(l)
    l = 1;
end
if nargin < 4 || isempty(opts)
    opts = sosoptions;
end

% polynomial variables
x = z.varname;

% ellipsoid decision variables
[p,Q] = sosdecvar('cp',z);

% equalitiy constraints
sosc = subs(p, x, xi) == l;

% psd constraint
sosc(end+1) = p >= 0;

% solve SOS problem
[info,dopt] = sosopt(sosc,x,[],opts);

% output
if info.feas
    p = subs(p,dopt);
    Q = subs(Q,dopt);
else
    p = [];
    Q = [];
end

