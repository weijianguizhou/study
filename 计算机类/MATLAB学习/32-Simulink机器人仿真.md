# 32-Simulink机器人仿真

用Simulink搭一个完整的2R机械臂仿真：轨迹生成→逆运动学→控制器→机械臂动力学→正运动学→可视化。

---

# 一、模型结构

```
[Trajectory] → [Inverse Kinematics] → [PID Controller] → [Robot Dynamics] → [Forward Kinematics] → [Scope/3D Plot]
                                         ↑_________________________________|
```

- **Trajectory**：生成参考轨迹$q_d(t)$
- **Inverse Kinematics**：期望末端位姿→期望关节角
- **PID Controller**：算控制力矩
- **Robot Dynamics**：ode积分得到实际$q,\dot{q}$
- **Forward Kinematics**：实际末端位姿→可视化

---

# 二、MATLAB Function块

Simulink里写`MATLAB Function`块可以直接写代码：

```matlab
function tau = robot_controller(q, dq, q_d, dq_d, ddq_d)
    Kp = diag([200, 200]);
    Kd = diag([50, 50]);
    tau = Kp*(q_d - q) + Kd*(dq_d - dq);
end
```

---

# 三、动力学用MATLAB Function

```matlab
function ddq = robot_dynamics(tau, q, dq)
    % 从M(q)ddq + C(q,dq)dq + G(q) = tau解出ddq
    [M, C, G] = compute_dynamics(q, dq);
    ddq = M \ (tau - C*dq - G);
end
```

---

# 四、3D可视化（用MATLAB画）

```matlab
function visualize(q)
    persistent h
    if isempty(h)
        figure; h = plot3(0,0,0,'o-','LineWidth',3);
        xlim([-1 1]); ylim([-1 1]); zlim([0 1]); grid on;
    end
    p = compute_joint_positions(q);
    h.XData = p(1,:); h.YData = p(2,:); h.ZData = p(3,:);
    drawnow;
end
```

---

## 下一步

- [[33-完整2R机器人仿真实例|完整2R机器人仿真实例]]
