# 第九章：转动铰约束方程与 Jacobian 完整推导

本笔记承接前面已经完成的欧拉参数速度映射推导：

$$
\boxed{
\boldsymbol{\omega}
=
H^*(\boldsymbol{\varepsilon})
\dot{\boldsymbol{\varepsilon}}
}
$$
>
> 这里采用统一术语：
>
> - **根端（base / root）刚体**：\(B_{b(j)}\)
> - **梢端（move / tip）刚体**：\(B_{m(j)}\)
>
> 目标是不跳步地从第七章的 \(H^*\) 出发，推到第九章转动铰的完整 \(5\times 7\) 约束 Jacobian，包括：
>
> 1. 固定向量的欧拉参数 Jacobian
> 2. 3 个铰点位置重合约束
> 3. 2 个铰轴方向约束
> 4. 根端刚体的完整 Jacobian
> 5. 梢端刚体的完整 Jacobian

---

# 0. 符号约定

为了让公式不至于过长，先把书中的根端、梢端记号做一个对应。

根端刚体：

$$
B_b \equiv B_{b(j)}.
$$

梢端刚体：

$$
B_m \equiv B_{m(j)}.
$$

根端姿态矩阵：

$$
A_b \equiv A_{0,b(j)}.
$$

梢端姿态矩阵：

$$
A_m \equiv A_{0,m(j)}.
$$

根端欧拉参数：

$$
\boldsymbol{\varepsilon}_b.
$$

梢端欧拉参数：

$$
\boldsymbol{\varepsilon}_m.
$$

对应的角速度映射矩阵：

$$
H_b^*
=
H^*(\boldsymbol{\varepsilon}_b),
$$

$$
H_m^*
=
H^*(\boldsymbol{\varepsilon}_m).
$$

单个刚体的广义坐标写成

$$
\mathbf q_B
=
\begin{bmatrix}
\mathbf r_B\\
\boldsymbol{\varepsilon}_B
\end{bmatrix}
\in\mathbb R^7.
$$

其中：

- 前 3 个分量为刚体参考点的平移坐标；
- 后 4 个分量为单位欧拉参数。

---

# 1. 第七章到第九章的桥梁：固定向量 \(A\mathbf r\) 的导数

第九章中反复出现的核心结构是

$$
A\widetilde{\mathbf r}^{\,T}H^*.
\tag{1}\label{eq:1}
$$

先从第七章已经得到的公式开始推。

---

## 1.1 已知 \(A^T\dot A=\widetilde{\boldsymbol{\omega}}\)

前面已经得到

$$
A^T\dot A
=
\widetilde{\boldsymbol{\omega}}.
\tag{2}\label{eq:2}
$$

左乘 \(A\)（即式~\eqref{eq:2} 两边左乘 \(A\)）：

$$
A(A^T\dot A)
=
A\widetilde{\boldsymbol{\omega}}.
\tag{3}\label{eq:3}
$$

利用结合律：

$$
(AA^T)\dot A
=
A\widetilde{\boldsymbol{\omega}}.
\tag{4}\label{eq:4}
$$

因为旋转矩阵满足

$$
AA^T=I_3,
\tag{5}\label{eq:5}
$$

由式~\eqref{eq:15}、式~\eqref{eq:16}、式~\eqref{eq:17} 可得

$$
\boxed{
\widetilde{\boldsymbol{\omega}}\mathbf r
=
-\widetilde{\mathbf r}\boldsymbol{\omega}
}
\tag{6}\label{eq:6}
$$

这里的 \(\boldsymbol{\omega}\) 是在当前刚体系中表达的角速度。

---

## 1.2 刚体上的固定向量

设

$$
\mathbf r
=
\begin{bmatrix}
r_1\\
r_2\\
r_3
\end{bmatrix}
\tag{7}\label{eq:7}
$$

固定在刚体坐标系中。

“固定”指的是它在刚体系中的坐标不变，因此

$$
\boxed{
\dot{\mathbf r}=0.
}
\tag{8}\label{eq:8}
$$

这个向量在惯性系中的表达为

$$
\mathbf y=A\mathbf r.
\tag{9}\label{eq:9}
$$

对时间求导：

$$
\dot{\mathbf y}
=
\dot A\mathbf r
+
A\dot{\mathbf r}.
\tag{10}\label{eq:10}
$$

因为固定向量在刚体系坐标不变（式~\eqref{eq:8}）

$$
\dot{\mathbf r}=0,
\tag{11}\label{eq:11}
$$

结合式~\eqref{eq:11}（即 $\dot{\mathbf r}=0$）与链式法则，

$$
\boxed{
\frac{d}{dt}(A\mathbf r)
=
\dot A\mathbf r.
}
\tag{12}\label{eq:12}
$$

将式~\eqref{eq:13} 代入式~\eqref{eq:12}：

$$
\dot A=A\widetilde{\boldsymbol{\omega}},
\tag{13}\label{eq:13}
$$

得到

$$
\boxed{
\frac{d}{dt}(A\mathbf r)
=
A\widetilde{\boldsymbol{\omega}}\mathbf r.
}
\tag{14}\label{eq:14}
$$

---

## 1.3 将 \(\widetilde{\boldsymbol{\omega}}\mathbf r\) 改写成关于 \(\boldsymbol{\omega}\) 的线性形式

由叉乘矩阵定义：

