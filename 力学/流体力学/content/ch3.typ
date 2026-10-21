#import "@preview/inelegant-note:0.9.1": *
#import "boxes.typ": property-showy

= 流体的物理性质

== 流体的连续介质模型

什么是固体？什么是流体？

初高中我们从分子间距离，也就是微观的角度去进行分类和理解。

流体力学研究的是宏观的性质，我们从宏观的视角去重新认识流体。

*流体的宏观性质：* 没有固定的形状，不一定具有固定的体积，且不能通过静止变形抵抗剪切。

*流体的分子输运性质：* 通过随机运动交换质量、动量、能量。对应的宏观效应是扩散、粘性和热传导。

=== 连续介质模型

+ 流体是连续分布的物质，它可以无限分割为具有一定质量的宏观微元体（物理模型）；
+ 在不发生化学反应和离解等非平衡热力学过程的运动流体中，微元体内流体状态服从热力学关系（仅有两个热力学参数是独立的，且与流体的历史无关）；
+ 除特殊面（界面、激波等）外，流体的力学和热力学状态参数在时空中是连续分布的，并且通常认为是无限可微的。

*连续介质模型的适用范围：* 流体的运动尺度远远大于流体分子运动的平均自由程。而王先智《物理流体力学》@wang2018 给出了流体力学适用条件为：体积元尺寸比分子尺寸大两到三个数量级。

为了衡量连续介质模型是否适用，给出了

#definition-showy(title: "努森数")[
  $ K n = lambda / L $
  即分子自由程 / 流动特征长度。
]

#figure(
  image("../Figure/空间尺度的三个层次.png", width: 100%),
  caption: [空间尺度的三个层次],
)<fig-空间尺度的三个层次>

=== 流体微团及流体质点

==== 流体微团

#definition-showy(title: "流体微团")[
  把流体无限分割为具有一定质量的微元，它是研究流体运动的最小单元，称为“流体微团”。
]

#property-showy[
  流体微团应是宏观上无限小，微观上无限大的质量体。
]

==== 流体质点

当不需要考虑流体微团的体积和变形，只研究它的位移和各个物理状态时，我们可以把它视作没有体积的质点，这时我们称流体微团为流体质点。

==== 流体物理量

空间任一点上的流体物理量（如密度、温度、速度等）是指位于该点上的流体质点的物理量，是宏观平均量的极限值。

如：流体在某一点上的密度定义为

$ rho(P) = lim_(Delta V -> 0) (Delta M)/(Delta V) $

根据连续介质模型，流体中每一点都被相应的流体质点所占据，流体质点可以用时空中的一个点 $(bold(x), t)$ 来标记，因此流体宏观物性的不均匀性，可以用时空变量 $(bold(x), t)$ 的函数来描述，即是一个*场函数*。

== 流体的基本性质

=== 流体的易流动性

流体在任意微小的剪切力作用下发生连续不断变形的性质。这是流体的本质属性。即流体无法通过静止变形抵抗剪切。

=== 流体的粘性

#definition-showy(title: "粘性")[
  流体运动时，流体微团之间具有抵抗相互滑移运动的属性，称为流体的粘性。
]

粘性是流体的固有属性之一，不论是静止流体还是运动流体都具有粘性。

*无滑移边界：* 物体表面的流体速度总是与物体速度一致。

#law-showy(title: "牛顿内摩擦定律")[
  $ tau = mu (d U)/(d y) $
  - $mu$：动力黏性系数；
  - 适用范围：平行流。
]

*动力粘性系数* $mu = mu(theta)$ 是流体粘性大小的一种度量，它取决于流体的种类和状态，与温度 $theta$ 有很大关系，而与压力关系不大。

后面还会用到*运动粘性系数* $nu$：

$ nu = mu / rho = nu(theta, rho) $

常温常压下：

- 液体：$theta arrow.t quad mu arrow.b quad rho arrow.b quad nu arrow.b$
- 气体：$theta arrow.t quad mu arrow.t quad rho arrow.b quad nu arrow.t$

=== 流体的压缩性

由于压强变化而引起流体体积变化的性质。

分液体和气体讨论：

==== 液体

*体积压缩系数：* 在一定温度下，单位压强增量引起的流体体积的相对变化量。

