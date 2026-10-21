/* ============================================================================
 *  机械设计 · 学习笔记（Typst 版）
 *  模板：inelegant-note 0.9.1（https://typst.app/universe/package/inelegant-note）
 *  内容由 LaTeX 版笔记转换而来，正文表述与公式沿用原笔记；
 *  摩擦磨损及润滑、滚动螺旋传动、蜗杆传动三章据课程课件（03/07/11 章）补入。
 *
 *  编译（务必指定输出名，避免覆盖 LaTeX 版 机械设计.pdf）：
 *      typst compile 机械设计.typ 机械设计-typst.pdf
 *  依赖：Typst ≥ 0.13；首次编译会自动下载模板及其依赖包。
 *  字体：正文 思源宋体（Source Han Serif SC）；标题 思源黑体（缺失时回退 Noto Sans SC）。
 * ============================================================================ */

#import "@preview/inelegant-note:0.9.1": *

// ----------------------------------------------------------------------------
//  字体：模板默认 Sans 为「Source Han Sans SC（思源黑体）」，未安装时回退到
//        「Noto Sans SC / 黑体」；正文衬线优先思源宋体。
// ----------------------------------------------------------------------------
#let my-sans = (
  (name: "Noto Sans SC", covers: "latin-in-cjk"),
  "Source Han Sans SC",
  "Noto Sans SC",
  "SimHei",
)
#let my-serif = (
  (name: "Source Han Serif SC", covers: "latin-in-cjk"),
  "Source Han Serif SC",
  "SimSun",
)

// ----------------------------------------------------------------------------
//  封面（模板样式；封面图缺省）
// ----------------------------------------------------------------------------
#{
  show text: set text(font: my-sans)
  cover-environment(
    title: [机械设计],
    subtitle: "Machine Design · 学习笔记",
    author: "魏舟",
    // date: datetime(year: 2026, month: 10, day: 15),
    cover-image:none ,
  )
}

#show: overall

// 章、节标题字体适配
#show heading: set text(font: my-sans)

// ----------------------------------------------------------------------------
//  盒子样式：沿用模板配色，标题字体统一为 my-sans，并新增「特征」「公式」盒
// ----------------------------------------------------------------------------
#let md-head = (size: 10.5pt, font: my-sans, weight: "regular", fill: black)
#let md-body = (size: 10.5pt, font: my-serif, weight: "regular", fill: black)

#let md-frame(identifier, name, color) = make-frame(
  identifier, name, inherited-levels: 1,
  render: my-fancy-box.with(
    border-color: color, title-color: color,
    body-color: color.lighten(95%), end-symbol: none,
    head-text: md-head, body-text: md-body,
  ),
)

#let (_, _, definition-showy, show-md-definition) = md-frame("md-definition", [定义], rgb("f19790"))
#let (_, _, theorem-showy, show-md-theorem) = md-frame("md-theorem", [定理], rgb("619ac3"))
#let (_, _, example-showy, show-md-example) = md-frame("md-example", [例], rgb("bec936"))
#let (_, _, feature-showy, show-md-feature) = md-frame("md-feature", [特征], rgb("63bbd0"))
#let (_, _, formula-showy, show-md-formula) = md-frame("md-formula", [公式], rgb("fba414"))

#let md-shows(body) = {
  show: show-md-definition
  show: show-md-theorem
  show: show-md-example
  show: show-md-feature
  show: show-md-formula
  body
}
#show: md-shows

// 注记盒：note（蓝）/ key（深蓝）/ warn（红）/ remark（灰引用条）
#let md-note-box(md-title, fill, icon, body) = my-notebox-rainbow(
  head-text: (size: .95em, weight: "regular", font: my-sans),
  body-text: (size: .95em, weight: "regular", font: my-serif, fill: black),
  fill: fill, title: md-title, icon-name: icon, body,
)
#let note-box(title: "注", body) = md-note-box(title, rgb("#0969da"), "info", body)
#let key-box(title: "重点", body) = md-note-box(title, rgb("#123a7d"), "bookmark", body)
#let warn-box(title: "注意", body) = md-note-box(title, rgb("#d1242f"), "alert", body)
#let remark-box(body) = my-quotebox-rainbow(
  body-text: (size: .95em, weight: "regular", font: my-serif, fill: black),
  body,
)

// 三线表
#let md-table(columns, head, ..rows) = table(
  columns: columns,
  stroke: none,
  inset: (x: 6pt, y: 5pt),
  table.hline(stroke: 0.08em),
  table.header(..head),
  table.hline(stroke: 0.05em),
  ..rows.pos(),
  table.hline(stroke: 0.08em),
)

// ----------------------------------------------------------------------------
//  前辅文：格言页、前言、目录
// ----------------------------------------------------------------------------
#front-matter[
  #align(center + horizon)[
    #text(font: "KaiTi", size: 17pt)[知者创物，巧者述之守之，世谓之工。]
  ]

  = 前言

  本笔记整理自《机械原理与机械设计（下）》（范元勋、梁医、张龙主编）的读书笔记与课程课件，现收录机械设计概论、机械零件的强度、摩擦磨损及润滑、螺纹连接、轴毂连接、滚动螺旋传动、带传动、链传动、齿轮传动、蜗杆传动、轴、滑动轴承、滚动轴承等全部章节。

  整理原则如下：

  - 概念、定义与计算公式一律沿用教材原文的表述与写法，仅作版式重排与环境归类，不改写、不删减；
  - 存疑或待补之处以醒目的标注框标出，不作臆改。

  #my-outline()
]

// ----------------------------------------------------------------------------
//  正文
// ----------------------------------------------------------------------------
#show: main-matter

// ============================================================================
//  第一章 机械设计概论
// ============================================================================

= 机械设计概论

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

== 机器、机械与机械零件

#definition-showy(title: "机器")[
  *机器*(_machine_)是人类进行生产以减轻体力劳动和提高劳动生产率的主要工具。
]

#definition-showy(title: "机械")[
  *机械*(_machinery_)是机器和机构(_mechanism_)的总称。使用机械进行生产的水平是衡量一个国家的技术水平和现代化程度的重要标志之一。
]

#definition-showy(title: "零件与部件")[
  组成机器的不可拆的基本单元称为*机械零件*(_machine elements_)或简称*零件*；为完成特定的功能在结构上组合在一起并协同工作的零件组合称为*部件*(_mechanical components_)，如联轴器、轴承、减速器等。机械零件一般泛指零件与部件。
]

#figure(
  image("Figure/零件示意图.png", width: 50%),
  caption: [零件示意图（连杆组件装配示意）],
)<fig-零件示意图>

#figure(
  image("Figure/轴承部件图.png", width: 85%),
  caption: [轴承部件图（几种滚动轴承剖面模型）],
)<fig-轴承部件图>

#definition-showy(title: "通用零件与专用零件")[
  各种机器中普遍使用的零件称*通用零件*(_universal components_)，如螺钉、键、带、齿轮、轴、弹簧等；只在特定的机器上使用的零件称为*专用零件*(_special components_)，如发动机的曲轴、汽轮机的叶片、船用螺旋桨等都是专用零件。
]

#definition-showy(title: "机构")[
  *机构*(_mechanism_)是能实现预期的机械运动的实物组合。机械的共同特征为：（1）人为的实物组合；（2）其组成各部分之间具有确定的相对运动；（3）必须能做有用功，完成信息的传递及能量的转换。机构仅具有特征（1）（2），机器能做有用功，而机构不能，仅能实现预期的机械运动；机器是由一个或多个机构组成的系统。
]

#definition-showy(title: "机器")[
  *机器*通常由以下部分组成：

  + 原动机：机械动力的来源；
  + 执行机构：完成机械预期的动作；
  + 传动机构：把原动机的运动和功率传递给工作机的中间环节；
  + 自动控制部分（控制系统）。
]

#definition-showy(title: "构件")[
  *构件*是组成机器的运动单元体，具有确定的运动。按照其在机器中所起的作用可分为：

  + 机架：固定不动的构件；
  + 原动件（输入构件）：驱动力（矩）作用的构件；
  + 从动件（输出构件）：随着原动构件的运动而运动的构件。
]

== 标准化、系列化与通用化

#definition-showy(title: "标准化")[
  在不同类型、不同规格的各种机器中，将同类零件或部件的结构型式、尺寸、材料等限定在合理的数量范围内，称为*标准化*(_standardization_)。
]

#definition-showy(title: "标准件与非标准件")[
  按规定标准生产并给以标准代号的零件和部件称为*标准件*(_standard components_)，不按规定标准生产的零件和部件称为*非标准件*。
]

#definition-showy(title: "系列化")[
  根据要求，按一定规律优化组合零、部件系列，称为*系列化*。系列化是标准化的重要内容，如螺栓系列、滚动轴承的类型和尺寸系列等。
]

#definition-showy(title: "通用化")[
  最大限度地减少和合并零、部件的型式、尺寸和材料品种等，称为*通用化*(_universalization_)。
]

#key-box(title: "三化")[
  标准化、系列化、通用化通称*三化*。
]

== 机械设计的基本要求

=== 对机器设计的基本要求

*（1）对机器使用功能方面的要求。*

+ 实现预定的使用功能是机器设计的最基本的要求，
+ 好的使用性能指标是设计的主要目标。
+ 操作使用方便、工作安全可靠、体积小、重量轻、效率高、外形美观、噪声低等往往也是机器设计时所要求的。
+ 对不同用途的机器还可能提出一些特殊的要求，如巨型机器有起重运输的要求，对生产食品的机器有保持清洁和不污染环境的要求等。

*（2）对机器经济性的要求。*

+ 设计的经济性体现为合理的功能定位、实现使用功能要求的最简单的技术途径和最简单、合理的结构；
+ 制造的经济性体现为采用合理的加工制造工艺、尽可能采用新的制造技术和最佳的生产组织管理，从而使机器在保证设计功能的前提下有尽可能低的制造成本；
+ 使用的经济性表现为机器应有较高的生产率、高效率，较少地消耗能源、原材料和辅助材料，管理和维护保养方便、费用低。

=== 对机械零件设计的基本要求

+ 要求在预定的工作期限内正常可靠地工作，从而保证机器的各种功能的正常实现；
+ 要尽量降低零件的生产制造成本。

== 机械设计的一般程序

=== 机器设计的一般程序

机器设计一般划分为市场调研与可行性研究、原理方案设计、技术设计、改进设计四个阶段，各阶段均设有评价与反馈环节，其流程如 @fig-机器设计一般程序 所示。

#figure(
  image("Figure/机器设计一般程序.svg", width: 100%),
  caption: [机器设计的一般程序],
)<fig-机器设计一般程序>

=== 机械零件设计的一般步骤

+ 根据机器的工作情况，按力学方法建立零件简化的力学模型，确定零件上的计算载荷。

  根据原动机的额定功率或根据机器在稳定和理想工作条件下的工作阻力，按力学方法计算出的作用在零件上的载荷称为*名义载荷*（或称公称载荷、额定载荷）。考虑原动机与工作机间实际载荷随时间的变化、载荷在零件上分布的不均匀性及其他影响零件受力等因素的影响，引入载荷系数 $K$（或工作情况系数）来作概略估计。载荷系数 $K$ 与名义载荷的乘积称为*计算载荷*。

+ 根据零件的使用要求，选择零件的类型与结构。

+ 根据零件的工作条件和材料的力学性能等选择适当的零件材料。

+ 据零件可能的失效形式确定计算准则，并根据零件的工作能力准则，确定零件的基本尺寸，并加以标准化和圆整。

+ 根据工艺性和标准化等原则进行零件的结构设计。

+ 绘制零件工作图，并编写计算说明书。

#definition-showy(title: "名义载荷与计算载荷")[
  根据原动机的额定功率或根据机器在稳定和理想工作条件下的工作阻力，按力学方法计算出的作用在零件上的载荷称为*名义载荷*（或称公称载荷、额定载荷）；载荷系数 $K$（或工作情况系数）与名义载荷的乘积称为*计算载荷*。
]

=== 设计计算与校核计算

机械零件的计算可分为*设计计算*（_design calculation_）和*校核计算*（_checking calculation_）两种。

#definition-showy(title: "设计计算")[
  先根据零件的工作情况和选定的工作能力准则拟定出安全条件，用计算方法求出零件危险截面的尺寸，然后根据结构和工艺要求，确定具体的零件结构。
]

#definition-showy(title: "校核计算")[
  先参照已有的零件实物、图纸或根据经验初步拟定零件的结构和基本尺寸，然后根据工作能力准则校核危险截面是否安全。
]

#note-box[
  校核计算时，因为已知零件的有关尺寸和结构，所以计算结果一般较精确。
]

== 机械零件的主要失效形式和设计计算准则

=== 机械零件的失效形式

#definition-showy(title: "失效")[
  *失效*(_failure_)：机械零件丧失正常工作能力或达不到设计要求的性能时称为失效。
]

机械失效形式虽然有很多种，但归结起来可以总结为以下问题：

+ 强度
+ 刚度
+ 耐磨性
+ 温度对工作能力的影响
+ 振动稳定性
+ 可靠性

#figure(
  image("Figure/一些失效案例.png", width: 100%),
  caption: [齿轮类零件的失效案例],
)<fig-失效案例>

=== 机械零件的计算准则

#definition-showy(title: "工作能力")[
  零件不发生失效时的安全工作限度称为*工作能力*。
]

#definition-showy(title: "计算准则")[
  *计算准则*（_criterion_）：根据零件失效分析结果，以防止产生各种可能失效为目的，拟定的零件工作能力计算依据的基本原则。
]

*1. 强度准则*

#definition-showy(title: "强度")[
  *强度*(_strength_)是指零件抵抗破坏的能力。强度准则要求零件中的应力不超过许用极限，其表达式为

  $ sigma <= [sigma] = sigma_"lim" / S_sigma $

  $ tau <= [tau] = tau_"lim" / S_tau $
]

*2. 刚度准则*

#definition-showy(title: "刚度")[
  *刚度*(_rigidity_)是零件在载荷作用下抵抗弹性变形的能力。刚度准则要求为：零件的弹性变形 $y$ 小于或等于许用的弹性变形量 $[y]$。其表达式为

  $ y <= [y] $
]

*3. 耐磨性准则*

#definition-showy(title: "耐磨性")[
  *耐磨性*(_wear resistance_)是作相对运动的零件及其工作表面抵抗磨损的能力。耐磨性准则要求零件工作表面的压强及压强—速度乘积不超过许用值，即

  $ p <= [p] $

  $ p v <= [p v] $

  其中，$p$ 为工作压强，$[p]$ 为许用压强；$p v$ 为压强—速度乘积，$[p v]$ 为许用 $p v$ 值。
]

#note-box[
  正常磨损是指磨损速度稳定缓慢，在预定的使用期限内，零件的磨损量不超过允许值。
]

*4. 振动与噪声准则*

#definition-showy(title: "振动与噪声准则")[
  对高速机械或对噪声有严格要求的机械，应进行振动分析和计算，确定机械或零件的固有频率 $f$ 或强迫振动频率 $f_p$，并分析噪声源。为保证机械能稳定工作，应避免共振，即

  $ cases(
    f_p < 0.85 f,
    f_p > 1.15 f,
  ) $

  其中，$f$ 为固有频率，$f_p$ 为强迫振动频率。
]

#note-box[
  不满足上述条件时，可改变机械或零件的刚度，或采取减振措施。
]

*5. 热平衡准则*

#definition-showy(title: "热平衡准则")[
  工作时发生剧烈摩擦的零件，其摩擦部位会产生大量的热。若散热不良，则零件的温度升高，会破坏正常的润滑条件、使零件承载能力降低，并引起热变形及热应力。热平衡准则要求：达到热平衡时，机械或零件的温升不超过正常工作允许的最大温升。
]

*6. 可靠性准则*

#definition-showy(title: "可靠度")[
  在规定的工作条件下和预定的工作期限内，零件正常工作（不发生失效）的概率称为*可靠度*，即

  $ R_t = N_t/N = (N - N_f)/N = 1 - N_f/N $
]

#definition-showy(title: "不可靠度")[
  零件失效的概率称为*不可靠度*（失效概率），即

  $ F_t = N_f/N = 1 - R_t $

  其中，$N$ 为零件总数量，$N_t$ 为正常工作零件数，$N_f$ 为失效零件数。
]

#note-box[
  由多个零件组成的串联系统，任一零件失效都会引起整个系统的失效，整个机器的可靠度为

  $ R = R_1 R_2 dots.c R_n $

  机械零件可靠性水平的高低，直接影响机械系统的可靠性。
]

== 机械零件的常用材料

=== 常用材料

==== 黑色金属（铁基）

+ *灰铸铁*：铸造性好、减震耐磨、成本低，多用于机座、箱体、床身；
+ *球墨铸铁*：强度韧性优于普通铸铁，可替代部分钢材，用于制造曲轴、齿轮；
+ *可锻铸铁*：塑性韧性较好，适合薄壁复杂小件；
+ *铸钢*：强度高，适合承受大载荷的铸造零件；
+ *碳钢、合金钢*：机械中使用最多，可热处理强化，用于轴、齿轮、螺栓等受力零件。

#figure(
  image("Figure/黑色金属材料.png", width: 95%),
  caption: [黑色金属材料示例],
)

==== 有色金属（非铁金属）

+ *铝合金*：密度小、可减重，用于壳体、支架；
+ *铜合金（黄铜、青铜）*：减摩耐磨、导热导电，用于轴承、蜗轮、垫片；
+ *钛合金*：比强度高、耐腐蚀，多用于高端设备。

#figure(
  image("Figure/有色金属材料.png", width: 95%),
  caption: [有色金属材料示例],
)

==== 非金属材料

+ *工程塑料*（尼龙、POM 聚甲醛等）：耐磨、自润滑，用于制造轻载齿轮、滑块；
+ *橡胶*：用于减振、密封件；
+ *陶瓷*：耐磨耐高温，用于特殊工况。

#figure(
  image("Figure/非金属材料.png", width: 95%),
  caption: [非金属材料示例],
)

==== 复合材料

复合材料（如碳纤维复合材料、氧化陶瓷基复合材料等）由两种或多种性质不同的材料组合而成，具有纤维增强、轻质高强等特点，在航空航天等领域应用广泛。

#figure(
  image("Figure/复合材料.png", width: 90%),
  caption: [复合材料在航空领域中的应用],
)

=== 机械零件材料的选用要求

*（1）使用要求。*根据零件的受载情况和工作状况、对零件尺寸和质量的限制、零件的重要程度等提出要求。

*（2）工艺要求。*要考虑毛坯制造、机械加工、热处理等工艺的可行性。

*（3）经济性要求。*考虑材料的相对价格、零件质量、加工性能及加工费用、材料的利用率，遵循局部品质原则，在性能相近时选用廉价的材料。

// ============================================================================
//  第二章 机械零件的强度
// ============================================================================

= 机械零件的强度

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

== 载荷与应力的分类

=== 载荷的分类

#definition-showy(title: "静载荷")[
  *静载荷*：载荷的大小和方向不随时间变化或变化缓慢的载荷。
]

#definition-showy(title: "变载荷")[
  *变载荷*：载荷的大小和方向随时间变化的载荷。变载荷可分为

  + 循环变载荷：
    + 稳定循环载荷；
    + 不稳定循环载荷。
  + 随机变载荷。
]

=== 应力的分类

#definition-showy(title: "静应力")[
  *静应力*：不随时间变化或变化缓慢的应力，其随时间的变化规律如 @fig-静应力 所示。
]

#figure(
  image("Figure/静应力.png", width: 52%),
  caption: [静应力],
)<fig-静应力>

#definition-showy(title: "变应力")[
  *变应力*：随时间变化的应力，可分为

  + *不稳定变应力*：
    + 规律性不稳定变应力，如 @fig-规律性不稳定变应力 所示；
    + 随机变应力，如 @fig-随机变应力 所示。
  + *稳定循环变应力*：
    + 非对称循环变应力，如 @fig-非对称循环变应力 所示；
    + 脉动循环变应力，如 @fig-脉动循环变应力 所示；
    + 对称循环变应力，如 @fig-对称循环变应力 所示。
]

#figure(
  image("Figure/规律性不稳定变应力.png", width: 60%),
  caption: [规律性不稳定变应力],
)<fig-规律性不稳定变应力>

#figure(
  image("Figure/随机变应力.png", width: 55%),
  caption: [随机变应力],
)<fig-随机变应力>

#figure(
  image("Figure/非对称循环变应力.png", width: 72%),
  caption: [非对称循环变应力],
)<fig-非对称循环变应力>

#figure(
  image("Figure/脉动循环变应力.png", width: 68%),
  caption: [脉动循环变应力],
)<fig-脉动循环变应力>

#figure(
  image("Figure/对称循环变应力.png", width: 68%),
  caption: [对称循环变应力],
)<fig-对称循环变应力>

=== 稳定循环变应力的基本参数

稳定循环变应力的基本参数包括最大应力 $sigma_"max"$、最小应力 $sigma_"min"$、平均应力 $sigma_m$ 和应力幅 $sigma_a$，其相互关系如下。

#definition-showy(title: "平均应力")[
  *平均应力*是指循环变应力中静应力分量的部分，其值为

  $ sigma_m = (sigma_"max" + sigma_"min")/2 $
]

#definition-showy(title: "应力幅")[
  *应力幅*是指循环变应力中变动应力分量的部分，其值为

  $ sigma_a = (sigma_"max" - sigma_"min")/2 $
]

#definition-showy(title: "应力循环特性（循环比）")[
  *应力循环特性（循环比）*是指最小应力与最大应力之比，即

  $ gamma = sigma_"min"/sigma_"max", quad -1 < gamma < +1 $
]

#key-box(title: "脉动循环与对称循环")[
  脉动循环变应力：$gamma = sigma_"min"/sigma_"max" = 0$（$sigma_"min" = 0$）；

  对称循环变应力：$gamma = sigma_"min"/sigma_"max" = -1$（$sigma_"max" = -sigma_"min"$）。
]

#note-box[
  静应力只能由#text(fill: red)[静载荷]产生；而变应力可能由#text(fill: red)[变载荷]产生，也可能由#text(fill: red)[静载荷]产生。对强度最不利的是#text(fill: red)[对称循环变应力]（$gamma = -1$）。
]

#figure(
  image("Figure/静载荷动应力的例子.png", width: 60%),
  caption: [静载荷产生动应力的例子],
)<fig-静载荷动应力的例子>

