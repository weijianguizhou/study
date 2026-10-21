#import "@preview/inelegant-note:0.9.1": *

// ============================================================================
//  补充盒子：模板内建了定义／定理／定律／引理等盒子，此处按同样的写法补充
//  「性质」盒（配色沿用模板中的青色 63bbd0），供各章直接调用：
//      #property-showy(title: "…")[ … ]
// ============================================================================
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
    border-color: property-sty.main-color, title-color: property-sty.main-color,
    body-color: property-sty.main-color.lighten(95%), end-symbol: none,
    head-text: property-sty.head-text + (fill: property-sty.head-color.showy),
    body-text: property-sty.body-text,
  ),
)
