classdef nlp_prob
% Nonlinear problems for model-predictive control implementation.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2019-03-22
% * Changed:    2019-03-22
%
%%

properties (Access=protected)
    % Lagrangian
    lag;
    lag_grad;
    lag_hess;
    
    % Cost function
    cost;
    cost_grad;
    cost_hess;
    
    % Constraints
    eq_cstr;
    ieq_cstr;
    
    % Sensitivity
    sns;
end

methods
function [nlp,dyn,sz] = nlp_prob(f, g, sz, N, ts, j, Xf, Vf)
% Setups NLP problem.
%
%% About
%
% * Author:     Torbjoern Cunis, Dominic Liao-McPherson
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2018-11-07
% * Changed:    2018-11-07
%
%% Variables, constants, and their units
%
% * |f|        :  system function, dx/dt = f(x,u)
% * |x|        :  state vector, x = [V alpha q Theta]
% * |u|        :  input vector, u = [eta T]
%
% * |N|        :  length of horizon
% * |nx|       :  number of states, nx = #x
% * |nu|       :  number of inputs, nu = #u
% * |ts|       :  sampling time (s)
%
% * |Q|        :  state cost matrix
% * |R|        :  input cost matrix
%
% * |Xf|       :  terminal set constraint
% * |Vf|       :  terminal cost penalty
%
%%

import casadi.*

nx = sz.nx;
nu = sz.nu;
ny = sz.ny;
nd = sz.nd;

%% Symbolic representation
% parameters
x0 = SX.sym('x0',nx);           % current state
u0 = SX.sym('u0',nu);           % last control input
y0 = SX.sym('y0',ny);           % current output
Q  = SX.sym('Q',nx,nx);         % state stage cost matrix
R  = SX.sym('R',nu,nu);         % control stage cost matrix
Qf = SX.sym('Qf',nx,nx);        % state terminal cost matrix
xtrg = SX.sym('xtrg',nx,1);     % target reference
utrg = SX.sym('utrg',nu,1);
xub = SX.sym('xub',nx,1);       % state upper bound
xlb = SX.sym('xlb',nx,1);       % state lower bound
uub = SX.sym('uub',nu,1);       % input upper bound
ulb = SX.sym('ulb',nu,1);       % input lower bound
dub = SX.sym('dub',nd,1);       % input rate upper bound
dlb = SX.sym('dlb',nd,1);       % input rate lower bound
yub = SX.sym('yub',ny,1);       % output upper bound
ylb = SX.sym('ylb',ny,1);       % output lower bound
gamma = SX.sym('gamma',1,1);    % constraint softening 
eps = SX.sym('eps',1,1);        % smoothing parameter

% OCP parameters
ocp = [x0;u0;y0;xtrg;utrg;eps];

% optimization problem
xk = SX.sym('xk',nx);
uk = SX.sym('uk',nu);
dk = SX.sym('dk',nu);
yk = SX.sym('yk',ny);
sk = SX.sym('sk',1);

% forward Euler dynamics (discrete)
xkp1 = xk + ts*f(xk,uk,eps);
yk0  =         g(xk,uk,eps);

if ny ~= 0
    ykp1 = yk + ts*g(xk,uk,eps);
else
    ykp1 = yk;
end

% Casadi functions
% syntax: name, inputs, outputs, input names, output names
fd  = Function('fd' , {xk,uk,eps},       {xkp1}       , {'xk','uk','eps'}, {'xkp1'});
gd  = Function('gd' , {xk,uk,eps},       {yk0 }       , {'xk','uk','eps'}, { 'yk' });
hd  = Function('hd' , {xk,uk,yk,eps},    {ykp1}  , {'xk','uk','yk','eps'}, {'ykp1'});
f_x = Function('f_x', {xk,uk,eps}, {jacobian(xkp1,xk)}, {'xk','uk','eps'}, {'f_x'});
f_u = Function('f_u', {xk,uk,eps}, {jacobian(xkp1,uk)}, {'xk','uk','eps'}, {'f_u'});
g_x = Function('g_x', {xk,uk,eps}, {jacobian(yk0, xk)}, {'xk','uk','eps'}, {'g_x'});
g_u = Function('g_u', {xk,uk,eps}, {jacobian(yk0, uk)}, {'xk','uk','eps'}, {'g_u'});
h_x = Function('h_x', {xk,uk,eps}, {jacobian(ykp1,xk)}, {'xk','uk','eps'}, {'h_x'});
h_u = Function('h_u', {xk,uk,eps}, {jacobian(ykp1,uk)}, {'xk','uk','eps'}, {'h_u'});
h_y = Function('h_y', {xk,uk,eps}, {jacobian(ykp1,yk)}, {'xk','uk','eps'}, {'h_y'});

