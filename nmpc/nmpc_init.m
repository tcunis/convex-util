function [ukm1,xkm1,ykm1,skm1,lkm1,vkm1,okm1] = nmpc_init(sz,xtrg,utrg,y0)
% Initialize variables for NMPC run.

ukm1 = zeros(sz.nu,sz.N) + utrg;
xkm1 = zeros(sz.nx,sz.N) + xtrg;
ykm1 = zeros(sz.ny,sz.N) + y0;
skm1 = zeros(sz.ns,1);

lkm1 = nan(sz.nl,1);
vkm1 = nan(sz.nv,1);
okm1 = nan(sz.nz,1);

% reshape
ukm1 = ukm1(:);
xkm1 = xkm1(:);
ykm1 = ykm1(:);
