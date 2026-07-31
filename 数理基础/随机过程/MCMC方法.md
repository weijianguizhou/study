# MCMC 方法 (Markov Chain Monte Carlo)

> 前置知识：[[马尔可夫链|马尔可夫链]]中的平稳分布、细致平衡、遍历定理；[[蒙特卡洛方法|蒙特卡洛方法]]中的重要性采样、ESS。

## 一、MCMC 的动机与核心思想

### 1.1 问题设定——从复杂分布采样

贝叶斯推断的核心困难：后验分布

$$\pi(\boldsymbol{\theta} \mid \mathbf{y}) = \frac{p(\mathbf{y} \mid \boldsymbol{\theta}) p(\boldsymbol{\theta})}{p(\mathbf{y})} \propto p(\mathbf{y} \mid \boldsymbol{\theta}) p(\boldsymbol{\theta})$$

仅以未归一化形式 $\tilde{\pi}(\boldsymbol{\theta}) = p(\mathbf{y} \mid \boldsymbol{\theta}) p(\boldsymbol{\theta})$ 已知。归一化常数 $p(\mathbf{y}) = \int p(\mathbf{y} \mid \boldsymbol{\theta}) p(\boldsymbol{\theta}) d\boldsymbol{\theta}$ 是高维积分，通常无法解析计算。

**传统方法的失效**：
- 直接采样：$\pi$ 不是标准分布，没有现成的采样器
- 拒绝采样：高维空间中使 $f(x) \leq M g(x)$ 成立的 $M$ 通常极大，接受率趋近于零
- 重要性采样：高维中重要性权重的方差指数级爆炸（维度灾难）

### 1.2 MCMC 的核心思想

MCMC 不直接采样 $\pi$，而是**构造一个以 $\pi$ 为平稳分布的马尔可夫链** $\{X_t\}_{t=0}^{\infty}$。由马尔可夫链的遍历理论，当 $t \to \infty$：

$$X_t \sim \pi(\mathbf{x}) \quad \text{(渐近分布)}$$

并且时间平均收敛于空间平均：

$$\frac{1}{N} \sum_{t=1}^{N} f(X_t) \xrightarrow{a.s.} \int f(\mathbf{x}) \pi(\mathbf{x}) d\mathbf{x} = \mathbb{E}_\pi[f(X)]$$

**MCMC 的独特优势**：构造过程仅需知道未归一化密度 $\tilde{\pi}(\mathbf{x})$——归一化常数在转移核的构造中自动抵消。

---

## 二、细致平衡条件——MCMC 的构造原理

### 2.1 细致平衡方程

**定义 2.1 (细致平衡)**：转移核 $K(\mathbf{x}, \mathbf{y})$（从 $\mathbf{x}$ 到 $\mathbf{y}$ 的转移密度）满足关于 $\pi$ 的细致平衡条件，若对所有 $\mathbf{x}, \mathbf{y}$：

$$\boxed{\pi(\mathbf{x}) K(\mathbf{x}, \mathbf{y}) = \pi(\mathbf{y}) K(\mathbf{y}, \mathbf{x})}$$

**定理 2.1**：若 $K$ 满足关于 $\pi$ 的细致平衡，则 $\pi$ 是 $K$ 的平稳分布。

**证明**：

$$\int \pi(\mathbf{x}) K(\mathbf{x}, \mathbf{y}) d\mathbf{x} = \int \pi(\mathbf{y}) K(\mathbf{y}, \mathbf{x}) d\mathbf{x} = \pi(\mathbf{y}) \int K(\mathbf{y}, \mathbf{x}) d\mathbf{x} = \pi(\mathbf{y})$$

**物理直觉**：细致平衡保证了在稳态下，从 $\mathbf{x}$ 到 $\mathbf{y}$ 的概率流与从 $\mathbf{y}$ 到 $\mathbf{x}$ 的相等——净流为零，分布不变。这是比全局平衡 $\pi K = \pi$ 更强的条件，但构造起来方便得多。

### 2.2 从细致平衡到 MCMC 算法

任何 MCMC 算法的核心是将转移核 $K$ 构造为满足细致平衡的形式：

