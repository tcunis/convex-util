function nbytes = writeBifurcation(obj, bd, varargin)

data = cell(size(varargin));

for i=1:length(varargin)
    var = varargin{i};
    
    if ~iscell(var)
        var = {var};
    end
    
    data{i} = coco_bd_data(bd, var{:});
end

data = vertcat(data{:});

nbytes = obj.writeData(data);
