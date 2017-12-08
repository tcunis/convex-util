function nbytes = writeHeader(obj, varargin)
% WRITEHEADER    Write column titles to file.
%
%% Usage & Description
%
%   datafile.writeHeader(col1,...,colN)
%   nbytes = datafile.writeHeader(...)
%
% Writes column headers |col1|, ..., |colN| to data file and returns number
% of written bytes.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2017-07-18
% * Changed:    2017-07-19
%
%%


fmt = sprintf('%%-%gs\t', obj.colwidth);

nbytes = fprintf(obj.fileID, [sprintf(fmt, varargin{:}) '\n']);


obj.nbytes = obj.nbytes + nbytes;

% type of each column
if length(obj.coltypes) == 1
    coltypes = cell(1, length(varargin));
    coltypes(:) = {obj.coltypes};
    obj.coltypes = coltypes;
end

end
