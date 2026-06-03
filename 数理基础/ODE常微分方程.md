# Chapter 3 一阶微分方程的解的存在定理
## 解的存在唯一性定理
考虑一阶常微分方程的初值问题 (IVP)：

$$\frac{dy}{dx} = f(x, y) \quad \text{满足初值条件} \quad y(x_0) = y_0$$

### **定理**

设函数 $f(x, y)$ 在包含点 $(x_0, y_0)$ 的一个封闭矩形区域 $R$ 上有定义，其中 $R$ 可表示为：

$$R = \{(x, y) : |x - x_0| \le a, |y - y_0| \le b\}, \quad (a > 0, b > 0)$$

如果 $f(x, y)$ 满足以下两个条件：

1. **连续性条件 (Existence Guarantee):** $f(x, y)$ 在区域 $R$ 上连续。
    
2. **利普希茨条件 (Uniqueness Guarantee):** $f(x, y)$ 关于变量 $y$ 在区域 $R$ 上满足利普希茨条件，即存在一个正数 $L$ (利普希茨常数)，使得对于区域 $R$ 中任意两点 $(x, y_1)$ 和 $(x, y_2)$，有：
    
    $$|f(x, y_1) - f(x, y_2)| \le L |y_1 - y_2|$$
    

则：

存在一个正数 $h > 0$，使得在区间 $I = [x_0 - h, x_0 + h]$ 上，上述初值问题**存在**一个**唯一**的解 $y = \phi(x)$。

> **注：** 条件 2 通常可以通过验证 $\frac{\partial f}{\partial y}$ 在 $R$ 上连续且有界来满足。

---
##### **一、 问题设置与等价转换**

我们考虑初值问题 (IVP)：

$$\frac{dy}{dx} = f(x, y), \quad y(x_0) = y_0$$

在满足定理条件（$f(x, y)$ 连续且关于 $y$ 满足利普希茨条件）的区域 $R = \{(x, y) : |x - x_0| \le a, |y - y_0| \le b\}$ 上进行研究。

积分方程转换：

将微分方程从 $x_0$ 积分到 $x$，并利用初值条件，我们将原 IVP 转化为等价的积分方程：

$$y(x) = y_0 + \int_{x_0}^{x} f(t, y(t)) dt$$

我们的目标是证明此积分方程的解 $y(x)$ 在某个区间 $I = [x_0 - h, x_0 + h]$ 上存在且唯一。

##### **二、 构造皮卡迭代序列**

我们定义一个**积分算子** $T$:

$$(Ty)(x) = y_0 + \int_{x_0}^{x} f(t, y(t)) dt$$

原问题等价于寻找一个函数 $y(x)$ 使得 $Ty = y$，即 $y(x)$ 是算子 $T$ 的一个**不动点**。

我们从一个初始逼近 $y_0(x)$ 开始，构造一个函数序列 $\{y_n(x)\}$：

1. **初始值：** $y_0(x) = y_0$ (常函数)
    
2. **迭代公式：** $y_{n+1}(x) = T(y_n)(x) = y_0 + \int_{x_0}^{x} f(t, y_n(t)) dt, \quad \text{for } n = 0, 1, 2, \ldots$
    

##### **三、 确定收敛区间 $I = [x_0 - h, x_0 + h]$**

根据前文的分析，我们选取 $h$ 满足：

$$h = \min \left\{a, \frac{b}{M}\right\}$$

其中 $M = \max_{(x, y) \in R} |f(x, y)|$。选择这个 $h$ 的目的是保证对于所有的迭代函数 $y_n(x)$，其图像 $\Gamma_n = \{(x, y_n(x)) : x \in I\}$ 始终包含在区域 $R$ 内。

**证明：** 对于 $y_1(x) = y_0 + \int_{x_0}^{x} f(t, y_0) dt$，当 $x \in I$ 时：

$$|y_1(x) - y_0| = \left| \int_{x_0}^{x} f(t, y_0) dt \right| \le \int_{x_0}^{x} |f(t, y_0)| dt \le M |x - x_0| \le M h \le M \left(\frac{b}{M}\right) = b$$

即 $|y_1(x) - y_0| \le b$，所以 $y_1(x)$ 的图像在 $R$ 内。通过归纳法，可以证明所有的 $y_n(x)$ 都在 $R$ 内。

##### **四、 证明解的存在性 (收敛性)**

我们通过证明序列 $\{y_n(x)\}$ 在区间 $I$ 上**一致收敛**来证明解的存在性。我们将 $\{y_n(x)\}$ 写成级数形式：

$$y_n(x) = y_0(x) + (y_1(x) - y_0(x)) + (y_2(x) - y_1(x)) + \cdots + (y_n(x) - y_{n-1}(x))$$

该序列的收敛性等价于级数 $\sum_{k=1}^{\infty} (y_k(x) - y_{k-1}(x))$ 的收敛性。

我们使用利普希茨条件 $|f(x, y_1) - f(x, y_2)| \le L |y_1 - y_2|$ 来估计每一项的模：

**第一项 $(k=1)$ 的估计：**

$$|y_1(x) - y_0(x)| = \left| \int_{x_0}^{x} f(t, y_0(t)) dt \right| \le M |x - x_0| \le M h$$

