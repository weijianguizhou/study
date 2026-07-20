# RL — DQN 与值函数近似

> 本章解决：当状态/动作空间连续或巨大时，表格方法失效。如何用神经网络近似值函数？

---

## 前置知识

- [[马尔可夫决策过程 (Markov Decision Process, MDP)|MDP]] — $Q(s,a)$、$V(s)$ 定义
- [[RL-动态规划与TD|RL-动态规划与TD]] — TD、Q-Learning、SARSA
- [[../../数理基础/代数/代数基础|代数基础]] — 梯度下降、矩阵运算
- [[../../数理基础/数学分析|数学分析]] — 均方误差最小化、梯度
- [[../机器学习与深度学习/0.绪论|深度学习绪论]]
- [[../机器学习与深度学习/1.机器学习概述|机器学习概述]]

---

## 1. 从表格到函数近似

### 1.1 表格方法的局限

- 状态空间爆炸：围棋 $3^{361}$ 种状态
- 连续状态空间：机器人的关节角度是连续值
- 内存不可行：$|\mathcal{S}| \times |\mathcal{A}|$ 的表格无法存储

### 1.2 函数近似

用一个参数化函数 $\hat{v}(s, \mathbf{w}) \approx V^{\pi}(s)$ 或 $\hat{q}(s, a, \mathbf{w}) \approx Q^{\pi}(s, a)$ 来替代表格。

$$\hat{v}(s, \mathbf{w}) = \mathbf{w}^{\mathsf{T}} \mathbf{x}(s) \quad \text{（线性函数近似）}$$

$$\hat{q}(s, a, \mathbf{w}) = f_{\mathbf{w}}(s, a) \quad \text{（非线性 / 神经网络近似）}$$

其中 $\mathbf{x}(s)$ 是状态的特征向量，$\mathbf{w}$ 是权重。

### 1.3 预测目标

我们希望最小化 TD 误差的平方（均值意义下）：

$$L(\mathbf{w}) = \mathbb{E}_{\pi}\left[ (R_{t+1} + \gamma \hat{v}(S_{t+1}, \mathbf{w}) - \hat{v}(S_t, \mathbf{w}))^2 \right]$$

$$\mathbf{w} \leftarrow \mathbf{w} + \alpha \underbrace{\delta_t \nabla_{\mathbf{w}} \hat{v}(S_t, \mathbf{w})}_{\text{半梯度更新}}$$

> 注意：这是**半梯度**方法（semi-gradient），因为 TD 目标中的 $\hat{v}(S_{t+1}, \mathbf{w})$ 也依赖于 $\mathbf{w}$，但我们在求梯度时将其视为常数。这引入偏差，但使算法稳定。

> 数学基础 → [[../../数理基础/代数/代数基础|代数基础]]：梯度下降 $\mathbf{w} \leftarrow \mathbf{w} - \alpha \nabla L(\mathbf{w})$
> 数学基础 → [[../../数理基础/数学分析|数学分析]]：可微函数、链式法则

---

## 2. DQN (Deep Q-Network)

2013/2015 年，DeepMind 将卷积神经网络与 Q-Learning 结合，在 Atari 游戏中达到人类水平。

### 2.1 核心架构

DQN 用神经网络 $Q(s, a; \theta)$ 来近似最优动作值函数 $Q^{*}(s, a)$。

**输入**：状态 $s$（可以是图像像素）
**输出**：每个动作 $a$ 的 $Q$ 值
**损失函数**：

$$L(\theta) = \mathbb{E}_{(s,a,r,s') \sim \mathcal{D}} \left[ \big( \underbrace{r + \gamma \max_{a'} Q(s', a'; \theta^{-})}_{\text{TD 目标}} - Q(s, a; \theta) \big)^2 \right]$$

### 2.2 两大关键技术

#### Experience Replay（经验回放）

将 agent 的交互数据 $(s_t, a_t, r_t, s_{t+1})$ 存入回放缓冲区 $\mathcal{D}$，训练时随机采样 mini-batch。

**好处**：
1. **打破数据相关性**：连续样本高度相关，随机采样使训练更稳定
2. **提高数据效率**：每条数据可被多次使用
3. **平滑学习**：避免因最近的异常样本而产生剧烈更新

