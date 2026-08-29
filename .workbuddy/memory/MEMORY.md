# 项目长期约定（studynotes）

## 内容来源与整合规则
- `教材/` 目录存放教材 PDF 与 Obsidian 读书笔记（`读书笔记——第X章 xxx.md`），是**内容源**。
- 整合进 LaTeX 笔记本时：**不改动原文措辞与公式**（用户明确要求）。
  - 明显 OCR 错字（如"体职"→"体积"、"丸个"→"九个"）可直接修正；
  - 存疑的物理量（如数量级、正负号）用 `warnbox[存疑]` 框标注，不擅自改。

## LaTeX 笔记本项目结构（模板见 `模板/课程笔记/`）
- 主文件：`X笔记.tex`，`book` 文档类 + `\input{preamble}` + `\notename/\noteauthor/\notebody` 骨架 + 独立 `preamble.tex`。
- 每章单独一个 `.tex`，由主文件 `\chapter{...}\input{...}`。
- **章节文件顶部必须加** `% !TeX root = 主文件.tex`（VS Code LaTeX Workshop / TeXstudio 靠它定位主文件）。
  缺这一行时，单独编译章节会报一大堆 `Undefined control sequence` / `Environment xxx undefined` / `Missing \begin{document}`——这是假报错，不是内容问题。
- 可用环境（preamble 中 tcolorbox 定义）：`theorem/lemma/corollary`、`definition/axiom`、`proposition/property`、
  `example/exercise/longexample`、`keybox/tipbox/warnbox`（无编号）、`proof`（可选参数填标题）、`solution`、`remark`、`note`。
- 数学：`\boldsymbol{}` 粗体、`\mathrm{d}` 微分、`\oiint`（需 `esint`）。
- `preamble.sty`（仓库根）用于 Obsidian 的 Extended MathJax 插件，定义 `\oiint` 等。

## 编译
- 编译器：TeX Live 2025，位于 `D:\Latex`（`xelatex` / `latexmk` / `pdftoppm` / `pdfinfo` 均可用）。
- 命令：`latexmk -xelatex -interaction=nonstopmode <主文件>.tex`
- 验收标准：`^! ` 无输出、`Reference ... undefined` 无、`Overfull` 为 0。

## 排版坑
- 在 `proof` 环境首段混用 `\emph{中文}` + 行内数学，会触发 xeCJK 假斜体替换导致整段不断行（Overfull 可达 130pt+）。
  **用 `\textbf{}` 代替 `\emph{}` 即可消除**（中文无真斜体）。
