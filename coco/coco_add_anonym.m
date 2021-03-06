function prob = coco_add_anonym(prob, fid, f, type_specs, varargin)
% Adds an anonymous function instance.
%
%% Usage and description
%   
%   PROB = coco_add_anonym(PROB, FID, @F, TYPE_SPEC, OPTS)
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2018-01-21
% * Changed:    2018-01-21
%
%% See also
%
% See COCO_ADD_FUNC.
%
%%

    prob = coco_add_func(prob, fid, @coco_anonym, {f}, type_specs, varargin{:});
end