#import "../library/template.typ": *
#import "boxes.typ": md-table, warn, property-showy, kmap, kmap-blue, kmap-red, kmap-orange, kmap-green

// ============================================================================
//  第二章 布尔代数
// ============================================================================

= 布尔代数

数字电路的基础为逻辑代数，由英国数学家 George Boole 在 1847 年提出，逻辑代数也称布尔代数。

== 基本逻辑运算

在逻辑代数中，变量常用字母 $A, B, C, dots.c, Y, Z$、$a, b, c, dots.c, x, y, z$ 等表示，变量的取值只能是“0”或“1”。

逻辑代数中只有三种基本逻辑运算，即“与”、“或”、“非”。

=== 与逻辑运算

#definition-showy(title: "与逻辑运算")[
  只有决定一事件的*全部条件*都具备时，这件事才成立；如果有一个或一个以上条件不具备，则这件事就不成立。这样的因果关系称为“与”逻辑关系，其函数式为 $F = A dot B = A B$。

  与门逻辑功能概括：#warn[有“0”出“0”，全“1”出“1”]。
]

与门逻辑符号如下：

#figure(
  image("../Figure/与逻辑电路.png", width: 30%),
  caption: [与门逻辑符号],
)

与逻辑真值表如下：

#figure(
  md-table(
    (auto, auto, auto),
    ([$A$], [$B$], [$F = A B$]),
    [0], [0], [0],
    [0], [1], [0],
    [1], [0], [0],
    [1], [1], [1],
  ),
  caption: [与逻辑真值表],
)

=== 或逻辑运算

#definition-showy(title: "或逻辑运算")[
  在决定一事件的各种条件中，只要有一个或一个以上条件具备时，这件事就成立；*只有*所有的条件*都不具备*时，这件事才*不成立*。这样的因果关系称为“或”逻辑关系，其函数式为 $F = A + B$。

  或门逻辑功能概括：#warn[有“1”出“1”，全“0”出“0”]。
]

或门逻辑符号如下：

#figure(
  image("../Figure/或逻辑电路.png", width: 32%),
  caption: [或门逻辑符号],
)

或逻辑真值表如下：

#figure(
  md-table(
    (auto, auto, auto),
    ([$A$], [$B$], [$F = A + B$]),
    [0], [0], [0],
    [0], [1], [1],
    [1], [0], [1],
    [1], [1], [1],
  ),
  caption: [或逻辑真值表],
)

#my-notebox-rainbow(title: "注意")[
  与门和或门均可以有多个输入端。
]

=== 非逻辑运算

#definition-showy(title: "非逻辑运算")[
  假定事件 $F$ 成立与否同条件 $A$ 的具备与否有关：若 $A$ 具备，则 $F$ 不成立；若 $A$ 不具备，则 $F$ 成立。$F$ 和 $A$ 之间的这种因果关系称为“非”逻辑关系，其函数式为 $F = overline(A)$。
]

非门逻辑符号如下：

#figure(
  image("../Figure/非逻辑电路.png", width: 30%),
  caption: [非门逻辑符号],
)

非逻辑真值表如下：

#figure(
  md-table(
    (auto, auto),
    ([$A$], [$F = overline(A)$]),
    [0], [1],
    [1], [0],
  ),
  caption: [非逻辑真值表],
)

== 复合逻辑运算

=== 与非逻辑

与非逻辑由与逻辑和非逻辑组合而成，函数式为 $F = overline(A dot B) = overline(A B)$。

#figure(
  image("../Figure/与非逻辑电路.png", width: 30%),
  caption: [与非门逻辑符号],
)

与非逻辑真值表如下：

#figure(
  md-table(
    (auto, auto, auto),
    ([$A$], [$B$], [$F = overline(A B)$]),
    [0], [0], [1],
    [0], [1], [1],
    [1], [0], [1],
    [1], [1], [0],
  ),
  caption: [与非逻辑真值表],
)

=== 或非逻辑

或非逻辑由或逻辑和非逻辑组合而成，函数式为 $F = overline(A + B)$。

#figure(
  image("../Figure/或非逻辑电路.png", width: 32%),
  caption: [或非门逻辑符号],
)

或非逻辑真值表如下：

