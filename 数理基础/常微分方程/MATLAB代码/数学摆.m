%% Mathematical pendulum  d2theta/dt2 + (g/l)*sin(theta) = 0
%  Numerical solution (ode45) vs small-angle approximation
clear; clc; close all;

g = 9.8; l = 1.0;
theta0 = 0.5;
tspan = [0 10];
f = @(t, y) [y(2); -(g/l)*sin(y(1))];
[t, y] = ode45(f, tspan, [theta0; 0]);

omega = sqrt(g/l);
theta_small = theta0 * cos(omega*t);

figure('Color','w','Position',[100 100 620 440]);
plot(t, y(:,1), 'LineWidth', 2, 'Color', [0 0.45 0.74]); hold on;
plot(t, theta_small, '--', 'LineWidth', 1.5, 'Color', [0.85 0.33 0.10]);
hold off;
xlabel('$t$ (s)', 'Interpreter','latex', 'FontSize', 13);
ylabel('$\theta(t)$ (rad)', 'Interpreter','latex', 'FontSize', 13);
title('Mathematical pendulum', 'FontSize', 14);
legend({'Numerical (large angle)', 'Small-angle approx.'}, ...
    'Location','northeast', 'FontSize', 11);
grid on; xlim([0 10]); ylim([-0.6 0.6]);

exportgraphics(gcf, '../Figures/fig_pendulum.png', 'Resolution', 150);
fprintf('Pendulum figure saved.\n');