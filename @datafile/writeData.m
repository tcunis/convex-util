function nbytes = writeData(obj, varargin)
% WRITEDATA  Write tabular data to file.

if length(varargin) == 1 && ~isvector(varargin{1})
    data = varargin{1};
    cols = size(data, 1);
else
    cols = length(varargin);
end



if length(obj.coltypes) == 1
    coltypes = cell(1, cols);
    coltypes(:) = {obj.coltypes};
    
else
    coltypes = obj.coltypes;
end
    
w = sprintf('%g', obj.colwidth);

fmt = [sprintf(['%%' '-' w '%s' '\t'], coltypes{:}) '\n'];


nbytes = fprintf(obj.fileID, fmt, varargin{:});


obj.nbytes = obj.nbytes + nbytes;

end