#figure(
  md-table(
    (auto, auto, auto),
    ([$A$], [$B$], [$F = overline(A + B)$]),
    [0], [0], [1],
    [0], [1], [0],
    [1], [0], [0],
    [1], [1], [0],
  ),
  caption: [或非逻辑真值表],
)

=== 与或非逻辑

与或非逻辑由与、或、非三种逻辑组合而成，函数式为 $F = overline(A B + C D)$。

#figure(
  image("../Figure/与或非门逻辑符号.png", width: 42%),
  caption: [与或非门逻辑符号],
)

与或非逻辑真值表如下：

#figure(
  md-table(
    (auto, auto, auto, auto, auto),
    ([$A$], [$B$], [$C$], [$D$], [$F = overline(A B + C D)$]),
    [0], [0], [0], [0], [1],
    [0], [0], [0], [1], [1],
    [0], [0], [1], [0], [1],
    [0], [0], [1], [1], [0],
    [0], [1], [0], [0], [1],
    [0], [1], [0], [1], [1],
    [0], [1], [1], [0], [1],
    [0], [1], [1], [1], [0],
    [1], [0], [0], [0], [1],
    [1], [0], [0], [1], [1],
    [1], [0], [1], [0], [1],
    [1], [0], [1], [1], [0],
    [1], [1], [0], [0], [0],
    [1], [1], [0], [1], [0],
    [1], [1], [1], [0], [0],
    [1], [1], [1], [1], [0],
  ),
  caption: [与或非逻辑真值表],
)

=== 异或逻辑

异或逻辑的函数式为 $F = overline(A) B + A overline(B) = A ⊕ B$，口诀：#warn[相同得“0”，相异得“1”]。

#figure(
  image("../Figure/异或逻辑电路.png", width: 32%),
  caption: [异或门逻辑符号],
)

异或逻辑真值表如下：

#figure(
  md-table(
    (auto, auto, auto),
    ([$A$], [$B$], [$F = A ⊕ B$]),
    [0], [0], [0],
    [0], [1], [1],
    [1], [0], [1],
    [1], [1], [0],
  ),
  caption: [异或逻辑真值表],
)

=== 同或逻辑

同或逻辑的函数式为 $F = overline(A) overline(B) + A B = A ⊙ B$，口诀：#warn[相同得“1”，相异得“0”]。

同或和异或互为反函数，即

$ A ⊕ B = overline(A ⊙ B) $

#figure(
  image("../Figure/同或逻辑电路.png", width: 32%),
  caption: [同或门逻辑符号],
)

同或逻辑真值表如下：

#figure(
  md-table(
    (auto, auto, auto),
    ([$A$], [$B$], [$F = A ⊙ B$]),
    [0], [0], [1],
    [0], [1], [0],
    [1], [0], [0],
    [1], [1], [1],
  ),
  caption: [同或逻辑真值表],
)

== 逻辑电平及正、负逻辑

门电路的输入、输出为二值信号，用“0”和“1”表示，这里的“0”、“1”一般用两个不同电平值来表示。

#definition-showy(title: "正逻辑与负逻辑")[
  - *正逻辑*：若用高电平 $V_H$ 表示逻辑“1”，用低电平 $V_L$ 表示逻辑“0”，则称为正逻辑约定，简称正逻辑；
  - *负逻辑*：若用高电平 $V_H$ 表示逻辑“0”，用低电平 $V_L$ 表示逻辑“1”，则称为负逻辑约定，简称负逻辑。

  一般采取正逻辑表示。
]

#my-notebox-rainbow(title: "注意")[
  对一个特定的逻辑门，采用不同的逻辑表示时，其门的名称也就不同。
]

== 基本定律和规则

=== 逻辑函数的相等

设有两个逻辑函数

$ F_1 = f_1 (A_1, A_2, dots.c, A_n), quad F_2 = f_2 (A_1, A_2, dots.c, A_n) $

如果对于 $A_1, A_2, dots.c, A_n$ 的任何一组取值（共 $2^n$ 组），$F_1$ 和 $F_2$ 均相等，则称 $F_1$ 和 $F_2$ 相等。

因此，如两个函数的真值表相等，则这两个函数一定相等。

=== 基本定律

