function [t,y,yi] = ode1d(f,tspan,y0,options)
% Discrete ODE solver.

if ~exist('options','var')
    options = optimset('Display','none', 'Algorithm','levenberg-marquardt');
end

t  = tspan;
y  = zeros(length(tspan),length(y0));

y(1,:) = y0;

yi = y;

for k = 2:length(tspan)
    y(k,:) = y(k-1,:) + (t(k)-t(k-1))*f(t(k),y(k-1,:)')';
    
    yi(k,:) = fsolve(@(x) yi(k-1,:) + (t(k)-t(k-1))*f(t(k),x')' - x, yi(k-1,:), options);
end