=== 名义应力和计算应力

#definition-showy(title: "名义应力")[
  *名义应力*：由名义载荷产生的应力。
]

#definition-showy(title: "计算应力")[
  *计算应力*：由计算载荷产生的应力。

  $ F_"ca" = K F $

  其中，$F_"ca"$ 为计算载荷（_calculated load_），$K$ 为载荷系数（_load factor_），$F$ 为名义载荷（_nominal load_）。
]

== 静应力时机械零件的强度计算

=== 静应力下机械零件的强度

==== 单向应力下的塑性材料零件

按照#text(fill: red)[不发生塑性变形]的条件进行强度计算，零件危险剖面上的工作应力即为计算应力，强度条件为

#theorem-showy(title: "单向应力塑性材料零件的强度条件")[
  $ cases(
    sigma_"ca" <= [sigma] = sigma_"s"/[S]_sigma,
    tau_"ca" <= [tau] = tau_"s"/[S]_tau,
  ) $

  或

  $ cases(
    S_sigma = sigma_"s"/sigma_"ca" >= [S]_sigma,
    S_tau = tau_"s"/tau_"ca" >= [S]_tau,
  ) $

  其中，$S_sigma$、$S_tau$ 分别为正应力和切应力的计算安全系数；$[S]_sigma$、$[S]_tau$ 分别为正应力和切应力的许用安全系数。
]

==== 复合应力时的塑性材料零件（弯扭联合作用）

根据第三、第四强度理论计算，强度条件为

#theorem-showy(title: "复合应力塑性材料零件的强度条件")[
  $ cases(
    sigma_"ca" = sqrt(sigma^2 + 4 tau^2) <= [sigma] = sigma_"s"/[S] &"（第三强度理论）",
    sigma_"ca" = sqrt(sigma^2 + 3 tau^2) <= [sigma] = sigma_"s"/[S] &"（第四强度理论）",
  ) $

  其中第三强度理论近似取 $sigma_"s"/tau_"s" = 2$，第四强度理论近似取 $sigma_"s"/tau_"s" = sqrt(3)$。则复合应力计算时的安全系数为

  $ S_"ca" = sigma_"s"/sqrt(sigma^2 + (sigma_"s"/tau_"s")^2 tau^2) >= [S] $

  或

  $ S_"ca" = (S_sigma S_tau)/sqrt(S_sigma^2 + S_tau^2) >= [S] $
]

==== 脆性材料和低塑性材料零件

此时零件的极限应力为材料的强度极限 $sigma_"b"$ 或 $tau_"b"$。

*（1）单向应力状态下的零件*，应按#text(fill: red)[不发生断裂]作为强度计算的条件。将单向应力下塑性材料零件的计算应力公式中的 $sigma_"s"$、$tau_"s"$ 分别改为 $sigma_"b"$、$tau_"b"$ 即可。

*（2）复合应力状态下的零件*，其强度条件应按第一强度理论确定：

#theorem-showy(title: "脆性材料复合应力零件的强度条件")[
  $ sigma_"ca" = 1/2 (sigma + sqrt(sigma^2 + 4 tau^2)) <= [sigma] = sigma_"b"/[S] $

  $ S_"ca" = (2 sigma_"b")/(sigma + sqrt(sigma^2 + 4 tau^2)) >= [S] $
]

== 机械零件的疲劳强度计算

=== 变应力作用下机械零件的失效特征

==== 失效形式

#definition-showy(title: "变应力下的失效形式")[
  *失效形式*：疲劳破坏（断裂）。
]

#figure(
  image("Figure/疲劳破坏过程.png", width: 70%),
  caption: [疲劳破坏过程],
)<fig-疲劳破坏过程>

==== 疲劳破坏特征

#definition-showy(title: "疲劳破坏特征")[
  + *断裂过程*：（1）产生微观初始裂纹；（2）裂纹尖端在切应力作用下反复扩展，直至产生宏观疲劳裂纹；（3）达到临界尺寸后突然断裂。
  + *断裂面*：（1）光滑区（疲劳发展区）；（2）粗糙区（脆性断裂区）。
  + 无明显塑性变形的#text(fill: red)[脆性突然断裂]。
  + 破坏时的应力（疲劳极限）*远小于*屈服极限。
]

==== 疲劳破坏的机理与影响因素

#definition-showy(title: "疲劳破坏的机理与影响因素")[
  *疲劳破坏的机理*：损伤的累积。

  *影响因素*：应力循环次数、变应力的循环特性、应力幅，还与材料抗疲劳性能有关。当 $sigma_m$、$gamma$ 一定时，$sigma_a$ 越小，材料寿命越长（极限循环次数 $N$ 越大），越不容易产生疲劳破坏。
]

#note-box[
  课件原文此处写作"$sigma_a$ 越小，$N$ 越少"，与疲劳曲线规律（应力幅越小、寿命越长）相反，笔记按正确结论"$N$ 越大"记录。
]

=== 材料的疲劳曲线和疲劳极限

#definition-showy(title: "疲劳极限")[
  *疲劳极限* $sigma_(gamma N)$（$tau_(gamma N)$）：循环变应力下，应力循环 $N$ 次后材料不发生疲劳破坏时的最大应力。
]

#definition-showy(title: "疲劳寿命")[
  *疲劳寿命* $N$：材料疲劳失效前所经历的应力循环次数。
]

#definition-showy(title: "疲劳曲线")[
  *疲劳曲线*：应力循环特性 $gamma$ 一定时，材料的疲劳极限与应力循环次数之间的关系曲线。其中 $N_0$ 为*循环基数*（$(10 tilde 25) times 10^7$），$sigma_gamma$ 为*持久极限*。
]

#figure(
  image("Figure/疲劳曲线.png", width: 70%),
  caption: [材料的疲劳曲线],
)<fig-疲劳曲线>

*（1）有限寿命区* $N < N_0$：

- 低周循环疲劳 $N < 10^3 (10^4)$：疲劳极限接近于屈服极限，按静强度计算。如压力容器、火箭发动机的某些零件等。
- 高周循环疲劳 $N >= 10^3 (10^4)$：如弹簧、传动轴等；*随循环次数$arrow.t$，疲劳极限$arrow.b$*。

*（2）无限寿命区* $N >= N_0$：$sigma_(gamma N) = sigma_gamma$（持久极限）。

- 对称循环：$sigma_(-1)$、$tau_(-1)$；脉动循环：$sigma_0$、$tau_0$。
- 注意：*有色金属和高强度合金钢无无限寿命区*。

#theorem-showy(title: "疲劳曲线方程")[
  $ sigma_(gamma N)^m dot N = sigma_gamma^m dot N_0 = C $

  $ therefore quad sigma_(gamma N) = root(m, N_0/N) sigma_gamma = K_N dot sigma_gamma $

  $ K_N = root(m, N_0/N) quad "——寿命系数" $

  采用寿命系数，通过疲劳曲线方程，可计算任意循环次数 $N$ 下的疲劳极限应力 $sigma_(gamma N)$。
]

#note-box[
  + $N_0$：硬度 $<= 350 "HBS"$ 钢，$N_0 = 10^7$；$>= 350 "HBS"$ 钢，$N_0 = (10 tilde 25) times 10^7$；有色金属（无水平部分）规定当 $N > 25 times 10^7$ 时取 $N = N_0 = 25 times 10^7$ 近似为无限寿命区。
  + $m$——指数与应力和材料种类有关。钢 $m = 9$（拉、弯应力，剪应力）、$m = 6$（接触应力）；青铜 $m = 9$（弯曲应力）、$m = 8$（接触应力）。
  + 应力循环特性 $gamma$ 越大，材料的疲劳极限与持久极限越高，对零件强度越有利；*对称循环（$gamma = -1$）最不利*。
]

=== 材料的疲劳极限应力图（$sigma_m - sigma_a$ 图）

同一种材料（标准试件）在不同的应力循环特性下进行疲劳试验，可得到持久极限 $sigma_gamma$（即 $sigma_"max"$）；由应力循环特性可求出 $sigma_"min" = gamma sigma_"max"$ 和 $sigma_m$、$sigma_a$；以 $sigma_m$ 为横坐标、$sigma_a$ 为纵坐标，即得材料在不同应力循环特性下的极限 $sigma_m$ 和 $sigma_a$ 的关系图。

#definition-showy(title: "材料的疲劳极限应力图")[
  *塑性材料的疲劳极限应力图呈抛物线分布（$A' B$ 曲线）*。四个特征点为：

  - $A'(0, sigma_(-1))$ —— 对称疲劳极限点；
  - $D'(sigma_0/2, sigma_0/2)$ —— 脉动疲劳极限点；
  - $B(sigma_"B", 0)$ —— 强度极限点；
  - $C(sigma_"s", 0)$ —— 屈服极限点。

  曲线上的点对应着不同应力循环特性下材料的疲劳极限 $sigma_gamma$。
]

#figure(
  image("Figure/材料的疲劳极限应力图.png", width: 70%),
  caption: [材料的疲劳极限应力图],
)<fig-材料的疲劳极限应力图>

#definition-showy(title: "简化疲劳极限应力图")[
  考虑塑性材料的最大应力不超过屈服极限，由 $C$ 点作 $135 degree$ 斜线与 $A' D'$ 的延长线交于 $G'$，得到折线 $bold(A' D' G' C)$。

  - 折线上各点的横坐标——极限平均应力 $sigma_m'$；纵坐标——极限应力幅 $sigma_a'$。
  - $G' C$ 上各点：$sigma_"max"' = sigma_m' + sigma_a' = sigma_"s"$，若 $sigma_"max" < sigma_"s"$ 不会屈服破坏。
  - 折线*以内*——疲劳和塑性安全区；*以外*——疲劳和塑性失效区。
  - 零件工作应力点 $(sigma_m, sigma_a)$ 应位于 $A' D' G' C$ 以内。
]

#figure(
  image("Figure/材料的简化疲劳极限应力图.png", width: 70%),
  caption: [材料的简化疲劳极限应力图],
)<fig-材料的简化疲劳极限应力图>

=== 影响机械零件疲劳强度的主要因素和零件极限应力图

实际机械零件与标准试件之间有差异，使零件的疲劳极限不同于材料的疲劳极限，其中尤以#text(fill: red)[应力集中、零件尺寸和表面状态]对机械零件的疲劳强度影响最大。

==== 应力集中的影响——有效应力集中系数 $k_sigma (k_tau)$

零件受载时，在几何形状突变处（圆角、凹槽、孔等）产生应力集中。材料强度越高、硬度越高，对应力集中越敏感。

#definition-showy(title: [有效应力集中系数 $k_sigma (k_tau)$])[
  *有效应力集中系数*为

  $ k_sigma = 1 + q_sigma (alpha_sigma - 1) $

  其中，$q_sigma$ 为材料的敏感系数。
]

#definition-showy(title: "理论应力集中系数")[
  *理论应力集中系数*为

  $ alpha_sigma = sigma_"max"/sigma $

  其中，$sigma_"max"$ 为实际最大应力，$sigma$ 为名义应力。
]

==== 零件尺寸的影响——尺寸系数 $epsilon_sigma (epsilon_tau)$

#definition-showy(title: [尺寸系数 $epsilon_sigma (epsilon_tau)$])[
  *尺寸系数*反映零件尺寸对疲劳强度的影响：零件尺寸愈大时，材料的晶粒较粗、出现缺陷的概率大，而机械加工后表面冷作硬化层相对较薄，所以对零件疲劳强度的不良影响愈显著。
]

==== 表面状态的影响

#definition-showy(title: "表面状态的影响因素")[
  表面状态的影响因素有：表面加工质量、表面强化处理工艺和表面腐蚀状况等。

  + *表面质量系数 $beta_1$*：零件加工的表面质量（主要指表面粗糙度）对疲劳强度的影响。钢的 $sigma_"B"$ 越高、表面愈粗糙，$beta_1$ 愈低。
  + *表面强化系数 $beta_2$*：考虑对零件进行不同的强化处理（淬火、渗氮、渗碳等热处理工艺；抛光、喷丸、滚压等冷作工艺）对疲劳强度的影响。
  + *表面腐蚀系数 $beta_3$*：受到腐蚀的零件表面会产生腐蚀垢，形成应力集中源，故腐蚀也会降低零件的疲劳强度。
]

*表面系数 $beta$ 的取值*：

#figure(
  md-table(
    (auto, auto),
    ([工作状态], [$beta$ 取值]),
    [零件只经过切削], [$beta = beta_1$],
    [零件切削后又强化处理], [$beta = beta_2$],
    [零件在腐蚀介质中工作], [$beta = beta_3$],
  ),
  caption: [表面系数 $beta$ 的取值],
)

==== 综合影响系数 $K_sigma (K_tau)$ 和零件的极限应力图

应力集中、零件尺寸和表面状态 $k_sigma, epsilon_sigma, beta$ 只对应力幅 $sigma_a$ 有影响，而对平均应力 $sigma_m$ 无影响（由试验得）。

#theorem-showy(title: "综合影响系数")[
  $ K_sigma = k_sigma/(epsilon_sigma beta_sigma), quad quad K_tau = k_tau/(epsilon_tau beta_tau) $

  综合影响系数表示了*材料极限应力幅与零件极限应力幅的比值*：

  $ K_sigma = sigma_a' ("标准试件的极限应力幅") / (sigma_(a e)' ("零件的极限应力幅")) $

  对称循环：

  $ K_sigma = sigma_(-1) ("标准试件对称循环的疲劳极限") / (sigma_(-1 e) ("零件试件对称循环的疲劳极限")) $
]

#definition-showy(title: "零件的极限应力图")[
  由于 $K_sigma$ 只对 $sigma_a$ 有影响、对 $sigma_m$ 无影响，所以在材料极限应力图 $A' D' G' C$ 的纵坐标上计入 $K_sigma$ 的影响：

  - $A(0, sigma_(-1)/K_sigma)$ —— 零件对称循环疲劳点；
  - $D(sigma_0/2, sigma_0/(2 K_sigma))$ —— 零件脉动循环疲劳点。

  得到零件的许用疲劳极限曲线（$A - D - G$ 折线）与屈服极限曲线（$G - C$）。
]

#figure(
  image("Figure/零件的极限应力图.png", width: 70%),
  caption: [零件的极限应力图],
)<fig-零件的极限应力图>

#theorem-showy(title: "零件极限应力图的直线方程")[
  直线 $C G$ 方程：

  $ sigma_(a e)' + sigma_(m e)' = sigma_"s" $

  直线 $A G$ 方程：

  $ sigma_(-1 e) = sigma_(-1)/K_sigma = sigma_(a e)' + (1/K_sigma dot (2 sigma_(-1) - sigma_0)/sigma_0) sigma_(m e)' $

  即

  $ sigma_(-1) = K_sigma sigma_(a e)' + (2 sigma_(-1) - sigma_0)/sigma_0 sigma_(m e)' $

  其中，$psi_sigma = (2 sigma_(-1) - sigma_0)/sigma_0$ 为标准试件的材料特性；$psi_(sigma e) = psi_sigma/K_sigma$ 为零件的材料特性。
]

=== 单向稳定变应力时的疲劳强度计算

*计算步骤（流程）*：

+ 先画出材料的极限应力图；
+ 查出并计算零件的综合影响系数；
+ 画出零件的极限应力图；
+ 找到工作应力点；
+ 找到与之对应的极限应力点；
+ 求出最大极限应力；
+ 最后求安全系数。

==== $gamma = sigma_"min"/sigma_"max" = C$

大多数转轴中的主应力状态（承受扭矩和弯矩的轴），满足

$ sigma_a/sigma_m = (1 - gamma)/(1 + gamma) = "常数" $

过原点与工作应力点 $M$（或 $N$）作连线交 $A D G$（或 $G C$）于 $M_1'$（$N_1'$）点，直线上任一点的应力循环特性均相同，$M_1'$、$N_1'$ 即为*极限应力点*。

#theorem-showy(title: [$gamma = C$ 时的疲劳强度计算])[
  *a) 工作应力点位于 $O A G$ 内*：极限应力为疲劳极限，按疲劳强度计算。

  $ sigma_"lime" = sigma_"max"' = sigma_(a e)' + sigma_(m e)' = (sigma_(-1) (sigma_m + sigma_a))/(K_sigma sigma_a + psi_sigma sigma_m) = (sigma_(-1) sigma_"max")/(K_sigma sigma_a + psi_sigma sigma_m) $

  强度条件为：

  $ S_"ca" = sigma_"lime"/sigma_"max" = sigma_(-1)/(K_sigma sigma_a + psi_sigma sigma_m) >= [S] $

  *b) 工作应力点位于 $O G C$ 内*：极限应力为屈服极限，按静强度计算。

  $ S_"ca" = sigma_"s"/sigma_"max" = sigma_"s"/(sigma_m + sigma_a) >= [S] $
]

==== $sigma_m = C$

振动中的受载弹簧的应力状态。过工作应力点 $M$（$N$）作与纵轴平行的直线交 $A G C$ 于 $M_2'$（$N_2'$）点，即为极限应力点。

#theorem-showy(title: [$sigma_m = C$ 时的疲劳强度计算])[
  *a) 工作应力点位于 $O A G H$ 区域*：极限应力为疲劳极限。

  $ sigma_"lime" = sigma_"max"' = sigma_(m e)' + sigma_(a e)' = sigma_m + (sigma_(-1) - psi_sigma sigma_m)/K_sigma $

  强度条件为：

  $ S_"ca" = (sigma_(-1) + (K_sigma - psi_sigma) sigma_m)/(K_sigma (sigma_m + sigma_a)) >= [S] $

  *b) 工作应力点位于 $G H C$ 区域*：极限应力为屈服极限。

  $ S_"ca" = sigma_"s"/sigma_"max" = sigma_"s"/(sigma_m + sigma_a) >= [S] $
]

==== $sigma_"min" = C$

受轴向变载荷的紧螺栓联接中的螺栓应力状态，满足

$ sigma_"min" = sigma_m - sigma_a = C $

过工作应力点 $M$（$N$）作与横坐标成 $45 degree$ 的直线，直线与极限应力线图的交点 $M_3'$（$N_3'$）即为所求极限应力点。

#theorem-showy(title: [$sigma_"min" = C$ 时的疲劳强度计算])[
  *a) 工作应力点位于 $O J G I$ 区域*：极限应力为疲劳极限。

  $ sigma_"lime" = sigma_"max"' = sigma_(a e)' + sigma_(m e)' = (2 sigma_(-1) + (K_sigma - psi_sigma) sigma_"min")/(K_sigma + psi_sigma) $

  强度条件为：

  $ S_"ca" &= sigma_"lime"/sigma_"max" = (2 sigma_(-1) + (K_sigma - psi_sigma) sigma_"min")/((K_sigma + psi_sigma)(sigma_m + sigma_a)) \
      &= (2 sigma_(-1) + (K_sigma - psi_sigma) sigma_"min")/((K_sigma + psi_sigma)(2 sigma_a + sigma_"min")) >= [S] $

  *b) 工作应力点位于 $I G C$ 区域*：极限应力为屈服极限，按静强度计算。

  $ S_"ca" = sigma_"s"/sigma_"max" = sigma_"s"/(sigma_m + sigma_a) = sigma_"s"/(sigma_"min" + 2 sigma_a) >= [S] $

  *c) 工作应力位于 $0 A J$ 区域内*：$sigma_"min"$ 为负值，工程中罕见，故不作考虑。
]

#note-box[
  + 若零件所受应力变化规律不能肯定，一般采用 $gamma = C$ 的情况计算；
  + 上述计算均按*无限寿命*设计。若按*有限寿命*要求设计（$10^3 (10^4) < N < N_0$），公式中的极限应力应为有限寿命的疲劳极限 $sigma_(gamma N) = root(m, N_0/N) sigma_gamma$，即以 $sigma_(-1 N)$ 代 $sigma_(-1)$、以 $sigma_(0 N)$ 代 $sigma_0$；
  + 当未知工作应力点所在区域时，应同时考虑可能出现的两种情况；
  + 对切应力上述公式同样适用，只需将 $sigma$ 改为 $tau$ 即可。
]

==== 例题 1（课件原题）

#example-showy(title: "单向稳定变应力疲劳强度校核")[
  某轴受弯曲稳定变应力作用，$sigma_"max" = 260 "MPa"$，$sigma_"min" = -60 "MPa"$。已知 $sigma_(-1) = 450 "MPa"$，$sigma_0 = 700 "MPa"$，$sigma_"s" = 800 "MPa"$，弯曲疲劳极限的综合影响系数 $K_sigma = 1.9$。

  （1）绘制材料的简化极限应力图，在图中标出工作应力点，并判别其可能破坏的形式；

  （2）按许用安全系数 $[S] = 1.4$，校核此轴的无限寿命疲劳强度；

  （3）若轴的转速 $n = 20 "r/min"$，每天工作 8 小时，共工作 360 天，循环基数 $N_0 = 5 times 10^6$，寿命指数 $m = 9$，按有限寿命校核其疲劳强度，$[S] = 1.4$。

  *（1）*求工作应力点坐标：

  $ sigma_a = (sigma_"max" - sigma_"min")/2 = (260 - (-60))/2 = 160 "MPa" $

  $ sigma_m = (sigma_"max" + sigma_"min")/2 = (260 + (-60))/2 = 100 "MPa" $

  - 工作应力点 $N(100, 160)$；
  - 极限应力图特征点：$A(0, 450)$（$sigma_(-1)$）、$D'(350, 350)$（$sigma_0/2, sigma_0/2$）、$C(800, 0)$（$sigma_"s"$）；
  - $gamma = sigma_"min"/sigma_"max" = (-60)/260 approx -0.23$，属 $gamma = C$ 情形；
  - 判别：$psi_sigma = (2 sigma_(-1) - sigma_0)/sigma_0 = 200/700 approx 0.286$，直线 $A G$ 上 $sigma_m = 100$ 处 $sigma_a' = sigma_(-1)/K_sigma - psi_sigma/K_sigma sigma_m = 450/1.9 - 0.286/1.9 times 100 approx 221.8 > 160$，工作应力点位于*$O A G$ 区域内*，可能发生*疲劳破坏*。

  *（2）*按 $gamma = C$ 计算，无限寿命：

  $ psi_sigma = (2 sigma_(-1) - sigma_0)/sigma_0 = (2 times 450 - 700)/700 approx 0.286 $

  $ S_"ca" &= sigma_(-1)/(K_sigma sigma_a + psi_sigma sigma_m) = 450/(1.9 times 160 + 0.286 times 100) \
      &= 450/332.6 approx 1.35 < 1.4 $

  故按无限寿命校核*不安全*。

  *（3）*应力循环次数：

  $ N = 60 n t = 60 times 20 times 8 times 360 = 3.456 times 10^6 $

  寿命系数：

  $ K_N = root(9, N_0/N) = root(9, (5 times 10^6)/(3.456 times 10^6)) approx 1.04 $

  $ sigma_(-1 N) = K_N sigma_(-1) $

  $ S_"ca" = (sigma_(-1 N))/(K_sigma sigma_a + psi_sigma sigma_m) = (K_N sigma_(-1))/(K_sigma sigma_a + psi_sigma sigma_m) approx 1.04 times 1.35 approx 1.4 >= 1.4 $

  故按有限寿命校核*安全*。
]

