function [X, Y, Z] = prepareContourData(x, y, z, m, n)
%PREPARECONTOURDATA     Prepares tabled data for contour plot.
%
% Input vectors x, y, z are of length m*n each; output matrices X, Y, Z are
% of dimensions 1xm, 1xn, nxm, respectively.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2017-05-29
% * Changed:    2017-05-29
%
%%

X = zeros(1, m);
Y = zeros(1, n);
Z = zeros(n, m);

for i = 1:m
    X(i) = x(i);
    for j = 1:n
        if i == 1, Y(j) = y(m*(j-1)+1); end %do once per iteration of i
        
        Z(j,i) = z(m*(j-1)+i);
    end
end     

end