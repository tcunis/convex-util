classdef AbstractLog
    %AbstractLog    Abstract log file data object
    %
    
    properties
        folder;
        file;
    end
    
    methods
        function log = AbstractLog(path)
            if nargin < 1
                path = '';
            end
            
            log.folder = '.';
            log.file = path;
        end
        
        function fid = open(log)
            %open   Open log data file for reading and returns file id.
            fid = fopen( log.get_abs_file(), 'r' );
        end
        
        function path = get_abs_file (log)
            %get_abs_file   Returns the absolute path to log file.
            path = sprintf( '%s/%s', log.folder, log.file );
        end
        
        function name = get_name (log)
            name = log.file;
        end
    end
    
end