#### Target Network（目标网络）

维护两个网络：
- **在线网络** $Q(s,a;\theta)$：每一步都更新
- **目标网络** $Q(s,a;\theta^{-})$：每隔 $C$ 步从在线网络复制 $\theta^{-} \leftarrow \theta$

**为什么需要**：TD 目标 $r + \gamma \max_{a'} Q(s',a';\theta)$ 中，被更新的参数 $\theta$ 同时也出现在目标中。这就像追着自己的尾巴跑——目标不断移动，导致不稳定。固定目标网络使目标暂时"静止"。

### 2.3 DQN 算法伪代码

```
初始化: 在线网络 θ, 目标网络 θ⁻ ← θ, 回放缓冲区 𝒟
for episode = 1 to M:
    初始化状态 s₁
    for t = 1 to T:
        以 ε-贪心策略选择 a_t
        执行 a_t, 观察 r_t, s_{t+1}
        存储 (s_t, a_t, r_t, s_{t+1}) 到 𝒟
        从 𝒟 随机采样 mini-batch
        对每个样本:
            y = r + γ max_{a'} Q(s', a'; θ⁻)      (TD 目标)
            用梯度下降最小化 (y - Q(s, a; θ))²
        每 C 步: θ⁻ ← θ
```

---

## 3. DQN 改进系列

### 3.1 Double DQN — 解决过估计问题

Q-Learning 中的 $\max$ 算子会导致系统性地高估 $Q$ 值（因为 $Q$ 函数本身就有误差，取 $\max$ 放大误差）。

**解决方案**：用在线网络选择动作，用目标网络评估：

$$y = r + \gamma Q(s', \arg\max_{a'} Q(s', a'; \theta); \theta^{-})$$

- 在线网络 $\theta$：选择最优动作
- 目标网络 $\theta^{-}$：评估该动作

### 3.2 Dueling DQN — 分离状态值与优势

将 $Q(s,a)$ 分解为状态价值 $V(s)$ 和优势 $A(s,a)$：

$$Q(s, a; \theta, \alpha, \beta) = V(s; \theta, \beta) + \left( A(s, a; \theta, \alpha) - \frac{1}{|\mathcal{A}|} \sum_{a'} A(s, a'; \theta, \alpha) \right)$$

**直觉**：有些状态下，无论选择哪个动作都差不多（例如等红灯时）。分离 $V$ 和 $A$ 让网络能更高效地学习这类状态的共性。

### 3.3 Prioritized Experience Replay (PER)

并非所有经验都同等重要。**TD 误差大**的样本应被更频繁地回放。

采样概率：$P(i) \propto |\delta_i|^{\alpha}$（$\alpha=0$ 为均匀采样，$\alpha=1$ 为纯优先级）

### 3.4 Rainbow

将 DQN + Double DQN + Dueling + PER + Multi-step + Noisy Nets + Distributional RL + C51 全部结合起来，是目前单智能体 Atari 性能最强的值函数方法。

---

## 4. 连续动作空间的挑战

DQN 需要计算 $\max_{a'} Q(s', a')$，这对于**连续动作空间**需要解一个优化问题。这是 Policy Gradient 方法的天然优势。

> → [[RL-策略梯度|RL-策略梯度]]：解决连续动作空间

---

## 相关笔记

- [[马尔可夫决策过程 (Markov Decision Process, MDP)|MDP]] — 问题框架
- [[RL-动态规划与TD|RL-动态规划与TD]] — Q-Learning 的表格形式
- [[RL-策略梯度|RL-策略梯度]] — 策略搜索替代方案
- [[RL-PPO理论|PPO 理论]]
- [[RL-机器人控制|RL 与机器人控制]] — 连续动作空间的 RL
- [[../../数理基础/代数/代数基础|代数基础]] — 梯度下降
- [[../../数理基础/数学分析|数学分析]] — 均方误差、梯度
- [[../../数理基础/概率论|概率论]] — 经验分布、期望
- [[../机器学习与深度学习/0.绪论|深度学习绪论]]
- [[../机器学习与深度学习/1.机器学习概述|机器学习概述]]
