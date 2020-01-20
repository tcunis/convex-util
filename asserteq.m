function asserteq(test, exp, varargin)
% Throws an exception if |test| != |exp|.
%
%% Usage & description
%
%   asserteq(test, exp)
%
% Compares values and throws exception with default message.
%
%   asserteq(..., msg)
%   asserteq(..., msgID, msg)
%
% Compares values and throws exception with message ID (if given) and 
% provided message. String representations of test and expected values are 
% provided to the message.
%
%   asserteq(..., msg, A1,...,An)
%   asserteq(..., msgID, msg, A1,...,An)
%
% Compares values and throws exception with message ID (if given), provided
% message and additional parameters A1,...,An. String representations of 
% test and expected values are provided to the message as final attributes.
%   
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2018-09-09
% * Changed:    2018-09-09
%
%%

if isempty(varargin)
    varargin = {'Expected (%s), but got (%s).\n'};
end

assert(length(test) == length(exp) && all(test == exp), varargin{:}, num2str(exp), num2str(test));

end

