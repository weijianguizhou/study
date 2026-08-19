%% Run all model plotting scripts
%  Execute in the MATLAB code directory; figures are saved to ../Figures/
clear; clc; close all;
cd(fileparts(mfilename('fullpath')));

scripts = {'RL_RLC电路.m', '数学摆.m', 'Malthus人口模型.m', ...
           'Logistic模型.m', 'SI传染病模型.m', ...
           'Volterra捕食被捕食模型.m', 'Lorenz方程.m'};
for k = 1:numel(scripts)
    fprintf('==== Run %s ====\n', scripts{k});
    run(scripts{k});
end
fprintf('All figures done!\n');
