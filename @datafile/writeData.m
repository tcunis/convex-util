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


% check for |data| input
if length(varargin) == 1 && ~isvector(varargin{1})
    % data matrix given
    data = varargin{1};
elseif isrow(varargin{1})
    % row vectors given
    data = vertcat(varargin{:});
elseif iscolumn(varargin{1})
    % column vectors given
    data = permute(horzcat(varargin{:}), [2 1]);
else
    % undefined input
    error('Undefined function for given input.')
end


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
