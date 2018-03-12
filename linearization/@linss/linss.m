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
            if ~iscell(x0), x0 = num2cell(x0); end
            if ~iscell(u0), u0 = num2cell(u0); end
            if ~iscell(p0), p0 = num2cell(p0); end
            
            obj@ss( double(A(x0{:}, u0{:}, p0{:})),  ...
                    double(B(x0{:}, u0{:}, p0{:})),  ...
                    double(C(x0{:}, u0{:}, p0{:})),  ...
                    double(D(x0{:}, u0{:}, p0{:}))   );
                
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
        
        function J = jacobian(obj)
            J = obj.A;
        end
    end
end