$$K(\mathbf{x}, \mathbf{y}) = \underbrace{q(\mathbf{y} \mid \mathbf{x})}_{\text{提议分布}} \cdot \underbrace{\alpha(\mathbf{x}, \mathbf{y})}_{\text{接受概率}} + \delta_{\mathbf{x}}(\mathbf{y}) \cdot r(\mathbf{x})$$

其中 $r(\mathbf{x}) = 1 - \int q(\mathbf{y} \mid \mathbf{x}) \alpha(\mathbf{x}, \mathbf{y}) d\mathbf{y}$ 为拒绝概率（留在原地）。

---

## 三、Metropolis-Hastings 算法

### 3.1 算法描述

**Metropolis-Hastings (MH) 算法** (Metropolis et al., 1953; Hastings, 1970) 是最通用的 MCMC 算法。

**算法 3.1 (Metropolis-Hastings)**：

1. 初始化：选择 $X_0$（任意）
2. 对 $t = 1, 2, \ldots, T$：
   - (a) **提议**：从提议分布 $q(\mathbf{x}^* \mid X_{t-1})$ 生成候选 $\mathbf{x}^*$
   - (b) **计算接受概率**：
     $$\alpha(\mathbf{x}^* \mid X_{t-1}) = \min\left(1, \frac{\tilde{\pi}(\mathbf{x}^*) \, q(X_{t-1} \mid \mathbf{x}^*)}{\tilde{\pi}(X_{t-1}) \, q(\mathbf{x}^* \mid X_{t-1})}\right)$$
   - (c) **接受/拒绝**：以概率 $\alpha$ 接受 $\mathbf{x}^*$（$X_t = \mathbf{x}^*$），否则拒绝（$X_t = X_{t-1}$）

### 3.2 接受概率的推导

从细致平衡出发。希望构造接受概率 $\alpha(\mathbf{x}, \mathbf{y})$ 使得细致平衡 $\pi(\mathbf{x}) q(\mathbf{y} \mid \mathbf{x}) \alpha(\mathbf{x}, \mathbf{y}) = \pi(\mathbf{y}) q(\mathbf{x} \mid \mathbf{y}) \alpha(\mathbf{y}, \mathbf{x})$ 成立。

定义比率 $R(\mathbf{x}, \mathbf{y}) = \frac{\pi(\mathbf{y}) q(\mathbf{x} \mid \mathbf{y})}{\pi(\mathbf{x}) q(\mathbf{y} \mid \mathbf{x})}$：
- 若 $R \geq 1$（从 $\mathbf{x}$ 到 $\mathbf{y}$ 是有利的），应设置 $\alpha(\mathbf{x}, \mathbf{y}) = 1$，$\alpha(\mathbf{y}, \mathbf{x}) = 1/R$
- 若 $R < 1$（从 $\mathbf{x}$ 到 $\mathbf{y}$ 是不利的），应设置 $\alpha(\mathbf{x}, \mathbf{y}) = R$，$\alpha(\mathbf{y}, \mathbf{x}) = 1$

综合为：

$$\boxed{\alpha(\mathbf{x}, \mathbf{y}) = \min\left(1, \frac{\pi(\mathbf{y}) q(\mathbf{x} \mid \mathbf{y})}{\pi(\mathbf{x}) q(\mathbf{y} \mid \mathbf{x})}\right)}$$

**关键性质**：归一化常数在分子分母约去，因此仅需未归一化密度 $\tilde{\pi}$。

### 3.3 对称提议——Metropolis 算法

当提议分布对称 $q(\mathbf{y} \mid \mathbf{x}) = q(\mathbf{x} \mid \mathbf{y})$（如 $N(\mathbf{x}, \sigma^2 I)$ 随机游走）时：

$$\boxed{\alpha(\mathbf{x}, \mathbf{y}) = \min\left(1, \frac{\tilde{\pi}(\mathbf{y})}{\tilde{\pi}(\mathbf{x})}\right)}$$

即仅比较目标密度在候选点和当前点的比值——候选点密度更高就接受，更低则以等于密度比值的概率接受。

### 3.4 提议分布的选择与最优接受率