$$
\widetilde{\boldsymbol{\omega}}\mathbf r
=
\boldsymbol{\omega}\times\mathbf r.
\tag{15}\label{eq:15}
$$

叉乘交换顺序会变号：

$$
\boldsymbol{\omega}\times\mathbf r
=
-\mathbf r\times\boldsymbol{\omega}.
\tag{16}\label{eq:16}
$$

而

$$
\mathbf r\times\boldsymbol{\omega}
=
\widetilde{\mathbf r}\boldsymbol{\omega}.
\tag{17}\label{eq:17}
$$

所以

$$
\widetilde{\boldsymbol{\omega}}\mathbf r
=
-\widetilde{\mathbf r}\boldsymbol{\omega}.
\tag{18}\label{eq:18}
$$

叉乘矩阵是反对称矩阵：

$$
\widetilde{\mathbf r}^{\,T}
=
-\widetilde{\mathbf r}.
\tag{19}\label{eq:19}
$$

结合式~\eqref{eq:18} 与反对称关系式~\eqref{eq:19}，

$$
\boxed{
\widetilde{\boldsymbol{\omega}}\mathbf r
=
\widetilde{\mathbf r}^{\,T}\boldsymbol{\omega}
}
\tag{20}\label{eq:20}
$$

完整逻辑可以写成

```text
ω~ r
 │
 ▼
ω × r
 │
 ▼
- r × ω
 │
 ▼
- r~ ω
 │
 ▼
r~ᵀ ω
```

将式~\eqref{eq:14} 中的 $\widetilde{\boldsymbol{\omega}}\mathbf r$ 用式~\eqref{eq:20} 替换，固定向量的时间导数变为

$$
\boxed{
\frac{d}{dt}(A\mathbf r)
=
A\widetilde{\mathbf r}^{\,T}
\boldsymbol{\omega}
}
\tag{21}\label{eq:21}
$$

---

## 1.4 代入 \(\boldsymbol{\omega}=H^*\dot{\boldsymbol{\varepsilon}}\)

第七章已经得到式~\eqref{eq:22}

$$
\boldsymbol{\omega}
=
H^*
\dot{\boldsymbol{\varepsilon}}.
\tag{22}\label{eq:22}
$$

将式~\eqref{eq:22} 代入式~\eqref{eq:21}：

$$
\frac{d}{dt}(A\mathbf r)
=
A\widetilde{\mathbf r}^{\,T}
H^*
\dot{\boldsymbol{\varepsilon}}.
\tag{23}\label{eq:23}
$$

因此得到完整形式（即式~\eqref{eq:24}）

$$
\boxed{
\frac{d}{dt}(A\mathbf r)
=
A\widetilde{\mathbf r}^{\,T}
H^*
\dot{\boldsymbol{\varepsilon}}.
}
\tag{24}\label{eq:24}
$$

---

## 1.5 再用链式法则看同一个导数

因为

$$
A=A(\boldsymbol{\varepsilon}),
\tag{25}\label{eq:25}
$$

且

$$
\boldsymbol{\varepsilon}
=
\boldsymbol{\varepsilon}(t),
\tag{26}\label{eq:26}
$$

所以

$$
A\mathbf r
=
A(\boldsymbol{\varepsilon}(t))\mathbf r.
\tag{27}\label{eq:27}
$$

按照链式法则：

$$
\frac{d}{dt}(A\mathbf r)
=
\frac{\partial(A\mathbf r)}
{\partial\boldsymbol{\varepsilon}}
\dot{\boldsymbol{\varepsilon}}.
\tag{28}\label{eq:28}
$$

将式~\eqref{eq:28} 与式~\eqref{eq:24} 比较：

$$
\frac{\partial(A\mathbf r)}
{\partial\boldsymbol{\varepsilon}}
\dot{\boldsymbol{\varepsilon}}
=
A\widetilde{\mathbf r}^{\,T}
H^*
\dot{\boldsymbol{\varepsilon}}.
\tag{29}\label{eq:29}
$$

于是对于满足单位欧拉参数约束的允许姿态变化，可以写成桥梁公式（式~\eqref{eq:30}）：桥梁公式（式~\eqref{eq:30}）：

$$
\boxed{
\frac{\partial(A\mathbf r)}
{\partial\boldsymbol{\varepsilon}}
=
A\widetilde{\mathbf r}^{\,T}H^*.
}
\tag{30}\label{eq:30}
$$

这就是第九章中反复出现的关键桥梁公式。

---

## 1.6 关于“偏导”的一个必要说明

单位欧拉参数满足

$$
\boldsymbol{\varepsilon}^T
\boldsymbol{\varepsilon}
=
1.
\tag{31}\label{eq:31}
$$

对时间求导：

$$
\boldsymbol{\varepsilon}^T
\dot{\boldsymbol{\varepsilon}}
=
0.
\tag{32}\label{eq:32}
$$

所以四个欧拉参数分量不是四个完全独立的自由变量。

因此这里的

$$
\frac{\partial(A\mathbf r)}
{\partial\boldsymbol{\varepsilon}}
=
A\widetilde{\mathbf r}^{\,T}H^*
\tag{33}\label{eq:33}
$$

应理解为：

> 对满足单位欧拉参数约束的合法姿态变化，\(A\mathbf r\) 对欧拉参数速度的运动学映射。

这也是为什么它可以直接用于约束速度和约束 Jacobian。

---

