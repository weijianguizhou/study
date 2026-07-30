# ARIMA 时间序列模型

> 参考文献：Box & Jenkins (1970), *Time Series Analysis: Forecasting and Control*

---

## 一、平稳性理论

### 1.1 严平稳

时间序列 $\{X_t\}_{t \in \mathbb{Z}}$ 称为**严平稳**的，若对任意 $n \geq 1$、任意时间点 $t_1, t_2, \ldots, t_n$ 以及任意滞后 $h$，联合分布函数满足：

$$F_{X_{t_1}, X_{t_2}, \ldots, X_{t_n}}(x_1, x_2, \ldots, x_n) = F_{X_{t_1+h}, X_{t_2+h}, \ldots, X_{t_n+h}}(x_1, x_2, \ldots, x_n)$$

直观含义：序列的统计性质不随时间原点平移而改变。严平稳要求所有阶矩存在且不变，实践中过于严苛。

### 1.2 弱平稳

时间序列 $\{X_t\}$ 称为**弱平稳**（协方差平稳），若满足：

1. **均值恒定**：$E(X_t) = \mu$，对任意 $t$
2. **方差恒定**：$\text{Var}(X_t) = E[(X_t - \mu)^2] = \sigma^2 < \infty$
3. **自协方差仅取决于滞后**：$\text{Cov}(X_t, X_{t+k}) = \gamma_k$，与 $t$ 无关

对于高斯过程，严平稳等价于弱平稳。ARIMA 框架中通常只要求弱平稳。

### 1.3 平稳性检验的重要性

若非平稳序列直接用于建模，会产生**伪回归**问题——即使两个完全无关的非平稳序列，回归也可能显示显著关系。此外，非平稳序列的方差随时间发散，预测无意义。

---

## 二、自相关函数 $\rho_k$ 与偏自相关函数 $\phi_{kk}$

### 2.1 自协方差函数

$$\gamma_k = \text{Cov}(X_t, X_{t+k}) = E[(X_t - \mu)(X_{t+k} - \mu)]$$

- $\gamma_0 = \text{Var}(X_t)$ 为方差
- $\gamma_k = \gamma_{-k}$（对称性）

### 2.2 自相关函数（ACF）

$$\rho_k = \frac{\gamma_k}{\gamma_0} = \frac{\text{Cov}(X_t, X_{t+k})}{\text{Var}(X_t)}$$

**性质：**
- $\rho_0 = 1$，$-1 \leq \rho_k \leq 1$
- 对于白噪声，$\rho_k = 0$（$\forall k \neq 0$）
- 对于平稳过程，$\rho_k \to 0$ 随着 $k \to \infty$

**样本自相关函数：**

$$\hat{\rho}_k = \frac{\sum_{t=1}^{n-k}(X_t - \bar{X})(X_{t+k} - \bar{X})}{\sum_{t=1}^{n}(X_t - \bar{X})^2}$$

Bartlett 近似标准差：$SE(\hat{\rho}_k) \approx \frac{1}{\sqrt{n}}\sqrt{1 + 2\sum_{j=1}^{k-1}\hat{\rho}_j^2}$

### 2.3 偏自相关函数（PACF）

$$\phi_{kk} = \text{Corr}(X_t, X_{t-k} \mid X_{t-1}, X_{t-2}, \ldots, X_{t-k+1})$$

即剔除了中间变量 $X_{t-1}, \ldots, X_{t-k+1}$ 的线性影响后，$X_t$ 与 $X_{t-k}$ 的净相关性。

**计算方式（Yule-Walker 递推）：**

$$\phi_{11} = \rho_1$$

$$\phi_{kk} = \frac{\rho_k - \sum_{j=1}^{k-1}\phi_{k-1,j}\,\rho_{k-j}}{1 - \sum_{j=1}^{k-1}\phi_{k-1,j}\,\rho_j}$$

$$\phi_{k,j} = \phi_{k-1,j} - \phi_{kk}\,\phi_{k-1,k-j}, \quad j = 1,\ldots,k-1$$

**截尾性质：** 对于 AR(p) 过程，$\phi_{kk} = 0$（$\forall k > p$）。这是 PACF 最重要的模型识别特征。

### 2.4 白噪声过程

若 $\{X_t\}$ 满足：
- $E(X_t) = 0$
- $\text{Var}(X_t) = \sigma^2$
- $\text{Cov}(X_t, X_s) = 0$（$\forall t \neq s$）

