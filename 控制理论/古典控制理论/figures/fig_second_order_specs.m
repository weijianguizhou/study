function fig_second_order_specs
%FIG_SECOND_ORDER_SPECS 二阶系统单位阶跃响应的时域性能指标
%   （原「二阶系统时域性能指标.jpg」重绘）
%   取 zeta = 0.5、omega_n = 1，标注 t_d、t_r、t_p、t_s、M_p 与允许误差带。
%   运行后在本文件夹生成「二阶系统时域性能指标.png」。
close all;

blue  = [0.0000 0.4470 0.7410];      % 响应曲线
red   = [0.8500 0.3250 0.0980];      % 超调、误差带
green = [0.0000 0.5000 0.0000];      % 时间指标
gray  = [0.5000 0.5000 0.5000];      % 辅助线

zeta = 0.5;  wn = 1;
wd   = wn*sqrt(1-zeta^2);
beta = acos(zeta);
t    = linspace(0, 11.5, 8000);
x    = 1 - exp(-zeta*wn*t)/sqrt(1-zeta^2).*sin(wd*t+beta);

% 特征时刻
t10 = crossing(t, x, 0.10);
t50 = crossing(t, x, 0.50);
t90 = crossing(t, x, 0.90);
tr  = crossing(t, x, 1.00);                     % 首次到达稳态值
[mp, ip] = max(x);
tp  = t(ip);
ts5 = (-log(0.05) - log(sqrt(1-zeta^2)))/(zeta*wn);   % ±5% 调整时间

figure('Units','centimeters','Position',[2 2 16 9.5],'Color','w');
ax = axes; hold(ax,'on');
plot(ax, t, x, '-', 'Color', blue, 'LineWidth', 1.8);

% 先固定坐标范围（annotation 箭头按图窗坐标定位，须在定界后再画）
xlim(ax, [0 13.2]); ylim(ax, [-0.46 1.52]);
xticks(ax, []);
yticks(ax, [0 0.1 0.5 0.9 1.0]);
yticklabels(ax, {'0','0.1','0.5','0.9','1.0'});
ax.XAxisLocation = 'origin';
box(ax, 'off');
set(ax, 'FontName','Times New Roman','FontSize',11, ...
    'TickDir','in','TickLength',[0.015 0.015],'LineWidth',0.9);

% 稳态值与各级辅助线
plot(ax, [0 13.2], [1 1],        '-', 'Color', gray, 'LineWidth', 0.8);
plot(ax, [0 t10],  [0.1 0.1],    ':', 'Color', gray);
plot(ax, [0 t50],  [0.5 0.5],    ':', 'Color', gray);
plot(ax, [0 t90],  [0.9 0.9],    ':', 'Color', gray);
plot(ax, [t50 t50],[0 0.5],      ':', 'Color', gray);
plot(ax, [tr tr],  [0 1],        ':', 'Color', gray);
plot(ax, [tp tp],  [0 mp],       ':', 'Color', gray);
plot(ax, [ts5 ts5],[0 1.05],     ':', 'Color', gray);
% ±5% 允许误差带
plot(ax, [4.6 13.2], [1.05 1.05], '--', 'Color', red, 'LineWidth', 1.0);
plot(ax, [4.6 13.2], [0.95 0.95], '--', 'Color', red, 'LineWidth', 1.0);

% M_p
drawarrow(ax, tp, 1, tp, mp, 'doublearrow', red);
text(ax, tp-0.16, (1+mp)/2, '$M_{\mathrm{p}}$', 'Interpreter','latex', ...
    'Color', red,'FontSize',11,'HorizontalAlignment','right', ...
    'VerticalAlignment','middle');

% t_d、t_r、t_p、t_s 标注箭头
drawarrow(ax, 0, 0.22, t50, 0.22, 'doublearrow', green);
text(ax, t50+0.16, 0.22, '$t_{\mathrm{d}}$', 'Interpreter','latex', ...
    'Color', green,'FontSize',11,'HorizontalAlignment','left', ...
    'VerticalAlignment','middle');

drawarrow(ax, 0, -0.10, tr, -0.10, 'doublearrow', green);
text(ax, tr+0.16, -0.10, '$t_{\mathrm{r}}$', 'Interpreter','latex', ...
    'Color', green,'FontSize',11,'HorizontalAlignment','left', ...
    'VerticalAlignment','middle');

drawarrow(ax, 0, -0.24, tp, -0.24, 'doublearrow', green);
text(ax, tp+0.16, -0.24, '$t_{\mathrm{p}}$', 'Interpreter','latex', ...
    'Color', green,'FontSize',11,'HorizontalAlignment','left', ...
    'VerticalAlignment','middle');

drawarrow(ax, 0, -0.38, ts5, -0.38, 'doublearrow', green);
text(ax, ts5+0.16, -0.38, '$t_{\mathrm{s}}$', 'Interpreter','latex', ...
    'Color', green,'FontSize',11,'HorizontalAlignment','left', ...
    'VerticalAlignment','middle');

% 「允许误差」说明
text(ax, 6.9, 1.42, '允许误差', 'FontName','SimSun','Color', red,'FontSize',11);
drawarrow(ax, 7.95, 1.36, 7.85, 1.09, 'arrow', red);
drawarrow(ax, 8.45, 1.36, 8.35, 0.91, 'arrow', red);

% ±5% 误差带宽度标注（置于曲线右端之外，避免与曲线重叠）
drawarrow(ax, 12.55, 0.95, 12.55, 1.05, 'doublearrow', red, 5, 4);
text(ax, 12.55, 1.08, '0.05', 'Color', red,'FontSize',9, ...
    'HorizontalAlignment','center','VerticalAlignment','bottom');

text(ax, -1.05, 1.14, '$x_{\mathrm{o}}(t)$', 'Interpreter','latex', ...
    'FontSize',12,'HorizontalAlignment','right','Clipping','off');
text(ax, 13.35, -0.12, '$t$', 'Interpreter','latex', ...
    'FontSize',12,'HorizontalAlignment','left','Clipping','off');

exportgraphics(gcf, '二阶系统时域性能指标.png', ...
    'Resolution', 300, 'BackgroundColor','white');
close(gcf);
end

function tc = crossing(t, x, level)
%CROSSING 响应曲线首次达到给定值的时刻（线性插值）
idx = find(x >= level, 1, 'first');
tc  = interp1(x(idx-1:idx), t(idx-1:idx), level);
end