# 2. 转动铰为什么有 5 个约束？

空间中两个刚体之间一共有 6 个相对自由度：

$$
3\text{ 个平移}
+
3\text{ 个转动}.
\tag{34}\label{eq:34}
$$

转动铰只允许绕铰轴发生 1 个相对转动自由度。

因此必须约束

$$
6-1=5
\tag{35}\label{eq:35}
$$

个自由度。

这 5 个约束分成两部分：

$$
\boxed{
5=3+2
}
\tag{36}\label{eq:36}
$$

即：

1. 3 个铰点位置重合约束；
2. 2 个铰轴方向约束。

---

# 3. 三个铰点位置重合约束

设根端刚体上的铰接点为 \(B_j\)，梢端刚体上的铰接点为 \(M_j\)。

---

## 3.1 根端铰点的位置

根端刚体参考点记为 \(O_b\)。

从 \(O_b\) 指向根端铰点 \(B_j\) 的向量，在根端刚体系中记为

$$
\mathbf r_{O_bB_j|b}.
\tag{37}\label{eq:37}
$$

它在惯性系中的铰点位置为

$$
\boxed{
\mathbf r_{O_0B_j|0}
=
\mathbf r_{O_0O_b|0}
+
A_b
\mathbf r_{O_bB_j|b}.
}
\tag{38}\label{eq:38}
$$

---

## 3.2 梢端铰点的位置

梢端刚体参考点记为 \(O_m\)。

从 \(O_m\) 指向梢端铰点 \(M_j\) 的向量，在梢端刚体系中记为

$$
\mathbf r_{O_mM_j|m}.
\tag{39}\label{eq:39}
$$

它在惯性系中的位置为

$$
\boxed{
\mathbf r_{O_0M_j|0}
=
\mathbf r_{O_0O_m|0}
+
A_m
\mathbf r_{O_mM_j|m}.
}
\tag{40}\label{eq:40}
$$

---

## 3.3 铰点重合条件

转动铰要求两个铰点在空间中重合：

$$
\mathbf r_{O_0M_j|0}
=
\mathbf r_{O_0B_j|0}.
\tag{41}\label{eq:41}
$$

由重合条件（式~\eqref{eq:41}）移项，定义位置约束（式~\eqref{eq:42}）：

$$
\boxed{
\mathbf c_p
=
\mathbf r_{O_0M_j|0}
-
\mathbf r_{O_0B_j|0}
=
0.
}
\tag{42}\label{eq:42}
$$

完全展开：

$$
\boxed{
\mathbf c_p
=
\mathbf r_{O_0O_m|0}
+
A_m\mathbf r_{O_mM_j|m}
-
\mathbf r_{O_0O_b|0}
-
A_b\mathbf r_{O_bB_j|b}
=
0.
}
\tag{43}\label{eq:43}
$$

这是一个三维向量方程，因此对应 3 个标量约束。

---

# 4. 两个铰轴方向约束

三个位置约束只保证两个铰点重合。

此时两个刚体仍然可能发生 3 个方向上的相对转动。

真正的转动铰只允许绕铰轴方向转动，所以还必须禁止另外两个相对转动方向。

因此还需要 2 个方向约束。

---

## 4.1 梢端铰轴变换到根端坐标系

按照本节采用的记号，设梢端铰轴在梢端刚体系中的单位方向为

$$
\mathbf n_{J_j}.
\tag{44}\label{eq:44}
$$

先用 \(A_m\) 将它从梢端坐标系变换到惯性系：

$$
A_m\mathbf n_{J_j}.
\tag{45}\label{eq:45}
$$

再用 \(A_b^T\) 将这个惯性系向量变换到根端坐标系：

$$
\boxed{
\mathbf y
=
A_b^TA_m\mathbf n_{J_j}.
}
\tag{46}\label{eq:46}
$$

所以 \(\mathbf y\) 的含义是：

> 梢端铰轴方向，用根端刚体坐标系表示。

---

## 4.2 为什么只需要两个方向约束？

在根端坐标系中，以根端铰轴为法向方向。

在垂直于根端铰轴的平面内，选择两个互相独立的单位向量

$$
\mathbf t_1,
\qquad
\mathbf t_2.
\tag{47}\label{eq:47}
$$

组成矩阵

$$
\boxed{
T_{J_j}
=
\begin{bmatrix}
\mathbf t_1&
\mathbf t_2
\end{bmatrix}
\in\mathbb R^{3\times2}.
}
\tag{48}\label{eq:48}
$$

如果梢端铰轴与根端铰轴完全平行，那么梢端铰轴在这两个垂直方向上的投影都必须为零：

$$
\mathbf t_1^T\mathbf y=0,
\tag{49}\label{eq:49}
$$

$$
\mathbf t_2^T\mathbf y=0.
\tag{50}\label{eq:50}
$$

合并起来：

$$
\boxed{
T_{J_j}^T\mathbf y=0.
}
\tag{51}\label{eq:51}
$$

代入

$$
\mathbf y=A_b^TA_m\mathbf n_{J_j},
\tag{52}\label{eq:52}
$$

得到方向约束：

$$
\boxed{
\mathbf c_r
=
T_{J_j}^T
A_b^TA_m
\mathbf n_{J_j}
=
0.
}
\tag{53}\label{eq:53}
$$

因为

$$
T_{J_j}^T\in\mathbb R^{2\times3},
\tag{54}\label{eq:54}
$$

