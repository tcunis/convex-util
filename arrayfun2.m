function varargout = arrayfun2(func, varargin)
%ARRAYFUN2  Apply function to elements in array along specified dimension.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2018-11-07
% * Changed:    2018-11-07
%
%%

varargout = cell(1,max(1,nargout));

A = cell(1,length(varargin));

N = 1;

for i=1:length(varargin)
    var = varargin{i};
    
    if ~ischar(var)
        A{N} = var;
        N = N + 1;
    else
        break;
    end
end

varargin(1:N-1) = [];

dim = A{N-1};

A(N-1:end) = [];


A = cellfun(@(c) num2cell(c,dim), A, 'UniformOutput', false);

[varargout{:}] = cellfun(func, A{:}, varargin{:});

end
