# LaTeX 报错修复说明

## 文件范围

`力学/流体力学/LaTeX/` 目录下的 `main.tex` 及 `Chapter01.tex ~ Chapter12.tex`。

## 修复的错误

### 1. `\oiint` 未定义 (Undefined control sequence)

- **文件**: `Chapter01.tex` (行 226, 530, 601, 625)
- **原因**: 缺少 `esint` 宏包，`\oiint`（二重闭曲面积分符号）不在默认加载的数学宏包中。
- **修复**: 在 `main.tex` 导言区添加 `\usepackage{esint}`。

### 2. `#` 字符导致宏参数错误 (macro parameter character `#`)

- **文件**: `Chapter01.tex` (行 648-650) 及所有使用 `\begin{mycode}` 的章节
- **原因**: `mycode` 环境原定义为 `\newtcolorbox`（普通文本框），内部 `#` 被 LaTeX 当作宏参数字符处理。Python 注释中的 `#` 不能出现在非逐字环境中。
- **修复**: 将 `main.tex` 中的 `\newtcolorbox{mycode}` 改为 `\newtcblisting{mycode}`（tcolorbox 的逐字列表环境），同时将 `\tcbuselibrary{skins,breakable}` 改为 `\tcbuselibrary{skins,breakable,listings}`。

### 3. `erf` 函数未定义 (Unknown function in PGF Math)

- **文件**: `Chapter05.tex` (行 470, 474, 478)
- **原因**: TikZ 的 PGF 数学引擎不提供误差函数 `erf()`。该函数用于 Stokes 第一问题的速度剖面图（`1-erf(y/sqrt(νt))`）。
- **修复**: 在 `main.tex` 导言区添加近似声明：
  ```latex
  \pgfmathdeclarefunction{erf}{1}{%
    \pgfmathparse{tanh(1.12837916709551*#1)}%
  }
  ```
  使用 `erf(x) ≈ tanh(2x/√π)` 近似，最大误差约 0.02。

### 4. Dimension too large（三角函数参数溢出）

- **文件**: `Chapter06.tex` (行 239-241)
- **原因**: `sin(40*\t r)` 中最大参数 `40 × 7.5 × 180/π ≈ 17189°` 超过 TeX 内部维度上限（约 16384pt/°）。PGF 标准定点算法无法处理如此大的三角函数参数。
- **修复**: 将该 plot 包裹在 `\begin{scope}[fpu=true]...\end{scope}` 中，启用 PGF 浮点数引擎。

### 5. Ch09–Ch12 大量未定义颜色和样式

- **文件**: `Chapter09.tex` ~ `Chapter12.tex`（共 50+ 个未定义标识符）
- **原因**: 各章 tikzpicture 使用了 `ch09supersonic`、`ch10grid`、`ch11dns`、`ch12nnlayer` 等颜色和样式名，但从未定义。
- **涉及标识符**:

| 章节 | 未定义的颜色 | 未定义的 tikz 样式 |
|------|-------------|-------------------|
| Ch09 | `ch09supersonic`、`ch09nozzlefill`、`ch09shock` | `ch09machline`、`ch09flowline`、`ch09arc`、`ch09angle`、`ch09label`、`ch09nozzle`、`ch09throat`、`ch09dim`、`ch09fan`、`ch09wall` |
| Ch10 | `ch10final` | `ch10grid`、`ch10arrow`、`ch10label`、`ch10exact`、`ch10dissipation`、`ch10dispersion`、`ch10block` |
| Ch11 | — | `ch11dns`、`ch11label`、`ch11les`、`ch11rans`、`ch11dim`、`ch11bl`、`ch11full`、`ch11filter` |
| Ch12 | `ch12chipfill`、`ch12dropletfill`、`ch12groundfill` | `ch12nnlayera`、`ch12nnlayer`、`ch12nnout`、`ch12nnarrow`、`ch12nnphys`、`ch12physarrow`、`ch12nndata`、`ch12dataarrow`、`ch12label`、`ch12grid`、`ch12interface`、`ch12chip`、`ch12channel`、`ch12droplet`、`ch12detector`、`ch12ground`、`ch12abl`、`ch12surfacelayer`、`ch12mixedlayer`、`ch12thermal`、`ch12windprofile`、`ch12dim` |

- **修复**: 在 `main.tex` 导言区批量使用 `\definecolor` 和 `\tikzset` 为所有缺失标识符提供合理默认值。

### 6. `myenum` 环境未定义

- **文件**: `Chapter10.tex` (行 445)
- **原因**: 使用了自定义环境 `{myenum}` 作为有序列表，但未在任何位置定义。
- **修复**: 在 `main.tex` 添加 `\newenvironment{myenum}{\begin{enumerate}[label=\arabic*.]}{\end{enumerate}}`。

### 7. `\\` 在 node 中报 "Not allowed in LR mode"

- **文件**: `Chapter09.tex` (行 337)、`Chapter11.tex` (行 80, 84, 92, 95, 98)、`Chapter12.tex` (行 561)
- **原因**: `\node[style] at (x,y) {文本\\换行}` 中 `\\` 需要节点处于 paragraph 模式，但默认的 TikZ 节点是 LR 模式（单行）。
- **修复**: 给相关节点样式 (`ch09label`、`ch11label`、`ch12label`) 添加 `align=center`，使节点支持换行。

## 编译验证

修复后执行两遍 `xelatex`：

```
xelatex -interaction=nonstopmode -halt-on-error main.tex
xelatex -interaction=nonstopmode main.tex
```

输出 `Output written on main.pdf (172 pages)`，0 个 Error，仅保留一条无害的楷体粗体回退警告。
