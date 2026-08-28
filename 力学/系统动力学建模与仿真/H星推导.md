# 第七章：从旋转矩阵到欧拉参数速度映射 \(H^*\) —— 完整因果推导

> 这份笔记重新整理了推导顺序，目标不是直接记住 \(H^*\)，而是回答三个问题：
>
> 1. 为什么角速度可以从 \(A^T\dot A\) 中得到？
> 2. 欧拉参数 \(\boldsymbol{\varepsilon}\) 以及它的导数 \(\dot{\boldsymbol{\varepsilon}}\) 是怎么自然进入推导的？
> 3. 怎样从 \(A^T\dot A=\widetilde{\boldsymbol{\omega}}\) 一步一步得到书中的 \(H^*\)？

---

## 0. 先统一术语和符号

这里使用的是**欧拉参数（Euler parameters）**，也就是单位四元数形式的姿态参数，不是三个欧拉角。

书中的欧拉参数写成

$$
\boldsymbol{\varepsilon}
=
\begin{bmatrix}
\bar{\boldsymbol{\varepsilon}}\\
\varepsilon_4
\end{bmatrix},
\qquad
\bar{\boldsymbol{\varepsilon}}
=
\begin{bmatrix}
\varepsilon_1\\
\varepsilon_2\\
\varepsilon_3
\end{bmatrix}.
$$

其中

- \(\boldsymbol{\varepsilon}\in\mathbb R^4\)：完整欧拉参数；
- \(\bar{\boldsymbol{\varepsilon}}\in\mathbb R^3\)：前三个分量组成的向量；
- \(\varepsilon_4\in\mathbb R\)：第四个标量分量。

单位欧拉参数满足

$$
\boldsymbol{\varepsilon}^T\boldsymbol{\varepsilon}
=
\bar{\boldsymbol{\varepsilon}}^T\bar{\boldsymbol{\varepsilon}}
+
\varepsilon_4^2
=
1.
$$

对时间求导：

$$
\bar{\boldsymbol{\varepsilon}}^T
\dot{\bar{\boldsymbol{\varepsilon}}}
+
\varepsilon_4\dot{\varepsilon}_4
=
0.
$$

这个导数约束后面用于保证 \(A^T\dot A\) 的对角元素为零。

---

# 1. 整个推导的正确因果顺序

先不要从欧拉参数导数开始。

真正自然的顺序是：

```text
刚体姿态
   │
   ▼
旋转矩阵 A(t)
   │
   │ 姿态随时间变化
   ▼
旋转矩阵导数 Ȧ
   │
   ▼
由 AᵀA = I 得知 AᵀȦ 为反对称矩阵
   │
   ▼
AᵀȦ = ω~
   │
   │ 现在才选择用欧拉参数描述 A
   ▼
A = A(ε)
   │
   │ ε = ε(t)
   ▼
A = A(ε(t))
   │
   │ 链式法则
   ▼
Ȧ 中自然出现 ε̇
   │
   ▼
把 A(ε)、Ȧ(ε,ε̇) 代入 AᵀȦ = ω~
   │
   ▼
得到 ω 与 ε̇ 的关系
   │
   ▼
ω = H*(ε) ε̇
```

所以：

**\(\dot{\boldsymbol{\varepsilon}}\) 不是人为塞进来的。**

它来自

$$
A=A(\boldsymbol{\varepsilon}(t))
$$

对时间求导时的链式法则。

---

# 2. 第一块地基：为什么 \(A^T\dot A\) 是反对称矩阵？

旋转矩阵满足

$$
A^TA=I.
$$

对时间求导：

$$
\frac{d}{dt}(A^TA)=0.
$$

根据乘积求导：

$$
\dot A^TA+A^T\dot A=0.
$$

又因为

$$
\dot A^TA=(A^T\dot A)^T,
$$

所以

$$
(A^T\dot A)^T+A^T\dot A=0.
$$

令

$$
S=A^T\dot A,
$$

则

$$
S^T=-S.
$$

因此 \(S\) 一定是 \(3\times3\) 反对称矩阵。

---

# 3. 三维反对称矩阵为什么可以对应角速度？

对于三维向量

$$
\mathbf a=
\begin{bmatrix}
a_1\\
a_2\\
a_3
\end{bmatrix},
$$

