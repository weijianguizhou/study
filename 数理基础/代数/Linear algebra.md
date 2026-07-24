# 线性代数 Linear Algebra（含详细推导）

> 参考教材：[Linear Algebra Done Right (Sheldon Axler, 4th Ed.)]、[Linear Algebra (M. Thamban Nair & Arindama Singh, Springer 2018)]、[Matrix Analysis and Applied Linear Algebra (Carl D. Meyer, SIAM)]

---

# 第一章 向量空间 Vector Spaces

## 1.1 向量空间的定义

**向量空间** $V$ 是一个非空集合，定义于数域 $\mathbb{F}$ 上，配有两种运算：
- **加法**：$(x,y) \mapsto x+y \in V$
- **标量乘法**：$(\alpha, x) \mapsto \alpha x \in V$

满足八条公理：

| 公理 | 名称 | 内容 |
|------|------|------|
| (1) | 加法交换律 | $x + y = y + x$ |
| (2) | 加法结合律 | $(x + y) + z = x + (y + z)$ |
| (3) | 加法单位元 | $\exists 0 \in V,\; x + 0 = x$ |
| (4) | 加法逆元 | $\exists (-x) \in V,\; x + (-x) = 0$ |
| (5) | 标量分配律(向量) | $\alpha(x + y) = \alpha x + \alpha y$ |
| (6) | 标量分配律(标量) | $(\alpha + \beta)x = \alpha x + \beta x$ |
| (7) | 标量结合律 | $(\alpha\beta)x = \alpha(\beta x)$ |
| (8) | 标量单位元 | $1x = x$ |

### 定理：零向量唯一

**证明**（标准手法——利用零向量的定义相互代入）：

设 $0$ 和 $\tilde{0}$ 都是零向量。由公理(3)：对任意 $x \in V$，$x + 0 = x$ 且 $x + \tilde{0} = x$。

取 $x = \tilde{0}$ 代入第一个等式：$\tilde{0} + 0 = \tilde{0}$。
取 $x = 0$ 代入第二个等式：$0 + \tilde{0} = 0$。
由公理(1)加法交换律：$\tilde{0} + 0 = 0 + \tilde{0}$。
联立得：$\tilde{0} = \tilde{0} + 0 = 0 + \tilde{0} = 0$。即零向量唯一。$\square$

### 定理：加法逆元唯一

**证明**：设 $x'$ 和 $\tilde{x}$ 都是 $x$ 的加法逆元，即 $x + x' = 0$ 且 $x + \tilde{x} = 0$。则：

$$
\begin{aligned}
\tilde{x} &= \tilde{x} + 0 && \text{(公理3)} \\
&= \tilde{x} + (x + x') && \text{(x' 为逆元)} \\
&= (\tilde{x} + x) + x' && \text{(公理2 结合律)} \\
&= (x + \tilde{x}) + x' && \text{(公理1 交换律)} \\
&= 0 + x' && \text{($\tilde{x}$ 为逆元)} \\
&= x' + 0 && \text{(公理1 交换律)} \\
&= x' && \text{(公理3)}
\end{aligned}
$$

故加法逆元唯一。以后称 $x$ 的加法逆元为 $-x$。$\square$

### 关键例子

| 向量空间 | 记法 | 说明 |
|----------|------|------|
| $n$ 元数组空间 | $\mathbb{F}^n$ | $\{(a_1,\ldots,a_n) : a_i \in \mathbb{F}\}$，分量加法 |
| 矩阵空间 | $\mathbb{F}^{m \times n}$ | $m \times n$ 矩阵，元素加法 |
| 多项式空间 | $\mathcal{P}_n(\mathbb{F})$ | 次数 $\leq n$ 的多项式 |
| 全体多项式 | $\mathcal{P}(\mathbb{F})$ | 任意次数多项式 |
| 序列空间 | $\mathbb{F}^\infty$ | 所有标量序列 |
| 函数空间 | $\mathcal{F}(S,\mathbb{F})$ | $S \to \mathbb{F}$ 的函数 |

---

## 1.2 子空间

**子空间**：$U \subseteq V$ 在 $V$ 的运算下自身构成向量空间。

**子空间判定定理**：$U \subseteq V$ 是子空间当且仅当：
1. $0 \in U$（非空，含零）
2. $u, v \in U \Rightarrow u + v \in U$（加法封闭）
3. $\alpha \in \mathbb{F}, u \in U \Rightarrow \alpha u \in U$（标量乘封闭）

**证明**（必要性显然，证充分性）：

只需验证 $U$ 满足八条公理。公理(1)(2)(5)(6)(7)(8)自动从 $V$ 继承（$U$ 的运算就是 $V$ 中运算的限制）。条件 1 保证公理(3)（零在 $U$）。对任意 $u \in U$，取 $\alpha = -1$，由条件 3 知 $(-1)u \in U$，而 $(-1)u = -u$ 是 $u$ 的逆元（从 $V$ 继承），故公理(4)成立。$\square$

### 子空间的交与和
- $U \cap W$ **是**子空间——对交中任意两元素及其线性组合，它们同时属于 $U$ 和 $W$，因而属于交。
- $U + W = \{u + w : u \in U, w \in W\}$ **是**子空间——由于 $U$ 和 $W$ 各自对加法和标量乘封闭。
- $U \cup W$ **通常不是**子空间——如 $\mathbb{R}^2$ 中 $x$ 轴与 $y$ 轴：$(1,0) + (0,1) = (1,1)$ 不属于并集。

### 直和 (Direct Sum)

若 $U \cap W = \{0\}$，称 $U + W$ 为**直和**，记作 $U \oplus W$。

**表征定理**：以下三条等价：
- (a) $U + W$ 是直和
- (b) $U \cap W = \{0\}$
- (c) 每 $v \in U+W$ 可**唯一**表为 $v = u + w$（$u \in U, w \in W$）

**证明 (a)$\iff$(b)**：由定义。**(b)$\Rightarrow$(c)**：设 $v = u_1 + w_1 = u_2 + w_2$，则 $u_1 - u_2 = w_2 - w_1$。左边属 $U$，右边属 $W$，由(b)知两边均为 $0$，故 $u_1 = u_2$，$w_1 = w_2$。**(c)$\Rightarrow$(b)**：若 $x \in U \cap W$，则 $x = x + 0 = 0 + x$ 给出 $x$ 的两种分解，由唯一性 $x = 0$。$\square$

---

## 1.3 线性生成、线性无关、基与维数

### 线性组合与生成

向量 $v$ 是 $\{v_1,\ldots,v_m\}$ 的**线性组合**若 $v = \alpha_1 v_1 + \cdots + \alpha_m v_m$。

**生成空间**：$\operatorname{span}\{v_1,\ldots,v_m\} = \{\sum \alpha_i v_i : \alpha_i \in \mathbb{F}\}$

