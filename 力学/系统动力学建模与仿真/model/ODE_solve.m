% 1. 清空工作区
clear; clc; close all;

% 2. 定义微分方程（匿名函数）
a = 0.5;

odefun = @(t,y) -a*y;  % dy/dt 表达式

% 3. 初始条件和求解区间
tspan = [0 20];   % 求解 0~20
y0 = 1;           % 初始值

% 4. 数值求解
[t,y] = ode45(odefun, tspan, y0);

% 5. 绘图可视化
figure('Position',[100,100,600,300])
plot(t, y, 'b-', 'LineWidth',2);
xlabel('t');
ylabel('y(t)');
title('MATLAB 微分方程数值解');
legend('数值解');
grid on;

exportgraphics(gcf, '图一.png',...
    'BackgroundColor','none', 'Resolution',300);