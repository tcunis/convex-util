function y = feval(obj, z, varargin)
%FEVAL Overloaded feval function.
%
% See also FEVAL
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2017-03-30
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


if strcmp(obj.name, 'Clift') && false %&& obj.sign < 0
    obj, z
end

[obj.sign, obj.z0] = direction(obj, z, obj.sign, obj.z0, obj.epsilon);

%% Left to right
%
%              ..... f2
%              :
%   f1 ......>..
%         z1   z2
%
if obj.sign > 0
    % left-hand side function
    if z < obj.z2
        y = obj.f1(z, varargin{:});
        
    % right-hand side function
    else
        y = obj.f2(z, varargin{:});
    end
    
%% Right to left
%
%          ..<...... f2
%          :    
%   f1 .....
%         z1   z2
%
else
    % left-hand side function
    if z <= obj.z1
        y = obj.f1(z, varargin{:});
        
    % right-hand side function
    else
        y = obj.f2(z, varargin{:});
    end
end

% %% Inner hysteresis
% %
% %          ..<...... f2
% %          :   :
% %   f1 ......>..
% %         z1   z2
% %
% if obj.z1 < obj.z2
%     % left-hand side function
%     % or left-to-right hysteresis
%     if z < obj.z1 || (obj.sign > 0 && z < obj.z2) %(obj.z0 < z && z < obj.z2)
%         y = obj.f1(z, varargin{:});
% 
%     % right-hand side function
%     % or right-to-left hysteresis
%     else
%         y = obj.f2(z, varargin{:});
%     end
% 
% %% Outer hysteresis
% %
% %          ..>...... f2
% %          :   :
% %   f1 ......<..
% %         z2   z1
% %
% else
%     % left-hand side function (z < obj.z2)
%     % or right-to-left hysteresis (sign < 0)
%     if z < obj.z2 || (obj.sign < 0 && z < obj.z1) %(obj.z0 > z && z < obj.z1)
%         y = obj.f1(z, varargin{:});
% 
%     % right-hand side function (z > obj.z1)
%     % or left-to-right hysteresis (sign > 0)
%     else
%         y = obj.f2(z, varargin{:});
%     end
% end

end