function prob = pw_BP2ep(prob, oid, varargin)
% Switch to secondary branch of piece-wise equilibrium points at branch.
%
%% Usage and description
%   
%   PROB = pw_BP2ep((PROB, OID, RUN, [SOID], LAB, [OPTS])
%
% with
%   OPTS :== '-ep-end' | '-end-ep' | '-var' VECS
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
% See PW_ISOL2EP, ODE_BP2EP.
%
%%

grammar   = 'RUN [SOID] LAB [OPTS]';
args_spec = {
     'RUN', 'cell', '{str}',  'run',  {}, 'read', {}
    'SOID',     '',   'str', 'soid', oid, 'read', {}
     'LAB',     '',   'num',  'lab',  [], 'read', {}  
  };
opts_spec = {
  '-ep-end',     '', '',  'end', {}
  '-end-ep',     '', '',  'end', {}
     '-var', 'vecs', [], 'read', {}
  };
[args, opts] = coco_parse(grammar, args_spec, opts_spec, varargin{:});

if ~coco_exist('NullItMX', 'class_prop', prob, 'cont')
  % Compute improved tangent to secondary branch to avoid detection of
  % spurious FP that can happen at transcritical bifurcation point.
  prob = coco_set(prob, 'cont', 'NullItMX', 1);
end
[sol, data] = ep_read_solution(args.soid, args.run, args.lab);

pw = data.pw;

data = ode_init_data(prob, data, oid, 'ep', 'pw');

if ~isempty(opts.vecs)
  assert(isnumeric(opts.vecs) && data.xdim == size(opts.vecs,1), ...
    '%s: incompatible specification of vectors of perturbations', ...
    mfilename);
  [prob, data] = ep_add(prob, data, sol, '-cache-jac');
  prob = ep_add_var(prob, data, opts.vecs);
  prob = ode_add_tb_info(prob, oid, 'ep', 'ep', 'ep', ep_sol_info('VAR'));
elseif isfield(sol, 'var')
  [prob, data] = ep_add(prob, data, sol, '-cache-jac');
  prob = ep_add_var(prob, data, sol.var.v);
  prob = ode_add_tb_info(prob, oid, 'ep', 'ep', 'ep', ep_sol_info('VAR'));
else
  prob = ep_add(prob, data, sol);
  prob = ode_add_tb_info(prob, oid, 'ep', 'ep', 'ep', ep_sol_info());
end

prob = ode_add_anonym(prob, 'boundary', pw.phihan, 'regular', 'phi');
prob = coco_add_event(prob, 'PW', 'boundary', 'phi', pw.dir, pw.phi0);


end