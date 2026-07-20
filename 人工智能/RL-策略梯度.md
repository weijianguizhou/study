# RL — 策略梯度方法

> 本章解决：DQN 需要 $\max_a Q(s,a)$，对于连续动作空间不可行。Policy Gradient 直接对策略参数化，天然适合连续控制。

---

## 前置知识

- [[马尔可夫决策过程 (Markov Decision Process, MDP)|MDP]] — $J(\pi)$、$V^{\pi}$、$Q^{\pi}$ 定义
- [[RL-动态规划与TD|RL-动态规划与TD]] — 优势函数 $A^{\pi}(s,a)$
- [[RL-DQN与值函数近似|RL-DQN与值函数近似]] — 值函数近似与梯度更新
- [[RL-PPO理论|PPO 理论]] — 策略梯度 → PPO 的完整推导（本章的进阶篇）
- [[../../数理基础/概率论|概率论]] — 期望的梯度、重要性采样
- [[../../数理基础/数学分析|数学分析]] — 对数导数技巧 $\nabla \log f(x) = \frac{\nabla f(x)}{f(x)}$
- [[../../数理基础/凸优化|凸优化]] — 梯度上升、KL 散度
- [[../../数理基础/数理统计|数理统计]] — 样本估计、方差减小

---

## 1. 为什么需要策略梯度

### Value-Based 方法的局限

| 问题 | Value-Based (DQN) | Policy-Based |
|------|-------------------|--------------|
| 连续动作 | $\max_a$ 是优化问题 | 直接输出动作分布 |
| 随机策略 | 通常确定性（$\varepsilon$-贪心是启发式） | 天然支持随机策略 |
| 策略表示 | 隐式（通过 $Q$ 导出） | 显式（直接参数化 $\pi$） |

随机策略在以下场景至关重要：
- 对手博弈（石头剪刀布——确定性策略必输）
- 部分可观测环境
- 探索需求

---

## 2. 策略梯度定理 (Policy Gradient Theorem)

### 2.1 目标函数

策略梯度方法直接最大化期望回报：

$$J(\theta) = \mathbb{E}_{\tau \sim \pi_{\theta}} [R(\tau)] = \sum_{\tau} R(\tau) P(\tau \mid \pi_{\theta})$$

其中 $\tau = (s_0, a_0, r_0, s_1, a_1, \dots)$ 是一条完整轨迹。

### 2.2 对数导数技巧 (Log-Derivative Trick)

$$\nabla_{\theta} P(\tau \mid \theta) = P(\tau \mid \theta) \cdot \nabla_{\theta} \log P(\tau \mid \theta)$$

因此：

$$\nabla_{\theta} J(\theta) = \mathbb{E}_{\tau \sim \pi_{\theta}} \left[ R(\tau) \cdot \nabla_{\theta} \log P(\tau \mid \theta) \right]$$

展开 $\log P(\tau \mid \theta)$：

$$P(\tau \mid \theta) = \rho_0(s_0) \prod_{t=0}^{T-1} \underbrace{P(s_{t+1} \mid s_t, a_t)}_{\text{环境，与 }\theta\text{ 无关}} \cdot \underbrace{\pi_{\theta}(a_t \mid s_t)}_{\text{策略}}$$

$$\nabla_{\theta} \log P(\tau \mid \theta) = \sum_{t=0}^{T-1} \nabla_{\theta} \log \pi_{\theta}(a_t \mid s_t)$$

环境转移概率项被消去（与 $\theta$ 无关）——这是策略梯度最大的优势：**不需要环境模型**。

### 2.3 最终梯度

$$\nabla_{\theta} J(\theta) = \mathbb{E}_{\tau \sim \pi_{\theta}} \left[ \sum_{t=0}^{T-1} \underbrace{R(\tau)}_{\text{整条轨迹的回报}} \cdot \nabla_{\theta} \log \pi_{\theta}(a_t \mid s_t) \right]$$

**直觉**：若 $R(\tau)$ 高，则提升轨迹中每个 $a_t$ 的概率；若 $R(\tau)$ 低，则降低。

> 数学基础 → [[../../数理基础/数学分析|数学分析]]：链式法则 $\nabla \log f = \frac{\nabla f}{f}$
> 数学基础 → [[../../数理基础/概率论|概率论]]：对数似然的梯度

---

## 3. REINFORCE — 最朴素的策略梯度

最简单的策略梯度算法：

**REINFORCE (Williams, 1992)**：
1. 用 $\pi_{\theta}$ 采样一条完整轨迹 $\tau$
2. 计算每步的回报 $G_t = \sum_{k=t}^{T} \gamma^{k-t} r_k$
3. 更新 $\theta \leftarrow \theta + \alpha \sum_{t} G_t \nabla_{\theta} \log \pi_{\theta}(a_t \mid s_t)$

**问题**：$G_t$ 方差极大（取决于整条轨迹的随机性）。一条好轨迹中的所有动作都被"信任"——即使某个动作实际上很差。

---

## 4. 方差减小技术

### 4.1 引入 Baseline

$$\nabla_{\theta} J(\theta) = \mathbb{E} \left[ \sum_{t} (G_t - b(s_t)) \cdot \nabla_{\theta} \log \pi_{\theta}(a_t \mid s_t) \right]$$

对于任意只依赖于 $s_t$ 的 baseline $b(s_t)$，期望不变（可证），但方差减小。

**常用 baseline**：$b(s_t) = V^{\pi}(s_t)$，此时 $G_t - V(s_t)$ 近似优势函数。

> 数学基础 → [[../../数理基础/概率论|概率论]]：控制变量法 (control variate)

### 4.2 用 $Q$ 和 $A$ 替代 $G_t$

