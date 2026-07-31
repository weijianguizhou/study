# 29-机器人独立关节PID控制

每个关节一个PID——忽略关节间的耦合。对低速、轻载的机器人够用。

---

# 一、PID + 前馈

$$\tau = K_p(q_d - q) + K_d(\dot{q}_d - \dot{q}) + K_i\int (q_d - q) dt + \hat{\tau}_{ff}$$

前馈项$\hat{\tau}_{ff}$可以用期望轨迹代入动力学算出来的力矩：

```matlab
function tau = pid_ff_control(q, dq, q_d, dq_d, ddq_d, M_func, C_func, G_func, params)
    Kp = 100 * eye(2); Kd = 20 * eye(2); Ki = 10 * eye(2);
    persistent integral; if isempty(integral), integral = [0;0]; end
    
    e = q_d - q; de = dq_d - dq;
    integral = integral + e * 0.001;
    
    M = M_func(q_d, params);
    C = C_func(q_d, dq_d, params);
    G = G_func(q_d, params);
    tau_ff = M * ddq_d + C * dq_d + G;        % 前馈力矩
    
    tau = Kp*e + Kd*de + Ki*integral + tau_ff;
end
```

---

# 二、计算力矩控制（CTC）

$$\tau = M(q)(\ddot{q}_d + K_d\dot{e} + K_pe) + C(q,\dot{q})\dot{q} + G(q)$$

把非线性动力学全部抵消，剩下一个线性的误差动态：

```matlab
function tau = computed_torque(q, dq, q_d, dq_d, ddq_d, M_f, C_f, G_f, p)
    Kp = 200 * eye(2); Kd = 50 * eye(2);
    e = q_d - q; de = dq_d - dq;
    
    M = M_f(q, p); C = C_f(q,dq,p); G = G_f(q,p);
    tau = M * (ddq_d + Kd*de + Kp*e) + C*dq + G;
end
```

CTC的物理直觉：**先算需要多大的力来抵消物理效应（重力、科氏力），再在这个基础上叠加线性控制**。

---

# 三、完整仿真循环

```matlab
for k = 1:length(t)-1
    dt = t(k+1) - t(k);
    
    % 当前参考
    q_d = q_ref(:,k); dq_d = dq_ref(:,k); ddq_d = ddq_ref(:,k);
    
    % 控制力矩
    tau = computed_torque(q, dq, q_d, dq_d, ddq_d, M_f, C_f, G_f, p);
    
    % 数值积分（Euler法——简单但不够准，演示用）
    M = M_f(q, p); C = C_f(q,dq,p); G = G_f(q,p);
    ddq = M \ (tau - C*dq - G);
    dq = dq + dt * ddq;
    q = q + dt * dq;
    
    % 记录
    q_hist(:,k+1) = q;
end
```

---

## 下一步

- [[30-阻抗与导纳控制|阻抗与导纳控制]]
