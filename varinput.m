function varargout = varinput(arg)
%VARINPUT Decomposes variable cell input.
%
%% Usage and description
%
%   [out1, out2, ...] = varinput({arg1, arg2, ...})
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2017-06-23
% * Changed:    2017-06-23
%
%%

assert(nargout <= length(arg), 'Not enough input arguments.');

varargout = arg;


end