**随机游走 Metropolis (RWM)**：$q(\mathbf{y} \mid \mathbf{x}) = N(\mathbf{y} \mid \mathbf{x}, \sigma^2 I)$

- $\sigma$ 太小：接受率过高（接近 1），但链移动太慢——每步改变太小
- $\sigma$ 太大：接受率过低，链频繁拒绝原地踏步
- **最优接受率**：Roberts, Gelman & Gilks (1997) 证明，对于高维（$d \to \infty$）独立正态目标，RWM 的最优接受率约为 **23.4%**

对于低维（$d=1,2$）目标，最优接受率约为 44%，随维度增加递减至 23.4%。

### 3.5 独立 Metropolis-Hastings

提议分布与当前状态无关：$q(\mathbf{y} \mid \mathbf{x}) = g(\mathbf{y})$

$$\alpha(\mathbf{x}, \mathbf{y}) = \min\left(1, \frac{\tilde{\pi}(\mathbf{y}) / g(\mathbf{y})}{\tilde{\pi}(\mathbf{x}) / g(\mathbf{x})}\right)$$

**关键要求**：$g$ 的尾部必须比 $\pi$ 厚（即 $g(\mathbf{x}) / \pi(\mathbf{x})$ 有正下界），否则链可能在尾部区域卡住。

---

## 四、Gibbs 采样

### 4.1 算法描述

**Gibbs 采样** (Geman & Geman, 1984) 是 MH 的重要特例——提议分布为全条件分布 (full conditional distribution)，接受率为 100%。

**算法 4.1 (系统扫描 Gibbs)**：设目标分布为 $\pi(x_1, x_2, \ldots, x_d)$。

1. 初始化 $\mathbf{x}^{(0)} = (x_1^{(0)}, \ldots, x_d^{(0)})$
2. 对 $t = 1, 2, \ldots$：
   - 从 $\pi(x_1 \mid x_2^{(t-1)}, x_3^{(t-1)}, \ldots, x_d^{(t-1)})$ 采样 $x_1^{(t)}$
   - 从 $\pi(x_2 \mid x_1^{(t)}, x_3^{(t-1)}, \ldots, x_d^{(t-1)})$ 采样 $x_2^{(t)}$
   - ...
   - 从 $\pi(x_d \mid x_1^{(t)}, x_2^{(t)}, \ldots, x_{d-1}^{(t)})$ 采样 $x_d^{(t)}$

**每次从全条件分布采样，且总是被接受**。

### 4.2 Gibbs 是 100% 接受率的 MH

**证明**：以更新 $x_1$ 为例（固定 $\mathbf{x}_{-1}$）。MH 中的提议分布为

$$q(\mathbf{x}^* \mid \mathbf{x}) = \pi(x_1^* \mid \mathbf{x}_{-1})$$

比例 $R = \frac{\pi(\mathbf{x}^*) q(\mathbf{x} \mid \mathbf{x}^*)}{\pi(\mathbf{x}) q(\mathbf{x}^* \mid \mathbf{x})} = \frac{\pi(x_1^*, \mathbf{x}_{-1}) \cdot \pi(x_1 \mid \mathbf{x}_{-1})}{\pi(x_1, \mathbf{x}_{-1}) \cdot \pi(x_1^* \mid \mathbf{x}_{-1})}$

将 $\pi(x_1^*, \mathbf{x}_{-1}) = \pi(\mathbf{x}_{-1}) \pi(x_1^* \mid \mathbf{x}_{-1})$ 和 $\pi(x_1, \mathbf{x}_{-1}) = \pi(\mathbf{x}_{-1}) \pi(x_1 \mid \mathbf{x}_{-1})$ 代入，得 $R = 1$。因此 $\alpha = 1$。

### 4.3 全条件分布的性质

对于联合分布 $\pi(\mathbf{x})$，全条件分布仅依赖于与目标变量直接相关的因子（由 Hammersley-Clifford 定理）：

$$\pi(x_j \mid \mathbf{x}_{-j}) \propto \text{所有包含 } x_j \text{ 的因子项}$$