定义叉乘矩阵

$$
\widetilde{\mathbf a}
=
\begin{bmatrix}
0&-a_3&a_2\\
a_3&0&-a_1\\
-a_2&a_1&0
\end{bmatrix}.
$$

它满足

$$
\widetilde{\mathbf a}\mathbf b
=
\mathbf a\times\mathbf b.
$$

因此任意 \(3\times3\) 反对称矩阵都可以唯一写成

$$
\widetilde{\mathbf a}
$$

的形式。

而刚体上随刚体旋转的向量满足

$$
\dot{\mathbf r}
=
\boldsymbol{\omega}\times\mathbf r
=
\widetilde{\boldsymbol{\omega}}\mathbf r.
$$

所以这个反对称矩阵中三个独立分量的物理意义正是角速度。

---

# 4. 从刚体上的固定向量进一步理解 \(A^T\dot A\)

设 \({}^B\mathbf r\) 固定在刚体坐标系 \(B\) 中。

它在惯性系 \(O\) 中表示为

$$
{}^O\mathbf r
=
A\,{}^B\mathbf r.
$$

因为 \({}^B\mathbf r\) 对时间不变，

$$
{}^O\dot{\mathbf r}
=
\dot A\,{}^B\mathbf r.
$$

另一方面，刚体以角速度 \({}^O\boldsymbol{\omega}\) 旋转时，

$$
{}^O\dot{\mathbf r}
=
{}^O\boldsymbol{\omega}
\times
{}^O\mathbf r
=
\widetilde{{}^O\boldsymbol{\omega}}
A\,{}^B\mathbf r.
$$

对任意 \({}^B\mathbf r\) 都成立，所以

$$
\dot A
=
\widetilde{{}^O\boldsymbol{\omega}}A.
$$

左乘 \(A^T\)：

$$
A^T\dot A
=
A^T\widetilde{{}^O\boldsymbol{\omega}}A.
$$

利用叉乘矩阵的坐标变换关系

$$
A^T\widetilde{\mathbf a}A
=
\widetilde{A^T\mathbf a},
$$

得到

$$
A^T\dot A
=
\widetilde{{}^B\boldsymbol{\omega}}.
$$

如果书中把刚体系表达的角速度简写为 \(\boldsymbol{\omega}\)，就是

$$
A^T\dot A
=
\widetilde{\boldsymbol{\omega}}.
$$

---

## 4.1 一个很重要的坐标系区别

若角速度在惯性系表达：

$$
\dot A A^T
=
\widetilde{{}^O\boldsymbol{\omega}}.
$$

若角速度在刚体系表达：

$$
A^T\dot A
=
\widetilde{{}^B\boldsymbol{\omega}}.
$$

因此以后看到

$$
\dot A=\widetilde{\boldsymbol{\omega}}A
$$

或者

$$
\dot A=A\widetilde{\boldsymbol{\omega}},
$$

必须先确认 \(\boldsymbol{\omega}\) 是在哪个坐标系中表示。

---

# 5. 现在才引入欧拉参数

前面我们已经独立建立了

$$
A^T\dot A
=
\widetilde{\boldsymbol{\omega}}.
$$

现在选择用欧拉参数描述姿态：

$$
A=A(\boldsymbol{\varepsilon}).
$$

因为刚体正在运动，

$$
\boldsymbol{\varepsilon}
=
\boldsymbol{\varepsilon}(t),
$$

所以严格来说

$$
A(t)=A(\boldsymbol{\varepsilon}(t)).
$$

这是复合函数。

---

# 6. \(\dot{\boldsymbol{\varepsilon}}\) 是怎样出现的？

因为

$$
A
=
A(
\varepsilon_1,
\varepsilon_2,
\varepsilon_3,
\varepsilon_4
),
$$

而每个 \(\varepsilon_i\) 都随时间变化，所以由链式法则

$$
\dot A
=
\frac{\partial A}{\partial\varepsilon_1}\dot\varepsilon_1
+
\frac{\partial A}{\partial\varepsilon_2}\dot\varepsilon_2
+
\frac{\partial A}{\partial\varepsilon_3}\dot\varepsilon_3
+
\frac{\partial A}{\partial\varepsilon_4}\dot\varepsilon_4.
$$

