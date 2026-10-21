function [x, iter, converged, resnorm] = Newton_Raphson(F, x0, varargin)
    p = inputParser;
    addParameter(p, 'J', []);
    addParameter(p, 'Tol', 1e-8);
    addParameter(p, 'MaxIter', 100);
    parse(p, varargin{:});
    Jfun  = p.Results.J;
    tol   = p.Results.Tol;
    maxit = p.Results.MaxIter;
    x = x0(:);                
    n = numel(x);
    converged = false;
    iter = 0;
    resnorm = inf;
    for iter = 1:maxit
        Fx = F(x);
        Fx = Fx(:);            
        if numel(Fx) ~= n
            error('Newton_Raphson:DimMismatch', ...
                  'F(x) 的维数 (%d) 必须与 x 的维数 (%d) 一致。', numel(Fx), n);
        end

        % 雅可比: 外部传入, 或内部前向差分
        if isempty(Jfun)
            J = jacobian_fd(F, x, Fx);
        else
            J = Jfun(x);
            if ~isequal(size(J), [n n])
                error('Newton_Raphson:JacSize', ...
                      '雅可比矩阵必须是 %d×%d。', n, n);
            end
        end

        % 奇异保护: 接近奇异时终止, 避免静默得到无效解
        if rcond(J) < eps
            error('Newton_Raphson:SingularJac', ...
                  '雅可比矩阵接近奇异(rcond=%.3e), 无法继续迭代。', rcond(J));
        end

        % 牛顿步: J * dx = -F(x)
        dx = -J \ Fx;
        x  = x + dx;

        % 收敛判据: 相对步长
        if norm(dx) <= tol * (1 + norm(x))
            converged = true;
            break;
        end
    end

    % ---------- 收尾 ----------
    resnorm = norm(F(x));
    if ~converged
        warning('Newton_Raphson:NoConvergence', ...
                '在 %d 次迭代内未收敛, 当前残差范数 = %.3e。', maxit, resnorm);
    end
end

function J = jacobian_fd(F, x, Fx)
%JACOBIAN_FD 前向差分近似雅可比矩阵。
%   第 j 列: J(:,j) = ( F(x + h_j*e_j) - F(x) ) / h_j,  h_j = sqrt(eps)*max(|x_j|, 1)
    n = numel(x);
    J = zeros(n, n);
    h = sqrt(eps) * max(abs(x), 1);
    for j = 1:n
        xh = x;
        xh(j) = xh(j) + h(j);
        J(:, j) = (F(xh) - Fx) / h(j);
    end
end
