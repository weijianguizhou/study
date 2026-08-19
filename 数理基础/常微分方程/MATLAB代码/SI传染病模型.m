%% SI epidemic model (no removal)  dS/dt = -b*S*I,  dI/dt = b*S*I
%  Total population N = S + I is constant
clear; clc; close all;

beta = 0.3; N = 1000;
S0 = 990; I0 = 10;
tspan = [0 60];
f = @(t, y) [-beta*y(1)*y(2); beta*y(1)*y(2)];
[t, y] = ode45(f, tspan, [S0; I0]);

figure('Color','w','Position',[100 100 560 420]);
plot(t, y(:,1), 'LineWidth', 2, 'Color', [0 0.45 0.74]); hold on;
plot(t, y(:,2), 'LineWidth', 2, 'Color', [0.85 0.33 0.10]);
hold off;
xlabel('$t$ (day)', 'Interpreter','latex', 'FontSize', 13);
ylabel('Population', 'FontSize', 13);
title('SI epidemic model', 'FontSize', 14);
legend({'Susceptible $S(t)$', 'Infective $I(t)$'}, 'Interpreter','latex', ...
    'Location','east', 'FontSize', 12);
grid on; xlim([0 60]);

exportgraphics(gcf, '../Figures/fig_SI.png', 'Resolution', 150);
fprintf('SI figure saved.\n');