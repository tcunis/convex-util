function f = sysfunc(sys, rangeOut)
%SYSFUNC    Stacks a set of functions to a vector function.
%
%% Usage and description
%
%   f = sysfunc({f1, f2, ...})
%
% Returns vector function |f(X) = [f1(X) f2(X) ...]^T|. f has same
% parameters as f1, f2, etc.
%
%   f = sysfunc(..., range)
%
% Additionally scales the scalar functions by the corresponding row of
% |range|,
%
%   	   | f1(X)/range(1) |
%   f(X) = | f2(X)/range(2) |
%          |       :        |
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2017-06-27
% * Changed:    2017-06-27
%
%%

if ~iscell(sys)
    sys = {sys};
end

n = length(sys);

if nargin < 2
    out = ones(n, 1);
else
    out = double(rangeOut);
end

if ~iscolumn(out)
    out = out';
end

switch n
    case 1
        f = @(varargin) sys{1}(varargin{:})./out;
    case 2
        f = @(varargin) [ sys{1}(varargin{:});
                          sys{2}(varargin{:})  ]./out;
    case 3
        f = @(varargin) [ sys{1}(varargin{:});
                          sys{2}(varargin{:});
                          sys{3}(varargin{:}); ]./out;
    case 4
        f = @(varargin) [ sys{1}(varargin{:});
                          sys{2}(varargin{:});
                          sys{3}(varargin{:}); 
                          sys{4}(varargin{:})  ]./out;
    otherwise
        error('Unsupported.');
end