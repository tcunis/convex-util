function [ h ] = coco_plot3( bd, varx, vary, varz, type_idxs, plotargin, varargin )
%COCO_PLOT Plots results of continuation in two dimensions.
%
%% Usage and description
%   
%   [h] = coco_plot(bd, varx | {varx, [varx_idx], [varx_conv]}, 
%                       vary | {vary, [vary_idx], [vary_conv]},
%                       varz | {varz, [varz_idx], [varz_conv]},
%                       {} | bd_type | bd_idxs | {bd_type, tp_idxs},
%                       {} | ax | linespec | {ax, linespec},
%                       [displayname], ['hold off'])
%
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2016-12-20
% * Changed:    2017-01-10
%
%% See also
%
% See PLOT.
%
%%


%% Select arguments
if ~iscell(plotargin),  plotargin = {plotargin};    end

for i=1:length(plotargin)
    arg = plotargin{i};
    if ~exist('ax','var') && isa(arg, 'Axes'),             ax = arg;    continue; end
    if ~exist('linespec','var') && ischar(arg),      linespec = arg;    continue; end
end
if ~exist('ax','var'),                                   ax = gca;              end
if ~exist('linespec','var'),                       linespec = '';               end

for i=1:length(varargin)
    arg = varargin{i};
    if ~exist('holdoff','var') && strcmp(arg, 'hold off'), holdoff = 1; continue; end
    if ~exist('dispname','var'),                      dispname = arg; continue; end
end
if ~exist('holdoff','var'),                              holdoff = 0;           end
if ~exist('dispname','var'),                          dispname = {};            end

%% Select data
Xvec = coco_bd_data(bd, varx, type_idxs);
Yvec = coco_bd_data(bd, vary, type_idxs);
Zvec = coco_bd_data(bd, varz, type_idxs);


%% Plot
h = plot3(ax, Xvec, Yvec, Zvec, linespec);

%% Set displayname
if ~iscell(dispname)
    h.DisplayName = dispname;
end

%% Hold on/off
if holdoff
    hold off
else
    hold on
end

end