// ============================================================================
//  dvd.typ —— 基于 @preview/dvdtyp:1.0.1 的本地适配版（古典控制理论笔记专用）
//
//  与上游 dvdtyp 1.0.1 的差异（仅做必要适配，视觉风格保持一致）：
//    1. 字体：上游指定的 "New Computer Modern Sans" 本机未安装，统一替换为
//       思源黑体族（Noto Sans SC / SimHei）；正文衬线在 New Computer Modern
//       基础上补充中文字体回退（思源宋体 > Noto Serif SC > SimSun）；
//    2. 语言：lang 设为 zh，使图、表、目录等自动编号使用中文；
//    3. 环境名称汉化：定理/定义/例/证/练习 等；
//    4. 新增不编号的「要点」盒（绿色），用于各章小结。
// ============================================================================

#import "@preview/ctheorems:1.1.3": *
#import "@preview/showybox:2.0.4": showybox

#let sans-font = ("Noto Sans SC", "SimHei")
#let serif-font = ("New Computer Modern", "Source Han Serif SC", "Noto Serif SC", "SimSun")

#let colors = (
  rgb("#9E9E9E"),
  rgb("#F44336"),
  rgb("#E91E63"),
  rgb("#9C27B0"),
  rgb("#673AB7"),
  rgb("#3F51B5"),
  rgb("#2196F3"),
  rgb("#03A9F4"),
  rgb("#00BCD4"),
  rgb("#009688"),
  rgb("#4CAF50"),
  rgb("#8BC34A"),
  rgb("#CDDC39"),
  rgb("#FFEB3B"),
  rgb("#FFC107"),
  rgb("#FF9800"),
  rgb("#FF5722"),
  rgb("#795548"),
  rgb("#9E9E9E"),
)

#let dvdtyp(
  title: "",
  subtitle: "",
  author: "",
  abstract: none,
  accent: colors.at(6),
  body,
) = {
  set document(title: title)

  show: thmrules

  set page(
    numbering: "1",
    number-align: center,
    header: context {
      if here().page() == 1 {
        return
      }
      box(stroke: (bottom: 0.7pt), inset: 0.2em)[
        #text(font: sans-font)[#author #h(1fr)#title]
      ]
    },
  )

  set heading(numbering: "1.")
  show heading: it => {
    set text(font: sans-font)
    set par(first-line-indent: 0em)

    if it.numbering != none {
      text(accent, weight: 500)[#sym.section]

      text(accent)[#counter(heading).display() ]
    }
    it.body
  }

  set text(font: serif-font, lang: "zh")

  show math.equation: set text(weight: 400)

  // Title row.
  align(center)[
    #set text(font: sans-font)
    #block(text(weight: 700, 25pt, title))
    #v(0.4em, weak: true)
    #if subtitle != none [#text(18pt, weight: 500)[#subtitle]]
    #v(0.3em, weak: true)
    #if author != none [#text(14pt)[by #author]]
  ]

  if abstract != none [#align(center)[#abstract]]

  set outline(indent: 1em)

  show outline: set heading(numbering: none)
  show outline: set par(first-line-indent: 0em)

  show outline.entry.where(level: 1): it => {
    text(font: sans-font, accent)[#strong[#it]]
  }
  show outline.entry: it => {
    text(font: sans-font, accent)[#it]
  }

  // Main body.
  set par(
    justify: true,
    first-line-indent: 1em,
  )

  body
}

#let thmtitle(t, color: rgb("#000000")) = {
  text(font: sans-font, weight: "semibold", fill: color)[#t]
}
#let thmname(t, color: rgb("#000000")) = {
  text(font: sans-font, fill: color)[(#t)]
}

#let thmtext(t, color: rgb("#000000")) = {
  let a = t.children
  if (a.at(0) == [ ]) {
    a.remove(0)
  }
  t = a.join()

  text(font: serif-font, fill: color)[#t]
}

#let thmbase(
  identifier,
  head,
  ..blockargs,
  supplement: auto,
  padding: (top: 0em, bottom: 0em),
  namefmt: x => [(#x)],
  titlefmt: strong,
  bodyfmt: x => x,
  separator: [#h(0.1em).#h(0.2em) \ ],
  base: "heading",
  base-level: none,
) = {
  if supplement == auto {
    supplement = head
  }
  let boxfmt(name, number, body, title: auto, ..blockargs_individual) = {
    if not name == none {
      name = [ #namefmt(name)]
    } else {
      name = []
    }
    if title == auto {
      title = head
    }
    if not number == none {
      title += " " + number
    }
    title = titlefmt(title)
    body = bodyfmt(body)
    pad(
      ..padding,
      showybox(
        width: 100%,
        radius: 0.3em,
        breakable: true,
        padding: (top: 0em, bottom: 0em),
        ..blockargs.named(),
        ..blockargs_individual.named(),
        [#title#name#titlefmt(separator)#body],
      ),
    )
  }

  let auxthmenv = thmenv(
    identifier,
    base,
    base-level,
    boxfmt,
  ).with(supplement: supplement)

  return auxthmenv.with(numbering: "1.1")
}

#let styled-thmbase = thmbase.with(titlefmt: thmtitle, namefmt: thmname, bodyfmt: thmtext)

#let builder-thmbox(color: rgb("#000000"), ..builderargs) = styled-thmbase.with(
  titlefmt: thmtitle.with(color: color.darken(30%)),
  bodyfmt: thmtext.with(color: color.darken(70%)),
  namefmt: thmname.with(color: color.darken(30%)),
  frame: (
    body-color: color.lighten(92%),
    border-color: color.darken(10%),
    thickness: 1.5pt,
    inset: 1.2em,
    radius: 0.3em,
  ),
  ..builderargs,
)

#let builder-thmline(color: rgb("#000000"), ..builderargs) = styled-thmbase.with(
  titlefmt: thmtitle.with(color: color.darken(30%)),
  bodyfmt: thmtext.with(color: color.darken(70%)),
  namefmt: thmname.with(color: color.darken(30%)),
  frame: (
    body-color: color.lighten(92%),
    border-color: color.darken(10%),
    thickness: (left: 2pt),
    inset: 1.2em,
    radius: 0em,
  ),
  ..builderargs,
)

#let problem-style = builder-thmbox(color: colors.at(16), shadow: (offset: (x: 2pt, y: 2pt), color: luma(70%)))

// 练习：不编号，出现位置灵活
#let problem = problem-style("problem", "练习").with(numbering: none)

#let theorem-style = builder-thmbox(color: colors.at(6), shadow: (offset: (x: 3pt, y: 3pt), color: luma(70%)))

#let theorem = theorem-style("theorem", "定理")

#let lemma = theorem-style("lemma", "引理")
#let corollary = theorem-style("corollary", "推论")

#let definition-style = builder-thmline(color: colors.at(8))

#let definition = definition-style("definition", "定义")
#let proposition = definition-style("proposition", "命题")
#let remark = definition-style("remark", "注")
#let observation = definition-style("observation", "观察")

#let example-style = builder-thmline(color: colors.at(16))

#let example = example-style("example", "例").with(numbering: none)

// 要点：不编号，绿色框，用于本章小结
// 注意：showybox 中多个未编号盒并列时，编号计数器不参与，显示稳定。
#let summary-style = builder-thmbox(color: colors.at(10))

#let summary = summary-style("summary", "要点").with(numbering: none)

#let solution(body) = {
  thmtitle[解：]
  body
}

#let proof(body, name: none) = {
  thmtitle[证明]
  if name != none {
    [ #thmname[#name]]
  }
  thmtitle[.]
  body
  h(1fr)
  $square$
}
