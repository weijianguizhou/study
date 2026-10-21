/* ============================================================================
 *  数字电路 · 学习笔记
 *  模板：inelegant-note 0.9.1（MIT，作者 Type；本地副本见 library/）
 *        字体与版式配置见 custom/parameter.typ（正文 SimSun、标题 SimHei）
 *  内容：第一章 数制与 BCD 码、第二章 布尔代数、第三章 组合逻辑电路基础、
 *        第四章 时序逻辑电路引论、第五章 时序逻辑电路的分析与设计
 *
 *  编译：typst compile 数字电路笔记.typ
 *  依赖：@preview/cuti、@preview/theorion、@preview/zebraw 等模板依赖
 *        （首次编译自动下载）
 * ============================================================================ */

#import "library/template.typ": *

// ----------------------------------------------------------------------------
//  封面
// ----------------------------------------------------------------------------
#cover-environment(
  title: [数字电路],
  subtitle: "Digital Circuits · 学习笔记",
  author: "魏舟",
  // date: datetime(year: 2026, month: 10, day: 18), // 默认今天
  cover-image: none, // 封面图（缺省）
)

#show: overall // 总体样式，不能删除

#front-matter[
  #include "content/pre.typ"

  #my-outline()
]

#show: main-matter // 正文环境，不能删除

#part-page("数字电路基础") // 部分环境

#include "content/ch1.typ"

#include "content/ch2.typ"

#include "content/ch3.typ"

#part-page("时序逻辑电路")

#include "content/ch4.typ"

#include "content/ch5.typ"
