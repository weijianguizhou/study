#import "../dvd.typ": *

= 控制系统的动态数学模型

*数学模型*：描述系统内部物理量（变量）之间关系的数学表达式。

- *静态模型*：变量各阶导数为零时的代数方程，反映平衡状态下的特性，输出只与当前输入有关；
- *动态模型*：描述变量各阶导数之间关系的微分方程，输出由从初始到当前的全部输入决定。

经典控制理论以*传递函数*为基本模型，现代控制理论以*状态空间*为基本模型，而依据物理定律列写的微分方程是二者的基础。

建模方法：*解析法*（机理法，依据基尔霍夫定律、牛顿定律等）与*实验法*（系统辨识法）。解析法步骤：确定输入输出变量 $arrow$ 依次列写各元件微分方程 $arrow$ 消去中间变量 $arrow$ 整理成标准形式（输出在左、输入在右、降幂排列）。

单输入单输出系统微分方程的一般形式：

$ a_0 x_o^((n))(t) + a_1 x_o^((n-1))(t) + dots.c + a_(n-1) dot(x)_o(t) + a_n x_o(t) = b_0 x_i^((m))(t) + dots.c + b_m x_i(t) quad (m <= n) $

== 基本环节的数学建模

=== 机械系统

机械系统分析使用三种理想化要素：

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  stroke: none,
  table.header([*要素*], [*特性*], [*关系式*]),
  [质量 $m$], [惯性大、忽略弹性], [$sum F = m a$（平动），$sum T = J alpha$（转动）],
  [弹簧 $k$], [柔度大、忽略惯性], [$f = k x$，储能元件],
  [阻尼 $D$], [阻力与相对速度成正比、方向相反], [$f = D dot(x)$，耗能元件],
)

组合机床动力滑台（质量—弹簧—阻尼系统）以力 $f_i(t)$ 为输入、位移 $y_o(t)$ 为输出：

#grid(
  columns: (1fr, 1.15fr),
  column-gutter: 1em,
  image("../Figure/动力滑台力学模型.png", width: 100%),
  align(horizon)[
    由牛顿第二定律
    $ f_i - k y_o - D dot(y)_o = M accent(y, dot.double)_o $
    整理得二阶微分方程：
    $ M accent(y, dot.double)_o + D dot(y)_o + k y_o = f_i $
    式中 $M$ 为受控质量，$k$ 为弹性刚度，$D$ 为粘性阻尼系数。
  ],
)

=== 电气系统

无源元件：电阻 $u = R i$；电容 $i = C (d u)/(d t)$；电感 $u = L (d i)/(d t)$（电容、电感为储能元件）。

运算放大器（有源元件）的两条分析依据：*虚断*（$i_+ = i_- approx 0$）与*虚短*（$u_+ approx u_-$）。以无源电路网络为例，由基尔霍夫定律与欧姆定律消去中间变量，可得

$ R_1 R_2 C dot(u)_o + (R_1 + R_2) u_o = R_1 R_2 C dot(u)_i + R_2 u_i $

=== 机电系统：电枢控制式直流电动机

#grid(
  columns: (1fr, 1.15fr),
  column-gutter: 1em,
  image("../Figure/电枢控制直流电机.png", width: 100%),
  align(horizon)[
    电枢回路（基尔霍夫定律）：
    $ e_i = R_a i_a + L_a (d i_a)/(d t) + e_m $\
    电磁转矩：$T = K_T i_a$\
    反电动势：$e_m = K_e (d theta_o)/(d t)$\
    转矩平衡：$T = J accent(theta, dot.double)_o + D dot(theta)_o$
  ],
)

消去中间变量 $i_a$、$e_m$、$T$ 得三阶方程

$ L_a J (d^3 theta_o)/(d t^3) + (L_a D + R_a J) accent(theta, dot.double)_o + (R_a D + K_T K_e) dot(theta)_o = K_T e_i $

- 忽略电枢电感 $L_a$：二阶方程 $R_a J accent(theta, dot.double)_o + (R_a D + K_T K_e) dot(theta)_o = K_T e_i$；
- 电感、电阻均较小：转速与电枢电压成正比——$dot(theta)_o = e_i / K_e$。