| 替代量 | 符号 | 方差 | 偏差 |
|--------|------|------|------|
| 整条轨迹回报 | $R(\tau)$ | 极高 | 无偏 |
| $t$ 时刻后回报 | $\sum_{k=t} \gamma^{k-t} r_k$ | 高 | 无偏 |
| 动作值函数 | $Q^{\pi}(s_t, a_t)$ | 中 | 依赖逼近质量 |
| **优势函数** | $A^{\pi}(s_t, a_t) = Q^{\pi} - V^{\pi}$ | 低 | 最小方差 |
| **TD error** | $\delta_t = r_t + \gamma V(s_{t+1}) - V(s_t)$ | 最低 | 有偏 |

实践经验：$A^{\pi}$ 和 $\delta_t$（TD error）是最常用的选择。

---

## 5. Actor-Critic 架构

将策略网络（Actor）和价值网络（Critic）结合：

```
           ┌──────────┐
state s ──►│  Actor   │──► action a
           │  π_θ     │
           └──────────┘
                │
           ┌──────────┐
state s ──►│  Critic  │──► V(s) 或 Q(s,a)
           │  V_φ     │
           └──────────┘
```

**Actor 更新**（策略梯度）：
$$\theta \leftarrow \theta + \alpha \cdot A(s_t, a_t) \cdot \nabla_{\theta} \log \pi_{\theta}(a_t \mid s_t)$$

其中 $A(s_t, a_t)$ 可由 Critic 提供。

**Critic 更新**（TD 学习）：
$$\phi \leftarrow \phi - \beta \cdot \delta_t \cdot \nabla_{\phi} V_{\phi}(s_t)$$

其中 $\delta_t = r_t + \gamma V_{\phi}(s_{t+1}) - V_{\phi}(s_t)$。

### Actor 与 Critic 的互动

```
for t = 1 to T:
    根据 π_θ(s_t) 选择 a_t
    执行 a_t, 观察 r_t, s_{t+1}
    δ_t = r_t + γ V_φ(s_{t+1}) - V_φ(s_t)    ← Critic 计算 TD error
    θ ← θ + α · δ_t · ∇ log π_θ(a_t|s_t)     ← Actor 用 δ_t 更新
    φ ← φ - β · δ_t · ∇ V_φ(s_t)             ← Critic 更新
```

---

## 6. 经典 Actor-Critic 变体

### 6.1 A2C / A3C (Advantage Actor-Critic)

**A2C**：同步版本。多个 worker 独立采样，收集后统一更新。

**A3C**：异步版本。多个 worker 独立采样、独立更新，异步将梯度推送到全局网络。不需要经验回放。

### 6.2 GAE (Generalized Advantage Estimation)

在前一章的 TD($\lambda$) 基础上，GAE 对优势估计做指数平滑：

$$\hat{A}_t^{\text{GAE}(\gamma, \lambda)} = \sum_{l=0}^{\infty} (\gamma \lambda)^l \delta_{t+l}$$

$$\delta_t = r_t + \gamma V(s_{t+1}) - V(s_t)$$

- $\lambda = 0$：退化为 TD(0) 误差（低方差、高偏差）
- $\lambda = 1$：退化为 MC 估计（高方差、低偏差）
- 常用 $\lambda \approx 0.95$

GAE 是 PPO 中的标准配置。详见 → [[RL-PPO理论#8.3 GAE|PPO 理论 · GAE 一节]]

### 6.3 TRPO (Trust Region Policy Optimization)

**核心思想**：策略更新时保证新策略不偏离旧策略太远。

$$\max_{\theta} \; \mathbb{E} \left[ \frac{\pi_{\theta}(a|s)}{\pi_{\theta_{\text{old}}}(a|s)} \hat{A}(s,a) \right] \quad \text{s.t.} \quad \mathbb{E}[D_{\text{KL}}(\pi_{\theta_{\text{old}}} \| \pi_{\theta})] \le \delta$$

使用共轭梯度 + 线性搜索求解，计算代价高。

**→ PPO 是 TRPO 的工程简化版**，用 Clip 或 Penalty 替代显式约束。

### 6.4 Deterministic Policy Gradient (DPG / DDPG)

对**确定性策略** $\mu_{\theta}(s)$，策略梯度定理退化为：

$$\nabla_{\theta} J(\theta) = \mathbb{E}_{s \sim \rho^{\mu}} \left[ \nabla_{a} Q^{\mu}(s, a)|_{a=\mu(s)} \cdot \nabla_{\theta} \mu_{\theta}(s) \right]$$

DDPG 将 DQN 的 Experience Replay + Target Network 与确定性策略梯度结合，适用于连续控制。

---

## 7. 方法谱系总结

```
                     策略梯度 (REINFORCE)
                          │
              ┌───────────┴───────────┐
         Actor-Critic              Baseline 减小方差
              │
     ┌────────┼────────┬──────────┐
    A2C    TRPO      DDPG     SAC
     │       │        │         │
    A3C     PPO      TD3     (最大熵)
     │       │
   (并行)  (Clip/Penalty)
```

---

## 相关笔记

- [[马尔可夫决策过程 (Markov Decision Process, MDP)|MDP]] — 问题框架
- [[RL-动态规划与TD|RL-动态规划与TD]] — 优势函数的基础
- [[RL-DQN与值函数近似|RL-DQN与值函数近似]] — Value-based 对比
- [[RL-PPO理论|PPO 理论]] — 策略梯度的工业级实现（TRPO→PPO→GAE→Critic Loss）
- [[RL-机器人控制|RL 与机器人控制]] — 连续控制的 RL 应用
- [[../../数理基础/概率论|概率论]] — 对数导数技巧、重要性采样
- [[../../数理基础/数学分析|数学分析]] — 梯度推导
- [[../../数理基础/凸优化|凸优化]] — 约束优化、KL 散度