$ beta = -1/V ((partial V)/(partial p))_T = 1/rho ((d rho)/(d p))_T quad "M"^2 "/" "N" $

*体积弹性模量：* $E = 1/beta$。

==== 气体

*理想气体状态方程：*

$ p = rho R theta $

- $R$：气体常数（空气：$R = 287 "J" / ("kg" dot "K")$）。

*不可压缩流体：* 流体运动过程中密度相对变化微小的流体。

一般情况下，液体的密度几乎不随压强变化，视为不可压流体。

气体视为可压缩的，但气体速度远小于当地音速时，视为不可压。

=== 理想流体

*粘性系数等于零*的流体称为理想流体。理想流体也不考虑流体的扩散和热传导性质。

- 人们为简化实际问题所提出的一种抽象模型；
- 可用于粘性系数较小、远离固壁、速度梯度较小情况。

== 作用在流体上的体积力和表面力

在流体中，任取一流体微团，其上受到两种外力：

- 第一种外力作用在流体微团的质心上，与流体微团的体积成正比，称为*体积力*，属于非接触力；
- 第二种外力是周围流体或物体作用在流体微团表面上的力，与力的作用面大小成正比，称为*表面力*，是接触力。

=== 体积力和体积力强度

==== 几种体积力

+ 地球引力场中流体微团受到的引力与它的质量成正比
  $ cases(delta bold(G) = bold(g) delta m, delta m = rho delta V) arrow.r.double delta bold(G) = rho bold(g) delta V $
+ 流体在非惯性坐标系中运动时，受到的惯性力
  $ delta bold(F) = -bold(a) delta m = -rho bold(a) delta V $
+ 带电质点在静电场中运动时，受到的静电力
  $ delta bold(F) = q bold(E) delta V $

==== 体积力强度

流体微团单位体积上作用的体积力称为*体积力强度*。

$ bold(f)_V = lim_(delta V -> 0) (delta bold(F))/(delta V) $

==== 体积力合力及合力矩（有限体积的流体）

- 主矢：$bold(F) = integral_V bold(f)_V d V$
- 主矩：$bold(M) = integral_V bold(r) times bold(f)_V d V$

=== 表面力和应力

==== 定义

单位面积上的表面力称为“应力”（矢量）：

$ bold(T)(bold(n)) = lim_(delta A -> 0) (delta bold(F))/(delta A) $

#figure(
  image("../Figure/应力.png", width: 45%),
  caption: [应力],
)<fig-应力>

*注意：*
+ 应力和它的作用面的方向有关；
+ $bold(T)(bold(n))$ 是向量，可分解为沿作用面的法向分量（正应力）和切向分量（切应力）。
  - 正应力：$T(bold(n), bold(n)) = bold(T)(bold(n)) dot bold(n)$
  - 切应力：$T(bold(n), bold(t)) = bold(T)(bold(n)) dot bold(t)$
  - 切应力：$T(bold(n), bold(s)) = bold(T)(bold(n)) dot bold(s)$

==== 应力的性质

相邻两微元面上的表面力是作用力与反作用力（牛顿第三定律）：

$ delta bold(F) = -delta bold(F)^* $

#property-showy(title: "应力的性质")[
  + 相邻微元面上的应力矢量等大、反向；
  + 相邻微元面上的正应力和切应力分量都分别相等。

  $ bold(T)(bold(n)^*) = lim_(delta A -> 0) (delta bold(F)^*)/(delta A) = lim_(delta A -> 0) (-(delta bold(F))/(delta A)) = -bold(T)(bold(n)) $

  $ bold(n)^* = -bold(n), quad quad bold(t)^* = -bold(t), quad quad bold(s)^* = -bold(s) $
]

#figure(
  image("../Figure/应力的性质.png", width: 58%),
  caption: [相邻微元面上的表面力与应力矢量],
)

=== 一点上的应力张量及其性质

==== 一点的应力状态

一点上三个相互垂直平面上的应力向量称为一点的应力状态。

只要知道一点的应力状态，就可以确定通过该点任意面上的应力。

#figure(
  image("../Figure/一点的应力状态.png", width: 45%),
  caption: [一点的应力状态],
)<fig-一点的应力状态>

采用指标表示：

