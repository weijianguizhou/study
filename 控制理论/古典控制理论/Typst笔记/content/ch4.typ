#import "../dvd.typ": *

= 控制系统的频率特性

时域分析直观，但高阶系统求解繁琐。*频率特性分析法*（频域法）是工程上广为采用的图解方法：不必求解闭环特征根，可间接用开环频率特性分析闭环性能，且频域指标与时域指标存在对应关系。机械振动中的共振频率、动刚度、抗振稳定性等概念，也都可归结为系统在频率域中的特性。

== 频率特性的概念

#definition("频率响应与频率特性")[
  线性定常系统对正弦输入的*稳态响应*称为频率响应：输出仍为同频率的正弦信号，仅幅值与相位随频率变化。稳态输出与输入的幅值之比、相位之差随频率 $omega$ 变化的规律，称为系统的*频率特性*：
  $ G(j omega) = G(s)|_(s = j omega) = U(omega) + j V(omega) = A(omega) e^(j phi(omega)) $
  $A(omega) = |G(j omega)|$ 为*幅频特性*，$phi(omega) = angle G(j omega)$ 为*相频特性*；$U(omega)$、$V(omega)$ 分别称实频、虚频特性。
]

#figure(image("../Figure/频率特性示意图.jpg", width: 74%), caption: [线性系统对正弦输入的稳态响应（频率不变性）])

设输入 $x_i(t) = A sin omega t$，则稳态输出

$ x_o(t) = A |G(j omega)| sin(omega t + phi(omega)) $

频率特性与传递函数本质相同：前者是后者在虚轴上的取值。求取方法有三：① $G(s)$ 中令 $s = j omega$；② 微分方程中代入正弦输入求稳态解；③ 实验测取（扫频）。

== 极坐标图（Nyquist 图）

当 $omega$ 由 $0$ 增至 $+oo$ 时，$G(j omega)$ 作为矢量其端点在复平面上的轨迹，称为*极坐标图*（Nyquist 图、乃氏图）。

#table(
  columns: (auto, auto, 1.5fr),
  align: (left, center, left),
  stroke: none,
  table.header([*环节*], [*$G(j omega)$*], [*Nyquist 图特征*]),
  [比例], [$K$], [实轴上一点 $K$],
  [积分], [$1/(j omega T)$], [沿负虚轴：$omega -> 0$ 时 $-j oo$，$omega -> oo$ 时原点],
  [微分], [$j omega T$], [沿正虚轴：由原点趋于 $+j oo$],
  [一阶惯性], [$1/(1 + j omega T)$], [$1 angle 0 degree -> 0 angle -90 degree$，第四象限半圆],
  [二阶振荡], [$1/(1 - T^2 omega^2 + 2 j zeta T omega)$], [$1 angle 0 degree -> 0 angle -180 degree$，与负虚轴交于 $omega = omega_n$，$|G| = 1/(2 zeta)$],
  [延时], [$e^(-j omega tau)$], [单位圆上顺时针无限盘旋],
)

作图一般步骤：写出 $|G(j omega)|$ 与 $angle G(j omega)$ $arrow$ 求 $omega = 0$ 与 $omega -> oo$ 时的值 $arrow$ 求与实轴交点（$Im G = 0$ 或 $angle G = n dot 180 degree$）$arrow$ 求与虚轴交点（$Re G = 0$ 或 $angle G = n dot 90 degree$，$n$ 为奇数）$arrow$ 必要时补中间点 $arrow$ 勾画曲线。负频段（$omega: -oo -> 0$）的曲线与正频段关于实轴对称。

开环频率特性一般可写为

$ G_k(j omega) = (K product_i (1 + j omega tau_i))/((j omega)^lambda product_j (1 + j omega T_j)) $

$lambda = 0, 1, 2, dots$ 分别称 0 型、I 型、II 型系统。*低频段*：0 型起于实轴上的 $K$；I 型起于无穷远、方向为 $-90 degree$；II 型起于无穷远、方向为 $-180 degree$。

#figure(image("../Figure/各型系统Nyquist低频段.png", width: 66%), caption: [0 型、I 型、II 型系统 Nyquist 图的低频段])

*高频段*：分母阶次大于分子阶次时曲线终止于原点；两者阶次相等时终止于实轴上的有限值。

#example[
  $G(j omega) = 1/(j omega (j omega + 1)(2 j omega + 1))$。$omega -> 0$ 时 $|G| -> oo$、$angle G -> -90 degree$；$omega -> oo$ 时趋于原点、相角 $-270 degree$。曲线与负实轴交于 $(-0.67, j 0)$。
]

#figure(image("../Figure/Nyquist图示例.png", width: 46%), caption: [交点附近的局部放大：$(-0.67, j 0)$])

== 对数坐标图（Bode 图）

Bode 图由*对数幅频特性* $L(omega) = 20 lg |G(j omega)|$（单位 dB）与*对数相频特性* $phi(omega)$ 组成，横轴为 $lg omega$。频率变化十倍称一个*十倍频程*（dec）。串联环节的乘除在对数坐标中化为加减，故 Bode 图最便于工程作图。