#summary[
  列写微分方程三步：划分环节定输入输出、按物理定律列写并适当简化、联立消元整理成标准形式。一切动态方程都是在某一平衡状态附近列出的。
]

== 数学模型的线性化

线性系统适用*叠加原理*：几个外作用同时加入时，总输出等于各外作用单独作用的输出之和；外作用放大 $A$ 倍，输出亦放大 $A$ 倍。这使分析大为简化。

非线性特性（饱和、死区、磁滞、继电型等）在一定范围内可用*切线法*（小偏差法）线性化：设 $y = f(x)$ 在平衡工作点 $(x_0, y_0)$ 连续可微，泰勒展开取一次项：

$ y = f(x_0) + f'(x_0)(x - x_0) + "高阶项" quad ==> quad Delta y = k Delta x, quad k = f'(x_0) $

略去增量符号即得工作点附近的线性化方程。多变量情形同理：$Delta y = K_1 Delta x_1 + K_2 Delta x_2$。

#example[
  单摆（$theta_o$ 为摆角，$l$ 为摆长）：由转动定律 $T_i(t) - m g l sin theta_o(t) = m l^2 accent(theta, dot.double)_o(t)$。在平衡点 $theta_(o 0) = 0$ 附近取 $sin theta_o approx theta_o$，得线性化方程
  $ m l^2 accent(theta, dot.double)_o + m g l theta_o = T_i(t) $
]

#grid(
  columns: (1fr, 1.4fr),
  column-gutter: 1em,
  image("../Figure/单摆模型.png", width: 100%),
  block[
    *线性化注意事项：*
    + 线性化是相对某一额定工作点进行的，工作点不同，方程系数不同；
    + 变量偏移愈小，线性化精度愈高；
    + 增量方程可认为初始条件为零（坐标原点平移到工作点处）；
    + 线性化只适用于没有间断点、折断点的单值函数。
  ],
)

== 拉氏变换与反变换

拉氏变换将微分方程化为复变量 $s$ 的代数方程，是分析机电系统的基本数学工具。函数 $x(t)$（$t<0$ 时为零且分段连续、指数级）的拉氏变换定义为

$ X(s) = L[x(t)] = integral_0^oo x(t) e^(-s t) d t quad quad (s = sigma + j omega) $

#table(
  columns: (auto, auto, auto, auto),
  align: (left + horizon, left, left, left),
  stroke: none,
  table.header([*原函数 $x(t)$*], [*象函数 $X(s)$*], [*原函数 $x(t)$*], [*象函数 $X(s)$*]),
  [$delta(t)$ (单位脉冲)], [$1$], [$1(t)$ (单位阶跃)], [$1 / s$],
  [$t$], [$1 / s^2$], [$t^n$], [$n! / s^(n+1)$],
  [$e^(-a t)$], [$1 / (s+a)$], [$sin omega t$], [$omega / (s^2+omega^2)$],
  [$cos omega t$], [$s / (s^2+omega^2)$], [$e^(-a t) sin omega t$], [$omega / ((s+a)^2+omega^2)$],
)

*常用性质：*

- 叠加定理：$L[a x_1 + b x_2] = a X_1(s) + b X_2(s)$；
- 微分定理：$L[(d x)/(d t)] = s X(s) - x(0^-)$；零初始条件下 $L[(d^n x)/(d t^n)] = s^n X(s)$；
- 积分定理：$L[integral x(t) d t] = X(s) / s + x(0^-) / s$（零初始条件下为 $X(s)/s$）；
- 衰减定理：$L[e^(-a t) x(t)] = X(s+a)$；延时定理：$L[x(t-a) 1(t-a)] = e^(-a s) X(s)$；
- 初值定理：$lim_(t -> 0) x(t) = lim_(s -> oo) s X(s)$；终值定理：$lim_(t -> oo) x(t) = lim_(s -> 0) s X(s)$（要求 $s X(s)$ 在虚轴及右半平面解析）。

*拉氏反变换*：$x(t) = 1/(2 pi j) integral_(a - j oo)^(a + j oo) X(s) e^(s t) d s$。工程上采用部分分式展开 + 留数法，分三种情形：

