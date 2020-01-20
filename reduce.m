function varargout = reduce(varargin)
%REDUCE Remove nested function calls.
%
%% Usage and description
%
%   [g1,...,gN] = reduce(f1,...,fN, x1,...,xM)
%   [...] = reduce(...,'Name',value)
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2018-10-19
% * Changed:    2018-10-19
%
%%

fhan = cell(1,nargin);
pvar = cell(1,nargin);

N = 1; M = 1;

for i=1:length(varargin)
    arg = varargin{i};
    
    if ischar(arg)
        break;
    elseif isa(arg, 'function_handle')
        fhan{N} = arg; N = N + 1;
    else
        pvar{M} = arg; M = M + 1;
    end
end

varargin(1:N+M-2) = [];
fhan(N:end) = [];
pvar(M:end) = [];

psym = cell(size(pvar));
for i=1:M-1
    psym{i} = sym(['x' num2str(i) '_'], size(pvar{i}));
end

fsym = cellfun(@(c) c(psym{:}), fhan, 'UniformOutput', false);
varargout = cellfun(@(c) matlabFunction(c, 'Vars', psym, varargin{:}), fsym, 'UniformOutput', false);

end

