%% Malthus population model (exponential growth)  dN/dt = r*N
%  Solution: N(t) = N0 * exp(r*t)
clear; clc; close all;

r = 0.05; N0 = 100;
t = linspace(0, 100, 300);
N = N0 * exp(r*t);

figure('Color','w','Position',[100 100 560 420]);
plot(t, N, 'LineWidth', 2.5, 'Color', [0 0.45 0.74]);
xlabel('$t$ (year)', 'Interpreter','latex', 'FontSize', 13);
ylabel('$N(t)$', 'Interpreter','latex', 'FontSize', 13);
title('Malthus model (exponential growth)', 'FontSize', 14);
text(50, N(end)/2, '$N(t)=N_0e^{rt}$', 'Interpreter','latex', ...
    'FontSize', 14, 'Color', [0 0.45 0.74]);
grid on;

exportgraphics(gcf, '../Figures/fig_malthus.png', 'Resolution', 150);
fprintf('Malthus figure saved.\n');