+ *单极点*：$a_k = [(s+p_k) X(s)]_(s=-p_k)$，$x(t) = sum_k a_k e^(-p_k t)$；
+ *共轭复极点*：求出其中一个留数，由实部虚部对应关系写成正弦、余弦函数形式；
+ *多重极点*：$a_(r-k) = 1/k! [d^k/(d s^k)((s-p)^r X(s))]_(s=p)$。

#example[
  求 $X(s) = (2 + 3 s)/(s^2 + 3 s + 2) = a_1/(s+1) + a_2/(s+2)$ 的反变换。解得 $a_1 = 1$，$a_2 = -1$，故 $x(t) = (e^(-t) - e^(-2t)) 1(t)$。
]

用拉氏变换解常系数线性微分方程：方程两边取拉氏变换（代入初始条件）$arrow$ 解代数方程得 $X(s)$ $arrow$ 部分分式展开 $arrow$ 求反变换。例如 $accent(y, dot.double) + 5 dot(y) + 6 y = 6$（$y(0) = dot(y)(0) = 2$），解得 $Y(s) = (2 s^2 + 12 s + 6)/(s(s+2)(s+3))$，反变换为 $y(t) = (1 + 5 e^(-2t) - 4 e^(-3t)) 1(t)$。

== 传递函数与典型环节

#definition("传递函数")[
  零初始条件下，线性定常系统输出象函数与输入象函数之比：
  $ G(s) = (X_o(s))/(X_i(s)) = (b_0 s^m + dots.c + b_m)/(a_0 s^n + dots.c + a_n) quad quad (n >= m) $
]

传递函数的性质：

+ $G(s)$ 取决于系统结构与参数，与输入的形式、大小无关；
+ 是复变量 $s$ 的有理真分式（$m <= n$），具有复变函数的一切性质；
+ 描述输入输出关系，但不提供系统的物理结构（不同物理系统可有相同的 $G(s)$）；
+ 与微分方程一一对应，置换 $d / d t <-> s$ 即得；
+ $G(s)$ 的拉氏反变换即单位脉冲响应 $g(t)$——脉冲响应包含系统的全部动态信息；
+ 已知 $G(s)$ 可研究系统在各种输入下的响应；未知 $G(s)$ 可加已知输入、由输出辨识得到。

*增益、零点、极点与型*：将 $G(s)$ 因式分解，

$ G(s) = K^* (product_(l=1)^m (s - z_l)) / (s^lambda product_(k=1)^q (s - p_k) product_(k=1)^r (s^2 + 2 zeta_k omega_k s + omega_k^2)) $

- $K^*$ 为增益；$z_l$、$p_k$ 使分子、分母多项式为零，分别称*零点*、*极点*；
- 极点是微分方程的特征根，决定系统自由运动的模态；零点越远离某极点，该极点模态占比越大，零极点重合则该模态被抵消；
- $lambda$ 为积分环节个数，称传递函数的*型*（0 型、I 型、II 型……）；当 $s=0$ 时 $G(0) = b_m / a_n = K$ 为静态放大系数。

*典型环节*（任何复杂传递函数都可分解为典型环节之积）：

#table(
  columns: (auto, auto, auto),
  align: (left, center, center),
  stroke: none,
  table.header([*典型环节*], [*微分方程*], [*传递函数 $G(s)$*]),
  [比例环节], [$x_o = K x_i$], [$K$],
  [一阶惯性环节], [$T dot(x)_o + x_o = x_i$], [$1 / (T s + 1)$],
  [理想微分环节], [$x_o = k dot(x)_i$], [$k s$],
  [积分环节], [$x_o = k integral x_i d t$], [$k / s$],
  [二阶振荡环节], [$T^2 accent(x, dot.double)_o + 2 zeta T dot(x)_o + x_o = x_i$], [$1 / (T^2 s^2 + 2 zeta T s + 1)$],
  [延时（纯滞后）环节], [$x_o = x_i (t - tau)$], [$e^(-tau s)$],
)

其中振荡环节 $omega_n = 1 / T$ 为无阻尼自然频率，$zeta$（$0 <= zeta < 1$）为阻尼比：环节内两个储能元件交换能量，输出出现振荡。

== 方块图及其简化

方块图的四种基本要素：*信号线*（带箭头）、*函数方块*（写 $G(s)$）、*相加点*（比较点，代数求和）、*分支点*（引出点，引出同一信号）。

三种基本连接及等效传递函数：

