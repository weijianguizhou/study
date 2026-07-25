# 42-扩展卡尔曼滤波(EKF)

标准KF是线性的，EKF把非线性系统在当前估计点线性化。

---

# 一、EKF框架

$$\dot{x} = f(x,u) + w, \quad z = h(x) + v$$

**预测**：$\hat{x}^- = \hat{x} + f(\hat{x},u)\Delta t,\quad P^- = FPF^T + Q$

**更新**：$K = P^-H^T(HP^-H^T+R)^{-1},\quad \hat{x} = \hat{x}^- + K(z-h(\hat{x}^-)),\quad P = (I-KH)P^-$

$F = \frac{\partial f}{\partial x}\Big|_{\hat{x}},\; H = \frac{\partial h}{\partial x}\Big|_{\hat{x}^-}$——在每个时间步重新计算。

---

# 二、机器人EKF定位

状态：$x = [p_x, p_y, \theta]^T$（平面位姿）

```matlab
dt = 0.01; Q = diag([0.01, 0.01, 0.001]); R = diag([0.1, 0.1]);
x_est = [0;0;0]; P = eye(3);

for k = 1:length(t)
    % 预测（里程计模型 u = [v, ω]）
    v = control(k,1); omega = control(k,2);
    x_pred = x_est + dt * [v*cos(x_est(3)); v*sin(x_est(3)); omega];
    F = [1, 0, -dt*v*sin(x_est(3));
         0, 1,  dt*v*cos(x_est(3));
         0, 0,  1];
    P = F * P * F' + Q;
    
    % 更新（GPS观测位置）
    z = gps_meas(:,k);
    H = [1,0,0; 0,1,0];
    y = z - H * x_pred;
    S = H * P * H' + R;
    K = P * H' / S;
    x_est = x_pred + K * y;
    P = (eye(3) - K*H) * P;
end
```

---

## 下一步

- [[43-鲁棒控制(H∞)|鲁棒控制(H∞)]]