% stage cost function
if ~exist('j','var') || isempty(j)
    j = @(x,u,~,Q,R,xtrg,utrg) 1/2*(x-xtrg)'*Q*(x-xtrg) + 1/2*(u-utrg)'*R*(u-utrg);
end

% terminal cost function
if ~exist('Vf','var') || isempty(Vf)
    Vf = @(x,Qf,xtrg,utrg,~) 1/2*(x-xtrg)'*Qf*(x-xtrg);
end

Jk  = Function('Jk', {xk,uk,sk,Q,R,xtrg,utrg}, {j(xk,uk,sk,Q,R,xtrg,utrg)}, {'xk','uk','sk','Q','R','xtrg','utrg'}, {'Jk'});
Jf  = Function('Jf', {xk,Qf,xtrg,utrg,eps}, {Vf(xk,Qf,xtrg,utrg,eps)}, {'xk' 'Qf' 'xtrg' 'utrg' 'eps'}, {'Vf'});

% stage constraints
cuk = Function('cuk',{uk,uub,ulb},{[uk-uub;ulb-uk]},{'uk','uub','ulb'},{'cuk'});
cxk = Function('cxk',{xk,xub,xlb},{[xk-xub;xlb-xk]},{'xk','xub','xlb'},{'cxk'});
cdk = Function('cdk',{dk,dub,dlb},{[dk-dub;dlb-dk]},{'dk','dub','dlb'},{'cdk'});
cyk = Function('cyk',{yk,yub,ylb},{[yk-yub;ylb-yk]},{'yk','yub','ylb'},{'cyk'});

% terminal set constraint
if ~exist('Xf','var') || isempty(Xf)
    Xf = @(x,xtrg,utrg,~) [(x-xtrg); (xtrg-x)];
end

cxf = Function('cxf',{xk,xtrg,utrg,eps},{Xf(xk,xtrg,utrg,eps)}, {'xk' 'xtrg' 'utrg' 'eps'}, {'Xf'});

% primal optimization variables
x = SX.sym('x',nx,N);   % x = [x1,x2,...]
u = SX.sym('u',nu,N);   % u = [u0,u1,...]
y = SX.sym('y',ny,N);   % y = [y1,y2,...]
s = SX.sym('s',1,N);    % s = [s1,s2,...]


% setup NMPC problem structure
[J,gx,gy,cu,cx,cd,cy,cs] = arrayfun2( ...
                    @(x,xm,u,um,y,ym,s) nlpstruct(x,xm,u,um,y,ym,s), ...
                    x, [x0 x(:,1:end-1)], u, [u0 u(:,1:end-1)], ...
                    y, [y0 y(:,1:end-1)],                       ...
                    s, 1, 'UniformOutput', false                ...
);

J  = sum([J{:}]) + Jf(x(:,end),Qf,xtrg,utrg,eps); 
                                    % cost function
gx = [gx{:}];                       % equality constraints: system dynamics
gy = [gy{:}];                       % equality constraints: system outputs
gu = [u(:,end)-utrg];               % equality constraints: system inputs
cu = [cu{:}];                       % inequality constraints: box inputs
cx = [cx{:}];                       % inequality constraints: box state
cd = [cd{:}];                       % inequality constraints: box input rates
cy = [cy{:}];                       % inequality constraints: box outputs
cf = cxf(x(:,end),xtrg,utrg,eps);   % terminal set constraint
sl = [-s; cs{:}];                   % slack positivity constraint

% number of constraints
sz.ncu = size(cu,1);
sz.ncx = size(cx,1);
sz.ncd = size(cd,1);
% sz.ncy = size(cy,1);
sz.ncf = size(cf,1);
sz.ncs = size(sl,1);


