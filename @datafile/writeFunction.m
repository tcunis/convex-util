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

pars = cell(1,nargin);
func = cell(1,nargin);

M = 1; N = 1;
for i=1:length(varargin)
    arg = varargin{i};
    if ~isa(arg, 'function_handle'),   pars{N} = arg; N = N + 1;
    else,               func{M} = arg; M = M + 1;
    end
end

pars(N:end) = [];
func(M:end) = [];

% mesh grid parameters...
[pars{:}] = ndgrid(pars{:});
% ...and transform to vectors
pars = cellfun( @(c) c(:), [pars], 'UniformOutput', false );

% evaluate function in all parameters
data = cell(1, length(func));
for i=1:length(func)
    data{i} = func{i}(pars{:});
end

% write data vectors to file
nbytes = obj.writeData(pars{:}, data{:});

end

