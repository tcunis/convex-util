classdef hystfunc < handle
%HYSTFUNC Function with hysteresis.
%
%              f
%               ^
%               |
%            f2 -       ........<.............................
%               |       :               :
%               |       :           	:
%   ------------+-------:---------------:--------------------->
%               |      z1              z2                      z
%               |       :               :
%   .........f1.-.......:.......>.......:
%               |
%               |
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2017-03-23
% * Changed:    2017-03-30
%
%% Variables
%
% * |f|      :  function with hysteresis
% * |f1|     :  left-hand side sub-function
% * |f2|     :  right-hand side sub-function
% * |z|      :  variable(s) of f
% * |z1|     :  boundary of right-to-left hysteresis
% * |z2|     :  boundary of left-to-right hysteresis
%
%%

    properties
        f1;
        f2;
        
        z1;
        z2;
        
        z0;
        sign;
        
        epsilon;
        name;
    end
    
    properties
        SIGN = NaN;
    end
    
    methods (Static)
        test;
    end
    
    methods
        function obj = hystfunc(z1, f1, z2, f2, name, epsilon)
            obj.f1 = f1;
            obj.f2 = f2;
            obj.z1 = z1;
            obj.z2 = z2;
            
            obj.z0 = NaN;
            obj.sign = NaN;
            
            if nargin > 5
                obj.epsilon = epsilon;
            else
                obj.epsilon = 0;
            end
            
            if nargin > 4
                obj.name = name;
            end
        end
        
        y = feval(obj, z, varargin);
        
        function h = fplot(obj, varargin)
            %FPLOT Overloaded fplot function.
            %
            % See also FPLOT
            %%
            
            if nargin > 1 && ~ischar(varargin{1})
                zint = varargin{1};
                varargin = varargin(2:end);
            else
                zint = [-5 5];
            end
            
            zval  = zint(1):.1:zint(end);
            fval1 = zeros(size(zval));
            fval2 = zeros(size(zval));
            
            for i = 1:length(zval)
                fval1(i) = feval(obj, zval(i));
            end
            for i = length(zval):-1:1
                fval2(i) = feval(obj, zval(i));
            end
            
            h = plot(zval, [fval1; fval2], varargin{:});
            legend('->-', '-<-');
        end
        
        function varargout = subsref(obj, s)
            %SUBSREF Overloaded subsref function.
            %
            % See also SUBSREF
            %%
            switch s(1).type
                case '()'
                    varargout = {feval(obj, s.subs{:})};
                otherwise
                    varargout{:} = builtin('subsref',obj,s);
            end
        end

    end
    
end

