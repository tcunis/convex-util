classdef OptkLog < AbstractLog
    %OptkLog    OptiTrack log file data object
    %
    
    properties
    end
    
    methods
        function log = OptkLog()
            log@AbstractLog();
        end
        
        function csv_data = csvread(log, row1, col1)
            csv_data = csvread(log.get_abs_file, row1, col1);
        end
    end
end

