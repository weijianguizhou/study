#import "@preview/inelegant-note:0.9.1": *
#import "boxes.typ": property-showy

= 流体运动学

采用数学分析和几何描述的方法研究流体运动的规律，不研究运动产生和变化的原因。

== 描述流体运动的两种方法

在流体力学中主要采用两种方法来描述流体的运动：

- *拉格朗日法*：以流场中个别质点的运动作为研究出发点，从而进一步研究整个流体的运动，这种方法是质点系力学研究方法的自然延续；
- *欧拉法*：以流体流过空间某点时的运动特性作为研究的出发点，从而研究流体在整个空间里的运动情况。

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  figure(image("../Figure/拉格朗日法示意.png", width: 100%), caption: [拉格朗日法：跟踪流体粒子]),
  figure(image("../Figure/欧拉法示意.png", width: 100%), caption: [欧拉法：观测固定位置]),
)

=== 拉格朗日法

拉格朗日法通过两个方面来描述流场：

- 某一运动的流体质点各种物理量随时间的变化（时间）；
- 相邻质点间这些物理量的变化（空间）。

关键是建立识别每个质点的标记方法：流体质点初始时刻的坐标与流体质点一一对应，可用来标记流体质点。

以质点 $P_1$ 在 $t_0$ 时刻的坐标 $(a_1, b_1, c_1)$ 作为标记，则在 $t$ 时刻质点 $P_1$ 的位置为

$ cases(
  x = x(a_1, b_1, c_1, t),
  y = y(a_1, b_1, c_1, t),
  z = z(a_1, b_1, c_1, t),
) quad bold(x) = bold(x)(bold(A)_1, t) $

对任意质点 $P: (a, b, c)$，在任意时刻 $t$ 的位置为

$ bold(x) = bold(x)(bold(A), t) $

其中 $a, b, c, t$ 为自变量，称为*拉格朗日变量*；$bold(x) = bold(x)(bold(A), t)$ 称为流体质点的*位移函数*。

- $bold(A)$ 固定：$bold(x)$ 表示某个确定质点的运动轨迹；
- $t$ 固定：$bold(x)$ 表示 $t$ 时刻各质点的位置。

==== 位移函数的两个基本性质

+ 在初始时刻 $t_0$，$bold(x) = bold(A)$，即 $bold(x)(bold(A), t_0) = bold(A)$；
+ 任意时刻 $bold(x)$ 和 $bold(A)$ 是一一对应的连续函数：

$ bold(x) = bold(x)(bold(A), t) arrow.l.r bold(A) = bold(A)(bold(x), t) $

其意义：欧拉变量与拉格朗日变量的转换。

#figure(
  image("../Figure/位移函数示意图.png", width: 76%),
  caption: [位移函数：不同时刻的质点构形与运动轨迹],
)

速度与加速度（位移函数对时间的导数）：

$ bold(U) = (partial bold(x)(a, b, c, t))/(partial t), quad quad bold(a) = (partial bold(U)(a, b, c, t))/(partial t) $

=== 欧拉法

欧拉法通过以下两个方面来描述整个流场：

- 在空间固定点上流体物理量随时间的变化（时间）；
- 在相邻空间点上这些物理量的变化（空间）。

空间点上的物理量指占据这些位置的各个流体质点的物理量在不同时刻由不同流体质点占据，从而引起空间点上物理量的变化。

在欧拉法中，流动物理量是时间 $t$ 和空间坐标 $bold(x) = (x, y, z)$ 的函数：

$ bold(U) = bold(U)(bold(x), t), quad p = p(bold(x), t), quad rho = rho(bold(x), t) $

其中 $x, y, z, t$ 为自变量，称为*欧拉变量*。欧拉法是一种*场的描述方法*。

*定常流场：* 与时间无关的欧拉速度场。

=== 欧拉描述与拉格朗日描述的相互转换

