##  1. 定义 (Definition)

对于一个定义在 $t \ge 0$ 上的函数 $f(t)$，其 Laplace 变换 $\mathcal{L}\{f(t)\}$ 定义为：

$$F(s) = \mathcal{L}\{f(t)\} = \int_{0}^{\infty} e^{-st} f(t) dt$$

其中：

- $s$ 是一个复变量，通常写作 $s = \sigma + i\omega$。
    
- $\sigma$ 必须足够大，使得积分收敛（$f(t)$ 必须是指数级增长的）。
    

---

##  2. 重要性质 (Key Properties)

Laplace 变换之所以有用，是因为它具有许多简化运算的性质，特别是将微积分运算转化为代数运算：

|**性质名称**|**时域 f(t)**|**s 域 F(s)=L{f(t)}**|
|---|---|---|
|**线性性**|$af(t) + bg(t)$|$aF(s) + bG(s)$|
|**微分**|$f'(t)$|$sF(s) - f(0)$|
|**二次微分**|$f''(t)$|$s^2F(s) - sf(0) - f'(0)$|
|**积分**|$\int_{0}^{t} f(\tau) d\tau$|$\frac{1}{s}F(s)$|
|**时移 (Time Shift)**|$f(t-a)u(t-a)$|$e^{-as}F(s)$ (其中 $a>0$)|
|**$s$ 域微分**|$t f(t)$|$-\frac{d}{ds}F(s)$|
|**卷积**|$(f * g)(t) = \int_{0}^{t} f(\tau)g(t-\tau) d\tau$|$F(s)G(s)$|

---

##  3. 常见函数的 Laplace 变换对

| **编号** | **时域函数 f(t) (t≥0)**                      | **s 域函数 F(s)=L{f(t)}**              | **收敛域 (ROC)**                     |
| ------ | ---------------------------------------- | ----------------------------------- | --------------------------------- |
| 1      | **单位冲激函数** $\delta(t)$                   | $1$                                 | 所有 $s$                            |
| 2      | **单位阶跃函数** $u(t)$                        | $\frac{1}{s}$                       | $\text{Re}\{s\} > 0$              |
| 3      | **常数** $C$                               | $\frac{C}{s}$                       | $\text{Re}\{s\} > 0$              |
| 4      | **指数函数** $e^{at}$                        | $\frac{1}{s-a}$                     | $\text{Re}\{s\} > \text{Re}\{a\}$ |
| 5      | **幂函数** $t^n$ ($n=1, 2, \dots$)          | $\frac{n!}{s^{n+1}}$                | $\text{Re}\{s\} > 0$              |
| 6      | **广义幂函数** $t^p$ ($p > -1$)               | $\frac{\Gamma(p+1)}{s^{p+1}}$       | $\text{Re}\{s\} > 0$              |
| 7      | **衰减幂函数** $t^n e^{at}$ ($n=1, 2, \dots$) | $\frac{n!}{(s-a)^{n+1}}$            | $\text{Re}\{s\} > \text{Re}\{a\}$ |
| 8      | **正弦函数** $\sin(\omega t)$                | $\frac{\omega}{s^2 + \omega^2}$     | $\text{Re}\{s\} > 0$              |
| 9      | **余弦函数** $\cos(\omega t)$                | $\frac{s}{s^2 + \omega^2}$          | $\text{Re}\{s\} > 0$              |
| 10     | **双曲正弦** $\sinh(\omega t)$               | $\frac{\omega}{s^2 - \omega^2}$     | $\text{Re}{s} >                   |
| 11     | **双曲余弦** $\cosh(\omega t)$               | $\frac{s}{s^2 - \omega^2}$          | $\text{Re}{s} >                   |
| 12     | **衰减正弦** $e^{at}\sin(\omega t)$          | $\frac{\omega}{(s-a)^2 + \omega^2}$ | $\text{Re}\{s\} > \text{Re}\{a\}$ |
| 13     | **衰减余弦** $e^{at}\cos(\omega t)$          | $\frac{s-a}{(s-a)^2 + \omega^2}$    | $\text{Re}\{s\} > \text{Re}\{a\}$ |

---

### **符号说明：**

- $u(t)$：单位阶跃函数（$t \ge 0$ 时为 1， $t < 0$ 时为 0）。
    
- $\delta(t)$：狄拉克单位冲激函数。
    
- $n!$：$n$ 的阶乘。
    
- $\Gamma(z)$：伽马函数，对于正整数 $n$，有 $\Gamma(n+1) = n!$。
    
- $\text{Re}\{s\}$：复变量 $s$ 的实部。

---

##  4. 应用 (Applications)

Laplace 变换在工程和科学领域有广泛的应用，最主要的用途是：

1. **求解常系数线性微分方程：** 这是最主要的用途。通过 Laplace 变换，微分方程被转换为 $s$ 域的**代数方程**，解出 $F(s)$ 后再通过**逆 Laplace 变换** $\mathcal{L}^{-1}$ 得到原函数 $f(t)$。
    
2. **系统分析（控制论）：** 在控制工程和电路分析中，Laplace 变换用于描述系统的**传递函数** $G(s)$，这极大地简化了系统对不同输入的响应分析。
    

---

##  5. 逆 Laplace 变换 (Inverse Laplace Transform)

要从 $F(s)$ 得到原始函数 $f(t)$，我们需要使用逆 Laplace 变换 $\mathcal{L}^{-1}$：

$$f(t) = \mathcal{L}^{-1}\{F(s)\} = \frac{1}{2\pi i} \int_{\sigma-i\infty}^{\sigma+i\infty} e^{st} F(s) ds$$

在实际应用中，通常**避免使用复杂的复积分**，而是通过**查表**或使用**部分分式展开**配合表格来找到逆变换。

$\frac{2}{(s^4+1)(s-1)}$