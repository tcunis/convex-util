classdef Length < Quantity
    %LENGTH Quantity of the dimension of a length.
    %   SI base unit is metre (m), suitable units are feet (ft), kilometre
    %   (km), inch (in), mile (mi), and nautical mile (naut mi).
    
    properties (Constant,Access=public)
        % UNITS -  Units of length:
        %   * metre             (m)
        %   * feet              (ft)
        %   * kilometre         (km)
        %   * inch              (in)
        %   * nautical mile     (naut mi)
        units = {'m', 'ft', 'km', 'in', 'mi', 'naut mi'};
    end
    properties (Constant,Access=protected)
        conv    = @convlength;                % Length conversion function.
        unitSI  = 'm';                        % SI unit of length: m.
    end
    
    methods (Static,Access=protected)
        function qnew = create(magn, unit)
            qnew = Length(magn, unit);
        end
    end
    methods
        function obj = Length(varargin)
            % LENGTH    Creates a quantity of the dimension of a length.
            %   The quantity is initialized with a magnitude |magn| in unit
            %   |unit|.
            %   If no arguments are given, quantity is zero and SI.
            obj@Quantity(varargin{:});
        end
    end
end