=== 双向稳定变应力时的疲劳强度计算

弯扭联合作用、拉扭联合作用。当零件上同时作用有*同相位*的对称循环变应力 $sigma_a$ 和 $tau_a$ 时，钢材满足以下极限应力关系式：

#theorem-showy(title: "双向稳定变应力的强度条件")[
  $ (tau_a'/tau_(-1 e))^2 + (sigma_a'/sigma_(-1 e))^2 = 1 $

  其中，$tau_(-1 e)$、$sigma_(-1 e)$ 为零件受对称循环的疲劳极限；$tau_a'$、$sigma_a'$ 为同时承受双向应力时的应力幅的极限值。

  *推导*：由 $S_"ca" = (O M')/(O M) = (O C')/(O C) = (O D')/(O D)$，有

  $ tau_a' = S_"ca" tau_a, quad quad sigma_a' = S_"ca" sigma_a $

  令 $S_tau = tau_(-1 e)/tau_a$，$S_sigma = sigma_(-1 e)/sigma_a$，代入椭圆方程得：

  $ (S_"ca"/S_tau)^2 + (S_"ca"/S_sigma)^2 = 1 $

  最终强度条件：

  $ S_"ca" = (S_sigma S_tau)/sqrt(S_sigma^2 + S_tau^2) >= [S] $
]

== 机械零件的接触强度

#definition-showy(title: "接触应力与接触强度")[
  高副零件工作时，理论上是点接触或线接触 $arrow.r$ 实际上由于接触部分的局部弹性变形而形成面接触 $arrow.r$ 由于接触面积很小，使表层产生的局部应力却很大，该应力称为*接触应力*。在表面接触应力作用下的零件强度称为*接触强度*。计算依据是弹性力学的*赫兹公式*。
]

=== 接触应力

==== 两圆柱体接触

#theorem-showy(title: "两圆柱体接触应力（赫兹公式）")[
  $ sigma_H = sqrt((F (1/rho_Sigma))/(pi b [(1 - mu_1^2)/E_1 + (1 - mu_2^2)/E_2])) $

  当 $mu_1 = mu_2 = 0.3, E_1 = E_2 = E$ 时：

  $ sigma_(H "max") = 0.418 sqrt((F E)/(b rho_Sigma)) $
]

#figure(
  image("Figure/两圆柱接触应力.png", width: 70%),
  caption: [两圆柱体接触应力],
)<fig-两圆柱接触应力>

==== 两球接触

#theorem-showy(title: "两球接触应力（赫兹公式）")[
  $ sigma_(H "max") = 1/pi root(3, 6 F [(1/rho_Sigma)/((1 - mu_1^2)/E_1 + (1 - mu_2^2)/E_2)]^2) $

  当 $mu_1 = mu_2 = 0.3, E_1 = E_2 = E$ 时：

  $ sigma_(H "max") = 0.388 root(3, (F E^2)/rho_Sigma^2) $
]

#definition-showy(title: "综合曲率半径")[
  $rho_Sigma$ 为*综合曲率半径*：

  $ 1/rho_Sigma = 1/rho_1 plus.minus 1/rho_2 quad cases(
    + arrow.r "外接触",
    - arrow.r "内接触",
  ) $
]

#figure(
  image("Figure/两球体接触应力.png", width: 70%),
  caption: [两球体接触应力],
)<fig-两球体接触应力>

#note-box[
  + 圆柱体 $sigma_(H "max") prop F^(1/2)$，球 $sigma_(H "max") prop F^(1/3)$，$therefore sigma_(H "max")$ 与 $F$ *不呈线性关系*。
  + 圆柱体 $sigma_(H "max") prop 1/rho_Sigma^(1/2)$，球 $sigma_(H "max") prop 1/rho_Sigma^(2/3)$，$therefore rho_Sigma$ 越大，$sigma_(H "max")$ 越小。
  + 同样的 $rho_1$、$rho_2$ 下，*内接触时 $rho_Sigma$ 较大、$sigma_(H "max")$ 较小*，约为外接触时的 48%。∴ 重载情况下采用内接触，有利于提高承载能力或降低接触副的尺寸。
]

=== 失效形式

#definition-showy(title: "接触强度失效形式")[
  - *静应力*：表面压碎（脆性材料）；表面塑性变形（塑性材料）。
  - *变应力*：*疲劳点蚀*——齿轮、滚动轴承的常见失效形式。
]

=== 提高接触疲劳强度的措施

接触强度条件为 $sigma_(H "max") <= [sigma]_H$：

+ 控制最大接触应力；
+ 提高接触表面硬度，改善表面加工质量；
+ 增大综合曲率半径 $rho_Sigma$；
+ 改外接触为内接触，点接触 $arrow.r$ 线接触；
+ 采用高粘度润滑油。

#heading(level: 2, numbering: none, outlined: true)[本章重点]

+ *应力的分类*：对称循环、脉动循环；
+ *材料极限应力图*和*零件极限应力图*；
+ 影响机械零件疲劳强度的主要因素（应力集中、零件尺寸、表面状态）；
+ *单向稳定变应力时的疲劳强度计算*：$gamma = C$，$sigma_m = C$，$sigma_"min" = C$ 三种情况；
+ 影响机械零件接触应力的主要因素。

// ============================================================================
//  第三章 摩擦、磨损及润滑（课件第 03 章）
// ============================================================================

= 摩擦、磨损及润滑

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

== 摩擦

=== 基本概念

#definition-showy(title: "摩擦")[
  两接触物体在接触表面间相对滑动或有滑动趋势时，产生阻碍其相对滑动的切向阻力，这种现象称为*摩擦*。
]

#definition-showy(title: "磨损")[
  由于摩擦引起的摩擦能耗和表面材料的不断损耗或转移，形成*磨损*。其后果是精度、可靠性下降，效率下降，直至零件破坏。
]

#definition-showy(title: "润滑")[
  减少摩擦、降低磨损的有效手段。研究摩擦、磨损与润滑三者关系的学科称为*摩擦学*（_Tribology_）。
]

=== 摩擦的分类

- *内摩擦*：同一物体内部材料间的摩擦；
- *外摩擦*：两物体接触表面间的摩擦，分为静摩擦与动摩擦，动摩擦又有滑动摩擦与滚动摩擦。

本课程主要讨论*金属摩擦副的滑动摩擦*。

=== 摩擦的四种状态（按润滑状态分）

#definition-showy(title: "四种摩擦状态")[
  - *干摩擦*：表面间无任何润滑剂，微凸体直接接触，伴随弹性/塑性变形，*最不利*；
  - *边界摩擦*：表面间仅有极薄的边界膜，是工程中的*最低要求*；
  - *流体摩擦*：两表面被流体膜完全隔开，摩擦系数极小、*无磨损*，最理想；
  - *混合摩擦*：部分边界摩擦、部分流体摩擦，介于两者之间。
]

=== 干摩擦

#theorem-showy(title: "库仑公式")[
  $ F_f = f F_n $

  式中 $F_f$ 为摩擦力，$F_n$ 为法向载荷，$f$ 为摩擦系数。
]

#theorem-showy(title: "简单粘着理论")[
  $ F_f = A_r tau_B = F_n/sigma_(s y) tau_B, quad quad f = tau_B/sigma_(s y) $

  $A_r$ 为真实接触面积，$tau_B$ 为较软材料的剪切强度极限，$sigma_(s y)$ 为其抗压屈服极限（压溃强度）。摩擦力的实质是真实接触面积被剪切所需的力。
]

=== 边界摩擦与边界膜

边界膜厚约 $0.1 ~ 0.2 upright(mu) "m"$，摩擦系数主要取决于边界膜的性质。

#figure(
  md-table(
    (auto, 1.4fr),
    ([边界膜类型], [适用工况]),
    [物理吸附膜], [常温、轻载、低速],
    [化学吸附膜], [中等载荷、速度与温度],
    [化学反应膜], [重载、高速、高温；膜强度最高],
  ),
  caption: [边界膜的类型与适用工况],
)

边界膜只有物理吸附膜、化学吸附膜、化学反应膜三种（不存在"物理反应膜"）。

=== 混合摩擦与流体摩擦

以*膜厚比* $lambda$ 判别摩擦状态：

$ lambda = h_min/(R_(a 1) + R_(a 2)) $

$h_min$ 为最小油膜厚度，$R_(a 1)$、$R_(a 2)$ 为两表面轮廓算术平均偏差。$lambda$ 越大，油膜承载能力越强、$f$ 越小；$lambda > 5$ 时形成全流体摩擦（$f$ 极小、无磨损）。

== 磨损

=== 磨损过程（三阶段）

#figure(
  image("Figure/磨损三阶段.png", width: 66%),
  caption: [典型磨损过程：磨损量 $q$ 随时间的变化],
)

+ *磨合磨损阶段*：初期磨损较快，随实际接触面积增大而减缓（"跑合"过程）；
+ *稳定磨损阶段*：磨损缓慢而均匀，为正常工作期，其长短决定工作寿命；
+ *剧烈磨损阶段*：磨损急剧加快，精度下降、噪声振动增大，必须停机检修。

=== 磨损的基本类型

#figure(
  md-table(
    (auto, 1.7fr, 1fr),
    ([类型], [机理与特点], [典型场合]),
    [粘着磨损], [接触点冷焊 $arrow$ 材料转移，严重时发展为胶合], [高速、重载],
    [磨粒磨损], [硬颗粒或微凸体切削表面，材料越硬磨损越小], [含尘、含砂工况],
    [表面疲劳磨损], [循环接触应力下表面产生裂纹、剥落（点蚀）], [滚动轴承、齿轮],
    [腐蚀磨损], [化学/电化学腐蚀与机械作用共同作用], [腐蚀介质中工作],
  ),
  caption: [磨损的基本类型],
)

另有*侵蚀磨损*（含固体微粒的流体高速冲刷表面，如水泵、水轮机叶片、火箭尾喷管）与*微动磨损*（接触表面间小幅相对振动，如过盈配合面、螺纹接合面）。

== 润滑

=== 润滑剂

#definition-showy(title: "润滑油")[
  矿物油（机油）、合成油等。主要性能指标：*粘度*（最重要）、油性、凝点（低温流动性）、闪点与燃点（安全指标）、极压性能、氧化稳定性。
]

#definition-showy(title: "润滑脂")[
  润滑油加稠化剂（皂基）形成的膏状润滑剂，分钙基、钠基、锂基等。主要指标：*针入度*（稠度）、滴点（耐热性）、安定性。载荷大时应选针入度较小（较稠）的润滑脂。
]

#definition-showy(title: "固体润滑剂与添加剂")[
  固体润滑剂：石墨、二硫化钼（$"MoS"_2$）、氮化硼、聚四氟乙烯等，适用于高温、重载、真空等不宜用油/脂的场合。添加剂用于改善抗氧化、抗磨、极压、防锈等性能。
]

=== 牛顿粘性定律与粘度

#theorem-showy(title: "牛顿粘性定律")[
  $ tau = -eta (partial u)/(partial y) $

  $tau$ 为切应力，$(partial u)/(partial y)$ 为沿膜厚方向的速度梯度，$eta$ 为动力粘度；负号表示切应力方向与速度梯度方向相反。
]

#figure(
  md-table(
    (auto, auto, 1.3fr),
    ([名称], [定义], [单位]),
    [动力粘度 $eta$], [由粘性定律定义], [$"N" dot "s" / "m"^2 = "Pa" dot "s"$],
    [运动粘度 $nu$], [$nu = eta/rho$], [$"m"^2 / "s"$；常用 $"cm"^2 / "s"$（斯 St）],
    [条件粘度], [用特定粘度计测定（如恩氏粘度）], [相对值，$degree "E"$],
  ),
  caption: [粘度的常用单位],
)

我国工业润滑油的*牌号按 40 ℃ 时运动粘度*确定。

=== 影响粘度的因素

- *温度*：温度升高，粘度下降。粘度指数（VI）越大，粘温性能越好；
- *压力*：$p <= 10 "MPa"$ 时可忽略；$p > 10 "MPa"$ 时 $eta_p = eta_0 e^(alpha p)$，压力升高粘度增大（$alpha$ 为粘压系数）。

=== 流体润滑的三种形式

- *流体动力润滑*：依靠摩擦副相对运动，在收敛油楔中自行产生压力油膜。条件：①间隙由大到小（收敛）；②相对滑动速度足够大且连续供油充足；
- *弹性流体动力润滑*（EHL）：在动力润滑基础上同时考虑表面弹性变形与压力对粘度的影响，适用于齿轮、滚动轴承等高副接触；
- *流体静力润滑*：由外部油泵强制供油建立压力油膜，与相对运动无关。承载能力大、精度高、寿命长、抗振性好，但费用较高，用于重载精密轴承、导轨、蜗杆副、传动螺旋等。

== 本章重点

+ 滑动摩擦的四种状态（干、边界、流体、混合）及特点；
+ 润滑油、润滑脂的主要性能指标；
+ 粘度的三种单位与润滑油牌号的确定方法；
+ 典型磨损三阶段与常见磨损类型。

// ============================================================================
//  第三章 螺纹连接
// ============================================================================

= 螺纹连接

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

== 螺纹

=== 螺纹的形成

#definition-showy(title: "螺纹的形成")[
  将直角三角形 $K$ 绕在圆柱体上，斜边在圆柱表面形成的空间曲线即*螺旋线*；沿螺旋线加工的沟槽即*螺纹*。改变原始三角形 $K$ 的形状（牙底形状），可得到矩形、梯形、锯齿形、管螺纹等不同牙型。
]

=== 螺纹的分类

#definition-showy(title: "螺纹按牙型分类")[
  - *联接螺纹*：#text(fill: red)[三角形螺纹（$60 degree$）]、锥螺纹（$55 degree$）、管螺纹（$55 degree$）；
  - *传动螺纹*：矩形螺纹、梯形螺纹、锯齿形螺纹（工作侧牙型角 $3 degree$）。

  *粗牙与细牙*（同属三角形螺纹）：

  - *粗牙*：作一般紧固件使用；
  - *细牙*：同一公称直径下#text(fill: red)[螺距最小]，牙细而浅，#text(fill: red)[自锁性好]，强度较高，适于#text(fill: red)[薄壁零件、细小零件、受冲击振动及变载荷]的场合。
]

#definition-showy(title: "按位置、旋向与线数分类")[
  - 按位置：*内螺纹*、*外螺纹*；
  - 按旋向：*右旋*（常用）、*左旋*（如#text(fill: red)[自行车脚踏曲柄上的螺纹为左旋]）；
  - 按螺旋线头数（线数）：*单线*（$n = 1$，用于*联接*）；*双线、多线*（$n >= 2$，用于*传动*，升角大、效率高，一般 $n <= 4$）。
]

#theorem-showy(title: "导程与螺距的关系")[
  $ L = n P $

  其中，$L$ 为导程，$P$ 为螺距，$n$ 为线数。
]

#figure(
  image("Figure/螺纹参数示意图.png", width: 80%),
  caption: [螺纹参数示意图],
)

=== 螺纹的主要参数

#definition-showy(title: "螺纹的主要参数")[
  #figure(
    md-table(
      (auto, auto, 1fr),
      ([参数], [符号], [定义]),
      [外径（大径）], [$d$], [与外螺纹牙顶相重合的假想圆柱面直径，亦称*公称直径*],
      [内径（小径）], [$d_1$], [与外螺纹牙底相重合的假想圆柱面直径，#text(fill: red)[强度计算中为计算直径]],
      [中径], [$d_2$], [轴向剖面内牙厚与牙间宽相等处的假想圆柱面直径，$d_2 approx (d + d_1)/2$；确定螺纹几何参数和配合性质的直径],
      [螺距], [$P$], [螺纹相邻两牙型上对应点间的轴向距离],
      [导程], [$L$], [螺纹上任一点沿同一螺旋线旋转一周移动的轴向距离，$L = n P$],
      [线数], [$n$], [螺纹螺旋线数目],
      [螺旋升角], [$psi$], [中径圆柱面上螺旋线的切线与垂直于螺纹轴线的平面间的夹角],
      [牙型角], [$alpha$], [螺纹轴向平面内螺纹牙型两侧边的夹角],
    ),
    caption: [螺纹的主要参数],
  )

  螺旋升角：

  $ psi = arctan L/(pi d_2) = arctan (n P)/(pi d_2) $
]

#note-box[
  螺纹强度计算一律使用#text(fill: red)[小径 $d_1$]（危险截面直径），不是大径 $d$。
]

== 螺纹连接的类型及螺纹连接件

=== 螺纹连接的基本类型

#definition-showy(title: "螺纹连接的五种基本类型")[
  #figure(
    md-table(
      (2.6cm, 6.2cm, 3.6cm),
      ([类型], [结构特点], [适用场合]),
      [普通螺栓联接（受拉螺栓）], [被联接件开通孔（不带螺纹），孔与螺杆之间有间隙且工作中不许消失；结构简单、装拆方便], [被联接件不太厚，应用最广],
      [铰制孔用螺栓联接（受剪螺栓）], [装配后*无间隙*，螺杆与孔壁直接接触（基孔制配合）], [主要承受*横向载荷*，也可作定位用],
      [双头螺柱联接], [螺杆两端均有螺纹，一端旋入被联接件，另一端配螺母；拆装时只需拆螺母], [#text(fill: red)[常拆卸且被联接件之一较厚]],
      [螺钉联接], [不用螺母，直接旋入被联接件], [被联接件之一较厚、受力不大、#text(fill: red)[不需经常装拆]],
      [紧定螺钉联接], [末端顶紧被联接件], [固定两零件的相对位置，传递不大的力或力矩],
    ),
    caption: [螺纹连接的基本类型、结构特点与适用场合],
  )

  *特殊用途螺钉*：吊环螺钉、地脚螺栓（固定机器于地基）。
]

=== 螺纹联接件

#definition-showy(title: "螺栓、螺母与垫圈")[
  - *螺栓*：六角头螺栓（标准）、双头螺柱、螺钉；
  - *螺母*：六角螺母（标准/扁/厚）、圆螺母（与止退垫圈配合使用）；
  - *垫圈*：作用——#text(fill: red)[保护被联接件表面、增大接触面积、遮掩不平表面]。普通垫圈（平垫圈、斜垫圈）；弹簧垫圈——防止螺母松脱；止动垫圈——配合圆螺母用。
]

== 螺纹连接的预紧和防松

=== 预紧

#definition-showy(title: "松联接与紧联接")[
  - *松联接*：装配时不拧紧，只有受外载荷时才受力；
  - *紧联接*：装配时需拧紧，即承载时已预先受力（*预紧力* $Q_P$）。
]

#definition-showy(title: "预紧的目的")[
  预紧目的：#text(fill: red)[增大联接的刚度、紧密性，提高防松能力]。

  预紧力 $Q_P$：预先施加的轴向作用力（拉力）。预紧过紧，螺杆静载荷增大，降低螺杆强度；预紧过松，工作不可靠。
]

#theorem-showy(title: "扳手拧紧力矩")[
  $ T = F_H dot L = T_1 + T_2 $

  其中，

  - $T_1$ 为螺纹摩擦阻力矩 $T_1 = Q_P tan(psi + phi.alt_v) d_2/2$
  - $T_2$ 为螺母端环形面与被联接件间的摩擦力矩 $T_2 = f_c Q_P dot 1/3 dot (D_1^3 - d_0^3)/(D_1^2 - d_0^2)$

  拧紧力矩系数

  $ K = 1/2 [(d_2/d) tan(psi + phi.alt_v) + (2 f_c)/(3d) dot (D_1^3 - d_0^3)/(D_1^2 - d_0^2)] $

  $ therefore quad T = K Q_P d, quad quad K = 0.1 tilde 0.3 $
]

#definition-showy(title: "预紧力 $Q_P$ 的控制方法")[
  + *测力矩扳手*——测出预紧力矩；
  + *定力矩扳手*——达到固定的拧紧力矩时卡盘不转动；
  + *测量预紧前后螺栓伸长量*——精度较高。
]

#figure(
  image("Figure/预紧力控制.png", width: 80%),
  caption: [预紧力控制方法],
)

=== 防松

#definition-showy(title: "防松的目的与原理")[
  在振动、冲击、变载或温度变化时，螺纹副中正压力可能减小或瞬间消失，摩擦力为零，使螺纹联接松动；反复作用会使联接松驰而失效，必须防松。

  防松原理：#text(fill: red)[消除（或限制）螺纹副之间的相对运动，或增大相对运动的难度]。
]

#definition-showy(title: "防松的方法")[
  + *摩擦防松*：双螺母（对顶螺母）、弹簧垫圈、自锁螺母（嵌尼龙圈、带颈收口、加金属防松装置）等；
  + *机械防松*：开槽螺母与开口销、止动垫片、串联钢丝（注意正确穿法）等；
  + *永久防松*：端铆、冲点、点焊、粘合。
]

== 单个螺栓连接的强度计算

=== 受力形式、失效形式与设计准则

#definition-showy(title: "螺栓受力与失效形式")[
  - *螺栓杆受力形式*：轴向拉力、扭转力矩或横向剪力。
  - *失效形式*：
    - 受拉螺栓：螺栓杆和螺纹可能发生#text(fill: red)[塑性变形或断裂]；
    - 受剪螺栓：螺栓杆、孔壁可能发生#text(fill: red)[剪断或压溃]。

  统计：90% 以上的螺栓属于#text(fill: red)[疲劳破坏]，失效原因主要是应力集中促使疲劳裂纹的发生和发展。疲劳破坏位置：（1）螺母支承面第一、第二牙圈处占 #text(fill: red)[65%]；（2）螺杆尾退刀槽处占 20%；（3）钉头支承面处占 15%。
]