在贝叶斯层次模型中，全条件分布通常可归约为标准分布（正态、Gamma、Dirichlet 等），便于直接采样。

**正态-正态层次模型示例**：

$$y_i \mid \mu, \tau \sim N(\mu, 1/\tau), \quad \mu \sim N(0, 1), \quad \tau \sim \text{Gamma}(a, b)$$

全条件分布：

$$\mu \mid \mathbf{y}, \tau \sim N\left(\frac{\tau \sum y_i}{1 + n\tau}, \frac{1}{1 + n\tau}\right)$$

$$\tau \mid \mathbf{y}, \mu \sim \text{Gamma}\left(a + \frac{n}{2}, b + \frac{1}{2}\sum(y_i - \mu)^2\right)$$

### 4.4 Gibbs 采样的局限性——混合问题

当变量高度相关时，Gibbs 采样像在狭窄的峡谷边缘爬行：
- 每步仅在坐标轴方向移动
- 高相关性导致每次更新改变极小
- 有效样本量 (ESS) 极低

**解决策略**：
- **块 Gibbs (Block Gibbs)**：同时更新一组相关变量
- **参数扩展 (Parameter Expansion)**：引入辅助变量打破相关性
- **Hamiltonian Monte Carlo**：利用梯度信息实现高效移动

---

## 五、MCMC 的收敛诊断

### 5.1 诊断的必要性

MCMC 本身不保证何时收敛——它仅保证在 $t \to \infty$ 时渐近收敛。诊断工具帮助我们判断：
1. 预热期 (burn-in) 是否结束？
2. 链是否已探索目标分布的主要区域？
3. 有效样本量是否足够？

### 5.2 Gelman-Rubin 诊断 ($\hat{R}$)

从 $m$ 个不同初始点运行 $m$ 条链，每条链长度为 $n$。

**定义**：
- 链内方差 (within-chain variance)：
  $$W = \frac{1}{m(n-1)} \sum_{j=1}^{m} \sum_{i=1}^{n} (X_{ij} - \bar{X}_j)^2$$
- 链间方差 (between-chain variance)：
  $$B = \frac{n}{m-1} \sum_{j=1}^{m} (\bar{X}_j - \bar{X})^2$$
- 边际后验方差估计：
  $$\hat{V} = \frac{n-1}{n} W + \frac{1}{n} B$$

**Gelman-Rubin 统计量**：

$$\boxed{\hat{R} = \sqrt{\frac{\hat{V}}{W}}}$$

**判断标准**：
- $\hat{R} < 1.1$：基本收敛（保守）
- $\hat{R} < 1.05$：良好收敛
- $\hat{R} \gg 1$：链尚未收敛

**原理**：当链收敛时，$W$（链内方差）和 $\hat{V}$（总体方差）应趋于一致，$\hat{R} \to 1$。

### 5.3 有效样本量 (ESS)

由于 MCMC 样本存在自相关，$N$ 个 MCMC 样本的信息量远小于 $N$ 个独立样本。

**定义**：

$$\boxed{\text{ESS} = \frac{N}{1 + 2\sum_{k=1}^{\infty} \rho_k}}$$

其中 $\rho_k = \text{Corr}(X_t, X_{t+k})$ 为滞后 $k$ 的自相关系数。实践中截断至自相关衰减到噪声水平。

**解释**：
- ESS $\approx N$：链混合良好，几乎独立采样
- ESS $\ll N$：链严重自相关，需要更长运行或调整参数
- 一般期望 ESS $\geq 400$（对每个参数）以保证估计精度

### 5.4 迹图 (Trace Plot)

绘制 $X_t$ 随迭代次数的变化：
- **好的混合**：迹图如"毛毛虫"，快速波动，无长期趋势
- **差的混合**：迹图缓慢漂移，有长周期波动，或有明显趋势

### 5.5 自相关函数 (ACF)

$$\rho_k = \frac{\text{Cov}(X_t, X_{t+k})}{\text{Var}(X_t)}$$

理想情况下 $\rho_k$ 应快速衰减到 0（在滞后约 10-50 内）。衰减慢表示混合不佳，需提高提议分布的步长或换用更高效的算法（如 HMC）。

