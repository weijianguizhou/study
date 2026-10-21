#import "@preview/xyznote:0.5.0": *

#show: xyznote.with(
  title: "弹性力学笔记",
  author: "爱吃烧饼的大熊猫",
  abstract: "",
  createtime: "10.14",
  lang: "zh",
  bibliography-style: "ieee",
  preface: [
    #set text(font: ("SimSun", "Times New Roman"), size: 14pt)
    #set heading(numbering: none, outlined: false)

    本笔记是南京理工大学尹晓春老师《弹性力学》课程的学习整理。

    先聊聊尹老师上课前讲的那些话吧。

    尹老师说，他从七八年开始授课，几十年下来，只有一个学生真正学明白了弹性力学。

    那我或许能成为第二个？

    尹老师把学习的目的分为四层：功利、兴趣、竞争和责任。

    尹老师把人才分为两类：优秀人才和尖端人才。

    先说功利。功利是最实在的一层。读书为了什么？为了一纸文凭，为了找份好工作，为了多挣几个钱，为了往后的房子车子都安稳些，这些都是功利。尹老师从不避讳谈功利。他说，人总得先活下去，才谈得上别的，饿着肚子谈情怀不现实。所以功利并不可耻，它恰恰是绝大多数人开始学习的第一个理由。

    可功利也有毛病：它只问"够不够用"，不问"学没学透"。考试一过、工作一找、职称一评，动力就散了。只靠功利读书的人，学到"够用"就停手，多一步都不肯走。这样的人能合格，却很难出众。

    比功利高一层的，是兴趣。兴趣不图什么，只图一个喜欢。真喜欢了，再枯燥的公式也能看出门道来。弹性力学的公式又多又长，若不是觉得它有意思，是很难坐得住的。但兴趣这东西也靠不住，今天有，明天未必还有。光靠兴趣，容易三天打鱼两天晒网，入个门可以，成事却不够。

    再往上是竞争。竞争图的是比别人强。它确实能逼人进步，让人不敢松懈：考试的排名、评奖评优，都属这一类。可竞争的坏处，是把读书变成一场赛跑，眼里只剩对手和名次。而做学问真正的对手从来不是别人，是问题本身。

    最高一层是责任。尹老师说，一个人读到大学、读到研究生，家里供着，国家养着，总得有人去做那些又苦又难、没人愿意干却必须有人干的事。往大了说，国家的科技要人扛；往小了说，本专业、本行业的传承要人接。功利让人出发，兴趣让人上路，竞争让人跑快，可只有责任，才能让人一直走下去。

    说完目的，再说人才。优秀人才是把交代的事做好的人，却仍是可以被替代的人：他是高级的观察者，能轻易看懂尖端人才给出的方案，是一个行业的脊梁。尖端人才则是能开创新局面、做出别人做不出来的东西的人，是真正解决问题、往前再拱一步的人。两类人都要，缺一不可。只是优秀可以培养，尖端往往靠磨炼，因为成材之前，谁也不知道自己究竟是不是那块料。做不了尖端人才，就当优秀人才，当尖端人才的助手。

    == 写在前面：四大方程的一张地图

    题外话说到这里，把眼光收回到课程本身。

    整门课翻起来公式成堆，可骨架只有四组方程。它们各自回答一个很朴素的问题：力怎么才能彼此不打架？变形怎么和位移对上账？材料又是怎么回应力的？最后，凭什么是这一道题而不是别的题？四个位置摆清楚了，后面再往里填细节，就不容易迷路。

    这里先按三维的一般情形，也就是空间问题，把四组方程摆一遍。平面问题不是另立门户，它只是这一套方程在薄板、长柱体上的退化：公式长得几乎一样，只是少了几项。等看到第二章那些式子，回来对一眼这张地图，就知道它们是从哪儿裁下来的。

    *一、平衡微分方程：管「力要自洽」。*

    把物体切成无穷多小块，切出来的每一块也得自己站稳。于是应力的变化率不能随意，它得和体力（自重、惯性力这一类）刚好抵消：

    $ mat(delim: #none, align: #left,
      (∂ sigma_x)/(∂ x) + (∂ tau_(y x))/(∂ y) + (∂ tau_(z x))/(∂ z) + f_x = 0 ",";
      (∂ tau_(x y))/(∂ x) + (∂ sigma_y)/(∂ y) + (∂ tau_(z y))/(∂ z) + f_y = 0 ",";
      (∂ tau_(x z))/(∂ x) + (∂ tau_(y z))/(∂ y) + (∂ sigma_z)/(∂ z) + f_z = 0 ".";
    ) $

    三个方向各一个式子，各自配上该方向的体力分量 $f_x$、$f_y$、$f_z$。写在式子里的是三个正应力，切应力则两两成对、按下标搭好：第一式管 $x$ 方向，凡下标末位为 $x$ 的切应力都到场。这一组纯属静力平衡，不牵扯材料是钢还是混凝土；换个说法，它就是应力散度加体力等于零，即 $nabla dot bold(sigma) + bold(f) = bold(0)$。

    *二、几何方程：管「变形要和位移对得上」。*

    位移是看得见的，应变是从位移里算出来的，中间靠这几条偏导数搭桥：

    $ mat(delim: #none, align: #left,
      epsilon_x = (∂ u)/(∂ x) "," quad epsilon_y = (∂ v)/(∂ y) "," quad epsilon_z = (∂ w)/(∂ z) ",";
      gamma_(x y) = (∂ u)/(∂ y) + (∂ v)/(∂ x) "," quad gamma_(y z) = (∂ v)/(∂ z) + (∂ w)/(∂ y) "," quad gamma_(z x) = (∂ w)/(∂ x) + (∂ u)/(∂ z) ".";
    ) $

    三个正应变加三个切应变，一共六个，同样不需要材料常数。留意切应变都是两个偏导数相加：一根竖线被推歪了，横向的错动和纵向的倾斜都要算在里头。正应变只认自己那一个方向的导数，切应变则要两个方向一起看，这就是「正」与「切」在本义上的分工。

    *三、物理方程：管「材料怎么回应」。*

    前两组方程对什么材料都成立，真正把钢材、混凝土、橡胶区分开的，是这一组。对均匀的各向同性线弹性材料，它就是广义胡克定律：

    $ mat(delim: #none, align: #left,
      epsilon_x = 1/E [sigma_x - mu (sigma_y + sigma_z)] "," quad gamma_(x y) = (2 (1 + mu))/E tau_(x y) ",";
      epsilon_y = 1/E [sigma_y - mu (sigma_z + sigma_x)] "," quad gamma_(y z) = (2 (1 + mu))/E tau_(y z) ",";
      epsilon_z = 1/E [sigma_z - mu (sigma_x + sigma_y)] "," quad gamma_(z x) = (2 (1 + mu))/E tau_(z x) ".";
    ) $

    弹性模量 $E$ 和泊松比 $mu$ 从这里才登场，日常还用到一个切变模量 $G = E\/(2 (1 + mu))$。注意每个正应变都不只由本方向的应力决定：括号里那两项 $mu sigma$ 是横向伸缩短带来的「拖累」，一根受拉的杆子会变细，出处就在这里。反过来由应变解应力，习惯用拉梅常数 $lambda = E mu\/((1 + mu)(1 - 2 mu))$ 和 $G$ 写：$sigma_x = lambda theta + 2 G epsilon_x$，$tau_(x y) = G gamma_(x y)$，其余各式轮换下标即得，其中 $theta = epsilon_x + epsilon_y + epsilon_z$ 是体积应变。

    *四、边界条件：管「这是哪一道题」。*

    前三组方程对任何三维弹性体都成立，所以它们有无穷多组解。真正把这一道题钉死的，是边界上的交代。边界上给定面力的部分，要满足应力边界条件：

    $ mat(delim: #none, align: #left,
      l sigma_x + m tau_(y x) + n tau_(z x) = overline(f)_x ",";
      l tau_(x y) + m sigma_y + n tau_(z y) = overline(f)_y ",";
      l tau_(x z) + m tau_(y z) + n sigma_z = overline(f)_z ";";
    ) quad "（应力边界）" $

    边界上给定位移的部分，则要满足位移边界条件：

    $ u = overline(u) "," quad v = overline(v) "," quad w = overline(w) quad "（位移边界）" $

    这里 $l$、$m$、$n$ 是边界外法线的三个方向余弦，$overline(f)_x$、$overline(f)_y$、$overline(f)_z$ 是边界上给定的面力，$overline(u)$、$overline(v)$、$overline(w)$ 是给定的位移。有的边上给力，有的边上给位移，也有的边一部分给力、一部分给位移，这就是混合边界条件。应力边界那三式的意思很直白：不管外面怎么拉、怎么压，穿过边界传进来的那一份面力，必须和内部应力在边界上的值对得上账。

    #tipbox[
      *小结*　空间问题一共 15 个未知量：6 个应力分量、6 个应变分量、3 个位移分量。四组方程里，平衡 3 个、几何 6 个、物理 6 个，正好 15 个，不多不少；再配上边界条件，就是一个定解问题。

      平面问题是它在薄板、长柱体上的退化：未知量减到 8 个（$sigma_x$、$sigma_y$、$tau_(x y)$、$epsilon_x$、$epsilon_y$、$gamma_(x y)$、$u$、$v$），方程减到 8 个（平衡 2 个、几何 3 个、物理 3 个），形式却一点没变。所以第二章那些公式看着像新的一套，其实都是从这张地图上裁下来的。
    ]

    #note[
      按应力求解时，几何方程被消掉了，但位移的连续性不能跟着丢掉。由 6 个几何方程消去 3 个位移分量，得到 6 个只含应变的变形协调方程（其中 3 个独立，另 3 个可由它们导出）；再用物理方程换成应力，用它顶替几何方程的位置。它的作用就是保证算出来的应变，确实来自一组连续、不会撕裂的位移。平面问题里，这 6 个退化成 1 个。
    ]

    所以这四组方程，说到底就是一句话：力要平衡，变形要连续，材料要有脾气，边界要交代清楚。三维写开是 15 个式子，平面问题裁到 8 个，可意思一个字没变。尹老师说的「学明白」，大概就是把这几行字变成看图、看结构时候的一种本能。
  ],
)