#figure(
  image("Figure/螺栓失效实例.png", width: 80%),
  caption: [螺栓失效实例],
)

#definition-showy(title: "设计准则与计算方法")[
  - 受拉螺栓——保证螺栓的#text(fill: red)[疲劳拉伸强度或静强度]；
  - 受剪螺栓——保证螺栓的#text(fill: red)[挤压强度和剪切强度]。

  计算方法：由强度条件确定螺纹小径 $d_1$，按标准选相应的公称直径 $d$ 及螺距 $P$，其余尺寸按标准选取。
]

=== 松螺栓联接（如吊钩螺栓）

工作前不拧紧，无预紧力 $Q_P$，只有工作载荷 $F$ 起拉伸作用：

#theorem-showy(title: "松螺栓联接的强度条件")[
  $ sigma = F/((pi d_1^2)/4) <= [sigma] quad quad "——验算用" $

  $ d_1 >= sqrt((4F)/(pi [sigma])) quad quad "——设计用" $

  其中，$[sigma] = sigma_"s"/n$，$sigma_"s"$ 查表 4-4，安全系数 $n$ 查表 4-5。
]

#remark-box[
  其实就是轴向正应力计算。
]

=== 紧螺栓联接——仅受预紧力（横向载荷的普通螺栓）

工作前拧紧，在预紧力和拧紧力矩联合作用下处于复合应力状态：

预紧力 $Q_P$ 产生拉伸应力 $sigma = Q_P/(pi d_1^2/4)$；

螺纹摩擦力矩 $T_1$ 产生剪应力 $tau$。

#theorem-showy(title: "仅受预紧力的紧螺栓强度（简化计算法）")[
  强度条件：

  $ d_1 >= sqrt((1.3 times 4 Q_P)/(pi [sigma])) $ <eq-紧螺栓仅预紧>
]

#key-box(title: "系数 1.3 的含义")[
  系数 1.3 将外载荷提高 30%，以考虑#text(fill: red)[螺纹扭转剪应力]对螺栓强度的影响，把拉扭复合应力状态简化为纯拉伸处理，故又称*简化计算法*。
]

=== 受横向载荷的紧螺栓联接

受横向载荷的螺栓联接时，为了防止被联接件滑移，需要施加预紧力。

=== 普通螺栓联接

靠拧紧正压力 $Q_P$ 产生摩擦力平衡外载荷：

#theorem-showy(title: "横向载荷普通螺栓的防滑条件")[
  不产生相对滑移条件：

  $ i dot f dot Q_P >= K_"s" R quad arrow.r.double quad Q_P >= (K_"s" R)/(f dot i) $

  - $f$ 为接缝面摩擦系数；
  - $i$ 为接合界面数目；
  - $K_"s"$ 为防滑（可靠性）系数，$K_"s" = 1.1 tilde 1.3$。
]

为了增加可靠性，减小直径，简化结构，提高承载能力。可采用如下减载装置：

#figure(
  image("Figure/减载装置.png", width: 80%),
  caption: [减载装置],
)

=== 铰制孔用螺栓联接

螺杆直接承受*挤压*和*剪切*平衡外载荷 $R$：

#theorem-showy(title: "横向载荷铰制孔螺栓的强度条件")[
  $ tau = R/((pi d_0^2)/4) <= [tau] quad quad "剪切强度条件" $ <eq-铰制孔剪切>

  $ sigma_P = R/(d_0 L_"min") <= [sigma]_P quad quad "挤压强度条件" $ <eq-铰制孔挤压>

  其中：

  - $R$ 为横向载荷；
  - $d_0$ 为螺杆或孔直径；
  - $L_"min"$ 为被联接件中受挤压孔壁的最小长度；
  - $[tau]$ 为许用剪应力。
]

=== 受轴向载荷的紧螺栓联接（重点）

#definition-showy(title: "受力变形分析")[
  - *拧紧（预紧状态）*：螺栓受拉 $Q_P$，伸长 $lambda_b$；被联接件受压 $Q_P$，压缩 $lambda_m$；
  - *加载 $F$（工作状态）*：螺栓继续受拉，$Q_P arrow.r Q = Q_P' + F$，总伸长 $lambda_b' = lambda_b + Delta lambda$；被联接件放松，$Q_P arrow.r Q_P'$（*残余预紧力*），总压缩 $lambda_m' = lambda_m - Delta lambda$。

  力—变形关系（螺栓刚度 $C_b$、被联接件刚度 $C_m$）：

  $ C_b = tan theta_b = Q_P/lambda_b = (Delta F)/(Delta lambda), quad quad C_m = tan theta_m = Q_P/lambda_m = (F - Delta F)/(Delta lambda) $
]

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    image("Figure/螺母拧紧时的变形.png", width: 100%),
    image("Figure/承载工作载荷时的变形.png", width: 100%),
  ),
  caption: [紧螺栓联接的力—变形关系（左：螺母拧紧时的变形；右：承载工作载荷时的变形）],
)<fig-力变形关系>

#theorem-showy(title: "螺栓相对刚度与总载荷")[
  *螺栓相对刚度*：

  $ K_c = C_b/(C_b + C_m) $

  $ Delta F = C_b/(C_b + C_m) F = K_c F quad quad "——部分工作载荷" $

  *螺栓总载荷*：

  $ Q = F + Q_P' = Delta F + Q_P = Q_P + K_c F $ <eq-总载荷>

  $ Q_P = Q_P' + (1 - K_c) F $
]

#figure(
  image("Figure/单个紧螺栓联接受力变形图.png", width: 80%),
  caption: [单个紧螺栓联接受力变形图],
)

#definition-showy(title: [残余预紧力 $Q_P'$ 的取法])[
  #figure(
    md-table(
      (auto, auto),
      ([工况], [$Q_P'$]),
      [有密封性要求], [$(1.5 tilde 1.8) F$],
      [一般稳定载荷], [$(0.2 tilde 0.6) F$],
      [一般不稳定载荷], [$(0.6 tilde 1.0) F$],
      [地脚螺栓], [$Q_P' > F$],
    ),
    caption: [残余预紧力 $Q_P'$ 的取法],
  )<tab-残余预紧力>
]

#note-box(title: [$K_c$ 的讨论])[
  - 最不利情况 $C_b >> C_m$：$Q approx Q_P + F$（外载几乎全由螺栓承受）；
  - 最理想情况 $C_b << C_m$：$Q approx Q_P$（外载几乎全由被联接件承受）；
  - #text(fill: red)[不允许 $Q_P' < 0$]（出现缝隙，联接失效）。

  *降低螺栓受力的措施*：采用刚度较小的螺栓（#text(fill: red)[空心螺栓、加长螺栓、细颈]）+ 加硬垫片或拧紧凸缘（增大被联接件刚度）。
]

== 螺栓组连接的设计与受力分析

#theorem-showy(title: "螺栓组的结构设计要求")[
  + 布局要尽量对称分布，螺栓组中心与联接结合面形心重合（有利于分度、划线、钻孔），以受力均匀。
  + 受弯矩和扭矩作用的螺栓组，螺栓应尽量远离对称轴。
  + 合理间距，适当边距，以利用扳手装拆。
  + 避免偏心载荷（eccentricIoading）作用。
]

=== 受轴向载荷螺栓组联接

单个螺栓的工作载荷：

$ F = P/Z $

其中，

- P：轴向外载
- Z：螺栓个数

=== 受横向载荷螺栓组联接

特点：普通螺栓、铰制孔用螺栓皆可用；#text(fill: red)[防滑]关键在于——外载垂直于螺栓轴线。

普通螺栓——受拉伸作用。

铰制孔螺栓——受横向载荷剪切、挤压作用。

单个螺栓所承受的横向载荷相等：

$ R = R_Sigma/Z $

#remark-box[
  若外力不作用在螺栓组的形心上，则需将力移动到形心上再计算。
]

=== 受扭矩螺栓组联接——传力方式与受横向载荷的螺栓组相同

*适用场合*：#text(fill: red)[凸缘式联轴器]（flange coupling）、齿轮与轴的凸缘联接等——转矩 $T$ 作用在*联接接合面内*（$T$ 的作用平面与接合面平行），螺栓组绕形心 $O$ 受扭。

#heading(level: 3, numbering: none, outlined: false)[a）普通螺栓联接（common bolt joints）]

每个螺栓处由预紧力 $Q_P$ 产生的摩擦力 $f Q_P$，其方向沿该螺栓的*切向*（垂直于 $O$ 与该螺栓的连线 $r_i$），以各螺栓的摩擦力矩平衡外转矩 $T$，故*传力方式与受横向载荷的螺栓组完全相同*。

#theorem-showy(title: "受扭矩普通螺栓组的防滑条件与预紧力")[
  *不产生相对滑动的条件*：

  $ f Q_P r_1 + f Q_P r_2 + dots.c + f Q_P r_z >= K_"s" T $

  *各螺栓所需的预紧力*：

  $ Q_P >= (T dot K_"s")/(f (r_1 + r_2 + dots.c + r_z)) = (K_"s" T)/(f sum_(i=1)^z r_i) $ <eq-扭矩预紧力>

  其中：

  - $f$ 为接合面摩擦系数；
  - $K_"s"$ 为防滑（可靠性）系数，$K_"s" = 1.1 tilde 1.3$；
  - $z$ 为螺栓数目；
  - $T$ 为外转矩；
  - $r_i$ 为第 $i$ 个螺栓中心到螺栓组*形心* $O$ 的距离（$r_1$ 为受力最大螺栓的半径）。

  *设计步骤*：由 @eq-扭矩预紧力 求得 $Q_P$ 后，按仅受预紧力的紧螺栓强度条件（@eq-紧螺栓仅预紧）$d_1 >= sqrt((1.3 times 4 Q_P)/(pi [sigma]))$ 确定螺栓直径。
]

#figure(
  image("Figure/受扭矩螺栓组普通螺栓.png", width: 80%),
  caption: [受扭矩的普通螺栓组（靠预紧力产生的摩擦力传递转矩）],
)

#note-box[
  @eq-扭矩预紧力 中，$z$ 个螺栓的摩擦力矩是*算术叠加* $sum r_i$（不是平方和），这是普通螺栓组受扭与铰制孔螺栓组受扭在公式上最易混淆之处。
]

#heading(level: 3, numbering: none, outlined: false)[b）铰制孔螺栓联接组（bolt joints by interference with a reamed hole）]

螺栓杆与孔壁*无间隙*配合，转矩靠螺栓杆的*剪切*和*孔壁的挤压*直接传递。

#theorem-showy(title: "变形协调条件与最大工作剪力")[
  *变形协调条件*：由变形协调条件可知，各个螺栓的变形量和受力大小与其中心到接合面*形心*的距离成正比：

  $ R_1/r_1 = R_2/r_2 = dots.c = R_z/r_z $

  $ R_i/r_i = R_"max"/r_"max" quad arrow.r.double quad R_i = R_"max"/r_"max" r_i $

  *由被联接件力矩平衡*：

  $ R_1 r_1 + R_2 r_2 + dots.c + R_z r_z = T $

  两式联立，得受力最大螺栓（距形心最远者）所受的工作剪力：

  $ #box(stroke: .6pt, inset: (x: 6pt, y: 3pt), radius: 2pt, $ R_"max" = (T dot r_"max")/(sum_(i=1)^z r_i^2) $) $ <eq-扭矩最大剪力>

  其中，$R_"max"$ 为受力最大螺栓的工作剪力，$r_"max"$ 为该螺栓到形心 $O$ 的距离，$z$ 为螺栓数目。
]

#figure(
  image("Figure/受扭矩螺栓组铰制孔螺栓.png", width: 85%),
  caption: [受扭矩的铰制孔螺栓组（各螺栓受力与其到形心的距离成正比）],
)

求得 $R_"max"$ 后，按受横向载荷的铰制孔螺栓强度条件（@eq-铰制孔剪切、@eq-铰制孔挤压）作*剪切*和*挤压*强度校核。

#key-box(title: "受扭矩螺栓组小结")[
  - *普通螺栓*：预紧产生摩擦力矩，$Q_P >= (K_"s" T)/(f sum r_i)$，按紧螺栓拉伸强度（$times 1.3$）设计；
  - *铰制孔螺栓*：直接受剪，$R_"max" = (T r_"max")/(sum r_i^2)$，按剪切、挤压强度校核；
  - 两种螺栓组均要求*转矩 $T$ 作用在接合面内*；若外力不作用在螺栓组的形心上，则需将力移动到形心上再计算。
]

=== 受倾覆（纵向）力矩螺栓组联接

#definition-showy(title: "受倾覆力矩螺栓组的特点")[
  *特点*：倾覆力矩 $M$ 在*铅直平面内*，底座有绕 $0 - 0$（对称轴线）*倾转*的趋势。取*底板*为受力对象，由*静平衡条件*：

  $ F_1 L_1 + F_2 L_2 + dots.c + F_z L_z = M $

  *螺栓拉伸变形量越大，所受工作拉力就越大*，故各螺栓的工作拉力 $F_i$ 与其到螺栓组*对称轴线*的距离 $L_i$ 成正比：

  $ F_1/L_1 = F_i/L_i = "const" = F_"max"/L_"max" $

  $ therefore quad F_"max" = (M dot L_"max")/(sum_(i=1)^z L_i^2) $ <eq-倾覆最大拉力>

  其中：

  - $F_i$——第 $i$ 个螺栓受到底座的轴向力；
  - $L_i$——第 $i$ 个螺栓到螺栓组*对称轴线*的距离；
  - $F_"max"$——受力最大螺栓的工作拉力，$L_"max"$ 为其到对称轴线的距离。
]

#figure(
  image("Figure/受倾覆力矩螺栓组.png", width: 80%),
  caption: [受倾覆力矩的螺栓组联接],
)

#warn-box(title: "不要与受扭矩螺栓组混淆")[
  - 受*扭矩* $T$：螺栓受*横向剪力*，比例尺是各螺栓到*形心 $O$* 的距离 $r_i$；
  - 受*倾覆力矩* $M$：螺栓受*轴向拉力*，比例尺是各螺栓到*对称轴线 $0 - 0$* 的距离 $L_i$；
  - 两式形式同为"$("外载荷" times "最远距离")/(sum ("距离")^2)$"，但几何基准与受力性质完全不同。
]

#note-box[
  若外力不作用在螺栓组的形心上，则需将力移动到形心上再计算。
]

#remark-box[
  *联接的补充（进阶）*：由 @eq-倾覆最大拉力 求得最大工作拉力 $F_"max"$ 后，一般还需按受轴向载荷的紧螺栓联接计算螺栓总拉力 $Q = Q_P' + K_c F_"max"$（@eq-总载荷）并校核*接合面不出现缝隙*（$Q_P' > 0$）与*不压溃*两个条件，也是*地脚螺栓*（$Q_P' > F$，见 @tab-残余预紧力）的设计依据。
]

=== 螺栓组四种受力状态对比与小结

#figure(
  md-table(
    (1.7cm, 2.9cm, 2.2cm, 5.4cm),
    ([受力状态], [载荷作用方式], [螺栓受力性质], [计算要点]),
    [受轴向载荷], [外载荷 $P$ 沿螺栓轴线，合力过形心], [轴向拉伸], [各螺栓均分：$F = P/z$；按 $Q = Q_P' + K_c F$ 求总拉力],
    [受横向载荷], [外载荷 $R$ 垂直于螺栓轴线，过形心], [普通：摩擦；铰制孔：剪切+挤压], [普通：$Q_P >= (K_"s" R)/(f i)$；铰制孔：$tau = R/(z dot (pi d_0^2)/4)$、$sigma_P = R/(z d_0 L_"min")$],
    [受扭矩 $T$], [转矩作用在接合面内，绕形心 $O$], [普通：摩擦；铰制孔：剪切+挤压], [普通：$Q_P >= (K_"s" T)/(f sum r_i)$；铰制孔：$R_"max" = (T r_"max")/(sum r_i^2)$],
    [受倾覆力矩 $M$], [力矩在铅直平面内，绕对称轴线 $0 - 0$], [轴向拉伸（拉力最大者不一定是离形心最远者）], [$F_"max" = (M L_"max")/(sum L_i^2)$，再按紧螺栓联接计算总拉力并校核接合面],
  ),
  caption: [螺栓组联接的四种受力状态对比],
)

#key-box(title: "受力分析的通用步骤")[
  + 将外载荷*向螺栓组形心平移*（必要时附加一个转矩），转化为上述基本受力状态；
  + 判断每种基本状态下*哪个螺栓受力最大*；
  + 按*叠加原理*求出受力最大螺栓的总工作载荷（拉力或剪力）；
  + 按相应强度条件（受拉：仅预紧 $arrow.r$ @eq-紧螺栓仅预紧，受轴向载荷 $arrow.r$ @eq-总载荷；受剪：@eq-铰制孔剪切、@eq-铰制孔挤压）完成设计或校核。
]

// ============================================================================
//  第四章 轴毂连接
// ============================================================================

= 轴毂连接

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

== 键连接的类型及应用

根据键连接在装配时是否预紧，分为*松键连接*和*紧键连接*：

$ "松键连接" quad cases(
  "平键连接" quad cases("普通平键", "导向平键", "滑键"),
  "半圆键连接",
) $

$ "紧键连接" quad cases(
  "楔键连接",
  "切向键连接",
) $

#figure(
  image("Figure/几种键.png", width: 90%),
  caption: [几种键],
)

=== 平键

工作面：两侧面；工作时靠键与键槽侧面的挤压来传递扭矩。

==== 普通平键

用于静连接，即轴与轮毂之间无相对轴向移动。

#figure(
  image("Figure/普通平键.png", width: 85%),
  caption: [普通平键],
)

==== 薄型平键

键高约为普通平键的 $60% tilde 70%$；有圆头、方头和单圆头，常用于薄壁结构、空心轴等径向尺寸受限制的场合。

==== 导向键和滑键

#figure(
  image("Figure/导向键和滑键.png", width: 80%),
  caption: [导向键和滑键],
)

=== 半圆键连接

#figure(
  image("Figure/半圆键.png", width: 55%),
  caption: [半圆键连接],
)

键槽用与半圆键形状相同的铣刀加工，键能在槽中绕几何中心摆动，工作时靠工作侧面的挤压传递扭矩。

#note-box[
  半圆键要注意画法：

  + 半圆键的两侧面为键的工作面，只在接触面上画一条轮廓线；
  + 应画出键上表面与轮毂的间隙。

  #figure(
    image("Figure/半圆键连接画法.png", width: 50%),
    caption: [半圆键连接的画法],
  )
]

=== 楔键连接

键的上表面与轮毂键槽底均具有 $1:100$ 的斜度，工作时键的上下表面与轮毂、轴的键槽工作面压紧，靠摩擦力和挤压传递扭矩。

#figure(
  image("Figure/楔键连接.png", width: 90%),
  caption: [楔键连接（普通楔键和钩头楔键）],
)

楔紧后，轴和轮毂产生偏心，在冲击载荷下易松脱，仅适用于低速轻载、精度要求不高的场合。

=== 切向键

切向键由两个普通的楔键组成，靠上下表面与键槽底面的挤压力和轮毂接触的摩擦力传递扭矩。适用于精度要求不高，低速、重载，轴径大于 $100$ mm 的轴上。

#figure(
  image("Figure/切向键.png", width: 70%),
  caption: [切向键],
)

== 键的选择和键连接的强度计算

=== 键的类型选择

#figure(
  md-table(
    (1.5cm, 4.1cm, 4.5cm, 4.1cm),
    ([键的名称], [使用要求], [结构特点], [工作条件]),
    [普通平键], [用于静连接，轴与轮毂之间无相对轴向移动], [矩形截面，两侧面为工作面；有圆头、方头、单圆头三种型式], [靠键与键槽侧面的挤压传递扭矩],
    [薄型平键], [用于薄壁结构、空心轴等径向尺寸受限制的场合], [键高约为普通平键的 $60% tilde 70%$；有圆头、方头和单圆头], [同普通平键，靠两侧面的挤压传递扭矩],
    [导向平键], [用于轮毂需沿轴作轴向移动的动连接，移动距离一般不大], [键固定在轴上，轮毂可沿键滑动], [靠两侧面挤压传递扭矩，兼起导向作用],
    [滑键], [用于轮毂沿轴移动距离较大的动连接], [键固定在轮毂上，随轮毂一起沿轴上较长的键槽滑动], [靠两侧面挤压传递扭矩，随轮毂一起移动],
    [半圆键], [适用于锥形轴端及传递较小扭矩的场合（轴槽较深，对轴的强度削弱较大）], [呈半圆形，键能在轴槽中绕几何中心摆动；键槽用与键形状相同的铣刀加工], [靠工作侧面（两侧面）的挤压传递扭矩],
    [楔键], [仅适用于低速、轻载、精度要求不高的场合], [键的上表面与轮毂键槽底均具有 $1:100$ 的斜度，工作时上下表面压紧], [靠上下表面的挤压力和摩擦力传递扭矩；楔紧后轴与轮毂产生偏心，在冲击载荷下易松脱],
    [切向键], [适用于精度要求不高、低速、重载、轴径大于 $100$ mm 的轴], [由两个普通楔键组成], [靠上下表面与键槽底面的挤压力和轮毂接触的摩擦力传递扭矩],
  ),
  caption: [键的类型选择],
)

=== 键的尺寸选择

键的尺寸关注两个量：截面尺寸（$b times h$）和长度（$L$）。按轴的直径 $d$ 由标准选定截面尺寸，由轮毂长度确定键的长度。一般取键长*略短*于轮毂长度 $5 tilde 10$ mm。

=== 普通平键的强度计算

假定载荷在键的工作面上均匀分布，普通平键的连接强度条件为

$ sigma_p = (2T times 10^3)/(k l d) <= [sigma]_p $

其中：

- $k$：键与轮毂的接触高度，$k = 0.5h$，$h$ 为键的高度；
- $l$：键的工作长度，A 型键 $l = L - b$，B 型键 $l = L$，C 型键 $l = L - b/2$。

=== 导向键和滑键连接强度计算

导向键和滑键连接强度条件为

$ p = (2T times 10^3)/(k l d) <= [p] $

=== 半圆键的剪切强度条件

半圆键的剪切强度条件为

$ T = N dot d/2 times 10^3 approx b l tau dot d/2 times 10^3 $

$ tau = (2000T)/(b l d) <= [tau] $

其中：

