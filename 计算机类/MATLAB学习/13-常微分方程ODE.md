# 13-常微分方程ODE

MATLAB解ODE的核心是`ode45`——自适应步长的4/5阶Runge-Kutta方法。几乎所有日常问题用`ode45`就够。

---

# 一、一阶ODE

$$\dot{y} = -2y + \sin(t), \quad y(0) = 1$$

```matlab
% 定义ODE右端函数
odefun = @(t, y) -2*y + sin(t);

% 求解
tspan = [0, 10];
y0 = 1;
[t, y] = ode45(odefun, tspan, y0);

plot(t, y);
xlabel('t'); ylabel('y');
```

---

# 二、高阶ODE → 一阶方程组

二阶方程$\ddot{x} + 2\zeta\omega_n\dot{x} + \omega_n^2 x = 0$，设$y_1 = x,\; y_2 = \dot{x}$：

$$\dot{y}_1 = y_2$$
$$\dot{y}_2 = -2\zeta\omega_n y_2 - \omega_n^2 y_1$$

```matlab
omega = 2; zeta = 0.1;

odefun = @(t, y) [y(2);
                  -2*zeta*omega*y(2) - omega^2*y(1)];

[t, y] = ode45(odefun, [0, 20], [1; 0]);

plot(t, y(:,1));
xlabel('t'); ylabel('x(t)');
title('弹簧-质量-阻尼系统');
```

---

# 三、带参数的ODE

```matlab
omega = 2; zeta = 0.1;
odefun = @(t, y) [y(2); -2*zeta*omega*y(2) - omega^2*y(1)];
% 参数直接"捕获"进了匿名函数
```

或者更清晰的方式——把参数传进去：

```matlab
function dydt = myode(t, y, omega, zeta)
    dydt = [y(2); -2*zeta*omega*y(2) - omega^2*y(1)];
end

[t, y] = ode45(@(t,y) myode(t,y,2,0.1), [0 20], [1;0]);
```

---

# 四、ODE求解器选择

| 求解器 | 适用 |
|--------|------|
| `ode45` | 绝大多数非刚性问题（首选） |
| `ode23` | 精度要求不高时更快 |
| `ode113` | 高精度非刚性问题 |
| `ode15s` | 刚性问题（如化学反应） |
| `ode23s` | 低精度刚性问题 |

---

## 下一步

- [[14-动力学基础|动力学基础-单自由度振动]]
