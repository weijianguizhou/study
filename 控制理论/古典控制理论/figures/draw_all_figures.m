function draw_all_figures
%DRAW_ALL_FIGURES 一次生成 figures/ 下全部 MATLAB 重绘插图（带坐标轴的图）
%   在 figures 文件夹中运行本函数，将依次生成：
%       一阶系统单位阶跃响应.png
%       一阶系统单位斜坡响应.png
%       一阶系统单位脉冲响应.png
%       二阶系统时域性能指标.png
%   依赖同文件夹中的 drawarrow.m 与各 fig_*.m。
fs = {'fig_first_order_step', 'fig_first_order_ramp', ...
      'fig_first_order_impulse', 'fig_second_order_specs'};
for k = 1:numel(fs)
    fprintf('生成插图：%s ...\n', fs{k});
    feval(fs{k});
end
fprintf('全部插图生成完毕。\n');
end
