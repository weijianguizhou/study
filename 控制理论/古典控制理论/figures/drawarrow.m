function drawarrow(ax, x1, y1, x2, y2, style, color, headLen, headWid)
%DRAWARROW 在坐标轴的数据坐标系中绘制箭头
%   drawarrow(ax, x1, y1, x2, y2)                  单箭头：(x1,y1) -> (x2,y2)
%   drawarrow(ax, x1, y1, x2, y2, 'doublearrow')   双箭头
%   drawarrow(ax, x1, y1, x2, y2, style, color)    指定颜色（默认黑色）
%   drawarrow(..., color, headLen, headWid)        指定箭头长度/宽度（磅，默认 8/6）
%
%   说明：annotation 使用图窗归一化坐标，本函数先把数据坐标换算为
%   图窗坐标，因此调用前应确定好 ax 的 Position、xlim 与 ylim。
if nargin < 6 || isempty(style)
    style = 'arrow';
end
if nargin < 7 || isempty(color)
    color = 'k';
end
if nargin < 8 || isempty(headLen)
    headLen = 8;
end
if nargin < 9 || isempty(headWid)
    headWid = 6;
end
xl = xlim(ax);  yl = ylim(ax);
p  = ax.Position;                       % [left bottom width height]
fx = @(x) p(1) + p(3)*(x - xl(1))/(xl(2) - xl(1));
fy = @(y) p(2) + p(4)*(y - yl(1))/(yl(2) - yl(1));
if strcmp(style, 'doublearrow')
    annotation(style, [fx(x1) fx(x2)], [fy(y1) fy(y2)], 'LineWidth', 0.9, ...
        'Head1Width', headWid, 'Head1Length', headLen, ...
        'Head2Width', headWid, 'Head2Length', headLen, 'Color', color);
else
    annotation(style, [fx(x1) fx(x2)], [fy(y1) fy(y2)], 'LineWidth', 0.9, ...
        'HeadWidth', headWid, 'HeadLength', headLen, 'Color', color);
end
end
