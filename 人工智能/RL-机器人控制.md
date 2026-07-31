# RL — 机器人控制

> 本章解决：如何将强化学习应用于真实（或仿真）机器人的运动控制？

---

## 前置知识

### 强化学习
- [[../马尔可夫决策过程 (Markov Decision Process, MDP)|MDP]] — 状态、动作、奖励的设计
- [[../RL-动态规划与TD|RL-动态规划与TD]] — TD 学习的基础
- [[../RL-DQN与值函数近似|RL-DQN与值函数近似]] — 值函数在连续控制中的局限
- [[../RL-策略梯度|RL-策略梯度]] — 连续动作空间的方法（Actor-Critic, PPO, SAC）
- [[../RL-PPO理论|PPO 理论]] — 机器人控制中最主流的 on-policy 算法

### 机器人学
- [[../../机器人学/DH参数法/DH参数法|DH 参数法]] — 机器人运动学的数学基础
- [[../刚体动力学算法/刚体动力学算法.tex|刚体动力学算法]] — 空间向量代数
- [[../刚体动力学算法/空间向量代数/1.空间速度 (Spatial Velocity)|空间速度]]
- [[../刚体动力学算法/空间向量代数/2.空间力 (Spatial Force )|空间力]]

### 仿真环境
- [[../刚体动力学算法/MuJoCo学习笔记.pdf|MuJoCo 学习笔记]] — 主流物理仿真引擎
- [[../刚体动力学算法/MuJoCo学习笔记.pdf|MuJoCo 学习笔记]]
- [[../刚体动力学算法/MuJoCo学习笔记.pdf|MuJoCo 代码设计]]

### 数学工具
- [[../../数理基础/ODE常微分方程|常微分方程]] — 动力学是 ODE
- [[../../数理基础/微分方程与动力系统|动力系统]] — 稳定性分析
- [[../../数理基础/随机过程/随机微分方程|随机微分方程]] — 噪声环境下的控制
- [[../../数理基础/代数/代数基础|代数基础]] — 雅可比矩阵、坐标变换
- [[../../数理基础/凸优化|凸优化]] — 轨迹优化与 MPC 的数学背景
- [[../../力学/动力学/质点动力学|质点动力学]] — 牛顿第二定律 $\mathbf{F} = m\mathbf{a}$

---

## 1. 机器人控制问题的 RL 建模

### 1.1 为什么用 RL

传统控制方法（PID、LQR、MPC）需要精确的系统模型或线性化假设。RL 的优势：
- **无需精确模型**：直接从交互中学习
- **处理非线性**：神经网络天然处理高维非线性
- **端到端学习**：从传感器原始数据到执行器指令

### 1.2 MDP 的机器人映射

| MDP 组件 | 机器人控制对应 |
|----------|---------------|
| **状态 $s$** | 关节角度、角速度、末端位姿、IMU 读数、视觉特征 |
| **动作 $a$** | 关节力矩/力 $\tau_i$、目标关节角度、目标末端速度 |
| **奖励 $r$** | 目标距离、能耗惩罚、平滑性惩罚、安全约束 |
| **转移 $\mathcal{P}$** | 物理规律（刚体动力学方程） |

### 1.3 典型的机器人状态空间

对于 $n$ 自由度机器人：
$$s_t = [q_1, \dots, q_n, \dot{q}_1, \dots, \dot{q}_n, p_x, p_y, p_z, \phi, \theta, \psi, \dots]$$

其中 $q_i$ 是关节位置，$\dot{q}_i$ 是关节速度，后续是末端执行器位姿。

> 空间速度记法 → [[../刚体动力学算法/空间向量代数/1.空间速度 (Spatial Velocity)|空间速度]]：$\hat{v} = [\omega_x, \omega_y, \omega_z, v_{Ox}, v_{Oy}, v_{Oz}]^{\mathsf{T}}$

---

## 2. 常用仿真环境

### 2.1 MuJoCo (Multi-Joint dynamics with Contact)

Google DeepMind 开源的物理引擎，特点：
- 快速且精确的接触动力学
- 原生支持肌腱、执行器、传感器
- OpenAI Gym / Gymnasium 标准接口

**常用环境**：Ant、HalfCheetah、Humanoid、Walker2d、Hopper

```python
import gymnasium as gym
env = gym.make("HalfCheetah-v4")
obs, info = env.reset()
# obs: 17维 (关节角度+速度)
# action: 6维 (关节力矩, 连续值 [-1, 1])
```

### 2.2 其他环境

