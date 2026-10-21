#import "../dvd.typ": *

= 时域瞬态响应分析

*瞬态响应*：系统输出从初始状态到稳定状态的响应过程（过渡过程）；*稳态响应*：$t -> oo$ 时的输出状态。时域分析法直观、准确，可提供响应的全部信息。工程上许多高阶系统具有近似一、二阶系统的响应，故重点研究一、二阶系统。

典型输入信号（选择依系统工作条件而定；性能指标通常由阶跃响应定义）：

#table(
  columns: (auto, auto, auto, 2fr),
  align: (left, left, left, left),
  stroke: none,
  table.header([*名称*], [*时域表达式*], [*象函数*], [*说明*]),
  [单位阶跃], [$1(t)$], [$1/s$], [突加常值输入，最常用],
  [单位斜坡], [$t dot 1(t)$], [$1/s^2$], [等速输入，考察跟踪能力],
  [单位加速度], [$t^2/2 dot 1(t)$], [$1/s^3$], [匀加速输入],
  [单位脉冲], [$delta(t)$], [$1$], [响应即冲激响应 $g(t)$],
  [正弦], [$sin omega t$], [$omega/(s^2+omega^2)$], [频域分析的输入],
)

这些信号依次存在微分/积分关系，响应之间亦然（线性定常系统：输入导数的响应等于响应的导数，积分类似）——算出一个即可校验其余。

== 一阶系统的瞬态响应

一阶惯性系统 $G(s) = 1/(T s + 1)$（$T$ 为时间常数），三种典型响应：

#table(
  columns: (auto, auto, auto),
  align: (left, center, center),
  stroke: none,
  table.header([*输入*], [*响应 $x_o(t)$*], [*特性*]),
  [单位阶跃], [$1 - e^(-t\/T)$], [单调上升，无振荡],
  [单位斜坡], [$t - T + T e^(-t\/T)$], [稳态误差 $e_(s s) = T$],
  [单位脉冲], [$1/T e^(-t\/T)$], [$t=0$ 处为 $1\/T$，指数衰减],
)

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 0.8em,
  figure(image("../Figure/一阶单位阶跃响应.png", width: 100%), caption: [单位阶跃响应]),
  figure(image("../Figure/一阶单位斜坡响应.png", width: 100%), caption: [单位斜坡响应]),
  figure(image("../Figure/一阶单位脉冲响应.png", width: 100%), caption: [单位脉冲响应]),
)

#summary[
  一阶系统阶跃响应要点：\
  $t = T$ 时上升到稳态值的 $63.2%$；$3T ~ 4T$ 内达到稳态值的 $95\% ~ 98\%$，取调整时间 $t_s = 3T ~ 4T$（对应 $5%$、$2%$ 误差带）；$t=0$ 处斜率为 $1\/T$，按此斜率上升恰经 $T$ 到达稳态值。$T$ 越小响应越快。\
  由 $e^(-t\/T) = 1 - x_o(t)$ 取对数，$lg[1 - x_o(t)]$ 与 $t$ 呈直线关系（斜率为 $-lg e \/ T$），可用于实验辨识时间常数。
]

== 二阶系统的瞬态响应

标准形式（$omega_n$ 无阻尼自然频率，$zeta$ 阻尼比）：

$ G(s) = omega_n^2/(s^2 + 2 zeta omega_n s + omega_n^2), quad quad "特征根" s_(1,2) = -zeta omega_n plus.minus omega_n sqrt(zeta^2 - 1) $

#table(
  columns: (auto, auto, auto, auto),
  align: (left, left, left, left),
  stroke: none,
  table.header([*阻尼比*], [*极点*], [*名称*], [*阶跃响应*]),
  [$zeta = 0$], [一对纯虚根 $plus.minus j omega_n$], [无阻尼], [等幅振荡],
  [$0 < zeta < 1$], [共轭复根 $-zeta omega_n plus.minus j omega_d$], [欠阻尼], [衰减振荡（最常见）],
  [$zeta = 1$], [二重实根 $-omega_n$], [临界阻尼], [单调上升，无超调],
  [$zeta > 1$], [两个互异负实根], [过阻尼], [单调上升，无超调],
)

