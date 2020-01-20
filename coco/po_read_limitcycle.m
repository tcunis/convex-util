function lc = po_read_limitcycle(bd,run,pnames,vnames,varargin)
% PO_READ_LIMITCYCLE    Reads limit cycle solution.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@onera.fr>
% * Created:    2018-11-07
% * Changed:    2018-11-07
%
%%

if ~iscell(run)
    run = {'' run};
end
if ~iscell(pnames)
    pnames = {pnames};
end
if ~iscell(vnames)
    vnames = {vnames};
end

labs = coco_bd_labs(bd);

p = sort(coco_bd_data(bd,pnames,{'lab' labs}),2);

lc_min = NaN(length(p),length(vnames));
lc_max = NaN(length(p),length(vnames));

for lab=labs
    sol = po_read_solution(run{:},lab);
    
    I = all(p == sol.p);
    
    sol_var = cell2mat(cellfun(@(c) c(sol.xbp',sol.p), varargin, 'UniformOutput', false)');

    lc_min(I,:) = min(lc_min(I,:), min(sol_var,[],2)');
    lc_max(I,:) = max(lc_max(I,:), max(sol_var,[],2)');
end

lc = [
        pnames                      vnames
        num2cell(p')                num2cell(lc_min)
        num2cell(p(:,end:-1:1)')    num2cell(lc_max(end:-1:1,:))
];