$ cases(
  bold(T)(bold(e)_i) = bold(T)_i, quad bold(T)(-bold(e)_i) = -bold(T)_i,
  bold(n) = n_1 bold(e)_1 + n_2 bold(e)_2 + n_3 bold(e)_3 = n_i bold(e)_i,
) $

投影关系：$delta A_i = delta A n_i$

平衡方程：$bold(T)(bold(n)) = bold(T)_1 n_1 + bold(T)_2 n_2 + bold(T)_3 n_3 = n_i bold(T)_i$

==== 应力张量分量

$ bold(T)(bold(n)) = n_i bold(T)_i $，一个向量可分解为三个分量：

$ cases(
  bold(T)_1 = T_11 bold(e)_1 + T_12 bold(e)_2 + T_13 bold(e)_3 = T_(1 j) bold(e)_j,
  bold(T)_2 = T_21 bold(e)_1 + T_22 bold(e)_2 + T_23 bold(e)_3 = T_(2 j) bold(e)_j,
  bold(T)_3 = T_31 bold(e)_1 + T_32 bold(e)_2 + T_33 bold(e)_3 = T_(3 j) bold(e)_j,
) arrow.r.double bold(T)_i = T_(i j) bold(e)_j $

一点的应力状态还可以用九个代数值组成的矩阵表示：

$ [T_(i j)] = mat(
  T_11, T_12, T_13;
  T_21, T_22, T_23;
  T_31, T_32, T_33
) $

第一个指标代表作用面，第二个指标代表应力分量。

于是任意面上的应力可表示为

$ bold(T)(bold(n)) = n_i bold(T)_i = n_i T_(i j) bold(e)_j $

即 $bold(T)(bold(n))$ 的分量就是把 $n_i T_(i j)$ 作为自由指标 $j$ 写开。

#theorem-showy(title: "切应力互等定理")[
  $ T_(i j) = T_(j i) $
  应力张量是*对称张量*，因此九个分量中只有六个是独立的。
]

*说明：* 该定理由 0 阶流体微团（点的单元体）的力矩平衡给出。在 $x_1 O x_2$ 平面内取单元体 $d x_1 d x_2$，设两个剪应力分量的大小分别为 $T_12$、$T_21$，则它们对单元体质心的力矩分别为

$ T_12 d x_2 d x_3 dot (d x_1)/2, quad T_21 d x_1 d x_3 dot (d x_2)/2 $

而两者转向相反，由转动平衡（合力矩为零）可得

$ T_12 = T_21 $

其余两对分量同理，合起来即 $T_(i j) = T_(j i)$。

==== 应力张量实体

以上是应力的分量形式，把分量收起来写成坐标无关的实体形式：

$ bold(T)(bold(n)) &= n_i bold(T)_i = n_i T_(i j) bold(e)_j \
  &= (n_k delta_(i k)) T_(i j) bold(e)_j = n_k (bold(e)_k dot bold(e)_i) T_(i j) bold(e)_j \
  &= n_k bold(e)_k dot (T_(i j) bold(e)_i bold(e)_j) = bold(n) dot (T_(i j) bold(e)_i bold(e)_j) $

#definition-showy(title: "应力张量实体")[
  $ bold(T) = T_(i j) bold(e)_i bold(e)_j $
  具有坐标不变性：
  $ bold(T) = T_(i j) bold(e)_i bold(e)_j = T'_(m n) bold(e)'_m bold(e)'_n $
]

于是 $n$ 截面上的应力矢量与 $n$ 截面上 $s$ 方向的应力分量分别写成

$ bold(T)(bold(n)) = bold(n) dot bold(T) $

$ T(bold(n), bold(s)) = bold(T)(bold(n)) dot bold(s) = bold(n) dot bold(T) dot bold(s) $

这与前文应力分量 $T(bold(n), bold(t)) = bold(T)(bold(n)) dot bold(t)$ 的约定一致。

==== 理想流体和静止流体的应力张量

理想流体和静止流体不能承受切应力，其应力张量为

#theorem-showy(title: "理想流体和静止流体的应力张量")[
  $ T_(i j) = -p delta_(i j) $
  矩阵形式为
  $ [T_(i j)] = mat(-p, 0, 0; 0, -p, 0; 0, 0, -p) $
  其中 $p$ 为大于零的标量。
]