### 5.6 Geweke 诊断

比较链的前 10% 和后 50% 的均值差异：

$$G = \frac{\bar{X}_{\text{early}} - \bar{X}_{\text{late}}}{\sqrt{\widehat{\text{SE}}_{\text{early}}^2 + \widehat{\text{SE}}_{\text{late}}^2}} \xrightarrow{d} N(0, 1)$$

$|G| > 2$ 表示链尚未收敛（前后段均值有显著差异）。

---

## 六、Hamiltonian Monte Carlo (HMC)

### 6.1 动机——为什么需要 HMC

随机游走 Metropolis 在高维空间效率极低：提议分布的各向同性导致每一步的期望平方位移为 $O(\sigma^2)$，而接受率的维护要求 $\sigma$ 随维度增加而减小。在高维中，链探索目标分布所需步数为 $O(d)$（或更差）。

HMC 利用**目标分布的梯度信息**——哈密顿动力学——实现大跨步提议同时保持高接受率。

### 6.2 哈密顿动力学

引入辅助动量变量 $\mathbf{p} \in \mathbb{R}^d$（通常取 $N(0, M)$），定义哈密顿量：

$$\boxed{H(\mathbf{q}, \mathbf{p}) = U(\mathbf{q}) + K(\mathbf{p})}$$

其中：
- $U(\mathbf{q}) = -\log \tilde{\pi}(\mathbf{q})$：势能（负对数目标密度）
- $K(\mathbf{p}) = \frac{1}{2} \mathbf{p}^T M^{-1} \mathbf{p}$：动能

联合分布为 $\pi(\mathbf{q}, \mathbf{p}) \propto \exp(-H(\mathbf{q}, \mathbf{p})) = \tilde{\pi}(\mathbf{q}) \cdot N(\mathbf{p} \mid 0, M)$。

**哈密顿方程**：

$$\frac{d\mathbf{q}}{dt} = \frac{\partial H}{\partial \mathbf{p}} = M^{-1} \mathbf{p}, \quad \frac{d\mathbf{p}}{dt} = -\frac{\partial H}{\partial \mathbf{q}} = \nabla \log \tilde{\pi}(\mathbf{q})$$

哈密顿动力学保持 $H$ 不变（$\frac{dH}{dt} = 0$），因此保持联合分布不变。

### 6.3 Leapfrog 积分器

蛙跳积分器 (Leapfrog Integrator) 以二阶精度近似哈密顿方程，同时保持时间可逆性和体积保持性（辛性质）：

1. 半步动量更新：$\mathbf{p}(t + \varepsilon/2) = \mathbf{p}(t) + \frac{\varepsilon}{2} \nabla \log \tilde{\pi}(\mathbf{q}(t))$
2. 全步位置更新：$\mathbf{q}(t + \varepsilon) = \mathbf{q}(t) + \varepsilon M^{-1} \mathbf{p}(t + \varepsilon/2)$
3. 半步动量更新：$\mathbf{p}(t + \varepsilon) = \mathbf{p}(t + \varepsilon/2) + \frac{\varepsilon}{2} \nabla \log \tilde{\pi}(\mathbf{q}(t + \varepsilon))$

重复 $L$ 步，总积分时间 $T = L \varepsilon$。

**最终 MH 接受/拒绝**：因数值误差 $H$ 不精确守恒，以概率 $\min(1, \exp(H_{\text{old}} - H_{\text{new}}))$ 接受提议。

### 6.4 NUTS (No-U-Turn Sampler)

HMC 需要手动调节 $L$（步数）和 $\varepsilon$（步长）。NUTS (Hoffman & Gelman, 2014) 自动确定 $L$——通过递归构建二叉树直到轨迹出现 U-turn（即哈密顿轨迹开始折回靠近起点），避免手动调参。NUTS 是 Stan 中的默认采样器。

### 6.5 HMC 的关键优势

- **高接受率 + 大位移**：利用梯度信息，在远距离提议的同时保持 $\sim 65\%$ - $80\%$ 的接受率
- **避免随机游走行为**：在 $d$ 维目标中，RWM 需 $O(d)$ 步达到独立样本，HMC 仅需 $O(d^{1/4})$ 步
- **自然的参数调节**：NUTS 自动调节步数，仅需调节步长 $\varepsilon$（Stan 在预热期自动调节）

