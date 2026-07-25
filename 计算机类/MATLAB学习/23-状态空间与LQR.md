# 23-状态空间与LQR

---

# 复习一下控制理论

## 1. 为什么要状态空间

传递函数有个致命弱点：它只描述**输入到输出**的关系，看不到系统**内部**发生了什么。两个完全不同的物理系统可以有完全相同的传递函数——传递函数把内部信息全压缩掉了，只留输入输出的"黑箱关系"。

状态空间把系统内部扒开，暴露出所有**状态变量**。一个$n$阶系统的完整描述是：

$$\dot{\mathbf{x}} = A\mathbf{x} + B\mathbf{u}$$
$$\mathbf{y} = C\mathbf{x} + D\mathbf{u}$$

- $\mathbf{x} \in \mathbb{R}^n$：状态向量——包含了系统的全部"记忆"。知道当前状态，就能预测未来的所有行为。
- $A$：系统矩阵——状态之间如何互相影响、如何自然演化
- $B$：输入矩阵——控制输入通过什么通道影响状态
- $C$：输出矩阵——我们能测量到状态的哪些组合
- $D$：直通矩阵——输入直接出现在输出里（大部分系统D=0）

举个例子：弹簧-质量-阻尼系统$\ddot{x} + 3\dot{x} + 2x = u$。选状态$x_1 = x$（位置），$x_2 = \dot{x}$（速度）。则：

$$\frac{d}{dt}\begin{pmatrix} x_1 \\ x_2 \end{pmatrix} = \begin{pmatrix} 0 & 1 \\ -2 & -3 \end{pmatrix} \begin{pmatrix} x_1 \\ x_2 \end{pmatrix} + \begin{pmatrix} 0 \\ 1 \end{pmatrix} u$$

$$y = \begin{pmatrix} 1 & 0 \end{pmatrix} \begin{pmatrix} x_1 \\ x_2 \end{pmatrix}$$

第一行是$\dot{x}_1 = x_2$（位置的导数=速度）。第二行是$\dot{x}_2 = -2x_1 - 3x_2 + u$（加速度=弹簧力+阻尼力+外力）。

## 2. 能控性和能观性

**能控性**：我能通过输入把系统从任意初始状态"开"到任意目标状态吗？

$$Co = [B\;\; AB\;\; A^2B\;\; \cdots\;\; A^{n-1}B]$$

如果$\operatorname{rank}(Co) = n$（满秩），系统能控。满秩意味着$B, AB, A^2B, \ldots$这$n$个向量张成了整个状态空间——输入可以通过各种"渠道"（直接、经过A、经过A²……）触及每一个状态维度。

**能观性**：光看输出，我能推测出系统的全部内部状态吗？

$$Ob = \begin{pmatrix} C \\ CA \\ CA^2 \\ \vdots \\ CA^{n-1} \end{pmatrix}$$

如果$\operatorname{rank}(Ob) = n$，系统能观。满秩意味着不同初始状态一定产生不同输出轨迹，我们可以从输出反向推断状态。

## 3. LQR最优控制

PID是"试出来的"，LQR是"算出来的"——你告诉它什么重要，它给你最优的控制律。

问题表述：找一个状态反馈$u = -K\mathbf{x}$，使以下代价函数最小：

$$J = \int_0^\infty (\mathbf{x}^T Q \mathbf{x} + \mathbf{u}^T R \mathbf{u})\, dt$$

- $Q$：状态权重矩阵（对角元大 = 该状态快速归零）
- $R$：控制权重矩阵（对角元大 = 省力，不要猛打）

$Q$和$R$的**比值**决定系统性能。这本质是一个trade-off：要求速度就得花大力气（大$Q$/小$R$），想省力就得忍受慢响应（小$Q$/大$R$）。

解是**Riccati方程**：

$$A^T P + PA - PBR^{-1}B^T P + Q = 0$$

解出正定矩阵$P$后，最优增益$K = R^{-1}B^T P$。推导过程用变分法或动态规划HJB方程——好在MATLAB有`lqr`直接算，不用手推Riccati。

## 4. 闭环性质

加上$u = -Kx$后，闭环系统变成$\dot{x} = (A - BK)x$。LQR的牛逼之处在于：不管$Q,R$怎么选，只要$(A,B)$能控，闭环一定**稳定**（所有特征值实部<0），而且有**至少60°相位裕度**和**无穷大增益裕度**。这比PID的鲁棒性还强。

---

# MATLAB实现

```matlab
A = [0, 1; -2, -3]; B = [0; 1]; C = [1, 0]; D = 0;
sys = ss(A, B, C, D);

% 能控性和能观性
fprintf('能控? %d\n', rank(ctrb(A,B)) == size(A,1));
fprintf('能观? %d\n', rank(obsv(A,C)) == size(A,1));
```

```matlab
% LQR设计
Q = diag([10, 1]);   % 位置权重>速度——希望位置先归零
R = 1;               % 控制代价

[K, P, e] = lqr(A, B, Q, R);
sys_cl = ss(A - B*K, B, C, D);
step(sys_cl);
```

`e`是闭环极点——$A-BK$的特征值。LQR自动把它们放在最优位置。

## LQR + 积分控制

标准LQR有稳态误差（因为没有积分）。加一个积分状态$\dot{x}_I = y - r$：

```matlab
A_aug = [A, zeros(2,1); -C, 0];
B_aug = [B; 0];
Q_aug = diag([10, 1, 100]);   % 第三个=积分权重
K_aug = lqr(A_aug, B_aug, Q_aug, R);
Kx = K_aug(1:2); Ki = -K_aug(3);
```

---

## 下一步

- [[24-机器人正运动学|机器人正运动学]]