任意面上的应力为

$ bold(T)(bold(n)) = T_(i j) n_i bold(e)_j = -p delta_(i j) n_i bold(e)_j = -p n_j bold(e)_j = -p bold(n) $

即与作用面方向无关的各向同性压力。

*说明：* 静止流体中各点无相对运动，不能承受切应力，故任意截面上的应力矢量必沿法线方向；再由一点的应力各向同性（帕斯卡定律），各方向上的法向应力大小相等，记其大小为 $p$，即得 $T_(i j) = -p delta_(i j)$（负号表示压应力，指向与 $bold(n)$ 相反）。

==== 例：已知应力状态

#example-showy(title: "已知应力状态求主方向与切应力")[
  已知应力状态
  $ [sigma_(i j)] = mat(3, 1, 0; 1, 3, 0; 0, 0, 2) "MPa" $
  + 求主应力和主方向；
  + 求法线为 $bold(n) = (sqrt(2)/2, 0, sqrt(2)/2)$ 平面上的切应力大小。

  *解：*（1）主应力满足特征方程 $det(sigma_(i j) - lambda delta_(i j)) = 0$，即
  $ (2 - lambda)[(3 - lambda)^2 - 1] = -(lambda - 2)^2 (lambda - 4) = 0 $
  得主应力 $lambda = 4, 2, 2 "MPa"$。对应主方向：$lambda = 4$ 时 $bold(v)_1 = (1, 1, 0)/sqrt(2)$；$lambda = 2$ 时 $bold(v)_2 = (1, -1, 0)/sqrt(2)$、$bold(v)_3 = (0, 0, 1)$。

  （2）$bold(n)$ 面上的应力矢量为
  $ bold(T)(bold(n)) = sigma dot bold(n) = (3 sqrt(2)/2, sqrt(2)/2, sqrt(2)) "MPa" $
  其法向分量为
  $ sigma_n = bold(T)(bold(n)) dot bold(n) = 3/2 + 1 = 5/2 "MPa" $
  故切应力大小为
  $ tau = sqrt(|bold(T)(bold(n))|^2 - sigma_n^2) = sqrt(7 - 25/4) = sqrt(3)/2 approx 0.866 "MPa" $
]

== 流体的界面现象和性质

流体和固体或流体和另一种互不掺混的流体交界面处的力学和热力学现象。

=== 表面张力

==== 表面张力的微观解释

#figure(
  image("../Figure/表面张力微观解释.png", width: 64%),
  caption: [表面张力的微观机理（A、B、C、D 为不同位置处的分子）],
)

- 液体内部分子吸引力；
- 表面分子密度小；
- 表面的分子势能大于内部；
- 最小势能原理。

*表面张力*是分子力的一种宏观表现，它使液体的自由表面处于拉伸状态，表面就像绷紧的弹性薄膜一样，处处存在沿切线的拉力。

==== 表面张力系数

#definition-showy(title: "表面张力系数")[
  表面张力位于界面的密切面内，并垂直于分割线。单位长度的表面张力称为*表面张力系数* $gamma$：
  $ [gamma] = [F][L]^(-1), quad "单位：" "N" / "m" $
  界面微元上的表面张力为
  $ delta bold(Gamma) = gamma bold(n) times d bold(x) $
]

表面张力系数与界面两侧介质属性以及温度有关，通常随温度升高而减小。例如 20 ℃ 时：水-空气界面 0.0731 N/m，酒精-空气界面 0.0223 N/m，水银-空气界面 0.5177 N/m。

=== 表面张力与应力平衡

==== 球形界面

以半径为 $R$ 的球面为例，取半个球面分析，表面张力沿分割圆周的合力与球面两侧的压力差平衡：

#figure(
  image("../Figure/表面张力与应力平衡.png", width: 36%),
  caption: [球形界面的受力平衡],
)

$ pi R^2 (p_- - p_+) = 2 pi R gamma arrow.r.double p_- - p_+ = (2 gamma)/R $

==== 一般曲面

在界面上取边长分别为 $delta l_1$、$delta l_2$ 的曲面微元：