$ "串联：" G = G_1 G_2, quad quad "并联：" G = G_1 + G_2, quad quad "反馈：" Phi = G / (1 + G H) $

闭环系统中：$1 + G H = 0$ 为*特征方程*；误差传递函数为 $E(s) / X_i(s) = 1 / (1 + G H)$。

*等效变换法则*：分支点或相加点与方块交叉时需移动，移动的支路须串入相应的补偿环节：

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  figure(image("../Figure/引出点后移.png", width: 100%), caption: [引出点后移：串入 $1/G$]),
  figure(image("../Figure/引出点前移.png", width: 100%), caption: [引出点前移：串入 $G$]),
  figure(image("../Figure/比较点后移.png", width: 100%), caption: [比较点后移：被移位支路串入 $G$]),
  figure(image("../Figure/比较点前移.png", width: 100%), caption: [比较点前移：被移位支路串入 $1/G$]),
)

化简步骤：明确输入输出 $arrow$ 移动分支点、比较点消除交叉 $arrow$ 由内向外把结构化为串联、并联、反馈的组合 $arrow$ 合并为单个方框。变换前后信号关系必须完全不变。

== 信号流图与梅逊公式

#definition("信号流图")[
  表示一组联立线性代数方程的图：*节点*表示变量，*支路*表示变量间的传递关系（有向有权），信号只能沿箭头方向传递。它与方块图一一对应，包含结构图的全部信息。
]

#grid(
  columns: (1fr, 1.3fr),
  column-gutter: 1em,
  figure(image("../Figure/最简单的信号流图.png", width: 100%), caption: [最简单的信号流图]),
  figure(image("../Figure/一般信号流图.jpg", width: 100%), caption: [一般信号流图]),
)

*术语*：输入节点（源节点，只有输出支路）、输出节点（汇节点，只有输入支路）、混合节点；通道（路径）；前向通道（输入到输出的通道）；回环（闭通道）；不接触回环（无公共节点的回环）；通道增益（支路传输之积）。

*性质*：只适用于线性系统；依据的方程必为因果形式的代数方程；信号单向传递；节点对输入支路信号求和后传给所有输出支路；混合节点加单位传输支路可变为汇节点；同一系统的信号流图不唯一。

由方块图绘制信号流图的要点：比较点之后的引出节点可与比较点共用一个节点；比较点之前的引出点需设置两个节点。

#figure(image("../Figure/控制系统方框图.png", width: 72%), caption: [控制系统方框图])

#figure(image("../Figure/方框图转信号流图.png", width: 72%), caption: [转换得到的信号流图（$e_1$、$e_2$ 为比较点前引出所设节点）])

#theorem("梅逊公式")[
  信号流图输入到输出的传递函数为
  $ T = (sum_k P_k Delta_k)/(Delta) $
  其中 $P_k$ 为第 $k$ 条前向通道增益；$Delta = 1 - sum_a L_a + sum_(b c) L_b L_c - sum_(d e f) L_d L_e L_f + dots.c$ 为特征式（$L_a$ 为各回环增益，$L_b L_c$ 为互不接触的 2 个回环增益之积，依此类推）；$Delta_k$ 为第 $k$ 条前向通道的余子式——去掉与该通道接触的回环后按同样方法计算。
]

#figure(image("../Figure/梅逊公式例题.jpg", width: 86%), caption: [梅逊公式例题：三条前向通道、六个回环])

#example[
  对图中信号流图：前向通道 $P_1 = G_1 G_2 G_3 G_4 G_5$，$P_2 = G_1 G_6 G_4 G_5$，$P_3 = G_1 G_2 G_7 G_5$；回环 $L_1 = -G_3 H_2$，$L_2 = -G_5 H_1$，$L_3 = -G_2 G_3 G_4 G_5 H_3$，$L_4 = -G_6 G_4 G_5 H_3$，$L_5 = -G_2 G_7 G_5 H_3$，$L_6 = G_5 G_6 G_7 H_2 H_3$。其中仅 $L_1$ 与 $L_2$ 互不接触，故
  $ Delta = 1 - (L_1 + L_2 + L_3 + L_4 + L_5 + L_6) + L_1 L_2 $
  各前向通道与前向内所有回环均接触（$Delta_k = 1$），代入梅逊公式即得总传递函数。
]
