function prob = pw_ep2HB(prob, oid, varargin)
% Starts continuation of Hopf bifurcations of piece-wise equilibria.
%
%% Usage and description
%   
%   PROB = pw_ep2HB((PROB, OID, RUN, [SOID], LAB, [OPTS])
%
% with
%   OPTS :== '-ep-end' | '-end-ep' | '-var' VECS
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2018-03-13
% * Changed:    2018-03-13
%
%% See also
%
% See PW_PW2EP, ODE_EP2HB.
%
%%

grammar   = 'RUN [SOID] LAB [OPTS]';
args_spec = {
     'RUN', 'cell', '{str}',  'run',  {}, 'read', {}
    'SOID',     '',   'str', 'soid', oid, 'read', {}
     'LAB',     '',   'num',  'lab',  [], 'read', {}
  };
opts_spec = {
  '-ep-end',       '',    '',    'end', {}
  '-end-ep',       '',    '',    'end', {}
  };
args = coco_parse(grammar, args_spec, opts_spec, varargin{:});

[sol, data] = ep_read_solution(args.soid, args.run, args.lab);

pw = data.pw;
switch pw.dir
    case '<'
        phi0 = pw.phi0 - pw.eps*pw.cnt;
    case '>'
        phi0 = pw.phi0 + pw.eps*pw.cnt;
    otherwise
        error('%s: Undefined direction ''%s''.', mfilename, pw.dir);
end

data = ode_init_data(prob, data, oid, 'ep', 'pw');
[prob, data] = ep_add(prob, data, sol, '-no-test', '-cache-jac');
[prob, data] = ep_add_var(prob, data, sol.var.v);
prob = ep_add_HB(prob, data, sol);
prob = ode_add_tb_info(prob, oid, 'ep', 'ep', 'ep', ep_sol_info('HB'));

prob = ode_add_anonym(prob, 'boundary', pw.phihan, 'regular', 'phi');
prob = coco_add_event(prob, 'PW', 'boundary', 'phi', pw.dir, phi0);

end