#table(
  columns: (auto, auto, auto),
  align: (left, center, center),
  stroke: none,
  table.header([*环节*], [*$L(omega)$*], [*$phi(omega)$*]),
  [比例], [$20 lg K$（水平线）], [$0 degree$],
  [积分], [过 $(omega = 1, 0 "dB"$)、斜率 $-20 "dB/dec"$], [$-90 degree$],
  [微分], [斜率 $+20 "dB/dec"$], [$+90 degree$],
  [一阶惯性], [低频 $0 "dB"$，转角 $omega = 1/T$ 后 $-20 "dB/dec"$], [$0 -> -90 degree$（$1/T$ 处 $-45 degree$）],
  [一阶微分], [低频 $0 "dB"$，转角后 $+20 "dB/dec"$], [$0 -> +90 degree$],
  [二阶振荡], [低频 $0 "dB"$，转角 $omega_n$ 后 $-40 "dB/dec"$，$zeta$ 小时有谐振峰], [$0 -> -180 degree$],
  [延时], [$0 "dB"$], [$-omega tau$（随频率线性下降）],
)

一般系统 Bode 图作图步骤：① 将 $G(j omega)$ 化为典型环节乘积（时间常数形式）；② 由静态放大倍数定低频段高度、由各时间常数定转角频率与斜率变化，画近似折线；③ 必要时修正。系统 Bode 图可由各环节 Bode 图叠加得到。

#figure(image("../Figure/Bode图示例.png", width: 86%), caption: [系统 Bode 图作图示例：各环节渐近线与总幅频、相频曲线])


#definition("最小相位系统")[
  开环传递函数在 $s$ 右半平面既无极点又无零点的系统。其幅频特性与相频特性一一对应——已知幅频特性即可唯一确定相频特性；非最小相位系统则不然。
]

== 由频率特性曲线求传递函数

实验测得 Bode 图后，可按以下线索反求传递函数：

+ *转角频率*对应时间常数的倒数（$omega = 1/T$）；
+ *斜率变化*确定环节类型：斜率减小 $20 "dB/dec"$ 对应一个惯性环节，减小 $40$ 对应振荡环节；斜率增大对应微分环节；
+ *低频段高度*确定静态放大倍数：0 型系统为 $20 lg K$；I 型系统为首段 $-20 "dB/dec"$ 延长线与 $omega = 1$ 线的交点高度 $20 lg K$；II 型系统为首段 $-40 "dB/dec"$ 延长线与 $omega = 1$ 线的交点高度 $20 lg K$。

同时用相频特性判断是否为最小相位系统，以确定零点在左半平面还是右半平面。

== 闭环频率特性与频域指标

对单位反馈系统，$Phi(j omega) = G/(1 + G)$。由开环 Bode 图可估计闭环幅频：低频时 $|Phi| approx 1$（0 dB），高频时 $|Phi| approx |G|$，两者在剪切频率附近衔接。

#figure(image("../Figure/开环与闭环频率特性.png", width: 78%), caption: [系统开环与闭环幅频特性对照])

由 Nyquist 图求闭环频率特性：设 $A$ 点对应 $G(j omega_A)$，则

$ Phi(j omega_A) = (O A)/(P A) = (G(j omega_A))/(1 + G(j omega_A)) $

即闭环幅值等于向量 $"OA"$ 与 $"PA"$（$P$ 为 $(-1, j 0)$）的幅值之比，闭环相角等于两向量夹角。

#definition("频域指标")[
  *开环指标*：剪切频率 $omega_c$（$|G| = 1$ 处的频率）、相位裕量 $gamma = 180 degree + phi(omega_c)$、幅值裕量 $K_g = 1\/|G(j omega_g)|$（$phi(omega_g) = -180 degree$）。\
  *闭环指标*：谐振峰值 $M_r$、谐振频率 $omega_r$（幅频最大处）、截止频率 $omega_b$（幅值降至 $-3 "dB"$ 处）。
]

#grid(
  columns: (1.2fr, 1fr),
  column-gutter: 1em,
  figure(image("../Figure/开环频域指标.png", width: 100%), caption: [开环频域指标：$omega_c$、$gamma$、$K_g$]),
  figure(image("../Figure/闭环频域指标.png", width: 100%), caption: [闭环频域指标：$M_r$、$omega_r$、$omega_b$]),
)

$M_r$ 反映系统的相对稳定性（$M_r$ 越大超调越大），$omega_b$ 反映快速性（带宽越宽响应越快）。对标准二阶系统：

$ omega_r = omega_n sqrt(1 - 2 zeta^2), quad quad M_r = 1/(2 zeta sqrt(1 - zeta^2)), quad quad omega_b = omega_n sqrt((1 - 2 zeta^2) + sqrt((1 - 2 zeta^2)^2 + 1)) $

#remark[
  机械系统的动刚度：质量—弹簧—阻尼系统的 $G(j omega)$ 是动柔度，其倒数为动刚度。$omega = 0$ 时动刚度等于静刚度 $k$；共振时动柔度最大、动刚度最小。增大阻尼比可有效提高动刚度。
]
