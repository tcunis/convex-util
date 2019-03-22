function varargout = wrap(z,f)
% Wraps CASADI Function object and returns sparse output.

    varargout = cell(1,nargout);
    
    [varargout{:}] = f(z);
    varargout = cellfun(@(c) full(c), varargout, 'UniformOutput',false);
end