#figure(
  image("../Figure/界面的应力平衡.png", width: 82%),
  caption: [曲面微元的表面张力与应力平衡],
)

$ delta l_1 = R_1 delta alpha_1, quad delta l_2 = R_2 delta alpha_2, quad delta A = delta l_1 times delta l_2 $

表面张力在法线方向的合力为

$ delta F_n &= [2 gamma delta l_2 sin((delta alpha_1)/2) + 2 gamma delta l_1 sin((delta alpha_2)/2)] \
  &approx [2 gamma delta l_2 (delta alpha_1)/2 + 2 gamma delta l_1 (delta alpha_2)/2] \
  &= gamma (1/R_1 + 1/R_2) delta A $

考虑表面张力情况下的界面力平衡方程为

$ T_+ (bold(n), bold(n)) - T_- (-bold(n), -bold(n)) = gamma (1/R_1 + 1/R_2) $

在理想流体中 $T(bold(n), bold(n)) = -p$，即得

#law-showy(title: "Young-Laplace 方程")[
  $ p_- - p_+ = gamma (1/R_1 + 1/R_2) $
  其中 $1/R_1 + 1/R_2$ 与坐标方向无关。
]

=== 流体在固壁上的接触角

#definition-showy(title: "接触线与接触角")[
  *接触线：* 当流场中有三种不互相浸融的介质共存时，三种介质的界面交于一线，如果其中一个界面为固壁，则称该交线为接触线。

  *接触角：* 在接触线上，流体界面切面与固壁表面切面的夹角（接触角内包含该流体）。
]

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  figure(image("../Figure/接触线.png", width: 100%), caption: [固壁上的接触线]),
  figure(image("../Figure/接触角.png", width: 100%), caption: [流体在固壁上的接触角]),
)

接触角的大小取决于固壁材料与流体的性质：

- 例如：空气、水、干净玻璃（浸润）；
- 空气、水银、干净玻璃：$theta = 130 degree ~ 140 degree$（不浸润）。

*浸润*（$theta < 90 degree$）、*不浸润*（$theta > 90 degree$）。

=== 毛细现象

#definition-showy(title: "毛细现象")[
  将细管插入液体，细管中的液面低于或高于周围连通的液面，这种现象称为*毛细现象*。
]

利用界面上表面张力平衡关系，可计算高度差 $h$：

- 表面张力：$p_D - p_A = gamma (1/R_1 + 1/R_2)$
- 几何关系：$R_1 = R_2 = R, quad R = d/(2 cos theta)$（$d$ 为细管内径，$theta$ 为接触角）
- 静力平衡：$p_B = p_C = p_D = p_A + rho g h$

联立得

$ rho g h = (4 gamma cos theta)/d arrow.r.double h = (4 gamma cos theta)/(rho g d) $

#figure(
  image("../Figure/毛细现象.png", width: 74%),
  caption: [(a) 玻璃管插在水中（浸润，液面上升）；(b) 玻璃管插在水银中（不浸润，液面下降）],
)

#figure(
  image("../Figure/热管.png", width: 86%),
  caption: [毛细现象的应用：热管（吸液芯的毛细作用使冷凝液体回流）],
)

- $theta < 90 degree$（*浸润壁面*）：细管内液面上升；
- $theta > 90 degree$（*不浸润壁面*）：细管内液面下降。

=== 界面上流体速度和温度的连续性

界面两侧流体处于热力学平衡状态，温度相等、速度相等：

$ theta_+ = theta_-, quad quad bold(U)_+ = bold(U)_- $

#property-showy(title: "界面上的平衡关系")[
  *应力平衡：*
  $ T_+ (bold(n), bold(n)) - T_- (bold(n), bold(n)) = gamma (1/R_1 + 1/R_2) $
  切向应力连续：
  $ T_+ (bold(n), bold(s)) = T_- (bold(n), bold(s)), quad quad T_+ (bold(n), bold(t)) = T_- (bold(n), bold(t)) $
  *压力平衡：*
  $ p_- - p_+ = gamma (1/R_1 + 1/R_2) $
]

对*理想流体*，由于不计粘性，界面上允许速度滑移，上述界面速度相等条件变为

$ bold(U)_+ dot bold(n) = bold(U)_- dot bold(n) quad quad "（不可穿透条件）" $