==== 拉格朗日描述变为欧拉描述

$ Q_L (bold(A), t) arrow.r Q_E (bold(x), t) $

由位移函数 $bold(x) = bold(x)(bold(A), t)$ 求其反函数 $bold(A) = bold(A)(bold(x), t)$，代入拉格朗日描述即可：

$ Q_L (bold(A), t) = Q_L (bold(A)(bold(x), t), t) = Q_E (bold(x), t) $

#example-showy(title: "拉格朗日描述 → 欧拉描述")[
  给定拉格朗日的位移表达式
  $ x_1 = a_1 e^(-2t/k), quad x_2 = a_2 e^(t/k), quad x_3 = a_3 e^(t/k) $
  其中 $k$ 为常数，$a_1, a_2, a_3$ 为拉格朗日变量，求欧拉速度场。

  *解：* 由拉格朗日的位移表达式求拉格朗日速度表达式
  $ U_1 = (partial x_1)/(partial t) = -(2 a_1)/k e^(-2t/k), quad U_2 = (partial x_2)/(partial t) = a_2/k e^(t/k), quad U_3 = (partial x_3)/(partial t) = a_3/k e^(t/k) $
  由位移表达式求反演
  $ a_1 = x_1 e^(2t/k), quad a_2 = x_2 e^(-t/k), quad a_3 = x_3 e^(-t/k) $
  代入拉格朗日速度表达式，得
  $ U_1 = -(2 x_1)/k, quad U_2 = x_2/k, quad U_3 = x_3/k $
  速度场与时间无关，为*定常流动*。
]

==== 欧拉描述变为拉格朗日描述

$ Q_E (bold(x), t) arrow.r Q_L (bold(A), t) $

流体质点的速度等于其当前所在地的流速，因此以欧拉速度场为右端积分（轨迹方程）：

$ bold(U)_E (bold(x), t) = (partial bold(x)(bold(A), t))/(partial t), quad quad t = 0: bold(x) = bold(A) $

解出位移函数 $bold(x) = bold(x)(bold(A), t)$，即可得拉格朗日描述；两描述之间由位移函数及其反函数相联系。

#example-showy(title: "欧拉描述 → 拉格朗日描述")[
  已知欧拉速度场
  $ U_1 = x_1 + t, quad U_2 = x_2 + t, quad U_3 = 0 $
  求质点位移和速度的拉格朗日表达式。

  *解：* 由轨迹方程 $U_i = (partial x_i)/(partial t)$ 分别积分：
  $ U_1 = (partial x_1)/(partial t) = x_1 + t arrow.r x_1 = c_1 e^t - t - 1 $
  $ U_2 = (partial x_2)/(partial t) = x_2 + t arrow.r x_2 = c_2 e^t - t - 1 $
  $ U_3 = (partial x_3)/(partial t) = 0 arrow.r x_3 = c_3 $
  由初始条件 $t = 0: x_1 = a_1, x_2 = a_2, x_3 = a_3$，得 $c_1 = a_1 + 1, c_2 = a_2 + 1, c_3 = a_3$，故质点位移的拉格朗日表达式为
  $ x_1 = (a_1 + 1) e^t - t - 1, quad x_2 = (a_2 + 1) e^t - t - 1, quad x_3 = a_3 $
  速度的拉格朗日表达式为
  $ U_1 = (a_1 + 1) e^t - 1, quad U_2 = (a_2 + 1) e^t - 1, quad U_3 = 0 $
]

=== 质点导数

#definition-showy(title: "质点导数")[
  流体质点的物理量对于时间的变化率称作该物理量的*质点导数*（物质导数、随体导数）。
]

牛顿、热力学定律适用于质点。

*在拉格朗日描述中* $Q = Q(bold(A), t)$，$Q$ 的质点导数为

$ (partial Q)/(partial t) = [(partial Q(bold(A), t))/(partial t)]_A $

例如：加速度是速度的质点导数

