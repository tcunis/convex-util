classdef (Abstract) Quantity
% QUANTITY  Abstract superclass of quantities with units.
%   Subclasses are representing quantities of a dimension (base quantity),
%   derived quantity, or without dimension (dimensionless).
%
%% Conventions and usage
%   Subclasses need to state an SI base unit (or, if not applicable,
%   declare default unit for substitute) and a conversion function with
%
%       valueOut = conv(valueIn, unitIn, unitOut)
%
%   SI base unit and conversion function are abstract constant object
%   properties and need to be defined by the inheriting class.
%
%   A list of units needs to be defined by subclasses. Elements of these 
%   list must be viable inputs for |unitIn|, |unitOut| of the conversion
%   function.
%
%   See also CONV, UNITSI, UNITS
%   
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2016-12-07
% * Changed:    2017-06-14
%
%%


%% Properties
    properties (Constant,Access=protected)
       MESSAGES = struct(   ...
        'ERR_SIZE_ARG', 'Input %s size is not matching %s size.',                               ...
        'ERR_DIFF_DIM', 'Cannot %s quantities of different dimensions.',                        ...
        'ERR_MULT_UNS', 'Creation of quantity array with different units not supported yet.',   ...
        'WRN_NQTY_GOT', 'Non-quantity will be treated as if of SI unit (%s).'                   ...
       ); 
    end
    properties (Abstract,Constant,Access=public)
        units;      % List of units for this dimension
    end
    properties (Abstract,Constant,Access=protected)
        % CONV -  Conversion function for this dimension; (quasi-static)
        %   Function signature is 
        %       valueOut = conv(value, unitIn, unitOut)
        conv;
        
        unitSI;     % SI base unit of this dimension. (quasi-static)
    end
    properties (Access=private)
        magnSI;     % Magnitude in SI base unit.
        
        unit;       % Initially assigned unit of this quantity.
        magn;       % Magnitude in initially assigned unit.
    end
    
%% Abstract methods
    methods (Abstract)
    end
    
%% Protected methods
    methods (Access=protected)
%       Single constructor
        function obj = Quantity(magn, unit)
            % QUANTITY  Protected superconstructor.
            %   Quantities needs to be initialized with a magnitude |magn|
            %   in unit |unit|.
            %   If no arguments are given, quantity should be zero and SI.
            if (nargin < 2)                           % default constructor
                obj.magn    = 0;
                obj.unit    = obj.unitSI;
                
            elseif length(magn) == 1                      % single quantity
                obj.magn    = magn;
                obj.unit    = unit;

                obj.magnSI  = obj.conv(magn, unit, obj.unitSI);
                
            else                         % multiple quantities of same unit
                                         % (quantities of different units
                                         % are not supported, use CREATEALL
                                         % instead).
                [m,n] = size(magn);
                q = obj(1).create(0, obj(1).unitSI);
                obj(1,1) = q;
                obj(m,n) = q;
                assert(~iscell(unit), Quantity.MESSAGES.ERR_MULT_UNS);
%                 assert(all([m,n]==size(unit)), ...
%                     Quantity.MESSAGES.ERR_SIZE_ARG, 'magnitude', 'unit');
                for i=1:m
                    for j=1:n
                        obj(i,j) = obj(i,j).create(magn(i,j), unit); %unit(i,j));
                    end
                end
            end
        end

%       Multiple-instances contructor
        function qnew = createAll(obj, magn, unit)
            % CREATEALL     Creates new instances of this dimension, 
            %   where the type of the new instances equals the type of the
            %   subclass. The new instances will have the given magnitudes
            %   and initial units:
            %   Magnitudes are given as double array, units as cell array
            %   of strings; and these arrays need to be of same size.
            %   Returns an array of quantities of same size as given
            %   magnitude and unit arrays then.
            %   See also CREATE.
            if length(unit) == 1
                qnew = obj(1).create(magn, char(unit));
            else
                assert(all(size(magn)==size(unit)), ...
                          Quantity.MESSAGES.ERR_SIZE_ARG, 'magnitude', 'unit');
                [m,n] = size(magn);
                qnew(m,n) = obj(1).create(0, obj(1).unitSI);
                for i=1:m
                    for j=1:n
                        qnew(i,j) = obj(1).create(magn(i,j), char(unit(i,j)));
                    end
                end
            end    
        end
    end
    
%% Protected abstract creator method
    methods (Abstract,Static,Access=protected)
        % CREATE    Creates a new instance of this dimension,
        %   where the type of the new instance (i.e., dimension and SI base
        %   unit) equals the type of the implementing class.
        %   The new instance will have the given magnitude in unit |unit| 
        %   and given initial unit.
        qnew = create(magn, unit);
    end
    
    %% Public methods
    methods