#figure(
  md-table(
    (auto, auto, auto),
    ([定律], [与形式], [或形式]),
    [① 0-1 律], [$A dot 0 = 0$], [$A + 1 = 1$],
    [② 自等律], [$A dot 1 = A$], [$A + 0 = A$],
    [③ 重叠律], [$A dot A = A$], [$A + A = A$],
    [④ 互补律], [$A dot overline(A) = 0$], [$A + overline(A) = 1$],
    [⑤ 交换律], [$A dot B = B dot A$], [$A + B = B + A$],
    [⑥ 结合律], [$A (B C) = (A B) C$], [$A + (B + C) = (A + B) + C$],
    [⑦ 分配律], [$A (B + C) = A B + A C$], [$A + B C = (A + B)(A + C)$],
    [⑧ 反演律], [$overline(A + B) = overline(A) dot overline(B)$], [$overline(A B) = overline(A) + overline(B)$],
  ),
  caption: [逻辑代数的基本定律],
)<tab-laws>

反演律也称*德·摩根定理*，是一个非常有用的定理。

=== 逻辑代数的三条规则

==== 代入规则

任何一个含有变量 $x$ 的等式，如果将所有出现 $x$ 的位置，都用一个逻辑函数式 $F$ 代替，则等式仍然成立。

==== 反演规则

设 $F$ 为任意逻辑表达式，若将 $F$ 中所有运算符、常量及变量作如下变换：

#figure(
  image("../Figure/反函数定义_白底.png", width: 75%),
  caption: [反函数的变换规则],
)

则所得新的逻辑式即为 $F$ 的反函数，记为 $overline(F)$。

*注意*：

+ 保持原式运算的优先次序；
+ 原式中的不属于单变量上的非号不变。

==== 对偶规则

设 $F$ 为任意逻辑表达式，若将 $F$ 中所有运算符和常量作如下变换：

#figure(
  image("../Figure/对偶式定义_白底.png", width: 40%),
  caption: [对偶式的变换规则],
)

则所得新的逻辑表达式即为 $F$ 的对偶式，记为 $F'$。

== 常用公式

=== 消去律

#theorem-showy(title: "消去律")[
  $ A B + A overline(B) = A $
]

#proof[
  $ A B + A overline(B) = A (B + overline(B)) = A dot 1 = A \
    arrow.r.long^(#text(size: .75em)[对偶关系]) (A + B)(A + overline(B)) = A $
]

=== 吸收律1

#theorem-showy(title: "吸收律1")[
  $ A + A B = A $
]

#proof[
  $ A + A B = A (1 + B) = A dot 1 = A \
    arrow.r.long^(#text(size: .75em)[对偶关系]) A (A + B) = A $
]

=== 吸收律2

#theorem-showy(title: "吸收律2")[
  $ A + overline(A) B = A + B $
]

#proof[
  $ A + overline(A) B = (A + overline(A))(A + B) = 1 dot (A + B) \
    arrow.r.long^(#text(size: .75em)[对偶关系]) A (overline(A) + B) = A B \
    = A + B $
]

=== 包含律

#theorem-showy(title: "包含律")[
  $ A B + overline(A) C + B C = A B + overline(A) C $
]

#proof[
  $ A B + overline(A) C + B C &= A B + overline(A) C + (A + overline(A)) B C \
    &= A B + overline(A) C + A B C + overline(A) B C \
    &= A B (1 + C) + overline(A) C (1 + B) $

  由对偶关系，可得

  $ (A + B)(overline(A) + C)(B + C) = (A + B)(overline(A) + C) $
]

=== 关于异或和同或运算

#property-showy(title: "对偶数个变量")[
  $ A_1 ⊕ A_2 ⊕ ⋯ ⊕ A_n = overline(A_1 ⊙ A_2 ⊙ ⋯ ⊙ A_n) $
]

#property-showy(title: "对奇数个变量")[
  $ A_1 ⊕ A_2 ⊕ ⋯ ⊕ A_n = A_1 ⊙ A_2 ⊙ ⋯ ⊙ A_n $
]

异或和同或的其他性质见@tab-xor-props。

#figure(
  md-table(
    (auto, auto),
    ([异或], [同或]),
    [$A ⊕ 0 = A$], [$A ⊙ 1 = A$],
    [$A ⊕ 1 = overline(A)$], [$A ⊙ 0 = overline(A)$],
    [$A ⊕ A = 0$], [$A ⊙ A = 1$],
    [$A ⊕ (B ⊕ C) = (A ⊕ B) ⊕ C$], [$A ⊙ (B ⊙ C) = (A ⊙ B) ⊙ C$],
    [$A (B ⊕ C) = A B ⊕ A C$], [$A + (B ⊙ C) = (A + B) ⊙ (A + C)$],
  ),
  caption: [异或和同或的其他性质],
)<tab-xor-props>

