#import "../library/template.typ": *

// ============================================================================
//  公共定义：正文强调色、补充盒子、三线表、卡诺图
//  各章通过 `#import "boxes.typ": ...` 取用。
// ============================================================================

// ----------------------------------------------------------------------------
//  配色（沿用原 LaTeX 笔记中的李思配色）
// ----------------------------------------------------------------------------
#let kmap-blue = rgb("#0000bf")
#let kmap-red = rgb("#bf0000")
#let kmap-orange = rgb("#bf6000")
#let kmap-green = rgb("#00bf00")

// 原稿中的红色强调文字
#let warn(body) = text(fill: rgb("#bf0000"), body)

// ----------------------------------------------------------------------------
//  性质盒：模板内建了定义／定理／定律等盒子，此处按同样写法补充「性质」盒，
//  配色沿用模板中的青色 63bbd0。用法：
//      #property-showy(title: "…")[ … ]
// ----------------------------------------------------------------------------
#let property-sty = (
  name: [性质],
  head-text: (size: 10.5pt, font: sans-font, weight: "regular"),
  body-text: (size: 10.5pt, font: serif-font, weight: "regular", fill: black),
  head-color: (rainbow: rgb("63bbd0"), showy: black),
  main-color: rgb("63bbd0"),
)

#let (property-counter, propertybox-showy, property-showy, show-my-property) = make-frame(
  "property",
  property-sty.name,
  inherited-levels: 1,
  render: my-fancy-box.with(
    border-color: property-sty.main-color,
    title-color: property-sty.main-color,
    body-color: property-sty.main-color.lighten(95%),
    end-symbol: none,
    head-text: property-sty.head-text + (fill: property-sty.head-color.showy),
    body-text: property-sty.body-text,
  ),
)

// ----------------------------------------------------------------------------
//  三线表
//      #md-table(
//        (auto, auto),            // 列宽
//        ([表头 1], [表头 2]),     // 表头
//        [单元], [单元], …         // 逐行排列的单元格
//      )
// ----------------------------------------------------------------------------
#let md-table(columns, head, ..rows) = table(
  columns: columns,
  stroke: none,
  inset: (x: 6pt, y: 5pt),
  align: center,
  table.hline(stroke: 0.08em),
  table.header(..head),
  table.hline(stroke: 0.05em),
  ..rows.pos(),
  table.hline(stroke: 0.08em),
)

// ----------------------------------------------------------------------------
//  卡诺图
//    vars   : 左上角变量标记，如 [$A backslash B C$]
//    cols   : 列标号（按循环码排列）
//    rows   : 行标号（按循环码排列）
//    cells  : 各行单元格内容（二维数组）
//    groups : 圈组，每项形如 (rows: (r1, r2), cols: (c1, c2), color: 颜色)，
//             其中 r、c 为数据区内的 0 基下标，区间均含端点；
//             跨边界的卷绕相邻拆成两个 group 分别绘制即可。
//  用法示例见第二章「卡诺图的构成」。
// ----------------------------------------------------------------------------
#let kmap(
  vars: none,
  cols: (),
  rows: (),
  cells: (),
  groups: (),
  cell-w: 13mm,
  cell-h: 9mm,
  label-w: 17mm,
) = {
  let n-cols = cols.len()
  let n-rows = rows.len()
  let total-w = label-w + n-cols * cell-w
  let total-h = (n-rows + 1) * cell-h
  let grid-line = 0.5pt + luma(130)

  // 单元格：以 place 绝对定位，保证圈组坐标可精确计算
  let cell-box(x, y, body, w: cell-w, h: cell-h, fill: none) = place(
    dx: x,
    dy: y,
    box(
      width: w,
      height: h,
      fill: fill,
      stroke: grid-line,
      inset: 0pt,
      align(center + horizon, body),
    ),
  )

  box(width: total-w, height: total-h)[
    // 表头（左上角变量 + 列标号）
    #cell-box(0pt, 0pt, vars, w: label-w, fill: luma(238))
    #for (j, c) in cols.enumerate() {
      cell-box(label-w + j * cell-w, 0pt, c, fill: luma(238))
    }
    // 行标号与数据
    #for (i, r) in rows.enumerate() {
      cell-box(0pt, (i + 1) * cell-h, r, w: label-w, fill: luma(238))
      for (j, c) in cells.at(i).enumerate() {
        cell-box(label-w + j * cell-w, (i + 1) * cell-h, c)
      }
    }
    // 圈组（最后绘制，盖在网格之上）
    #for g in groups {
      let (r1, r2) = g.rows
      let (c1, c2) = g.cols
      let color = g.at("color", default: kmap-blue)
      place(
        dx: label-w + c1 * cell-w + 2pt,
        dy: (r1 + 1) * cell-h + 2pt,
        rect(
          width: (c2 - c1 + 1) * cell-w - 4pt,
          height: (r2 - r1 + 1) * cell-h - 4pt,
          radius: 4pt,
          stroke: 1.1pt + color,
          fill: color.transparentize(92%),
        ),
      )
    }
  ]
}