- $tau$：键剪切应力；
- $b$：键宽；
- $l$：键的工作长度，取 $l = L$。

#note-box[
  强度不足时：

  + 当强度不足时，可适当增加键长或采用两个键按 $180 degree$ 布置；
  + 考虑两个键的载荷分布不均匀性，在强度校核时按 1.5 个键计算。
]

== 花键连接

=== 花键连接的类型、特点及应用

花键连接是由周向均匀分布的多个纵向键齿的*花键轴*和带有键槽的轮毂相配合构成的可拆连接。

#definition-showy(title: "花键连接的优缺点")[
  *优点*：

  + 键齿数多，总接触面积大，比平键承载能力高；
  + 键齿与轴一体且槽较浅，齿根应力集中较小，对轴的削弱小；
  + 键齿对称布置、均匀分布，受力均匀。

  *缺点*：结构相对复杂，加工时需要专门的刀具和设备，成本高。
]

按齿形不同，花键连接分为*矩形花键*和*渐开线花键*：

- 矩形花键——*内径定心*，定心精度高，定心稳定性好，可用磨削消除热处理后的变形；
- 渐开线花键——*齿形定心*，齿受载时齿上的径向力能自动定心，有利于各齿均载。

=== 花键连接的强度计算

设计步骤：按轴径确定花键尺寸，再校核连接强度。

失效形式：压溃（静连接）、磨损（动连接）、齿根剪断。

假定工作载荷沿键的工作长度均匀分布，各齿面上压力的合力 $N$ 作用在平均直径 $d_m$ 处，即传递的转矩为

$ T = (N d_m)/2 $

静连接的挤压强度条件为

$ sigma_p = (2T times 10^3)/(psi z h l d_m) <= [sigma_p] $

动连接的强度条件（耐磨性）为

$ p = (2T times 10^3)/(psi z h l d_m) <= [p] $

其中：

- $psi$：载荷分配不均系数，$psi = 0.7 tilde 0.8$；
- $z$：花键的键齿数；
- $h$：花键齿侧面的高度；
  - 矩形花键：$h = (D - d)/2 - 2C$（$D$ 为花键大径，$d$ 为花键小径，$C$ 为倒角尺寸）；
  - 渐开线花键：$alpha = 30 degree$ 时 $h = m$；$alpha = 45 degree$ 时 $h = 0.8 m$。
- $l$：键的工作长度；
- $d_m$：平均直径。

== 无键连接

轴与毂的连接不用键或花键时，统称无键连接。

#definition-showy(title: "型面连接（Profile connection）")[
  轴与毂孔可为柱形或锥形。

  特点：没有应力集中源，对中性好，承载能力强，装拆方便；但加工需用专用设备，应用较少。
]

#definition-showy(title: "胀紧连接")[
  利用锥面贴合并挤紧在轴毂之间，靠摩擦力传递扭矩。

  特点：可传递较大的扭矩和轴向力，应力集中较小，对中性好，承载能力高，有过载保护作用；但轴毂之间需安装胀套，应用受到尺寸限制。
]

== 销连接

#definition-showy(title: "销按用途分类")[
  - *定位销*：主要用于零件间的位置定位，常用作组合加工和装配时的主要辅助零件；
  - *连接销*：主要用于零件间的联接或锁定，可传递不大的载荷；
  - *安全销*：主要用于安全保护装置中的过载剪断元件。
]

#definition-showy(title: "销按结构形式分类")[
  - *圆柱销*：不宜多次装拆，否则定位精度下降；
  - *圆锥销*：$1:50$ 锥度，可自锁，定位精度较高，允许多次装拆，且便于拆卸；
  - *特殊型式销*：带螺纹锥销、开尾圆锥销、弹性销、开口销、槽销等。

  销的常用材料为 35、45 钢。
]

#heading(level: 2, numbering: none, outlined: true)[本章重点]

+ 松键和紧键的区别；
+ 键大小的选择；
+ 平键的挤压和剪切强度校核，强度不足时的措施；
+ 花键的优缺点；
+ 花键的类型。

// ============================================================================
//  第七章 滚动螺旋传动（课件第 07 章）
// ============================================================================

= 滚动螺旋传动

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

== 螺旋传动的分类

按用途，螺旋传动分为三类：

- *传力螺旋*：以传递动力为主，如举重器、千斤顶；
- *传导螺旋*：以传递运动为主，要求精度高，如机床进给丝杠；
- *调整螺旋*：用于调整并固定零件间的相对位置，如显微镜调整螺旋。

普通*滑动螺旋*构造简单、承载能力大、加工方便，但摩擦阻力大、磨损快、寿命短、传动效率低（约 $30% ~ 60%$）。在对效率、精度和寿命要求高的场合，采用*滚动螺旋传动*。

== 滚珠丝杠副

=== 工作原理

#definition-showy(title: "滚动螺旋传动")[
  在具有圆弧形螺旋槽的螺杆与螺母之间连续装填若干*滚动体*（滚珠），工作时滚动体沿螺纹滚道滚动并形成循环，把螺旋运动变为直线运动。
]

#figure(
  image("Figure/滚珠丝杠副工作原理.png", width: 90%),
  caption: [滚珠丝杠副：由螺杆、螺母、滚珠及循环装置组成（转动 $arrow.l.r$ 移动）],
)

=== 结构分析

*螺纹滚道型面*不同：

#figure(
  image("Figure/滚道型面-单圆弧与双圆弧.png", width: 72%),
  caption: [单圆弧与双圆弧滚道型面],
)

- *单圆弧型面*：接触角随初始间隙与轴向载荷大小而变化，传动效率、承载能力与轴向刚度不稳定；
- *双圆弧型面*：接触角基本保持不变，效率、承载能力与轴向刚度较稳定，磨削需专用成形砂轮。

*滚珠循环方式*不同，按滚珠在循环过程中是否与丝杠表面脱离，分为内循环与外循环：

#figure(
  image("Figure/滚珠循环方式-内循环与外循环.png", width: 84%),
  caption: [内循环式与外循环式],
)

- *内循环*：借助反向器上回珠槽的作用，迫使滚珠翻越丝杠螺纹牙顶后重新回到初始滚道，构成一个循环的滚珠链；
- *外循环*：成形弯管（回珠管）插入螺纹滚道两端与滚道相切的通孔内，由弯管引导滚珠进出，构成循环通道。

=== 特点与应用

#feature-showy(title: "滚珠丝杠副的特点")[
  + 传动效率高，可达 $85% ~ 98%$；
  + 摩擦阻力小、启动力矩小，传动灵活平稳；
  + 定位精度高，可实现微量进给与可逆传动；
  + 结构较复杂、成本较高；效率高而不能自锁，垂直安装时需加制动装置。
]

广泛应用于数控机床进给系统、精密测量仪器、工业机器人、航空航天装备等，是高档数控机床的核心功能部件之一。

== 本章小结

+ 螺旋传动按用途分为传力、传导、调整三类；滑动螺旋效率低、磨损大；
+ 滚珠丝杠副由螺杆、螺母、滚珠和循环装置组成，滚珠在滚道内滚动并循环；
+ 滚道型面分单圆弧、双圆弧；循环方式分内循环、外循环；
+ 滚珠丝杠副效率高、精度高、可逆传动，但结构复杂、不能自锁。

// ============================================================================
//  第五章 带传动
// ============================================================================

= 带传动

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

== 概述

=== 带传动的工作原理及特点

*组成*：主动带轮、从动带轮、传动带。

*工作原理*：依靠带与带轮接触面间的摩擦力拖动从动轮一起回转。

#figure(
  image("Figure/传送带组成.png", width: 70%),
  caption: [带传动的组成],
)

*优点*：

+ 有良好的*挠性*和*弹性*，有吸振和缓冲作用，可使带传动平稳、噪声小；
+ 有*过载保护作用*：过载时带在带轮上发生相对滑动，可防止其他零件的损坏；
+ 结构简单，制造、安装、维护方便；
+ 适用于两轴*中心距较大*的传动（最大距离可达 $15$ m）。

*缺点*：

+ 由于弹性滑动，使传动效率降低，不能保证准确的传动比；
+ 由于带传动需要初始张紧，当传递同样大的圆周力时，与啮合传动相比轴上的压力较大；
+ 结构尺寸较大，不紧凑；
+ 传动带寿命较短；
+ 传动带与带轮之间会产生摩擦放电现象，不宜用于有爆炸危险的场合。

#note-box[
  上述优缺点均可由后面的受力分析、应力分析与弹性滑动分析一一回溯。
]

=== 带传动的类型与应用

#figure(
  md-table(
    (2.6cm, 5.0cm, 6.0cm),
    ([类型], [结构 / 工作原理], [特点与应用]),
    [平带传动], [带为扁平矩形截面，靠带与带轮面间的摩擦工作], [最简单，适合于中心距较大的情况],
    [V 带传动（三角带）], [靠两侧边与轮槽接触，靠两侧面产生的摩擦力工作], [摩擦力比平带大，能传递较大的功率],
    [多楔带传动], [由若干条 V 形楔组成], [适用于传递功率较大、要求结构紧凑的场合],
    [同步带传动], [啮合型：靠带上的齿与轮缘上的齿相互啮合传动], [传动比恒定，柔韧性好，张紧力小，带比较轻薄，在高速设备、数控机床、机器人行业、汽车行业、轻纺行业中广泛应用],
  ),
  caption: [带传动的类型与应用],
)

V 带靠两侧边与轮槽接触，靠两侧面所产生的摩擦力来工作。当带被张紧时，带以力 $Q$ 压向轮槽，两侧面的法向力为

$ 2 N sin (phi/2) = Q quad arrow.r.double quad N = Q/(2 sin(phi/2)), $

摩擦力为

$ F_f = 2 f N = (f Q)/(sin(phi/2)) = f_v Q, quad quad f_v = f/(sin(phi/2)), $

其中：

- $f_v$ 为当量摩擦因数；
- $phi$ 为 V 带带轮轮槽楔角。

所以 V 带传动的摩擦力比平带大，能传递较大的功率。

#figure(
  image("Figure/V带的摩擦受力分析.png", width: 60%),
  caption: [V 带的摩擦受力分析],
)

=== V 带及其标准

V 带的主要参数：

- 中性层（节面）；
- 带轮基准直径 $D$；
- 基准长度 $L_d$（公称长度）；
- 标注示例：A2240——A 型带，公称长度 $L_d = 2240$ mm。

普通 V 带是标准件，截面形状为楔角 $40 degree$ 的梯形。按截面尺寸由小到大分为 Y、Z、A、B、C、D、E 七种：截面尺寸越大，承载能力越大，适用的传动转速越低。

V 带轮的最小基准直径见 @tab-带传动-最小基准直径（教材表 8-4）。

#figure(
  table(
    columns: 11,
    stroke: none,
    inset: (x: 3pt, y: 5pt),
    align: center,
    table.hline(stroke: 0.08em),
    table.header([带型], [Z], [SPZ], [A], [SPA], [B], [SPB], [C], [SPC], [D], [E]),
    table.hline(stroke: 0.05em),
    [$d_(d "min")$/mm], [50], [63], [75], [90], [125], [140], [200], [224], [355], [500],
    table.hline(stroke: 0.08em),
  ),
  caption: [V 带轮的最小基准直径],
)<tab-带传动-最小基准直径>

== 带传动的工作情况分析

带传动的一些基本参数如 @fig-带传动-参数示例 所示。

#figure(
  image("Figure/带传动各参数示例.png", width: 75%),
  caption: [带传动各参数示例],
)<fig-带传动-参数示例>

=== 带传动的受力分析

工作前，两边初拉力均为 $F_0$；工作时，两边拉力变化：紧边 $F_0 arrow.r F_1$，松边 $F_0 arrow.r F_2$。

由工作时带的总长度不变（紧边伸长的量等于松边缩短的量），有

$ F_1 - F_0 = F_0 - F_2 quad "或" quad F_1 + F_2 = 2 F_0. $

取主动轮上的一段带为分离体，总摩擦力 $F_e$ 和两边拉力对轴心的力矩代数和 $sum T = 0$，得

$ F_e = F_1 - F_2, $

$F_e$ 称为带的有效拉力，即带与带轮接触面上各点摩擦力的总和。

带传动所能传递的功率为

$ P_"kW" = (F_e v)/1000, $

式中 $F_e$ 的单位为 N，$v$ 的单位为 m/s，$P_"kW"$ 的单位为 kW。

=== 带传动的最大有效拉力及其影响因素

承受载荷越大，摩擦力越大；当带沿带轮有打滑趋势时，摩擦力达到最大值，带的有效拉力也达到最大值。此时 $F_1$ 与 $F_2$ 的关系为

$ F_1/F_2 = "e"^(f alpha), $

其中 $f$ 为摩擦因数，$alpha$ 为包角（单位 rad）。

包角（小带轮包角 $alpha_1$）为

$ alpha_1 = 180 degree - (D_2 - D_1)/a times 60 degree, quad quad alpha_2 = 180 degree + (D_2 - D_1)/a times 60 degree. $

将 $F_1 + F_2 = 2 F_0$ 代入上式，可得带所能传递的最大有效拉力（即有效拉力的临界值）

$ F_"ec" = 2 F_0 ("e"^(f alpha) - 1)/("e"^(f alpha) + 1) = 2 F_0 (1 - 1/"e"^(f alpha))/(1 + 1/"e"^(f alpha)). $

#warn-box(title: "打滑条件")[
  由功率算得的有效拉力超过临界值时发生打滑，即 $F_e > F_"ec"$。
]

=== 带的应力分析

带在工作时产生三种应力：

+ *拉应力*：紧边 $sigma_1 = F_1/A$；松边 $sigma_2 = F_2/A$。
+ *弯曲应力*：带绕在带轮上时要引起弯曲应力

  $ sigma_b approx (E h)/D, $

  其中 $h$ 为带的横截面厚度，$D$ 为带轮的计算直径，$E$ 为带的弹性模量。
+ *离心应力*：

  $ sigma_c = (q v^2)/A, $

  其中 $q$ 为带单位长度的质量，$v$ 为带的线速度。

三种应力中：紧边拉应力大于松边拉应力；带轮直径越小弯曲应力越大；离心应力近似全局相同。于是瞬时最大应力在*紧边开始绕上小带轮处*，此时的最大应力可近似表示为

$ sigma_"max" = sigma_1 + sigma_(b 1) + sigma_c. $

带是在变应力下工作，所以带的疲劳寿命取决于 $sigma_"max"$ 与应力循环次数 $N$；当 $N$ 达到一定数值后，带产生疲劳损坏。疲劳强度条件为

$ sigma_"max" = sigma_1 + sigma_(b 1) + sigma_c <= [sigma] quad arrow.r.double quad sigma_1 <= [sigma] - sigma_(b 1) - sigma_c. $

讨论：

+ $sigma_c = q v^2/A$，$q$ 为单位长度质量，$v$ 增大则 $sigma_c$ 增大。对于高速带，$sigma_c$ 对带的寿命起主要作用。
+ V 带传动中，$sigma_(b 1)$ 对寿命起主要作用，所以要限制小带轮的最小基准直径 $D_"min"$（教材表 8-4）。

=== 带的弹性滑动和打滑

#definition-showy(title: "弹性滑动")[
  由于带的弹性变形引起的带与带轮之间的（微量）相对滑动，称为*弹性滑动*。
]

弹性滑动是带传动工作的固有特性，是*不可避免*的。弹性滑动与紧、松边拉力值有关：带传递的圆周力 $F_e$ 越大，弹性滑动越大。

#definition-showy(title: "打滑")[
  由过载引起的带与带轮发生的相对滑动称为*打滑*。
]

打滑使带磨损加剧，从动轮转速急剧下降，甚至传动失效。

#figure(
  md-table(
    (2.2cm, 5.6cm, 5.6cm),
    ([对比项], [弹性滑动], [打滑]),
    [产生原因], [带的弹性变形引起], [过载引起（外载荷超过最大有效圆周力）],
    [性质], [固有特性，不可避免], [可以避免的失效形式],
    [滑动范围], [局部、微量], [沿带轮面全面滑动],
    [后果], [传动比不准确、传动效率降低], [带磨损加剧，从动轮转速急剧下降，甚至传动失效],
  ),
  caption: [弹性滑动与打滑的对比],
)

*滑动率与传动比*。滑动率为

$ epsilon = (v_1 - v_2)/v_1 times 100%, $

或 $v_2 = (1 - epsilon) v_1$，其中带速

$ v = (pi D n)/(60 times 1000). $

代入滑动率公式，可得 $D_2 n_2 = (1 - epsilon) D_1 n_1$，因而带传动的实际平均传动比为

$ i = n_1/n_2 = D_2/(D_1 (1 - epsilon)). $

在一般传动中，因滑动率不大（$epsilon = 1% tilde 2%$），故可不予考虑，而取传动比为

$ i = n_1/n_2 approx D_2/D_1. $

== V 带传动的设计计算

=== 设计准则和单根 V 带的基本额定功率

失效形式：1）打滑；2）带的疲劳破坏；另外还有磨损、静载拉断等。

设计准则：保证带在不打滑的前提下，具有足够的疲劳强度和寿命。

单根 V 带的基本额定功率 $P_0$ 是根据特定的实验和分析确定的，是 V 带传动设计的主要依据：

- 由临界条件（带处于打滑趋势）确定带的最大有效拉力 $F_e$，单根 V 带所传递的临界功率 $P_0 = F_e v/1000$；
- 由疲劳强度条件 $sigma_1 <= [sigma] - sigma_(b 1) - sigma_c$ 限定单根带所能传递的功率。

实验条件：包角 $alpha = 180 degree$、特定长度、平稳的工作载荷。单根 V 带的基本额定功率 $P_0$ 见教材表 8-6(a)。

=== V 带传动的设计步骤和方法

已知条件：$P$、$n_1$、$n_2$ 或 $i$，传动布置要求（中心距 $a$），工作条件。

设计要求：带——型号、根数、长度；轮——$D_"min"$、结构、尺寸；中心距 $a$、轴压力 $Q$ 等。

设计步骤：

+ *确定计算功率 $P_"ca"$*：

  $ P_"ca" = K_A P, $

  其中 $P$ 为额定功率（kW），$K_A$ 为工况系数（教材表 8-7）。

+ *选择带型号*：根据计算功率 $P_"ca"$、小带轮转速 $n_1$ 按选型图选取普通 V 带型号（教材图 8-7）。

+ *确定带轮直径（验算带速 $v$）*：

  - 根据带的型号选择小带轮基准直径 $D_1$，一般应 $D_1 >= D_(d "min")$（教材表 8-4）；
  - 大带轮直径：考虑滑动率时 $D_2 = (D_1 n_1 (1 - epsilon))/n_2$，不考虑滑动率时 $D_2 = (D_1 n_1)/n_2$；
  - 验算带速：

    $ v = (pi D_1 n_1)/(60 times 1000), $

    要求最佳带速 $v = 20 tilde 25$ m/s；
  - 讨论：
    - $v$ 太小：由 $P = F v$ 可知，传递同样功率时圆周力 $F$ 太大，带寿命下降；
    - $v$ 太大：离心力大，带与带轮正压力减小，摩擦力减小，传递载荷能力下降；
    - 如 $v$ 不合适，应重选 $D_1$。

+ *求中心距 $a$ 和带的基准长度 $L_d$*：

  - 初选 $a_0$：$0.7 (D_1 + D_2) < a_0 < 2 (D_1 + D_2)$；
  - 由 $a_0$ 定计算基准带长度：

    $ L_(d 0) approx 2 a_0 + pi/2 (D_1 + D_2) + (D_2 - D_1)^2/(4 a_0); $
  - 根据 $L_(d 0)$ 按教材表 8-3 选定相近的基准长度 $L_d$；
  - 由 $L_d$ 求实际中心距：

    $ a approx a_0 + (L_d - L_(d 0))/2; $
  - 考虑安装、中心距调整、补偿张紧力 $F_0$，中心距 $a$ 的变动范围为

    $ (a - 0.015 L_d) tilde (a + 0.03 L_d). $

+ *验算小轮包角*：

  $ alpha_1 = 180 degree - (D_2 - D_1)/a times 60 degree >= 120 degree quad ("个别情况下至少" 90 degree). $

  如不满足，采取的措施为：增大中心距；加张紧轮。

+ *计算带的根数 $z$*：

  $ z = P_"ca"/((P_0 + Delta P_0) K_alpha K_L K), $

  其中：

  - $K_alpha$：包角系数，查教材表 8-9；
  - $K_L$：长度系数，查教材表 8-10；
  - $Delta P_0$：考虑 $i != 1$ 时传动功率的增量，见教材表 8-6(b)；
  - $K$：材质系数；
  - $P_0$：单根 V 带的基本额定功率，见表 8-6(a)。

+ *确定带的初拉力 $F_0$（单根带）*：

  $ F_0 = 500 P_"ca"/(z v) (2.5/K_alpha - 1) + q v^2. $

+ *求带作用于轴的压力 $Q$*：

  $ Q = 2 z F_0 sin alpha_1/2. $

== V 带轮的设计

=== 设计要求

重量轻，结构工艺性好，无过大的铸造内应力，质量分布均匀；轮槽表面要经过精细加工，以减轻带的磨损；各轮槽尺寸与角度要有一定的精度，使载荷分布较均匀。

=== 带轮材料

铸铁（常用）、铸钢（转速 $v$ 较大时）、铸铝或塑料（重量轻，小功率传动）。

=== 带轮的结构尺寸

按直径大小可做成实心式、腹板式和轮辐式；实心式用于 $D <= (2.5 tilde 3) d$（$d$ 为轴的直径）。

== 带传动的张紧与维护

=== 带的张紧

初拉力 $F_0$ 太小，传动能力下降；$F_0$ 太大，带寿命下降，应保证要求的初拉力。

常用的张紧方法：

+ 调节中心距；
+ 张紧轮。

张紧轮位置：① 松边内侧、靠大带轮；② 松边外侧（用于增大小带轮包角）。

=== 带的维护

+ 安装时，最好先缩小中心距，后套上 V 带，再预调整使带张紧，不能硬撬，以免损坏胶带，降低使用寿命；
+ 禁止与矿物油、酸、碱等介质接触，以免腐蚀带，亦不能曝晒；
+ 带根数较多的传动，若少数几根破坏，不要立即补全，否则由于旧带已永久变形，新旧带一起使用，载荷分配不均，加速新带的损坏，应使旧带继续工作或全部换新；
+ 为保证安全生产，应安装防护罩；
+ 带工作一段时间后，应重新张紧。

