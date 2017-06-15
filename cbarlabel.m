function [ h ] = cbarlabel( txt, varargin )
%CBARLABEL Creates and adds a labeled colorbar to the current figure.

gcc = colorbar(varargin{:});
gcc.Label.String = txt;
gcc.Label.FontSize = 16;
set(gcc.Label, 'Interpreter', 'default');

h = gcc;

end

