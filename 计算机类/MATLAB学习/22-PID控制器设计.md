# 22-PID控制器设计

$$u(t) = K_p e(t) + K_i \int_0^t e(\tau)d\tau + K_d \frac{de}{dt}$$

---

# 复习一下控制理论

## 1. 三项各干什么

PID三个字母代表三个动作，各有各的职责：

**P — 比例（现在）**：$u = K_p e$。误差有多大就出多大力。$K_p$大了响应快，但也容易超调和振荡。光靠P永远消除不了稳态误差——你想想，如果没误差了($e=0$)，$K_p \times 0 = 0$就没输出，系统又偏了。刚拉回来就没力了，所以永远停在"有一点误差刚好够P撑着"的状态。

**I — 积分（过去）**：$u = K_i \int e\, dt$。把历史上所有误差累积起来。只要误差一直不为零，积分就一直增长，输出就一直增大——直到把误差逼到零。所以**I消除稳态误差**。但积分是"慢变量"，加多了会让系统迟钝、震荡。积分饱和也是个问题——误差大时积分迅速累积，即使控制量已经饱和了还继续累，恢复后出现大幅过冲。

**D — 微分（未来趋势）**：$u = K_d \frac{de}{dt}$。误差在增大还是减小？增大→加大输出提前抑制，减小→减小输出避免过冲。**D提供阻尼**，压下超调和振荡。但D对噪声极其敏感——噪声的导数更大！实际中微分项前通常串一个低通滤波器$\frac{N}{1+N/s}$，或者对测量信号先滤波再微分。

## 2. 时域直觉

想象你在开车跟前面的车保持距离：
- **P**：离得远就踩油门，离得近就松——但光这样总是在目标距离前后晃。
- **I**：如果长时间跟不近，慢慢加大油门——消除"总是差一点"的稳态偏差。
- **D**：看到前车在急刹车（距离快速减小），提前松油——防追尾。

## 3. 频域视角

PID的传递函数：$C(s) = K_p + \frac{K_i}{s} + K_d s$

- $K_p$：全频段均匀抬高增益
- $\frac{K_i}{s}$：低频段大幅提高增益（消除稳态误差），高频衰减
- $K_d s$：高频段提高增益（加速响应），但对噪声也放大

积分在低频工作（稳态），微分在高频工作（暂态），比例全覆盖。三者配合，覆盖了全频段的需求。

---

# MATLAB实现

## 手工搭建

```matlab
s = tf('s');
G = 1 / (s^2 + 3*s + 2);

Kp = 10; Ki = 5; Kd = 1;
C = Kp + Ki/s + Kd*s;        % PID传递函数

T = feedback(C*G, 1);        % 闭环
step(T);
```

手动调可以，但效率低。`pidtune`能自动给你找最优参数：

```matlab
[C, info] = pidtune(G, 'PID');
T = feedback(C*G, 1);
step(T);
fprintf('PM: %.1f°  GM: %.1f dB\n', info.StabilityMargin);
```

`pidtune`内部是基于频域的优化——它设计一个目标开环穿越频率和相位裕度，然后自动求解满足条件的PID参数。

## Ziegler-Nichols（经典手调法）

在没有模型、只有实物的情况下用的经典方法：

1. 把$K_i$和$K_d$设为零，只留$K_p$
2. 逐渐增大$K_p$直到系统出现等幅振荡——此时的$K_p$叫**临界增益$K_u$**
3. 测量振荡周期$T_u$
4. 查表：
   - P控制：$K_p = 0.5 K_u$
   - PI控制：$K_p = 0.45 K_u,\; T_i = 0.85 T_u$
   - PID控制：$K_p = 0.6 K_u,\; T_i = 0.5 T_u,\; T_d = 0.125 T_u$

Z-N的参数通常偏激进（超调大），建议以此为起点再手动微调。

## 抗积分饱和

```matlab
function u = pid_antiwindup(e, dt, Kp, Ki, Kd, u_min, u_max)
    persistent integral prev_e
    if isempty(integral), integral = 0; prev_e = 0; end
    
    integral = integral + e * dt;
    derivative = (e - prev_e) / dt;
    prev_e = e;
    u = Kp*e + Ki*integral + Kd*derivative;
    
    % 饱和处理 + 退饱和
    if u > u_max
        u = u_max;
        integral = integral - e*dt;   % 退饱和：输出被限时停止积分
    elseif u < u_min
        u = u_min;
        integral = integral - e*dt;
    end
end
```

关键是`integral = integral - e*dt`这行——输出被限幅了，就不应该继续累积误差，否则解限后会有一个巨大的积分尾巴。

---

## 下一步

- [[23-状态空间与LQR|状态空间与LQR]]