**生成空间是子空间的验证**：$0 = \sum 0 \cdot v_i \in \operatorname{span}$；对 $\sum \alpha_i v_i, \sum \beta_i v_i$，其和 $\sum (\alpha_i + \beta_i)v_i \in \operatorname{span}$；$\lambda\sum \alpha_i v_i = \sum (\lambda\alpha_i)v_i \in \operatorname{span}$。

### 线性无关与线性相关

**定义**：$\{v_1,\ldots,v_m\}$ **线性无关**若 $\alpha_1 v_1 + \cdots + \alpha_m v_m = 0 \implies \alpha_1 = \cdots = \alpha_m = 0$。
否则为**线性相关**。

**引理**：$\{v_1,\ldots,v_m\}$ 线性相关 $\iff$ 其中某向量可表为其余向量的线性组合。

**证明**：
($\Rightarrow$) 设 $\sum \alpha_i v_i = 0$ 且 $\alpha_k \neq 0$，则 $v_k = -\sum_{i \neq k} (\alpha_i/\alpha_k) v_i$。
($\Leftarrow$) 若 $v_k = \sum_{i \neq k} \beta_i v_i$，则 $\sum_{i \neq k} \beta_i v_i + (-1)v_k = 0$，系数不全为零。$\square$

### 基

**基**：线性无关 + 生成 $V$。

### 基等价定理（维数不变性）

**定理**：若 $V$ 有一组 $n$ 元素基，则 $V$ 中任意 $n+1$ 个向量线性相关。

**证明**（对 $n$ 归纳，这是线性代数中最核心的论证之一）：

$n = 1$：基为 $\{v_1\}$。任取 $\{w_1, w_2\}$，有 $w_1 = a_1 v_1$，$w_2 = a_2 v_1$。若 $a_1 = 0$ 则 $w_1 = 0$ 线性相关；否则 $w_2 - (a_2/a_1)w_1 = 0$ 线性相关。

假设定理对 $n-1$ 成立。设 $V$ 有基 $B = \{v_1,\ldots,v_n\}$，取 $W = \{w_1,\ldots,w_{n+1}\} \subseteq V$。

将每 $w_j$ 用基表出：$w_j = \sum_{i=1}^n a_{ij} v_i$。若对所有 $j$，$a_{1j} = 0$，则 $W \subseteq \operatorname{span}\{v_2,\ldots,v_n\}$，而 $\operatorname{span}\{v_2,\ldots,v_n\}$ 维数 $\leq n-1$，由归纳假设 $W$ 线性相关。

否则存在某 $w_k$ 且 $a_{1k} \neq 0$。定义 $u_j = w_j - (a_{1j}/a_{1k}) w_k$（$j \neq k$）。则 $u_j$ 中 $v_1$ 的系数为 0，故每 $u_j \in \operatorname{span}\{v_2,\ldots,v_n\}$。这 $n$ 个向量 $\{u_j\}_{j \neq k}$ 在维数 $\leq n-1$ 的空间中，由归纳假设线性相关。从而存在不全为零的 $\beta_j$ 使 $\sum_{j \neq k} \beta_j u_j = 0$。代入 $u_j$ 定义：

$$
\sum_{j \neq k} \beta_j w_j - \left(\sum_{j \neq k} \beta_j \frac{a_{1j}}{a_{1k}}\right) w_k = 0
$$

这是 $w_1,\ldots,w_{n+1}$ 的系数不全为零（至少一个 $\beta_j \neq 0$）的线性组合为零，故 $W$ 线性相关。$\square$

**推论**：$V$ 中任意两组基具有相同个数。$\therefore$ $\dim V$ 的定义是良定的。

### 子空间维数公式

$$
\dim(U + W) = \dim U + \dim W - \dim(U \cap W)
$$

**推导**：设 $\{x_1,\ldots,x_k\}$ 是 $U \cap W$ 的基（$k = \dim(U \cap W)$）。将其分别扩充为 $U$ 的基 $\{x_1,\ldots,x_k, u_1,\ldots,u_m\}$ 和 $W$ 的基 $\{x_1,\ldots,x_k, w_1,\ldots,w_n\}$。其中 $\dim U = k+m$，$\dim W = k+n$。

**断言**：$\{x_1,\ldots,x_k, u_1,\ldots,u_m, w_1,\ldots,w_n\}$ 是 $U+W$ 的基。

**生成**：任意 $v \in U+W$ 可写 $v = u + w$。$u$ 可表为 $\{x_i,u_j\}$ 的线性组合，$w$ 可表为 $\{x_i,w_l\}$ 的线性组合，合并即得。

**线性无关**：设 $\sum \alpha_i x_i + \sum \beta_j u_j + \sum \gamma_l w_l = 0$。则
$$
\sum \gamma_l w_l = -\sum \alpha_i x_i - \sum \beta_j u_j \in U
$$
但 $\sum \gamma_l w_l \in W$，故 $\sum \gamma_l w_l \in U \cap W = \operatorname{span}\{x_i\}$。又 $\{x_i,w_l\}$ 是 $W$ 的基，所以 $\sum \gamma_l w_l = \sum \delta_i x_i$，从而 $\sum \gamma_l w_l - \sum \delta_i x_i = 0$。由 $\{x_i,w_l\}$ 线性无关得所有 $\gamma_l = 0$ 和 $\delta_i = 0$。代回原式得 $\sum \alpha_i x_i + \sum \beta_j u_j = 0$，由 $\{x_i,u_j\}$ 线性无关得所有 $\alpha_i = \beta_j = 0$。

因此该集合是基，维数为 $k+m+n = \dim U + \dim W - \dim(U \cap W)$。$\square$

---

## 1.4 商空间

**商空间** $V/U = \{v + U : v \in V\}$。运算：
- $(v + U) + (w + U) = (v + w) + U$
- $\alpha(v + U) = \alpha v + U$

**维数公式推导**：$\dim(V/U) = \dim V - \dim U$。

设 $u_1,\ldots,u_k$（$k = \dim U$）为 $U$ 的基，扩充为 $V$ 的基 $u_1,\ldots,u_k, v_1,\ldots,v_m$（$k+m = \dim V$）。则 $\{v_1+U, \ldots, v_m+U\}$ 是 $V/U$ 的基：
- **生成**：对 $v+U \in V/U$，$v = \sum \alpha_i u_i + \sum \beta_j v_j$，故 $v + U = \sum \beta_j (v_j + U)$。
- **线性无关**：若 $\sum \beta_j (v_j+U) = 0+U$，则 $\sum \beta_j v_j \in U$，可表为 $u_i$ 的组合，与 $\{u_i, v_j\}$ 线性无关矛盾（除非所有 $\beta_j = 0$）。

$\dim(V/U) = m = \dim V - \dim U$。$\square$

---

# 第二章 线性映射 Linear Maps

## 2.1 定义

$T: V \to W$ 是**线性映射**若：
- $T(u + v) = T(u) + T(v)$
- $T(\alpha v) = \alpha T(v)$

全体 $V \to W$ 的线性映射构成向量空间 $\mathcal{L}(V,W)$。

## 2.2 秩-零度定理（线性映射基本定理）

