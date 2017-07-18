classdef datafile < handle
% DATAFILE   Write data to tabular file.
%
%% Usage
%
% Create a new data file object and open for writing:
%
%   df = datafile(data_file, encoding, colwidth);
%
% Write column header:
%
%   df.writeHeader(...);
%
% Write data:
%
%   df.writeData(...);
%
% Close file:
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
        
        function set(obj, field, value)
            if strcmp(field, 'nbytes')
                error('Cannot set field "nbytes"');
            elseif strcmp(field, 'colwidth') && obj.nbytes > 0
                error('Column width cannot be changed after writing.');
            end
            
            %else:
            obj.(field) = value;
        end
        
        function fileID = close(obj)
            fclose(obj.fileID);
            
            fileID = obj.fileID;
        end
        
        
    end
    
end