则称 $\{X_t\}$ 为**白噪声过程**，记为 $X_t \sim WN(0, \sigma^2)$。

---

## 三、AR(p) 模型——自回归模型

### 3.1 模型定义

$p$ 阶自回归模型 AR(p)：

$$X_t = c + \phi_1 X_{t-1} + \phi_2 X_{t-2} + \cdots + \phi_p X_{t-p} + \varepsilon_t$$

其中 $\varepsilon_t \sim WN(0, \sigma^2)$，$\varepsilon_t$ 与过去的 $X_{t-k}$ 独立。

### 3.2 滞后算子表示

引入滞后算子（backshift operator）$B$，满足 $B X_t = X_{t-1}$，$B^k X_t = X_{t-k}$：

$$\Phi(B) X_t = c + \varepsilon_t$$

其中特征多项式：

$$\Phi(B) = 1 - \phi_1 B - \phi_2 B^2 - \cdots - \phi_p B^p$$

### 3.3 平稳性条件

AR(p) 过程平稳的充要条件是：特征方程 $\Phi(z) = 0$ 的所有根的模都大于 1（即在单位圆外）。

$$\Phi(z) = 1 - \phi_1 z - \phi_2 z^2 - \cdots - \phi_p z^p = 0 \quad \Longrightarrow \quad |z_i| > 1, \forall i$$

**等价判别（Schur-Cohn 条件）：**

对 AR(1)：$|\phi_1| < 1$

对 AR(2)：

$$\begin{cases} \phi_1 + \phi_2 < 1 \\ \phi_2 - \phi_1 < 1 \\ |\phi_2| < 1 \end{cases}$$

### 3.4 AR(1) 的 Yule-Walker 方程

$$X_t = c + \phi X_{t-1} + \varepsilon_t$$

- 均值：$\mu = \dfrac{c}{1 - \phi}$
- 自协方差：$\gamma_0 = \sigma^2 / (1 - \phi^2)$
- ACF：$\rho_k = \phi^{|k|}$（指数衰减至零）

若 $\phi > 0$，ACF 单调衰减；若 $\phi < 0$，ACF 正负交替衰减。

### 3.5 AR(p) 的 Yule-Walker 方程

$$\begin{pmatrix} \gamma_0 & \gamma_1 & \cdots & \gamma_{p-1} \\ \gamma_1 & \gamma_0 & \cdots & \gamma_{p-2} \\ \vdots & \vdots & \ddots & \vdots \\ \gamma_{p-1} & \gamma_{p-2} & \cdots & \gamma_0 \end{pmatrix} \begin{pmatrix} \phi_1 \\ \phi_2 \\ \vdots \\ \phi_p \end{pmatrix} = \begin{pmatrix} \gamma_1 \\ \gamma_2 \\ \vdots \\ \gamma_p \end{pmatrix}$$

即 $\Gamma_p \boldsymbol{\phi} = \boldsymbol{\gamma}_p$。

---

## 四、MA(q) 模型——移动平均模型

### 4.1 模型定义

$$X_t = \mu + \varepsilon_t + \theta_1 \varepsilon_{t-1} + \theta_2 \varepsilon_{t-2} + \cdots + \theta_q \varepsilon_{t-q}$$

滞后算子形式：

$$X_t = \mu + \Theta(B) \varepsilon_t$$

其中 $\Theta(B) = 1 + \theta_1 B + \theta_2 B^2 + \cdots + \theta_q B^q$。

### 4.2 可逆性条件

MA(q) 过程可逆的充要条件是：特征方程 $\Theta(z) = 0$ 的所有根都在单位圆外（$|z| > 1$）。

**可逆性的意义：** 可逆 MA 过程可以表示为 AR($\infty$) 过程，即当前值可以完全由过去的观测值解释。这保证了参数估计的唯一性。

对 MA(1)：$|\theta_1| < 1$

### 4.3 MA(q) 的统计性质

- **均值**：$E(X_t) = \mu$（无条件均值）
- **方差**：$\gamma_0 = \sigma^2(1 + \theta_1^2 + \theta_2^2 + \cdots + \theta_q^2)$
- **自协方差**：$\gamma_k = \sigma^2(\theta_k + \theta_1\theta_{k+1} + \cdots + \theta_{q-k}\theta_q)$，其中 $\theta_0 \equiv 1$

**核心性质：MA(q) 的 ACF 在 $k > q$ 时为零**（$q$ 步截尾）。这是识别 MA 模型的关键。

### 4.4 MA(1) 示例

$$X_t = \mu + \varepsilon_t + \theta \varepsilon_{t-1}$$

