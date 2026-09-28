function fig_first_order_ramp
%FIG_FIRST_ORDER_RAMP 一阶系统的单位斜坡响应（原「一阶系统单位斜坡响应.jpg」重绘）
%   x_i(t) = t，x_o(t) = t - T + T*exp(-t/T)，稳态误差 e(∞) = T。
%   运行后在本文件夹生成「一阶系统单位斜坡响应.png」。
close all;

blue  = [0.0000 0.4470 0.7410];      % 输出响应
red   = [0.8500 0.3250 0.0980];      % 稳态误差
green = [0.0000 0.5000 0.0000];      % 输入信号

T  = 1;
t  = linspace(0, 6*T, 1200);
xi = t;
xo = t - T + T*exp(-t/T);

figure('Units','centimeters','Position',[2 2 13.5 9],'Color','w');
ax = axes; hold(ax,'on');
plot(ax, t, xi, '-', 'Color', green, 'LineWidth', 1.2);    % 输入斜坡
plot(ax, t, xo, '-', 'Color', blue,  'LineWidth', 1.8);    % 输出响应

% 先固定坐标范围（annotation 箭头按图窗坐标定位，须在定界后再画）
xlim(ax, [0 6.2]); ylim(ax, [0 6.6]);
xticks(ax, 0:6);   yticks(ax, 0:6);
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
box(ax, 'off');
set(ax, 'FontName','Times New Roman','FontSize',11, ...
    'TickDir','in','TickLength',[0.015 0.015],'LineWidth',0.9);

% 两条曲线上的标注（旋转角度按坐标轴比例估计）
text(ax, 1.65, 2.05, '$x_{\mathrm{i}}(t)=t$', 'Interpreter','latex', ...
    'Color', green,'FontSize',11,'Rotation',31);
text(ax, 2.55, 1.35, '$x_{\mathrm{o}}(t)=t-T+T\mathrm{e}^{-t/T}$', ...
    'Interpreter','latex','Color', blue,'FontSize',11,'Rotation',28);

% 稳态误差 e(∞) = T 标注
x0    = 5.2;
y_in  = x0;
y_out = x0 - T + T*exp(-x0/T);
drawarrow(ax, x0, y_out, x0, y_in, 'doublearrow', red);
text(ax, x0+0.12, (y_in+y_out)/2, '$e(\infty)=T$', 'Interpreter','latex', ...
    'Color', red,'FontSize',11,'Rotation',90,'HorizontalAlignment','left', ...
    'VerticalAlignment','middle');

text(ax, 0.08, 6.42, '$x_{\mathrm{i}}(t),\;x_{\mathrm{o}}(t)$', ...
    'Interpreter','latex','FontSize',12,'HorizontalAlignment','left', ...
    'VerticalAlignment','bottom','Clipping','off');
text(ax, 6.10, -0.45, '$t$', 'Interpreter','latex', ...
    'FontSize',12,'HorizontalAlignment','left','Clipping','off');

exportgraphics(gcf, '一阶系统单位斜坡响应.png', ...
    'Resolution', 300, 'BackgroundColor','white');
close(gcf);
end
