classdef Velocity < Quantity
    %VELOCITY Quantity of the dimension of length per time.
    %   SI base unit is metres per second (m/s), suitable units are feet
    %   per second (ft/s), kilometres per second (km/s), inches per second
    %   (in/s), kilometres per hour (km/h), miles per hour (mph), knots
    %   (kts), and feet per minute (ft/min).
    
    properties (Constant,Access=public)
        % UNITS -  Units of length:
        %   * metres per second             (m/s)
        %   * feet per second               (ft/s)
        %   * kilometres per second         (km/s)
        %   * inches per second             (in/s)
        %   * kilometres per hour           (km/h)
        %   * miles per hour                (mph)
        %   * knots                         (kts)
        %   * feet per minute               (ft/min)
        units = {'m/s', 'ft/s', 'km/s', 'in/s', ...
                 'km/h', 'mph', 'kts', 'ft/min'};
    end
    properties (Constant,Access=protected)
        conv    = @convvel;                 % Velocity conversion function.
        unitSI  = 'm/s';                    % SI unit of velocity: m/s.
    end
    
    methods (Static,Access=protected)
        function qnew = create(magn, unit)
            qnew = Velocity(magn, unit);
        end
    end
    methods
        function obj = Velocity(varargin)
            % VELOCITY  Creates a quantity of a velocity.
            %   The quantity is initialized with a magnitude |magn| in unit
            %   |unit|.
            %   If no arguments are given, quantity is zero and SI.
            obj@Quantity(varargin{:});
        end
    end
end