**第二项 $(k=2)$ 的估计：**

$$\begin{aligned} |y_2(x) - y_1(x)| &= \left| \int_{x_0}^{x} [f(t, y_1(t)) - f(t, y_0(t))] dt \right| \\ &\le \left| \int_{x_0}^{x} L |y_1(t) - y_0(t)| dt \right| \\ &\le \left| \int_{x_0}^{x} L (M |t - x_0|) dt \right| \\ &\le L M \frac{|x - x_0|^2}{2} \le M L \frac{h^2}{2} \end{aligned}$$

一般项 $(k=n)$ 的估计 (使用归纳法)：

假设 $|y_{n-1}(x) - y_{n-2}(x)| \le M L^{n-2} \frac{|x - x_0|^{n-1}}{(n-1)!}$。

$$\begin{aligned} |y_n(x) - y_{n-1}(x)| &= \left| \int_{x_0}^{x} [f(t, y_{n-1}(t)) - f(t, y_{n-2}(t))] dt \right| \\ &\le \left| \int_{x_0}^{x} L |y_{n-1}(t) - y_{n-2}(t)| dt \right| \\ &\le \left| \int_{x_0}^{x} L \left( M L^{n-2} \frac{|t - x_0|^{n-1}}{(n-1)!} \right) dt \right| \\ &= M L^{n-1} \frac{1}{(n-1)!} \left| \int_{x_0}^{x} |t - x_0|^{n-1} dt \right| \\ &\le M L^{n-1} \frac{1}{(n-1)!} \frac{|x - x_0|^n}{n} \\ &\le \frac{M}{L} \frac{(L h)^n}{n!} \end{aligned}$$

级数收敛性：

对于 $x \in I$，我们有 $|x - x_0| \le h$。

$$\sum_{k=1}^{\infty} |y_k(x) - y_{k-1}(x)| \le \sum_{k=1}^{\infty} \frac{M}{L} \frac{(L h)^k}{k!} = \frac{M}{L} \sum_{k=1}^{\infty} \frac{(L h)^k}{k!}$$

由于级数 $\sum_{k=0}^{\infty} \frac{(L h)^k}{k!} = e^{L h}$ 是收敛的（泰勒级数），因此比较判别法保证了 $\sum_{k=1}^{\infty} |y_k(x) - y_{k-1}(x)|$ 一致收敛。

根据魏尔斯特拉斯判别法 (Weierstrass M-test)，序列 $\{y_n(x)\}$ 在 $I$ 上**一致收敛**到一个极限函数 $y(x)$:

$$\lim_{n \to \infty} y_n(x) = y(x)$$

由于 $y_n(x)$ 连续，一致收敛保证了极限函数 $y(x)$ 也是**连续**的。

验证 $y(x)$ 是解：

我们对迭代公式取极限：

$$\lim_{n \to \infty} y_{n+1}(x) = y_0 + \int_{x_0}^{x} f(t, \lim_{n \to \infty} y_n(t)) dt$$

由于 $f(t, y)$ 是连续的，且 $\{y_n(t)\}$ 一致收敛，我们可以交换极限和积分号：

$$y(x) = y_0 + \int_{x_0}^{x} f(t, y(t)) dt$$

这证明了 $y(x)$ 满足积分方程，因此是 IVP 的一个**连续解**。

##### **五、 证明解的唯一性**

假设 $y(x)$ 和 $z(x)$ 都是 IVP 在区间 $I$ 上的解。

$$y(x) = y_0 + \int_{x_0}^{x} f(t, y(t)) dt$$

$$z(x) = y_0 + \int_{x_0}^{x} f(t, z(t)) dt$$

两式相减并取绝对值：

$$|y(x) - z(x)| = \left| \int_{x_0}^{x} [f(t, y(t)) - f(t, z(t))] dt \right|$$

记 $\delta(x) = \max_{t \in [x_0, x]} |y(t) - z(t)|$。利用利普希茨条件：

$$|y(x) - z(x)| \le \left| \int_{x_0}^{x} L |y(t) - z(t)| dt \right| \le L \left| \int_{x_0}^{x} \delta(t) dt \right|$$

