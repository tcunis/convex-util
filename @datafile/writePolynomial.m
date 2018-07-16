function nbytes = writePolynomial(obj, varargin)
% WRITEPOLYNOMIAL   Write polynomial variables and data.
%
%% Usage & Description
%
%   datafile.writePolynomial(P1,...,Pk, f1,...,fM)
%   datafile.writePolynomial(..., domain, npts)
%   nbytes = datafile.writeData(...)
%
% Writes data of polynomials |P1|, ..., |Pk| as well as functions |f1|, 
% ..., |fM| to file. All polynomials and functions must be functions in N 
% variables.
% Returns number of written bytes.
%
% Inputs:
%   -Pi:    polynomials as POLYNOMIAL with N variables
%   -fi:    functions in N variables
%   -domain:  1-by-2N row vector of the plotting domain; 
%             (default: domain = [-1 1 ... -1 1]).
%   -npts:  N-by-1 column vector (or scalar) of grid points in each axis;
%           (default: npts = 100).
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2018-05-24
% * Changed:    2018-05-25
%
%%

% reserve cells for inputs
poly = cell(1,nargin);
func = cell(1,nargin);

K = 1; M = 1;
for i=1:length(varargin)
    arg = varargin{i};
    if isa(arg, 'polynomial') 
        poly{K} = arg; K = K + 1;
    elseif isa(arg, 'function_handle')
        func{M} = arg; M = M + 1;
    elseif ~exist('domain','var') && isrow(arg) && ~isscalar(arg)
        domain = arg;
    elseif ~exist('npts','var') && (iscolumn(arg) || isscalar(arg))
        npts = arg;
    end
end

% erase empty cells
poly(K:end) = [];
func(M:end) = [];

% number of arguments
N = poly{1}.nvars;

% default inputs
if ~exist('domain','var')
    domain = ones(1,2*N);
    domain(1:2:end) = -1;
end
if ~exist('npts','var'), npts = 100;  end

% arguments
X = cell(1,N);
for j=1:N
    if isscalar(npts), nj = npts; else, nj = npts(j); end
    
    X{j} = linspace(domain(2*j-1), domain(2*j), nj);
end
% grid
[X{:}] = ndgrid(X{:});
X = cellfun(@(c) c(:), [X], 'UniformOutput', false);
% outputs
Y = NaN(length(X{1}),K+M-2);
% function evaluation
for j=1:K-1
    Y(:,j) = subs(poly{j}, poly{j}.varname, horzcat(X{:})');
end
for j=1:M-1
    Y(:,K-1+j) = func{j}(vertcat(X{:}));
end

% output to cell
Y = num2cell(Y,1);

% write data vectors to file
nbytes = obj.writeData(X{:},Y{:});

end