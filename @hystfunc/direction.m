function [sign, z0] = direction(obj, z, sign, z0, epsilon)
%GETSIGN Determine direction of hysteresis.
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
% * |z|      :  variable(s) of f
% * |z0|     :  last value of z
%
%%

if nargin < 5
    epsilon = 0;
end

%% Pre-defined direction
if ~isnan(obj.SIGN)
    sign = obj.SIGN;
    z0   = z;
%% No change
elseif abs(z - obj.z0) <= epsilon
    % nothing to do
else
    %% Left to right
    if z > z0
        sign = 1;
    %% Right to left
    elseif z < z0
        sign = -1;
    end
    z0 = z;
end

end