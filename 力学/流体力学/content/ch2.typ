#import "@preview/inelegant-note:0.9.1": *

= 张量代数基础

之前学过的物理量分为标量和向量，其实可以都归结于张量。

而我们知道，表示一个物理量有很多种方式，比如*实体形式*和*分量形式*。

*实体形式*具有*客观存在性*和*坐标无关性*；而*分量形式*依赖于选取的坐标系，是随着坐标变化的。

如应力：

$ bold(sigma) = mat(
  sigma_11, sigma_12, sigma_13;
  sigma_21, sigma_22, sigma_23;
  sigma_31, sigma_32, sigma_33
) $

左侧即为实体形式，右侧为分量形式。

== 张量的指标表示

=== 向量的表示

$ bold(a) = a_1 bold(e)_1 + a_2 bold(e)_2 + a_3 bold(e)_3 : mat(a_1, a_2, a_3)^"T" : a_i $

$ bold(b) = b_1 bold(e)_1 + b_2 bold(e)_2 + b_3 bold(e)_3 : mat(b_1, b_2, b_3)^"T" : b_j $

$ bold(a) + bold(b) : a_i + b_i $

$ bold(a) dot bold(b) = a_i b_i $

这里使用*爱因斯坦求和约定*：重复下标默认求和。

向量是一阶张量。

== 张量的指标表示

$ bold(C) = mat(
  c_11, c_12, c_13;
  c_21, c_22, c_23;
  c_31, c_32, c_33
) : C_(i j) $

矩阵是二阶张量。

== 张量运算

=== 点乘

$ bold(C) dot bold(D) : C_(i j) D_(j k) -> "结果为矩阵，二阶张量，剩两个自由指标" $

$ bold(C) dot bold(x) : C_(i j) x_j -> "结果为向量，剩一个自由指标" i $

$ bold(y) dot bold(D) dot bold(x) : y_i C_(i j) x_j -> "结果为数，剩零个自由指标" $

*相邻张量的相邻指标相同。*

=== 缩并：降两阶的手段

$ C_(i j) arrow.r.double C_(i i) $

二阶张量缩并之后就是矩阵的迹，即二阶张量对角线元素之和，也是二阶张量特征值之和。

*张量自身一对指标相同。*

=== 并积

$ bold(x) : x_i, quad bold(y) = y_j $

$ bold(x) bold(y) = x_i y_j $

*两个张量放在一起不做任何表示（指标不重复）。*

=== 指标表示规则

+ 每一项中，同一指标最多出现两次
  + 出现一次的指标是自由指标，可以任意取值；
  + 出现两次的指标是哑指标，自动求和，触发爱因斯坦求和约定。
+ 指标平衡：每一项中，自由指标数相同且一一对应。

== 向量乘法与指标运算

对于

$ bold(a) = a_i bold(e)_i, quad bold(b) = b_i bold(e)_i $

- *点乘*：$bold(a) bold(b) = a_i b_i$
- *叉乘*：$bold(a) times bold(b) = a_i b_j epsilon_(i j k)$
- *混合积*：$bold(a) times bold(b) dot bold(c) = a_i b_j c_k epsilon_(i j k)$

两个重要符号：

=== *Kronecker* $delta$ 符号

$ bold(e)_i bold(e)_j = delta_(i j) = cases(1 & quad i = j, 0 & quad i != j) $

这是一个单位阵。

*说明：*
+ $delta_(i j) = delta_(j i)$；
+ $a_i delta_(i j) = a_j, quad A_(m i) delta_(i j) = A_(m j)$，*Kronecker* $delta$ 符号有换脚标的一个效果。

  例：$bold(a) bold(e)_j = a_i bold(e)_i bold(e)_j = a_i delta_(i j) = a_j$

=== 置换符号 $epsilon$

$ bold(e)_i times bold(e)_j = epsilon_(i j k) bold(e)_k $

置换符号

$ epsilon_(i j k) = cases(
  0 & quad i\,j\,k "中有两个相同",
  1 & quad i\,j\,k "为" 1\,2\,3 "的偶排列",
  -1 & quad i\,j\,k "为" 1\,2\,3 "的奇排列",
) $

如下图，满足顺时针关系时为 1，逆时针为 -1。

#figure(
  image("../Figure/指标顺序.png", width: 45%),
  caption: [指标顺序],
)<fig-指标顺序>
