%% Volterra predator-prey model
%  dx/dt = a*x - b*x*y   (prey)
%  dy/dt = -c*y + d*x*y  (predator)
clear; clc; close all;

a = 1.2; b = 0.6; c = 0.8; d = 0.3;
x0 = 2; y0 = 1;
tspan = [0 40];
f = @(t, z) [a*z(1) - b*z(1)*z(2); -c*z(2) + d*z(1)*z(2)];
[t, z] = ode45(f, tspan, [x0; y0]);

subplot(1,2,1);
plot(t, z(:,1), 'LineWidth', 2, 'Color', [0 0.45 0.74]); hold on;
plot(t, z(:,2), 'LineWidth', 2, 'Color', [0.85 0.33 0.10]);
hold off;
xlabel('$t$', 'Interpreter','latex', 'FontSize', 12);
ylabel('Population', 'FontSize', 12);
title('(a) Time history', 'FontSize', 13);
legend({'Prey $x(t)$', 'Predator $y(t)$'}, 'Interpreter','latex', ...
    'Location','northeast', 'FontSize', 10);
grid on; xlim([0 40]);

subplot(1,2,2);
plot(z(:,1), z(:,2), 'LineWidth', 2, 'Color', [0.5 0.5 0.5]);
xlabel('$x$ (prey)', 'Interpreter','latex', 'FontSize', 12);
ylabel('$y$ (predator)', 'Interpreter','latex', 'FontSize', 12);
title('(b) Phase portrait', 'FontSize', 13);
grid on;

sgtitle('Volterra predator-prey model', 'FontSize', 15);
exportgraphics(gcf, '../Figures/fig_volterra.png', 'Resolution', 150);
fprintf('Volterra figure saved.\n');