#set text(font: ("SimSun", "Times New Roman"), size: 14pt)

// 图题：模板默认钉在 9pt 楷体（show 规则优先级高于 set 规则），这里覆盖成宋体、略小于正文
#show figure.caption: set text(font: ("SimSun", "Times New Roman"), size: 12pt)
// 图号“图 x.y”也跟着放大，否则它会单独保持 9pt
#show figure: set figure(
  numbering: (..nums) => context {
    set text(font: ("SimSun", "Times New Roman"), size: 12pt)
    numbering("1.1", counter("chapter").at(here()).first(), ..nums)
  },
)

= 平面问题的基本理论
== 平面应力问题与平面应变问题
严格来说任何一个弹性力学问题都是空间问题。但是,如果所考察的弹性体具有某种特殊的形状,并且承受的是某种特殊的外力和约束,就可以把空间问题简化为近似的平面问题。
=== 平面应力问题
#definition[
  当分析对象是很薄的等厚度薄板（如@平面应力问题 所示），且只在板边上受有平行于板面并且不沿厚度变化的面力或约束,同时,体力也平行于板面并且不沿厚度变化，这时的弹性力学问题可以看作一个平面应力问题。
]
#figure(
  image("figure/平面应力问题.png", width: 50%),
  caption: [
    平面应力问题
  ],
) <平面应力问题>
设薄板的厚度为$delta$,以薄板的中面为$x y$面，以垂直于中面的任一直线为$z$轴，因为板的前后面，即$z=plus.minus frac(delta, 2)$处不受力。所以有
$ (sigma_z)_(z=plus.minus frac(delta, 2))=0 wide (tau_(z x))_(z=plus.minus frac(delta, 2))=0 wide (tau_(z y))_(z=plus.minus frac(delta, 2))=0   $