- $\gamma_0 = \sigma^2(1 + \theta^2)$
- $\gamma_1 = \sigma^2 \theta$
- $\gamma_k = 0$（$k \geq 2$）
- $\rho_1 = \dfrac{\theta}{1 + \theta^2}$，最大绝对值 $\frac{1}{2}$ 当 $\theta = 1$

---

## 五、ARMA(p, q) 模型

### 5.1 模型定义

$$X_t = c + \sum_{i=1}^{p}\phi_i X_{t-i} + \varepsilon_t + \sum_{j=1}^{q}\theta_j \varepsilon_{t-j}$$

$$\Phi(B) X_t = c + \Theta(B) \varepsilon_t$$

### 5.2 模型的 ACF/PACF 识别特征

这是 Box-Jenkins 方法中模型识别的核心依据：

| 模型 | ACF（自相关函数） | PACF（偏自相关函数） |
|:---:|:---:|:---:|
| AR(p) | **拖尾**（指数/阻尼正弦衰减） | **$p$ 步截尾** |
| MA(q) | **$q$ 步截尾** | **拖尾**（指数/阻尼正弦衰减） |
| ARMA(p,q) | **拖尾** | **拖尾** |

### 5.3 Wold 分解定理

任意协方差平稳过程 $\{X_t\}$ 可以唯一分解为：

$$X_t = \sum_{j=0}^{\infty} \psi_j \varepsilon_{t-j} + \kappa_t$$

其中 $\psi_0 = 1$，$\sum \psi_j^2 < \infty$，$\varepsilon_t$ 为白噪声，$\kappa_t$ 为确定性成分。这意味着任意平稳过程都可表示为（可能的无穷阶）MA 过程。

---

## 六、差分与 ARIMA(p, d, q) 模型

### 6.1 差分算子

**一阶差分：**

$$\nabla X_t = X_t - X_{t-1} = (1 - B) X_t$$

**$d$ 阶差分：**

$$\nabla^d X_t = (1 - B)^d X_t = \sum_{i=0}^{d} (-1)^i \binom{d}{i} X_{t-i}$$

**季节差分**（周期 $s$）：

$$\nabla_s X_t = X_t - X_{t-s} = (1 - B^s) X_t$$

### 6.2 差分过度的风险

$$\nabla (\nabla X_t) = X_t - 2X_{t-1} + X_{t-2}$$

二阶差分使方差增大，且可能引入虚假的 MA(1) 结构。实际中 $d$ 通常不超过 2。

### 6.3 ARIMA(p, d, q) 模型

若 $\{X_t\}$ 非平稳，但其 $d$ 阶差分后满足 ARMA(p, q)，则称 $\{X_t\}$ 服从 ARIMA(p, d, q)：

$$\Phi(B)(1 - B)^d X_t = c + \Theta(B) \varepsilon_t$$

**特例：**
- ARIMA(0, 1, 0)：随机游走 $X_t = X_{t-1} + \varepsilon_t$
- ARIMA(0, 1, 1)：指数平滑

### 6.4 单位根与差分

若 $\Phi(z)$ 有根恰好在单位圆上（$|z| = 1$），则过程具有**单位根**，是非平稳的。差分 $d$ 次相当于消去 $d$ 个单位根。

例如：ARIMA(1, 1, 0)：
$$(1 - \phi B)(1 - B)X_t = \varepsilon_t$$

多项式 $(1 - z)(1 - \phi z) = 0$ 有一个单位根 $z = 1$。

---

## 七、Box-Jenkins 方法论

Box-Jenkins（1970）建立的 ARIMA 建模三阶段方法论：

### 7.1 第一阶段：模型识别（Identification）

**步骤 1 — 确定差分阶数 $d$：**
- 绘制时序图，观察趋势
- ADF 检验判断平稳性
- 若 ACF 衰减极慢（长期不趋于零），提示非平稳，需要差分
- 逐步差分直到序列平稳

**步骤 2 — 确定 $p$ 和 $q$：**
- 观察差分后序列的 ACF 和 PACF 图
- 参考上节截尾/拖尾特征表
- 配合信息准则（AIC/BIC）辅助决策

**步骤 3 — 考虑乘法季节性模型：**

$$(1 - B^s)(1 - B) X_t \approx WN$$

### 7.2 第二阶段：参数估计（Estimation）

**条件最小二乘（CLS）：**

$$\hat{\theta} = \arg\min_{\theta} \sum_{t=1}^{n} \varepsilon_t^2(\theta)$$