| 环境 | 特点 |
|------|------|
| **PyBullet** | 免费、Python 原生 |
| **Isaac Gym** | GPU 并行仿真（数千环境同时训练） |
| **Isaac Sim** | NVIDIA Omniverse 平台、高保真渲染 |
| **Gazebo** | ROS 集成、传感器仿真 |

---

## 3. 奖励函数设计 (Reward Shaping)

机器人控制中，奖励函数的设计是成败关键。

### 3.1 稀疏奖励 vs 稠密奖励

**稀疏奖励**（仅目标达成时给奖励）：
- 优点：不引入人为偏差
- 缺点：学习极慢（探索不到奖励）

**稠密奖励**（每步都给信号）：
- 优点：学习快
- 缺点：可能引导出意料之外的行为（reward hacking）

### 3.2 典型的奖励成分

$$r_t = \underbrace{w_1 \cdot r_{\text{goal}}}_{\text{目标达成}} + \underbrace{w_2 \cdot r_{\text{progress}}}_{\text{进度项}} - \underbrace{w_3 \cdot r_{\text{energy}}}_{\text{能耗惩罚}} - \underbrace{w_4 \cdot r_{\text{smooth}}}_{\text{平滑惩罚}} - \underbrace{w_5 \cdot r_{\text{safety}}}_{\text{安全约束}}$$

具体：
- **$r_{\text{goal}}$**：$\exp(-\|p_{\text{ee}} - p_{\text{target}}\|)$
- **$r_{\text{progress}}$**：$\Delta d$（每步靠近目标的距离变化）
- **$r_{\text{energy}}$**：$\sum \tau_i^2$（关节力矩平方和）
- **$r_{\text{smooth}}$**：$\sum (\tau_i^{(t)} - \tau_i^{(t-1)})^2$
- **$r_{\text{safety}}$**：关节限位、自碰撞惩罚

### 3.3 势函数奖励 (Potential-Based Reward Shaping)

通过势函数 $\Phi(s)$ 构造形式奖励，保证最优策略不变：

$$F(s, a, s') = \gamma \Phi(s') - \Phi(s)$$

例如：$\Phi(s) = -\|p_{\text{ee}} - p_{\text{target}}\|$（负末端距离作为势）。

---

## 4. 主流算法选型

### 4.1 连续控制的算法谱系

| 算法 | 类型 | 适用场景 |
|------|------|---------|
| **PPO** | On-policy, Stochastic | 通用、稳定、主流首选 |
| **SAC** | Off-policy, Stochastic | 样本效率高、探索强 |
| **TD3** | Off-policy, Deterministic | 确定性策略、简单任务 |
| **TRPO** | On-policy, Stochastic | PPO 的前身，更保守 |
| **DDPG** | Off-policy, Deterministic | 较老，被 TD3/SAC 取代 |

### 4.2 推荐方案

- **入门**：PPO + MuJoCo HalfCheetah
- **样本效率优先**：SAC（off-policy，可复用历史数据）
- **仿真资源充足**：PPO + Isaac Gym（GPU 并行数千环境）
- **真实机器人**：Soft Actor-Critic (SAC) + Domain Randomization

---

## 5. 从仿真到真实 (Sim-to-Real)

仿真中训练的策略直接部署到真实机器人通常失败——这就是 **Sim-to-Real Gap**。

### 5.1 差距来源

| 因素 | 仿真 | 真实 |
|------|------|------|
| 物理参数 | 精确已知 | 质量、摩擦、阻尼不确定 |
| 传感器 | 无噪声、无延迟 | 有噪声、有延迟 |
| 执行器 | 理想力矩 | 饱和、死区、带宽限制 |
| 接触 | 简化碰撞模型 | 复杂形变、静摩擦 |
| 视觉 | 完美渲染 | 光照、遮挡、纹理变化 |

### 5.2 域随机化 (Domain Randomization)

在训练时**随机扰动**仿真参数，迫使策略对参数变化鲁棒：

```python
# 每个 episode 随机采样物理参数
mass_noise = np.random.uniform(0.8, 1.2)      # 质量 ±20%
friction_noise = np.random.uniform(0.5, 1.5)  # 摩擦 ±50%
joint_damping = np.random.uniform(0.0, 0.1)   # 阻尼 [0, 0.1]
gravity_z = np.random.uniform(-9.5, -10.5)    # 重力 ±5%

env.set_params(mass_noise, friction_noise, ...)
```

**关键论文**：OpenAI 用域随机化训练了一只机械手拧魔方（2019）。

### 5.3 系统辨识 (System Identification)