所以

$$
\mathbf c_r\in\mathbb R^2.
\tag{55}\label{eq:55}
$$

这正好给出 2 个方向约束。

---

# 5. 转动铰完整约束方程

将位置约束（式~\eqref{eq:42}）与方向约束（式~\eqref{eq:53}）上下拼接，得到完整约束（式~\eqref{eq:56}）：

$$
\boxed{
\mathbf c_{J_j}
=
\begin{bmatrix}
\mathbf c_p\\
\mathbf c_r
\end{bmatrix}
=
0.
}
\tag{56}\label{eq:56}
$$

即

$$
\boxed{
\mathbf c_{J_j}
=
\begin{bmatrix}
\mathbf r_{O_0O_m|0}
+
A_m\mathbf r_{O_mM_j|m}
-
\mathbf r_{O_0O_b|0}
-
A_b\mathbf r_{O_bB_j|b}
\\[2mm]
T_{J_j}^T
A_b^TA_m
\mathbf n_{J_j}
\end{bmatrix}
=
0.
}
\tag{57}\label{eq:57}
$$

维数为

$$
3+2=5.
\tag{58}\label{eq:58}
$$

因此：

$$
\boxed{
\mathbf c_{J_j}\in\mathbb R^5.
}
\tag{59}\label{eq:59}
$$

---

# 6. 根端（base / root）刚体的完整约束 Jacobian

根端刚体广义坐标：

$$
\boxed{
\mathbf q_b
=
\begin{bmatrix}
\mathbf r_{O_0O_b|0}\\
\boldsymbol{\varepsilon}_b
\end{bmatrix}
\in\mathbb R^7.
}
\tag{60}\label{eq:60}
$$

需要计算

$$
\frac{\partial\mathbf c_{J_j}}
{\partial\mathbf q_b}.
\tag{61}\label{eq:61}
$$

---

## 6.1 根端对位置约束的平移 Jacobian

由位置约束（式~\eqref{eq:42}，展开为式~\eqref{eq:62}）：

$$
\mathbf c_p
=
\mathbf r_{O_0O_m|0}
+
A_m\mathbf r_{O_mM_j|m}
-
\mathbf r_{O_0O_b|0}
-
A_b\mathbf r_{O_bB_j|b}.
\tag{62}\label{eq:62}
$$

其中关于根端平移坐标的部分只有

$$
-\mathbf r_{O_0O_b|0}.
\tag{63}\label{eq:63}
$$

因此

$$
\boxed{
\frac{\partial\mathbf c_p}
{\partial\mathbf r_{O_0O_b|0}}
=
-I_3.
}
\tag{64}\label{eq:64}
$$

---

## 6.2 根端对位置约束的姿态 Jacobian

关于根端欧拉参数的部分只有

$$
-A_b\mathbf r_{O_bB_j|b}.
\tag{65}\label{eq:65}
$$

利用桥梁公式（式~\eqref{eq:30}）

$$
\frac{\partial(A\mathbf r)}
{\partial\boldsymbol{\varepsilon}}
=
A\widetilde{\mathbf r}^{\,T}H^*,
\tag{66}\label{eq:66}
$$

得到（即式~\eqref{eq:67}）

$$
\boxed{
\frac{\partial\mathbf c_p}
{\partial\boldsymbol{\varepsilon}_b}
=
-
A_b
\widetilde{\mathbf r}_{O_bB_j|b}^{\,T}
H_b^*.
}
\tag{67}\label{eq:67}
$$

所以位置约束对应的根端 Jacobian 为

$$
\boxed{
\frac{\partial\mathbf c_p}
{\partial\mathbf q_b}
=
-
\begin{bmatrix}
I_3
&
A_b
\widetilde{\mathbf r}_{O_bB_j|b}^{\,T}
H_b^*
\end{bmatrix}.
}
\tag{68}\label{eq:68}
$$

---

## 6.3 根端平移不会改变铰轴方向

方向约束为

$$
\mathbf c_r
=
T_{J_j}^T
A_b^TA_m
\mathbf n_{J_j}.
\tag{69}\label{eq:69}
$$

这里没有根端参考点位置

$$
\mathbf r_{O_0O_b|0},
\tag{70}\label{eq:70}
$$

所以

$$
\boxed{
\frac{\partial\mathbf c_r}
{\partial\mathbf r_{O_0O_b|0}}
=
O_{2\times3}.
}
\tag{71}\label{eq:71}
$$

---

## 6.4 根端姿态变化如何改变梢端铰轴在根端系中的表示？

定义

$$
\boxed{
\mathbf y
=
A_b^TA_m\mathbf n_{J_j}.
}
$$

于是

$$
\mathbf c_r
=
T_{J_j}^T\mathbf y.
\tag{72}\label{eq:72}
$$

现在只考虑根端姿态变化。

梢端的

$$
A_m\mathbf n_{J_j}
\tag{73}\label{eq:73}
$$

保持不变。

所以

$$
\dot{\mathbf y}
=
\dot A_b^T
A_m\mathbf n_{J_j}.
\tag{74}\label{eq:74}
$$

---

## 6.5 先推 \(\dot A_b^T\)

前面已经有式~\eqref{eq:75}

$$
\dot A_b
=
A_b\widetilde{\boldsymbol{\omega}}_b.
\tag{75}\label{eq:75}
$$

两边转置：

