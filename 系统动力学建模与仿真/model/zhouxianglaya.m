%% ============================================================
%  等强度柱（等强度杆）问题 - MATLAB程序
%  考虑自重的变截面杆等强度设计
%% ============================================================

clear; clc; close all;

%% 1. 参数设置
F = 10000;          % 顶部拉力 F (N)
sigma_allow = 100e6; % 许用应力 [σ] (Pa) = 100 MPa
rho = 7850;         % 材料密度 (kg/m^3)，例如钢材
g = 9.8;            % 重力加速度 (m/s^2)
E = 200e9;          % 弹性模量 (Pa) = 200 GPa
L = 10;             % 杆的总长度 (m)

%% 2. 计算基本参数
A0 = F / sigma_allow;           % 顶部截面积 (x=0处)
k = rho * g / sigma_allow;      % 指数系数
delta_l = sigma_allow * L / E;  % 总伸长量

fprintf('========== 等强度柱计算结果 ==========\n');
fprintf('顶部拉力 F = %.2f N\n', F);
fprintf('许用应力 [σ] = %.2f MPa\n', sigma_allow/1e6);
fprintf('材料密度 ρ = %.0f kg/m³\n', rho);
fprintf('弹性模量 E = %.0f GPa\n', E/1e9);
fprintf('杆长 L = %.2f m\n', L);
fprintf('----------------------------------------\n');
fprintf('顶部截面积 A₀ = F/[σ] = %.6f m² = %.2f mm²\n', A0, A0*1e6);
fprintf('指数系数 k = ρg/[σ] = %.6f 1/m\n', k);
fprintf('底部截面积 A(L) = %.6f m² = %.2f mm²\n', A0*exp(k*L), A0*exp(k*L)*1e6);
fprintf('面积放大倍数 = %.4f\n', exp(k*L));
fprintf('----------------------------------------\n');
fprintf('总伸长量 |Δl| = [σ]L/E = %.6f m = %.4f mm\n', delta_l, delta_l*1000);

%% 3. 计算截面面积分布
x = linspace(0, L, 1000);   % 沿杆长度方向的坐标
A_x = A0 * exp(k * x);      % 截面面积分布 A(x) = A₀ * e^(kx)

%% 4. 绘制截面面积变化曲线
figure('Name', '等强度柱截面面积分布', 'Position', [100 100 1200 400]);

