%% RL / RLC circuit
%  Left: RL series circuit  L*dI/dt + R*I = E, solution I(t) = (E/R)*(1-exp(-R*t/L))
%  Right: RLC discharge circuit  L*d2q/dt2 + R*dq/dt + q/C = 0 (underdamped)
clear; clc; close all;

% ---- Left: RL circuit ----
R = 10; L = 1; E = 12;
t = linspace(0, 1, 200);
I = (E/R) * (1 - exp(-R*t/L));

subplot(1,2,1);
plot(t, I, 'LineWidth', 2, 'Color', [0 0.45 0.74]);
hold on;
plot([0 1], [E/R E/R], 'k--', 'LineWidth', 1);
hold off;
xlabel('$t$ (s)', 'Interpreter','latex', 'FontSize', 12);
ylabel('$I(t)$ (A)', 'Interpreter','latex', 'FontSize', 12);
title('(a) RL circuit', 'FontSize', 13);
legend({'$I(t)=\frac{E}{R}(1-e^{-Rt/L})$', '$E/R$'}, ...
    'Interpreter','latex', 'Location','southeast', 'FontSize', 10);
grid on; xlim([0 1]);

% ---- Right: RLC circuit (underdamped) ----
R2 = 4; L2 = 1; C2 = 0.04;          % R^2 < 4L/C => underdamped
q0 = 0.01; dq0 = 0;
tspan = [0 6];
f = @(t, y) [y(2); -R2/L2*y(2) - 1/(L2*C2)*y(1)];
[t2, y2] = ode45(f, tspan, [q0; dq0]);

subplot(1,2,2);
plot(t2, y2(:,1)*1e3, 'LineWidth', 2, 'Color', [0.85 0.33 0.10]);
xlabel('$t$ (s)', 'Interpreter','latex', 'FontSize', 12);
ylabel('$q(t)$ (mC)', 'Interpreter','latex', 'FontSize', 12);
title('(b) RLC discharge (underdamped)', 'FontSize', 13);
grid on; xlim([0 6]);

sgtitle('RL / RLC circuit', 'FontSize', 15);
exportgraphics(gcf, '../Figures/fig_RLC.png', 'Resolution', 150);
fprintf('RL/RLC figure saved.\n');
