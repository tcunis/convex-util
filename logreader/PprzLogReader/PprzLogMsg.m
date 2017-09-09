classdef PprzLogMsg < AbstractLogMsg & matlab.mixin.Heterogeneous
    %PprzLogMsg Paparazzi log message object.
    %
    
    properties (Constant)
        INT_POS_FRAC = 0.00390625;  %position in m
        INT_VEL_FRAC = 0.00000191;  %velocity in m/s
        INT_ACC_FRAC = 0.00097656;  %acceleration in m/s2
        INT_MLB_FRAC = 0.00006104;  %matlab frac
        INT_DEG_FRAC = 0.00349733;  %angle in deg
        INT_DRT_FRAC = 0.01398823;  %angular rate in deg/s
    end
    
    properties
        %name         from AbstractLogMsg
        line_fmt;
        %line_count   from AbstractLogMsg
        %col0         from AbstractLogMsg, 1 <=> columns have titles.
        %cols         from AbstractLogMsg
        %data         from AbstractLogMsg
        %intervall    from AbstractLogMsg
        coefficients = 1;
    end
    
    methods
        function msg = PprzLogMsg( name, fmt )
            msg@AbstractLogMsg( name );
            msg.line_fmt    = strcat( '%f %*d %*s ', fmt );
        end
        
        function coeff_tot = set_coeff( msg, coeff )
            if ( iscell(coeff) )
                coeff = cell2mat(coeff);
            end
            msg.coefficients = coeff;
            
            coeff_tot = [1 msg.coefficients];
        end
        
        function fields = set_fields( msg, field_cell )
            msg.set_coltitle( field_cell(:,1)' );
            coeff = msg.set_coeff( field_cell(:,2)' );
            
            fields = { msg.cols', num2cell(coeff)' };
        end
                
        function find = scan_line( msg, tline )
            %scan_line  Scans tline for matching this message;
            %           if matches, the line data is read and appended.
            %           Returns true if and only tline matches.
            find = ~isempty(findstr(tline, msg.name));
            if find
                data = textscan(tline, msg.line_fmt,1);
                if (  length(msg.coefficients) > 1 || msg.coefficients ~= 1 )
                    data = num2cell( cell2mat(data).*[1,msg.coefficients] );
                end
                msg.add_data( data );
            end
        end
    end
    
end

