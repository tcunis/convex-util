classdef linss < ss
    %LINSS Linearized state-space model.
   
    properties
        Alin;
        Blin;
        Clin;
        Dlin;
        
        x0;
        u0;
        p0;
    end
    
    methods (Static)
        [obj, x0, y0, u0, mu0] = linearize(nlsys, x0, u0, mu0);
    end
    
    methods
        function obj = linss(A, B, C, D, x0, u0, p0)
            %LINSS
            if iscell(x0), x0 = cell2mat(x0); end
            if iscell(u0), u0 = cell2mat(u0); end
            if iscell(p0), p0 = cell2mat(p0); end
            
            obj@ss( (A(x0, u0, p0)),  ...
                    (B(x0, u0, p0)),  ...
                    (C(x0, u0, p0)),  ...
                    (D(x0, u0, p0))   );
                
            obj.Alin = A; obj.Blin = B; obj.Clin = C; obj.Dlin = D;
            obj.x0 = x0;         obj.u0 = u0;          obj.p0 = p0;
        end
        
        function varargout = subsref(obj, s)
            switch s(1).type
                case '()'
                if length(s.subs) < 3, p0 = 0; else, p0 = s.subs{3}; end
                varargout = {linss(obj.Alin, obj.Blin, obj.Clin, obj.Dlin, ...
                              s.subs{1}, s.subs{2}, p0)};
                varargout{1}.StateName  = obj.StateName;
                varargout{1}.InputName  = obj.InputName;
                varargout{1}.OutputName = obj.OutputName;
                otherwise
                varargout{:} = builtin('subsref',obj,s);
            end
        end
        
        function J = jacobian(obj, v)
            J = obj.A;
            
            if nargin > 1
                J = J(v,v);
            end
        end
        
        function [rQ, Qs] = controllable(obj, v)
            if nargin <= 1 || isempty(v)
                v = 1:size(obj.B, 2);
            end
            
            Qs = ctrb(obj.A, obj.B(:,v));
            
            rQ = rank(Qs);
        end
        
        function [rQ, Qb] = observable(obj, v)
            if nargin <= 1 || isempty(v)
                v = 1:size(obj.C, 1);
            end
            
            Qb = obsv(obj.A, obj.C(v,:));
            
            rQ = rank(Qb);
        end
    end
end