%%      Mathematical functions
        function int = interval(obj)
           % INTERVAL   Returns the interval [min max].
           
           A = sort(obj);
           int = [A(1) A(end)];
        end

        function len = lebesgue(obj)
            % LEBESGUE  Lebesgue-measure of a quantity interval.

            int = interval(obj);
            len = (int(end) - int(1));
        end
        
        function vec = range(obj, stepmagn, stepunit)
            % RANGE     Returns range of units with given steps.
            %   Range is equal to |obj(1)|:(magn unit):|obj(end)|.
            
            step = obj(1).create(stepmagn, stepunit);
            vec  = obj(1).create(obj(1).get(stepunit):step.get(stepunit):obj(end).get(stepunit), stepunit);
        end
        
        function [B, I] = sort(obj, varargin)
            % SORT  Overloaded function sort.
            %   Quantities are sorted with respect to their magnitudes in
            %   SI base unit; returns array (matrix) of quantities of the
            %   same size as |obj|, with the unit of |obj(1)|.
            %   See also SORT.
            
            [B, I] = sort(double(obj), varargin{:});
            
            B = obj.create(B, obj(1).unitSI);
            B = obj.create(B.get(obj(1).unit), obj(1).unit);
        end

%%      Getter
        function magnSI = getSI(obj)
            % GETSI  Returns magnitude in SI base unit.
            %   Magnitudes of an array of quantities are retrieved 
            %   element-wise; returns an array of magnitudes of the same
            %   size as |obj|.
            %   See also GET.
            
            % obj is m-by-n
            [m,n] = size(obj);
            if m == 1
                % obj is row vector
                magnSI = [obj.magnSI];
            elseif n == 1
                % obj is column vector
                magnSI = [obj.magnSI]';
            else
                % obj is matrix
                magnSI = zeros(m,n);
                for i=1:m
                    magnSI(i,:) = getSI(obj(i,:));
                end
            end
        end
        
        function magn = get(obj, unit)
            % GET   Returns magnitude in unit |unit|.
            %   Valid units are defined by implementing subclass.
            %
            %% Usage
            %
            %       magn = obj.get(unit)
            %   Where unit is a single string; retrieves the magnitudes in 
            %   unit |unit| and returns an array of magnitudes of the same 
            %   size as |obj|.
            %
            %       magn = obj.get(units)
            %   Where units is a cell array of strings with same size as
            %   |obj|; retrieves magnitudes element-wise and returns an 
            %   array of magnitudes of the same size as |obj|.
            %%
            % See also GETSI.
            
            % convert singular unit cell to character
            if iscell(unit) && length(unit) == 1
                unit = char(unit);
            end
            
            if length(obj) == 1                           % single quantity
                magn = obj.conv(obj.getSI, obj.unitSI, unit);
                
            elseif all(eq_dim(obj(:), obj(1))) && ~iscell(unit)
                                    % multiple quantities of same dimension
                                    % AND a single unit is requested
                magn = obj(1).conv(obj.getSI, obj(1).unitSI, unit);
                
            else
                                    % quantities of (multiple) dimensions
                                    % and multiple units are requested.
                                    % requires size of quantities equals 
                                    % size of requested units!
                assert(all(size(obj)==size(unit)), ...
                     Quantity.MESSAGES.ERR_SIZE_ARG, 'argument', 'object');
                [m,n] = size(obj);
                magn = zeros(m, n);
                for i=1:m
                    for j=1:n
                        magn(i,j) = obj(i,j).get(char(unit(i,j)));
                    end
                end
            end
        end
        
        function units = getUnits(obj)
            % GETUNITS  Returns initial units.
            %   Returns a cell of units of the same size as |obj|.
            
            % obj is m-by-n
            [m,n] = size(obj);
            if m == 1
                % obj is row vector
                units = {obj.unit};
            elseif n == 1
                % obj is column vector
                units = {obj.unit}';
            else
                % obj is matrix
                units = cell(m,n);
                for i=1:m
                    units(i,:) = getUnits(obj(i,:));
                end
            end
        end
        
        function units = getUnitsSI(obj)
            % GETUNITSSI  Returns SI units.
            %   Returns a cell of units of the same size as |obj|.
            %   See also GETUNITS
            
            % obj is m-by-n
            [m,n] = size(obj);
            if m == 1
                % obj is row vector
                units = {obj.unitSI};
            elseif n == 1
                % obj is column vector
                units = {obj.unitSI}';
            else
                % obj is matrix
                units = cell(m,n);
                for i=1:m
                    units(i,:) = getUnitsSI(obj(i,:));
                end
            end
        end
        