因为板很薄,外力又不沿厚度变化,且应力是连续分布的,所以,可以认为在整个薄板的所有各点都有
$ sigma_z=0 wide tau_(z x)=0 wide tau_(z y)=0 $
再由切应力互等定理，于是只剩下了平行于$x y$面的三个应力分量$sigma_x, sigma_y, tau_(x y) =tau_(y x)$。同时,也因为板很薄,这三个应力分量,以及分析问题时需要考虑的应变分量和位移分量,都可以认为是不沿厚度变化的。这就是说,它们只是$x$和$y$的函数,不随$z$而变化。

== 平面应变问题
#definition[
  设有一很长的柱形体，其横截面不沿长度变化，在柱面上受有平行于横截面并且不沿长度变化的面力或约束，同时体力也平行于横截面并且不沿长度变化（如 @平面应变问题 所示），这时的弹性力学问题可以看作一个平面应变问题。
]

工程中沿长度方向很长的挡土墙、隧道、管道、重力坝等，除去靠近两端的一小段外，中间部分都可近似按平面应变问题处理。

#figure(
  image("figure/平面应变问题.png", width: 50%),
  caption: [平面应变问题],
) <平面应变问题>

假想柱形体的长度趋于无限，以任一横截面为 $x y$ 面，任一纵线为 $z$ 轴。由于截面形状和所受外力都不沿 $z$ 方向变化，所以一切应力分量、应变分量和位移分量都只是 $x$ 和 $y$ 的函数，不随 $z$ 变化。此外，柱体既然无限长，任一横截面都可以看作对称面，截面内的各点只可能沿 $x$、$y$ 方向移动，不可能沿 $z$ 方向移动（否则对称面两侧的材料将发生相对错动）。于是

$ u = u(x, y), quad v = v(x, y), quad w = 0 $

代入几何方程，得到

$ epsilon_z = (∂ w)/(∂ z) = 0, quad gamma_(z x) = (∂ w)/(∂ x) + (∂ u)/(∂ z) = 0, quad gamma_(z y) = (∂ w)/(∂ y) + (∂ v)/(∂ z) = 0 $

