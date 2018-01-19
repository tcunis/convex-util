function [data, y] = coco_anonym(~, data, u)
% Wrapper function for anonymous function call during continuation.
%
%% Usage and description
%   
% Given an anonymous function |func| in the continuation variables |u|, use
%
%   PROB = coco_add_func(PROB, FID, @coco_anonym, {func}, ...)
%
% to add a call to func(u) during the continuation.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2018-01-19
% * Changed:    2018-01-19
%
%% See also
%
% See COCO_ADD_FUNC.
%
%%

    f = data{1};
    y = f(u);
end