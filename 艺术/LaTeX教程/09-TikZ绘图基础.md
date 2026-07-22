# 09 · TikZ 绘图基础

## 9.1 TikZ 概述

TikZ（TikZ ist kein Zeichenprogramm —— "TikZ 不是绘图程序"）是 Till Tantau 开发的 LaTeX 矢量绘图宏包，随 PGF（Portable Graphics Format）底层系统一起发布。TikZ 允许用户在 LaTeX 文档中直接用代码描述图形，与文档中的字体和数学符号完美统一。

```latex
\usepackage{tikz}
\usetikzlibrary{arrows.meta, shapes, positioning, calc}
```

TikZ 有两种使用方式：`\tikz{...}` 命令和 `tikzpicture` 环境。后者更适合复杂图形。

引用：Till Tantau, *The TikZ & PGF Manual*（CTAN 文档，最新版为 3.1.10）；刘海洋《LaTeX 入门》第13章。

## 9.2 坐标系统

**直角坐标**：`(x, y)`，单位默认为 cm。

**极坐标**：`(angle:radius)`，如 `(30:2cm)`。

**相对坐标**：

- `++(dx,dy)`：相对前一点偏移，并更新当前点
- `+(dx,dy)`：相对前一点偏移，不更新当前点

```latex
\draw (0,0) -- ++(1,0) -- ++(0,1);   % 绘制 L 形折线
\draw (0,0) -- +(1,0) -- +(1,1);     % 两条线段从同一点出发
```

**交点坐标系**：`(A |- B)` 表示 A 的 x 坐标与 B 的 y 坐标的交点。

**节点坐标系**：`(node.anchor)` 如 `(A.north)`、`(B.south east)`。

## 9.3 基本绘图命令

```latex
\begin{tikzpicture}
  % 直线
  \draw (0,0) -- (2,0);

  % 矩形
  \draw (0,0) rectangle (2,1);

  % 圆与椭圆
  \draw (0,0) circle (1);                    % 半径为 1
  \draw (0,0) ellipse (2 and 1);             % 半轴 2 和 1

  % 网格
  \draw[step=0.5] (-1,-1) grid (1,1);

  % 贝塞尔曲线
  \draw (0,0) .. controls (1,2) and (2,-1) .. (3,1);

  % 弧线
  \draw (0,0) arc (0:180:1);                 % 从 0° 到 180°，半径 1

  % 箭头
  \draw[->] (0,0) -- (2,0);
  \draw[->, >=stealth, thick] (0,0.5) -- (2,0.5);
\end{tikzpicture}
```

## 9.4 节点与标签

节点（node）是 TikZ 中最强大的元素——它可以包含任意 LaTeX 文本，并有多个可选的锚点（anchor）。

```latex
\node[draw, circle, fill=blue!20] (A) at (0,0) {A};
\node[draw, rectangle, right=1cm of A] (B) {B};
\draw[->] (A.east) -- (B.west);
```

`positioning` 库启用相对定位语法 `above/below/left/right=距离 of 节点`。

锚点包括：`north`、`south`、`east`、`west`、`north east`、`south west`、`center` 等。

**边标签**：

```latex
\draw (A) -- node[above] {边标签} (B);
\draw (A) -- node[below, sloped] {倾斜标签} (B);
```

## 9.5 颜色、填充与样式

```latex
% 颜色
\draw[color=red] (0,0) -- (1,0);
\draw[red!50!blue] (0,0) -- (1,1);     % 50%红+50%蓝混合

% 填充
\fill[fill=yellow!30] (0,0) rectangle (2,1);
\draw[fill=cyan!20, draw=blue, thick] (1,1) circle (0.5);

% 样式定义
\tikzset{
  mynode/.style={draw, circle, fill=gray!20, minimum size=1cm}
}
\node[mynode] {内容};
```

使用 `patterns` 库可添加纹理填充：`\usetikzlibrary{patterns}`，模式包括 `north west lines`、`crosshatch`、`grid` 等。

## 9.6 循环与数学运算

`\foreach` 循环大大简化重复性绘图：

```latex
\begin{tikzpicture}
  \foreach \x in {0,1,...,5}
    \draw (\x,0) circle (0.3);
\end{tikzpicture}
```

```latex
\foreach \x/\y in {0/red, 1/blue, 2/green}
  \fill[\y] (\x,0) circle (0.3);
```

数学运算：`\pgfmathparse{表达式}` 或 `\pgfmathsetmacro{\var}{表达式}`。

**函数绘图**：PGF 支持直接绘制数学函数。

```latex
\begin{tikzpicture}
  \draw[domain=-2:2, samples=100] plot (\x, {exp(-(\x)^2)});
\end{tikzpicture}
```

## 9.7 图层与范围

`scope` 环境用于局部设置：

```latex
\begin{scope}[xshift=3cm, red]
  \draw (0,0) -- (1,0);   % 红色，偏移
\end{scope}
\draw (0,0) -- (1,0);     % 黑色，未偏移
```

图层控制（background 库）：

```latex
\pgfdeclarelayer{background}
\pgfsetlayers{background,main}
\begin{pgfonlayer}{background}
  \fill[gray!10] (-1,-1) rectangle (5,3);
\end{pgfonlayer}
```

**参考资料**：
- Till Tantau, *The TikZ & PGF Manual*（包内文档，texdoc tikz 可阅读）
- 刘海洋，《LaTeX 入门》，第13章
- Stefan Kottwitz, *LaTeX Graphics with TikZ*, Packt Publishing, 2023
