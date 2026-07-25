# 31-Simulink快速入门

Simulink是MATLAB的图形化仿真环境——拖拽模块、连线、点运行。非常适合控制系统和物理系统的建模仿真。

---

# 一、第一个Simulink模型

1. 命令窗口打`simulink`打开起始页
2. 点**Blank Model**
3. 打开**Library Browser**（工具栏里像乐高积木的图标）
4. 拖进来：
   - `Sources → Sine Wave`（正弦信号源）
   - `Math Operations → Gain`（增益，设为2）
   - `Sinks → Scope`（示波器）
5. 连线：Sine → Gain → Scope
6. 点绿色三角形运行

Scope里会显示翻倍的正弦波。

---

# 二、传递函数仿真

```
Step → Sum → [Transfer Fcn] → Scope
           ↑_______|
```

`Sum`块做负反馈，`Transfer Fcn`块里填分子分母系数。

---

# 三、PID控制器

```
Step → [PID Controller] → [Transfer Fcn] → Scope
                ↑___________________|
```

双击`PID Controller`块可以实时调$K_p, K_i, K_d$。

---

# 四、从MATLAB导入数据

```matlab
t = 0:0.01:10;
u = sin(t);
simOut = sim('my_model');   % 运行Simulink模型
y = simOut.yout{1}.Values.Data;
plot(t, y);
```

反过来，Simulink里可以用`To Workspace`块把仿真数据送回MATLAB工作区。

---

# 五、子系统封装

选中一组模块 → 右键`Create Subsystem`。子系统就像自定义函数——输入输出端口，内部随便搭，外部只管接。

---

## 下一步

- [[32-Simulink机器人仿真|Simulink机器人仿真]]
