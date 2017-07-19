classdef datafile < handle
% DATAFILE   Write data to tabular file.
%
%% Usage
%
% Create a new data file object and open for writing:
%
%   df = datafile(data_file, encoding, colwidth);
%
% write column header:
%
%   df.writeHeader(...);
%
% write data:
%
%   df.writeData(...);
%
% close file:
%
%   fileId = df.close;
%
% See also FOPEN, FPRINTF, FCLOSE.
%   
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2017-07-18
% * Changed:    2017-07-18
%
%%

    
    properties
        fileID;
        colwidth;
        coltypes;
        
        nbytes;
    end
    
    methods
        nbytes = writeHeader(obj, varargin);
        nbytes = writeData(obj, varargin);
        nbytes = writeMatrix(obj, parameter, varargin);
        
        function obj = datafile(data_file, encoding)
           if ~exist('encoding', 'var'), encoding = 'UTF8'; end
           
           obj.fileID = fopen([data_file '.dat'], 'w', 'n', encoding);
           
           obj.colwidth = 12;
           obj.coltypes = 'e';
           obj.nbytes = 0;
        end
        
        function set(obj, varargin)
            for i=1:length(varargin)
                arg = varargin{i};
                if ischar(arg) || iscell(arg), obj.coltypes = arg;
                elseif isnumeric(arg) && obj.nbytes > 0
                    error('Column width cannot be changed after writing.');
                elseif isnumeric(arg), obj.colwidth = arg;
                end
            end
        end
        
        function fileID = close(obj)
            fclose(obj.fileID);
            
            fileID = double(obj);
        end
        
        function fileID = double(obj)
            fileID = obj.fileID;
        end
    end
    
    methods (Static)
        function [fileID, df] = writeDataToFile(file, header, varargin)
            if ~iscell(header), header = {header}; end

            for i=1:length(varargin)
                arg = varargin{i};
                if ~iscell(arg), data = varargin; break;
                elseif ~exist('matrix','var'),   data = arg;
                elseif ~exist('settings','var'), settings = arg;
                end
            end
            if ~exist('settings', 'var'), settings = {}; end
            
            df = datafile(file);
            df.set(settings{:});
            df.writeHeader(header{:});
            df.writeData(data{:});
            
            if nargout <= 1
                df.close;
            end
            
            fileID = double(df);
        end
        
        function [fileID, df] = writeMatrixToFile(file, header, varargin)
            if ~iscell(header), header = {header}; end
            
            for i=1:length(varargin)
                arg = varargin{i};
                if ~iscell(arg), matrix = varargin; break;
                elseif ~exist('matrix','var'),   matrix = arg;
                elseif ~exist('settings','var'), settings = arg;
                end
            end
            if ~exist('settings', 'var'), settings = {}; end
            
            df = datafile(file);
            df.set(settings{:});
            df.writeHeader(header{:});
            df.writeMatrix(matrix{:});
            
            if nargout <= 1
                df.close;
            end
            
            fileID = double(df);
        end
    end
    

    
end

