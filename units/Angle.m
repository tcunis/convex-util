classdef Angle < Quantity
    %ANGLE Quantity of the dimension of am angle.
    %   SI base unit is radians (rad), suitable unit is degree (deg).
    
    properties (Constant,Access=public)
        % UNITS -  Units of angle:
        %   * radians       (rad)
        %   * degree        (deg)
        units = {'rad', 'deg'};
    end
    properties (Constant,Access=protected)
        conv    = @convang;                    % Angle conversion function.
        unitSI  = 'rad';                       % SI unit of angle: rad.
    end
    
    methods (Static,Access=protected)
        function qnew = create(magn, unit)
            qnew = Angle(magn, unit);
        end
    end
    methods
        function obj = Angle(varargin)
            % ANGLE    Creates a quantity of the dimension of an angle.
            %   The quantity is initialized with a magnitude |magn| in unit
            %   |unit|.
            %   If no arguments are given, quantity is zero and SI.
            obj@Quantity(varargin{:});
        end
        
        %% Trigonometric functions (radians)
        function sina = sin(angl)
            %SIN    Sine of this angle in radians.
            sina = sin(angl.getSI);
        end
        
        function cosa = cos(angl)
            % COS   Cosine of this angle in radians.
            cosa = cos(angl.getSI);
        end
        
        function tana = tan(angl)
            % TAN   Tangens of this angle in radians.
            tana = tan(angl.getSI);
        end
        
        
        %% Trigonometric functions (degrees)
        function sina = sind(angl)
            % SIND  Sine of this angle in degree.
            sina = sind(angl.get('deg'));
        end
        
        function cosa = cosd(angl)
            % COSD  Cosine of this angle in degree.
            cosa = cosd(angl.get('deg'));
        end
        
        function tana = tand(angl)
            % TAND  Tangens of this angle in degree.
            tana = tand(angl.get('deg'));
        end
    end
    
    methods (Static)
        %% Trigonometric inverse functions
        function angl = asin(x)
            angl = Angle.create(asin(double(x)), 'rad');
        end
        
        function angl = asind(x)
            angl = Angle.create(asind(double(x)), 'deg');
        end
    end
end