利用递推关系，在给定初始值的条件下，依次计算残差 $\varepsilon_t(\theta)$。

**极大似然估计（MLE）：**

对于高斯 ARMA(p, q) 模型，似然函数为：

$$L(\phi, \theta, \sigma^2) = (2\pi\sigma^2)^{-n/2} \exp\left(-\frac{1}{2\sigma^2} \sum_{t=1}^{n} \varepsilon_t^2\right)$$

对数似然：

$$\ell = -\frac{n}{2}\ln(2\pi\sigma^2) - \frac{1}{2\sigma^2}\sum_{t=1}^{n} \varepsilon_t^2$$

最大化 $\ell$ 等价于最小化残差平方和。对 $\sigma^2$ 集中后：

$$\hat{\sigma}^2 = \frac{1}{n}\sum_{t=1}^{n} \varepsilon_t^2(\phi, \theta)$$

代入得集中对数似然函数，用数值优化（如 BFGS、Nelder-Mead）求解。

### 7.3 第三阶段：模型诊断（Diagnostic Checking）

**残差检验（白噪声检验）：**

模型残差 $\{\hat{\varepsilon}_t\}$ 应近似为白噪声。若残差存在自相关，说明模型未充分捕获序列结构，需重新指定阶数。

---

## 八、ADF 检验

### 8.1 检验原理

**假设：**
- $H_0$：序列存在单位根（非平稳）
- $H_1$：序列平稳（无单位根）

### 8.2 三种形式

**无截距无趋势：**

$$\Delta X_t = \gamma X_{t-1} + \sum_{i=1}^{p} \delta_i \Delta X_{t-i} + \varepsilon_t$$

**有截距：**

$$\Delta X_t = \alpha + \gamma X_{t-1} + \sum_{i=1}^{p} \delta_i \Delta X_{t-i} + \varepsilon_t$$

**有截距有趋势：**

$$\Delta X_t = \alpha + \beta t + \gamma X_{t-1} + \sum_{i=1}^{p} \delta_i \Delta X_{t-i} + \varepsilon_t$$

检验统计量 $ADF = \dfrac{\hat{\gamma}}{SE(\hat{\gamma})}$，与 Dickey-Fuller 分布比较（非标准分布，需查特殊临界值表）。

### 8.3 滞后阶数 $p$ 的选择

通过 AIC 或 BIC 自动选择，或设定最大滞后阶数 $p_{\max} = \lfloor 12 \cdot (n/100)^{1/4} \rfloor$（Schwert 规则）。

### 8.4 互补性检验

**KPSS 检验：** 与 ADF 互补，其原假设为**序列平稳**。若 ADF 拒绝 $H_0$（单位根），而 KPSS 不拒绝 $H_0$（平稳），则结论一致——序列平稳。建议同时进行两种检验。

---

## 九、Ljung-Box 检验

### 9.1 检验统计量

检验一系列残差自相关系数是否联合为零：

$$Q(m) = n(n + 2)\sum_{k=1}^{m} \frac{\hat{\rho}_k^2}{n - k}$$

其中 $\hat{\rho}_k$ 为残差的第 $k$ 阶样本自相关系数。

### 9.2 分布

在残差为白噪声的原假设下：

$$Q(m) \sim \chi^2(m - p - q)$$

自由度须扣除估计的参数个数。若 $Q(m)$ 的 p 值大于显著性水平（如 0.05），则残差可视为白噪声。

### 9.3 修正：Box-Pierce 检验

$$Q_{BP}(m) = n \sum_{k=1}^{m} \hat{\rho}_k^2$$

Ljung-Box 是对 Box-Pierce 的小样本修正，更常用。

---

## 十、季节性 SARIMA 模型

### 10.1 SARIMA(p, d, q)(P, D, Q)$_s$

$$\Phi_P(B^s)\,\Phi(B)\,(1 - B^s)^D\,(1 - B)^d\,X_t = c + \Theta_Q(B^s)\,\Theta(B)\,\varepsilon_t$$

其中：
- $s$：季节周期（月度 $s=12$，季度 $s=4$）
- $p,d,q$：非季节性阶数
- $P,D,Q$：季节性阶数
- $\Phi_P(B^s) = 1 - \Phi_1 B^s - \Phi_2 B^{2s} - \cdots - \Phi_P B^{Ps}$
- $\Theta_Q(B^s) = 1 + \Theta_1 B^s + \Theta_2 B^{2s} + \cdots + \Theta_Q B^{Qs}$

