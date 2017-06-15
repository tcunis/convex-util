function varargout = hfigure( id, varargin )
%HFIGURE Creates and/or returns the figure with given ID string.
%
%% Usage and description
%
%   hfigure(id)
%   hfigure(id, 'PropertyName', propertyvalue,...)
%   h = figure(...)
%
% Input |id| is a unique string identifier for this figure. For further
% usage of optional arguments, see FIGURE.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2016-12-09
% * Changed:    2016-12-19
%
%% See also
%
% See also FIGURE.
%
%%

% hashed id needs to be in [1, 2147483646]
idhash = mod(string2hash(id)-1, 2147483646)+1;

h = figure(idhash,  varargin{:});

%h.id = id;

if strcmp(h.NumberTitle, 'on')
    h.NumberTitle = 'off';
    name = ['Figure ' id];
    if ~isempty(h.Name)
        name = [name ': ' h.Name];
    end
    h.Name = name;
end

if nargout > 0
    varargout = {h};
end

end