---

## 七、高级 MCMC 方法

### 7.1 Slice Sampling (切片采样)

避免调节步长参数的自适应方法。

**算法**：对一维目标 $\pi(x)$
1. 从 $U(0, \pi(x_t))$ 采样辅助变量 $u$（确定一个水平切片）
2. 找到区间 $[L, R]$ 使 $\pi(x) \geq u$ 对所有 $x \in [L, R]$ 成立
3. 从 $[L, R]$ 中均匀采样 $x_{t+1}$

**优势**：完全自适应——无需任何步长参数
**局限**：在高维中求切片区间困难，通常仅用于嵌入 Gibbs 采样

### 7.2 Parallel Tempering (并行回火)

解决多峰分布的 MCMC 困境。

**思想**：运行 $K$ 条不同温度的链：

$$\pi_\beta(\mathbf{x}) \propto \pi(\mathbf{x})^{\beta}, \quad \beta \in [0, 1]$$

- $\beta = 1$（冷链）：目标分布（缓慢探索单个峰）
- $\beta \approx 0$（热链）：近似均匀分布（快速在各峰间跳跃）

**链间交换**：相邻温度的链以概率 $\min\left(1, \frac{\pi_{\beta_i}(\mathbf{x}_j) \pi_{\beta_j}(\mathbf{x}_i)}{\pi_{\beta_i}(\mathbf{x}_i) \pi_{\beta_j}(\mathbf{x}_j)}\right)$ 交换状态。

热链上的自由移动通过交换"传递"到冷链，使冷链能在各峰间跳跃。

### 7.3 Reversible Jump MCMC (RJ-MCMC)

当参数空间维度可变时（如选择回归模型的自变量个数），传统 MCMC 无法跨越不同维度的子空间。RJ-MCMC (Green, 1995) 通过引入辅助变量和雅可比行列式，实现在不同维度子空间之间的转移。

**接受概率**：

$$\alpha = \min\left(1, \frac{\pi(m^*, \mathbf{x}^*) q(m \mid m^*)}{\pi(m, \mathbf{x}) q(m^* \mid m) q(\mathbf{u})} \left|\frac{\partial (\mathbf{x}^*, \mathbf{u}^*)}{\partial (\mathbf{x}, \mathbf{u})}\right|\right)$$

其中 $m$ 为模型维度，$\mathbf{u}$ 为辅助变量。

### 7.4 变分推断与 MCMC 的互补

| 特性 | MCMC | 变分推断 (VI) |
|------|------|---------------|
| 精确性 | 渐近精确 | 有偏（变分近似误差） |
| 速度 | 慢（需要收敛时间） | 快（优化问题） |
| 诊断 | 困难（需诊断收敛） | 简单（监控 ELBO） |
| 大数据 | 不适应 | 支持随机梯度 |

现代贝叶斯实践中两者互补：快速探索用 VI，精确推断用 MCMC。

---

## 八、MCMC 的实践最佳实践

### 8.1 Burn-in（预热期）

丢弃初始样本——链尚未收敛阶段。Burn-in 比例通常为 $10\%$-$50\%$，具体由迹图和 $\hat{R}$ 确定。

### 8.2 Thinning（稀疏化）

每隔 $k$ 步取一个样本以降低存储成本和自相关性。注意：thinning **不增加**有效信息（丢弃中间样本虽然降低自相关但也减少了样本量），仅在存储受限时使用。

### 8.3 多链策略

从分散的初始点运行至少 $3$-$4$ 条链：
- 链间的一致性是收敛的有力证据（Gelman-Rubin $\hat{R}$ 的基础）
- 避免单条链困在局部模式中

### 8.4 参数调节指南

| 方法 | 关键参数 | 调节目标 |
|------|----------|----------|
| Random Walk MH | 提议方差 $\sigma^2$ | 接受率 $\approx 23\%$-$44\%$ |
| HMC | 步长 $\varepsilon$ | 接受率 $\approx 65\%$-$80\%$ |
| HMC | 步数 $L$ | NUTS 自动确定 |
| Gibbs | 全条件分布 | 无需调节 |
| Slice Sampling | 无 | 完全自动 |