$$
\dim V = \dim \ker T + \dim \operatorname{im} T
$$

**推导**（构造基的手法）：

设 $\dim V = n$，$\dim \ker T = k$。取 $\ker T$ 的基 $\{u_1,\ldots,u_k\}$，将其扩充为 $V$ 的基 $\{u_1,\ldots,u_k, v_1,\ldots,v_{n-k}\}$。

**断言**：$\{T v_1, \ldots, T v_{n-k}\}$ 是 $\operatorname{im} T$ 的基。

**生成**：对任意 $Tv \in \operatorname{im} T$，$v = \sum \alpha_i u_i + \sum \beta_j v_j$。则
$$Tv = \sum \alpha_i T u_i + \sum \beta_j T v_j = \sum \beta_j T v_j \quad (\because Tu_i = 0)$$
可见 $\{Tv_j\}$ 生成 $\operatorname{im} T$。

**线性无关**：设 $\sum \beta_j T v_j = 0$，即 $T(\sum \beta_j v_j) = 0$，故 $\sum \beta_j v_j \in \ker T$。用 $\ker T$ 的基表出：$\sum \beta_j v_j = \sum \alpha_i u_i$，即 $\sum \beta_j v_j - \sum \alpha_i u_i = 0$。由 $\{u_i, v_j\}$ 线性无关得所有 $\beta_j = 0$。

因此 $\dim \operatorname{im} T = n-k = \dim V - \dim \ker T$。$\square$

- $T$ 单射 $\iff \ker T = \{0\}$：若 $T$ 单且 $Tv = 0 = T0$，则 $v = 0$；反方向，若 $\ker T = \{0\}$ 且 $Tv = Tw$，则 $T(v-w) = 0$，$v-w \in \ker T$，$v = w$。
- $T$ 满射 $\iff \operatorname{im} T = W$：由定义。

## 2.3 基变换公式的推导

若 $B = \{v_1,\ldots,v_n\}$ 和 $B' = \{v_1',\ldots,v_n'\}$ 是 $V$ 的两组基。对每 $k$，$v_k'$ 可用 $B$ 表出：
$$v_k' = \sum_{i=1}^n p_{ik} v_i$$

矩阵 $P = (p_{ik})$ 称为**过渡矩阵**（$B$ 到 $B'$）。$P$ 可逆，因为 $B'$ 也线性无关。

任取 $v \in V$，设 $v = \sum x_i v_i = \sum x_k' v_k'$。则有：
$$\sum x_k' v_k' = \sum_k x_k' \sum_i p_{ik} v_i = \sum_i \left(\sum_k p_{ik} x_k'\right) v_i$$

与 $\sum x_i v_i$ 比较得 $x_i = \sum_k p_{ik} x_k'$，即 $\mathbf{x} = P \mathbf{x}'$，或 $\mathbf{x}' = P^{-1} \mathbf{x}$。