== 逻辑函数的标准形式

=== 函数的“与--或”式和“或--与”式

#definition-showy(title: "“与--或”式")[
  “与--或”式指一个函数表达式中包含若干个“与”项，这些“与”项的“或”表示这个函数，如

  $ F(A, B, C, D) = A + B overline(C) + A B C overline(D) $
]

#definition-showy(title: "“或--与”式")[
  “或--与”式指一个函数表达式中包含若干个“或”项，这些“或”项的“与”表示这个函数，如

  $ F(A, B, C, D) = (A + C + D)(overline(B) + D)(A + overline(B) + overline(D)) $
]

=== 最小项

#definition-showy(title: "最小项")[
  最小项是“与”项，具有以下特点：

  + $n$ 个变量构成的每个最小项一定包含 $n$ 个因子的乘积项；
  + 每个变量必须以原变量或反变量形式作为因子出现*一次且仅一次*。

  例如：两变量有 $2^2 = 4$ 个最小项：$A overline(B)$、$overline(A) B$、$overline(A) overline(B)$、$A B$；三变量有 $2^3 = 8$ 个最小项。
]

#definition-showy(title: "最小项的编号")[
  任一最小项用 $m_i$ 表示，$m$ 表示最小项，下标 $i$ 为使该最小项为 1 的变量取值所对应的等效十进制数。

  例如：使最小项 $A overline(B) C$ 为 1 的取值 $A, B, C = 1, 0, 1$，二进制数 101 等效十进制数为 5，所以 $A overline(B) C = m_5$。
]

#property-showy(title: "最小项的性质")[
  + 变量任取一组值，仅有一个最小项为 1，其他最小项为零；
  + $n$ 变量的全体最小项之和为 1；
  + 不同的最小项相与，结果为 0；
  + 相邻最小项相“或”可以合并成一项，并消去一个变量因子。
]

#definition-showy(title: "最小项相邻")[
  两最小项如仅有一个变量因子不同，其他变量均相同，则称这两个最小项相邻。例如 $overline(A) B C + A B C = B C$。任一 $n$ 变量的最小项，必定和其他 $n$ 个不同最小项相邻。
]

=== 最大项

#definition-showy(title: "最大项")[
  最大项是“或”项，具有以下特点：

  + 每个最大项一定包含 $n$ 个因子的“或”项；
  + 每个变量必须以原变量或反变量形式出现*一次且仅一次*。

  例如：两变量有 $A + B$、$A + overline(B)$、$overline(A) + B$、$overline(A) overline(B)$ 四个最大项。
]

#definition-showy(title: "最大项的编号")[
  任一最大项用 $M_i$ 表示，下标 $i$ 为使该最大项为*0*的变量取值所对应的等效十进制数。

  例如：使最大项 $overline(A) + B + C$ 为 0 的取值为 $A, B, C = 1, 0, 0$，二进制数 100 等效十进制数为 4，所以 $overline(A) + B + C = M_4$。
]

#property-showy(title: "最大项的性质")[
  + 变量任取一组值，仅有一个最大项为 0，其他最大项为 1；
  + $n$ 变量的全体最大项之积为 0；
  + 不同的最大项相或，结果为 1；
  + 两相邻的最大项相“与”可以合并成一项，并消去一个变量因子。例如 $(A + B + overline(C))(A + B + C) = A + B$。任一 $n$ 变量的最大项，必定和其他 $n$ 个不同最大项相邻。
]

=== 最小项和最大项的关系

#theorem-showy(title: "最小项与最大项的关系")[
  编号下标相同的最小项和最大项互为反函数，即

  $ M_i = overline(m_i) $
]

=== 逻辑函数的最小项之和形式

#theorem-showy(title: "最小项之和形式")[
  最小项之和式为“与或”式，任一逻辑函数都可以表达为最小项之和的形式，而且是*唯一*的。例如

  $ F(A, B, C) = overline(A) B overline(C) + A overline(B) overline(C) + A B overline(C) = Sigma m(2, 4, 6) $
]