$ bold(a)(bold(A), t) = [(partial bold(U)(bold(A), t))/(partial t)]_A $

*在欧拉描述中* $Q = Q(bold(x), t)$：$t$ 时刻质点的物理量为 $Q = Q(x, y, z, t)$，$t + Delta t$ 时刻质点的物理量为

$ Q' = Q(x + Delta x, y + Delta y, z + Delta z, t + Delta t) $

$Delta t$ 时间内该质点物理量的增量

$ Delta Q &= Q(x + Delta x, y + Delta y, z + Delta z, t + Delta t) - Q(x, y, z, t) \
  &= (partial Q)/(partial x) Delta x + (partial Q)/(partial y) Delta y + (partial Q)/(partial z) Delta z + (partial Q)/(partial t) Delta t + dots $

$Q$ 的质点导数

$ (D Q)/(D t) = lim_(Delta t -> 0) (Delta Q)/(Delta t) = (partial Q)/(partial x) u + (partial Q)/(partial y) v + (partial Q)/(partial z) w + (partial Q)/(partial t) $

或写成

$ (D Q)/(D t) = (partial Q)/(partial t) + bold(U) dot nabla Q $

- $(partial Q)/(partial t)$：*局部导数*，由流场的非定常性引起；
- $bold(U) dot nabla Q$：*迁移导数*，由流场的非均匀性引起。

加速度：

$ bold(a) = (D bold(U))/(D t) = (partial bold(U))/(partial t) + bold(U) dot nabla bold(U) $

*质点的加速度 = 局部加速度 + 迁移加速度。*

*思考：* 质点导数满足乘积求导法则吗？

$ (D(Q P))/(D t) = (D Q)/(D t) P + Q (D P)/(D t) quad ? $

== 流场的几何描述

=== 迹线

#definition-showy(title: "迹线")[
  *迹线*（pathline, trajectory）：流体质点运动的轨迹。
]

拉格朗日描述：$bold(x) = bold(x)(bold(A), t)$（位移函数）；

欧拉描述：

$ ((partial bold(x))/(partial t))_A = bold(U)_E (bold(x), t) quad "或" quad (d bold(x))/(d t) = bold(U)_E (bold(x), t) $

即

$ (d x)/(d t) = u, quad (d y)/(d t) = v, quad (d z)/(d t) = w $

#example-showy(title: "求质点的轨迹")[
  已知流体的速度场在直角坐标 $(x, y, z)$ 中为
  $ u = x/(1 + t), quad v = y, quad w = 0 $
  求 $t = 0$ 时位于 $(1, 1, 1)$ 的质点的轨迹。

  *解：* 分别积分迹线方程
  $ u = (d x)/(d t) = x/(1 + t) arrow.r x = c_1 (1 + t) $
  $ v = (d y)/(d t) = y arrow.r y = c_2 e^t $
  $ w = (d z)/(d t) = 0 arrow.r z = c_3 $
  由初始条件 $t = 0: x = 1, y = 1, z = 1$，得 $c_1 = 1, c_2 = 1, c_3 = 1$。迹线的参数方程为
  $ x = 1 + t, quad y = e^t, quad z = 1 $
  或消去 $t$：
  $ y = e^(x - 1), quad z = 1 $
]

=== 流线

#definition-showy(title: "流线")[
  *流线*（streamline）：流线是速度场的向量线，它是某一固定时刻的空间曲线，该曲线上任意一点的切线方向与在该点的流体速度方向一致。
]

$ bold(U) times d bold(x) = 0 $

直角坐标系中流线方程：

$ (d x)/u = (d y)/v = (d z)/w $

#figure(
  image("../Figure/流场流速分布与流线图.png", width: 88%),
  caption: [绕流翼型的流场流速分布图（左）与流场流线图（右）],
)

