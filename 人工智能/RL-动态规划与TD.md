# RL — 动态规划与蒙特卡洛/时序差分方法

> 本章解决：已知 MDP，如何求解最优策略与最优值函数？

---

## 前置知识

- [[马尔可夫决策过程 (Markov Decision Process, MDP)|MDP 框架]] — 五元组、Bellman 方程
- [[../../数理基础/概率论|概率论]] — 条件期望、大数定律、Monte Carlo 积分
- [[../../数理基础/代数/代数基础|代数基础]] — Bellman 方程是线性方程组
- [[../../数理基础/数学分析|数学分析]] — 压缩映射、不动点定理（Banach 不动点定理）

---

## 1. 动态规划 (Dynamic Programming, DP)

**前提**：已知 MDP 的完整模型（$\mathcal{P}$ 和 $\mathcal{R}$ 均已知）。

DP 方法直接求解 Bellman 方程。它有两个核心操作：

### 1.1 策略评估 (Policy Evaluation)

给定策略 $\pi$，通过迭代计算 $V^{\pi}$。Bellman 期望方程：

$$V_{k+1}(s) = \sum_{a \in \mathcal{A}} \pi(a \mid s) \left[ \mathcal{R}_s^a + \gamma \sum_{s' \in \mathcal{S}} \mathcal{P}_{ss'}^a \, V_k(s') \right]$$

持续迭代直到收敛（$k \to \infty$ 时 $V_k \to V^{\pi}$）。

**收敛性保证**：迭代算子 $\mathcal{T}^{\pi}$ 是 $\gamma$-压缩映射（由 Banach 不动点定理保证）。

### 1.2 策略改进 (Policy Improvement)

基于 $V^{\pi}$ 构造贪心策略 $\pi'$：

$$\pi'(s) = \arg\max_{a} \left[ \mathcal{R}_s^a + \gamma \sum_{s'} \mathcal{P}_{ss'}^a \, V^{\pi}(s') \right]$$

> **策略改进定理**：$\pi'$ 一定不差于 $\pi$（即 $V^{\pi'}(s) \ge V^{\pi}(s)$ 对所有 $s$ 成立）。

### 1.3 策略迭代 (Policy Iteration)

重复：策略评估 $\to$ 策略改进 $\to$ 策略评估 $\to \cdots$ 直到策略不再变化。

```
初始策略 π₀
重复:
    评估 V^{π_k}  (通过迭代求解 Bellman 期望方程)
    改进 π_{k+1} ← 贪心(V^{π_k})
直到 π_{k+1} = π_k
```

对有限 MDP，策略迭代在有限步内收敛到 $\pi^{*}$。

### 1.4 值迭代 (Value Iteration)

将评估与改进合并为一步——直接使用 Bellman 最优方程迭代：