对线性映射 $T$，设 $A = \mathcal{M}_B(T)$，$A' = \mathcal{M}_{B'}(T)$。对任意 $v \in V$：
$$
\begin{aligned}
\mathcal{M}_B(Tv) &= A \cdot \mathbf{x} \\
\mathcal{M}_{B'}(Tv) &= A' \cdot \mathbf{x}'
\end{aligned}
$$

又 $\mathcal{M}_{B'}(Tv) = P^{-1} \mathcal{M}_B(Tv) = P^{-1} A \mathbf{x} = P^{-1} A P \mathbf{x}'$，故：
$$
A' = P^{-1} A P
$$

## 2.4 四大基本子空间

对 $A \in \mathbb{F}^{m \times n}$：

| 子空间 | 记法 | 定义 | 所在空间 |
|--------|------|------|----------|
| 列空间 | $\mathcal{C}(A)$ | $\{Ax : x \in \mathbb{F}^n\}$ | $\mathbb{F}^m$ |
| 行空间 | $\mathcal{R}(A)$ | $\{A^{\top} y : y \in \mathbb{F}^m\}$ | $\mathbb{F}^n$ |
| 零空间 | $\mathcal{N}(A)$ | $\{x : Ax = 0\}$ | $\mathbb{F}^n$ |
| 左零空间 | $\mathcal{N}(A^{\top})$ | $\{y : A^{\top} y = 0\}$ | $\mathbb{F}^m$ |

### 秩相等定理

$\operatorname{rank}(A) = \operatorname{rank}(A^{\top})$。

**推导思路**：将 $A$ 化为行阶梯形 $R$。$A$ 的行秩 = $R$ 的主元个数；同时 $A$ 的列秩 = 主元所在列对应的 $A$ 的列数。两者均等于主元个数，故等。

### 正交补关系

在标准内积下：$\mathcal{C}(A)^\perp = \mathcal{N}(A^{\top})$。

**证明**：$y \in \mathcal{N}(A^{\top}) \iff A^{\top}y = 0 \iff \forall x, \langle y, Ax \rangle = (Ax)^{\top} y = x^{\top} A^{\top} y = 0 \iff y \perp \mathcal{C}(A)$。

同理 $\mathcal{N}(A)^\perp = \mathcal{R}(A)$。

### 秩+零度

由正交补关系：$\dim \mathcal{N}(A) + \dim \mathcal{R}(A) = n$，而 $\dim \mathcal{R}(A) = \operatorname{rank} A$，故：
$$\operatorname{rank} A + \dim \mathcal{N}(A) = n$$
这恰好是秩-零度定理的另一种表述。

---

# 第三章 初等运算与线性方程组

## 3.1 初等矩阵的推导

| 运算 | 初等矩阵 | 行列式 | 逆 |
|------|---------|--------|-----|
| $R_i \leftrightarrow R_j$ | $E_{ij}$（$I$ 中交换第 $i,j$ 行）| $-1$ | 自身 |
| $R_i \leftarrow \alpha R_i$ | $E_i(\alpha)$（$I$ 中第 $i$ 对角元 = $\alpha$）| $\alpha$ | $E_i(1/\alpha)$ |
| $R_i \leftarrow R_i + \alpha R_j$ | $E_{ij}(\alpha)$（$I$ 中 $(i,j)$ 位置 = $\alpha$）| $1$ | $E_{ij}(-\alpha)$ |

## 3.2 LU 分解推导

对 $n \times n$ 可逆矩阵 $A$，第 $k$ 步消元等价于左乘 $L_k$（下三角，记录第 $k$ 列下方的倍加系数）。消元完成后：
$$L_{n-1} \cdots L_2 L_1 A = U \quad (\text{上三角})$$

故 $A = L_1^{-1} L_2^{-1} \cdots L_{n-1}^{-1} U$。注意 $L_k^{-1} = E_{ij}(-\alpha)$ 仍为单位下三角矩阵，下三角矩阵的乘积仍为下三角，因此 $L = L_1^{-1} \cdots L_{n-1}^{-1}$ 是单位下三角矩阵。

$L$ 的第 $k$ 列（对角线下）就是第 $k$ 步消元倍加系数的负值。$A = LU$。

## 3.3 非齐次方程组解的结构

$Ax = b$ 有解 $\iff b \in \mathcal{C}(A)$。

若 $x_p$ 是一个特解，$x_h$ 是齐次通解（$Ax_h = 0$），则 $A(x_p + x_h) = Ax_p + 0 = b$，故通解 = $x_p + \mathcal{N}(A)$。

---

# 第四章 行列式 Determinants

## 4.1 行列式的定义与公理化特征

$$
\det A = \sum_{\sigma \in S_n} \operatorname{sgn}(\sigma) \, a_{1,\sigma(1)} a_{2,\sigma(2)} \cdots a_{n,\sigma(n)}
$$

行列式是唯一满足以下三条的函数：
- **多重线性**：对每一行是线性的
- **交错性**：两行相同则值为 0
- **规范化**：$\det I = 1$

## 4.2 基本性质推导

### 交换两行变号

设 $A'$ 为交换 $A$ 的 $r,s$ 行所得。

**推导**：将 $A$ 和 $A'$ 视为行向量组。考虑函数 $f(A,r,s) = \det(\cdots, a_r + a_s, \cdots, a_r + a_s, \cdots)$（在第 $r$ 行和第 $s$ 行都放 $a_r + a_s$）。由交错性 $f = 0$。
由多重线性展开：
$$0 = \det(\cdots, a_r, \cdots, a_r, \cdots) + \det(\cdots, a_r, \cdots, a_s, \cdots) + \det(\cdots, a_s, \cdots, a_r, \cdots) + \det(\cdots, a_s, \cdots, a_s, \cdots)$$

第一、四项为 0（重复行）。故 $\det(\cdots, a_s, \cdots, a_r, \cdots) = -\det(\cdots, a_r, \cdots, a_s, \cdots)$。$\square$

### 倍加不变性

$R_i \leftarrow R_i + \alpha R_j$（$i \neq j$）不改变行列式。

**推导**：由多重线性：
$$\det(\cdots, a_i + \alpha a_j, \cdots) = \det(\cdots, a_i, \cdots) + \alpha \det(\cdots, a_j, \cdots)$$
后一项 $\det(\cdots, a_j, \cdots, a_j, \cdots)$ 因两行相同 = 0。$\square$

### 乘法定理 $\det(AB) = \det A \cdot \det B$

**推导思路**（用初等矩阵和三角化）：

对于任意可逆矩阵 $A$，将其分解为初等矩阵之积 $A = E_1 E_2 \cdots E_k$。则需证 $\det(E_i B) = \det(E_i) \det(B)$ 对每类初等矩阵成立。

以倍加型 $E_{ij}(\alpha)$ 为例：$E_{ij}(\alpha)B$ 将 $B$ 的第 $i$ 行加上 $\alpha$ 倍第 $j$ 行。由倍加不变性，$\det(E_{ij}(\alpha)B) = \det B = 1 \cdot \det B = \det(E_{ij}(\alpha)) \det(B)$。

类似验证交换型和倍乘型。然后逐次累乘得 $\det(AB) = \det(E_1 \cdots E_k B) = \det E_1 \cdots \det E_k \det B = \det A \det B$。

对奇异 $A$：$\det A = 0$。若 $\det(AB) \neq 0$ 则 $AB$ 可逆，从而 $A = (AB)B^{-1}$ 可逆，矛盾。故 $\det(AB) = 0 = \det A \det B$。$\square$

### 转置不变性 $\det(A^{\top}) = \det A$

由定义：$\det A = \sum_{\sigma} \operatorname{sgn}(\sigma) \prod_i a_{i,\sigma(i)}$。由于 $\sigma \mapsto \sigma^{-1}$ 是 $S_n$ 的双射且 $\operatorname{sgn}(\sigma) = \operatorname{sgn}(\sigma^{-1})$：
$$\det A^{\top} = \sum_{\sigma} \operatorname{sgn}(\sigma) \prod_i a_{\sigma(i), i} = \sum_{\sigma} \operatorname{sgn}(\sigma^{-1}) \prod_j a_{j, \sigma^{-1}(j)} = \det A$$

---

## 4.3 Cramer 法则推导

$Ax = b$，记 $A$ 的列为 $a_1,\ldots,a_n$。则 $b = \sum x_j a_j$。

考虑 $\det(a_1,\ldots,a_{i-1}, b, a_{i+1},\ldots,a_n)$：
$$
\begin{aligned}
&= \det(a_1,\ldots,a_{i-1}, \sum_{j} x_j a_j, a_{i+1},\ldots,a_n) \\
&= \sum_j x_j \det(a_1,\ldots,a_{i-1}, a_j, a_{i+1},\ldots,a_n)
\end{aligned}
$$

当 $j \neq i$，第 $j$ 列出现两次 $\implies$ 行列式 = 0。仅 $j = i$ 项非零：
$$= x_i \det(a_1,\ldots,a_{i-1}, a_i, a_{i+1},\ldots,a_n) = x_i \det A$$

因此 $x_i = \dfrac{\det A_i}{\det A}$，其中 $A_i$ 为 $A$ 第 $i$ 列换为 $b$。$\square$

---

## 4.4 Jacobi 公式推导

$\frac{d}{dx} \det A(x) = \det A(x) \cdot \operatorname{tr}(A^{-1} \frac{dA}{dx})$。

**推导**：对 $n$ 阶矩阵 $A(x)$，用行列式的多重线性。对于第 $k$ 列，将其视为关于 $x$ 的函数进行微分（按列的导数规则）：

$$\frac{d}{dx} \det A(x) = \sum_{j=1}^n \det(a_1,\ldots, a_{j-1}, \frac{da_j}{dx}, a_{j+1},\ldots, a_n)$$

由 Cramer 法则（逆矩阵的列表示）：$A^{-1}$ 的第 $j$ 列 $= \dfrac{1}{\det A}(\cdots, C_{ij}, \cdots)^{\top}$。利用伴随矩阵展开上式，得到：

$$\frac{d}{dx} \det A = \sum_{i,j} \frac{\partial \det A}{\partial a_{ij}} \frac{da_{ij}}{dx} = \sum_{i,j} C_{ij} \frac{da_{ij}}{dx}$$

其中 $C_{ij}$ 为代数余子式（$\operatorname{adj}(A)^{\top}$ 的 $(i,j)$ 元）。而 $C_{ij} = (\det A)(A^{-1})_{ji}$，因此：

$$\frac{d}{dx} \det A = \det A \sum_{i,j} (A^{-1})_{ji} \frac{da_{ij}}{dx} = \det A \cdot \operatorname{tr}\!\left(A^{-1} \frac{dA}{dx}\right)$$

其中最后一步用了迹的定义 $\operatorname{tr}(XY) = \sum_{i,j} X_{ji} Y_{ij}$。$\square$

---

# 第五章 特征值与特征向量

## 5.1 特征多项式与特征方程

$Tv = \lambda v \iff (T - \lambda I)v = 0$，$v \neq 0$。

这意味着 $T - \lambda I$ 不可逆（有非零核），$\iff \det(T - \lambda I) = 0$。

因此定义**特征多项式** $p(\lambda) = \det(A - \lambda I)$。$\lambda$ 是特征值 $\iff p(\lambda) = 0$。

### 特征多项式展开

$$
p(\lambda) = \det(A - \lambda I) = (-1)^n \lambda^n + (-1)^{n-1}(\operatorname{tr} A) \lambda^{n-1} + \cdots + \det A
$$

**推导**（$(-1)^{n-1} \operatorname{tr} A$ 系数的由来）：

按行列式定义，选取对角线元素 $a_{ii} - \lambda$ 对乘积贡献最多。$\lambda^{n-1}$ 的项来自：选取 $n-1$ 个对角元 $(a_{ii} - \lambda)$ 和 1 个非对角元。非对角元选在 $(i,j)$ 位置（$i \neq j$）时，必须同时选 $(j,i)$ 以形成非零循环——但这对应排列含对换，符号为负。实际上，展开式中 $\lambda^{n-1}$ 的总系数为 $(-1)^{n-1} \sum_i a_{ii} = (-1)^{n-1} \operatorname{tr} A$。

## 5.2 几何重数公式推导

几何重数 $GM = \dim E_\lambda = \dim \ker(A - \lambda I)$。

由秩-零度定理：
$$\dim \ker(A - \lambda I) = n - \operatorname{rank}(A - \lambda I)$$
即 $GM = n - \operatorname{rank}(A - \lambda I)$。

### $1 \leq GM \leq AM$ 的证明

**$GM \geq 1$**：因为 $\lambda$ 是特征值 $\implies$ 存在特征向量 $\implies \ker(A - \lambda I) \neq \{0\}$。

**$GM \leq AM$**（核心）：

将 $E_\lambda$ 的基 $\{v_1,\ldots,v_g\}$（$g = GM$）扩充为全空间基。在此基下矩阵为：
$$A = \begin{pmatrix} \lambda I_g & B \\ 0 & C \end{pmatrix}$$

特征多项式：$p(\mu) = \det\begin{pmatrix} (\lambda-\mu)I_g & B \\ 0 & C - \mu I \end{pmatrix} = (\lambda-\mu)^g \det(C - \mu I)$

因此 $(\lambda - \mu)^g$ 整除 $p(\mu)$，从而 $\lambda$ 的代数重数至少为 $g$。$\square$

## 5.3 Cayley-Hamilton 定理

$p(A) = 0$，其中 $p(\lambda) = \det(A - \lambda I)$。

**推导思路**（利用伴随矩阵）：

考虑 $\lambda I - A$ 的伴随矩阵 $B(\lambda) = \operatorname{adj}(\lambda I - A)$。$B(\lambda)$ 的每个元素是 $\lambda$ 的不超过 $n-1$ 次多项式，故可写 $B(\lambda) = B_0 + B_1\lambda + \cdots + B_{n-1}\lambda^{n-1}$。

基本恒等式：$B(\lambda)(\lambda I - A) = \det(\lambda I - A)I = p(\lambda)I$。

设 $p(\lambda) = c_0 + c_1\lambda + \cdots + c_{n-1}\lambda^{n-1} + \lambda^n$。展开上式并按 $\lambda$ 的幂次比较系数可得递推关系，最后推出 $p(A) = 0$。$\square$

## 5.4 对角化条件

$A$ 可对角化 $\iff$ 存在 $n$ 个线性无关的特征向量。

**$n$ 个不同特征值 $\implies$ 可对角化**的证明：

设 $\lambda_1,\ldots,\lambda_k$ 为不同特征值，$v_1,\ldots,v_k$ 为对应特征向量。

**归纳证明线性无关**：$k=1$ 显然。假设 $k-1$ 个不同特征值的特征向量线性无关。设 $\sum_{i=1}^k \alpha_i v_i = 0$。两边作用 $A$：
$$0 = A\left(\sum \alpha_i v_i\right) = \sum \alpha_i \lambda_i v_i$$

同时 $\lambda_k \cdot \left(\sum \alpha_i v_i\right) = \sum \alpha_i \lambda_k v_i = 0$。两式相减：
$$\sum_{i=1}^{k-1} \alpha_i (\lambda_i - \lambda_k) v_i = 0$$

由归纳假设，$\alpha_i(\lambda_i - \lambda_k) = 0$ 对所有 $i < k$。由于 $\lambda_i \neq \lambda_k$，故 $\alpha_i = 0$（$i < k$）。再由 $\alpha_k v_k = 0$ 且 $v_k \neq 0$ 得 $\alpha_k = 0$。全部 $\alpha_i = 0$。$\square$

## 5.5 Gershgorin 圆盘定理的推导

对任意特征对 $(\lambda, x)$，设 $|x_k| = \max_i |x_i| = \|x\|_\infty$。从第 $k$ 个方程：
$$\sum_{j=1}^n a_{kj} x_j = \lambda x_k$$

整理得 $(\lambda - a_{kk}) x_k = \sum_{j \neq k} a_{kj} x_j$。取绝对值并除以 $|x_k|$：
$$|\lambda - a_{kk}| = \left|\sum_{j \neq k} a_{kj} \frac{x_j}{x_k}\right| \leq \sum_{j \neq k} |a_{kj}| \frac{|x_j|}{|x_k|} \leq \sum_{j \neq k} |a_{kj}|$$

其中最后一步用了 $|x_j|/|x_k| \leq 1$（$|x_k|$ 是最大分量）。故特征值落在以 $a_{kk}$ 为中心、行非对角元绝对值之和为半径的圆盘中。$\square$

---

# 第六章 内积空间

## 6.1 Cauchy-Schwarz 不等式推导

$|\langle u, v \rangle| \leq \|u\| \|v\|$。

**证明**（对实内积）：

对任意 $t \in \mathbb{R}$，由正定性：
$$0 \leq \|u + tv\|^2 = \langle u+tv, u+tv \rangle = \|u\|^2 + 2t\langle u, v \rangle + t^2\|v\|^2$$

这是关于 $t$ 的二次型恒 $\geq 0$。其判别式必 $\leq 0$：
$$\Delta = 4\langle u, v \rangle^2 - 4\|u\|^2 \|v\|^2 \leq 0$$

即 $\langle u, v \rangle^2 \leq \|u\|^2 \|v\|^2$，开方得 $|\langle u, v \rangle| \leq \|u\|\|v\|$。等号成立 $\iff u, v$ 线性相关。$\square$

**复情形**：取 $t = -\dfrac{\langle u, v \rangle}{|\langle u, v \rangle|}$（合适的复相位）转化为实情形，或用正定性 $\|u - \lambda v\|^2 \geq 0$ 取 $\lambda = \frac{\langle u, v \rangle}{\|v\|^2}$。

### 三角不等式推导

由 Cauchy-Schwarz：
$$\begin{aligned}
\|u+v\|^2 &= \langle u+v, u+v \rangle = \|u\|^2 + \langle u, v \rangle + \langle v, u \rangle + \|v\|^2 \\
&= \|u\|^2 + 2\operatorname{Re}\langle u, v \rangle + \|v\|^2 \\
&\leq \|u\|^2 + 2\|u\|\|v\| + \|v\|^2 = (\|u\| + \|v\|)^2
\end{aligned}$$

开方得 $\|u+v\| \leq \|u\| + \|v\|$。$\square$

## 6.2 Gram-Schmidt 正交化推导

给定 $\{v_1,\ldots,v_n\}$ 线性无关，递归构造标准正交基 $\{e_1,\ldots,e_n\}$：

$$
u_k = v_k - \sum_{j=1}^{k-1} \langle v_k, e_j \rangle e_j,\quad e_k = \frac{u_k}{\|u_k\|}
$$

**推导原理**：$u_k$ 是将 $v_k$ 投影到已构造的标准正交基 $\{e_1,\ldots,e_{k-1}\}$ 的正交补上。具体而言，对 $i < k$：
$$\langle u_k, e_i \rangle = \langle v_k, e_i \rangle - \sum_{j=1}^{k-1} \langle v_k, e_j \rangle \underbrace{\langle e_j, e_i \rangle}_{\delta_{ji}} = \langle v_k, e_i \rangle - \langle v_k, e_i \rangle = 0$$

因此 $u_k \perp \operatorname{span}\{e_1,\ldots,e_{k-1}\}$。归一化即得 $e_k$。

$u_k \neq 0$（否则 $v_k \in \operatorname{span}\{e_1,\ldots,e_{k-1}\} = \operatorname{span}\{v_1,\ldots,v_{k-1}\}$ 与线性无关矛盾）。$\square$

## 6.3 正交投影公式推导

设 $U$ 有标准正交基 $\{e_1,\ldots,e_k\}$。对 $v \in V$：
$$P_U(v) = \sum_{j=1}^k \langle v, e_j \rangle e_j$$

**推导**：需证 $v - P_U(v) \perp U$，即 $\forall i$，$\langle v - P_U(v), e_i \rangle = 0$：
$$
\begin{aligned}
\langle v - \sum_{j=1}^k \langle v, e_j \rangle e_j, e_i \rangle &= \langle v, e_i \rangle - \sum_{j=1}^k \langle v, e_j \rangle \underbrace{\langle e_j, e_i \rangle}_{\delta_{ji}} \\
&= \langle v, e_i \rangle - \langle v, e_i \rangle = 0
\end{aligned}
$$

因此 $v = P_U(v) + (v - P_U(v))$ 是到 $U \oplus U^\perp$ 的分解，投影即提取 $U$ 分量。$\square$

## 6.4 最小二乘正规方程推导

问题：$\min_x \|Ax - b\|_2^2$。

$$
\begin{aligned}
\|Ax - b\|^2 &= \langle Ax-b, Ax-b \rangle \\
&= \langle Ax, Ax \rangle - \langle Ax, b \rangle - \langle b, Ax \rangle + \langle b, b \rangle \\
&= x^{\top} A^{\top} A x - 2 x^{\top} A^{\top} b + b^{\top} b
\end{aligned}
$$

这是 $x$ 的二次函数（凸函数，因 $A^{\top}A \succeq 0$）。极值点处梯度为零：
$$\nabla_x = 2A^{\top} A x - 2A^{\top} b = 0$$

故得**正规方程**：$A^{\top} A \hat{x} = A^{\top} b$。

若 $A$ 列满秩，$A^{\top}A$ 正定可逆，得解析解 $\hat{x} = (A^{\top}A)^{-1} A^{\top} b$。

**几何解释**：$\hat{x}$ 使残差 $r = b - A\hat{x} \perp \mathcal{C}(A)$。正规方程正是 $A^{\top}(b - A\hat{x}) = 0$——即残差与 $A$ 的列正交。$\square$

---

# 第七章 内积空间上的算子

## 7.1 伴随算子的存在唯一性推导

**定理**：对 $T \in \mathcal{L}(V,W)$，存在唯一的 $T^*: W \to V$ 使 $\langle Tv, w \rangle_W = \langle v, T^*w \rangle_V$。

**存在性**：取 $W$ 的标准正交基 $\{e_i\}$，对 $w \in W$，定义线性泛函 $\varphi(v) = \langle Tv, w \rangle$。由 Riesz 表示定理，存在唯一 $u_w \in V$ 使 $\varphi(v) = \langle v, u_w \rangle$。令 $T^*w = u_w$。由唯一性可验证 $T^*$ 是线性的。

坐标表示下：若 $A$ 是 $T$ 在标准正交基下的矩阵，则 $T^*$ 的矩阵是 $A^* = \overline{A}^{\top}$（共轭转置）。因为：
$$\langle Ax, y \rangle = y^{\top} \overline{Ax} = (A^* y)^{\top} x = \langle x, A^* y \rangle$$

## 7.2 $\ker T^* = (\operatorname{im} T)^\perp$ 推导

**双向包含证明**：

($\subseteq$) 设 $w \in \ker T^*$，即 $T^*w = 0$。对任意 $v \in V$：$\langle Tv, w \rangle = \langle v, T^*w \rangle = \langle v, 0 \rangle = 0$。故 $w \perp \operatorname{im} T$。

($\supseteq$) 设 $w \perp \operatorname{im} T$，即 $\forall v$，$\langle Tv, w \rangle = 0$。由伴随定义：$\langle v, T^*w \rangle = 0$ 对所有 $v$ 成立。取 $v = T^*w$ 得 $\|T^*w\|^2 = 0$，故 $T^*w = 0$。$\square$

## 7.3 实谱定理推导

**定理**：$T \in \mathcal{L}(V)$（$V$ 为实内积空间）是自伴算子 $\iff$ $V$ 有由 $T$ 的特征向量组成的标准正交基。

**证明思路**（对 $\dim V$ 归纳）：

$n=1$：平凡。

设 $\dim V = n > 1$。**第一步**：证自伴算子至少有一个实特征值。考虑 Rayleigh 商 $R(v) = \frac{\langle Tv, v \rangle}{\|v\|^2}$，在紧单位球面上极值点 $u$ 处，$R(u)$ 是特征值，$u$ 是特征向量（这用到 Lagrange 乘子法或变分原理的反证法）。也可用特征多项式在实闭包上有根 + 自伴保证特征值皆为实。

**第二步**：设 $u$ 是单位特征向量，$Tu = \lambda u$。则 $T$ 将 $U = \operatorname{span}\{u\}^\perp$ 映到 $U$（因为对 $v \perp u$：$\langle Tv, u \rangle = \langle v, Tu \rangle = \lambda\langle v, u \rangle = 0$）。$T$ 在 $U$ 上的限制仍是自伴的，维数 $n-1$，由归纳假设 $U$ 有标准正交特征向量基。并上 $u$ 即得 $V$ 的标准正交特征向量基。$\square$

## 7.4 极分解推导

**定理**：$T \in \mathcal{L}(V)$ 可写 $T = S \sqrt{T^*T}$，其中 $S$ 是等距。

**推导**：$\sqrt{T^*T}$ 是正算子（$T^*T$ 是正自伴算子，其唯一正平方根）。

对 $v \in V$：
$$\|\sqrt{T^*T} v\|^2 = \langle \sqrt{T^*T} v, \sqrt{T^*T} v \rangle = \langle T^*T v, v \rangle = \|T v\|^2$$

因此 $\|\sqrt{T^*T} v\| = \|Tv\|$。定义 $S_0: \operatorname{im}\sqrt{T^*T} \to \operatorname{im} T$ 为 $S_0(\sqrt{T^*T} v) = Tv$。由范数相等关系 $S_0$ 是良定的等距。将其延拓为全空间 $V$ 上的等距 $S$ 即得。$\square$

---

# 第八章 复向量空间上的算子

## 8.1 广义特征空间分解的推导

考虑算子 $T: V \to V$（$V$ 为 $\mathbb{C}$ 上有限维），$\lambda_1,\ldots,\lambda_m$ 为不同特征值。

**广义特征空间**：$G(\lambda_j) = \{v \in V : (T - \lambda_j I)^k v = 0,\; k \geq 1\}$。

**不动链**：对充分大的 $k$（$\leq \dim V$），$\ker(T - \lambda_j I)^k$ 稳定，即 $G(\lambda_j) = \ker(T - \lambda_j I)^{\dim V}$。

**分解定理**：$V = G(\lambda_1) \oplus \cdots \oplus G(\lambda_m)$。

**证明思路**（利用多项式互素）：

设 $p_j(x) = \prod_{i \neq j} (x - \lambda_i)^{\dim V}$。则 $p_1,\ldots,p_m$ 的最大公因式为 1（没有公共根）。由 Bezout 恒等式，存在多项式 $q_j$ 使：
$$\sum_{j=1}^m q_j(x) p_j(x) = 1$$

代入 $T$ 得 $\sum q_j(T) p_j(T) = I$。对任意 $v \in V$：
$$v = \sum_{j=1}^m q_j(T) p_j(T) v$$

令 $v_j = q_j(T)p_j(T)v$。由于 $(T - \lambda_j I)^{\dim V} p_j(T) = 0$（$p_j$ 含 $(x - \lambda_j)^{\dim V}$ 因子），而 $m_T(x)$（最小多项式）乘 $p_j$ 被 $(x-\lambda_j)^{\dim V}$ 整除，故 $(T - \lambda_j I)^{\dim V} v_j = 0$，即 $v_j \in G(\lambda_j)$。

直和性（各 $G(\lambda_j)$ 交仅 $\{0\}$）及独立性由不变性可得。$\square$

## 8.2 Jordan 标准形的构造

**步骤一**：将 $V$ 分解为广义特征空间直和：$V = \bigoplus G(\lambda_j)$。对每特征值独立处理。

**步骤二**：对单个特征值 $\lambda$，考虑幂零算子 $N = (T - \lambda I)|_{G(\lambda)}$。对幂零算子，寻找循环基——对于 $G(\lambda)$ 中不属于 $\ker N$ 的向量 $v$，其轨道 $\{v, Nv, N^2v, \ldots\}$ 产生一个块。重复直至基完整。

**具体**：取 $v_1 \in G(\lambda) \setminus \ker N^{k-1}$（$k$ 为 Jordan 块大小）。构造链：
$$v_1,\; N v_1 = (T - \lambda I)v_1,\; \ldots,\; N^{k-1} v_1$$

在此基下 $T = \lambda I + N$ 在所生成的子空间上的矩阵为一个 $k \times k$ Jordan 块。重复构造直到所有广义特征向量被覆盖。

**唯一性**：Jordan 块的大小分布由 $\dim \ker(T - \lambda I)^j$ 的差决定：
$$\text{大小为 } \geq p \text{ 的 Jordan 块数} = \dim \ker(T - \lambda I)^p - \dim \ker(T - \lambda I)^{p-1}$$

这唯一确定了 Jordan 形。$\square$

## 8.3 迹的循环不变性推导

$\operatorname{tr}(AB) = \operatorname{tr}(BA)$。

设 $A \in \mathbb{F}^{m \times n}, B \in \mathbb{F}^{n \times m}$：
$$
\operatorname{tr}(AB) = \sum_{i=1}^m (AB)_{ii} = \sum_{i=1}^m \sum_{k=1}^n a_{ik} b_{ki} = \sum_{k=1}^n \sum_{i=1}^m b_{ki} a_{ik} = \sum_{k=1}^n (BA)_{kk} = \operatorname{tr}(BA)
$$

交换求和次序即得证。$\square$

---

# 第九章 奇异值分解 SVD

## 9.1 SVD 的推导

**第一步**：$A^* A$ 是 $n \times n$ 自伴且正半定矩阵（$\langle A^*A x, x \rangle = \|Ax\|^2 \geq 0$）。由谱定理，存在酉矩阵 $V = [v_1,\ldots,v_n]$ 使：
$$V^*(A^*A)V = \operatorname{diag}(\lambda_1,\ldots,\lambda_n)$$
其中 $\lambda_1 \geq \cdots \geq \lambda_r > 0 = \lambda_{r+1} = \cdots = \lambda_n$（$r = \operatorname{rank} A$）。

**第二步**：定义 $\sigma_i = \sqrt{\lambda_i}$（奇异值）。$u_i = \frac{1}{\sigma_i} A v_i$（$i = 1,\ldots,r$）。

验证 $\{u_1,\ldots,u_r\}$ 为标准正交组：
$$\langle u_i, u_j \rangle = \frac{1}{\sigma_i \sigma_j} \langle A v_i, A v_j \rangle = \frac{1}{\sigma_i \sigma_j} \langle A^*A v_i, v_j \rangle = \frac{\lambda_i}{\sigma_i \sigma_j} \langle v_i, v_j \rangle = \frac{\sigma_i}{\sigma_j}\delta_{ij} = \delta_{ij}$$

**第三步**：将 $\{u_1,\ldots,u_r\}$ 扩充为 $\mathbb{C}^m$ 的标准正交基 $\{u_1,\ldots,u_r, u_{r+1},\ldots,u_m\}$。令 $U = [u_1,\ldots,u_m]$。

**第四步**：验证 $A = U \Sigma V^*$。对每 $j$：
$$A v_j = \begin{cases} \sigma_j u_j & j \leq r \\ 0 & j > r \end{cases}$$
而 $U \Sigma V^*$ 的第 $j$ 列恰为 $U \Sigma e_j = \sigma_j U e_j$（$j \leq r$ 时 $= \sigma_j u_j$，$j > r$ 时 $= 0$）。两者相等。$\square$

## 9.2 Eckart-Young 定理推导

**定理**：$A_k = \sum_{i=1}^k \sigma_i u_i v_i^*$ 是所有秩 $\leq k$ 矩阵中对 $A$ 在谱范数下的最佳近似。

**推导（利用矩阵范数的酉不变性）**：

设 $B$ 的秩 $\leq k$。则 $\dim \ker B \geq n-k$。考虑由 $v_1,\ldots,v_{k+1}$ 生成的子空间（维数 $k+1$）。由于交的维数：
$$\dim(\operatorname{span}\{v_1,\ldots,v_{k+1}\} \cap \ker B) \geq (k+1) + (n-k) - n = 1$$
故存在非零 $z = \sum_{i=1}^{k+1} \alpha_i v_i$ 且 $Bz = 0$。取 $\|z\| = 1$。

$$
\begin{aligned}
\|A - B\|_2^2 &\geq \|(A - B)z\|^2 = \|Az\|^2 = \left\|\sum_{i=1}^{k+1} \alpha_i \sigma_i u_i\right\|^2 \\
&= \sum_{i=1}^{k+1} |\alpha_i|^2 \sigma_i^2 \geq \sigma_{k+1}^2 \sum_{i=1}^{k+1} |\alpha_i|^2 = \sigma_{k+1}^2
\end{aligned}
$$

而下界 $\sigma_{k+1}$ 被 $A_k$ 达到（$\|A - A_k\|_2 = \sigma_{k+1}$），故 $A_k$ 是最逼近。$\square$

---

# 第十章 多重线性代数与张量

## 10.1 二次型正交对角化推导

二次型 $q(x) = x^{\top} A x$（$A$ 对称）。由实谱定理，存在正交矩阵 $P$（$P^{\top} = P^{-1}$）使：
$$P^{\top} A P = D = \operatorname{diag}(\lambda_1,\ldots,\lambda_n)$$

令 $y = P^{\top} x$（等价 $x = Py$），则：
$$q(x) = x^{\top} A x = (Py)^{\top} A (Py) = y^{\top} (P^{\top}AP) y = y^{\top} D y = \sum_{i=1}^n \lambda_i y_i^2$$

这就是主轴变换（principal axis transformation）。

## 10.2 Sylvester 惯性定律

**定理**：对实对称矩阵 $A$，在任何可逆变量替换 $x = Cy$ 下，正特征值的个数、负特征值的个数、零特征值的个数均不变。

**推导**（反证法）：设 $C_1^{\top} A C_1 = D_1$，$C_2^{\top} A C_2 = D_2$。$D_1, D_2$ 的对角元正是新旧正/负/零特征值指示。若正特征值个数不同，构造一个子空间（正空间与负空间交至少含一个非零元）推矛盾——利用维数包含与正交性质导出此向量必须既"正"又"非正"。$\square$

## 10.3 张量积的构造

$V \otimes W$ 的形式构造：以 $V \times W$ 的所有元素为基生成自由向量空间，模去关系：
- $(v_1+v_2, w) - (v_1,w) - (v_2,w)$
- $(v, w_1+w_2) - (v,w_1) - (v,w_2)$
- $(\alpha v, w) - \alpha(v,w)$
- $(v, \alpha w) - \alpha(v,w)$

$(v,w)$ 所在等价类记为 $v \otimes w$。

**维数公式** $\dim(V \otimes W) = \dim V \cdot \dim W$ 的验证：设 $V$ 有基 $\{e_i\}$，$W$ 有基 $\{f_j\}$。则 $\{e_i \otimes f_j\}$ 生成 $V \otimes W$（任意 $v \otimes w$ 可由基的张量积线性表出）。进一步它们线性无关（由万有性质可证），故基的大小为 $\dim V \cdot \dim W$。

---

# 第十一章 数值线性代数专题

## 11.1 诱导矩阵范数计算公式推导

对 $p=1$：$\|A\|_1 = \max_{j} \sum_i |a_{ij}|$（最大列和）。

**推导**：设 $\|x\|_1 = \sum |x_j| = 1$。
$$
\|Ax\|_1 = \sum_i \left|\sum_j a_{ij} x_j\right| \leq \sum_i \sum_j |a_{ij}| |x_j| = \sum_j |x_j| \sum_i |a_{ij}|
$$
令 $C_j = \sum_i |a_{ij}|$（第 $j$ 列之和）。则 $\|Ax\|_1 \leq \sum_j C_j |x_j| \leq \max_j C_j \cdot \sum_j |x_j| = \max_j C_j$。

取 $x = e_k$（第 $k$ 个标准基向量），其中 $k$ 使 $C_k$ 最大，则 $\|Ae_k\|_1 = C_k$。故上界可达，$\|A\|_1 = \max_j \sum_i |a_{ij}|$。$\square$

对 $p=\infty$：类似可得 $\|A\|_\infty = \max_i \sum_j |a_{ij}|$（最大行和）。

## 11.2 误差放大不等式推导

对 $Ax = b$，扰动 $\Delta b$ 引起的 $\Delta x$：
$$A(x + \Delta x) = b + \Delta b \implies A \Delta x = \Delta b \implies \Delta x = A^{-1} \Delta b$$

由范数相容性：
$$\|\Delta x\| \leq \|A^{-1}\| \cdot \|\Delta b\|$$

从 $\|b\| = \|Ax\| \leq \|A\| \cdot \|x\|$ 得 $\frac{1}{\|x\|} \leq \frac{\|A\|}{\|b\|}$。两不等式相乘：
$$\frac{\|\Delta x\|}{\|x\|} \leq \|A\| \cdot \|A^{-1}\| \cdot \frac{\|\Delta b\|}{\|b\|} = \kappa(A) \frac{\|\Delta b\|}{\|b\|}$$

$\kappa(A) = \|A\| \cdot \|A^{-1}\|$ 为条件数。$\square$

---

# 附：重要定理推导线索速查

| 定理 | 推导手法 |
|------|----------|
| 秩-零度 | 将 $\ker T$ 的基扩充为 $V$ 的基，像的基 = 扩充部分经 $T$ 的像 |
| Cayley-Hamilton | 伴随矩阵展开 + 多项式系数比对 |
| Cauchy-Schwarz | 二次型判别式 $\leq 0$ |
| 实谱定理 | 对维数归纳：Rayleigh 商寻特征值 + 正交补不变性 |
| Jordan 形 | 广义特征空间分解 + 幂零算子的循环基构造 |
| SVD | $A^*A$ 的谱分解 → 奇异值 → 标准正交化 $Av_i$ |
| Eckart-Young | 维数交论证 + 范数下界 |
| Gershgorin | 取最大分量行等式化 |
| Perron-Frobenius | Brouwer 不动点 + 正锥紧性论证 |

---

**交叉引用**：[[代数基础]]（多项式、矩阵、特征值与行列式）、[[群论]]（群表示的基础）、[[环论]]（$M_n(F)$ 是非交换环）、[[模论]]（$F[x]$-模 $\to$ Jordan/有理标准形）、[[域论与伽罗瓦理论]]（特征多项式的 Galois 群）
