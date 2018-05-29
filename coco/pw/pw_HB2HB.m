function prob = pw_HB2HB(prob, oid, varargin)
% STart continuation of piece-wise Hopf bifurcations.
%
%% Usage and description
%   
%   PROB = ODE_HB2HB(PROB, OID, VARARGIN)
% 
% with
%   VARARGIN = { RUN [SOID] LAB ... }
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
% See PW_PW2EP, ODE_HB2HB
%
%%

grammar   = 'RUN [SOID] LAB';
args_spec = {
     'RUN', 'cell', '{str}',  'run',  {}, 'read', {}
    'SOID',     '',   'str', 'soid', oid, 'read', {}
     'LAB',     '',   'num',  'lab',  [], 'read', {}
  };
opts_spec = {};
str  = coco_stream(varargin{:});
args = coco_parse(grammar, args_spec, opts_spec, str);

sol_type = coco_read_tb_info(args.soid, args.run, args.lab, 'sol_type');
if isempty(sol_type)
  sol_type = guess_sol_type(args.soid, args.run, args.lab);
end

assert(~isempty(sol_type), ...
  '%s: could not determine type of saved solution', mfilename);

ctor_nm = sprintf('pw_%s2HB', sol_type);
if any(exist(ctor_nm, 'file') == [2 3 6])
  ctor = str2func(ctor_nm);
  prob = ctor(prob, oid, str.put(args.run, args.soid, args.lab));
else
  error('%s: could not find piece-wise HB constructor for solution type ''%s''', ...
  	mfilename, sol_type);
end

end

function sol_type = guess_sol_type(oid, run, lab)
  tbid = coco_get_id(oid, 'ep');
  data = coco_read_solution(tbid, run, lab, 'data');
  if ~isempty(data)
    sol_type = 'ep';
    return
  end
  run_data = coco_read_solution(run, lab, 'run');
  switch run_data.sol_type
    case 'HB'
      sol_type = '';
    otherwise
      sol_type = run_data.sol_type;
  end
end
