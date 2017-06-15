function [ obj, x0, y0, u0, mu0 ] = linearize( nlsys, x0, u0, mu0 )
%LINEARIZE  Linearizes a non-linear system at given equilibrium.
%
% The non-linear system is represented by the open-loop function |fop|.
%
% The linear system is represented by its state-space model,
%
% d/dt x = A*(x - x0) + B*(u - u0)
% y - y0 = C*(x - x0) + D*(u - u0)
%
% with the state, input, output, and feed-through matrices A, B, C, D;
% and x, u, y the state, input, and output vector, respectively.
%
%% Usage and description
%
%   [sys] = linss.linearize(fop, x0, u0, p0)
%   [---] = linss.linearize({fop, hout}, --------)
%   [sys, x0, y0, u0, mu0] = linss.linearize(-----)
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2017-02-15
% * Changed:    2017-02-15
%
%% Variables, constants, and their units
%
% * |mu|       :  parameter vector
% * |mu0|      :  parameter vector at equilibrium
% * |f|        :  non-linear, open-loop function |dx/dt = f(x, u, mu)|
% * |h|        :  non-linear output function |y| = h(x, u, mu)|
% * |u|        :  input vector
% * |u0|       :  input vector at equilibrium
% * |x|        :  state vector
% * |x0|       :  state vector at equilibrium
% * |y|        :  output vector
% * |y0|       :  output vector at equilibrium
%%

if iscell(nlsys) && length(nlsys) > 1
    fop  = nlsys{1};
    hout = nlsys{2};
else
    fop  = nlsys;
    hout = @(x, u, ~) x;
end

if nargin < 4
    mu0 = 0;
end


%% System parameter
% d/dt x = A*(x - x0) + B*(u - u0)
% y - y0 = C*(x - x0) + D*(u - u0)

% output at equilibrium 
y0 = hout(x0, u0, mu0);

% state degree
n = length(x0);
% number of inputs
p = length(u0);
% number of outputs
q = length(y0);
% number of parameters
r = length(mu0);


%% Symbolics
% state vector
X = sym('X', [n 1]);
% input vector
U = sym('U', [p 1]);
% parameter vector
Mu = sym('Mu', [r 1]);

% open-loop function
f = fop(X, U, Mu);
% output function
h = hout(X, U, Mu);


%% Partial derivation
% state, input, output, and feed-through matrices, i.e.
% A = df/dx, B = df/du, C = dh/dx, D = dh/dy
% as functions of x0, u0, p0

% partial derivatives
dfdx = sym('A', [n n]);
dfdu = sym('B', [n p]);
dhdx = sym('C', [q n]);
dhdu = sym('D', [q p]);

% component-wise partial derivation of f and h w.r.t. x
for i = 1:n
    % partial derivative of f and h 
    % w.r.t. the i-th component of x
    dfdx(:,i) = diff(f, X(i));
    dhdx(:,i) = diff(h, X(i));
end
% component-wise partial derivation of f and h w.r.t. u
for i = 1:p
    % partial derivative of f and h
    % w.r.t. the i-th component of u
    dfdu(:,i) = diff(f, U(i));
    dhdu(:,i) = diff(h, U(i));
end

%% Linear system
% matrices A, B, C, D as functions of x, u, mu
A = symfun(dfdx, [X; U; Mu]);
B = symfun(dfdu, [X; U; Mu]);
C = symfun(dhdx, [X; U; Mu]);
D = symfun(dhdu, [X; U; Mu]);

obj = linss(A, B, C, D, x0, u0, mu0);

end