其中 $omega_d = omega_n sqrt(1 - zeta^2)$ 为阻尼振荡角频率。欠阻尼（$0 < zeta < 1$）单位阶跃响应：

$ x_o(t) = 1 - e^(-zeta omega_n t)/sqrt(1 - zeta^2) sin(omega_d t + beta), quad quad beta = arccos zeta = arctan (sqrt(1 - zeta^2))/zeta $

由稳态分量 $1$ 与衰减振荡分量叠加而成：包络 $e^(-zeta omega_n t)$ 决定衰减快慢，$omega_d$ 决定振荡快慢。临界阻尼响应为 $x_o(t) = 1 - (1 + omega_n t) e^(-omega_n t)$，是不过冲情形中过渡过程最短者。

== 时域性能指标

#grid(
  columns: (1.15fr, 1fr),
  column-gutter: 1em,
  figure(image("../Figure/二阶性能指标.png", width: 100%), caption: [欠阻尼二阶系统的性能指标]),
  align(horizon)[
    + *上升时间* $t_r$：首次到达稳态值的时间；
    + *峰值时间* $t_p$：首次到达峰值的时间；
    + *最大超调量* $M_p$：峰值超出稳态值的百分比；
    + *延迟时间* $t_d$：到达稳态值 $50%$ 的时间；
    + *调整时间* $t_s$：进入并保持于 $plus.minus 5%$（或 $plus.minus 2%$）误差带的时间；
    + *振荡次数* $N$：调整时间内振荡的周期数。
  ],
)

#table(
  columns: (auto, auto, 1.35fr),
  align: (left, center, left),
  stroke: none,
  table.header([*指标*], [*近似计算*], [*说明*]),
  [$t_r$], [$(pi - beta) \/ omega_d$], [无超调系统改取 $10% -> 90%$ 上升时间],
  [$t_p$], [$pi \/ omega_d$], [由 $d x_o \/ d t = 0$ 的第一个正根得],
  [$M_p$], [$e^(-pi zeta \/ sqrt(1-zeta^2)) times 100%$], [*只与 $zeta$ 有关*，与 $omega_n$ 无关],
  [$t_d$], [$(1 + 0.7 zeta) \/ omega_n$], [经验公式],
  [$t_s$], [$3 \/ (zeta omega_n)$ 或 $4 \/ (zeta omega_n)$], [$5%$ / $2%$ 误差带；与 $zeta omega_n$ 成反比],
  [$N$], [$3 sqrt(1-zeta^2) \/ (2 pi zeta)$], [$N = t_s \/ T_d$，$T_d = 2 pi \/ omega_d$],
)

#summary[
  $M_p$ 与 $N$ 只由 $zeta$ 决定（相对稳定性）；$t_r$、$t_p$、$t_d$、$t_s$ 由 $zeta$ 与 $omega_n$ 共同决定（快速性）。减小 $zeta$ 加快上升但增大超调与振荡；提高 $omega_n$ 各项时间指标缩短而超调不变。工程上常取 $zeta = 0.4 ~ 0.8$ 折中。
]

== 高阶系统的瞬态响应

高阶系统阶跃响应是一系列一阶、二阶分量的叠加；工程上用两条规则降阶近似：

+ *主导极点*：离虚轴最近、留数不为零的极点，其分量衰减最慢、占主导地位。其他极点实部比主导极点大 5 倍以上时可忽略；
+ *偶极子相消*：某零点与某极点相距很近时，对应分量系数近似为零，二者近似相消、可同时略去。

降阶方法：化为首一式 $arrow$ 找主导极点、忽略次要极点（及近距零点）$arrow$ 降为一、二阶系统，令近似模型与原系统*静态增益相同*确定系数。

#example[
  设 $G(s) = (0.2 s + 1) / ((s+0.2)(s+1)(s+10))$。极点 $-0.2$、$-1$、$-10$ 中 $-0.2$ 为主导极点（与 $-1$ 相距 5 倍，$-10$ 更远）。原系统静态增益 $G(0) = 1/(0.2 times 1 times 10) = 0.5$，取 $T = 1/0.2 = 5$，得一阶近似
  $ G(s) approx 0.5/(5 s + 1) $
]
