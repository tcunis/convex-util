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
%   df.writeMatrix(...);
%   df.writeFunction(...);
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
        nbytes = writeMatrix(obj, varargin);
        nbytes = writeFunction(obj, varargin);
        nbytes = writeBifurcation(obj, bd, varargin);
        nbytes = writePolynomial(obj, varargin);
        
        function obj = datafile(data_file, encoding)
           if ~exist('encoding', 'var'), encoding = 'UTF8'; end
           
           obj.fileID = fopen([data_file '.dat'], 'w', 'n', encoding);
           
           obj.colwidth = 13;
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
        function varargout = writeDataToFile(file, header, varargin)
            varargout = cell(1, nargout);
            
            [varargout{:}] = datafile.writeToFile(file, @writeData, header, varargin{:});
        end
        
        function varargout = writeMatrixToFile(file, header, varargin)
            varargout = cell(1, nargout);
            
            [varargout{:}] = datafile.writeToFile(file, @writeMatrix, header, varargin{:});
        end
        
        function varargout = writeFunctionToFile(file, header, varargin)
            varargout = cell(1, nargout);
            
            [varargout{:}] = datafile.writeToFile(file, @writeFunction, header, varargin{:});
        end
        
        function varargout = writeBdToFile(file, bd, header, varargin)
            varargout = cell(1, nargout);
            
            if isempty(varargin)
                varargin = header;
            end
            
            [varargout{:}] = datafile.writeToFile(file, {@writeBifurcation, bd}, header, varargin{:});
        end
        
        function varargout = writePolyToFile(file, header, varargin)
            varargout = cell(1, nargout);
            
            [varargout{:}] = datafile.writeToFile(file, @writePolynomial, header, varargin{:});
        end
    end
    
    methods (Static, Access = protected)
        function [fileID, df] = writeToFile(file, handle, header, varargin)
            if ~iscell(header), header = {header}; end
            
            if iscell(handle) && length(handle) > 1
                pars = handle(2:end);
                handle = handle{1};
            else
                pars = {};
            end
            
            for i=1:length(varargin)
                arg = varargin{i};
                if ~iscell(arg), input = varargin; break;
                elseif ~exist('input','var'),    input = arg;
                elseif ~exist('settings','var'), settings = arg;
                end
            end
            if ~exist('settings', 'var'), settings = {}; end
            
            df = datafile(file);
            df.set(settings{:});
            df.writeHeader(header{:});
            handle(df, pars{:}, input{:});
            
            if nargout <= 1
                df.close;
            end
            
            fileID = double(df);
        end
    
    end
end