这就是说，纵向正应变 $epsilon_z$ 和两个纵向切应变 $gamma_(z x)$、$gamma_(z y)$ 都等于零，只剩下平行于 $x y$ 面的三个应变分量 $epsilon_x$、$epsilon_y$、$gamma_(x y)$，这正是「平面应变」这一名称的由来。

应变分量是三个，应力分量却不只三个。设材料的弹性模量为 $E$，泊松比为 $mu$，切变模量为 $G = E/(2 (1 + mu))$，由物理方程（广义胡克定律）

$ cases(
  epsilon_x = 1/E (sigma_x - mu (sigma_y + sigma_z)),
  epsilon_y = 1/E (sigma_y - mu (sigma_z + sigma_x)),
  epsilon_z = 1/E (sigma_z - mu (sigma_x + sigma_y)) = 0,
  gamma_(x y) = (2 (1 + mu))/E tau_(x y),
) $

其中关于 $epsilon_z$ 的式子给出了 $sigma_z$ 与 $sigma_x$、$sigma_y$ 的关系，即

$ sigma_z = mu (sigma_x + sigma_y) $

可见平面应变问题中虽无 $z$ 方向的应变，却有 $z$ 方向的应力；它一般不等于零，只是不独立，可以由 $sigma_x$、$sigma_y$ 直接算出。把上式代回前两式，得到

$ epsilon_x = (1 - mu^2)/E (sigma_x - mu/(1 - mu) sigma_y), quad epsilon_y = (1 - mu^2)/E (sigma_y - mu/(1 - mu) sigma_x), quad gamma_(x y) = (2 (1 + mu))/E tau_(x y) $

把平面应力问题的物理方程

$ epsilon_x = 1/E (sigma_x - mu sigma_y), quad epsilon_y = 1/E (sigma_y - mu sigma_x), quad gamma_(x y) = (2 (1 + mu))/E tau_(x y) $

与上式逐项对照，可以看出：只要把 $E$ 换成 $E/(1 - mu^2)$，把 $mu$ 换成 $mu/(1 - mu)$，平面应力问题的物理方程就变成了平面应变问题的物理方程。因此两类平面问题在数学形式上是完全相同的：独立未知量都是 $sigma_x$、$sigma_y$、$tau_(x y)$、$epsilon_x$、$epsilon_y$、$gamma_(x y)$、$u$、$v$ 共 8 个，方程也都是 2 个平衡微分方程、3 个几何方程、3 个物理方程，共 8 个，而且边界条件的形式也相同。

#tipbox[
  *小结*　平面应力问题与平面应变问题的控制方程和边界条件形式一致，只是物理方程中的弹性常数不同。因此以后导出的公式和解答，凡含有 $E$、$mu$ 的，都不必重新推导：由平面应力问题的结果按 $E arrow.r E/(1 - mu^2)$、$mu arrow.r mu/(1 - mu)$ 替换，即得平面应变问题的结果；反之，作相反的替换即可。
]

#note[
  两类问题的区别在于形状与受力的组合，而不在于问题是否「二维」。薄板受板面内的力是平面应力问题，此时 $sigma_z = 0$ 而 $epsilon_z eq.not 0$（板厚可以自由改变）；长柱体受横截面内的力是平面应变问题，此时 $epsilon_z = 0$ 而 $sigma_z eq.not 0$。后者容易被误认为「$z$ 方向没有应力」，实际 $sigma_z = mu (sigma_x + sigma_y)$ 往往不可忽略，在混凝土坝、隧洞衬砌等按平面应变计算的构件中，仍需用它校核纵向强度。
]

= 公式

$
  (a + b)^2 = a^2 + 2a b + b^2
$

$a^2-b^2 = (a-b)(a+b)$

= 代码


#figure(
  ```python
  def hello():
    print("Hello, Typst!")
  ```,

  caption: "代码示例",
)

= 自定义样式

This is #highlight(fill: blue.C)[highlighted in blue]. This is #highlight(fill: yellow.C)[highlighted in yellow]. This is #highlight(fill: green.C)[highlighted in green]. This is #highlight(fill: red.C)[highlighted in red].

#sectionline

#brainstorming(lang: "en")[
  This is a brainstorming.
]

#definition[
  This is a definition.
]

#pagebreak()

#question[
  This is a question.
]

#task[
  This is a task.
]

#brainstorming(lang: "zh")[
  This is a brainstorming.
]

#definition(lang: "zh")[
  This is a definition.
]

#question(lang: "zh")[
  This is a question.
]

#task(lang: "zh")[
  This is a task.
]

#sectionline

#tipbox[
  contents
]

#markbox[
  contents
]

#sectionline

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    [77],[77],[77],
    [77],[77],[77],
    [77],[77],[77],
  )
)
