function data = coco_bd_data(bd, var, varargin) %type_idxs, default)
%COCO_BD_DATA Retrieves variable data of continuation.
%
%% Usage and description
%   
%   [h] = coco_bd_data(bd, var | {var, [var_idx], [var_conv]}, 
%                      [{} | bd_type | bd_idxs | {bd_type, tp_idxs | 'end'}
%                          | 'min' | 'max' | {'min' | 'max', arg}],
%                      [default]
%                     )
%
% where arg ::= arg_type | arg_idxs | {arg_type, arg_idxs}.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2017-01-10
% * Changed:    2017-01-10
%
%%


%% Select arguments
if ~iscell(var),        var = {var};                    end

% if nargin < 3
%     type_idxs = {};
% elseif ~iscell(type_idxs)
%     type_idxs = {type_idxs};
% end

for i=1:length(var)
    arg = var{i};
    if ~exist('bd_var','var'),                          bd_var = arg;
    elseif ~exist('var_idx','var') && isreal(arg),      var_idx = arg;
    elseif ~exist('var_conv','var') && isfunc(arg),     var_conv = arg;
    end
end

for i=1:length(varargin)
    arg = varargin{i};
    if ~exist('type_idxs','var') && iscell(arg),        type_idxs = arg;         
    elseif ~exist('type_idxs','var') && ~isfunc(arg),	type_idxs = {arg};  
    elseif ~exist('default', 'var') && isfunc(arg),     default = arg;        
    end
end

if ~exist('type_idxs','var'),   type_idxs = {};                         end
for i=1:length(type_idxs)
    arg = type_idxs{i};
    if ~exist('bd_type','var') && ischar(arg),          bd_type = arg;
    elseif ~exist('bd_arg', 'var') && (ischar(arg) || iscell(arg))
                                                        bd_arg  = arg;
    elseif ~exist('bd_idxs','var') && isreal(arg),      bd_idxs = arg;
    end
end

if ~exist('var_idx','var'),     var_idx = [];                           end
if ~exist('var_conv','var'),	var_conv = @double;                     end
if ~exist('bd_type','var'),     bd_type = [];                           end
if ~exist('bd_arg', 'var'),     bd_arg  = [];                           end
if ~exist('bd_idxs','var'),     bd_idxs = [];                           end
if ~exist('default','var'),     default = @zeros;                       end

%% Empty variable request
if isempty(var)
    pseudo = coco_bd_data(bd, 'PT', type_idxs);
    
    data = default(size(pseudo));
else
    
%% Get variable data
data = coco_bd_col(bd, bd_var);

%% Select variable index
if isempty(var_idx)
    var_idx = 1:size(data, 1);
end

%% Select bifurcation type and index, if given
if any(strcmp(bd_type, {'min','max'}))
    minmax = bd_type;
    if ~isempty(bd_arg) && ~all(strcmp(var, bd_arg))
        argdata = coco_bd_data(bd, bd_arg);
    else
        argdata = data(var_idx);
    end
    [~, idxs] = feval(minmax, argdata);
elseif ~isempty(bd_type)
    idxs = coco_bd_idxs(bd, bd_type);
    if strcmp(bd_arg, 'end')
        idxs = idxs(end);
    elseif ~isempty(bd_idxs)
        idxs = idxs(bd_idxs);
    end
elseif ~isempty(bd_idxs)
    idxs = bd_idxs;
else
    idxs = 1:size(data, 2);
end

%% Convert and return data
data = var_conv(data(var_idx,idxs));

end

end

function tf = isfunc(A)
%ISFUNC     Determines whether input is function handle.

    tf = isa(A, 'function_handle');
end