%%      Conversion, comparison, and operator overloading        
        function magn = double(obj)
            % DOUBLE    Conversion function to double,
            %   returns magnitude (or array of magnitues) in SI base unit.
            %   See also GETSI.
            magn = obj.getSI;
        end
        
        function is_eq = eq_dim(q1, q2)
            % EQ_DIM    Compares quantities for equal dimensions.
            %   Two quantities have equal dimensions if and only if they
            %   have the same SI base unit.
            %   Arrays of quantities are compared element-wise, returning a
            %   logical array.
            is_eq = strcmp(q1.getUnitsSI, q2.getUnitsSI);
        end
        
        function qpos = uplus(obj)
            % UPLUS  Overloaded unary operator '+'.
            %   Returns quantity (or array of quantities) of same magnitude
            %   and initial unit as given.
            qpos = obj.createAll(uplus(obj.get(obj.getUnits)), obj.getUnits);
        end
        
        function qneg = uminus(obj)
            % UMINUS    Overloaded unary operator '-'.
            %   Quantities are negated element-wise by negating the  
            %   magnitudes. Returns quantity (or array of quantities) of 
            %   same magnitude and initial unit as given.
            qneg = obj.createAll(uminus(obj.get(obj.getUnits)), obj.getUnits);
        end
        
        function qdif = minus(q1, q2)
            % MINUS     Overloaded binary operator '-'.
            %   Requires inputs to be of same dimension.
            %
            %   Quantities are substracted element-wise by adding the   
            %   magnitudes given in the initial unit of the first quantity. 
            %   If one input is a non-quantity, it is treated like a 
            %   quantity in the dimension's SI base unit.
            %   Arrays of quantities are added element-wise, returning an
            %   array of quantities. In this case, given arrays must be of
            %   same size.
            %   See also PLUS, UMINUS.
            qdif = plus(q1, uminus(q2));
        end
        
        function qsum = plus(q1, q2)
            % PLUS  Overloaded binary operator '+'.
            %   Requires inputs to be of same dimension.
            %
            %   Quantities are added element-wise by adding the magnitudes  
            %   given in the initial unit of the first quantity. If one 
            %   input is a non-quantity, it is treated like a quantity in 
            %   the dimension's SI base unit.
            %   Arrays of quantities are added element-wise, returning an
            %   array of quantities. In this case, given arrays must be of
            %   same size.
            
            if ~isa(q1, 'Quantity') || length(q1) < length(q2)
                qsum = plus(q2, q1);
            elseif (isa(q1, 'Quantity') && isa(q2, 'Quantity'))
                assert(all(eq_dim(q1, q2)), ...
                                    Quantity.MESSAGES.ERR_DIFF_DIM, 'sum');
                if length(q1) == 1
                    qsum = q1.create(q1.get(q1.unit)+q2.get(q1.unit), q1.unit);
                else
                    assert(all(size(q1) == size(q2)),    ...
                                        Quantity.MESSAGES.ERR_SIZE_ARG, ...
                                        'first operand', 'second operand');
                    qsum = q1.createAll(plus(q1.get(q1.getUnits),q2.get(q1.getUnits)), q1.getUnits);
                end
            else
                warning(Quantity.MESSAGES.WRN_NQTY_GOT, q1.unitSI);
                qsum = plus(q1, q1.create(double(q2), q1.unitSI));
            end
        end
        
        function qpro = mtimes(q1, q2)
            % MTIMES    Overloaded binary operator '*'.
            %   Does not support multiplication of two quantities yet!
            
            if isa(q2, 'Quantity')
                assert(~isa(q1, 'Quantity'), ...
                     'Multiplication of quantities is not supported yet.');
                
                qpro = mtimes(q2, q1);
            else
                qpro = q1.createAll(mtimes(q1.get(q1.getUnits), ...
                                                   double(q2)), q1.getUnits);
            end
        end
        
        function qdiv = mrdivide(q1, q2)
            % MRDIVIDE  Overloaded binary operator '/'.
            %   Does not support division by a quantity yet!
            
            assert(~isa(q2, 'Quantity'), ...
                          'Division by a quantitiy is not supported yet.');
                      
            qdiv = q1.createAll(mrdivide(q1.get(q1.getUnits), ...
                                                   double(q2)), q1.getUnits);
        end
        
        function dpro = times(q1, q2)
            % TIMES     Overloaded element-wise binary operator '.*'.
            %   Returns product of magnitudes in SI units.
            
            dpro = times(double(q1), double(q2));
        end
        
        function ddiv = rdivide(q1, q2)
            % RDIVIDE   Overloaded element-wise binary operator './'.
            %   Returns division of magnitudes in SI units.
            
            ddiv = rdivide(double(q1), double(q2));
        end
        
        function dpow = power(q, d)
            % POWER     Overloaded element-wise binary operator '.^'.
            %   Returns magnitude of |q| in SI unit to the power of |d|.
            
            dpow = power(double(q), d);
        end
        
        function is_eq = eq(q1, q2)
            % EQ    Overloaded operator '=='.
            %   Two quantities are equal if and only if they are of the
            %   same dimension and their magnitudes in SI are equal.
            %   A quantity is equal to a non-quantity if its magnitude in
            %   SI is equal to the respective double representation.
            %   Arrays of quantities are compared element-wise, returning a
            %   logical array.
            %   See also EQ_DIM.

            if isa(q1, 'Quantity') && isa(q2, 'Quantity')  % two quantities
                is_eq = eq_dim(q1, q2) & eq(double(q1), double(q2));
            else                                % at least one non-quantity
                is_eq = eq(double(q1), double(q2));
            end
        end
        
        function is_ne = ne(q1, q2)
            % NE    Overloaded operator '~='.
            %   Two quantities are unequal---or a quantity is unequal to a
            %   non-quantity---if and only if they are not equal by
            %   defitnion of ==:
            %   Arrays of quantities are compared element-wise, returning a
            %   logical array.
            %   See also EQ.
            is_ne = ~eq(q1, q2);
        end
        
        function is_lt = lt(q1, q2)
            % LT    Overloaded operator '<'.
            %   Requires inputs to be of same dimension, or one input to be
            %   without dimension.
            %   Quantities are ordered according to their SI base units.
            %   Arrays of quantities are compared element-wise, returning a
            %   logical array.
 
            if (isa(q1, 'Quantity') && isa(q2, 'Quantity'))
                assert(all(eq_dim(q1, q2)), ...
                                Quantity.MESSAGES.ERR_DIFF_DIM, 'compare');
            end
            
            is_lt = lt(double(q1), double(q2));
        end
        
        function is_le = le(q1, q2)
            % LE    Overloaded operator '<='.
            %   Requires inputs to be of same dimension, or one input to be
            %   without dimension.
            %   A quantity |q1| is lower than or equal a quantity |q2| if
            %   and only if |q1 < q2| or |q1 == q2|.
            %   Arrays of quantities are compared element-wise, returning a
            %   logical array.
            %   See also EQ, LT.
            is_le = lt(q1, q2) | eq(q1, q2);
        end
        
        function is_gt = gt(q1, q2)
            % GT    Overloaded operator '>'.
            %   Requires inputs to be of same dimension, or one input to be
            %   without dimension.
            %   A quantity |q1| is greater than a quantity |q2| if and only
            %   |q1| is neither lower than nor equal |q2|.
            %   Arrays of quantities are compared element-wise, returning a
            %   logical array.
            %   See also EQ, LT.
            is_gt = ~lt(q1, q2) & ~eq(q1, q2);
        end
        
        function is_ge = ge(q1, q2)
            % GT    Overloaded operator '>='.
            %   Requires inputs to be of same dimension, or one input to be
            %   without dimension.
            %   A quantity |q1| is greater than or equal a quantity |q2| if
            %   and only |q1| is not lower than |q2|.
            %   Arrays of quantities are compared element-wise, returning a
            %   logical array.
            %   See also LT.
            is_ge = ~lt(q1, q2);
        end
        
%%      String conversion and display
        function strSI = charSI(obj)
            % TOSTRINGSI  Returns an SI string representation,
            %   format is |'m u'|, where |m| is the magnitude in SI and |u|
            %   is the SI base unit.
            strSI = sprintf('%d %s', obj.getSI, obj.unitSI);
        end
        
        function str = char(obj)
            % TOSTRING  Returns a string representation in initial unit,
            %   format is |'m u'|, where |m| is the magnitude and |u| is
            %   the initially assigned unit.
            str = sprintf('%d %s', obj.magn, obj.unit);
        end
                
        function disp(obj)
            % DISP  Overloaded display function.
            %   Prints string representation in initially assigned unit.
            %   See also TOSTRING, DISP.
            [m,n] = size(obj);
            for i=1:m
                for j=1:n
                    fprintf('     %s', obj(i,j).char);
                end
                fprintf('\n');
            end
            fprintf('\n');
        end
    end
    
end