$$
\dot A_b^T
=
(A_b\widetilde{\boldsymbol{\omega}}_b)^T.
\tag{76}\label{eq:76}
$$

利用转置性质（式~\eqref{eq:77}）

$$
(AB)^T=B^TA^T,
\tag{77}\label{eq:77}
$$

得到

$$
\dot A_b^T
=
\widetilde{\boldsymbol{\omega}}_b^{\,T}
A_b^T.
\tag{78}\label{eq:78}
$$

又因为叉乘矩阵反对称（式~\eqref{eq:19}）：

$$
\widetilde{\boldsymbol{\omega}}_b^{\,T}
=
-\widetilde{\boldsymbol{\omega}}_b,
\tag{79}\label{eq:79}
$$

所以

$$
\boxed{
\dot A_b^T
=
-\widetilde{\boldsymbol{\omega}}_bA_b^T.
}
\tag{80}\label{eq:80}
$$

---

## 6.6 代回 \(\dot{\mathbf y}\)

有

$$
\dot{\mathbf y}
=
\dot A_b^TA_m\mathbf n_{J_j}.
$$

将式~\eqref{eq:80} 代入式~\eqref{eq:74}：

$$
\dot{\mathbf y}
=
-\widetilde{\boldsymbol{\omega}}_b
A_b^TA_m
\mathbf n_{J_j}.
\tag{81}\label{eq:81}
$$

根据式~\eqref{eq:46}（即 $\mathbf y=A_b^TA_m\mathbf n_{J_j}$）：

$$
\mathbf y
=
A_b^TA_m\mathbf n_{J_j},
$$

所以

$$
\dot{\mathbf y}
=
-\widetilde{\boldsymbol{\omega}}_b\mathbf y.
\tag{82}\label{eq:82}
$$

由叉乘定义：

$$
-\widetilde{\boldsymbol{\omega}}_b\mathbf y
=
-\boldsymbol{\omega}_b\times\mathbf y.
\tag{83}\label{eq:83}
$$

交换叉乘顺序：

$$
-\boldsymbol{\omega}_b\times\mathbf y
=
\mathbf y\times\boldsymbol{\omega}_b.
\tag{84}\label{eq:84}
$$

所以

$$
\dot{\mathbf y}
=
\widetilde{\mathbf y}
\boldsymbol{\omega}_b.
\tag{85}\label{eq:85}
$$

再利用反对称性质（式~\eqref{eq:86}）

$$
\widetilde{\mathbf y}
=
-\widetilde{\mathbf y}^{\,T},
\tag{86}\label{eq:86}
$$

也可以写成

$$
\boxed{
\dot{\mathbf y}
=
-\widetilde{\mathbf y}^{\,T}
\boldsymbol{\omega}_b.
}
\tag{87}\label{eq:87}
$$

---

## 6.7 引入根端的 \(H_b^*\)

根端角速度满足式~\eqref{eq:88}

$$
\boldsymbol{\omega}_b
=
H_b^*
\dot{\boldsymbol{\varepsilon}}_b.
\tag{88}\label{eq:88}
$$

所以

$$
\dot{\mathbf y}
=
-\widetilde{\mathbf y}^{\,T}
H_b^*
\dot{\boldsymbol{\varepsilon}}_b.
\tag{89}\label{eq:89}
$$

按照链式法则：

$$
\dot{\mathbf y}
=
\frac{\partial\mathbf y}
{\partial\boldsymbol{\varepsilon}_b}
\dot{\boldsymbol{\varepsilon}}_b.
\tag{90}\label{eq:90}
$$

将式~\eqref{eq:89} 与式~\eqref{eq:90} 比较可得

$$
\boxed{
\frac{\partial\mathbf y}
{\partial\boldsymbol{\varepsilon}_b}
=
-\widetilde{\mathbf y}^{\,T}H_b^*.
}
\tag{91}\label{eq:91}
$$

把式~\eqref{eq:46}（即 $\mathbf y=A_b^TA_m\mathbf n_{J_j}$）

$$
\mathbf y=A_b^TA_m\mathbf n_{J_j}
\tag{92}\label{eq:92}
$$

代回：

$$
\boxed{
\frac{\partial\mathbf y}
{\partial\boldsymbol{\varepsilon}_b}
=
-
\left[
A_b^TA_m\mathbf n_{J_j}
\right]_\times^T
H_b^*.
}
\tag{93}\label{eq:93}
$$

---

## 6.8 根端方向约束的姿态 Jacobian

因为

$$
\mathbf c_r
=
T_{J_j}^T\mathbf y,
\tag{94}\label{eq:94}
$$

所以

$$
\frac{\partial\mathbf c_r}
{\partial\boldsymbol{\varepsilon}_b}
=
T_{J_j}^T
\frac{\partial\mathbf y}
{\partial\boldsymbol{\varepsilon}_b}.
\tag{95}\label{eq:95}
$$

将式~\eqref{eq:93} 代入式~\eqref{eq:95}：

$$
\boxed{
\frac{\partial\mathbf c_r}
{\partial\boldsymbol{\varepsilon}_b}
=
-
T_{J_j}^T
\left[
A_b^TA_m\mathbf n_{J_j}
\right]_\times^T
H_b^*.
}
\tag{96}\label{eq:96}
$$

---

## 6.9 根端完整 \(5\times7\) Jacobian

把位置约束与方向约束上下拼起来：

