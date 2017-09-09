classdef AbstractXLogMsg < AbstractLogMsg
    %PprzXLogMsg    Paparazzi x-log message object.
    %
    
    properties
        %name   from AbstractLogMsg
        %data   from AbstractLogMsg
        ac_id;
    end
    
    methods
        function xmsg = AbstractXLogMsg( name )
            xmsg@AbstractLogMsg(name);
            %xmsg.data = {};
            xmsg.ac_id = 0;
        end
        
        function value_name = get_value_name( xmsg, field_name, value_unit )
            value_name = sprintf('%s_%s', field_name, value_unit);
            %value_name = regexprep( value_name, '[^_a-zA-Z0-9]', '' );
            value_name = matlab.lang.makeValidName(value_name);
        end
        
        function add_data( xmsg, entry_data )
            %add_data   Overriding add_data@AbstractLogMsg
            if ( xmsg.row_count == 0 )
                xmsg.data = [entry_data];
                xmsg.row_count = size(entry_data,1);
            else
                add_data@AbstractLogMsg(xmsg, entry_data);
            end
        end
        
        function time = get_time( xmsg )
            %get_time   Overriding get_time@AbstractLogMsg
            time = [xmsg.data.time];
        end
        
        function col_data = get_column( xmsg, col_name )
            %get_column     Overriding get_column@AbstractLogMsg
            col_name = matlab.lang.makeValidName(col_name);
            % remove trailing underscores generate by makeValidName(...)
            col_name = regexprep(col_name, '_$', '');
            col_data = [xmsg.data.(col_name)];
        end
    end
end
