function [q,A,b] = fit_polygon(p,x,opts)
% Fits a polygon {x: Ax <= b} into {x: p(x) <= 0}.

if nargin < 3
    opts = [];
end
if nargin < 2
    x = p.varname;
end

A = zeros(2^length(x),length(x));
b = -ones(2^length(x),1);

% positive corner points
eip = zeros(length(x));

for i=1:length(x)
    pi = subs(p,part(x,i),zeros(length(x)-1,1));
    
    [ebnds,~,~,info] = pcontain(pi, x(i)^2, [], opts);
    if ~info.feas
        keyboard;
    end
    eip(i,i) = sqrt(ebnds(1));
end

% negative corner points
eim = -eip;

P = combine(eip,eim);

for k=1:length(P)
    Pk = P{k};
    
    d = b(k);
    D = det(Pk);
    % Cramer's rule
    for i=1:length(x)
        Pi = Pk; Pi(:,i) = ones(length(x),1);
        A(k,i) = -d/D*det(Pi);
    end
end

q = A*x + b;

end

function [a,ai] = part(a,i)
% Removes the i-th row of a.

    if isvector(a)
        ai = a(i);
        a(i) = [];
    else
        ai = a(i,i);
        a(i,:) = [];
        a(:,i) = [];
    end
end

function P = combine(a1,a2)
% Compute all permutations of elements of a1 with elements of a2.

n = length(a1);

if n == 1
    P = {a1 a2};
    return
end

%else
P1 = combine(part(a1,1),part(a2,1));

P = cellfun(@(a) {blkdiag(a1(1), a) blkdiag(a2(1), a)}, P1, 'UniformOutput', false);

P = [P{:}];

end