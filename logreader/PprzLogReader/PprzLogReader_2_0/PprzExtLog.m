classdef PprzExtLog < PprzLog
    %PprzExtLog    Paparazzi extended log file data object.
    %   
    
    properties
        %folder     from PprzLog
        %date       from PprzLog
        module;
        desc;
    end
    
    methods
        function log = PprzExtLog()
            log@PprzLog();
            log.module = '';
            log.desc = '';
        end
        
        function name = get_name(log)
            %get_name(log)  Returns the name of a log file object.
            formatOut = 'yyyymmdd_HHMMSS';
            date_s = datestr( log.date, formatOut );
            
            if ( ~strcmp(log.desc, '') )
                name = sprintf( '%s__%s', date_s, log.desc );
            else
                name = date_s;
            end
        end
        
        function path = get_path(log)
            %get_path   Returns the path of a log file object.
            name = log.get_name();
            
            path = sprintf( '%s\\%s\\%s', log.folder, log.module, name );
        end        
    end
end