我们使用[[数学分析#格朗沃尔不等式 (Gronwall's Inequality)]] 的思想。令 $u(x) = |y(x) - z(x)|$，且 $C_0 = \max_{x \in I} u(x)$。

$$u(x) \le L \left| \int_{x_0}^{x} u(t) dt \right|$$

通过重复迭代（或者直接应用格朗沃尔不等式），我们可以推导出：

$$|y(x) - z(x)| \le C_0 \frac{(L |x - x_0|)^n}{n!}$$

对于任意 $x \in I$，我们有 $|x - x_0| \le h$，则：

$$|y(x) - z(x)| \le C_0 \frac{(L h)^n}{n!}$$

令 $n \to \infty$。由于 $Lh$ 是一个有限数，$\lim_{n \to \infty} \frac{(L h)^n}{n!} = 0$。

因此，

$$0 \le |y(x) - z(x)| \le 0$$

这蕴含了 $y(x) = z(x)$，证明了在区间 $I$ 上解是**唯一**的。

**证毕。**
####  进一步说明：$h$ 的确定

虽然定理保证了 $h$ 的存在性，但它的具体取值与 $f(x, y)$ 在区域 $R$ 上的界有关。设 $M$ 是 $f(x, y)$ 在 $R$ 上的最大值（即 $|f(x, y)| \le M$），则 $h$ 至少应满足：

$$\color{blue}h \le \min \left\{a, \frac{b}{M}\right\}$$

选择更小的 $h$ (例如 $h < \min \left\{a, \frac{b}{M}\right\}$) 保证了在解的整个区间上 $y(x)$ 仍然停留在区域 $R$ 的内部，从而保证了迭代过程的收敛性。
#### $\text{\color{red}{利用 Picard 迭代进行近似计算与误差估计}}$

皮卡迭代法不仅是证明一阶常微分方程解的存在唯一性定理（皮卡-林德洛夫定理）的工具，同时也是一种可以实际操作的**数值近似方法**。

###### **一、 近似计算步骤**

考虑初值问题 (IVP)：

$$\frac{dy}{dx} = f(x, y), \quad y(x_0) = y_0$$

将其转化为积分方程：

$$y(x) = y_0 + \int_{x_0}^{x} f(t, y(t)) dt$$

**迭代步骤：**

1. **零次近似 (Initial Approximation):** 选取初值作为第一次近似。
    
    $$y_0(x) = y_0$$
    
2. **$n$ 次近似 (Iteration):** 根据递推公式计算后续近似。
    
    $$y_{n+1}(x) = y_0 + \int_{x_0}^{x} f(t, y_n(t)) dt, \quad n = 0, 1, 2, \ldots$$
    

只要函数 $f(x, y)$ 满足皮卡-林德洛夫定理的条件（局部连续且关于 $y$ 满足利普希茨条件），迭代序列 $y_n(x)$ 就会在解存在的区间 $I = [x_0 - h, x_0 + h]$ 上**一致收敛**到精确解 $y(x)$。

---

##### **二、 误差估计 (Error Estimation)**

误差估计是 Picard 迭代的核心价值之一，因为它提供了一个**可计算的误差上界**。

我们希望估计第 $n$ 次近似解 $y_n(x)$ 与精确解 $y(x)$ 之间的最大误差 $|y(x) - y_n(x)|$。

**基本参数回顾：**

- $R = \{(x, y) : |x - x_0| \le a, |y - y_0| \le b\}$ (矩形区域)
    
- $M = \max_{(x, y) \in R} |f(x, y)|$ (函数 $f$ 的最大值)
    
- $L$ (关于 $y$ 的利普希茨常数): $|f(x, y_1) - f(x, y_2)| \le L |y_1 - y_2|$
    
- $h = \min \left\{a, \frac{b}{M}\right\}$ (解存在区间的一半长度)
    

**误差上界公式：**

对于任意 $x \in I = [x_0 - h, x_0 + h]$，第 $n$ 次近似解 $y_n(x)$ 与精确解 $y(x)$ 之间的误差满足：

$$|y(x) - y_n(x)| \le \frac{M}{L} \frac{(L |x - x_0|)^{n+1}}{(n+1)!}$$

由于 $|x - x_0| \le h$，我们可以得到在整个区间 $I$ 上的最大误差估计：

$$\color{blue}\max_{x \in I} |y(x) - y_n(x)| \le \frac{M}{L} \frac{(L h)^{n+1}}{(n+1)!}$$

###### **公式推导思路：**

这个误差公式来源于证明存在性时使用的**一致收敛性**证明：

精确解 $y(x)$ 是无穷级数 $y(x) = y_0 + \sum_{k=1}^{\infty} (y_k(x) - y_{k-1}(x))$ 的和。

$y(x) - y_n(x)$ 是该级数从第 $n+1$ 项开始的余项：

$$y(x) - y_n(x) = \sum_{k=n+1}^{\infty} (y_k(x) - y_{k-1}(x))$$

取绝对值并利用三角不等式和第三部分的估计式：

$$\begin{aligned} |y(x) - y_n(x)| &\le \sum_{k=n+1}^{\infty} |y_k(x) - y_{k-1}(x)| \\ &\le \sum_{k=n+1}^{\infty} \frac{M}{L} \frac{(L |x - x_0|)^k}{k!} \\ &\le \frac{M}{L} \left( \frac{(L |x - x_0|)^{n+1}}{(n+1)!} + \frac{(L |x - x_0|)^{n+2}}{(n+2)!} + \cdots \right) \end{aligned}$$

最保守的、也是最常用的估计是**只取余项的第一项作为上界**，因为后续各项会以因子 $\frac{L|x-x_0|}{k}$ 衰减，当 $k$ 足够大时，这个因子通常远小于 1，所以第一项主导了误差。

##### **三、 示例（以 $y' = y, y(0)=1$ 为例）**

**初值问题：** $y' = y$, $y(0) = 1$。精确解为 $y(x) = e^x$。

参数确定：

取任意区域 $R$ 包含 $(0, 1)$。这里 $f(x, y) = y$。

- $x_0 = 0, y_0 = 1$
    
- $f$ 关于 $y$ 的偏导 $\frac{\partial f}{\partial y} = 1$，因此利普希茨常数 $L=1$。
    
- $M$ 和 $h$ 的选取在此例中可以忽略，我们只在小区间内考虑。取 $h=1$。
    

**迭代计算：**

1. $y_0(x) = 1$
    
2. $y_1(x) = 1 + \int_{0}^{x} y_0(t) dt = 1 + \int_{0}^{x} 1 dt = 1 + x$
    
3. $y_2(x) = 1 + \int_{0}^{x} y_1(t) dt = 1 + \int_{0}^{x} (1+t) dt = 1 + x + \frac{x^2}{2}$
    
4. $y_n(x) = 1 + x + \frac{x^2}{2!} + \cdots + \frac{x^n}{n!}$
    

**误差估计 (对 $y_n(x)$)：**

在区间 $|x| \le 1$ 上，取 $M=e$（$|f(x, y)| \le e$ 在 $x=1, y=e$ 附近），$L=1, h=1$。

误差上界为：

$$|e^x - y_n(x)| \le \frac{M}{L} \frac{(L |x|)^{n+1}}{(n+1)!} \approx \frac{e}{1} \frac{(1 \cdot |x|)^{n+1}}{(n+1)!}$$

我们知道 $y_n(x)$ 是 $e^x$ 的泰勒级数的前 $n+1$ 项。误差 $|e^x - y_n(x)|$ 正是泰勒级数的余项，Picard 误差估计公式与泰勒余项的估计是高度一致的。

例如，对于 $y_2(x) = 1 + x + \frac{x^2}{2}$，其最大误差在 $x=1$ 处：

$$|e^1 - y_2(1)| \le \frac{e}{1} \frac{(1)^{2+1}}{(2+1)!} = \frac{e}{6} \approx 0.45$$

实际误差是 $e - (1+1+0.5) \approx 2.718 - 2.5 = 0.218$，误差上界确实是成立的。

___
## **基于隐函数定理的存在唯一性**

考虑一阶隐式微分方程的初值问题 (IVP)：

$$F(x, y, p) = 0, \quad \text{其中 } p = \frac{dy}{dx}$$

并给定初值条件 $y(x_0) = y_0$。

假设 $p_0$ 是满足 $F(x_0, y_0, p_0) = 0$ 的一个实数（即 $p_0$ 是初值点的斜率）。

如果函数 $F(x, y, p)$ 满足以下条件：

1. **光滑性条件：** $F(x, y, p)$ 在包含点 $(x_0, y_0, p_0)$ 的一个三维区域 $D$ 内具有关于 $x, y, p$ 的**连续一阶偏导数**。
    
2. **非零偏导数条件 (关键条件)：** $F(x, y, p)$ 关于 $p$ 的偏导数在点 $(x_0, y_0, p_0)$ 处**不为零**：$$\frac{\partial F}{\partial p}\left(x_0, y_0, p_0\right) \ne 0$$
则：
3. **局部显式转化：** 根据隐函数定理，存在一个包含 $(x_0, y_0)$ 的区域 $R$ 和一个包含 $p_0$ 的区间 $I$，使得方程 $F(x, y, p) = 0$ 可以在 $R \times I$ 内**局部唯一地解出** $p$：$$p = \phi(x, y) \quad \text{即 } \frac{dy}{dx} = \phi(x, y)$$
    其中 $\phi(x, y)$ 在 $R$ 内具有连续偏导数。
    
4. **存在唯一性：** 转化后的显式方程 $\frac{dy}{dx} = \phi(x, y)$ 满足皮卡-林德洛夫定理的条件（$\phi(x, y)$ 连续且关于 $y$ 满足利普希茨条件），因此，该隐式初值问题在包含 $x_0$ 的某个小区间上**存在唯一的解** $y(x)$，且满足 $y'(x_0) = p_0$。
    

---

### ** 关键点的解释**

- **光滑性 (条件 1)：** 保证了函数 $F$ 及其偏导数是良态的，这是应用隐函数定理和皮卡-林德洛夫定理的前提。
    
- **非零偏导数 (条件 2)：** 这是保证**局部唯一地解出 $p$** 的关键。如果 $\frac{\partial F}{\partial p}$ 为零，则隐函数定理失效，可能导致在 $(x_0, y_0)$ 处**无法解出唯一的 $p$**（可能有多个 $p$ 满足方程，或根本无法解出），从而可能导致解的**不唯一**或**奇解**的出现。
    

#### **几何意义**

条件 2 确保了在初值点 $(x_0, y_0)$ 处，隐式微分方程只确定了**一个唯一的斜率 $p_0$**。只要有了唯一的斜率 $p_0$，方程就局部转化为标准的显式方程，从而保证了局部存在唯一性。

---

#### 奇解 (Singular Solution) 与唯一性失效

如果 $\frac{\partial F}{\partial p}(x_0, y_0, p_0) = 0$ 成立，则唯一性定理通常失效。

在这种情况下，点 $(x_0, y_0, p_0)$ 被称为一个**奇点**。如果解 $y(x)$ 的图像在某个点 $\tilde{x}$ 处满足 $F(\tilde{x}, y(\tilde{x}), y'(\tilde{x})) = 0$ 且 $\frac{\partial F}{\partial p}(\tilde{x}, y(\tilde{x}), y'(\tilde{x})) = 0$，则 $y(x)$ 可能是**奇解**。

**奇解**的特点是：

1. 它满足微分方程 $F(x, y, y') = 0$。
    
2. 在奇解曲线上任何一点， $\frac{\partial F}{\partial p}$ 均为零。
    
3. 奇解通常是微分方程通解族曲线的**包络线**，并且在同一初值点处，它可能与通解曲线相切，从而**破坏了解的唯一性**。
# Chapter 4 高阶微分方程
## 一、 高阶常微分方程概述

高阶常微分方程 (Ordinary Differential Equation, ODE) 的一般形式可以写为：

$$F(x, y, y', y'', \dots, y^{(n)}) = 0$$

其中 $n$ 为方程的阶数。

### 1. **线性 (Linear) 方程**

如果 $F$ 对 $y, y', \dots, y^{(n)}$ 是线性的，则称为线性 ODE。它具有以下标准形式：

$$y^{(n)} + p_1(x) y^{(n-1)} + \dots + p_n(x) y = f(x)$$

### 2. **非线性 (Non-linear) 方程**

除了线性方程以外的所有方程都属于非线性方程。非线性方程通常没有通用的解析解法。

---

##  二、 线性高阶常微分方程的解法

线性方程是高阶 ODE 中最重要的一类，其通解可以分解为**齐次解**和**特解**两部分：

$$y(x) = y_h(x) + y_p(x)$$

- $y_h(x)$：**齐次方程**（即 $f(x)=0$ 时的解，也叫通解）
    
- $y_p(x)$：**非齐次方程**的一个**特解**
    

### (一) 求齐次方程的通解 $y_h(x)$

对于**$\text{\color{red}{常系数齐次线性微分方程}}$**：

$$y^{(n)} + a_1 y^{(n-1)} + \dots + a_n y = 0 \quad (a_i \text{ 为常数})$$

#### 1. **特征方程法 (Characteristic Equation Method)**

这是核心解法。

- 步骤 1：构造特征方程
    
    将微分运算符 $y^{(k)}$ 替换为代数变量 $\lambda^k$，得到一个 $n$ 阶代数方程：
    
    $$\lambda^n + a_1 \lambda^{n-1} + \dots + a_n = 0$$
    
- 步骤 2：求解特征根
    
    解出该特征方程的所有 $n$ 个根 $\lambda_1, \lambda_2, \dots, \lambda_n$。
    
- 步骤 3：构造基本解组 $y_h(x)$
    
    根据特征根的类型，构造对应的线性无关解：
    

| **根的类型**                           | **对应解的形式**                                                                                                                           |     |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | --- |
| **实数单根** $\lambda$                 | $e^{\lambda x}$                                                                                                                      |     |
| **实数 $k$ 重根** $\lambda$            | $e^{\lambda x}, x e^{\lambda x}, \dots, x^{k-1} e^{\lambda x}$                                                                       |     |
| **复数单根** $\alpha \pm i \beta$      | $e^{\alpha x} \cos(\beta x), e^{\alpha x} \sin(\beta x)$                                                                             |     |
| **复数 $k$ 重根** $\alpha \pm i \beta$ | $e^{\alpha x} \cos(\beta x), x e^{\alpha x} \cos(\beta x), \dots,$ $e^{\alpha x} \sin(\beta x), x e^{\alpha x} \sin(\beta x), \dots$ |     |

- 步骤 4：写出通解
    
    将所有基本解线性组合，得到齐次通解：
    
    $$y_h(x) = C_1 y_1(x) + C_2 y_2(x) + \dots + C_n y_n(x)$$
    
    其中 $C_i$ 为任意常数。
    

### (二) 求非齐次方程的特解 $y_p(x)$

对于非齐次方程 $y^{(n)} + a_1 y^{(n-1)} + \dots + a_n y = f(x)$：

#### 1. **待定系数法 (Method of Undetermined Coefficients)**

这种方法适用于非齐次项 $f(x)$ 具有特殊形式时（如多项式、指数函数、正弦/余弦函数或它们的乘积）。

- **基本思想：** 根据 $f(x)$ 的形式，推测 $y_p(x)$ 的形式，但要确保该形式中的每一项都不是齐次方程的解。
    
- **修正规则 (Modification Rule)：** 如果推测的特解形式中的某一项是齐次方程的解，则将整个推测形式乘以 $x^k$，其中 $k$ 是该项成为齐次解的重数。
    

#### 2. **常数变易法 (Method of Variation of Parameters)**

这是一种**通用**的方法，适用于任意形式的 $f(x)$，但计算量较大，需要先求出齐次通解 $y_h(x)$。

- **基本思想：** 假设特解的形式为 $y_p(x) = C_1(x) y_1(x) + C_2(x) y_2(x) + \dots + C_n(x) y_n(x)$，其中 $y_i(x)$ 是齐次方程的基本解组，而 $C_i(x)$ 是待求的函数。
    
- 步骤： 求解一个由 $\frac{dC_i}{dx}$ 构成的线性代数方程组，该方程组的系数矩阵是朗斯基矩阵 (Wronskian Matrix) $W(y_1, \dots, y_n)$。
    
    $$\begin{pmatrix} y_1 & y_2 & \dots & y_n \\ y_1' & y_2' & \dots & y_n' \\ \vdots & \vdots & \ddots & \vdots \\ y_1^{(n-1)} & y_2^{(n-1)} & \dots & y_n^{(n-1)} \end{pmatrix} \begin{pmatrix} C_1'(x) \\ C_2'(x) \\ \vdots \\ C_n'(x) \end{pmatrix} = \begin{pmatrix} 0 \\ 0 \\ \vdots \\ f(x) \end{pmatrix}$$
    
    然后通过积分得到 $C_i(x)$。
    

---

## 三、 特殊形式的非线性高阶方程

对于非线性高阶方程，虽然没有通用解法，但有些特殊形式可以通过**降阶**简化。

### 1. 不含 $y$ 的方程

如果方程中不显含 $y$，即 $F(x, y', y'', \dots, y^{(n)}) = 0$，可以令：

$$z = y'$$

则 $z' = y''$, $z'' = y'''$, $\dots$

原 $n$ 阶方程降为关于 $z$ 的 $n-1$ 阶方程：

$$F(x, z, z', \dots, z^{(n-1)}) = 0$$

解出 $z(x)$ 后，再积分一次 $y(x) = \int z(x) dx + C$ 即可。

### 2. 不含 $x$ 的方程

如果方程中不显含 $x$，即 $F(y, y', y'', \dots, y^{(n)}) = 0$，可以令：

$$y' = p$$

将 $p$ 视为 $y$ 的函数，即 $p=p(y)$。

$$\begin{aligned} y'' &= \frac{dp}{dx} = \frac{dp}{dy} \frac{dy}{dx} = p \frac{dp}{dy} \\ y''' &= \frac{d}{dx} \left(p \frac{dp}{dy}\right) = \frac{d}{dy} \left(p \frac{dp}{dy}\right) \frac{dy}{dx} = p \left[ p \frac{d^2p}{dy^2} + \left(\frac{dp}{dy}\right)^2 \right]\end{aligned}$$

原 $n$ 阶方程降为关于 $p$ 的 $n-1$ 阶方程，其自变量为 $y$：

$$G(y, p, p', \dots, p^{(n-1)}) = 0 \quad \text{其中 } p' = \frac{dp}{dy}$$

解出 $p(y)$ 后，再解微分方程 $\frac{dy}{dx} = p(y)$ 即可。

---

## 简要总结

| **方程类型**        | **求解步骤**                                                    | **常用方法**                    |
| --------------- | ----------------------------------------------------------- | --------------------------- |
| **齐次线性常系数**     | 1. 构造特征方程。 2. 求解特征根。 3. 构造基本解组。                             | 特征方程法                       |
| **非齐次线性常系数**    | 1. **齐次解 $y_h$** (同上)。 2. **特解 $y_p$**。 3. $y = y_h + y_p$。 | 待定系数法（特殊 $f(x)$）/ 常数变易法（通用） |
| **不含 $y$ 的非线性** | 令 $z = y'$ 降阶。                                              | 降阶法                         |
| **不含 $x$ 的非线性** | 令 $y' = p$ 降阶，以 $y$ 为自变量。                                   | 降阶法                         |
##### 补充：朗斯基行列式的导数与原行列式的关系：阿贝尔公式 (Abel's Formula)

###### 1. 基础知识回顾

设我们有一个 $n$ 阶线性齐次微分方程：

$$y^{(n)} + a_{n-1}(x) y^{(n-1)} + \cdots + a_1(x) y' + a_0(x) y = 0$$

设 $y_1(x), y_2(x), \dots, y_n(x)$ 是这个微分方程的 $n$ 个解。

朗斯基行列式 (Wronskian) $W(x)$ 定义为：

$$W(x) = W(y_1, y_2, \dots, y_n)(x) = \begin{vmatrix} y_1 & y_2 & \cdots & y_n \\ y_1' & y_2' & \cdots & y_n' \\ \vdots & \vdots & \ddots & \vdots \\ y_1^{(n-1)} & y_2^{(n-1)} & \cdots & y_n^{(n-1)} \end{vmatrix}$$

###### 2. 阿贝尔公式 (Abel's Formula)

朗斯基行列式的导数 $\frac{dW}{dx}$ 与原行列式 $W(x)$ 满足以下关系：

$$\frac{dW}{dx} = -a_{n-1}(x) W(x)$$

其中 $a_{n-1}(x)$ 是微分方程中 $y^{(n-1)}$ 项的系数（前提是 $y^{(n)}$ 的系数为 1）。

###### 3. $W(x)$ 与 $W(x_0)$ 的关系（积分形式）

对上面的微分方程进行分离变量和积分，可以得到朗斯基行列式在任意点 $x$ 的值与在某个定点 $x_0$ 的值之间的关系：

$$W(x) = W(x_0) \exp \left( -\int_{x_0}^x a_{n-1}(t) dt \right)$$

这个公式就是著名的**阿贝尔公式**。

###### 4. 证明思路

证明的关键在于行列式求导的性质：

1. 行列式求导规则： 对一个 $n$ 阶行列式求导，等于对每一行分别求导，然后将所有结果加起来。
    
    $$\frac{dW}{dx} = \sum_{i=1}^n (\text{行列式 } W \text{ 的第 } i \text{ 行求导})$$
    
2. **具体计算:**
    
    - 对第 $1$ 行求导，得到新行列式的第 $1$ 行为 $y_j'$，它与第 $2$ 行 $y_j'$ 相同，所以该行列式为 $0$。
        
    - 对第 $2$ 行求导，得到新行列式的第 $2$ 行为 $y_j''$，它与第 $3$ 行 $y_j''$ 相同，所以该行列式为 $0$。
        
    - $\cdots$
        
    - 直到第 $n-1$ 行求导，新行列式的第 $n-1$ 行与第 $n$ 行不同，因此该项不为 $0$。
        
    - **只有对最后一行（第 $n$ 行）求导的项是非零的。**
        
3. 结果:
    
    $$\frac{dW}{dx} = \begin{vmatrix} y_1 & y_2 & \cdots & y_n \\ y_1' & y_2' & \cdots & y_n' \\ \vdots & \vdots & \ddots & \vdots \\ y_1^{(n)} & y_2^{(n)} & \cdots & y_n^{(n)} \end{vmatrix}$$
    
    （新的最后一行是 $y_j^{(n)}$）
    
4. 利用微分方程: 由于 $y_j(x)$ 是微分方程的解，因此有：
    
    $$y_j^{(n)} = -a_{n-1} y_j^{(n-1)} - a_{n-2} y_j^{(n-2)} - \cdots - a_0 y_j$$
    
5. **行列式运算:** 将 $y_j^{(n)}$ 的表达式代入上式行列式的最后一行。然后利用行列式的性质（将某一行乘以一个数加到另一行上，行列式值不变）：
    
    - 将倒数第二行（$y_j^{(n-1)}$）乘以 $a_{n-1}$ 加到最后一行。
        
    - 将倒数第三行（$y_j^{(n-2)}$）乘以 $a_{n-2}$ 加到最后一行。
        
    - $\cdots$
        
    - 最终，最后一行变为：$(-a_{n-1} y_j^{(n-1)}, -a_{n-1} y_j^{(n-1)}, \dots)$。
        
    
    提取 $-a_{n-1}$ 得到：
    
    $$\frac{dW}{dx} = -a_{n-1} \begin{vmatrix} y_1 & y_2 & \cdots & y_n \\ y_1' & y_2' & \cdots & y_n' \\ \vdots & \vdots & \ddots & \vdots \\ y_1^{(n-1)} & y_2^{(n-1)} & \cdots & y_n^{(n-1)} \end{vmatrix} = -a_{n-1} W(x)$$
    

###### 5. 核心推论

1. **非零性:** 如果 $a_{n-1}(x)$ 在区间 $I$ 上连续，那么朗斯基行列式 $W(x)$ 在 $I$ 上的值：
    
    - **要么恒为零** (当 $W(x_0)=0$ 时)。
        
    - **要么恒不为零** (当 $W(x_0) \neq 0$ 时)。
        
    - **这意味着 $W(x)$ 不可能在区间 $I$ 上的某些点为零而在其他点不为零。**
        
2. **线性无关性判别:** $y_1, \dots, y_n$ 是线性齐次微分方程解集的充要条件是它们**线性无关**，而这等价于它们的朗斯基行列式 $W(x)$ 在整个区间上**不恒为零**。
# Chapter 5 线性微分方程组

## 求解步骤：齐次方程组
首先，我们考虑对应的**齐次方程组**：
$$\mathbf{x}'(t) = A(t) \mathbf{x}(t)$$
求解的关键是找到**基解矩阵**（Fundamental Matrix）。
### 情况一：常系数齐次方程组 ($A$ 是常数矩阵)
当系数矩阵 $A$ **不依赖于 $t$** 时，求解方法如下：
#### 1. 求解特征值和特征向量
计算矩阵 $A$ 的特征值 $\lambda$ 和对应的特征向量 $\mathbf{v}$。特征值 $\lambda$ 是方程 $\det(A - \lambda I) = 0$ 的根。
#### 2. 构造齐次解 $\mathbf{x}_h(t)$
- **如果 $A$ 有 $n$ 个线性无关的特征向量**（无论特征值是否重复）：
    - 设特征值为 $\lambda_1, \lambda_2, \ldots, \lambda_n$，对应的特征向量为 $\mathbf{v}_1, \mathbf{v}_2, \ldots, \mathbf{v}_n$。
    - 则 $n$ 个线性无关的特解为 $\mathbf{x}_i(t) = e^{\lambda_i t} \mathbf{v}_i$。
    - 齐次通解为它们的线性组合：$$\mathbf{x}_h(t) = c_1 e^{\lambda_1 t} \mathbf{v}_1 + c_2 e^{\lambda_2 t} \mathbf{v}_2 + \cdots + c_n e^{\lambda_n t} \mathbf{v}_n$$
        其中 $c_i$ 是任意常数。
- **如果 $A$ 存在重特征值且不足 $n$ 个线性无关的特征向量**（亏损 Deficiency）：
    - 需要使用**广义特征向量**（Generalized Eigenvectors）来构造额外的线性无关解，或者使用**矩阵指数** $e^{At}$。
    - **矩阵指数法：** 齐次通解为 $\mathbf{x}_h(t) = e^{At} \mathbf{c}$，其中 $\mathbf{c}$ 是一个 $n$ 维常数向量。
        

---

## 求解步骤：非齐次方程组

求解非齐次方程组 $\mathbf{x}'(t) = A(t) \mathbf{x}(t) + \mathbf{f}(t)$ 的通解 $\mathbf{x}(t)$，总是由**齐次通解** $\mathbf{x}_h(t)$ 和**一个特解** $\mathbf{x}_p(t)$ 构成：

$$\mathbf{x}(t) = \mathbf{x}_h(t) + \mathbf{x}_p(t)$$

当 $A$ 是**常数矩阵**时，求解特解 $\mathbf{x}_p(t)$ 最常用的方法是**常数变易法**（Variation of Parameters）。

### 常数变易法（Variation of Parameters）

#### 1. 构造基解矩阵 $\Phi(t)$

首先找到齐次方程组的 $n$ 个线性无关的特解 $\mathbf{x}_1(t), \mathbf{x}_2(t), \ldots, \mathbf{x}_n(t)$。

将这些特解按列排成一个 $n \times n$ 矩阵，即为基解矩阵 $\Phi(t)$：

$$\Phi(t) = \left[ \mathbf{x}_1(t) \quad \mathbf{x}_2(t) \quad \cdots \quad \mathbf{x}_n(t) \right]$$

对于常系数齐次方程组，如果使用矩阵指数法， $\Phi(t)$ 可以取 $e^{At}$。

#### 2. 假设特解形式

设非齐次方程组的特解 $\mathbf{x}_p(t)$ 具有如下形式：

$$\mathbf{x}_p(t) = \Phi(t) \mathbf{u}(t)$$

其中 $\mathbf{u}(t)$ 是一个待定的 $n$ 维向量函数。

#### 3. 求解 $\mathbf{u}(t)$

将 $\mathbf{x}_p(t)$ 代入非齐次方程组 $\mathbf{x}'(t) = A \mathbf{x}(t) + \mathbf{f}(t)$，经过推导（利用 $\Phi'(t) = A \Phi(t)$），可以得到关于 $\mathbf{u}'(t)$ 的方程：

$$\Phi(t) \mathbf{u}'(t) = \mathbf{f}(t)$$

由于 $\Phi(t)$ 是基解矩阵，所以它是可逆的，因此：

$$\mathbf{u}'(t) = \Phi^{-1}(t) \mathbf{f}(t)$$

对 $\mathbf{u}'(t)$ 进行积分，得到 $\mathbf{u}(t)$：

$$\mathbf{u}(t) = \int \Phi^{-1}(t) \mathbf{f}(t) dt$$

(注意：这里积分不加常数项，因为我们只要求一个特解 $\mathbf{x}_p$)

#### 4. 最终特解和通解

- 特解 $\mathbf{x}_p(t)$ 为：
    
    $$\mathbf{x}_p(t) = \Phi(t) \int \Phi^{-1}(t) \mathbf{f}(t) dt$$
    
- 最终通解 $\mathbf{x}(t)$ 为：
    
    $$\mathbf{x}(t) = \mathbf{x}_h(t) + \mathbf{x}_p(t) = \Phi(t) \mathbf{c} + \Phi(t) \int \Phi^{-1}(t) \mathbf{f}(t) dt$$
    
    其中 $\mathbf{c}$ 是一个 $n$ 维常数向量，$\mathbf{x}_h(t) = \Phi(t) \mathbf{c}$。
    

---

## 总结流程（常系数线性方程组）

| **步骤**      | **目标**                          | **方法/公式**                                                                                               |
| ----------- | ------------------------------- | ------------------------------------------------------------------------------------------------------- |
| **1. 齐次通解** | 求解 $\mathbf{x}' = A \mathbf{x}$ | 计算 $A$ 的**特征值** $\lambda_i$ 和**特征向量** $\mathbf{v}_i$。                                                   |
|             |                                 | $\mathbf{x}_h(t) = c_1 e^{\lambda_1 t} \mathbf{v}_1 + \cdots + c_n e^{\lambda_n t} \mathbf{v}_n$ (简单情况) |
| **2. 基解矩阵** | 构造 $\Phi(t)$                    | $\Phi(t) = \left[ \mathbf{x}_1(t) \quad \cdots \quad \mathbf{x}_n(t) \right]$                           |
| **3. 积分项**  | 计算 $\mathbf{u}(t)$ 的导数          | $\mathbf{u}'(t) = \Phi^{-1}(t) \mathbf{f}(t)$                                                           |
|             | 计算 $\mathbf{u}(t)$              | $\mathbf{u}(t) = \int \mathbf{u}'(t) dt$                                                                |
| **4. 特解**   | 求解 $\mathbf{x}_p(t)$            | $\mathbf{x}_p(t) = \Phi(t) \mathbf{u}(t)$                                                               |
| **5. 最终通解** | 求解 $\mathbf{x}(t)$              | $\mathbf{x}(t) = \mathbf{x}_h(t) + \mathbf{x}_p(t)$                                                     |


