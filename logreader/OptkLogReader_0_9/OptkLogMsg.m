classdef OptkLogMsg < AbstractLogMsg
    %OptkLogMsg OptiTrack log message object.
    %           This class provides a similar interface to PprzLogMsg.
    
    properties
        mean_error;
    end
    
    methods
        function msg = OptkLogMsg( name )
            msg@AbstractLogMsg( name );
            msg.mean_error = NaN;
        end
        
        function data_size = set_optkdata( msg, col0, data )
            %set_optkdata   Sets the OptiTrack column titles and data of 
            %               this message. This method call is identical to
            %               the sequential calls:
            %                   1 msg.set_coltitle( col0 );
            %                   2 msg.add_data( data );
            %               Returns the size of the data afterwards, i.e.
            %               number of rows and columns, respectively.
            msg.set_coltitle( col0 );
            msg.add_data( data );
            data_size = size(msg.data);
        end
    end
    
end