$$V_{k+1}(s) = \max_{a} \left[ \mathcal{R}_s^a + \gamma \sum_{s'} \mathcal{P}_{ss'}^a \, V_k(s') \right]$$

收敛后，最优策略为：

$$\pi^{*}(s) = \arg\max_{a} \left[ \mathcal{R}_s^a + \gamma \sum_{s'} \mathcal{P}_{ss'}^a \, V^{*}(s') \right]$$

### DP 方法对比

| 方法 | 每次迭代 | 收敛速度 | 特点 |
|------|---------|---------|------|
| 策略迭代 | 先评估再改进 | 最快（轮数最少） | 每轮代价高 |
| 值迭代 | 一次 Bellman 最优更新 | 较慢 | 每步简单 |
| 广义策略迭代 (GPI) | 评估与改进交织 | 灵活 | 大多数 RL 方法的框架 |

> 数学基础 → [[../../数理基础/凸优化|凸优化]]：策略改进本质上是一个逐点最大化问题
> 数学基础 → [[../../数理基础/数学分析|数学分析]]：压缩映射与 Banach 不动点定理确保收敛

---

## 2. 蒙特卡洛方法 (Monte Carlo, MC)

**前提**：模型未知，但可以从环境中采样完整的 episode。

### 2.1 核心思想

直接从经验（采样轨迹）中估计值函数，不依赖模型。

$$V^{\pi}(s) = \mathbb{E}_{\pi}[G_t \mid S_t = s] \approx \frac{1}{N(s)} \sum_{i: S_t^{(i)} = s} G_t^{(i)}$$

其中 $N(s)$ 是从状态 $s$ 出发的采样次数，$G_t$ 是从 $t$ 时刻到 episode 结束的实际回报。

### 2.2 First-Visit MC vs Every-Visit MC

- **First-Visit MC**：每个 episode 中只使用状态 $s$ 的第一次出现来更新
- **Every-Visit MC**：使用状态 $s$ 的每一次出现来更新

两种方法都收敛到 $V^{\pi}$（由大数定律保证）。

### 2.3 MC 估计 $Q^{\pi}$

MC 更适合估计 $Q^{\pi}$（因为模型未知时 $V^{\pi}$ 无法直接用于策略改进）：

$$Q^{\pi}(s, a) \approx \frac{1}{N(s, a)} \sum G_t \quad \text{（其中 } S_t=s, A_t=a \text{）}$$

### 2.4 探索问题

MC 需要保证每个 $(s, a)$ 对被充分访问。解决方法：

- **Exploring Starts**：从随机 $(s_0, a_0)$ 开始
- **$\varepsilon$-贪心**：以概率 $1-\varepsilon + \varepsilon/|\mathcal{A}|$ 选最优动作，以概率 $\varepsilon/|\mathcal{A}|$ 随机探索

### MC 优缺点

| 优点 | 缺点 |
|------|------|
| 无偏估计 | 方差大 |
| 不需要模型 | 需要完整 episode |
| 天然适合 episodic 任务 | 不适合连续任务 |
| 收敛到局部最优（$\varepsilon$-贪心） | 学习效率低 |

> 数学基础 → [[../../数理基础/概率论|概率论]]：大数定律、无偏估计
> 数学基础 → [[../../数理基础/数理统计|数理统计]]：样本均值作为期望的估计量

---

## 3. 时序差分学习 (Temporal Difference, TD)

**前提**：模型未知，但可以从非完整 episode 中学习。

TD 是 MC 和 DP 的结合：像 MC 一样从经验学，像 DP 一样 bootstrap（用当前估计去更新当前估计）。

### 3.1 TD(0) — 最简单的 TD 方法

$$V(S_t) \leftarrow V(S_t) + \alpha \big[ \underbrace{R_{t+1} + \gamma V(S_{t+1})}_{\text{TD 目标}} - \underbrace{V(S_t)}_{\text{当前估计}} \big]$$

$$\hspace{3cm} \text{TD error} = \delta_t$$

- **MC**：目标 = $G_t$（实际完整回报，无偏但方差大）
- **TD(0)**：目标 = $R_{t+1} + \gamma V(S_{t+1})$（有偏但方差小）
- **DP**：目标 = 对所有后继状态加权求和（需要模型）

### 3.2 SARSA — On-Policy TD Control

SARSA 估计动作值函数 $Q$ 并同时用 $\varepsilon$-贪心选择动作：

$$Q(S_t, A_t) \leftarrow Q(S_t, A_t) + \alpha \big[ R_{t+1} + \gamma Q(S_{t+1}, A_{t+1}) - Q(S_t, A_t) \big]$$

状态 → 动作 → 奖励 → 下一状态 → 下一动作（SARSA 因此得名）。

### 3.3 Q-Learning — Off-Policy TD Control

Q-Learning 使用贪心目标，但与行为策略（$\varepsilon$-贪心）解耦：

$$Q(S_t, A_t) \leftarrow Q(S_t, A_t) + \alpha \big[ R_{t+1} + \gamma \max_{a'} Q(S_{t+1}, a') - Q(S_t, A_t) \big]$$

**关键区别**：
| | SARSA (on-policy) | Q-Learning (off-policy) |
|---|-------------------|------------------------|
| 更新规则 | 实际动作 $A_{t+1}$ 的 $Q$ 值 | $\max$ 下的 $Q$ 值 |
| 学习策略 | $\varepsilon$-贪心 | 贪心 |
| 行为 | 较保守（考虑探索风险） | 较激进（假设最优行为） |

### 3.4 TD($\lambda$) 与 Eligibility Traces

在 MC 和 TD(0) 之间通过参数 $\lambda \in [0,1]$ 平滑过渡：

$$\lambda\text{-回报}: \quad G_t^{\lambda} = (1-\lambda) \sum_{n=1}^{\infty} \lambda^{n-1} G_t^{(n)}$$

其中 $G_t^{(n)}$ 是 $n$ 步回报：
$$G_t^{(n)} = R_{t+1} + \gamma R_{t+2} + \cdots + \gamma^{n-1} R_{t+n} + \gamma^n V(S_{t+n})$$

- $\lambda = 0$：TD(0)
- $\lambda = 1$：MC
- 实际常用 $\lambda \approx 0.9$

> 数学基础 → [[../../数理基础/数学分析|数学分析]]：指数加权平均、几何级数

---

## 4. 三种方法的统一视角

| 维度 | DP | MC | TD |
|------|-----|-----|-----|
| 需要模型？ | 是 | 否 | 否 |
| Bootstrap？ | 是 | 否 | 是 |
| 采样？ | 否（全期望） | 是（完整轨迹） | 是（单步） |
| 偏差 | 低（精确模型） | 无偏 | 有偏 |
| 方差 | 低 | 高 | 中 |
| 适用 | 小/中等 MDP | episodic 任务 | 连续/非连续任务 |

**核心洞察**：RL 的几乎所有方法都处于 **DP — MC — TD** 的三角形中，在"偏差-方差"和"计算效率"之间寻找平衡。

---

## 5. 梯度视角下的 TD 方法

在函数近似框架下（见下一章），TD 方法可以理解为**半梯度方法**（semi-gradient methods），因为它们忽略了目标中也包含估计参数的影响。

TD 误差 $\delta_t$ 正是 Critic 网络所要最小化的对象——这是 Actor-Critic 架构的核心组件。

> → [[RL-DQN与值函数近似|RL-DQN与值函数近似]]：从表格方法到函数近似
> → [[RL-策略梯度|RL-策略梯度]]：Policy Gradient 与 Actor-Critic

---

## 相关笔记

- [[马尔可夫决策过程 (Markov Decision Process, MDP)|MDP]] — 问题框架
- [[RL-DQN与值函数近似|RL-DQN与值函数近似]] — 值函数近似的深度方法
- [[RL-策略梯度|RL-策略梯度]] — 策略搜索方法
- [[RL-PPO理论|PPO 理论]] — 当前最强的 on-policy RL
- [[../../数理基础/概率论|概率论]] — 大数定律、Monte Carlo 积分
- [[../../数理基础/数理统计|数理统计]] — 样本估计
- [[../../数理基础/数学分析|数学分析]] — 压缩映射、Banach 不动点定理
- [[../../数理基础/代数/代数基础|代数基础]] — Bellman 方程的矩阵形式