$$
\frac{\partial\mathbf c_{J_j}}
{\partial\mathbf q_b}
=
\begin{bmatrix}
-I_3
&
-
A_b
\widetilde{\mathbf r}_{O_bB_j|b}^{\,T}
H_b^*
\\[2mm]
O_{2\times3}
&
-
T_{J_j}^T
\left[
A_b^TA_m\mathbf n_{J_j}
\right]_\times^T
H_b^*
\end{bmatrix}.
\tag{97}\label{eq:97}
$$

将整体负号提出：

$$
\boxed{
\frac{\partial\mathbf c_{J_j}}
{\partial\mathbf q_b}
=
-
\begin{bmatrix}
I_3
&
A_b
\widetilde{\mathbf r}_{O_bB_j|b}^{\,T}
H_b^*
\\[2mm]
O_{2\times3}
&
T_{J_j}^T
\left[
A_b^TA_m\mathbf n_{J_j}
\right]_\times^T
H_b^*
\end{bmatrix}.
}
\tag{98}\label{eq:98}
$$

这就是根端（base / root）刚体对应的完整约束 Jacobian。

---

# 7. 梢端（move / tip）刚体的完整约束 Jacobian

梢端刚体广义坐标：

$$
\boxed{
\mathbf q_m
=
\begin{bmatrix}
\mathbf r_{O_0O_m|0}\\
\boldsymbol{\varepsilon}_m
\end{bmatrix}
\in\mathbb R^7.
}
\tag{99}\label{eq:99}
$$

需要计算

$$
\frac{\partial\mathbf c_{J_j}}
{\partial\mathbf q_m}.
\tag{100}\label{eq:100}
$$

---

## 7.1 梢端对位置约束的平移 Jacobian

位置约束中与梢端平移有关的是

$$
+\mathbf r_{O_0O_m|0}.
\tag{101}\label{eq:101}
$$

因此

$$
\boxed{
\frac{\partial\mathbf c_p}
{\partial\mathbf r_{O_0O_m|0}}
=
I_3.
}
\tag{102}\label{eq:102}
$$

---

## 7.2 梢端对位置约束的姿态 Jacobian

梢端姿态项为

$$
+A_m\mathbf r_{O_mM_j|m}.
\tag{103}\label{eq:103}
$$

利用桥梁公式（式~\eqref{eq:30}）：

$$
\boxed{
\frac{\partial\mathbf c_p}
{\partial\boldsymbol{\varepsilon}_m}
=
A_m
\widetilde{\mathbf r}_{O_mM_j|m}^{\,T}
H_m^*.
}
\tag{104}\label{eq:104}
$$

所以梢端位置约束 Jacobian 为（式~\eqref{eq:105}）

$$
\boxed{
\frac{\partial\mathbf c_p}
{\partial\mathbf q_m}
=
\begin{bmatrix}
I_3
&
A_m
\widetilde{\mathbf r}_{O_mM_j|m}^{\,T}
H_m^*
\end{bmatrix}.
}
\tag{105}\label{eq:105}
$$

---

## 7.3 梢端平移不会改变铰轴方向

由方向约束（式~\eqref{eq:53}）

$$
\mathbf c_r
=
T_{J_j}^TA_b^TA_m\mathbf n_{J_j}
\tag{106}\label{eq:106}
$$

不含梢端平移坐标，因此

$$
\boxed{
\frac{\partial\mathbf c_r}
{\partial\mathbf r_{O_0O_m|0}}
=
O_{2\times3}.
}
\tag{107}\label{eq:107}
$$

---

## 7.4 梢端姿态变化如何改变 \(\mathbf y\)？

仍然定义（同式~\eqref{eq:46}）

$$
\mathbf y
=
A_b^TA_m\mathbf n_{J_j}.
\tag{108}\label{eq:108}
$$

这一次根端 \(A_b\) 不变，只有梢端 \(A_m\) 变化。

所以

$$
\dot{\mathbf y}
=
A_b^T
\dot A_m
\mathbf n_{J_j}.
\tag{109}\label{eq:109}
$$

前面有式~\eqref{eq:110}

$$
\dot A_m
=
A_m
\widetilde{\boldsymbol{\omega}}_m.
\tag{110}\label{eq:110}
$$

将式~\eqref{eq:110} 代入式~\eqref{eq:109}：

$$
\dot{\mathbf y}
=
A_b^TA_m
\widetilde{\boldsymbol{\omega}}_m
\mathbf n_{J_j}.
\tag{111}\label{eq:111}
$$

---

## 7.5 改写 \(\widetilde{\boldsymbol{\omega}}_m\mathbf n_{J_j}\)

根据叉乘定义（式~\eqref{eq:15}）

$$
\widetilde{\boldsymbol{\omega}}_m\mathbf n_{J_j}
=
\boldsymbol{\omega}_m
\times
\mathbf n_{J_j}.
\tag{112}\label{eq:112}
$$

交换顺序：

$$
\boldsymbol{\omega}_m
\times
\mathbf n_{J_j}
=
-
\mathbf n_{J_j}
\times
\boldsymbol{\omega}_m.
\tag{113}\label{eq:113}
$$

所以

$$
\widetilde{\boldsymbol{\omega}}_m\mathbf n_{J_j}
=
-
\widetilde{\mathbf n}_{J_j}
\boldsymbol{\omega}_m.
\tag{114}\label{eq:114}
$$

