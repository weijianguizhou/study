# 10 · Beamer 演示文稿

## 10.1 Beamer 概述

Beamer 是 Till Tantau 开发的 LaTeX 演示文稿文档类。与 PowerPoint 或 Keynote 不同，Beamer 源文件是纯文本的 `.tex` 文件，利用 LaTeX 的排版引擎生成 PDF 演示文稿。Beamer 的优势在于：数学公式质量极高、样式统一、版本控制友好。

```latex
\documentclass{beamer}
\usetheme{Madrid}
\begin{document}

\begin{frame}{标题}
这是第一页。
\end{frame}

\end{document}
```

编译使用 `pdflatex` 或 `xelatex`。

引用：Till Tantau, *Beamer User's Guide*（CTAN 文档，`texdoc beamer` 可阅读）。

## 10.2 帧结构

Beamer 的基本单位是"帧"（frame），每一帧对应一页幻灯片。

```latex
% 基本帧
\begin{frame}{帧标题}{子标题}
  帧内容
\end{frame}

% 含自动分页的帧（内容超长时自动分页）
\begin{frame}[allowframebreaks]{参考文献}
  \bibliography{ref}
\end{frame}

% 无导航栏的帧
\begin{frame}[plain]{全屏帧}
  无顶部/底部导航
\end{frame}
```

`\frametitle` 和 `\framesubtitle` 可在帧内设置标题。

## 10.3 主题与外观

Beamer 通过主题系统控制整体外观：

**演示主题**（`\usetheme`）：

| 主题 | 风格 |
|------|------|
| `default` | 极简 |
| `Madrid` | 底部导航条，蓝灰配色 |
| `Berlin` | 顶部导航目录 |
| `Warsaw` | 类似早期 Windows 风格 |
| `Copenhagen` | 目录条清晰 |
| `AnnArbor` | 简约大气 |

**颜色主题**（`\usecolortheme`）：`dolphin`、`seahorse`、`whale`、`beetle` 等。

**字体主题**（`\usefonttheme`）：`serif`（衬线字体，适合数学）、`professionalfonts`（不覆盖字体命令）、`structurebold`。

```latex
\usetheme{Madrid}
\usecolortheme{dolphin}
\usefonttheme{professionalfonts}
```

## 10.4 覆盖与动画

覆盖（overlay）是 Beamer 最强大的功能之一，控制元素逐帧出现。

**`\pause`**：最简单的暂停命令。

```latex
\begin{frame}{逐步呈现}
  第一点 \pause
  第二点 \pause
  第三点
\end{frame}
```

**覆盖规范**：`<n>` 表示第 n 帧出现，`<n-m>` 表示第 n 到 m 帧出现。

```latex
\begin{frame}
  \only<1>{第一帧才显示}
  \visible<2-3>{第二到三帧显示}
  \uncover<4>{第四帧揭晓}
  \onslide<5->{从第五帧开始}
\end{frame}
```

**列表逐项出现**：

```latex
\begin{enumerate}[<+->]
  \item 第一点（先出现）
  \item 第二点
  \item 第三点
\end{enumerate}
```

## 10.5 分栏与区块

**分栏**（`columns` 环境）：

```latex
\begin{frame}{分栏布局}
\begin{columns}[T]   % T 表示顶部对齐
  \column{0.48\textwidth}
    左栏内容
    
  \column{0.48\textwidth}
    右栏内容
\end{columns}
\end{frame}
```

**区块**（block）三种变体：

```latex
\begin{block}{普通区块}
  灰色背景，通用区块
\end{block}

\begin{alertblock}{警示区块}
  红色强调
\end{alertblock}

\begin{exampleblock}{示例区块}
  绿色示例
\end{exampleblock}
```

**定理与证明**在 Beamer 中也有预设样式：

```latex
\begin{theorem}
  定理内容
\end{theorem}
\begin{proof}
  证明过程
\end{proof}
```

**参考资料**：
- Till Tantau, *Beamer User's Guide*（CTAN 文档）
- 刘海洋，《LaTeX 入门》，第15章
- Andrew Mertz & William Slough, *Beamer by Example*（网络文档）
