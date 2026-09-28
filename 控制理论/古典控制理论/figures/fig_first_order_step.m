function fig_first_order_step
%FIG_FIRST_ORDER_STEP 一阶系统的单位阶跃响应（原「一阶系统单位阶跃响应.jpg」重绘）
%   x_o(t) = 1 - exp(-t/T)，标注时间常数 T、0.632 点、初始斜率与各整倍
%   时间常数处的响应百分比。
%   运行后在本文件夹生成「一阶系统单位阶跃响应.png」。
close all;

blue  = [0.0000 0.4470 0.7410];      % 响应曲线
red   = [0.8500 0.3250 0.0980];      % 初始切线
green = [0.0000 0.5000 0.0000];      % 响应百分比
gray  = [0.5000 0.5000 0.5000];      % 辅助线

T  = 1;                               % 时间常数
t  = linspace(0, 5.4*T, 1200);
x  = 1 - exp(-t/T);
tn = t/T;                             % 归一化横坐标，刻度标为 T、2T、…

figure('Units','centimeters','Position',[2 2 14.5 9.5],'Color','w');
ax = axes; hold(ax,'on'); box(ax,'on');

plot(ax, tn, x, '-', 'Color', blue, 'LineWidth', 1.8);        % 响应曲线
plot(ax, [0 5.4], [1 1], ':', 'Color', gray);                 % 稳态值 x_o = 1
plot(ax, [0 1.10], [0 1.10], '--', 'Color', red, 'LineWidth', 1.2);  % 原点切线
plot(ax, [0 1], [0.632 0.632], '--', 'Color', gray);          % 63.2% 辅助线
plot(ax, [1 1], [0 0.632],     '--', 'Color', gray);

% 先固定坐标范围与刻度（annotation 箭头按图窗坐标定位，须在定界后再画）
xlim(ax, [0 5.5]); ylim(ax, [0 1.30]);
xticks(ax, 0:5);   xticklabels(ax, {'0','T','2T','3T','4T','5T'});
yticks(ax, [0 0.632 1]); yticklabels(ax, {'0','0.632','1'});
set(ax, 'FontName','Times New Roman','FontSize',11, ...
    'TickDir','in','TickLength',[0.015 0.015],'LineWidth',0.9);

% 各整倍时间常数处标注响应百分比
tv  = 1:5;
xv  = 1 - exp(-tv);
lab = {'63.2%','86.5%','95.0%','98.2%','99.3%'};
for k = 1:5
    drawarrow(ax, tv(k), 0, tv(k), xv(k), 'doublearrow', green);
    text(ax, tv(k)-0.14, xv(k)/2, lab{k}, 'Rotation', 90, ...
        'Color', green, 'HorizontalAlignment','center','FontSize',8);
end

% 切线说明
drawarrow(ax, 1.16, 1.21, 0.98, 0.99, 'arrow', red);
text(ax, 1.21, 1.25, '斜率 = 1/T', 'Color', red, ...
    'FontName','SimSun','FontSize',10);
text(ax, 2.90, 1.16, '$x_{\mathrm{o}}(t)=1-\mathrm{e}^{-t/T}$', ...
    'Interpreter','latex','Color', blue,'FontSize',11);

text(ax, -0.28, 1.24, '$x_{\mathrm{o}}(t)$', 'Interpreter','latex', ...
    'FontSize',12,'HorizontalAlignment','right','Clipping','off');
text(ax, 5.55, -0.10, '$t$', 'Interpreter','latex', ...
    'FontSize',12,'HorizontalAlignment','left','Clipping','off');

exportgraphics(gcf, '一阶系统单位阶跃响应.png', ...
    'Resolution', 300, 'BackgroundColor','white');
close(gcf);
end
