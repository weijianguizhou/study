# LaTeX 排版教程 · 内容索引

> 本教程系统讲解 LaTeX 排版的方方面面——从基础安装到进阶绘图与演示文稿制作。各章独立成篇，按学习路径编排。

---

## 教程结构

```
艺术/LaTeX教程/
├── 00-LaTeX教程MOC.md            ← 本文件 · 内容索引
├── 01-简介与安装.md              ← LaTeX 概述与环境配置
├── 02-文档结构与基础命令.md      ← 导言区、正文、基本语法
├── 03-文字与段落排版.md          ← 字体、段落、列表、断词
├── 04-数学公式排版.md            ← 行内/行间公式、矩阵、定理环境
├── 05-图片、表格与浮动体.md      ← graphicx、tabular、float 机制
├── 06-章节、目录与交叉引用.md    ← 文档层级、自动编号、超链接
├── 07-参考文献与BibTeX.md        ← thebibliography、BibTeX、biblatex
├── 08-自定义命令与环境.md         ← \newcommand、\newenvironment、宏编程
├── 09-TikZ绘图基础.md            ← 图形绘制、坐标系、箭头、图层
├── 10-Beamer演示文稿.md          ← 幻灯片制作、主题、动画
├── 11-编译工具链与调试.md        ← xelatex、latexmk、常见报错
└── 12-进阶技巧与资源.md          ← 宏包推荐、模板、社区
```

## 章节链接

- [[01-简介与安装|01 简介与安装]] → [[02-文档结构与基础命令|02 文档结构]] → [[03-文字与段落排版|03 文字与段落]] → [[04-数学公式排版|04 数学公式]] → [[05-图片、表格与浮动体|05 图片表格]] → [[06-章节、目录与交叉引用|06 章节目录]] → [[07-参考文献与BibTeX|07 参考文献]] → [[08-自定义命令与环境|08 自定义命令]] → [[09-TikZ绘图基础|09 TikZ 绘图]] → [[10-Beamer演示文稿|10 Beamer]] → [[11-编译工具链与调试|11 编译调试]] → [[12-进阶技巧与资源|12 进阶资源]]

## 各章概要

| 章 | 主题 | 核心内容 |
|----|------|----------|
| 01 | 简介与安装 | TeX 发行版选择（TeX Live / MiKTeX）、编辑器配置（VS Code + LaTeX Workshop）、首次编译 |
| 02 | 文档结构与基础命令 | `\documentclass`、导言区、`\begin{document}`、源文件结构、注释与空格规则 |
| 03 | 文字与段落排版 | 字体族与字号、段落控制、列表环境（itemize/enumerate/description）、断词与对齐 |
| 04 | 数学公式排版 | `$...$` 与 `\[...\]`、常用符号、矩阵、多行公式、定理环境（amsthm） |
| 05 | 图片、表格与浮动体 | `\includegraphics`、tabular/tabularx、浮动体定位、`\caption`、交叉引用 |
| 06 | 章节目录与交叉引用 | `\section` 层级体系、`\tableofcontents`、`\label`/`\ref`、`hyperref` |
| 07 | 参考文献与 BibTeX | `thebibliography` 环境、`.bib` 数据库、BibTeX 编译流程、biblatex 简介 |
| 08 | 自定义命令与环境 | `\newcommand`/`\renewcommand`、`\newenvironment`、参数与可选参数、`\def` |
| 09 | TikZ 绘图基础 | 坐标系统、`\draw` 与形状、箭头、颜色与填充、`foreach` 循环、图层管理 |
| 10 | Beamer 演示文稿 | 帧结构、主题选择、覆盖与动画、分栏与区块 |
| 11 | 编译工具链与调试 | `xelatex` 编译顺序、`latexmk` 自动化、常见报错对照表、日志分析 |
| 12 | 进阶技巧与资源 | 常用宏包索引、模板推荐、CTAN 检索、社区资源 |

---

## 核心术语速查

| 术语 | 解释 |
|------|------|
| TeX | Donald Knuth 开发的排版引擎 |
| LaTeX | Leslie Lamport 基于 TeX 开发的宏包集合 |
| 导言区（Preamble） | `\documentclass` 与 `\begin{document}` 之间的配置区域 |
| 宏包（Package） | 以 `.sty` 为扩展名的功能扩展文件，用 `\usepackage` 加载 |
| 浮动体（Float） | 图片、表格等在文档中自动定位的元素 |
| 计数器（Counter） | LaTeX 内部用于自动编号的机制（如 `section`、`figure`） |
| 盒子（Box） | LaTeX 排版的基本单元，一切内容最终被置于盒子中 |
| 胶合（Glue） | 用于控制盒子间伸缩与收缩的弹性间距 |
| 命令（Command / Macro） | 以 `\` 开头的控制序列 |
| 环境（Environment） | 以 `\begin{...}` 和 `\end{...}` 包裹的结构化区域 |
| 文档类（Document Class） | 定义文档整体格式的基础模板 |

---

> **编写说明**：本教程基于 LaTeX2ε（当前稳定版本），示例代码均经过测试。建议使用 TeX Live 2024+ 或 MiKTeX 最新版编译。
>
> 初次编写：2026-07