#example-showy(title: "求流线方程")[
  已知流体的速度场在直角坐标 $(x, y)$ 中为
  $ u = x/(1 + t), quad v = y $
  求 $t = 0$ 时通过 $(1, 1)$ 的流线方程。

  *解：* 由流线方程
  $ (d x)/u = (d y)/v arrow.r (d x)/x (1 + t) = (d y)/y arrow.r (1 + t) ln x = ln y + ln c $
  $ arrow.r x^(1 + t) = c y $
  由 $t = 0: x = 1, y = 1$，得 $c = 1$，所求流线方程为
  $ y = x $
]

==== 说明与比较

迹线是*同一质点*在不同时刻的运动轨迹，迹线方程中 $t$ 是自变量；流线是*同一时刻*不同质点上的速度场向量线，流线方程中 $t$ 是参变量，积分时作为常数。

#figure(
  image("../Figure/迹线与流线对比.png", width: 84%),
  caption: [迹线（同一粒子、不同时刻）与流线（不同粒子、同一时刻）],
)

- 迹线 —— 拉格朗日几何描述方法；
- 流线 —— 欧拉几何描述方法。

==== 流线的性质

#property-showy(title: "流线的性质")[
  + 一般情况下流线不能相交，同一时刻通过一点只有一根流线；两个例外：*驻点*（速度为零）、*奇点*（速度为无限大）；
  + 定常流动中，流线与迹线重合。
]

#figure(
  image("../Figure/流线性质_源与汇.png", width: 74%),
  caption: [流场的流线图与两个例外（源、汇）],
)

#example-showy(title: "求流线和迹线方程")[
  已知流体的速度场在直角坐标 $(x, y)$ 中为
  $ u = a x, quad v = -a y $
  求流线和迹线方程。

  *解：* 流线：
  $ (d x)/(a x) = (d y)/(-a y) arrow.r (d x)/x = -(d y)/y arrow.r ln x = -ln y + ln c arrow.r x y = c $
  迹线：
  $ (partial x)/(partial t) = a x arrow.r ln x = a t + ln c_1, quad (partial y)/(partial t) = -a y arrow.r ln y = -a t + ln c_2 $
  消去 $t$：$ln x y = ln c_1 c_2 = ln c$，即 $x y = c$。可见*流线和迹线相同*。
]

=== 流面和流管

在给定瞬时，通过任一非流线的曲线上各点作流线，这些流线组成的曲面称为*流面*；

在给定瞬时，通过任一非流线的封闭曲线上各点作流线，由这些流线构成的管状曲面称为*流管侧面*，该曲面包围的空间称为*流管*。

#figure(
  image("../Figure/流面与流管.png", width: 62%),
  caption: [流面（左）与流管（右）],
)

*流管侧面不可能有流体通过。*

== 流体微团运动分析

=== 几何分析

正交微元六面体经过微小时间间隔将变成斜平行六面体：

#figure(
  image("../Figure/正交微元六面体的变形.png", width: 78%),
  caption: [正交微元六面体的变形],
)

流体微团的运动可分解为四种基本形式：

#figure(
  image("../Figure/微团运动分解.png", width: 94%),
  caption: [微团运动的分解：平移、线变形、角变形、转动],
)

=== 线应变率与体积应变率

#definition-showy(title: "线应变率")[
  单位时间内流体线的相对伸长，称为*线应变率*（线变形率）：
  $ dot(epsilon)_(x x) = (partial u)/(partial x), quad dot(epsilon)_(y y) = (partial v)/(partial y), quad dot(epsilon)_(z z) = (partial w)/(partial z) $
]

#definition-showy(title: "体积应变率")[
  流体微团的体积在单位时间内的相对变化，称为*流体微团体积应变率*（体积膨胀速率）：
  $ 1/(delta V) (D(delta V))/(D t) $
]

流体微团体积应变率 = 三个方向线应变率之和 = *流体散度*：

