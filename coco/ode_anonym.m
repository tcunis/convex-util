function [data, y] = ode_anonym(prob, data, u)
% Wrapper function for anonymous ODE function call during continuation.
%
%% Usage and description
%   
% Given an anonymous function |fode| in the continuation variables |x|, and
% parameters |p|, use
%
%   PROB = coco_add_func(PROB, FID, @ode_anonym, {fode}, ...)
%
% to add a call to func(x, p) during the continuation.
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

    f = data{1};

    n = fdata.pr.xdim;
    r = fdata.pr.pdim;
    
    x = u(1:n);
    p = u(n+1:n+r);

    y = f(x, p);
end