classdef OptkXLogMsg < AbstractXLogMsg
    %OptkLogMsg OptiTrack "x-log" message object.
    %           This class provides a similar interface to PprzXLogMsg.
    
    properties
        mean_error;
        temp_data = {};
    end
    
    methods
        function xmsg = OptkXLogMsg( name )
            xmsg@AbstractXLogMsg( name );
            xmsg.mean_error = NaN;
        end
        
        function add_time( xmsg, time )
            xmsg.temp_data.time = time;
        end
        
        function add_column( xmsg, column_name, value_unit, data )
            value_name = xmsg.get_value_name(column_name, value_unit);
            
            xmsg.temp_data.(value_name) = data;
        end
        
        function set_temp_data( xmsg )
            xmsg.add_data( xmsg.temp_data );
        end
    end
    
end

