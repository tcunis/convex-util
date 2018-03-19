function nbytes = writeData(obj, varargin)
% WRITEDATA  Write tabular data to file.
%
%% Usage & Description
%
%   datafile.writeData(col1,...,colN)
%   datafile.writeData(data)
%   nbytes = datafile.writeData(...)
%
% Writes column data vectors |col1|, ..., |colN| or data matrix |data| to
% file; data matrix has N rows of data vectors.
% Returns number of written bytes.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2017-07-18
% * Changed:    2017-07-19
%
%%

data = cell(size(varargin));

% check for |data| input
for i=1:length(varargin)
    arg = varargin{i};
    if length(varargin) == 1 && ~isvector(arg)
        % data matrix given
        data = {arg};
    elseif i > 1 && isscalar(arg)
        % scalar given
        data{i} = arg*ones(size(data{1}));
    elseif isrow(arg)
        % row vector given
        data{i} = arg;
    elseif iscolumn(arg)
        % column vectors given
        data{i} = permute(arg, [2 1]);
    else
        % undefined input
        error('Undefined function for given input.')
    end
end

data = vertcat(data{:});

% number of columns equals number of rows in |data|
cols = size(data, 1);

% type of each column
if length(obj.coltypes) == 1
    coltypes = cell(1, cols);
    coltypes(:) = {obj.coltypes};    
else
    coltypes = obj.coltypes;
end

% column width
w = sprintf('%g', obj.colwidth);

% column format specification
fmt = [sprintf(['%%' '-' w '%s' '\t'], coltypes{:}) '\n'];

% write data matrix to file
nbytes = fprintf(obj.fileID, fmt, data);


obj.nbytes = obj.nbytes + nbytes;


end