#example-showy[
  将 $F(A, B, C) = A B + overline(A) C$ 化为最小项之和的形式：

  $ F(A, B, C) &= A B + overline(A) C \
    &= A B (C + overline(C)) + overline(A) C (B + overline(B)) \
    &= A B C + A B overline(C) + overline(A) B C + overline(A) overline(B) C \
    &= Sigma m(1, 3, 6, 7) $
]

=== 逻辑函数的最大项之积形式

#theorem-showy(title: "最大项之积形式")[
  最大项之积式为“或与”式，任一逻辑函数都可以表达为最大项之积的形式，而且是*唯一*的。例如

  $ F(A, B, C) = (A + B + C)(A + overline(B) + C)(overline(A) + B + C) = Pi M(0, 2, 4) $
]

#example-showy[
  将 $F(A, B, C) = (overline(A) + C)(B + overline(C))$ 化为最大项之积的形式：

  $ F(A, B, C) &= (overline(A) + C)(B + overline(C)) \
    &= (overline(A) + C + B overline(B))(B + overline(C) + A overline(A)) \
    &= (overline(A) + B + C)(overline(A) + overline(B) + C)(A + B + overline(C))(overline(A) + B + overline(C)) \
    &= Pi M(1, 4, 5, 6) $
]

=== 两种标准形式之间的关系

#theorem-showy(title: "两种标准形式之间的关系")[
  若 $F = Sigma m_i$，则

  $ overline(F) = sum_(j != i) m_j = product_(j != i) M_j $
]

#example-showy[
  $ F(A, B, C) = Sigma (1, 3, 4, 6, 7) = Pi (0, 2, 5) $
]

== 真值表与逻辑表达式

真值表与逻辑表达式都是表示逻辑函数的方法。

=== 由逻辑函数式列真值表

#example-showy[
  试列出逻辑函数式 $F(A, B, C) = A B + B C$ 的真值表。

  *方法一*（直接代入法）：把 $A, B, C$ 三个变量所有取值的组合分别代入函数式，算出函数值，填进真值表，适用于变量较少的情况。

  *方法二*：先将函数式 $F$ 表示为最小项之和的形式：

  $ F(A, B, C) &= A B + B C \
    &= A B (C + overline(C)) + B C (A + overline(A)) \
    &= A B C + A B overline(C) + overline(A) B C \
    &= Sigma m(3, 6, 7) $

  最后根据最小项的性质，在真值表中对应于 $A B C$ 取值为 011、110、111 处填“1”，其它位置填“0”，即

  #figure(
    md-table(
      (auto, auto, auto, auto),
      ([$A$], [$B$], [$C$], [$F$]),
      [0], [0], [0], [0],
      [0], [0], [1], [0],
      [0], [1], [0], [0],
      [0], [1], [1], [1],
      [1], [0], [0], [0],
      [1], [0], [1], [0],
      [1], [1], [0], [1],
      [1], [1], [1], [1],
    ),
    caption: [$F(A, B, C) = A B + B C$ 的真值表],
  )

  *方法三*：根据函数式 $F$ 的含义，直接填表。
]

=== 由真值表写逻辑函数式

#my-notebox-rainbow(title: "方法", icon-name: "light-bulb")[
  根据最小项的性质，用观察法，可直接从真值表写出函数的最小项之和表达式。
]

== 逻辑函数的化简

#my-notebox-rainbow(title: "最简与或表达式的标准", icon-name: "light-bulb")[
  + 所得与或表达式中，乘积项（与项）数目最少；
  + 每个乘积项中所含的变量数最少。
]

=== 公式法

公式法化简就是反复运用逻辑代数公式消去多余的乘积项和每个乘积项中多余的因子，使函数式符合最简标准。常用方法见@tab-formula-method。

