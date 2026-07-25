# 41-滑模控制(SMC)

滑模控制的思路：设计一个**滑模面**$s=0$，把系统状态强制拽过去并锁在上面。一旦滑进去了，系统行为就变成你设计好的——不受参数变化和干扰的影响。

---

# 一、滑模面设计

对二阶系统$\ddot{x} = f(x,\dot{x}) + u$，选滑模面：

$$s = \dot{e} + \lambda e, \quad e = x - x_d$$

当$s=0$时，$\dot{e} = -\lambda e \implies e(t) = e(0)e^{-\lambda t}$——指数收敛到零。

---

# 二、控制律

$$u = \hat{f} + \ddot{x}_d - \lambda \dot{e} - K \cdot \text{sgn}(s)$$

```matlab
function u = smc_control(x, dx, x_d, dx_d, dd_x_d, lambda, K)
    e = x - x_d; de = dx - dx_d;
    s = de + lambda * e;
    u = dd_x_d - lambda*de - K * sign(s);
end
```

$K$必须大于不确定性的上界。$K$够大，$s\dot{s} < 0$成立，保证滑模面可达。

---

# 三、消除抖振——用饱和函数替代符号函数

```matlab
sat = @(s, phi) min(max(s/phi, -1), 1);
u = dd_x_d - lambda*de - K * sat(s, 0.05);
```

$\phi$是边界层厚度。边界层内用连续控制替代bang-bang，消除高频抖振。

---

# 四、倒立摆SMC仿真

```matlab
g = 9.81; L = 0.5;
lambda = 5; K = 10;

odefun = @(t, y) [y(2); (g/L)*sin(y(1)) + smc_control(y(1),y(2),...
    sin(t), cos(t), -sin(t), lambda, K)];
[t, y] = ode45(odefun, [0, 10], [0.5; 0]);
plot(t, y(:,1), t, sin(t)); legend('实际', '期望');
```

---

## 下一步

- [[42-扩展卡尔曼滤波|扩展卡尔曼滤波(EKF)]]
