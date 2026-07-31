# 马尔可夫决策过程 (Markov Decision Process, MDP)

> MDP 是强化学习的数学框架。本节将建立从概率基础到 Bellman 方程的完整推导链。

---

## 1. 形式化定义

一个有限 MDP 由五元组 $(\mathcal{S}, \mathcal{A}, \mathcal{P}, \mathcal{R}, \gamma)$ 定义：

| 符号 | 名称 | 含义 |
|------|------|------|
| $\mathcal{S}$ | 状态空间 | 所有可能状态的有限集合 |
| $\mathcal{A}$ | 动作空间 | 所有可能动作的有限集合 |
| $\mathcal{P}$ | 状态转移概率 | $\mathcal{P}_{ss'}^{a} = \Pr(S_{t+1}=s' \mid S_t=s, A_t=a)$ |
| $\mathcal{R}$ | 奖励函数 | $\mathcal{R}_{s}^{a} = \mathbb{E}[R_{t+1} \mid S_t=s, A_t=a]$ |
| $\gamma$ | 折扣因子 | $\gamma \in [0,1]$，权衡即时奖励与未来奖励 |

**马尔可夫性质**：下一状态 $S_{t+1}$ 和奖励 $R_{t+1}$ 仅依赖于当前状态 $S_t$ 和动作 $A_t$，与历史无关：
$$\Pr(S_{t+1}, R_{t+1} \mid S_t, A_t, S_{t-1}, A_{t-1}, \dots) = \Pr(S_{t+1}, R_{t+1} \mid S_t, A_t)$$

> 数学基础 → [[../../数理基础/概率论|概率论]]：条件概率、条件期望、全概率公式

---

## 2. 策略 (Policy)

策略 $\pi$ 定义了智能体在每个状态下选择动作的方式：

- **确定性策略**：$\pi(s) = a$，即 $a = \pi(s)$
- **随机策略**：$\pi(a \mid s) = \Pr(A_t=a \mid S_t=s)$

在有限 MDP 中，随机策略更通用。$\pi(a \mid s)$ 是一个条件概率分布，满足 $\sum_{a \in \mathcal{A}} \pi(a \mid s) = 1$。

> 数学基础 → [[../../数理基础/概率论|概率论]]：条件分布

---

## 3. 回报 (Return)

从时刻 $t$ 开始的累积折扣奖励称为**回报** $G_t$：

$$G_t = R_{t+1} + \gamma R_{t+2} + \gamma^2 R_{t+3} + \cdots = \sum_{k=0}^{\infty} \gamma^k R_{t+k+1}$$

**为什么需要折扣因子 $\gamma$？**
1. **数学上**：保证无穷级数收敛（当 $\gamma < 1$ 且奖励有界时）
2. **经济上**：今天的 1 元钱比明天的 1 元钱更有价值
3. **实际上**：避免 agent 无限拖延收集奖励

$\gamma = 0$ 表示 agent 只关心即时奖励（贪心策略），$\gamma \to 1$ 表示远见卓识。

> 数学基础 → [[../../数理基础/数学分析|数学分析]]：级数收敛、几何级数 $\sum_{k=0}^{\infty} \gamma^k = \frac{1}{1-\gamma}$

---

## 4. 值函数 (Value Functions)

### 4.1 状态值函数 $V^{\pi}(s)$

在策略 $\pi$ 下，从状态 $s$ 出发的期望回报：

$$V^{\pi}(s) = \mathbb{E}_{\pi}\left[G_t \mid S_t = s\right] = \mathbb{E}_{\pi}\left[\sum_{k=0}^{\infty} \gamma^k R_{t+k+1} \;\middle|\; S_t = s\right]$$

$\mathbb{E}_{\pi}[\cdot]$ 表示 agent 按策略 $\pi$ 选择动作，环境按转移概率 $\mathcal{P}$ 给出下一状态时的期望。

### 4.2 动作值函数 $Q^{\pi}(s, a)$

在策略 $\pi$ 下，从状态 $s$ 执行动作 $a$ 后的期望回报：

$$Q^{\pi}(s, a) = \mathbb{E}_{\pi}\left[G_t \mid S_t = s, A_t = a\right]$$

### 4.3 $V^{\pi}$ 与 $Q^{\pi}$ 的关系

$$V^{\pi}(s) = \sum_{a \in \mathcal{A}} \pi(a \mid s) \, Q^{\pi}(s, a)$$

状态值 = 所有可能动作的动作值的策略加权平均。

> 数学基础 → [[../../数理基础/概率论|概率论]]：全期望公式 $\mathbb{E}[X] = \mathbb{E}[\mathbb{E}[X \mid Y]]$

---

## 5. Bellman 期望方程

Bellman 方程是 MDP 中最重要的递推关系，它将值函数分解为**即时奖励**与**后继状态值函数**之和。

### 5.1 $V^{\pi}$ 的 Bellman 方程

