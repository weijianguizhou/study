# 38-Simscape多体动力学

Simscape是Simulink的物理建模扩展——你不用手写运动方程，像搭积木一样把刚体、关节、力源拼出来，Simscape自己算动力学。

---

# 一、建模步骤

1. 命令行打`smnew`新建模板
2. 从Library Browser拖模块：
   - `Body Elements → Solid`（刚体）
   - `Joints → Revolute Joint`（转动关节）
   - `Frames and Transforms → Rigid Transform`（坐标系变换）
   - `Forces and Torques → External Force`
3. 连线：World Frame → 关节1 → 连杆1 → 关节2 → 连杆2
4. 双击每个模块设置质量、惯性、几何
5. 运行

---

# 二、与Simulink控制器结合

```matlab
% Simscape输出关节角q到工作区
% Simulink控制器算出tau
% tau送进Simscape关节的Actuation端口
```

控制器照常用`MATLAB Function`块写——跟Simscape完全分离，各管各的。

---

# 三、导出到MATLAB

```matlab
simOut = sim('my_model');
q = simOut.logsout{1}.Values.Data;
```

---

## 下一步

- [[39-机器人正运动学可视化|机器人可视化]]