先在真实机器人上采集数据，拟合出更精确的仿真参数，然后在校准后的仿真中训练。

### 5.4 Sim-to-Real 增强技术

| 技术 | 说明 |
|------|------|
| **域自适应** | 用 GAN 或特征对齐来桥接仿真与真实观测 |
| **动作空间正则化** | 限制动作变化率，避免在真实机器人上剧烈运动 |
| **渐近微调** | 先在仿真训练，再在真实机器人上 fine-tune |

---

## 6. 实例：用 PPO 训练 MuJoCo 行走机器人

### 6.1 环境选择

```python
import gymnasium as gym
env = gym.make("HalfCheetah-v4")
# 状态: 17维 (位置+速度)
# 动作: 6维 (6个关节的力矩, [-1,1] 归一化)
# 奖励: 前进速度 - 控制代价
```

### 6.2 关键超参（典型值）

| 超参数 | 值 | 说明 |
|--------|-----|------|
| 学习率 | $3 \times 10^{-4}$ | Actor & Critic |
| $\gamma$ | 0.99 | 折扣因子 |
| $\lambda$ (GAE) | 0.95 | 优势平滑 |
| $\epsilon$ (Clip) | 0.2 | PPO clip 范围 |
| 更新轮数 | 10 | 同一批数据迭代次数 |
| Batch size | 64 | mini-batch 大小 |
| 总步数 | $10^6$ | HalfCheetah 通常 $10^6$ 步收敛 |

### 6.3 训练曲线解读

- **Average Return 上升**：策略在变好
- **Value Loss 下降**：Critic 越估越准
- **Entropy 缓慢下降**：策略从探索到坚定

---

## 7. 进阶话题

### 7.1 模型基 RL (Model-Based RL)

学习环境的动力学模型 $f(s_t, a_t) \approx s_{t+1}$，然后用它做规划（MPC/规划）。

**优势**：样本效率极高（比 model-free 快 10-100 倍）
**挑战**：模型误差会累积

**代表算法**：PETS、MBPO、Dreamer

### 7.2 分层 RL (Hierarchical RL)

高层策略设定子目标，低层策略执行具体动作。
适用于长时序任务（如"走到厨房→打开冰箱→取出可乐"）。

### 7.3 多智能体 RL (MARL)

多个机器人协作/竞争。在机器人足球、仓储调度中应用广泛。

### 7.4 安全 RL (Safe RL)

在 RL 中嵌入硬约束（如关节限位、避障），保证探索和部署过程中的安全性。

> 稳定性分析 → [[../../数理基础/微分方程与动力系统|动力系统]]
> 约束优化 → [[../../数理基础/凸优化|凸优化]]

---

## 8. 学习路径建议

```
第1步: 理解 MDP 框架 → [[../马尔可夫决策过程 (Markov Decision Process, MDP)|MDP]]
第2步: 掌握 TD/Q-Learning → [[../RL-动态规划与TD|RL-动态规划与TD]]
第3步: 理解策略梯度 → [[../RL-策略梯度|RL-策略梯度]]
第4步: 精通 PPO → [[../RL-PPO理论|PPO 理论]]
第5步: 在 MuJoCo 仿真中实践 → [[../刚体动力学算法/MuJoCo学习笔记.pdf|MuJoCo]]
第6步: 了解 Sim-to-Real → 域随机化、系统辨识
第7步: 真实机器人部署
```

---

## 相关笔记

- [[../马尔可夫决策过程 (Markov Decision Process, MDP)|MDP]]
- [[../RL-动态规划与TD|RL-动态规划与TD]]
- [[../RL-策略梯度|RL-策略梯度]] — Actor-Critic, GAE
- [[../RL-PPO理论|PPO 理论]] — 机器人控制中最常使用的算法
- [[../../机器人学/DH参数法/DH参数法|DH 参数法]] — 机器人运动学建模
- [[../刚体动力学算法/刚体动力学算法.tex|刚体动力学算法]] — 正逆动力学
- [[../刚体动力学算法/空间向量代数/0.数学知识预备|空间向量代数]]
- [[../刚体动力学算法/MuJoCo学习笔记.pdf|MuJoCo]]
- [[../刚体动力学算法/MuJoCo学习笔记.pdf|MuJoCo 代码设计]]
- [[../../数理基础/ODE常微分方程|常微分方程]] — 动力学是 ODE
- [[../../数理基础/微分方程与动力系统|动力系统]] — 稳定性
- [[../../数理基础/随机过程/随机微分方程|随机微分方程]] — 随机控制
- [[../../数理基础/凸优化|凸优化]] — 轨迹优化
