function [ varargout ] = coco_plot3( bd, varx, vary, varz, type_idxs, plotargin, varargin )
%COCO_PLOT Plots results of continuation in two dimensions.
%
%% Usage and description
%   
%   [h] = coco_plot(bd, varx | {varx, [varx_idx], [varx_conv]}, 
%                       vary | {vary, [vary_idx], [vary_conv]},
%                       varz | {varz, [varz_idx], [varz_conv]},
%                       {} | bd_type | bd_idxs | {bd_type, tp_idxs},
%                       {} | ax | linespec | {ax, linespec},
%                       [displayname], [plothandle])
%
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2016-12-20
% * Changed:    2018-03-04
%
%% See also
%
% See PLOT3.
%
%%


%% Select arguments
if ~exist('type_idxs', 'var')
    type_idxs = {};
elseif ~iscell(type_idxs)
    type_idxs = {type_idxs};
end
if ~exist('plotargin', 'var')
    plotargin = {};
elseif ~iscell(plotargin)
    plotargin = {plotargin};    
end

for i=1:length(plotargin)
    arg = plotargin{i};
    if ~exist('ax','var') && isa(arg, 'Axes'),             ax = arg;    continue; end
    if ~exist('linespec','var') && ischar(arg),      linespec = arg;    continue; end
end
if ~exist('ax','var'),                                   ax = gca;              end
if ~exist('linespec','var'),                       linespec = '';               end

for i=1:length(varargin)
    arg = varargin{i};
    if ~exist('dispname','var') && ischar(arg),       dispname = arg; continue; end
    if ~exist('plothan','var') && isa(arg,'function_handle'), plothan = arg;    end
end
if ~exist('dispname','var'),                          dispname = {};            end
if ~exist('plothan','var'),                           plothan = @plot3;         end

%% Select data
Xvec = coco_bd_data(bd, varx, type_idxs);
Yvec = coco_bd_data(bd, vary, type_idxs);
Zvec = coco_bd_data(bd, varz, type_idxs);


%% Plot
h = plothan(ax, Xvec, Yvec, Zvec, linespec);

hold on

%% Unstable plot
if ~isempty(type_idxs) && strcmp(type_idxs{1}, 'stab') && ~isnumeric(type_idxs{end})
    coco_plot3(bd, varx, vary, varz, [type_idxs {0}], {ax, [linespec '--']}, plothan);
end

%% Set displayname
if ~iscell(dispname)
    h.DisplayName = dispname;
end

if nargout > 0
    varargout{:} = h;
end

end