== 同步带传动

同步带传动靠挠性带上的齿和轮缘上的齿相互啮合进行传动。

特点：保证准确的传动比；张紧力小；重量轻；柔韧性好；制造安装要求高。

#heading(level: 2, numbering: none, outlined: true)[本章重点]

+ 带传动的组成、工作原理与优缺点；
+ 受力分析：$F_e = F_1 - F_2$、$F_1 + F_2 = 2 F_0$；
+ 最大有效拉力 $F_"ec"$ 与打滑条件；
+ 带的三种应力、瞬时最大应力位置与疲劳强度条件；
+ 弹性滑动与打滑的区别；
+ 滑动率与传动比；
+ V 带传动的设计步骤：计算功率、带型、带轮直径与带速、中心距与基准长度、包角、根数、初拉力、轴压力；
+ 带传动的张紧方法与维护。

// ============================================================================
//  第六章 链传动
// ============================================================================

= 链传动

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

在学完这一章之后最大的收获其实是知道了自行车为啥会响（

和上一节的带传动相比，由于链传动是链轮轮齿和链节啮合传动，所以链传动的#text(fill: red)[平均传动比]准确，传动效率高，压轴力小，能在温度较高、有油污的恶劣环境条件下工作。对，适合用在自行车上。

但缺点也很明显啊。瞬时传动比不恒定，传动平稳性差，工作中有冲击和噪声，不宜在急速变载和变向的传动中使用。

== 传动链的结构

传动链主要分为滚子链和齿形链。课程掌握滚子链为主。

=== 滚子链结构

滚子链的结构如下图：

#figure(
  image("Figure/滚子链结构.jpg", width: 90%),
  caption: [滚子链结构],
)

观察这个滚子链的结构，可以看出以下特点：

- 链板制成"8"字形，目的是使各截面抗拉强度近似相等并减少质量及惯性力
- 内外链板间有间隙，保证润滑油能进入磨损面（主要磨损面是套筒和销轴之间）

然后滚子链各部件之间的配合关系如下：

- 内链板和套筒之间采用过盈配合
- 外链板和销轴之间采用过盈配合
- 套筒和销轴之间采用间隙配合
- 滚子和套筒之间采用间隙配合

#feature-showy(title: "滚子链的接头型式")[
  当链节为偶数时，接头处用开口销或弹簧卡片来固定。链节数最好取偶数：以使链条联成环形时，正好是外链板和内链板相接。若连接数为奇数，则需在接头处用一个过渡链节来连接。但过渡链节工作时受附加弯矩，尽量避免使用。
]

滚子链的基本参数有链节数、节距、链轮齿数、链条长度、链条宽度等。其中节距 $p$ 是主要参数。

#formula-showy(title: "节距")[
  $ p = "链号" times 25.4/16 $
]

== 齿形链

齿形链是由一组带有两个齿的链板左右交错并列铰接而成。

齿形链有如下优点：

- 传动平稳、无噪声，承受冲击性能好，铰接工作可靠；
- 高速传动、传动比大和中心距较小的场合；
- 结构复杂，价格较高，多用于高速或运动精度较高的传动装置。

#figure(
  image("Figure/齿形链.jpg", width: 30%),
  caption: [齿形链],
)

== 链轮

=== 链轮的基本参数及主要尺寸

- 配用链条的节距 $p$
- 套筒的最大外径 $d_1$
- 链轮的齿数 $z$
- 排距 $p_t$

=== 链轮齿形

三圆弧一直线（凹齿形），如 @fig-三圆弧一直线 所示。

#figure(
  image("Figure/三圆弧一直线.png", width: 30%),
  caption: [链轮齿形],
)<fig-三圆弧一直线>

优点是：接触应力小、冲击小、磨损少、不易跳齿和脱链。

=== 链轮的材料

链轮的材料应该具有足够的轮齿接触强度和耐磨性，同时小链轮的材料要优于大链轮。

+ 冲击载荷时，低碳钢和低碳合金钢。
+ 无剧烈冲击，中等速度，中碳钢和中碳合金钢
+ 中小功率，普通或优质碳素钢；大功率，合金钢

== 传动链的几何计算

#definition-showy(title: "链节线")[
  在链条（如滚子链、无声链）中，链节线是一条假想的直线，其核心定义是：当链条处于直线状态时，穿过所有连接销轴（或摇轴）接触点中心的一条线。
]

链条线长度计算公式（$pi D_1 = z_1 p$ 和 $pi D_2 = z_2 p$ 是链轮的外径）：

$ L_P &= 2 a + pi/2 (D_1 + D_2) + (D_2 - D_1)^2/(4 a) \
    &= 2 a + ((z_1 + z_2) p)/2 + ((z_2 - z_1)/(2 pi))^2 dot p^2/a $

链节数

$ N_P = (z_1 + z_2)/2 + (2 a)/p + ((z_2 - z_1)/(2 pi))^2 dot p/a $

中心距：

$ a = p/4 [ &(L_P - (z_1 + z_2)/2) \
        &+ sqrt((L_P - (z_1 + z_2)/2)^2 - 8 ((z_2 - z_1)/(2 pi))^2) ] $

== 链传动的运动特性

在链传动中，链条进入链轮后形成折线，相当于两个正多边形之间的传动，正多边形的边长等于链条的节距 $p$。链节在运动中忽上忽下、忽快忽慢，使链速和瞬时传动比都作有规律的周期性波动。

本节符号：$z_1$、$z_2$ 为主、从动轮齿数；$n_1$、$n_2$ 为主、从动轮转速；$p$ 为链条节距；$d_1$、$d_2$ 为主、从动轮分度圆直径；$omega_1$、$omega_2$ 为主、从动轮角速度；$beta$、$gamma$ 为主、从动轮相位角；$phi_1$、$phi_2$ 为分度圆上相邻两齿所对的中心角。

=== 平均链速与平均传动比

链轮每转过一个齿，链条就移动一个节距，故链条的平均速度

$ v = (z_1 p n_1)/(60 times 1000) = (z_2 p n_2)/(60 times 1000), $

式中 $v$ 的单位为 m/s，$p$ 的单位为 mm，$n_1$、$n_2$ 的单位为 r/min。由此得平均传动比

$ i = n_1/n_2 = z_2/z_1 = "常数", $

即链传动的*平均传动比准确*；但由于链条在链轮上呈折线分布，瞬时传动比并不是定值。

=== 瞬时链速与瞬时传动比

*主动轮*。设主动轮分度圆直径为 $d_1$，角速度为 $omega_1$，则链节销轴中心随主动轮转动的圆周速度

$ v_1 = (omega_1 d_1)/2, $

它沿链条方向的分量即为链速 $v$，垂直方向的分量 $v'$ 则使链条上下抖动：

$ v = v_1 cos beta = (omega_1 d_1)/2 cos beta, quad quad v' = v_1 sin beta = (omega_1 d_1)/2 sin beta, $

式中 $beta$ 为主动轮的相位角，其变化范围为

$ beta in [-phi_1/2, +phi_1/2], quad quad phi_1 = 360 degree/z_1. $

可见在啮合过程中，链速 $v$ 与垂直分量 $v'$ 都在周期性地变化：

- 开始啮合（$beta = -phi_1/2$）：$v$ 最小，$v'$ 最大（链条向上抖动）；
- 销轴位于分度圆最高点（$beta = 0$）：$v$ 最大，$v' = 0$；
- 退出啮合（$beta = +phi_1/2$）：$v$ 最小，$v'$ 最大（链条向下抖动）。

*从动轮*。同理，从动轮分度圆上的圆周速度 $v_2$ 与链速满足 $v = v_2 cos gamma$，故

$ v_2 = (omega_2 d_2)/2 = v/cos gamma = (omega_1 d_1 cos beta)/(2 cos gamma), $

式中 $gamma$ 为从动轮的相位角，$gamma in [-phi_2/2, +phi_2/2]$，$phi_2 = 360 degree/z_2$。由此得瞬时传动比

$ i_t = omega_1/omega_2 = (d_2 cos gamma)/(d_1 cos beta) != "常数". $

#definition-showy(title: "多边形效应")[
  链条绕在链轮上形成正多边形，使瞬时链速与瞬时传动比随相位角 $beta$、$gamma$ 周期性波动，这种现象称为*多边形效应*。
]

#remark-box[
  链轮齿数一般取与链节数互为质数的奇数。
]

// ============================================================================
//  第七章 齿轮传动
// ============================================================================

= 齿轮传动

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

== 齿轮传动的特点

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  [
    优点：

    - 传动效率高；
    - 传动比准确；
    - 结构紧凑，承载能力高；
    - 工作可靠，寿命长；
  ],
  [
    缺点：

    - 对齿轮制造、安装要求高；
    - 齿轮制造需用专用机床及刀具；
    - 齿轮传动成本及费用高；
    - 不适宜中心距过大的动力传递；
  ],
)

== 齿轮传动的失效形式

对于齿轮传动的失效形式，需要清楚失效的原因、失效的常见位置还有怎么预防失效。

=== 轮齿折断

轮齿折断_（Teeth breaking-off）_为*闭式硬齿面齿轮*的主要失效形式。

一般分为弯曲疲劳折断和过载折断两种形式。

力作用使齿根处产生最大拉应力，导致齿轮折断。

于是对于折断部位我们可以看到，对于直齿轮折断一般发生在齿根部位，对于斜齿轮则为局部折断。（斜齿轮接触线倾斜，啮合逐渐进入退出，加上轴向力和偏载，载荷沿齿宽分布不均，端部或局部齿根应力最大，所以常表现为局部折断。）

提高轮齿抗折断的能力：

+ 减小齿根应力集中（如增大齿根过渡圆角半径）
+ 提高安装精度及支承刚度，避免偏载
+ 改善热处理使其有足够的齿芯韧性和齿面硬度
+ 齿根部分进行表面强化处理（喷丸、滚压等）

=== 齿面疲劳点蚀

*齿面疲劳点蚀*是*闭式软齿面齿轮*的主要失效形式。

疲劳点蚀一般发生在节线附近。

节线附近通常为单齿对啮合，接触应力较大。且节线处相对滑动速度低，不易形成润滑油膜。

#figure(
  image("Figure/齿面疲劳点蚀.png", width: 80%),
  caption: [疲劳点蚀],
)

防止轮齿疲劳点蚀的措施：

+ 提高齿面硬度
+ 降低表面粗糙度
+ 采用变位齿轮以增加综合曲率半径
+ 选用较高粘度润滑油
+ 提高加工安装精度，改善散热

=== 齿面磨损

开式齿轮的主要失效形式是齿面磨损。

防止齿面磨损措施：

+ 提高齿面硬度（我比沙子硬就行）
+ 降低表面粗糙度
+ 降低滑动系数
+ 润滑油清洁更换
+ 变开式为闭式（我加个罩子就成了吧）

=== 齿面胶合

高速重载齿轮的主要失效形式是齿面胶合。

高速重载下，压力大，滑动速度高，摩擦热就大，产生高温，导致啮合齿面黏结，然后黏结的地方被剪切，导致齿轮失效。

而胶合形式又分为热胶合和冷胶合。

热胶合成因如上，冷胶合一般发生在低速重载，但是缺少润滑油，也会产生冷焊结点。

#figure(
  image("Figure/齿面胶合.png", width: 80%),
  caption: [齿面胶合],
)

防止齿面胶合措施：

+ 采用抗胶合能力强的润滑油
+ 降低滑动速度（变位或减小模数和齿高）
+ 提高齿面硬度
+ 降低粗糙度
+ 配对齿轮有适当的硬度差
+ 改善润滑与散热条件

=== 齿面塑性变形

低速重载齿轮的主要失效形式是齿面塑性变形。

齿面在过大的摩擦力作用下处于屈服状态，产生沿摩擦力方向的齿面材料的塑性流动，使齿面正确轮廓曲线被破坏。

防止塑性变形措施：

+ 采用高粘度的润滑油或加极压添加剂。
+ 提高齿面硬度

== 设计准则

#figure(
  image("Figure/齿轮传动设计准则.svg", width: 100%),
  caption: [齿轮传动设计准则],
)

== 齿轮传动的计算载荷

#formula-showy[
  $ F_"nc" = K F_n $

  其中：

  - $F_"nc"$：计算法向载荷
  - $K$：载荷系数
  - $F_n$：名义法向载荷
]

对于载荷系数 $K$，有

$ K = K_A K_v K_beta K_alpha $

下面逐一看看这四个系数。

=== 工作情况系数 $K_A$

考虑齿轮啮合时，外部因素引起的附加动载荷对传动的影响。

外部因素：与原动机、工作机、联轴器等有关。

=== 动载荷系数 $K_v$

考虑齿轮制造、安装误差及弹性变形等内部因素引起的附加动载荷的影响。

=== 齿向载荷分布系数 $K_beta$

考虑轴的弯曲、扭转变形、轴承、支座弹性变形及制造和装配误差而引起的沿齿宽方向载荷分布不均匀的影响。

影响因素：

+ *支承情况*：对称布置——好；非对称布置——差；悬臂布置——差；
+ *齿轮宽度*：齿轮宽度越大，齿向载荷分布系数越大；
+ *齿面硬度*：齿面硬度越高，越易偏载，齿面较软时有变形退让；
+ *制造、安装精度*：精度越高，齿向载荷分布系数越小。

减小 $K_beta$ 的措施：

+ 提高制造安装精度；
+ 提高支承刚度，尽量避免悬臂布置；
+ 采用鼓形齿（drum tooth），齿向鼓形量取 $(0.0005 tilde 0.001) b$；
+ 螺旋角修形（helical angle correction）——沿小齿轮齿宽进行修形，以补偿由于轴的弯曲和扭转变形引起的啮合线位置的改变。

=== 齿间载荷分配系数 $K_alpha$

考虑同时有多对齿啮合时，各对轮齿间载荷分配不均匀的影响。

== 直齿圆柱齿轮传动的强度计算

=== 受力分析

#figure(
  image("Figure/轮齿受力分析.png", width: 50%),
  caption: [轮齿受力分析],
)

如上图所示，法向力 $F_n$ 可以正交分解为径向力 $F_r$ 和切向力 $F_t$，且方向遵循"主反从同"。

=== 齿根弯曲疲劳强度计算

计算假设：

+ 单对齿啮合。
+ 载荷作用于齿顶。
+ 按悬臂梁计算。
+ 只考虑弯曲应力。
+ 用重合度系数考虑非单对齿啮合。
+ 危险截面用 $30 degree$ 切线法。

#formula-showy[
  $ sigma_F = (2 K T_1)/(b d_1 m) dot Y_(F a) Y_(S a) Y_epsilon $

  其中：

  - $sigma_F$：齿根弯曲应力（MPa）
  - $K$：载荷系数
  - $T_1$：小齿轮传递的转矩（N·mm）
  - $b$：齿宽（mm）
  - $d_1$：小齿轮分度圆直径（mm）
  - $m$：模数（mm）
  - $Y_(F a)$：齿形系数（考虑齿形对齿根弯曲应力的影响）
  - $Y_(S a)$：应力修正系数（考虑齿根过渡圆角处应力集中的影响）
  - $Y_epsilon$：重合度系数（考虑重合度对齿根弯曲应力的影响）
]

引入齿宽系数 $Phi_d = b/d_1$，则有

#formula-showy(title: "校核公式")[
  $ sigma_F = (2 K T_1 Y_(F a) Y_(s a) Y_epsilon)/(phi_d m^3 Z_1^2) <= [sigma]_F $
]

#formula-showy(title: "设计公式")[
  $ m >= root(3, (2 K T_1)/(phi_d Z_1^2) dot (Y_(F a) Y_(s a) Y_epsilon)/[sigma]_F) $
]

== 齿面接触疲劳强度计算

设计依据：两圆柱体接触赫兹公式。

#formula-showy(title: "接触疲劳强度的校核公式")[
  $ sigma_H = Z_E dot Z_epsilon dot Z_H sqrt((K F_t)/(b d_1) dot (u plus.minus 1)/u) <= [sigma]_H $

  其中：

  - $sigma_H$：齿面接触应力（MPa）
  - $Z_E$：弹性影响系数（与两齿轮材料的弹性模量、泊松比有关）
  - $Z_H$：区域系数（考虑节点处齿廓形状对接触应力的影响）
  - $Z_epsilon$：重合度系数
  - $K$：载荷系数
  - $F_t$：圆周力（N），$F_t = 2 T_1/d_1$
  - $b$：齿宽（mm）
  - $d_1$：小齿轮分度圆直径（mm）
  - $u$：齿数比（$u = z_2/z_1$），外啮合取"$+$"，内啮合取"$-$"
  - $[sigma]_H$：许用接触应力（MPa）
  - $T_1$：小齿轮传递的转矩（N·mm）
  - $phi_d$：齿宽系数（$phi_d = b/d_1$）
]

#formula-showy(title: "设计公式")[
  $ d_1 >= root(3, (2 K T_1)/phi_d dot (u plus.minus 1)/u ((Z_H Z_E Z_epsilon)/[sigma]_H)^2) $
]

== 斜齿圆柱齿轮传动的强度计算

=== 受力分析

/ 轴向力: 根据主动轮轮齿的齿向（左旋或右旋）伸左手或右手，四指沿主动轮的转向握住轴线，大拇指所指即为主动轮所受的轴向力 $F_a$ 的方向。$F_a = F_t dot tan beta$
/ 径向力: 指向各自轮心。$F_r = F_t dot tan alpha_t = F_t dot tan alpha_n slash cos beta$
/ 圆周力: 主反从同。$F_t = 2 T_1/d_1$

// ---- 第七章完 ----

// ============================================================================
//  第十一章 蜗杆传动（课件第 11 章）
// ============================================================================

= 蜗杆传动

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

== 蜗杆传动的类型及特点

=== 类型

蜗杆传动由*蜗杆*与*蜗轮*组成，用于传递交错角为 $90 degree$ 的两轴之间的运动与动力。

#figure(
  image("Figure/蜗杆传动组成与类型.png", width: 94%),
  caption: [蜗杆传动的组成与类型：圆柱蜗杆、环面蜗杆、锥蜗杆],
)

- 按蜗杆形状：圆柱蜗杆传动、环面蜗杆传动、锥蜗杆传动；
- 圆柱蜗杆按齿廓：阿基米德蜗杆（ZA，车刀车制）、渐开线蜗杆（ZI）、法向直廓蜗杆（ZN）、锥面包络圆柱蜗杆（ZK，铣刀铣制）、圆弧圆柱蜗杆（ZC）。

=== 特点

#feature-showy(title: "蜗杆传动的特点")[
  优点：传动比大（动力传动 $i = 8 ~ 80$，分度机构可达数百）；连续啮合、传动平稳、噪声小；结构紧凑；当导程角小于当量摩擦角时具有自锁性。\
  缺点：齿面相对滑动速度大，摩擦磨损大、效率低（一般 $0.7 ~ 0.8$），发热量大，需进行热平衡计算；蜗轮常需采用贵重的减摩材料（青铜）。
]

== 普通圆柱蜗杆传动的主要参数

=== 中间平面与正确啮合条件

#definition-showy(title: "中间平面")[
  通过蜗杆轴线并垂直于蜗轮轴线的平面。在中间平面内，蜗杆蜗轮传动相当于*齿轮齿条传动*。
]

#figure(
  image("Figure/中间平面.png", width: 50%),
  caption: [中间平面内的蜗杆蜗轮啮合],
)

正确啮合条件（中间平面内）：

$ m_(a 1) = m_(t 2) = m, quad quad alpha_(a 1) = alpha_(t 2) = alpha, quad quad gamma = beta $

即模数、压力角分别相等，且蜗杆导程角 $gamma$ 与蜗轮螺旋角 $beta$ 大小相等、旋向相同。标准压力角 $alpha = 20 degree$。

=== 蜗杆分度圆直径与直径系数

蜗杆分度圆直径 $d_1$ 与模数之比定义为*直径系数* $q$：

$ d_1 = m q, quad quad q = d_1/m $

$d_1$ 与 $q$ 已标准化。标准化 $q$ 的目的：限制蜗轮滚刀数量（滚刀与蜗杆尺寸一致），并保证蜗杆具有足够的刚度。

=== 蜗杆头数与蜗轮齿数

- 蜗杆头数 $z_1$：常取 $1, 2, 4$；$z_1$ 大则传动比小、效率高；
- 蜗轮齿数 $z_2$：动力传动取 $z_2 = 27 ~ 80$（过小易根切、啮合区小；过大则 $d_2$ 不变时模数变小、弯曲强度不足）。

传动比：

$ i = n_1/n_2 = z_2/z_1 = d_2/d_1 $

=== 导程角

$ tan gamma = (z_1 p_z)/(pi d_1) = (z_1 m)/d_1 = z_1/q $

$gamma$ 为蜗杆分度圆柱上螺旋线的切线与端面间的夹角。$gamma$ 增大，传动效率提高，但制造困难，一般 $gamma < 28 degree$。

=== 变位

蜗轮变位、蜗杆不变位。变位目的：配凑中心距、提高承载能力、改变传动比、提高效率。变位后：

$ a' = a + x_2 m = (d_1 + d_2 + 2 x_2 m)/2 $

中心距改变时（$a' != a$）传动比不变；中心距不变而变位时（$a' = a$）传动比改变。

=== 几何尺寸计算

#figure(
  md-table(
    (auto, auto, 1.3fr),
    ([名称], [符号], [计算式]),
    [分度圆直径], [$d_1, d_2$], [$d_1 = m q, quad d_2 = z_2 m$],
    [齿顶圆直径], [$d_(a 1), d_(a 2)$], [$d_(a 1) = d_1 + 2 h_a^* m$],
    [齿根圆直径], [$d_(f 1), d_(f 2)$], [$d_(f 1) = d_1 - 2 (h_a^* + c^*) m$],
    [中心距], [$a$], [$a = (d_1 + d_2)/2 = m(q + z_2)/2$],
    [齿距], [$p$], [$p = pi m$],
    [导程], [$p_z$], [$p_z = z_1 p = pi m z_1$],
  ),
  caption: [普通圆柱蜗杆传动的几何尺寸计算],
)

其中 $h_a^* = 1$，$c^* = 0.2$。

== 承载能力计算

=== 失效形式与材料

蜗杆传动的主要失效形式：齿面点蚀、齿根折断、齿面胶合与过度磨损。

