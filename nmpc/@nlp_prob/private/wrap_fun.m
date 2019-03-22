function [f,g] = wrap_fun(z,fg)
% Wraps objective CASADI Function object and returns sparse output.

    [f,g] = fg(z);

    % ensure full vectors
    f = full(f);
    g = full(g);
end
