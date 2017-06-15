function [ prob ] = coco_setup( prob )
%COCO_SETUP Creates and setups a COCO prob for trim condition continuation.
%
%% Usage and description
%   
%   prob = coco_setup
%   prob = coco_setup(prob)
%
% Setups the COCO prob; if no prob is given, a new one is created.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2016-12-20
% * Changed:    2017-01-09
%%

if nargin < 1 || isempty(prob)
    prob = coco_prob;
end

prob = coco_set(prob, 'ode', 'vectorized', false);
prob = coco_set(prob, 'cont', 'ItMX', 550);

end

