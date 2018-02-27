function prob = pw_isol2ep(prob, oid, f1, f2, phi, varargin)
% Start continuation of piece-wise equilibrium points from initial guess.
%
%% Usage and description
%   
%   PROB = pw_isol2ep(PROB, F1, F2, PHI, X0, [PNAMES], P0, [OPTS])
%
% with
%    F1 ::= f1 | {f1 [df1dx [df1dp]]}
%    F2 ::= f2 | {f2 [df2dx [dfxdp]]}
%   PHI ::= phi | {phi ['<'|'>'] [phi0 [epsilon]]}
%
% Starts a continuation of equilibrium points of f(x,p), where f is a 
% piece-wise defined, non-linear function
%
%            / f1(x,p)    if phi(x,p) <|> phi0;
%   f(x,p) = |
%            \ f2(x,p)    else.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2018-01-21
% * Changed:    2018-01-21
%
%% See also
%
% See ODE_ISOL2EP.
%
%%


if ~iscell(f1),   f1 = {f1};  end
if ~iscell(f2),   f2 = {f2};  end
if ~iscell(phi), phi = {phi}; end

grammar   = 'F [DFDX [DFDP]] X0 [PNAMES] P0 [OPTS]';
args_spec = {
       'F',     '',     '@',    'fhan', [], 'read', {}
    'DFDX',     '',  '@|[]', 'dfdxhan', [], 'read', {}
    'DFDP',     '',  '@|[]', 'dfdphan', [], 'read', {}
      'X0',     '', '[num]',      'x0', [], 'read', {}
  'PNAMES', 'cell', '{str}',  'pnames', {}, 'read', {}
      'P0',     '', '[num]',      'p0', [], 'read', {}
  };
opts_spec = {
  '-ep-end',     '', '',  'end', {}
  '-end-ep',     '', '',  'end', {}
     '-var', 'vecs', [], 'read', {}
  };
pw_spec = {
     'PHI',     '',     '@',  'phihan',  [], 'read', {}
     'DIR',     '',   'str',     'dir', '>', 'read', {}
    'PHI0',     '',   'num',    'phi0',   0, 'read', {}
     'EPS',     '',   'num',     'eps',   0, 'read', {}
  };
[args, opts] = coco_parse(grammar, args_spec, opts_spec, f1{:}, varargin{:});
[pw] = coco_parse('PHI [DIR] [PHI0 [EPS]]', pw_spec, {}, phi{:});

[sol, data] = ep_read_solution('', '', args);

pw.f1 = f1;
pw.f2 = f2;
pw.cnt = 0;

data.pw = pw;

data = ode_init_data(prob, data, oid, 'ep', 'pw');

if ~isempty(opts.vecs)
  assert(isnumeric(opts.vecs) && data.xdim == size(opts.vecs,1), ...
    '%s: incompatible specification of vectors of perturbations', ...
    mfilename);
  [prob, data] = ep_add(prob, data, sol, '-cache-jac');
  prob = ep_add_var(prob, data, opts.vecs);
  prob = ode_add_tb_info(prob, oid, 'ep', 'ep', 'ep', ep_sol_info('VAR'));
else
  prob = ep_add(prob, data, sol);
  prob = ode_add_tb_info(prob, oid, 'ep', 'ep', 'ep', ep_sol_info());
end

prob = ode_add_anonym(prob, 'boundary', pw.phihan, 'regular', 'phi');
prob = coco_add_event(prob, 'PW', 'boundary', 'phi', pw.dir, pw.phi0);




end