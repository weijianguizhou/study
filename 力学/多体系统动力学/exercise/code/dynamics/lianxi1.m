function lianxi1()
% 题目四：四杆机构重力势能极小值（与 lianxi1.cpp 功能相同）
% 流程：KKT 一阶条件 F(x)=0 → Newton-Raphson 迭代（自定义列主元高斯消元求解）
%       → 多初值收集驻点 → 二阶判据 Q 判定极小值点
%
% 运行：把本文件所在目录设为当前目录后，命令行输入 lianxi1 即可。

% ================= 参数 =================
P.l1 = 1.0;  P.l2 = 1.0;  P.l3 = 1.2;  P.l4 = 2.0;
P.m1 = 1.0;  P.m2 = 1.0;  P.g  = -9.8;

fprintf('========== 题目四：四杆机构势能极小值 ==========\n');
fprintf('l1=%.6f, l2=%.6f, l3=%.6f, l4=%.6f, m1=%.6f, m2=%.6f, g=%.6f\n\n', ...
    P.l1, P.l2, P.l3, P.l4, P.m1, P.m2, P.g);

% ================= 多初值求解一阶条件 =================
% 注意：乘子初值不能取 0 —— 当 λ=0 时 KKT 矩阵 [[0, c_x'], [c_x, 0]] 是奇异的
%（切向零空间对应的 (d, 0) 就是它的零空间向量），高斯消元会直接报奇异。
starts = [ 0.5,  0.9, 1.4,  1.0;
           0.5, -0.9, 1.4, -1.0;
           0.3,  1.0, 1.1,  1.1;
           0.3, -1.0, 1.1, -1.1];

sols   = zeros(8, 7);   % 收集到的互不重复驻点
nfound = 0;

for s = 1:size(starts, 1)
    x = [starts(s, :)'; 1; 1; 1];

    [x, ok] = newtonSolve(x, 100, 1e-10, P);
    if ~ok
        continue;                      % 该初值没收敛，跳过
    end

    isNew = true;                      % 与已有解比较去重
    for k = 1:nfound
        if norm(x - sols(k, :)') < 1e-6
            isNew = false;
            break;
        end
    end

    if isNew
        nfound = nfound + 1;
        sols(nfound, :) = x.';
    end
end

sols = sols(1:nfound, :);

fprintf('共找到 %d 个驻点解：\n', nfound);

for k = 1:nfound
    x   = sols(k, :)';
    q   = x(1:4);
    lam = x(5:7);

    f = potential(q, P);
    Q = secondOrderQ(x, P);

    fprintf('\n解 %d：\n', k);
    fprintf('  (x1, y1) = (%.6f, %.6f)\n', q(1), q(2));
    fprintf('  (x2, y2) = (%.6f, %.6f)\n', q(3), q(4));
    fprintf('  (λ1, λ2, λ3) = (%.6f, %.6f, %.6f)\n', lam(1), lam(2), lam(3));
    fprintf('  势能 f = %.6f\n', f);
    fprintf('  二阶判据 Q = %.6f  ->  ', Q);

    if Q > 1e-8
        fprintf('极小值点（稳定）\n');
    elseif Q < -1e-8
        fprintf('非极小值点（不稳定/鞍点）\n');
    else
        fprintf('退化，需看更高阶\n');
    end
end

end % ================= main =================


% ================= 线性方程组求解器：列主元高斯消元 =================
% 解 A x = b。info：0 成功；3 主元过小（奇异）
function [x, info] = GuassSolver(A, b, tol)
if nargin < 3
    tol = 1e-12;
end

n    = size(A, 1);
x    = zeros(n, 1);
info = 0;

if n == 0
    return;
end

M   = A;
rhs = b(:);

for k = 1:n
    % —— 选主元：在第 k 列、第 k 行及以下找绝对值最大者 ——
    p      = k;
    maxAbs = abs(M(k, k));
    for i = k+1:n
        v = abs(M(i, k));
        if v > maxAbs
            maxAbs = v;
            p      = i;
        end
    end

    % —— 整列都快没了，判定为奇异（否则下面会除以 0）——
    if maxAbs <= tol
        info = 3;
        return;
    end

    % —— 主元行不在第 k 行就交换两行（右端项要一起换）——
    if p ~= k
        M([k p], :)   = M([p k], :);
        rhs([k p])    = rhs([p k]);
    end

    pivotVal = M(k, k);

    % —— 消元：用第 k 行把下面各行的第 k 列消成 0 ——
    for i = k+1:n
        factor = M(i, k) / pivotVal;
        if factor == 0
            continue;
        end
        M(i, k:n) = M(i, k:n) - factor * M(k, k:n);
        rhs(i)    = rhs(i)    - factor * rhs(k);
    end
end

% —— 回代 ——
for i = n:-1:1
    sum_i = rhs(i);
    for j = i+1:n
        sum_i = sum_i - M(i, j) * x(j);
    end
    if abs(M(i, i)) <= tol
        info = 3;
        return;
    end
    x(i) = sum_i / M(i, i);
end
end


% ================= 题目四的方程构造 =================
% 广义坐标 q = [x1; y1; x2; y2]

% 约束方程 c(q) = 0：杆 1 长 l1、杆 2 长 l2、末端到固定铰 (l4, 0) 距离 l3
function c = constraint(q, P)
x1 = q(1); y1 = q(2); x2 = q(3); y2 = q(4);

c = [ x1*x1 + y1*y1 - P.l1*P.l1;
      (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) - P.l2*P.l2;
      (x2-P.l4)*(x2-P.l4) + y2*y2 - P.l3*P.l3 ];
end


% 约束雅可比矩阵 c_x = dc/dq（3×4）
function C = constraintJacobian(q, P)
x1 = q(1); y1 = q(2); x2 = q(3); y2 = q(4);

C = [ 2*x1,         2*y1,         0,               0;
      2*(x1-x2),    2*(y1-y2),    2*(x2-x1),       2*(y2-y1);
      0,            0,            2*(x2-P.l4),     2*y2 ];
end


% 重力势能 f(q) = m1 g y1 + m2 g y2
function f = potential(q, P)
f = P.m1*P.g*q(2) + P.m2*P.g*q(4);
end


% 二阶导的加权和 H = H_f + Σ λ_i (c_i)_qq
% （势能是线性的，H_f = 0；每一项都是常系数二阶导）
function H = weightedHessian(lam)
H = zeros(4, 4);

% c1 = x1^2 + y1^2 - l1^2   → H_c1 = diag(2, 2, 0, 0)
H(1,1) = H(1,1) + 2*lam(1);
H(2,2) = H(2,2) + 2*lam(1);

% c2 = (x2-x1)^2 + (y2-y1)^2 - l2^2
H(1,1) = H(1,1) + 2*lam(2);  H(3,3) = H(3,3) + 2*lam(2);
H(2,2) = H(2,2) + 2*lam(2);  H(4,4) = H(4,4) + 2*lam(2);
H(1,3) = H(1,3) - 2*lam(2);  H(3,1) = H(3,1) - 2*lam(2);
H(2,4) = H(2,4) - 2*lam(2);  H(4,2) = H(4,2) - 2*lam(2);

% c3 = (x2-l4)^2 + y2^2 - l3^2  → H_c3 = diag(0, 0, 2, 2)
H(3,3) = H(3,3) + 2*lam(3);
H(4,4) = H(4,4) + 2*lam(3);
end


% 未知量 x = [q; λ]（共 7 个），一阶条件（KKT 方程）：
%     F(x) = [ f_x + c_x' λ ;  c(q) ] = 0
function F = residual(x, P)
q   = x(1:4);
lam = x(5:7);

fx = [0; P.m1*P.g; 0; P.m2*P.g];      % f_x = (0, m1 g, 0, m2 g)

F = [ fx + constraintJacobian(q, P).' * lam;
      constraint(q, P) ];
end


% F(x) 的雅可比矩阵（7×7）：
%     J = [ H_f + Σ λ_i (c_i)_qq   ,  c_x' ]
%         [ c_x                    ,   0   ]
function J = jacobian(x, P)
q   = x(1:4);
lam = x(5:7);

C = constraintJacobian(q, P);

J = [ weightedHessian(lam), C.';
      C,                    zeros(3, 3) ];
end


% ================= Newton-Raphson 迭代 =================
% 每步解 J(x)·dx = -F(x)，然后 x ← x + dx
function [x, ok] = newtonSolve(x, maxIter, tol, P)
ok = false;

for iter = 1:maxIter
    F = residual(x, P);
    if norm(F) < tol              % 已经满足一阶条件
        ok = true;
        return;
    end

    J   = jacobian(x, P);
    rhs = -F;                     % 解  J·dx = -F

    [dx, info] = GuassSolver(J, rhs);
    if info ~= 0                  % 雅可比奇异，迭代无法继续
        ok = false;
        return;
    end

    x = x + dx;

    if norm(dx) < 1e-14           % 步长已到机器精度，停止
        break;
    end
end

ok = norm(residual(x, P)) < 1e-9; % 最终用残差判定是否收敛
end


% ================= 二阶判据 =================
% 对切空间中的非零方向 d（这里切空间是 1 维，c_x d = 0）：
%     Q = d' (H_f + Σ λ_i H_ci) d
% Q > 0 → 严格局部极小；Q < 0 → 不是极小；Q ≈ 0 → 退化
function Q = secondOrderQ(x, P)
q   = x(1:4);
lam = x(5:7);
C   = constraintJacobian(q, P);   % 3×4

% 切向量 d：3×4 矩阵的广义叉积 —— 去掉第 i 列后的三阶子式，逐项轮换符号
d = zeros(4, 1);
for i = 1:4
    cols  = 1:4;
    cols(i) = [];
    minor = C(:, cols);           % 3×3 子式

    if mod(i, 2) == 1
        sgn = 1;
    else
        sgn = -1;
    end
    d(i) = sgn * det(minor);
end

H = weightedHessian(lam);
Q = d.' * H * d;
end
