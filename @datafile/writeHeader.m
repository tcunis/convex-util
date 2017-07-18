function nbytes = writeHeader(obj, varargin)
% WRITEHEADER    Write column titles to file.

fmt = sprintf('%%-%gs\t', obj.colwidth);

nbytes = fprintf(obj.fileID, [sprintf(fmt, varargin{:}) '\n']);


obj.nbytes = obj.nbytes + nbytes;

end
