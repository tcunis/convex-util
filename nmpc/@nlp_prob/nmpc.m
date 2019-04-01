function [T,Xt,Ut,Yt,out,res] = nmpc(nlp,dyn,sz,xtrg,utrg,tspan,espan,x0,u0,y0,args,opts)
% Run NMPC optimization.
%
%% About
%
% * Author:     Torbjoern Cunis, Dominic Liao-McPherson
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2018-11-08
% * Changed:    2018-11-08
%
%%

% default options
if ~exist('opts','var') || isempty(opts)
    opts = struct;
end
if sz.nd == 0
    % no limits on input rates
    args.dlb = [];
    args.dub = [];
end
if sz.ny == 0
    % no limits on output
    args.ylb = [];
    args.yub = [];
end
if ~isfield(args,'Xf')
    args.Xf = @(varargin) false;
    args.Kf = @(varargin) NaN;
end

% simulation time
if length(tspan) < 2
    T = tspan + [0 args.ts];
elseif length(tspan) == 2
    T = tspan(1):args.ts:tspan(end);
else
    T = tspan;
end

nsim = length(T);
neps = length(espan);

% initial optimizer guess
ukm1 = zeros(sz.nu,sz.N) + utrg(1:sz.nu);
xkm1 = zeros(sz.nx,sz.N) + xtrg;
ykm1 = zeros(sz.ny,sz.N) + y0(1:sz.ny);
skm1 = zeros(sz.ns,1);
lkm1 = zeros(sz.nl,1);
vkm1 = zeros(sz.nv,1);
tkm1 = zeros(1,sz.N);

Xt = zeros(length(x0),nsim);
Ut = zeros(length(u0),nsim);
Yt = zeros(length(y0),nsim);

res = zeros(nsim,neps);

Xt(:,1) = x0;
Ut(:,1) = u0;
Yt(:,1) = y0;

out(1:nsim-1,1:neps) = struct('ukm1',ukm1,'xkm1',xkm1,'ykm1',ykm1,'tkm1',tkm1,'vkm1',vkm1,'lkm1',lkm1,'skm1',skm1,'info',[],'epsilon',0);

fprintf('Start NMPC:\n0%%');

t = tic;

erange = 1:neps;

for i = 1:nsim-1
    for j = erange
        eps = espan(j);
        
        if args.Xf(T(i),Xt(:,i)) % switch to nominal controller
            Ut(:,i+1) = args.Kf(T(i),Xt(:,i));
            
            info.message = sprintf('Switched to nominal control at i=%d.',i);
            info.status = -Inf;
            info.time = 0;
            
            res(i,j) = 0;
        else
            [Ut(1:sz.nu,i+1),ukm1,xkm1,ykm1,skm1,lkm1,vkm1,res(i,j),info] = ...
                    nlp.nmpc_step(Xt(:,i),Ut(1:sz.nu,i),Yt(1:sz.ny,i),xtrg,utrg,eps,ukm1(:),xkm1(:),ykm1(:),skm1,lkm1,vkm1,args,sz,opts);
        end
        
        Xt(:,i+1) = full(dyn.f(Xt(:,i),Ut(:,i+1),eps)); %,T(i+1)-T(i)));
        Yt(:,i+1) = Yt(:,i) + args.ts*full(dyn.g(Xt(:,i),Ut(:,i+1),eps));

        out(i,j).ukm1(:) = ukm1;
        out(i,j).xkm1(:) = xkm1;
        out(i,j).ykm1(:) = ykm1;
        out(i,j).skm1 = skm1;
        out(i,j).lkm1 = lkm1;
        out(i,j).vkm1 = vkm1;
        out(i,j).tkm1 = T(i+1)+(0:(sz.N-1))*args.ts;

        out(i,j).flag = info.status;
        out(i,j).time = info.time;
        out(i,j).info = info;
        
        out(i,j).epsilon = eps;
    end
    
    if floor((i-1)/(nsim-1)*100/2.5) < floor(i/(nsim-1)*100/2.5)
        fprintf('-');
        if mod(floor(i/(nsim-1)*100), 10) == 0
            fprintf('%d%%', floor(i/(nsim-1)*100));
        end
    else
        fprintf('');
    end
    
    % after first iteration
    % only iterate for last epsilon
    erange = erange(end);
end

Ut = [Ut(:,2:end) Ut(:,end)];
% Yt = [Yt(:,2:end) Yt(:,end)];
res(nsim,:)  = 0;

if floor(i/(nsim-1)*100) < 100
    fprintf('100%%');
end
fprintf('\nFinish NMPC (%g iteration(s) in %g s.\n\n', i, toc(t));

end