### 10.2 季节模型识别

季节性 AR 或 MA 项在 ACF/PACF 图中表现为在滞后 $s, 2s, 3s, \ldots$ 处的峰值。例如：
- $P=1$（SAR(1)）：PACF 在 $s$ 处截尾，ACF 在 $s, 2s, \ldots$ 处拖尾
- $Q=1$（SMA(1)）：ACF 在 $s$ 处截尾，PACF 在 $s, 2s, \ldots$ 处拖尾

### 10.3 季节差分

以月度数据为例，若存在年度季节性，先做周期 12 的差分：

$$\nabla_{12} X_t = (1 - B^{12}) X_t = X_t - X_{t-12}$$

若趋势和季节同时存在，需同时做一阶差分和季节差分。

---

## 十一、模型选择准则

### 11.1 AIC（Akaike 信息准则）

$$AIC = -2\ln L + 2k$$

其中：
- $L$：模型的最大似然值
- $k$：模型中自由参数的总个数

AIC 衡量模型的信息损失：首项 $-2\ln L$ 衡量拟合优度，第二项 $2k$ 惩罚复杂度。**AIC 越小越好。**

### 11.2 BIC（贝叶斯信息准则）

$$BIC = -2\ln L + k \ln n$$

其中 $n$ 为样本量。BIC 对参数个数的惩罚比 AIC 更重（当 $n > 8$ 时），倾向于选择更简洁的模型。

### 11.3 AIC 与 BIC 的比较

| 准则 | 惩罚项 | 性质 | 适用场景 |
|:---:|:---:|:---|:---|
| AIC | $2k$ | 渐近最小化预测误差 | 短期预测 |
| BIC | $k\ln n$ | 相合性（$n\to\infty$ 选对概率→1） | 识别真实模型 |
| AICc | $2k + \frac{2k(k+1)}{n-k-1}$ | AIC 的小样本修正 | 小样本 |

### 11.4 网格搜索

实际建模中，对 $(p, d, q)$ 在一组候选范围内（如 $p \in \{0,\ldots,4\}, d \in \{0,\ldots,2\}, q \in \{0,\ldots,4\}$）进行网格搜索，选择 AIC 或 BIC 最小的组合。

```python
import itertools
best_aic = float('inf')
best_order = None

for p, d, q in itertools.product(range(5), range(3), range(5)):
    if p == 0 and q == 0:
        continue
    try:
        model = ARIMA(data, order=(p, d, q))
        fit = model.fit()
        if fit.aic < best_aic:
            best_aic = fit.aic
            best_order = (p, d, q)
    except:
        continue
```

### 11.5 模型平均

当多个模型 AIC 相近（$\Delta AIC < 2$）时，单一模型选择的不确定性较大。此时可考虑 AIC 权重进行加权平均：

$$w_i = \frac{\exp(-\Delta AIC_i / 2)}{\sum_j \exp(-\Delta AIC_j / 2)}$$

---

## 十二、ARIMA 模型的局限性

### 12.1 线性假设

ARIMA 模型假设序列由线性差分方程产生，无法捕获非线性动态。替代方案：
- 非线性 AR 模型（NAR）
- 门限自回归（TAR）
- ARCH/GARCH（异方差）

### 12.2 对异常值敏感

异常观测值（outliers）会显著影响 ACF/PACF 估计和模型拟合。需在建模前进行异常值检测和处理（如 additive outlier / innovational outlier 检测）。

### 12.3 结构突变

若序列存在结构断点（均值漂移、趋势变化等），ARIMA 模型难以自动适应。需结合断点检测方法（如 Chow 检验、Bai-Perron 方法）。

### 12.4 预测区间发散

长期预测的置信区间随预测步长 $h$ 增加而发散：

$$\text{Var}(X_{n+h} \mid X_1,\ldots,X_n) = \sigma^2 \sum_{i=0}^{h-1} \psi_i^2$$

其中 $\psi$ 权重来自 MA($\infty$) 表示。

---

## 十三、相关参考

- [[./指数平滑与组合预测|指数平滑与组合预测]] — 对 ARIMA(0,1,1) 的特例
- [[../《时间序列分析》/../ODE常微分方程|暂无链接]]
- Box, G. E. P., Jenkins, G. M., Reinsel, G. C., & Ljung, G. M. (2015). *Time Series Analysis: Forecasting and Control* (5th ed.). Wiley.
- Hamilton, J. D. (1994). *Time Series Analysis*. Princeton University Press.