% 子图1：面积随高度变化
subplot(1, 3, 1);
plot(A_x * 1e6, x, 'b-', 'LineWidth', 2);
hold on;
plot(A0 * 1e6, 0, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
plot(A0*exp(k*L) * 1e6, L, 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
xlabel('截面积 A(x) (mm²)', 'FontSize', 12);
ylabel('高度 x (m)', 'FontSize', 12);
title('截面面积沿高度分布', 'FontSize', 14);
legend('A(x)', '顶部 A₀', '底部 A(L)', 'Location', 'best');
grid on;
set(gca, 'YDir', 'reverse');  % 让x=0在上方，符合悬挂杆的直觉

% 子图2：面积对数坐标
subplot(1, 3, 2);
semilogy(x, A_x * 1e6, 'b-', 'LineWidth', 2);
xlabel('高度 x (m)', 'FontSize', 12);
ylabel('截面积 A(x) (mm²) - 对数坐标', 'FontSize', 12);
title('截面面积对数分布', 'FontSize', 14);
grid on;

% 子图3：绘制等强度柱形状示意图
subplot(1, 3, 3);
% 计算半径（假设圆形截面）
r_x = sqrt(A_x / pi);
% 绘制轮廓
fill([r_x, -fliplr(r_x)] * 1000, [x, fliplr(x)], [0.8 0.9 1], ...
    'EdgeColor', 'b', 'LineWidth', 2);
hold on;
plot([0 0], [0 L], 'k--', 'LineWidth', 1);  % 中心线
xlabel('半径 (mm)', 'FontSize', 12);
ylabel('高度 x (m)', 'FontSize', 12);
title('等强度柱形状示意图', 'FontSize', 14);
axis equal;
grid on;
set(gca, 'YDir', 'reverse');

sgtitle('等强度柱（考虑自重）设计分析', 'FontSize', 16, 'FontWeight', 'bold');

%% 5. 验证：各截面应力是否相等
sigma_x = (F + rho * g .* cumtrapz(x, A_x)) ./ A_x;
% 或者用解析式：sigma_x = sigma_allow * ones(size(x));

figure('Name', '应力验证', 'Position', [100 550 600 400]);
plot(x, sigma_x / 1e6, 'r-', 'LineWidth', 2);
hold on;
plot(x, sigma_allow/1e6 * ones(size(x)), 'b--', 'LineWidth', 1.5);
xlabel('高度 x (m)', 'FontSize', 12);
ylabel('应力 σ (MPa)', 'FontSize', 12);
title('各截面应力验证（应恒等于许用应力）', 'FontSize', 14);
legend('实际应力', '许用应力', 'Location', 'best');
grid on;
ylim([0.95*sigma_allow/1e6, 1.05*sigma_allow/1e6]);

fprintf('\n应力验证：最大偏差 = %.10f MPa\n', max(abs(sigma_x - sigma_allow))/1e6);

%% 6. 不同参数的影响分析
figure('Name', '参数敏感性分析', 'Position', [750 100 700 500]);

% 不同许用应力下的面积分布
sigma_values = [50, 100, 150, 200] * 1e6;  % MPa -> Pa
colors = jet(length(sigma_values));

hold on;
for i = 1:length(sigma_values)
    sigma_i = sigma_values(i);
    A0_i = F / sigma_i;
    k_i = rho * g / sigma_i;
    A_x_i = A0_i * exp(k_i * x);
    plot(x, A_x_i * 1e6, 'Color', colors(i,:), 'LineWidth', 2, ...
        'DisplayName', sprintf('[σ] = %d MPa', sigma_i/1e6));
end
xlabel('高度 x (m)', 'FontSize', 12);
ylabel('截面积 A(x) (mm²)', 'FontSize', 12);
title('不同许用应力下的截面面积分布', 'FontSize', 14);
legend('Location', 'best');
grid on;

%% 7. 计算体积和重量
V = integral(@(x) A0 * exp(k * x), 0, L);  % 总体积
W = rho * g * V;                            % 总重量
W_ratio = W / F;                            % 自重与外力之比

fprintf('----------------------------------------\n');
fprintf('总体积 V = %.6f m³\n', V);
fprintf('总重量 W = %.2f N = %.4f kN\n', W, W/1000);
fprintf('自重/外力比 W/F = %.4f\n', W_ratio);
fprintf('========================================\n');

%% 8. 交互式计算函数
fprintf('\n========== 交互式计算 ==========\n');
fprintf('可以修改参数重新运行，或使用以下函数：\n');
fprintf('  [A, delta] = equalStrengthColumn(F, sigma, rho, E, L)\n');
fprintf('=================================\n');

%% ============================================================
%  函数定义：等强度柱计算
%% ============================================================
function [A_profile, delta_total] = equalStrengthColumn(F, sigma_allow, rho, E, L)
    % 等强度柱计算函数
    % 输入:
    %   F          - 顶部拉力 (N)
    %   sigma_allow - 许用应力 (Pa)
    %   rho        - 密度 (kg/m^3)
    %   E          - 弹性模量 (Pa)
    %   L          - 长度 (m)
    % 输出:
    %   A_profile  - 面积分布函数句柄 A(x)
    %   delta_total - 总伸长量 (m)
    
    A0 = F / sigma_allow;
    k = rho * g / sigma_allow;
    
    A_profile = @(x) A0 * exp(k * x);
    delta_total = sigma_allow * L / E;
    
    fprintf('等强度柱设计完成！\n');
    fprintf('  A(x) = %.6f * exp(%.6f * x)  (m²)\n', A0, k);
    fprintf('  Δl = %.6f m\n', delta_total);
end