- *开式传动*：主要为齿面过度磨损与轮齿折断 $arrow$ 按*齿根弯曲疲劳强度*设计；
- *闭式传动*：主要为齿面胶合与点蚀 $arrow$ 按*齿面接触疲劳强度*设计，并进行热平衡计算。

#figure(
  md-table(
    (auto, 1.6fr),
    ([零件], [常用材料]),
    [蜗杆], [碳钢（45 钢）或合金钢（40Cr、20CrMnTi 等），经淬火或渗碳淬火，表面硬度高、光洁],
    [蜗轮], [铸造锡青铜（ZCuSn10P1、ZCuSn5Pb5Zn5）：耐磨性好、价格高，用于 $v_s >= 3 "m/s"$],
    [ ], [铸造铝铁青铜（ZCuAl10Fe3）：耐磨性差、价格低，用于 $v_s <= 4 "m/s"$],
    [ ], [灰铸铁（HT150、HT200）：用于 $v_s <= 2 "m/s"$ 的低速传动],
  ),
  caption: [蜗杆、蜗轮的常用材料],
)

=== 受力分析

#figure(
  image("Figure/蜗杆受力分析.png", width: 58%),
  caption: [蜗杆传动的受力分析],
)

蜗杆主动时，各分力大小：

$ F_(t 1) = (2 T_1)/d_1 = -F_(a 2), quad quad F_(a 1) = (2 T_2)/d_2 = -F_(t 2), quad quad F_(r 1) = -F_(r 2) = F_(t 2) tan alpha $

- 蜗杆*圆周力* $F_(t 1)$ 为阻力，与转向相反；
- 蜗杆*轴向力* $F_(a 1)$ 与蜗轮圆周力 $F_(t 2)$ 大小相等、方向相反；
- *径向力* $F_(r 1)$、$F_(r 2)$ 分别指向各自轮心。

*方向判别*：蜗杆轴向力 $F_(a 1)$ 由螺旋线旋向与蜗杆转向按左（右）手定则确定——右旋用右手、左旋用左手，四指弯曲方向与蜗杆转向一致，拇指指向即为 $F_(a 1)$ 的方向；蜗轮转向与 $F_(t 2)$ 同向。

== 滑动速度与效率

=== 滑动速度

#figure(
  image("Figure/滑动速度.png", width: 42%),
  caption: [蜗杆传动的滑动速度],
)

蜗杆蜗轮齿面间的相对滑动速度：

$ v_s = v_1/(cos gamma) = (pi d_1 n_1)/(60 times 1000 cos gamma) > v_1 $

$v_1$、$v_2$ 分别为蜗杆、蜗轮的节点圆周速度。$v_s$ 较大时发热量大、润滑易失效，易发生齿面磨损与胶合，故对材料与润滑要求高。

=== 效率

$ eta = eta_1 eta_2 eta_3 approx (0.95 ~ 0.96) tan gamma/(tan(gamma + rho_v)) $

$eta_1$ 为啮合效率（$rho_v$ 为当量摩擦角），$eta_2$、$eta_3$ 为轴承效率与搅油效率。影响总效率的关键因素是啮合效率，其主要影响因素为导程角 $gamma$、滑动速度、材料配对与润滑。$z_1$ 增大 $arrow$ $gamma$ 增大 $arrow$ 效率提高。

== 润滑与热平衡

=== 润滑

目的：提高效率、降低温升、防止磨损与胶合。一般低速重载用粘度高的润滑油，高速轻载用粘度低的油；浸油润滑时浸油深度约为蜗轮齿高的 1 个齿高。

=== 热平衡计算

闭式蜗杆传动效率低、发热量大，须进行热平衡计算。单位时间产热与散热量相等时：

$ 1000 P (1 - eta) = K_d A (t_1 - t_0) quad ==> quad t_1 = t_0 + (1000 P (1 - eta))/(K_d A) <= 80 degree $

$P$ 为输入功率（kW），$K_d$ 为箱体表面散热系数，$A$ 为散热面积，$t_0$ 为环境温度，$[t_1] = 80 degree$ 为允许油温。

油温超过限值时采取：加散热片以增大散热面积；蜗杆轴端加风扇强制风冷；箱内装循环冷却水管；采用压力喷油循环润滑。

== 结构设计

- *蜗杆*：通常与轴做成一个整体（车制或铣制）；
- *蜗轮*：整体浇铸式（青铜）、齿圈压配式（青铜齿圈 + 钢轮芯）、组合式、螺栓联接式。

== 本章重点

+ 蜗杆传动的类型与特点（传动比大、平稳、可自锁；效率低、发热大）；
+ 中间平面、正确啮合条件与主要参数（$m, alpha, d_1 = m q, z_1, z_2, gamma, i$）；
+ 几何尺寸计算与中心距；
+ 失效形式、材料与设计准则；受力分析与方向判别；
+ 滑动速度、效率、润滑与热平衡计算。

// ============================================================================
//  第八章 轴
// ============================================================================

= 轴

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

== 概述

=== 轴的功用与分类

#definition-showy(title: "轴的功用")[
  轴是机器中的重要零件之一，其主要作用有二：#text(fill: red)[支承回转零件]（如齿轮、带轮），并#text(fill: red)[传递运动和动力]。
]

按承载情况不同，轴可分为三类：

#figure(
  md-table(
    (2.2cm, 4.6cm, 6.0cm),
    ([类型], [受力特点], [典型实例]),
    [*转轴*], [既承受弯矩 $M$，又传递转矩 $T$], [减速器中的齿轮轴（工作中转动）],
    [*心轴*], [只承受弯矩 $M$，不传递转矩 $T$], [火车轮轴（转动心轴）、自行车前轴（固定心轴）],
    [*传动轴*], [主要传递转矩 $T$，弯矩很小或可忽略], [汽车连接发动机与后桥的传动轴],
  ),
  caption: [按承载情况分类的三种轴],
)

#figure(
  image("Figure/轴的分类-转轴心轴传动轴.png", width: 90%),
  caption: [转轴、心轴与传动轴的受力对比],
)

按轴线形状，轴又分为直轴（光轴、阶梯轴）、曲轴、空心轴和钢丝软轴等。机械中最常用的是*阶梯轴*，因其便于轴上零件的装拆与定位。

#note-box[
  判断一根轴是转轴、心轴还是传动轴，关键看它工作时是否传递转矩（是否受扭），而不是看它转不转。火车轮轴随车轮一起转动，但只受弯矩，故为*转动心轴*。
]

=== 轴的材料

#definition-showy(title: "轴的常用材料")[
  + *碳素钢*：35、45、50 钢（正火或调质），*45 钢应用最广*；
  + *合金钢*：力学性能高，但价格贵，用于有强度、韧性或耐磨性要求的重要轴，如 20Cr、40Cr、40CrNi、38SiMnMo 等；
  + *铸铁*：用于形状复杂的低速轻载轴（如曲轴），减振耐磨但脆。
]

#key-box(title: "两个重要结论")[
  + 各种钢材的弹性模量 $E$ 相差很小，故#text(fill: red)[采用合金钢并不能显著提高轴的刚度]；
  + 合金钢对应力集中较敏感，且价格贵；轴的热处理与表面强化（高频淬火、渗碳、氮化、喷丸、滚压等）主要提高的是#text(fill: red)[疲劳强度]，而非刚度。
]

== 轴的结构设计

轴的结构设计是本章难点。设计要求可归纳为三点：轴和轴上零件要有准确牢固的工作位置（轴向与周向固定）；零件装拆调整方便；轴本身具有良好的制造与装配工艺性。

=== 轴的组成

#definition-showy(title: "轴颈、轴头与轴身")[
  + *轴颈*：轴被轴承支承的部分；
  + *轴头*：安装轮毂（齿轮、带轮等）的部分，其直径与轮毂内径配合；
  + *轴身*：连接轴颈与轴头的中间部分。
]

#figure(
  image("Figure/轴的结构组成-轴肩轴环轴颈轴头.png", width: 90%),
  caption: [阶梯轴的结构组成（轴肩、轴环、轴颈、轴头）],
)

=== 轴上零件的轴向定位

零件在轴上的轴向固定，常见方式如下：

#figure(
  md-table(
    (3.0cm, 5.2cm, 4.6cm),
    ([定位方式], [特点], [适用场合]),
    [轴肩 / 轴环], [结构简单、可靠，可承受较大轴向力；但轴肩高度受零件装拆限制], [最常用的轴向定位方式],
    [套筒], [定位方便、简化轴结构、减小应力集中；但套筒不宜过长，且不宜用于高速], [相邻两零件间距较小时],
    [圆螺母 + 止动垫圈], [可承受较大轴向力；但有螺纹应力集中，多用细牙], [轴端或无法用套筒处],
    [轴端挡圈], [仅用于轴端零件，可承受较大轴向力，应用广], [轴端零件固定],
    [弹性挡圈], [结构简单、定位方便；承载小，有应力集中], [轻载、光轴处],
    [紧定螺钉 / 销], [承载能力低，可兼作周向定位], [轻载、低速],
    [圆锥面 + 挡圈螺母], [对中好、可拆，兼作周向定位], [受冲击、对中要求高的轴端],
    [轴承端盖], [压紧轴承外圈，使轴承在箱体中轴向定位], [轴承外圈的轴向固定],
  ),
  caption: [轴上零件的轴向定位方式],
)

#warn-box(title: "两个关键尺寸约束")[
  + 为保证轴肩能贴紧零件端面，*轴段长度应比轮毂宽度短 $2 tilde 3$ mm*（即 $L_"轴" < L_"毂"$），否则套筒或挡圈压不紧轮毂；
  + 轴肩高度必须#text(fill: red)[小于滚动轴承内圈的高度]，否则拆卸轴承时拉马（拔卸器）的拉爪钩不住内圈。
]

#figure(
  image("Figure/轴肩定位-轴承内圈高度限制.png", width: 80%),
  caption: [轴肩高度须低于轴承内圈高度，便于拆卸],
)

=== 轴上零件的周向定位

周向定位的目的是保证轴与零件不发生相对转动并传递转矩。常用方式：键（普通平键、导向键）、花键（承载大、对中好，适于动联接）、紧定螺钉与销、过盈配合等。*紧定螺钉与过盈配合可同时实现轴向与周向定位*。

=== 轴段直径与长度的确定

+ *直径*：先按转矩初估最小直径 $d_"min"$，再按零件装拆定位要求逐段确定各轴段直径；与标准件（轴承、联轴器）配合的轴径必须取标准值；同一轴径段上不宜装三个以上零件。
+ *长度*：各轴段长度与相配零件的轮毂宽度对应；转动件与静止件之间必须留有间隙。

=== 轴的结构工艺性

#definition-showy(title: "轴的结构工艺性要点")[
  + 轴肩圆角 $r$ 要小于相配零件轮毂孔的倒角或圆角，以保证端面贴紧；增大过渡圆角可降低应力集中；
  + 轴端倒角，便于零件安装并去除毛刺；
  + 需要磨削的轴段应留*砂轮越程槽*，需要车螺纹的轴段应留*螺纹退刀槽*；
  + 同一根轴上的多个键槽应布置在*同一条母线上*，并取相同截面尺寸，以便一次装夹铣出。
]

#figure(
  image("Figure/轴的工艺性-砂轮越程槽退刀槽.png", width: 80%),
  caption: [砂轮越程槽与螺纹退刀槽],
)

== 轴的强度计算

=== 按转矩初估轴径

只受转矩或以转矩为主的传动轴，可按扭转强度初估轴径。圆轴的抗扭截面系数 $W_t approx 0.2 d^3$。

#formula-showy(title: "扭转强度条件与设计公式")[
  $ tau = T/W_t = (9.55 times 10^6 P/n)/(0.2 d^3) <= [tau] $

  设计公式：

  $ d >= root(3, (9.55 times 10^6)/(0.2 [tau]) dot P/n) = A_0 root(3, P/n) $

  其中 $P$ 为传递功率（kW），$n$ 为转速（r/min），$A_0$ 为由材料许用切应力决定的系数。
]

#note-box[
  轴上开有键槽时，轴径应放大：一个键槽放大 $3% tilde 5%$，两个键槽放大 $7% tilde 10%$，然后圆整为标准值。此式多用于#text(fill: red)[结构设计之前初估轴的最小直径]。
]

=== 按弯扭合成强度计算（重点）

转轴既受弯矩又受转矩。弯矩产生的弯曲应力通常是*对称循环变应力*，而转矩产生的扭转切应力的循环特性则随工作情况而定。为按第三强度理论 $sigma_"ca" = sqrt(sigma^2 + 4 tau^2)$ 统一处理，引入*折合系数 $alpha$*，把转矩折算成等效弯矩。

#formula-showy(title: "当量弯矩与弯扭合成强度条件")[
  当量弯矩：

  $ M_"ca" = sqrt(M^2 + (alpha T)^2) $

  强度条件：

  $ sigma_"ca" = M_"ca"/W = M_"ca"/(0.1 d^3) <= [sigma]_{-1} $

  设计公式：

  $ d >= root(3, M_"ca"/(0.1 [sigma]_{-1})) $
]

#figure(
  md-table(
    (5.5cm, 7.0cm),
    ([转矩 $T$ 的循环特性], [折合系数 $alpha$] ),
    [静应力（不反转、载荷平稳）], [$alpha approx 0.3$],
    [脉动循环应力（频繁正反转或启动）], [$alpha approx 0.6$],
    [对称循环应力（频繁正反转）], [$alpha = 1$],
  ),
  caption: [折合系数 $alpha$ 的取值],
)

#figure(
  image("Figure/弯扭合成-当量弯矩图.png", width: 85%),
  caption: [轴的受力分析与当量弯矩图绘制流程],
)

#key-box(title: "弯扭合成计算步骤")[
  + 画出轴的受力简图，求水平面、垂直面支反力；
  + 分别作水平面弯矩图 $M_H$、垂直面弯矩图 $M_V$，合成弯矩图 $M = sqrt(M_H^2 + M_V^2)$；
  + 作转矩图 $T$，按循环特性取 $alpha$，作当量弯矩图 $M_"ca" = sqrt(M^2 + (alpha T)^2)$；
  + 在当量弯矩最大的危险截面，按 $d >= root(3, M_"ca"/(0.1 [sigma]_{-1}))$ 校核或设计；若算得 $d$ 大于结构设计直径，则应修改结构。
]

#note-box[
  对于心轴：$T = 0$，$M_"ca" = M$。其中*转动心轴*的弯曲应力为对称循环，许用应力取 $[sigma]_{-1}$；*固定心轴*的弯曲应力为静应力，许用应力取 $[sigma]_{+1}$。
]

=== 安全系数校核计算

对于重要的轴，还需在应力集中较大的危险截面作疲劳安全系数校核。综合考虑载荷性质、应力集中、尺寸系数、表面状态与强化处理后：

#formula-showy(title: "弯扭联合作用下的安全系数")[
  $ S_sigma = sigma_{-1}/(K_sigma sigma_a + psi_sigma sigma_m), quad S_tau = tau_{-1}/(K_tau tau_a + psi_tau tau_m) $

  $ S_"ca" = (S_sigma S_tau)/sqrt(S_sigma^2 + S_tau^2) >= [S] $
]

这与第二章疲劳强度计算中的双向稳定变应力公式一致。

== 轴的刚度与振动稳定性

=== 轴的刚度

+ *弯曲刚度*：控制轴上剖面的挠度 $y <= [y]$ 和偏转角 $theta <= [theta]$。如齿轮处 $[y] = (0.01 tilde 0.03)$ mm，轴承处 $[theta] < 0.001$ rad。
+ *扭转刚度*：控制单位长度扭转角 $phi.alt <= [phi.alt]$，一般传动轴 $[phi.alt] = 0.5 degree tilde 1 degree$/m。

=== 轴的临界转速

#definition-showy(title: "临界转速")[
  由于轴和轴上零件的质量不均、对中误差等，转动时会产生周期性离心力，激起弯曲振动。当强迫振动频率与轴的固有频率重合时发生共振，此时的转速称为*临界转速* $n_c$。
]

单圆盘轴的一阶临界角速度近似为

$ omega_c = sqrt(g/y_0), quad n_c = 60 omega_c/(2 pi) $

其中 $y_0$ 为圆盘处轴的静挠度。

#key-box(title: "刚性轴与挠性轴")[
  + *刚性轴*：工作转速 $n < 0.85 n_c$，在远低于一阶临界转速下工作；
  + *挠性轴*：工作转速 $1.15 n_c < n < 0.85 n_(c_2)$，越过一阶临界转速后在共振区之上高速稳定运转。高速轴应使其工作转速避开相应的临界转速。
]

== 提高轴的强度与刚度的措施

+ *减小应力集中*：使轴径变化平缓、增大过渡圆角、采用内凹圆角或过渡肩环、过盈配合处开卸载槽、盘铣刀铣键槽比指铣刀应力集中小、渐开线花键优于矩形花键、避免在受载大处切制螺纹。
+ *合理布置轴上零件*：传动件尽量靠近支承、避免悬臂布置；转矩由一个输入、多个输出时，输入件放在中间，以减小轴上转矩。
+ *改进轴上零件结构*：如将齿轮布置在两轴承之间而非外伸端，使轴只受弯或弯扭均减小。
+ *改进表面质量*：降低表面粗糙度、进行表面强化处理（高频淬火、渗碳、氮化、喷丸、滚压），使表层产生预压应力，提高疲劳强度。

#heading(level: 2, numbering: none, outlined: true)[本章重点]

+ 轴按承载分为转轴、心轴、传动轴，会判别；
+ 合金钢不能提高轴的刚度，只能提高强度与疲劳强度；
+ 轴上零件的轴向/周向定位方式，以及"轴段短于轮毂 $2 tilde 3$ mm"、"轴肩低于轴承内圈"两个工艺约束；
+ 按转矩初估轴径 $d = A_0 root(3, P/n)$；
+ 弯扭合成强度计算：当量弯矩 $M_"ca" = sqrt(M^2 + (alpha T)^2)$，按转矩循环特性取 $alpha = 0.3/0.6/1$；
+ 轴的刚度校核（挠度、偏转角、扭转角）与临界转速、刚性轴/挠性轴概念。

// ============================================================================
//  第九章 滑动轴承
// ============================================================================

= 滑动轴承

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

== 概述

=== 轴承的功用与摩擦状态

#definition-showy(title: "轴承的功用")[
  轴承用来#text(fill: red)[支承轴及轴上零件]，减少轴颈转动时与支承间的摩擦与磨损。按摩擦性质分为*滑动轴承*与*滚动轴承*两大类。
]

滑动轴承中，轴颈与轴瓦表面间的润滑状态由差到好依次为：

#figure(
  image("Figure/滑动轴承的摩擦状态.png", width: 90%),
  caption: [干摩擦、边界摩擦、液体摩擦与混合摩擦],
)

+ *干摩擦*：表面间无润滑剂，磨损剧烈；
+ *边界摩擦*：润滑油中极性分子在金属表面形成极薄边界膜，但微观尖峰仍直接接触，摩擦系数 $f approx 0.1 tilde 0.3$；
+ *液体摩擦*：两表面完全被压力油膜隔开，摩擦仅发生在润滑油分子之间，$f approx 0.001 tilde 0.008$；
+ *混合摩擦*：边界摩擦与液体摩擦共存，多数实际轴承处于这种状态。

工程上把处于边界摩擦或混合摩擦下的称为*非流体润滑滑动轴承*（半液体润滑）；完全实现液体摩擦的称为*流体润滑滑动轴承*，又分*动压轴承*与*静压轴承*。

=== 滑动轴承的特点与应用

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  [
    优点：
    - 承载能力高；
    - 工作平稳、可靠、噪声低；
    - 径向尺寸小；
    - 旋转精度高；
    - 可用于高速、重载、冲击及剖分安装场合。
  ],
  [
    缺点：
    - 非流体摩擦时摩擦大、磨损严重；
    - 流体润滑轴承的设计、制造、润滑维护要求高。
  ],
)

滑动轴承特别适用于：转速特高（汽轮发电机）、旋转精度要求高（精密磨床）、特重型（水轮机）、承受巨大冲击振动（轧钢机）、必须剖分安装（曲轴）、径向尺寸受限或在水/泥浆/腐蚀介质中工作的场合。

=== 按承载方向分类

+ *径向（向心）滑动轴承*：承受径向载荷 $F_r$；
+ *止推（推力）滑动轴承*：承受轴向载荷 $F_a$；
+ *径向止推滑动轴承*：同时承受 $F_r$ 与 $F_a$。

#figure(
  image("Figure/滑动轴承分类-径向止推.png", width: 70%),
  caption: [径向滑动轴承与止推滑动轴承],
)

== 径向滑动轴承的主要类型

#figure(
  md-table(
    (2.6cm, 6.0cm, 4.2cm),
    ([类型], [结构特点], [适用场合]),
    [整体式], [轴承座与轴瓦整体或套筒压入；结构简单、成本低，但装拆需轴作轴向移动，磨损后间隙不可调], [低速、轻载、间歇工作],
    [剖分式（对开式）], [由轴承座、轴承盖、剖分轴瓦、螺栓组成；装拆时轴不需轴向移动，磨损后可通过减薄剖分面垫片调整间隙], [最常用，剖分面一般水平],
    [自动调心式], [轴瓦外表面做成球面，与座孔球面配合；轴倾斜时轴瓦可自动调位，避免边缘接触], [宽径比 $B/d > 1.5$、轴刚度差或对中不良],
    [调隙式], [锥形轴瓦两端用螺母调节轴向位置，从而调整径向间隙], [一般机床主轴],
  ),
  caption: [径向滑动轴承的主要类型],
)

#figure(
  image("Figure/剖分式径向滑动轴承结构.png", width: 85%),
  caption: [剖分式径向滑动轴承结构],
)

#figure(
  image("Figure/自动调心式滑动轴承.png", width: 70%),
  caption: [自动调心式滑动轴承（宽径比大时防止边缘磨损）],
)

== 滑动轴承的材料及轴瓦结构

=== 对轴承材料的要求

滑动轴承的主要失效形式是*磨损、胶合（烧瓦）和疲劳剥落*。因此轴瓦（轴承衬）材料应满足：

+ 良好的减摩性、耐磨性和抗胶合性；
+ 良好的*顺应性*（适应轴变形与对中误差）和*嵌藏性*（容纳硬粒污物）；
+ 足够的强度与必要的塑性；
+ 良好的导热性、耐腐蚀性和对润滑油的吸附能力；
+ 良好的工艺性与经济性。

