%% Lorenz equation (butterfly effect)
%  dx/dt = s*(y - x),  dy/dt = x*(r - z) - y,  dz/dt = x*y - b*z
clear; clc; close all;

sigma = 10; rho = 28; beta = 8/3;
x0 = [1; 1; 1];
tspan = [0 50];
f = @(t, y) [sigma*(y(2) - y(1)); ...
             y(1)*(rho - y(3)) - y(2); ...
             y(1)*y(2) - beta*y(3)];
[t, y] = ode45(f, tspan, x0);

figure('Color','w','Position',[100 100 620 480]);
plot3(y(:,1), y(:,2), y(:,3), 'LineWidth', 1.2, 'Color', [0 0.45 0.74]);
xlabel('$x$', 'Interpreter','latex', 'FontSize', 13);
ylabel('$y$', 'Interpreter','latex', 'FontSize', 13);
zlabel('$z$', 'Interpreter','latex', 'FontSize', 13);
title('Lorenz equation ($\sigma=10,\ \rho=28,\ \beta=8/3$)', ...
    'Interpreter','latex', 'FontSize', 14);
grid on; view([-20 25]);

exportgraphics(gcf, '../Figures/fig_lorenz.png', 'Resolution', 150);
fprintf('Lorenz figure saved.\n');