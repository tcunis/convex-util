classdef Force < Quantity
    %FORCE Quantity of the dimension of mass times length per time squared.
    %   SI base unit is newton (N, 1 N = 1 kg*m/s^2), suitable unit is
    %   pound force (lbf).
    
    properties (Constant,Access=public)
        % UNITS -  Units of length:
        %   * newton            (N)
        %   * pound f           (lbf)
        units = {'N', 'lbf'};
    end
    properties (Constant,Access=protected)
        conv    = @convforce;                  % Force conversion function.
        unitSI  = 'N';                         % SI unit of force: N.
    end
    
    methods (Static,Access=protected)
        function qnew = create(magn, unit)
            qnew = Force(magn, unit);
        end
    end
    methods
        function obj = Force(varargin)
            % FORCE     Creates a quantity of a force.
            %   The quantity is initialized with a magnitude |magn| in unit
            %   |unit|.
            %   If no arguments are given, quantity is zero and SI.
            obj@Quantity(varargin{:});
        end
    end
end