=== 常用轴承材料

#figure(
  md-table(
    (2.6cm, 6.4cm, 3.8cm),
    ([材料], [特点], [适用场合]),
    [铸铁], [有游离石墨可自润滑，价廉但脆], [轻载、低速、无冲击],
    [轴承合金（巴氏合金/白合金）], [以锡或铅为软基体、悬浮锑锡/铜锡硬晶粒；硬晶粒耐磨、软基体顺应，嵌藏性与抗胶合性最好，但强度低、价贵，多浇注在钢或青铜轴瓦上作轴承衬], [高速、重载的重要轴承],
    [铜合金（青铜）], [锡青铜减摩耐磨最好，强度高；铅青铜抗胶合好；铝青铜硬而强], [重载、中速；高速重载；低速重载],
    [铝基合金], [强度高、耐磨、导热、耐腐蚀], [中、高速柴油机轴承],
    [粉末冶金（含油轴承）], [多孔组织，孔隙储油，自润滑], [中轻载、不便加油处],
    [非金属（塑料、橡胶）], [塑料：自润滑、耐蚀、减振，但导热差；橡胶：弹性大、可水润滑], [水泵、水轮机、污介质],
  ),
  caption: [常用滑动轴承材料],
)

=== 轴瓦结构与油沟

轴瓦分整体式与剖分式。为节约贵重金属，常在钢或青铜轴瓦内表面浇注一层薄的*轴承衬*（厚度一般不超过 6 mm），形成双金属结构。

#definition-showy(title: "油孔与油槽的开设原则")[
  + 油孔供油、油槽布油；
  + 油孔、油槽#text(fill: red)[不得开在油膜承载区]，否则会破坏压力油膜、显著降低承载能力；
  + 轴向油槽长度约为轴瓦宽度的 $0.8 B$，#text(fill: red)[不宜开通]，以免油从端部大量泄漏；
  + 周向油槽一般开在非承载区或半周，不要延伸到承载区。
]

#figure(
  image("Figure/油孔油槽形式.png", width: 90%),
  caption: [常见油孔与油槽形式（均布置在非承载区）],
)

== 滑动轴承的润滑

=== 润滑剂

+ *润滑油*：主要性能指标是*粘度*和*油性*。粘度高则承载能力强、摩擦功耗大、发热多；载荷大、温度高、冲击变载、表面粗糙时选高粘度油；滑动速度高、易形成油膜时选低粘度油。
+ *润滑脂*：由润滑油加钙/钠/锂等金属皂稠化而成，内阻力大，适于*低速重载*。指标有针入度（稠度）、滴点（耐热性）、耐水性。常用钙基脂（耐水、不耐热，$< 60 tilde 80 degree C$）、钠基脂（耐热、不耐水）、锂基脂（通用，$-20 tilde 150 degree C$）。
+ *固体润滑剂*：石墨、二硫化钼、聚四氟乙烯，用于高温、真空等特殊场合。

=== 润滑方法

#figure(
  md-table(
    (3.2cm, 5.0cm, 4.6cm),
    ([润滑方式], [特点], [适用]),
    [压注油杯（间歇）], [定期用油枪压注，简单], [小型、低速、间歇工作],
    [滴油润滑（针阀油杯）], [可调节油量、可控制供油], [一般重要轴承],
    [油芯（绳芯）润滑], [毛细管吸油自动滴油，不可调量], [轻载、连续工作],
    [油环润滑], [靠套在轴上的油环带油，$n = 50 tilde 2000$ r/min], [水平轴、转速适中],
    [浸油 / 飞溅润滑], [轴颈浸油或靠转动件溅油，供油连续；浸油搅油损失大], [减速器等封闭箱内],
    [压力循环润滑], [油泵强制供油，可冷却], [高速、重载、重要轴承],
    [脂润滑], [旋盖油杯、黄油枪，定期补充], [低速重载],
  ),
  caption: [常用润滑方式],
)

== 非全流体润滑滑动轴承的计算

非流体润滑轴承（边界/混合摩擦）的主要失效是过度磨损与温升导致边界膜破裂。设计时作#text(fill: red)[条件性计算]，校核三个指标：

#formula-showy(title: "径向滑动轴承的三个校核")[
  1. 限制平均比压（防止油被挤出、过度磨损）：

  $ p = F/(d B) <= [p] $

  2. 限制 $p v$ 值（限制温升、防止边界膜破裂；$p v$ 与摩擦功耗成正比）：

  $ p v = F/(d B) dot (pi d n)/(60 times 1000) <= [p v] $

  3. 限制滑动速度（当 $p$ 很小时，防止高速磨损）：

  $ v = (pi d n)/(60 times 1000) <= [v] $

  其中 $d$ 为轴颈直径，$B$ 为轴瓦宽度。
]

#key-box(title: "三个校核的目的")[
  + $p$ —— 防止载荷过大把润滑油挤干，导致磨粒磨损；
  + $p v$ —— 限制单位面积摩擦功耗，从而控制温升，避免边界膜因高温破裂而胶合；
  + $v$ —— 当比压不大时，单独限制线速度，防止高速下轴瓦过快磨损。
]

校核不满足时的措施：改选更好的轴瓦/轴承衬材料，或增大 $d$、$B$。

对于*推力滑动轴承*，同样校核 $p$ 和 $p v_m$（$v_m$ 为止推环平均直径处的圆周速度）；多环轴承受力不均，$[p]$、$[p v]$ 应降低约 $50%$。

#note-box[
  即使是流体动压轴承，在启动和停车阶段也处于混合润滑状态，因此设计时仍先用上述 $p$、$p v$、$v$ 作初步条件性校核。
]

#heading(level: 2, numbering: none, outlined: true)[本章重点]

+ 四种摩擦状态（干摩擦、边界、液体、混合）的特点与摩擦系数量级；
+ 整体式、剖分式、自动调心式、调隙式径向轴承的结构与适用；
+ 轴承合金（巴氏合金）"软基体+硬晶粒"的组织特点；
+ 油孔油槽必须开在非承载区、轴向油槽不开通；
+ 非流体润滑轴承的 $p$、$p v$、$v$ 三校核及其物理目的；
+ 滑动轴承与滚动轴承的适用场合对比。

// ============================================================================
//  第十章 滚动轴承
// ============================================================================

= 滚动轴承

#counter(figure.where(kind: image)).update(0)
#counter(figure.where(kind: table)).update(0)

== 概述

=== 滚动轴承的结构

滚动轴承是标准件，由四部分组成：

#figure(
  image("Figure/滚动轴承结构组成.png", width: 65%),
  caption: [滚动轴承的结构：内圈、外圈、滚动体、保持架],
)

+ *内圈*：装在轴颈上；*外圈*：装在轴承座孔内；
+ *滚动体*：球或滚子，是滚动轴承的核心元件，内、外圈滚道与滚动体间为点/线接触；
+ *保持架*：把滚动体均匀隔开，避免相互摩擦。

滚动体形状有球、圆柱滚子、圆锥滚子、鼓形滚子、滚针等。*球轴承*承载能力低、极限转速高；*滚子轴承*承载能力高、耐冲击，但极限转速较低。

内外圈和滚动体用轴承钢（GCr15、GCr15SiMn）制造，热处理后硬度 HRC 60~65；保持架多用低碳钢板冲压，高速时用铜或塑料。

=== 滚动轴承的特点

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  [
    优点：
    - 起动力矩小、摩擦功耗小；
    - 运转精度高，可预紧消隙；
    - 轴向尺寸小；
    - 可同时承受径向与轴向载荷，结构紧凑；
    - 润滑维护方便、互换性好（标准件）。
  ],
  [
    缺点：
    - 抗冲击能力差；
    - 高速时振动噪声较大；
    - 高速重载寿命较低；
    - 径向尺寸比滑动轴承大。
  ],
)

== 滚动轴承的类型与选择

=== 接触角与轴承分类

#definition-showy(title: "接触角 $alpha$")[
  滚动体与套圈滚道接触处的法线，与轴承径向平面（垂直于轴线的平面）之间的夹角称为*接触角* $alpha$。接触角越大，承受轴向载荷的能力越强。
]

#figure(
  image("Figure/滚动轴承接触角与分类.png", width: 75%),
  caption: [向心轴承、向心推力轴承与推力轴承的接触角],
)

按承载方向：
+ *向心轴承*（$alpha = 0$）：主要承受径向力；
+ *向心推力（角接触）轴承*（$0 < alpha < 45 degree$）：可同时承受径向力和轴向力；
+ *推力轴承*（$alpha = 90 degree$）：只能承受轴向力。

=== 常用滚动轴承类型

#figure(
  md-table(
    (2.0cm, 3.4cm, 3.0cm, 4.4cm),
    ([代号], [类型], [承载], [特点与适用]),
    [6], [深沟球轴承], [$F_r$，可兼受不大的 $F_a$], [当量摩擦系数最小、结构简单价廉、最常用；高速],
    [7], [角接触球轴承], [$F_r + F_a$], [接触角 $alpha = 15 degree$(`C`)/$25 degree$(`AC`)/$40 degree$(`B`)；须成对对称安装],
    [3], [圆锥滚子轴承], [$F_r + F_a$], [承载能力高于角接触球轴承，内外圈可分离；须成对安装；用于中低速重载],
    [N], [圆柱滚子轴承], [$F_r$], [内外圈可相对轴向游动，用于热伸长补偿；不能受轴向力],
    [5], [推力球轴承], [$F_a$], [不能受径向力；高速时离心力大，需加预载],
    [1/2], [调心球/调心滚子轴承], [$F_r$ + 小 $F_a$], [外圈外球面，可自动调心，允许内、外圈轴线偏斜 $2 tilde 3 degree$；用于轴刚度差、对中不良],
  ),
  caption: [常用滚动轴承类型与特点],
)

=== 滚动轴承的代号

滚动轴承代号由*前置代号 + 基本代号 + 后置代号*组成，其中基本代号最关键，从右往左：

#figure(
  md-table(
    (2.6cm, 9.6cm),
    ([位置（从右起）], [含义]),
    [第 1 位（内径代号）], [$00 = 10$ mm，$01 = 12$，$02 = 15$，$03 = 17$；$>= 04$ 时内径 = 代号 $times 5$（如 $04 arrow.r 20$ mm，$08 arrow.r 40$ mm）；$< 10$ 或 $22/28/32$ 等特殊值直接标注或加斜杠],
    [第 3 位（直径系列）], [同一内径下不同的外径/宽度，代号 $7/8/9$ 超轻，$0/1$ 特轻，$2$ 轻，$3$ 中，$4$ 重],
    [第 4 位（宽度系列）], [同一内径外径下不同宽度，$0$ 为正常宽度，常省略],
    [第 5 位（类型代号）], [$6$ 深沟球、$7$ 角接触球、$3$ 圆锥滚子、$N$ 圆柱滚子、$5$ 推力球、$1/2$ 调心等],
  ),
  caption: [基本代号的构成（从右往左读）],
)

后置代号常见：接触角 `C`/`AC`/`B`、密封防尘 `RS`/`Z`、公差等级 `P0`（省略）/`P6`/`P5`/`P4`/`P2`（精度依次升高）、游隙 `C1`~`C5`（`C0` 普通组省略）、成对配置 `DB`（背对背）/`DF`（面对面）/`DT`（串联）。

#example-showy(title: "代号识读")[
  + *6208*：深沟球轴承，轻系列，正常宽度，内径 $8 times 5 = 40$ mm，`P0` 级、`C0` 游隙（均省略）。
  + *7211AC/P2*：角接触球轴承，轻系列，内径 $55$ mm，接触角 $25 degree$，`P2` 级公差，`C0` 游隙。
  + *30321/P6x*：圆锥滚子轴承，中系列，内径 $105$ mm，`P6x` 级（仅用于 3 类）。
]

=== 类型选择原则

+ 高速、轻载、旋转精度高 → *球轴承*；低速、重载或有冲击 → *滚子轴承*。
+ 主要受 $F_r$ → 向心轴承；主要受 $F_a$ 且转速不高 → 推力轴承。
+ $F_r$、$F_a$ 同时较大：转速高选*角接触球轴承（7 类）*，转速低选*圆锥滚子轴承（3 类）*。
+ $F_r$ 大、$F_a$ 小 → 深沟球轴承；$F_a$ 大、$F_r$ 小 → 深沟球轴承 + 推力球轴承组合。
+ 轴刚度差、对中不良、多支点 → 调心轴承。

== 滚动轴承的受力、失效与计算准则

=== 角接触轴承的派生轴向力

角接触轴承（7 类、3 类）在径向力 $F_r$ 作用下，滚动体法向反力可分解为径向分力和轴向分力。所有受载滚动体的轴向分力之和，形成一个使内、外圈有分离趋势的*派生轴向力 $S$*。

#figure(
  image("Figure/角接触轴承派生轴向力.png", width: 80%),
  caption: [角接触轴承在径向力下产生派生轴向力 $S$],
)

派生轴向力方向：由轴承外圈的宽边指向窄边，通过内圈作用在轴上，有使内、外圈分离的趋势。因此*角接触轴承必须成对使用、反向安装*。

#key-box(title: "实际轴向力 $A$ 的判定方法")[
  + 先计算两轴承的派生轴向力 $S_1$、$S_2$，并与外加轴向载荷 $F_a$ 一起判断轴的窜动趋势；
  + *被压紧（压紧端）*的轴承：实际轴向力 $A = $ 除自身 $S$ 外其余所有轴向力的代数和；
  + *被放松（放松端）*的轴承：实际轴向力 $A = $ 自身的派生轴向力 $S$。
]

#figure(
  image("Figure/角接触轴承正装反装.png", width: 80%),
  caption: [正装（面对面）与反装（背对背）的派生轴向力方向],
)

=== 滚动体上的载荷与应力变化

+ *滚动体*：转入承载区时受力、转出时不受力，承受的是不稳定脉动循环变应力；
+ *转动套圈*：每转一圈，某一点交替进入/离开承载区，承受不稳定脉动循环变应力；
+ *固定套圈*：只有承载区那几个固定位置长期受载，承受稳定的脉动循环变应力（通常固定套圈滚道先点蚀）。

=== 失效形式与计算准则

#figure(
  md-table(
    (3.0cm, 4.6cm, 4.8cm),
    ([失效形式], [产生条件], [计算准则]),
    [*疲劳点蚀*], [转速较高、润滑安装正常时的主要失效；滚动体/滚道在脉动接触应力下产生微裂纹并扩展成点蚀], [作*疲劳寿命计算*（动载荷计算）],
    [*塑性变形*], [转速很低或缓慢摆动，受大静载/冲击，滚道出现压痕], [作*静强度计算*（基本额定静载荷 $C_0$）],
    [*磨损*], [密封不严、多尘、润滑不良，导致游隙增大、精度下降], [改善密封润滑；条件好时不作专门计算],
  ),
  caption: [滚动轴承的主要失效形式与计算准则],
)

一般轴承作疲劳寿命计算；低速或摆动轴承只作静强度校核；高速轴承除寿命外还要校验极限转速。

== 滚动轴承的动载荷与寿命计算

=== 基本额定寿命与基本额定动载荷

#definition-showy(title: "基本额定寿命 $L_{10}$")[
  同一批轴承在相同条件下运转，其中 $90%$ 的轴承在发生疲劳点蚀前所能经历的总转数（以 $10^6$ r 为单位），或一定转速下的工作小时数，称为*基本额定寿命* $L_{10}$（可靠度 $90%$）。
]

#definition-showy(title: "基本额定动载荷 $C$")[
  使轴承的基本额定寿命恰好为 $10^6$ r 时，轴承所能承受的载荷，称为*基本额定动载荷* $C$。它代表轴承的承载能力，由实验测定、查手册得到。
]

=== 当量动载荷

实际轴承可能同时受径向力 $F_r$ 和轴向力 $F_a$。为与 $C$ 的实验条件一致，把实际载荷折算成一个假想的*当量动载荷 $P$*：

#formula-showy(title: "当量动载荷")[
  $ P = f_P (X F_r + Y F_a) $

  其中：
  - $f_P$ 为载荷系数（考虑冲击、振动）；
  - $X$ 为径向动载荷系数；
  - $Y$ 为轴向动载荷系数。

  只受径向力时 $P = f_P F_r$；只受轴向力时 $P = f_P F_a$。当 $F_a/F_r <= e$ 时，取 $X = 1, Y = 0$；当 $F_a/F_r > e$ 时，取 $X < 1, Y > 0$（$e$ 为判别系数，查手册）。
]

=== 寿命公式

由大量实验，载荷与寿命的关系为 $P^epsilon L = C^epsilon times 1$（$10^6$ r）：

#formula-showy(title: "滚动轴承寿命公式")[
  $ L = (C/P)^epsilon quad ("单位：" 10^6 "r") $

  以小时计：

  $ L_h = (10^6/(60 n)) (C/P)^epsilon $

  寿命指数：*球轴承 $epsilon = 3$*；*滚子轴承 $epsilon = 10/3 approx 3.33$*。

  当工作温度 $t > 120 degree C$ 时，引入温度系数 $f_t$，用 $f_t C$ 代替 $C$。
]

#key-box(title: "设计与校核两个方向")[
  + *校核寿命*：已知 $P$、$n$、已选轴承 $C$，求 $L_h$ 与预期寿命比较；
  + *选择轴承*：给定预期寿命 $L_h$、$n$、$P$，反求所需的 $C$：

  $ C >= P/f_t root(epsilon, (60 n L_h)/10^6) $

  再按 $C$ 选轴承型号。
]

对于不稳定载荷和转速，用平均当量动载荷 $P_m = root(epsilon, sum (p_i^epsilon t_i))/sum t_i$ 与平均转速 $n_m$ 代入计算。

=== 静载荷与极限转速（自学要点）

+ *基本额定静载荷 $C_0$*：使受载最大的滚动体与滚道接触中心处产生一定接触塑性变形量时的静载荷。低速/摆动轴承按 $C_0 >= S_0 P_0$ 校核，$P_0 = max(F_r, X_0 F_r + Y_0 F_a)$。
+ *极限转速 $n_"lim"$*：轴承在一定载荷、润滑条件下达到热平衡时的最高转速。超过时的改进措施：改善润滑与冷却、提高轴承精度、适当加大游隙、改用更高级的保持架材料。

== 滚动轴承的组合结构设计

=== 支承的结构型式

#figure(
  md-table(
    (3.4cm, 5.4cm, 3.6cm),
    ([型式], [结构], [适用]),
    [两端固定（双支点各单向固定）], [两端轴承各限制一个方向的轴向移动，留出少量热膨胀间隙], [跨距小 $L < 350$ mm、温升不大的轴],
    [一端固定、一端游动], [一支承双向固定，另一支承可轴向游动；深沟球轴承游动端靠外圈与端盖间留间隙；圆柱滚子轴承游动端内外圈均双向固定], [跨距大、温变大的长轴],
    [两端游动], [两支承都游动，由另一对啮合齿轮（如人字齿轮）限制轴向位置], [人字齿轮高速主动轴],
  ),
  caption: [滚动轴承的三种支承型式],
)

#figure(
  image("Figure/滚动轴承支承-两端固定.png", width: 75%),
  caption: [两端固定支承（两端各限制一个方向）],
)

#figure(
  image("Figure/一端固定一端游动支承.png", width: 75%),
  caption: [一端固定、一端游动（长轴、温变大）],
)

=== 轴向固定

+ *内圈与轴*：一端靠轴肩，另一端用轴用弹性挡圈、轴端挡圈、圆螺母+止动垫圈、紧定套等固定；
+ *外圈与座孔*：靠座孔凸肩、轴承端盖、孔用弹性挡圈、止动环、螺纹环、套杯等固定。

=== 配合

滚动轴承是标准件：
+ *内圈与轴*采用*基孔制*（轴承内孔为基准孔，公差带在零线下方，与普通基孔制不同），常用轴公差 js6/j6/k6/m6/n6；
+ *外圈与座孔*采用*基轴制*，常用孔公差 H7/JS7/J7 等。

配合选择原则：转动套圈（通常内圈）比固定套圈（外圈）紧；高速、重载、冲击、振动、旋转精度要求高时取较紧配合；游动套圈、常拆卸轴承取较松配合。

=== 预紧

#definition-showy(title: "轴承预紧")[
  预紧是在安装时使滚动体与内、外圈之间产生一定的初始弹性变形，以消除游隙。其目的是：提高旋转精度、增加支承刚度、减小振动和噪声。
]

常用预紧方法：用不同长度的间隔套（隔套）预紧；夹紧一对磨窄了滚道的角接触/圆锥滚子轴承；用弹簧恒定预紧。

=== 装拆、润滑与密封

+ *装拆*：压力应直接加在配合较紧的套圈上，#text(fill: red)[不允许通过滚动体传递装拆力]，禁止用手锤直接敲击内外圈。
+ *润滑*：脂润滑——承载大、不易流失、密封简单，用于不常加油、转速不高处；油润滑——冷却效果好，用于高速，方式有油浴、飞溅、滴油、喷油、油雾。
+ *密封*：接触式（毡圈、橡胶油封）——密封可靠但有摩擦，适于低速；非接触式（油沟、甩油环、曲路/迷宫密封）——无磨损，适于高速；组合式密封用于要求高的场合。

#heading(level: 2, numbering: none, outlined: true)[本章重点]

+ 滚动轴承四大组成（内圈、外圈、滚动体、保持架）及球/滚子轴承的特点对比；
+ 接触角 $alpha$ 的含义，以及 6、7、3、N、5、1/2 类轴承的承载特点与代号；
+ 基本代号从右往左读：内径（$>= 04$ 乘 5）、直径系列、宽度系列、类型；后置代号 `C`/`AC`/`B`、`P0`~`P2`、`C0`~`C5`；
+ 角接触轴承的派生轴向力 $S$、"压紧端/放松端"实际轴向力 $A$ 的判定；
+ 失效形式：疲劳点蚀（寿命计算）、塑性变形（静强度）、磨损；
+ 寿命公式 $L_h = (10^6/(60 n))(C/(f_P(X F_r + Y F_a)))^epsilon$，球 $epsilon = 3$、滚子 $epsilon = 10/3$；
+ 三种支承型式（两端固定、一端固定一端游动、两端游动）及适用；
+ 内圈基孔制、外圈基轴制；预紧的目的；装拆不能通过滚动体传力。

// ---- 第十、十二~十四章完 ----