也可以简写成

$$
\dot A
=
\sum_{i=1}^{4}
\frac{\partial A}{\partial\varepsilon_i}\dot\varepsilon_i.
$$

这就是欧拉参数导数的来源。

注意：

$$
\dot{\boldsymbol{\varepsilon}}
\neq
\boldsymbol{\omega}.
$$

\(\dot{\boldsymbol{\varepsilon}}\) 是**姿态参数的变化率**；

\(\boldsymbol{\omega}\) 是**刚体真实的三维物理角速度**。

二者之间需要一个姿态相关的速度映射。

---

# 7. 欧拉参数对应的旋转矩阵 \(A(\boldsymbol{\varepsilon})\) 从哪里来？

假设旋转轴为单位向量 \(\mathbf n\)，旋转角为 \(\theta\)。

欧拉参数定义为

$$
\bar{\boldsymbol{\varepsilon}}
=
\mathbf n\sin\frac{\theta}{2},
\qquad
\varepsilon_4
=
\cos\frac{\theta}{2}.
$$

Rodrigues 公式为

$$
A
=
I_3
+
\sin\theta\,\widetilde{\mathbf n}
+
(1-\cos\theta)\widetilde{\mathbf n}^{\,2}.
$$

利用

$$
\sin\theta
=
2\sin\frac{\theta}{2}\cos\frac{\theta}{2},
$$

以及

$$
1-\cos\theta
=
2\sin^2\frac{\theta}{2},
$$

得到

$$
A
=
I_3
+
2\varepsilon_4
\widetilde{\bar{\boldsymbol{\varepsilon}}}
+
2\widetilde{\bar{\boldsymbol{\varepsilon}}}^{\,2}.
$$

又因为叉乘矩阵满足

$$
\widetilde{\mathbf a}^{\,2}
=
\mathbf a\mathbf a^T
-
(\mathbf a^T\mathbf a)I_3,
$$

所以

$$
\widetilde{\bar{\boldsymbol{\varepsilon}}}^{\,2}
=
\bar{\boldsymbol{\varepsilon}}
\bar{\boldsymbol{\varepsilon}}^T
-
(
\bar{\boldsymbol{\varepsilon}}^T
\bar{\boldsymbol{\varepsilon}}
)I_3.
$$

代入后：

$$
A
=
\left(
1
-
2\bar{\boldsymbol{\varepsilon}}^T
\bar{\boldsymbol{\varepsilon}}
\right)I_3
+
2\bar{\boldsymbol{\varepsilon}}
\bar{\boldsymbol{\varepsilon}}^T
+
2\varepsilon_4
\widetilde{\bar{\boldsymbol{\varepsilon}}}.
$$

由单位约束

$$
1
=
\bar{\boldsymbol{\varepsilon}}^T
\bar{\boldsymbol{\varepsilon}}
+
\varepsilon_4^2,
$$

可将第一项改写为

$$
1
-
2\bar{\boldsymbol{\varepsilon}}^T
\bar{\boldsymbol{\varepsilon}}
=
\varepsilon_4^2
-
\bar{\boldsymbol{\varepsilon}}^T
\bar{\boldsymbol{\varepsilon}}.
$$

因此得到欧拉参数形式的旋转矩阵：

$$
A
=
\left(
\varepsilon_4^2
-
\bar{\boldsymbol{\varepsilon}}^T
\bar{\boldsymbol{\varepsilon}}
\right)I_3
+
2\bar{\boldsymbol{\varepsilon}}
\bar{\boldsymbol{\varepsilon}}^T
+
2\varepsilon_4
\widetilde{\bar{\boldsymbol{\varepsilon}}}.
$$

这就是后面求 \(H^*\) 的真正起点。

---

# 8. 对 \(A(\boldsymbol{\varepsilon})\) 求时间导数

原式：

$$
A
=
\left(
\varepsilon_4^2
-
\bar{\boldsymbol{\varepsilon}}^T
\bar{\boldsymbol{\varepsilon}}
\right)I_3
+
2\bar{\boldsymbol{\varepsilon}}
\bar{\boldsymbol{\varepsilon}}^T
+
2\varepsilon_4
\widetilde{\bar{\boldsymbol{\varepsilon}}}.
$$

