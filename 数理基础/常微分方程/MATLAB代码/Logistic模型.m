%% Logistic model (Verhulst)  dN/dt = r*N*(1 - N/Nm)
%  Solution: N(t) = Nm / (1 + (Nm/N0 - 1)*exp(-r*t))
clear; clc; close all;

r = 0.5; Nm = 1000; N0 = 100;
t = linspace(0, 20, 400);
N = Nm ./ (1 + (Nm/N0 - 1) * exp(-r*t));

figure('Color','w','Position',[100 100 560 420]);
plot(t, N, 'LineWidth', 2.5, 'Color', [0.85 0.33 0.10]);
hold on;
plot([0 20], [Nm Nm], 'k--', 'LineWidth', 1.2);
hold off;
xlabel('$t$', 'Interpreter','latex', 'FontSize', 13);
ylabel('$N(t)$', 'Interpreter','latex', 'FontSize', 13);
title('Logistic model (S-shaped growth)', 'FontSize', 14);
legend({'$N(t)=\frac{N_m}{1+(\frac{N_m}{N_0}-1)e^{-rt}}$', 'Capacity $N_m$'}, ...
    'Interpreter','latex', 'Location','southeast', 'FontSize', 11);
grid on;

exportgraphics(gcf, '../Figures/fig_logistic.png', 'Resolution', 150);
fprintf('Logistic figure saved.\n');