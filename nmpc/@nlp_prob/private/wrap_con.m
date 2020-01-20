function [c,ceq,dc,dceq] = wrap_con(z,cstr)
% Wraps constraint CASADI Function object and returns sparse output.

    [ceq,c,dceq,dc] = cstr(z);

    % ensure full vectors
    c = full(c);
    ceq = full(ceq);
    
    % ensure sparse matrizes
    dc = sparse(dc);
    dceq = sparse(dceq);
end
