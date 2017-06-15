% Quantities with units.
%   Classes representing quantities of a dimension (base quantity),
%   derived quantity, or without dimension (dimensionless).
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2016-12-07
% * Changed:    2016-12-14
%
%% Version history
% # 0.1     Initial version:
%           *   Conversion between SI base unit and further units of the
%               implemented dimension;
%           *   String representation and display function overloading.
%
% # 0.2     Operator overloading:
%           *   Conversion function and SI base unit are abstract, constant
%               properties;
%           *   Constructor and factory method for creation of arrays of
%               quantities of the same dimension;
%           *   Overloading for conversion to double, binary relations (==,
%               ~=, <, <=, >, >=) and unary and binary operations (+, -).
% # 0.2b    *   Basic trigonometric functions (sin, cos, tan; sind, cosd,
%               tand) and inverse functions (asin, asind) for quantities of
%               the dimension of an angle.
% # 0.2c    *   Overloading of scalar multiplication (*); multiplication of
%               quantities is not supported yet!
%
%% TODO
%           Operator overloading:
%           *   Binary plus/minus with array and scalar (cf. 1 + [2 3] in
%               MATLAB);
%           *   Multiplication and division of quantities.
%
%           Trigonometric functions
%           *   All functions (cf. <https://fr.mathworks.com/help/matlab
%               /functionlist.html#trigonometry>);
%           *   Inverse functions for dimensionless quantities.
%
%           Arrays of quantities
%           *   Arrays of quantities of different dimensions.
%%