$$V^{\pi}(s) = \sum_{a \in \mathcal{A}} \pi(a \mid s) \left[ \mathcal{R}_s^a + \gamma \sum_{s' \in \mathcal{S}} \mathcal{P}_{ss'}^a \, V^{\pi}(s') \right]$$

**含义**：
1. 在状态 $s$，按策略 $\pi$ 选择动作 $a$
2. 获得即时期望奖励 $\mathcal{R}_s^a$
3. 以概率 $\mathcal{P}_{ss'}^a$ 转移到下一状态 $s'$
4. 后续累积 $\gamma V^{\pi}(s')$

### 5.2 $Q^{\pi}$ 的 Bellman 方程

$$Q^{\pi}(s, a) = \mathcal{R}_s^a + \gamma \sum_{s' \in \mathcal{S}} \mathcal{P}_{ss'}^a \sum_{a' \in \mathcal{A}} \pi(a' \mid s') \, Q^{\pi}(s', a')$$

或者等价地：
$$Q^{\pi}(s, a) = \mathcal{R}_s^a + \gamma \sum_{s' \in \mathcal{S}} \mathcal{P}_{ss'}^a \, V^{\pi}(s')$$

### 5.3 Bellman 方程的矩阵形式

将 $V^{\pi}$ 视为 $|\mathcal{S}|$ 维向量，Bellman 方程可写成：

$$\mathbf{V}^{\pi} = \mathbf{R}^{\pi} + \gamma \mathbf{P}^{\pi} \mathbf{V}^{\pi}$$

其解析解为：
$$\mathbf{V}^{\pi} = (\mathbf{I} - \gamma \mathbf{P}^{\pi})^{-1} \mathbf{R}^{\pi}$$

> 数学基础 → [[../../数理基础/代数/代数基础|代数基础]]：线性方程组求解、矩阵求逆
> 数学基础 → [[../../数理基础/数学分析|数学分析]]：不动点理论 — $V^{\pi}$ 是 Bellman 算子 $\mathcal{T}^{\pi}$ 的唯一不动点

---

## 6. Bellman 最优方程

### 6.1 最优值函数

**最优状态值函数** $V^{*}(s)$：在所有策略中，从 $s$ 出发可获得的最大期望回报：
$$V^{*}(s) = \max_{\pi} V^{\pi}(s)$$

**最优动作值函数** $Q^{*}(s, a)$：
$$Q^{*}(s, a) = \max_{\pi} Q^{\pi}(s, a)$$

### 6.2 Bellman 最优方程

$$V^{*}(s) = \max_{a \in \mathcal{A}} \left[ \mathcal{R}_s^a + \gamma \sum_{s' \in \mathcal{S}} \mathcal{P}_{ss'}^a \, V^{*}(s') \right]$$

$$Q^{*}(s, a) = \mathcal{R}_s^a + \gamma \sum_{s' \in \mathcal{S}} \mathcal{P}_{ss'}^a \, \max_{a' \in \mathcal{A}} Q^{*}(s', a')$$

关键直觉：在最优策略下，每个状态的最优值 = 选择最优动作后的即时奖励 + 后继状态的最优值的折扣。

### 6.3 最优策略

已知 $Q^{*}$，最优策略为：
$$\pi^{*}(s) = \arg\max_{a \in \mathcal{A}} Q^{*}(s, a)$$

即：在每个状态选择使 $Q$ 值最大的动作（贪心策略）。

> 数学基础 → [[../../数理基础/凸优化|凸优化]]：最大化问题 — 注意 Bellman 最优方程是非线性的（含有 $\max$ 算子）

---

## 7. 强化学习 vs 规划

| | 已知条件 | 核心问题 | 典型方法 |
|---|---------|---------|---------|
| **动态规划 (DP)** | $\mathcal{P}$ 和 $\mathcal{R}$ 已知 | 直接求解 Bellman 方程 | 策略迭代、值迭代 |
| **蒙特卡洛 (MC)** | 仅有采样轨迹 | 从经验中估计 $V^{\pi}$ | 完整回报平均 |
| **时序差分 (TD)** | 仅有采样轨迹 | 从经验中 bootstrap | TD(0)、SARSA、Q-Learning |

> → [[RL-动态规划与TD|RL-动态规划与TD]]：DP / MC / TD 的详细对比与算法

---

## 8. 与马尔可夫链的层级关系

$$\text{马尔可夫链 (MC)} \;\subset\; \text{马尔可夫奖励过程 (MRP)} \;\subset\; \text{马尔可夫决策过程 (MDP)}$$

- **MC**：仅有 $\mathcal{S}$ 和 $\mathcal{P}$，无奖励、无动作
- **MRP**：在 MC 基础上添加 $\mathcal{R}$ 和 $\gamma$，引入 $V(s)$
- **MDP**：在 MRP 基础上添加 $\mathcal{A}$（决策），引入 $Q(s,a)$ 和控制

> 数学基础 → [[../../数理基础/概率论|概率论]]：随机过程、Markov 性质
> 数学基础 → [[../../数理基础/随机过程/随机微分方程|随机微分方程]]：MDP 是离散时间/离散状态的随机控制；SDE 是连续时间/连续状态的随机控制

---

## 相关笔记

- [[RL-PPO理论|PPO 理论]] — 基于策略梯度的深度 RL 算法
- [[RL-动态规划与TD|RL-动态规划与TD]] — DP / MC / TD 求解方法
- [[RL-DQN与值函数近似|RL-DQN与值函数近似]] — 深度 Q 网络
- [[RL-策略梯度|RL-策略梯度]] — Policy Gradient 方法族
- [[RL-机器人控制|RL 与机器人控制]] — MDP 在物理系统中的应用
- [[../../数理基础/概率论|概率论]] — 概率空间、条件期望、随机过程
- [[../../数理基础/随机过程/随机微分方程|随机微分方程]] — MDP 的连续类比
- [[../../数理基础/代数/代数基础|代数基础]] — Bellman 方程的矩阵求解
- [[../../数理基础/凸优化|凸优化]] — 最优策略的存在性与求解
- [[../../数理基础/数学分析|数学分析]] — 不动点定理、级数收敛
