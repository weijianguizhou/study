随机微分方程（Stochastic Differential Equation，简称 **SDE**）是**常微分方程**（Ordinary Differential Equation, ODE）的扩展。

###  核心概念

- **定义：** SDE 是一种微分方程，其中包含**随机过程**（通常是一个白噪声项，例如布朗运动的微分），因此其解本身也是一个随机过程。
    
- **形式：** SDE 通常用来描述一个随机变量随时间的变动过程，它在常规的微分方程的基础上增加了一个随机项。
    
- 数学表示（伊藤（Itô）形式）：
    
    $$dX_t = \mu(t, X_t) dt + \sigma(t, X_t) dW_t$$
    
    - $X_t$: 描述的随机过程（例如，资产价格、粒子位置）。
        
    - $\mu(t, X_t)$: **漂移项**（Drift Term），与常规 ODE 中的项类似，描述了过程的确定性趋势。
        
    - $\sigma(t, X_t)$: **扩散项**（Diffusion Term），描述了随机扰动的大小。
        
    - $dW_t$: **维纳过程**（Wiener Process，也称布朗运动）的微分，代表了随机的“白噪声”输入。
###  随机微分方程 (SDE) 模型应用

对于第 $i$ 个智能体，其位置的 SDE 可以写成如下形式：

$$d\mathbf{x}_i = \mathbf{F}_{\text{吸引}}(\mathbf{x}_i) dt + \mathbf{F}_{\text{邻里}}(\mathbf{x}_i) dt + \mathbf{F}_{\text{排斥}}(\mathbf{x}_i) dt + \sigma d\mathbf{W}_i$$

其中：

- $d\mathbf{x}_i = \frac{d\mathbf{x}_i}{dt} dt$
    
- $\mathbf{W}_i$ 是独立的 $d$ 维维纳过程（随机扰动）。
    
- $\sigma > 0$ 是随机扰动项的强度（扩散系数）。
    

下面我们将详细定义这四个力项 $\mathbf{F}$。我们假设群体总数为 $N$，目标位置为 $\mathbf{x}^*$。

---

### 1.  目标吸引力（Target Attraction）

这个力项使智能体倾向于移动到某个预设的目标位置 $\mathbf{x}^*$。

$$\mathbf{F}_{\text{吸引}}(\mathbf{x}_i) = k_A (\mathbf{x}^* - \mathbf{x}_i)$$

- $k_A > 0$: **吸引系数**，控制吸引力的强度。
    
- $\mathbf{x}^* - \mathbf{x}_i$: 从 $\mathbf{x}_i$ 指向目标 $\mathbf{x}^*$ 的向量。
    
- **物理意义：** 这是一种简单的**线性反馈**，距离目标越远，吸引力越大。
    

### 2.  邻里交互（群体效应 / Cohesion）

这个力项使智能体倾向于靠近其邻居，以维持群体的凝聚力。通常建模为趋向于**局部中心**或**群体中心**。

$$\mathbf{F}_{\text{邻里}}(\mathbf{x}_i) = k_C \left( \frac{1}{|\mathcal{N}_i|} \sum_{j \in \mathcal{N}_i} \mathbf{x}_j - \mathbf{x}_i \right)$$

- $k_C > 0$: **凝聚系数**，控制群体交互的强度。
    
- $\mathcal{N}_i$: 智能体 $i$ 的**邻居集合**。这可以是所有其他智能体 $j \neq i$，或者是在 $i$ 周围特定半径 $R_C$ 内的智能体集合。
    
- $\frac{1}{|\mathcal{N}_i|} \sum_{j \in \mathcal{N}_i} \mathbf{x}_j$: 智能体 $i$ 的邻居的**平均位置**（局部中心）。
    
- **物理意义：** 智能体 $i$ 试图收敛到其邻居的平均位置。
    

### 3. 拥塞排斥力（Crowd Repulsion / Separation）

这个力项使智能体与其**太近的**邻居相互排斥，以防止碰撞和过度拥塞。这通常是一个短程、非线性的斥力。

$$\mathbf{F}_{\text{排斥}}(\mathbf{x}_i) = -k_R \sum_{j \in \mathcal{R}_i} g(|\mathbf{x}_i - \mathbf{x}_j|) \frac{\mathbf{x}_i - \mathbf{x}_j}{|\mathbf{x}_i - \mathbf{x}_j|}$$

- $k_R > 0$: **排斥系数**。
    
- $\mathcal{R}_i$: 智能体 $i$ 的**排斥邻居集合**（例如，距离小于 $R_R$ 的智能体）。通常 $R_R$ 远小于 $R_C$。
    
- $g(r)$: 一个**单调递减**的函数，当距离 $r$ 减小时，其值急剧增大（例如 $g(r) = 1/r^2$ 或 $g(r) = e^{-\alpha r}$）。
    
- $\frac{\mathbf{x}_i - \mathbf{x}_j}{|\mathbf{x}_i - \mathbf{x}_j|}$: 从 $j$ 指向 $i$ 的单位向量（排斥方向）。
    
- **物理意义：** 当两个智能体靠得太近时，它们之间会产生一个迅速增大的推力，使它们分开。
    

### 4.  随机扰动（Stochastic Perturbation）

这是 SDE 区别于 ODE 的关键项，它为系统的运动引入了不确定性。

$$\mathbf{F}_{\text{随机}}(\mathbf{x}_i) dt = \sigma d\mathbf{W}_i$$

- $\sigma$: **噪声强度**，控制运动的随机性程度。
    
- $d\mathbf{W}_i$: $d$ 维维纳过程的微分，满足 $\mathbb{E}[d\mathbf{W}_i] = 0$ 且 $\mathbb{E}[d\mathbf{W}_i d\mathbf{W}_i^T] = I dt$。
    

---

###  完整的 SDE

将所有项组合起来，第 $i$ 个智能体的完整 SDE 模型为：

$$\mathbf{dx}_i = \left[ k_A (\mathbf{x}^* - \mathbf{x}_i) + k_C \left( \frac{1}{|\mathcal{N}_i|} \sum_{j \in \mathcal{N}_i} \mathbf{x}_j - \mathbf{x}_i \right) - k_R \sum_{j \in \mathcal{R}_i} g(|\mathbf{x}_i - \mathbf{x}_j|) \frac{\mathbf{x}_i - \mathbf{x}_j}{|\mathbf{x}_i - \mathbf{x}_j|} \right] dt + \sigma d\mathbf{W}_i$$

这个模型是**自组织群体运动**（如 Boids 模型）和**随机控制理论**的常见应用。