逐项求导。

第一项：

$$
\frac{d}{dt}
\left(
\varepsilon_4^2
-
\bar{\boldsymbol{\varepsilon}}^T
\bar{\boldsymbol{\varepsilon}}
\right)
=
2\varepsilon_4\dot\varepsilon_4
-
2\bar{\boldsymbol{\varepsilon}}^T
\dot{\bar{\boldsymbol{\varepsilon}}}.
$$

第二项：

$$
\frac{d}{dt}
\left(
2\bar{\boldsymbol{\varepsilon}}
\bar{\boldsymbol{\varepsilon}}^T
\right)
=
2\dot{\bar{\boldsymbol{\varepsilon}}}
\bar{\boldsymbol{\varepsilon}}^T
+
2\bar{\boldsymbol{\varepsilon}}
\dot{\bar{\boldsymbol{\varepsilon}}}^T.
$$

第三项：

$$
\frac{d}{dt}
\left(
2\varepsilon_4
\widetilde{\bar{\boldsymbol{\varepsilon}}}
\right)
=
2\dot\varepsilon_4
\widetilde{\bar{\boldsymbol{\varepsilon}}}
+
2\varepsilon_4
\widetilde{\dot{\bar{\boldsymbol{\varepsilon}}}}.
$$

因此

$$
\dot A
=
2\left(
\varepsilon_4\dot\varepsilon_4
-
\bar{\boldsymbol{\varepsilon}}^T
\dot{\bar{\boldsymbol{\varepsilon}}}
\right)I_3
+
2\dot{\bar{\boldsymbol{\varepsilon}}}
\bar{\boldsymbol{\varepsilon}}^T
+
2\bar{\boldsymbol{\varepsilon}}
\dot{\bar{\boldsymbol{\varepsilon}}}^T
+
2\dot\varepsilon_4
\widetilde{\bar{\boldsymbol{\varepsilon}}}
+
2\varepsilon_4
\widetilde{\dot{\bar{\boldsymbol{\varepsilon}}}}.
$$

同时

$$
A^T
=
\left(
\varepsilon_4^2
-
\bar{\boldsymbol{\varepsilon}}^T
\bar{\boldsymbol{\varepsilon}}
\right)I_3
+
2\bar{\boldsymbol{\varepsilon}}
\bar{\boldsymbol{\varepsilon}}^T
-
2\varepsilon_4
\widetilde{\bar{\boldsymbol{\varepsilon}}}.
$$

注意最后一项变号，是因为

$$
\widetilde{\bar{\boldsymbol{\varepsilon}}}^{\,T}
=
-
\widetilde{\bar{\boldsymbol{\varepsilon}}}.
$$

---

# 9. 计算 \(S=A^T\dot A\)：这里不用硬算全部九个元素

定义

$$
S=A^T\dot A.
$$

前面已经证明

$$
S^T=-S.
$$

因此它一定具有形式

$$
S
=
\begin{bmatrix}
0&-\omega_3&\omega_2\\
\omega_3&0&-\omega_1\\
-\omega_2&\omega_1&0
\end{bmatrix}.
$$

所以我们实际上只需要计算三个独立元素：

$$
S_{32}=\omega_1,
\qquad
S_{13}=\omega_2,
\qquad
S_{21}=\omega_3.
$$

这比把 \(A^T\dot A\) 的九个元素全部展开清楚得多。

---

# 10. 先定义一个单位约束因子

为了看清代数结构，定义

$$
N
=
\varepsilon_1^2
+
\varepsilon_2^2
+
\varepsilon_3^2
+
\varepsilon_4^2.
$$

单位欧拉参数满足

$$
N=1.
$$

把前面的 \(A^T\) 与 \(\dot A\) 相乘，并整理三个独立的反对称元素，可以得到：

$$
S_{32}
=
2N
\left(
\varepsilon_4\dot\varepsilon_1
+
\varepsilon_3\dot\varepsilon_2
-
\varepsilon_2\dot\varepsilon_3
-
\varepsilon_1\dot\varepsilon_4
\right),
$$