又因为反对称（式~\eqref{eq:115}）

$$
\widetilde{\mathbf n}_{J_j}^{\,T}
=
-
\widetilde{\mathbf n}_{J_j},
\tag{115}\label{eq:115}
$$

因此

$$
\boxed{
\widetilde{\boldsymbol{\omega}}_m\mathbf n_{J_j}
=
\widetilde{\mathbf n}_{J_j}^{\,T}
\boldsymbol{\omega}_m.
}
\tag{116}\label{eq:116}
$$

---

## 7.6 引入梢端的 \(H_m^*\)

将式~\eqref{eq:116} 代回式~\eqref{eq:111}：

$$
\dot{\mathbf y}
=
A_b^TA_m
\widetilde{\mathbf n}_{J_j}^{\,T}
\boldsymbol{\omega}_m.
\tag{117}\label{eq:117}
$$

梢端角速度满足式~\eqref{eq:118}

$$
\boldsymbol{\omega}_m
=
H_m^*
\dot{\boldsymbol{\varepsilon}}_m.
\tag{118}\label{eq:118}
$$

所以

$$
\dot{\mathbf y}
=
A_b^TA_m
\widetilde{\mathbf n}_{J_j}^{\,T}
H_m^*
\dot{\boldsymbol{\varepsilon}}_m.
\tag{119}\label{eq:119}
$$

另一方面，链式法则：

$$
\dot{\mathbf y}
=
\frac{\partial\mathbf y}
{\partial\boldsymbol{\varepsilon}_m}
\dot{\boldsymbol{\varepsilon}}_m.
\tag{120}\label{eq:120}
$$

将式~\eqref{eq:119} 与式~\eqref{eq:120} 比较得到

$$
\boxed{
\frac{\partial\mathbf y}
{\partial\boldsymbol{\varepsilon}_m}
=
A_b^TA_m
\widetilde{\mathbf n}_{J_j}^{\,T}
H_m^*.
}
\tag{121}\label{eq:121}
$$

---

## 7.7 梢端方向约束的姿态 Jacobian

由方向约束式~\eqref{eq:94}（即 $\mathbf c_r=T_{J_j}^T\mathbf y$）

$$
\mathbf c_r
=
T_{J_j}^T\mathbf y,
$$

所以

$$
\frac{\partial\mathbf c_r}
{\partial\boldsymbol{\varepsilon}_m}
=
T_{J_j}^T
\frac{\partial\mathbf y}
{\partial\boldsymbol{\varepsilon}_m}.
\tag{122}\label{eq:122}
$$

将式~\eqref{eq:121} 代入式~\eqref{eq:122}：

$$
\boxed{
\frac{\partial\mathbf c_r}
{\partial\boldsymbol{\varepsilon}_m}
=
T_{J_j}^T
A_b^TA_m
\widetilde{\mathbf n}_{J_j}^{\,T}
H_m^*.
}
\tag{123}\label{eq:123}
$$

---

## 7.8 梢端完整 \(5\times7\) Jacobian

把位置约束（式~\eqref{eq:105}）和方向约束（式~\eqref{eq:123}）拼起来，得到梢端完整 Jacobian（式~\eqref{eq:124}）：

$$
\boxed{
\frac{\partial\mathbf c_{J_j}}
{\partial\mathbf q_m}
=
\begin{bmatrix}
I_3
&
A_m
\widetilde{\mathbf r}_{O_mM_j|m}^{\,T}
H_m^*
\\[2mm]
O_{2\times3}
&
T_{J_j}^T
A_b^TA_m
\widetilde{\mathbf n}_{J_j}^{\,T}
H_m^*
\end{bmatrix}.
}
\tag{124}\label{eq:124}
$$

这就是梢端（move / tip）刚体对应的完整约束 Jacobian。

---

# 8. 两个完整 Jacobian 并列

根端（即式~\eqref{eq:98}）：

$$
\boxed{
\frac{\partial\mathbf c_{J_j}}
{\partial\mathbf q_b}
=
-
\begin{bmatrix}
I_3
&
A_b
\widetilde{\mathbf r}_{O_bB_j|b}^{\,T}
H_b^*
\\[2mm]
O_{2\times3}
&
T_{J_j}^T
\left[
A_b^TA_m\mathbf n_{J_j}
\right]_\times^T
H_b^*
\end{bmatrix}
}
\tag{125}\label{eq:125}
$$

梢端（即式~\eqref{eq:124}）：

$$
\boxed{
\frac{\partial\mathbf c_{J_j}}
{\partial\mathbf q_m}
=
\begin{bmatrix}
I_3
&
A_m
\widetilde{\mathbf r}_{O_mM_j|m}^{\,T}
H_m^*
\\[2mm]
O_{2\times3}
&
T_{J_j}^T
A_b^TA_m
\widetilde{\mathbf n}_{J_j}^{\,T}
H_m^*
\end{bmatrix}
}
\tag{126}\label{eq:126}
$$

---

# 9. 每个分块的物理意义

两个大矩阵看起来复杂，但实际上都只有四类结构。

| Jacobian 分块 | 物理意义 |
|---|---|
| \(I_3\) 或 \(-I_3\) | 刚体平移直接改变铰点位置 |
| \(A\widetilde{\mathbf r}^{\,T}H^*\) | 刚体旋转使偏置铰点产生位置变化 |
| \(O_{2\times3}\) | 刚体平移不会改变铰轴方向 |
| 右下角 \(2\times4\) 块 | 刚体旋转改变铰轴方向 |

