function [data, y] = coco_anonym(~, data, u)
    f = data{1};
    y = f(u);
end