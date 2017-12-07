% Tests of the hystfunc class and methods.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2017-03-30
% * Changed:    2017-03-30
%
%% Variables
%
% * |f|      :  function with hysteresis
% * |f1|     :  left-hand side sub-function
% * |f2|     :  right-hand side sub-function
% * |z|      :  variable(s) of f
% * |z1|     :  boundary of right-to-left hysteresis
% * |z2|     :  boundary of left-to-right hysteresis
%
%%

f1 = @(~) -3;
f2 = @(~)  3;

% no hysteresis (step)
% z1 = z2
st = hystfunc(0, f1, 0, f2);

% inner hysteresis
% z1 < z2
hi = hystfunc(-1, f1, 1, f2);

% outer hysteresis
% z1 > z2
ho = hystfunc(1, f1, -1, f2);

%% Plots
hfigure('hystfunc-test-step')
clf
fplot(st, [-5 5]);
set(gca, 'YLim', [-5 5]);

hfigure('hystfunc-test-inner')
clf
fplot(hi, [-5, 5]);
set(gca, 'YLim', [-5 5]);

hfigure('hystfunc-test-outer')
clf
fplot(ho, [-5, 5]);
set(gca, 'YLim', [-5 5]);