因此可以把完整结构记成：

```text
                    单个刚体广义坐标
                平移               姿态
                 │                  │

位置约束         ±I           ±A r~ᵀ H*
              ───────────────────────────
方向约束          0          铰轴方向 Jacobian
```

---

# 10. 为什么根端与梢端的符号不同？

位置约束（式~\eqref{eq:42}）也可写成

$$
\mathbf c_p
=
\mathbf r_{M_j}
-
\mathbf r_{B_j}.
\tag{127}\label{eq:127}
$$

所以：

- 梢端项 \(\mathbf r_{M_j}\) 前面是正号；
- 根端项 \(\mathbf r_{B_j}\) 前面是负号。

这与普通函数

$$
f=x_m-x_b
\tag{128}\label{eq:128}
$$

完全一样（与根端式~\eqref{eq:64}、梢端式~\eqref{eq:102} 的符号一致）：

$$
\frac{\partial f}{\partial x_b}
=
-1,
\tag{129}\label{eq:129}
$$

$$
\frac{\partial f}{\partial x_m}
=
1.
\tag{130}\label{eq:130}
$$

方向约束中根端和梢端的符号差异，则来自：

- 根端变化作用在 \(A_b^T\) 上；
- 梢端变化作用在 \(A_m\) 上；

而式~\eqref{eq:80}（即 $\dot A_b^T=-\widetilde{\boldsymbol{\omega}}_bA_b^T$）

$$
\dot A_b^T
=
-\widetilde{\boldsymbol{\omega}}_bA_b^T
\tag{131}\label{eq:131}
$$

本身带有负号。

---

# 11. 维数检查

转动铰有 5 个约束：

$$
\mathbf c_{J_j}\in\mathbb R^5.
\tag{132}\label{eq:132}
$$

单个刚体广义坐标为

$$
\mathbf q_B\in\mathbb R^7.
\tag{133}\label{eq:133}
$$

因此

$$
\boxed{
\frac{\partial\mathbf c_{J_j}}
{\partial\mathbf q_B}
\in
\mathbb R^{5\times7}.
}
\tag{134}\label{eq:134}
$$

位置约束部分：

$$
I_3
\in\mathbb R^{3\times3}.
\tag{135}\label{eq:135}
$$

姿态部分：

$$
A
\widetilde{\mathbf r}^{\,T}
H^*
\tag{136}\label{eq:136}
$$

尺寸为

$$
(3\times3)
(3\times3)
(3\times4)
=
3\times4.
\tag{137}\label{eq:137}
$$

所以位置约束一行块为

$$
3\times(3+4)
=
3\times7.
\tag{138}\label{eq:138}
$$

方向约束：

$$
O_{2\times3}
\tag{139}\label{eq:139}
$$

加一个 \(2\times4\) 姿态块：

$$
2\times7.
\tag{140}\label{eq:140}
$$

最终：

$$
(3+2)\times7
=
5\times7.
\tag{141}\label{eq:141}
$$

维数完全一致。

---

# 12. 第七章到第九章的完整因果链

```text
单位欧拉参数 ε
       │
       ▼
姿态矩阵 A(ε)
       │
       ▼
Aᵀ Ȧ = ω~
       │
       ▼
Ȧ = A ω~
       │
       ▼
刚体固定向量 Ar
       │
       ▼
d(Ar)/dt = A ω~ r
       │
       ▼
ω~ r = r~ᵀ ω
       │
       ▼
d(Ar)/dt = A r~ᵀ ω
       │
       ▼
ω = H* ε̇
       │
       ▼
d(Ar)/dt = A r~ᵀ H* ε̇
       │
       ▼
∂(Ar)/∂ε = A r~ᵀ H*
       │
       ├────────────────────────┐
       ▼                        ▼
3 个铰点位置约束           2 个铰轴方向约束
r_M - r_B = 0          Tᵀ A_bᵀ A_m n = 0
       │                        │
       └───────────┬────────────┘
                   ▼
           对根端、梢端分别求导
                   │
                   ▼
         两个完整 5×7 Jacobian
```

---

# 13. 当前最值得记住的三层结构

第一层，第七章（即式~\eqref{eq:22}）：

$$
\boxed{
\boldsymbol{\omega}
=
H^*\dot{\boldsymbol{\varepsilon}}
}
\tag{142}\label{eq:142}
$$

第二层，桥梁公式（即式~\eqref{eq:30}）：

$$
\boxed{
\frac{\partial(A\mathbf r)}
{\partial\boldsymbol{\varepsilon}}
=
A\widetilde{\mathbf r}^{\,T}H^*
}
\tag{143}\label{eq:143}
$$

第三层，转动铰完整约束（即式~\eqref{eq:56}）：

$$
\boxed{
\mathbf c_{J_j}
=
\begin{bmatrix}
\mathbf r_{M_j}-\mathbf r_{B_j}\\[1mm]
T_{J_j}^TA_b^TA_m\mathbf n_{J_j}
\end{bmatrix}
=
0.
}
\tag{144}\label{eq:144}
$$

两个完整 Jacobian（根端式~\eqref{eq:98}、梢端式~\eqref{eq:124}）都只是对这两类约束分别求导后的结果，并不是需要独立背诵的新公式。