#figure(
  {
    set text(size: 9.5pt)
    md-table(
      (auto, auto, 1fr),
      ([方法], [利用公式], [例]),
      [*并项法*], [$A B + A overline(B) = A$],
      [$F = overline(A) overline(B) C + overline(A) B C + A overline(B) C + A B C$ \
        $= (overline(A) overline(B) + overline(A) B) C + (A overline(B) + A B) C$ \
        $= overline(A) C + A C = C$],
      [*吸收法*], [$A + A B = A$], [$F = A overline(B) + A overline(B) C = A overline(B)$],
      [*消项法*], [$A B + overline(A) C + B C = A B + overline(A) C$], [$F = A B + overline(A) C + B C = A B + overline(A) C$],
      [*消因子法*], [$A + overline(A) B = A + B$], [$F = A + overline(A) B C = A + B C$],
      [*配项法*], [$A + overline(A) = 1$、$A dot 1 = A$],
      [$F = A B + overline(A) C + B C$ \
        $= A B + overline(A) C + (A + overline(A)) B C$ \
        $= A B (1 + C) + overline(A) C (1 + B) = A B + overline(A) C$],
    )
  },
  caption: [公式法化简的常用方法],
)<tab-formula-method>

#my-notebox-rainbow(title: "注意")[
  对比较复杂的函数式，要求熟练掌握上述方法，才能把函数化成最简。
]

=== 卡诺图法

将逻辑函数用*卡诺图*表示，然后在卡诺图上进行化简。卡诺图是一种包含小方块的几何图形，每个小方块称为一个*单元*，每个单元对应一个最小项，两个相邻的最小项在卡诺图中也必须相邻。

==== 卡诺图的构成

- 相邻的含义：① *几何相邻性*（左右紧挨或者上下相接）；② *对称相邻性*（图形中对称位置的单元是相邻的）；
- 行列标号按*循环码*（格雷码）排列。

三变量卡诺图与四变量卡诺图分别见@fig-kmap3 和@fig-kmap4。

#figure(
  kmap(
    vars: [$A backslash B C$],
    cols: ($00$, $01$, $11$, $10$),
    rows: ($0$, $1$),
    cells: (
      ($m_0$, $m_1$, $m_3$, $m_2$),
      ($m_4$, $m_5$, $m_7$, $m_6$),
    ),
  ),
  caption: [三变量卡诺图],
)<fig-kmap3>

#figure(
  kmap(
    vars: [$A B backslash C D$],
    cols: ($00$, $01$, $11$, $10$),
    rows: ($00$, $01$, $11$, $10$),
    cells: (
      ($m_0$, $m_1$, $m_3$, $m_2$),
      ($m_4$, $m_5$, $m_7$, $m_6$),
      ($m_(12)$, $m_(13)$, $m_(15)$, $m_(14)$),
      ($m_8$, $m_9$, $m_(11)$, $m_(10)$),
    ),
  ),
  caption: [四变量卡诺图],
)<fig-kmap4>

二变量、五变量卡诺图类似，标号同样按循环码排列。

==== 逻辑函数的卡诺图表示法

把各组变量值所对应的逻辑函数 $F$ 的值填在对应的小方格中（卡诺图实质是真值表的另一种画法）。

==== 在卡诺图上合并最小项的规则

- 任何*两个*标 1 方格相邻，可合并为 1 项，消去 1 个变量；
- 任何*四个*标 1 方格相邻，可合并为一项，消去 2 个变量（四个标 1 方格相邻的特点：① 同在一行或一列；② 同在一个田字格中）；
- 任何*八个*标 1 方格相邻，可并成一项，消去 3 个变量。

*一般规律*：在 $n$ 个变量的卡诺图中，只有 $2^i$ 个相邻的标 1 方格（必须排列成方形格或矩形格）才能圈在一起合并为一项，该项保留原来各项中 $n - i$ 个相同的变量，消去 $i$ 个不同的变量。

==== 用卡诺图化简逻辑函数

最简标准：项数最少（圈数最少）；每项中变量数最少（圈尽可能大）。

#example-showy[
  将 $F(A, B, C) = Sigma m(3, 4, 5, 6, 7)$ 化为最简与或式。

  #figure(
    kmap(
      vars: [$A backslash B C$],
      cols: ($00$, $01$, $11$, $10$),
      rows: ($0$, $1$),
      cells: (
        ($0$, $0$, $1$, $0$),
        ($1$, $1$, $1$, $1$),
      ),
      groups: (
        (rows: (1, 1), cols: (0, 3), color: kmap-blue),
        (rows: (0, 1), cols: (2, 2), color: kmap-red),
      ),
    ),
    caption: [例 1 的卡诺图及圈法],
  )

  #solution[
    将 $A = 1$ 的 4 个标 1 方格圈为一组（图中蓝色圈），合并为乘积项 $A$；将 $B C = 11$ 的 $m_3$、$m_7$ 两个标 1 方格圈为一组（图中红色圈），合并为乘积项 $B C$。两圈已覆盖全部标 1 方格，故最简与或式为

    $ F(A, B, C) = A + B C $
  ]
]