$$
S_{13}
=
2N
\left(
-\varepsilon_3\dot\varepsilon_1
+
\varepsilon_4\dot\varepsilon_2
+
\varepsilon_1\dot\varepsilon_3
-
\varepsilon_2\dot\varepsilon_4
\right),
$$

$$
S_{21}
=
2N
\left(
\varepsilon_2\dot\varepsilon_1
-
\varepsilon_1\dot\varepsilon_2
+
\varepsilon_4\dot\varepsilon_3
-
\varepsilon_3\dot\varepsilon_4
\right).
$$

因为

$$
N=1,
$$

所以直接得到：

$$
\omega_1
=
2
\left(
\varepsilon_4\dot\varepsilon_1
+
\varepsilon_3\dot\varepsilon_2
-
\varepsilon_2\dot\varepsilon_3
-
\varepsilon_1\dot\varepsilon_4
\right),
$$

$$
\omega_2
=
2
\left(
-\varepsilon_3\dot\varepsilon_1
+
\varepsilon_4\dot\varepsilon_2
+
\varepsilon_1\dot\varepsilon_3
-
\varepsilon_2\dot\varepsilon_4
\right),
$$

$$
\omega_3
=
2
\left(
\varepsilon_2\dot\varepsilon_1
-
\varepsilon_1\dot\varepsilon_2
+
\varepsilon_4\dot\varepsilon_3
-
\varepsilon_3\dot\varepsilon_4
\right).
$$

这三行就是 \(H^*\) 的三行。

---

# 11. 把三个角速度分量写成矩阵形式

将上一节三个式子上下排列：

$$
\begin{bmatrix}
\omega_1\\
\omega_2\\
\omega_3
\end{bmatrix}
=
2
\begin{bmatrix}
\varepsilon_4 & \varepsilon_3 & -\varepsilon_2 & -\varepsilon_1\\
-\varepsilon_3 & \varepsilon_4 & \varepsilon_1 & -\varepsilon_2\\
\varepsilon_2 & -\varepsilon_1 & \varepsilon_4 & -\varepsilon_3
\end{bmatrix}
\begin{bmatrix}
\dot\varepsilon_1\\
\dot\varepsilon_2\\
\dot\varepsilon_3\\
\dot\varepsilon_4
\end{bmatrix}.
$$

即

$$
\boldsymbol{\omega}
=
H^*(\boldsymbol{\varepsilon})
\dot{\boldsymbol{\varepsilon}},
$$

其中

$$
H^*(\boldsymbol{\varepsilon})
=
2
\begin{bmatrix}
\varepsilon_4 & \varepsilon_3 & -\varepsilon_2 & -\varepsilon_1\\
-\varepsilon_3 & \varepsilon_4 & \varepsilon_1 & -\varepsilon_2\\
\varepsilon_2 & -\varepsilon_1 & \varepsilon_4 & -\varepsilon_3
\end{bmatrix}.
$$

这就是书中的 \(H^*\)。

---

# 12. \(H^*\) 的紧凑写法是怎么来的？

先看

$$
\widetilde{\bar{\boldsymbol{\varepsilon}}}
=
\begin{bmatrix}
0&-\varepsilon_3&\varepsilon_2\\
\varepsilon_3&0&-\varepsilon_1\\
-\varepsilon_2&\varepsilon_1&0
\end{bmatrix}.
$$

因此

$$
\varepsilon_4 I_3
-
\widetilde{\bar{\boldsymbol{\varepsilon}}}
=
\begin{bmatrix}
\varepsilon_4&\varepsilon_3&-\varepsilon_2\\
-\varepsilon_3&\varepsilon_4&\varepsilon_1\\
\varepsilon_2&-\varepsilon_1&\varepsilon_4
\end{bmatrix}.
$$

再在右侧拼上一列

$$
-\bar{\boldsymbol{\varepsilon}}
=
\begin{bmatrix}
-\varepsilon_1\\
-\varepsilon_2\\
-\varepsilon_3
\end{bmatrix},
$$

就得到

$$
H^*(\boldsymbol{\varepsilon})
=
2
\begin{bmatrix}
\varepsilon_4 I_3
-
\widetilde{\bar{\boldsymbol{\varepsilon}}}
&
-\bar{\boldsymbol{\varepsilon}}
\end{bmatrix}.
$$

