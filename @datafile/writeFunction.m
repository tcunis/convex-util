function nbytes = writeFunction(obj, varargin)
% WRITEFUNCTION     Write function parameter and data to file.
%
%% Usage & Description
%
%   datafile.writeFunction(par1,...,parN, f1,...,fM)
%   nbytes = datafile.writeData(...)
%
% Writes data of functions |f1|, ..., |fM| for parameters |par1|, ...,
% |parN|. Parameter vectors are of size |n1|, ..., |nN| and functions are
% functions in N variables.
% Returns number of written bytes.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2017-07-19
% * Changed:    2017-07-19
%
%%

% reserve cells for parameters, functions, 
% and constants respectively
pars = cell(1,nargin);
func = cell(1,nargin);
cons = cell(1,nargin);

% parse input
M = 1; N = 1; P = 1;
for i=1:length(varargin)
    arg = varargin{i};
    if isa(arg, 'function_handle') ...
        || isa(arg, 'pwfitobject')
        func{M} = arg; M = M + 1;
    elseif ~isscalar(arg)   % input is parameter
        pars{N} = arg; N = N + 1;
    else                    % input is constant
        cons{P} = arg; P = P + 1;
    end
end

% erase empty cells
pars(N:end) = [];
func(M:end) = [];
cons(P:end) = [];

% mesh grid parameters & constants...
[pars{:}, cons{:}] = ndgrid(pars{:}, cons{:});
% ...and transform to vectors
pars = cellfun( @(c) c(:), [pars], 'UniformOutput', false );
cons = cellfun( @(c) c(:), [cons], 'UniformOutput', false );

% evaluate function in all parameters
data = cell(1, length(func));
for i=1:length(func)
    data{i} = func{i}(pars{:});
end

% write data vectors to file
nbytes = obj.writeData(pars{:}, data{:}, cons{:});

end

