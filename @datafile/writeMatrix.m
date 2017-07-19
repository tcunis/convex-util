function nbytes = writeMatrix(obj, varargin)
% WRITEMATRIX	Write matrix parameter and data to file.
%
%% Usage & Description
%
%   datafile.writeMatrix(par1,...,parN, mat1,...,matM)
%   nbytes = datafile.writeData(...)
%
% Writes data of matrizes |mat1|, ..., |matM| for parameters |par1|, ...,
% |parN|. Parameter vectors are of size |n1|, ..., |nN| and matrizes are of
% size |n1|x...x|nN|.
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
mats = cell(1,nargin);

M = 1; N = 1;
for i=1:length(varargin)
    arg = varargin{i};
    if isvector(arg),   pars{N} = arg; N = N + 1;
    else                mats{M} = arg; M = M + 1;
    end
end

pars(N:end) = [];
mats(M:end) = [];

% mesh grid parameters
[pars{:}] = ndgrid(pars{:});

% transform to vectors
data = cellfun( @(c) c(:), [pars, mats], 'UniformOutput', false );

% write data vectors to file
nbytes = obj.writeData(data{:});

end