$ nabla dot bold(U) = (partial u)/(partial x) + (partial v)/(partial y) + (partial w)/(partial z) quad quad "i.e.," quad (partial U_i)/(partial x_i) $

不可压缩流体：$nabla dot bold(U) = 0$。

=== 角应变率

#definition-showy(title: "角应变率")[
  微元平面上两垂直线段夹角在单位时间内减小量之半称为*角应变率*（角变形速率），用 $dot(epsilon)_(i j)$ 表示，下标 $i j$ 表示两线段的方向。
]

#figure(
  image("../Figure/角应变率几何分析.png", width: 60%),
  caption: [角应变的几何分析],
)

在 $x O y$ 平面内，两微元线段的转角分别为

$ alpha_1 approx (partial v)/(partial x) Delta t, quad quad alpha_2 approx (partial u)/(partial y) Delta t $

于是

$ dot(epsilon)_(x y) = (alpha_1 + alpha_2)/(2 Delta t) = 1/2 ((partial v)/(partial x) + (partial u)/(partial y)) $

同理

$ dot(epsilon)_(y z) = 1/2 ((partial w)/(partial y) + (partial v)/(partial z)), quad quad dot(epsilon)_(x z) = 1/2 ((partial u)/(partial z) + (partial w)/(partial x)) $

统一写为

$ dot(epsilon)_(i j) = 1/2 ((partial U_i)/(partial x_j) + (partial U_j)/(partial x_i)) $

=== 流体旋转角速度

#definition-showy(title: "流体旋转角速度")[
  过同一点的任意两条正交微元流体线，在它们所在的平面上的旋转角速度的平均值，称为该点流体的*旋转角速度*在垂直该平面方向的分量。
]

在 $x O y$ 平面内，两微元线段的转角（带符号）为

$ alpha_1 approx (partial v)/(partial x) Delta t, quad quad alpha_2 approx -(partial u)/(partial y) Delta t $

则

$ tilde(omega)_z = 1/2 (alpha_1/(Delta t) + alpha_2/(Delta t)) = 1/2 ((partial v)/(partial x) - (partial u)/(partial y)) $

同理

$ tilde(omega)_x = 1/2 ((partial w)/(partial y) - (partial v)/(partial z)), quad quad tilde(omega)_y = 1/2 ((partial u)/(partial z) - (partial w)/(partial x)) $

即

$ tilde(bold(omega)) = 1/2 nabla times bold(U) $

=== 小结：微团运动的独立控制量

$ dot(epsilon)_(x x) = (partial u)/(partial x), quad dot(epsilon)_(y y) = (partial v)/(partial y), quad dot(epsilon)_(z z) = (partial w)/(partial z) $

$ dot(epsilon)_(i j) = 1/2 ((partial U_i)/(partial x_j) + (partial U_j)/(partial x_i)) quad quad (i != j) $

$ tilde(bold(omega)) = 1/2 nabla times bold(U) $

上述物理量是相互独立的，从中可以有如下 9 个独立控制量：

$ (partial u)/(partial x), quad (partial u)/(partial y), quad (partial u)/(partial z), quad (partial v)/(partial x), quad (partial v)/(partial y), quad (partial v)/(partial z), quad (partial w)/(partial x), quad (partial w)/(partial y), quad (partial w)/(partial z) $

#exercise-showy(title: "作业 6")[
  *2.1* 已知拉格朗日速度分布 $u = -beta (a sin beta t + b cos beta t)$，$v = beta (a cos beta t - b sin beta t)$，$w = alpha$。如 $t = 0$ 时 $x = a$，$y = b$，$z = c$，试用欧拉变量表示上述流场速度分布，并求流场加速度分布，式中 $alpha, beta, a, b, c$ 为常数。

  *2.2* 给定速度场 $u = x + y$，$v = x - y$，$w = 0$，且令 $t = 0$ 时 $x = a$，$y = b$，$z = c$，求质点空间分布。
]