所以也可以先写成向量形式：

$$
\boldsymbol{\omega}
=
2
\left[
\left(
\varepsilon_4I_3
-
\widetilde{\bar{\boldsymbol{\varepsilon}}}
\right)
\dot{\bar{\boldsymbol{\varepsilon}}}
-
\bar{\boldsymbol{\varepsilon}}\dot\varepsilon_4
\right].
$$

这与展开的 \(3\times4\) 矩阵完全等价。

---

# 13. 单位欧拉参数的导数约束在这里起什么作用？

单位约束：

$$
\bar{\boldsymbol{\varepsilon}}^T
\bar{\boldsymbol{\varepsilon}}
+
\varepsilon_4^2
=
1.
$$

求导：

$$
\bar{\boldsymbol{\varepsilon}}^T
\dot{\bar{\boldsymbol{\varepsilon}}}
+
\varepsilon_4\dot\varepsilon_4
=
0.
$$

在直接展开 \(A^T\dot A\) 时，对角元素会出现与

$$
\bar{\boldsymbol{\varepsilon}}^T
\dot{\bar{\boldsymbol{\varepsilon}}}
+
\varepsilon_4\dot\varepsilon_4
$$

成比例的项。

由于上式为零，所以三个对角元素消失。

这与前面从

$$
A^TA=I
$$

推得 \(A^T\dot A\) 必为反对称矩阵是完全一致的。

也就是说：

- \(A^TA=I\) 是旋转矩阵层面的正交约束；
- \(\boldsymbol{\varepsilon}^T\boldsymbol{\varepsilon}=1\) 是欧拉参数层面的单位约束；

两者描述的是同一个“姿态只有三个独立自由度”的事实。

---

# 14. 为什么 \(\dot{\boldsymbol{\varepsilon}}\) 有四维，而角速度只有三维？

完整欧拉参数：

$$
\boldsymbol{\varepsilon}\in\mathbb R^4.
$$

但单位约束减少一个自由度：

$$
\boldsymbol{\varepsilon}^T
\boldsymbol{\varepsilon}
=
1.
$$

因此真正独立的速度维数是

$$
4-1=3.
$$

对单位约束求导：

$$
\boldsymbol{\varepsilon}^T
\dot{\boldsymbol{\varepsilon}}
=
0.
$$

所以 \(\dot{\boldsymbol{\varepsilon}}\) 只能位于单位四元数曲面的三维切空间内。

这正好可以通过一个 \(3\times4\) 的映射矩阵 \(H^*\) 映射为三维角速度：

$$
\boldsymbol{\omega}
=
H^*\dot{\boldsymbol{\varepsilon}}.
$$

---

# 15. 从 \(H^*\) 反过来得到 \(\dot{\boldsymbol{\varepsilon}}\)

定义

$$
G(\boldsymbol{\varepsilon})
=
\begin{bmatrix}
\varepsilon_4I_3
+
\widetilde{\bar{\boldsymbol{\varepsilon}}}\\
-\bar{\boldsymbol{\varepsilon}}^T
\end{bmatrix}.
$$

则

$$
G^T
=
\begin{bmatrix}
\varepsilon_4I_3
-
\widetilde{\bar{\boldsymbol{\varepsilon}}}
&
-\bar{\boldsymbol{\varepsilon}}
\end{bmatrix}.
$$

因此

$$
H^*
=
2G^T.
$$

利用单位约束可以证明

$$
G^TG=I_3.
$$

于是对应的欧拉参数一阶导数可以写成

$$
\dot{\boldsymbol{\varepsilon}}
=
\frac{1}{2}
G\boldsymbol{\omega}.
$$

也就是

$$
\dot{\boldsymbol{\varepsilon}}
=
\frac{1}{2}
\begin{bmatrix}
\varepsilon_4I_3
+
\widetilde{\bar{\boldsymbol{\varepsilon}}}\\
-\bar{\boldsymbol{\varepsilon}}^T
\end{bmatrix}
\boldsymbol{\omega}.
$$

这就是书中 \(H^*\) 后面给出的逆向关系。

---

# 16. 用单位姿态做一次最简单的自检

当刚体没有旋转时：