#example-showy[
  将 $F(A, B, C, D) = Sigma m(0, 1, 3, 7, 8, 10, 13)$ 化为最简与或式。

  #figure(
    kmap(
      vars: [$A B backslash C D$],
      cols: ($00$, $01$, $11$, $10$),
      rows: ($00$, $01$, $11$, $10$),
      cells: (
        ($1$, $1$, $1$, $0$),
        ($0$, $0$, $1$, $0$),
        ($0$, $1$, $0$, $0$),
        ($1$, $0$, $0$, $1$),
      ),
      groups: (
        (rows: (0, 0), cols: (0, 1), color: kmap-blue),
        (rows: (0, 1), cols: (2, 2), color: kmap-red),
        (rows: (3, 3), cols: (0, 0), color: kmap-orange),
        (rows: (3, 3), cols: (3, 3), color: kmap-orange),
        (rows: (2, 2), cols: (1, 1), color: kmap-green),
      ),
    ),
    caption: [例 2 的卡诺图及圈法],
  )

  #solution[
    先圈出孤立的标 1 方格，再圈出覆盖其余标 1 方格的最大圈：

    + $m_0, m_1$ 相邻，圈为一组（蓝色圈），合并为 $overline(A) overline(B) overline(C)$；
    + $m_3, m_7$ 相邻，圈为一组（红色圈），合并为 $overline(A) C D$；
    + $m_8, m_(10)$ 位于同一行两端、左右相邻（卷绕相邻），圈为一组（橙色圈），合并为 $A overline(B) overline(D)$；
    + $m_(13)$ 孤立，单独圈出（绿色圈），为 $A B overline(C) D$。

    将各乘积项相加，得最简与或式

    $ F(A, B, C, D) = overline(A) overline(B) overline(C) + overline(A) C D + A overline(B) overline(D) + A B overline(C) D $
  ]
]

==== 化简中注意的问题

+ 每一个标 1 的方格必须至少被圈一次；
+ 每个圈中包含的相邻小方格数必须为 2 的整数次幂；
+ 为了得到尽可能大的圈，圈与圈之间可以重叠；
+ 若某个圈中的所有标 1 方格已经完全被其他圈所覆盖，则该圈为多余的。

==== 用卡诺图求反函数的最简与或式

在卡诺图中合并标*0*方格，可得到反函数的最简与或式；常利用该方法求逻辑函数 $F$ 的最简与或非式（将 $overline(F)$ 上的非号移到右边）。

==== 复杂逻辑函数

可将函数分解成多个部分，先将每个部分分别填入各自的卡诺图，然后通过卡诺图对应方格的运算（与、或、异或等）求出函数的卡诺图，再进行化简。

==== 不完全确定的逻辑函数及其化简（无关项）

#definition-showy(title: "无关项")[
  在某些实际数字电路中，逻辑函数的输出只和一部分最小项有确定对应关系，而和余下的最小项无关；余下的最小项无论写入函数式与否都不影响电路的逻辑功能。这些最小项称为*无关项*，用字母 $d$（don't care）表示，对应的函数值记为“$times$”。
]

包含无关项的逻辑函数称为*不完全确定的逻辑函数*。利用无关项往往可以把函数化得更简单。

#example-showy(breakable: false)[
  设计一个奇偶判别电路，输入为 8421BCD 码，输入为偶数时输出 0，输入为奇数时输出 1。由于 8421BCD 码中无 $1010 ∼ 1111$ 这 6 个码，电路禁止输入这 6 个码，它们对应的最小项为无关项：

  $ F(A, B, C, D) = Sigma m(1, 3, 5, 7, 9) + Sigma d(10 ∼ 15) $

  - 若不利用无关项（将卡诺图中的 $times$ 均作 0 处理），化简结果为
    $ F(A, B, C, D) = overline(A) D + overline(B) overline(C) D $
  - 若利用无关项（将 $times$ 按化简需要处理，有的作 0、有的作 1），化简结果为 $F(A, B, C, D) = D$。
]
