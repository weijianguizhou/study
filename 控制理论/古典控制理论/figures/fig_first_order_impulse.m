function fig_first_order_impulse
%FIG_FIRST_ORDER_IMPULSE 一阶系统的单位脉冲响应（原「一阶系统单位脉冲响应.jpg」重绘）
%   x_o(t) = (1/T)*exp(-t/T)，初值 x_o(0) = 1/T。
%   运行后在本文件夹生成「一阶系统单位脉冲响应.png」。
close all;

blue = [0.0000 0.4470 0.7410];       % 响应曲线
red  = [0.8500 0.3250 0.0980];       % 初值标注

T = 1;
t = linspace(0, 5.2*T, 1000);
x = exp(-t/T)/T;

figure('Units','centimeters','Position',[2 2 12 9],'Color','w');
ax = axes; hold(ax,'on');
plot(ax, t, x, '-', 'Color', blue, 'LineWidth', 1.8);
plot(ax, [0 0.55], [1 1], '--', 'Color', red, 'LineWidth', 1.0);
plot(ax, 0, 1, 'o', 'MarkerFaceColor', red, 'MarkerEdgeColor', red, ...
    'MarkerSize', 5);

xlim(ax, [0 5.4]); ylim(ax, [0 1.15]);
xticks(ax, 0:5);
yticks(ax, [0 1]); yticklabels(ax, {'0','1/T'});
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
box(ax, 'off');
set(ax, 'FontName','Times New Roman','FontSize',11, ...
    'TickDir','in','TickLength',[0.015 0.015],'LineWidth',0.9);

text(ax, 1.75, 0.40, '$x_{\mathrm{o}}(t)=\frac{1}{T}\mathrm{e}^{-t/T}$', ...
    'Interpreter','latex','Color', blue,'FontSize',12);

text(ax, -0.25, 1.10, '$x_{\mathrm{o}}(t)$', 'Interpreter','latex', ...
    'FontSize',12,'HorizontalAlignment','right','Clipping','off');
text(ax, 5.45, -0.10, '$t$', 'Interpreter','latex', ...
    'FontSize',12,'HorizontalAlignment','left','Clipping','off');

exportgraphics(gcf, '一阶系统单位脉冲响应.png', ...
    'Resolution', 300, 'BackgroundColor','white');
close(gcf);
end
