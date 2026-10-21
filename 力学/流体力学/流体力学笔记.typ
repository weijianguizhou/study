#import "@preview/inelegant-note:0.9.1": *

// ----------------------------------------------------------------------------
//  字体：模板默认无衬线字体为「Source Han Sans SC（思源黑体）」，未安装时
//        逐级回退到 Noto Sans SC / 黑体；正文衬线优先思源宋体。
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
  "Noto Serif SC",
  "SimSun",
)

// ----------------------------------------------------------------------------
//  封面
// ----------------------------------------------------------------------------
#{
  show text: set text(font: my-sans)
  cover-environment(
    title: [流体力学],
    subtitle: "Fluid Mechanics · 学习笔记",
    author: "魏舟",
    // date: datetime(year: 2026, month: 10, day: 16), // 设定时间（默认今天）
    cover-image: none, // 封面图（缺省）
  )
}

#show: overall // 总体样式，不能删除，否则不能正常显示全文

// 章、节标题字体适配
#show heading: set text(font: my-sans)

#front-matter[
  #include "content/pre.typ"

  #my-outline()
] // 前辅助页环境

#show: main-matter // 正文环境，不能删除，否则不能正常显示正文

#part-page("流体力学基础") // 部分环境（后续章节可按此结构继续追加）

#include "content/ch1.typ"

#include "content/ch2.typ"

#include "content/ch3.typ"

#include "content/ch4.typ"

#appendix[
  #my-bibliography(bibliography("./refs.bib"))
] // 附录环境