$$
\bar{\boldsymbol{\varepsilon}}
=
\begin{bmatrix}
0\\0\\0
\end{bmatrix},
\qquad
\varepsilon_4=1.
$$

此时

$$
H^*
=
2
\begin{bmatrix}
1&0&0&0\\
0&1&0&0\\
0&0&1&0
\end{bmatrix}.
$$

所以

$$
\boldsymbol{\omega}
=
2
\begin{bmatrix}
\dot\varepsilon_1\\
\dot\varepsilon_2\\
\dot\varepsilon_3
\end{bmatrix}.
$$

例如仅绕 \(z\) 轴发生很小的转动：

$$
\varepsilon_3
\approx
\frac{\theta}{2},
\qquad
\varepsilon_4
\approx
1.
$$

因此

$$
\omega_3
=
2\dot\varepsilon_3
\approx
2\frac{\dot\theta}{2}
=
\dot\theta.
$$

和普通角速度定义完全一致。

这个检查也解释了为什么四元数运动学中经常出现系数 \(2\) 或 \(1/2\)。

---

# 17. 从第七章到第九章的连接

到这里已经得到

$$
\boldsymbol{\omega}
=
H^*\dot{\boldsymbol{\varepsilon}}.
$$

第九章接下来会反复处理刚体上的固定向量或固定点。

例如刚体坐标系中的固定向量 \(\mathbf r\) 转到惯性系：

$$
\mathbf r^0=A\mathbf r.
$$

其时间导数最终会使用

$$
\dot A
=
A\widetilde{\boldsymbol{\omega}}
$$

以及

$$
\boldsymbol{\omega}
=
H^*\dot{\boldsymbol{\varepsilon}}.
$$

于是会自然出现

$$
A\widetilde{\mathbf r}^{\,T}H^*.
$$

这正是第九章铰约束 Jacobian 中频繁出现的结构。

因此整体关系是：

```text
欧拉参数 ε
   │
   ▼
姿态矩阵 A(ε)
   │
   │ 时间求导
   ▼
Ȧ
   │
   ▼
AᵀȦ = ω~
   │
   ▼
ω = H* ε̇
   │
   ▼
刚体点/方向向量速度
   │
   ▼
约束方程 Jacobian
```

---

# 18. 当前真正应该记住的核心，而不是背大矩阵

第一层：

$$
A^TA=I
\quad\Longrightarrow\quad
A^T\dot A
\text{ 是反对称矩阵}.
$$

第二层：

$$
A^T\dot A
=
\widetilde{\boldsymbol{\omega}}.
$$

第三层：

$$
A=A(\boldsymbol{\varepsilon}(t))
$$

所以 \(\dot{\boldsymbol{\varepsilon}}\) 由链式法则自然进入 \(\dot A\)。

第四层：

$$
\boldsymbol{\omega}
=
2
\left[
\left(
\varepsilon_4I_3
-
\widetilde{\bar{\boldsymbol{\varepsilon}}}
\right)
\dot{\bar{\boldsymbol{\varepsilon}}}
-
\bar{\boldsymbol{\varepsilon}}\dot\varepsilon_4
\right].
$$

最后才把它记成

$$
\boldsymbol{\omega}
=
H^*(\boldsymbol{\varepsilon})
\dot{\boldsymbol{\varepsilon}}.
$$

其中

$$
H^*
=
2
\begin{bmatrix}
\varepsilon_4I_3
-
\widetilde{\bar{\boldsymbol{\varepsilon}}}
&
-\bar{\boldsymbol{\varepsilon}}
\end{bmatrix}.
$$

---

## 后续建议

下一步不要立刻跳到第九章。

建议按下面两步继续：

1. 单独把
   $$
   \dot A=A\widetilde{\boldsymbol{\omega}}
   $$
   与
   $$
   \dot A=\widetilde{{}^O\boldsymbol{\omega}}A
   $$
   的坐标系区别重新推一遍；

2. 再推
   $$
   \frac{d}{dt}(A\mathbf r)
   $$
   和
   $$
   \frac{\partial(A\mathbf r)}
   {\partial\boldsymbol{\varepsilon}},
   $$
   这样第九章中的
   $$
   A\widetilde{\mathbf r}^{\,T}H^*
   $$
   就会自然出现。