%% Lagrangian
% reshape to column vectors
x = x(:);
u = u(:);
y = y(:);
s = s(:);
gx = gx(:);
gy = gy(:);
gu = gu(:);
cu = cu(:);
cx = cx(:);
cd = cd(:);
cy = cy(:);
cf = cf(:);
cs = sl(:);

% collect similar terms
z = [u;x;y;s];          % optimization variables
g = [gx;gy;gu];         % equality constraints
h = [cu;cx;cd;cy;cf;cs];    % inequality constraints

sz.nz = length(z);
sz.ns = length(s);

nv = length(h);
nl = length(g);

% dual variables
l = SX.sym('l',nl,1);   % equality duals (= costates)
v = SX.sym('v',nv,1);   % inequality duals

sigma = SX.sym('sigma',1,1);

% Lagrangian
L = sigma*J + l'*g + v'*h;

% Hessian, Jacobian, & gradient
Lzz = hessian(L,z);
Jzz = hessian(J,z);
Lz = gradient(L,z);
Jz = gradient(J,z);
gz = jacobian(g,z);
hz = jacobian(h,z);
% sensitivity derivatives
gp = jacobian(g,ocp);
cp = jacobian(h,ocp);
Lzp = jacobian(Lz,ocp);


%% Function objects & Problem structure
% Lagrangian
nlp.lag      = Function('Lc',{ocp,z,l,v,Q,R,Qf,gamma,sigma},{L},  {'ocp','z','l','v','Q','R','Qf','gamma','sigma'},{'L'});
nlp.lag_grad = Function('dL',{ocp,z,l,v,Q,R,Qf,gamma,sigma},{Lz}, {'ocp','z','l','v','Q','R','Qf','gamma','sigma'},{'Lz'});
nlp.lag_hess = Function('HL',{ocp,z,l,v,Q,R,Qf,gamma,sigma},{Lzz},{'ocp','z','l','v','Q','R','Qf','gamma','sigma'},{'Lzz'}); 

% Cost Function
nlp.cost      = Function('Jc',{ocp,z,Q,R,Qf},{J} , {'ocp','z','Q','R','Qf'},{'J'});
nlp.cost_grad = Function('dJ',{ocp,z,Q,R,Qf},{Jz}, {'ocp','z','Q','R','Qf'},{'Jz'});
nlp.cost_hess = Function('HJ',{ocp,z,Q,R,Qf},{Jzz},{'ocp','z','Q','R','Qf'},{'Jzz'});

% Constraints
nlp.eq_cstr  = Function('g',{ocp,z},{g,gz},{'ocp','z'},{'g','G'});
nlp.ieq_cstr = Function('h',{ocp,z,uub,ulb,xub,xlb,dub,dlb,yub,ylb}, ...
                                    {h,hz},{'ocp','z','uub','ulb','xub','xlb','dub','dlb','yub','ylb'}, ...
                                                       {'c','C'});

% Sensitivity
nlp.sns = Function('Fp',{ocp,z,l,v,Q,R,Qf,gamma},{Lzp,gp},{'ocp','z','l','v','Q','R','Qf','gamma'},{'Lzp','gp'});

% Collect remaining problemsize data
sz.N  = N;
sz.nv = nv;
sz.nl = nl;

% Dynamics
dyn.f = fd;
dyn.g = gd;
dyn.h = hd;
dyn.A = f_x;
dyn.B = f_u;
dyn.C = g_x;
dyn.D = g_u;
dyn.Ci = h_x;
dyn.Di = h_u;
dyn.I  = h_y;


function [Ji,gxi,gyi,cui,cxi,cdi,cyi,csi] = nlpstruct(xi,xim,uim,uim2,yi,yim,si)
%NLPSTRUCT  Returns NLP structure for single stage.

    Ji  = Jk(xim,uim,si,Q,R,xtrg,utrg);    
    gxi = xi - fd(xim,uim,eps);
    gyi = yi - hd(xim,uim,yim,eps);
    
    dui = (uim-uim2)/ts;
    
    cui = cuk(uim,uub,ulb);
    cxi = cxk(xi, xub,xlb);
    cyi = cyk(yi, yub,ylb);
    csi = -Ji(2:end);

    cdi = cdk(dui,dub,dlb);

    Ji  = Ji(1);
end

end

end
end