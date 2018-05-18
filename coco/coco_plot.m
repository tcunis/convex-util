function [varargout] = coco_plot( bd, varx, vary, type_idxs, plotargin, varargin )
%COCO_PLOT Plots results of continuation in two dimensions.
%
%% Usage and description
%   
%   [h] = coco_plot(bd, varx | {varx, [varx_idx], [varx_conv]}, 
%                       vary | {vary, [vary_idx], [vary_conv]},
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
% See PLOT.
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
if ~exist('plothan','var'),                           plothan = @plot;          end

%% Select data
if ~isempty(bd)
    Xvec = coco_plot_data(bd, varx, type_idxs);
    Yvec = coco_plot_data(bd, vary, type_idxs);
else
    Xvec = [];
    Yvec = [];
end

%% Plot
if isempty(Yvec)
    h = plothan(ax, Xvec, linespec);
else
    h = plothan(ax, Xvec, Yvec, linespec);
end

hold on

%% Unstable plot
if ~isempty(type_idxs) && strcmp(type_idxs{1}, 'stab') && ~isnumeric(type_idxs{end})
    coco_plot(bd, varx, vary, [type_idxs {0}], {ax, [linespec '--']}, plothan);
end

%% Set displayname
if ~iscell(dispname) && ~isempty(h)
    h.DisplayName = dispname;
end

if nargout > 0
    varargout{:} = h;
end


end