### 8.5 贝叶斯线性回归 Gibbs 采样示例

设 $p(\beta \mid \sigma^2) = N(0, \sigma^2 \tau^2 I_p)$ 和 $p(\sigma^2) = \text{Inv-Gamma}(a, b)$，则：

$$\beta \mid \mathbf{y}, \sigma^2 \sim N\left(\left(X^T X + \frac{1}{\tau^2} I\right)^{-1} X^T \mathbf{y}, \; \sigma^2 \left(X^T X + \frac{1}{\tau^2} I\right)^{-1}\right)$$

$$\sigma^2 \mid \mathbf{y}, \beta \sim \text{Inv-Gamma}\left(a + \frac{n+p}{2}, \; b + \frac{1}{2}\|\mathbf{y} - X\beta\|^2 + \frac{1}{2\tau^2}\|\beta\|^2\right)$$

交替采样即构成 Gibbs 采样器。

---

## 九、MCMC 的数学理论

### 9.1 马尔可夫链的收敛速率

设 $P$ 为转移核，平稳分布为 $\pi$。全变差距离：

$$\|P^n(x, \cdot) - \pi\|_{\text{TV}} = \frac{1}{2} \int |P^n(x, y) - \pi(y)| dy$$

**几何遍历性**：存在 $\rho \in (0, 1)$ 和 $C(x)$ 使 $\|P^n(x, \cdot) - \pi\|_{\text{TV}} \leq C(x) \rho^n$。大多数合理设计的 MCMC 算法满足几何遍历性。

收敛速率由 $P$ 的谱间隙 (spectral gap) 决定：

$$\text{Gap}(P) = 1 - \lambda_2$$

其中 $\lambda_2$ 为 $P$ 的第二大特征值（在函数空间的谱意义下）。Gap 越大，收敛越快。

### 9.2 MCMC 中心极限定理

**定理 9.1 (MCMC CLT)**：对满足几何遍历性的马尔可夫链 $\{X_t\}$ 和有界函数 $f$，

$$\sqrt{N}\left(\frac{1}{N}\sum_{t=1}^{N} f(X_t) - \mathbb{E}_\pi[f]\right) \xrightarrow{d} N(0, \sigma_f^2)$$

其中 $\sigma_f^2 = \text{Var}_\pi(f(X)) \cdot \left(1 + 2\sum_{k=1}^{\infty} \rho_k\right)$。

**注意**：渐近方差 $\sigma_f^2$ 比独立采样大一个因子 $\tau_f = 1 + 2\sum_k \rho_k$，即积分自相关时间 (integrated autocorrelation time, IACT)。

---

## 十、关键总结

1. **MCMC 本质**：通过构造以 $\pi$ 为平稳分布的马尔可夫链间接采样——避开归一化常数问题
2. **细致平衡**：$\pi(x) K(x, y) = \pi(y) K(y, x)$ 是 MCMC 构造的充分条件（比全局平衡更强但构造方便）
3. **MH 算法**：最通用的 MCMC，核心是 $\alpha = \min(1, \frac{\tilde{\pi}(y) q(x \mid y)}{\tilde{\pi}(x) q(y \mid x)})$
4. **Gibbs 采样**：MH 的特例——从全条件分布采样，接受率 100%，极大简化实现
5. **最优接受率**：RWM 约 23.4%（高维），HMC 约 65%-80%
6. **HMC 创新**：利用梯度信息和哈密顿动力学实现高效高维采样，远优于 RWM
7. **NUTS**：自动调节 HMC 步数，消除手动调参，是 Stan 的默认引擎
8. **收敛诊断**：$\hat{R} < 1.05$ 指示收敛；ESS 衡量有效信息；迹图提供直观检查
9. **多峰分布**：需要特殊方法（并行回火、slice sampling）——是 MCMC 的核心挑战
10. **MCMC vs VI**：MCMC 精确但慢，VI 快速但有偏——贝叶斯计算的两大支柱
