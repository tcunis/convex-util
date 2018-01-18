function data = coco_bd_data(bd, var, varargin) %type_idxs, default)
%COCO_BD_DATA Retrieves column data of continuation.
%
%% Usage and description
%   
%   [h] = coco_bd_data(bd, var | {var, [var_idx], [var_conv]}, 
%                      [{} | bd_type | bd_idxs | {bd_type, tp_idxs | 'end'}
%                          | func | {func, [arg], [par]}],
%                      [default]
%                     )
%
% where 
%   func ::= 'min' | 'max' | 'zero' | 'nzero' | 'stab' | FUNCTION_HANDLE
%   arg  ::= arg_var | {arg_var, arg_idx}
%   par  ::= NUMERIC
%
% Retrieves column data of |bd|; the column is specified by |var| and
% |var_idx|, if given.
%
% If |func| is given, two parameters are passed to the corresponding
% function: a variable vector as specified by |arg| and a numeric value as 
% specified by |par|. Default value and interpretation of the second 
% parameter depends on the function:
%
%  * zero/nzero : tolerance; default: 0
%  * min/max    : unused
%  * stab       : stable / unstable flag; default: 1
%
% If no |arg| is given for a function, the column data as selected by |var|
% and |var_idx| is as first argument.
%
% Note, that the conversion function |var_conv| is applied at last step.
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
    elseif ~exist('bd_func', 'var') && isfunc(arg)
        bd_func = arg; bd_type = 'func';
    elseif ~exist('bd_arg', 'var') && (ischar(arg) || iscell(arg))
                                                        bd_arg  = arg;
    elseif ~exist('bd_idxs','var') && isnumeric(arg),      bd_idxs = arg;
    end
end

if ~exist('var_idx','var'),     var_idx = [];                           end
if ~exist('var_conv','var'),	var_conv = @double;                     end
if ~exist('bd_type','var'),     bd_type = '';                           end
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

switch (bd_type)
    case 'func'
        % custom function evaluation
        % nothing to do here
    case 'min'
        bd_func = @(x,~) eq(x,min(x));
    case 'max'
        bd_func = @(x,~) eq(x,max(x));
    case 'zero'
        bd_func = @(x,p) le(abs(x),p);
    case 'nzero'
        bd_func = @(x,p) gt(abs(x),p);
    case 'stab'
        bd_func = @(x,p) eq(x,~gt(p,0));
        bd_arg  = 'ep.test.USTAB';
        funcpar = 1;
    otherwise
        bd_func = {};
end

if ~isempty(bd_func)
    % determine argument data
    if ~isempty(bd_arg) %&& ~all(strcmp(var, bd_arg))
        argdata = coco_bd_data(bd, bd_arg);
    else
        argdata = data(var_idx,:);
    end
    
    % determine function parameter
    if ~isempty(bd_idxs)
        funcpar = bd_idxs;
    elseif ~exist('funcpar', 'var')
        funcpar = 0;
    end
    
    idxs = find(bd_func(argdata,funcpar));
            
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