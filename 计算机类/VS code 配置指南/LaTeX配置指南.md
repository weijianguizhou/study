# VS Code LaTeX 配置完全指南（Windows）

> 适用于 VS Code 1.90+（2026年）

## 1. 前提条件

### 必需软件
| 软件 | 用途 | 下载地址 |
|------|------|----------|
| **VS Code** | 代码编辑器 | https://code.visualstudio.com |
| **TeX 发行版** | LaTeX 编译器 | 见下方选择 |

### 选择 TeX 发行版

| 发行版 | 特点 | 推荐场景 |
|--------|------|----------|
| **TeX Live** | 跨平台，更新频繁，最常用 | 通用（推荐） |
| **MiKTeX** | Windows 专用，按需安装包 | 磁盘空间有限 |
| **Overleaf** | 在线编辑器，无需本地安装 | 快速开始、协作 |

### 安装 TeX Live（推荐）

**方法一：完整安装（推荐）**
1. 下载 TeX Live 安装程序: https://www.tug.org/texlive/
2. 运行 `install-tl-windows.exe`
3. 选择完整安装（约 4-5GB），包含所有宏包
4. 安装路径建议保持默认：`C:\texlive\2025`

**方法二：使用 install-tl-noadmin（用户级安装）**
1. 下载 `install-tl-windows.exe`
2. 以普通用户身份运行
3. 安装到用户目录，如 `C:\Users\用户名\texlive\2025`

### 安装 MiKTeX（备选）

1. 下载 MiKTeX: https://miktex.org/download
2. 选择 "Install for anyone who uses this computer"
3. MiKTeX 默认按需安装缺失的宏包（首次使用时会自动下载）

### 验证安装
```bash
pdflatex --version
xelatex --version
bibtex --version
```

### 推荐额外工具
| 工具 | 用途 | 下载地址 |
|------|------|----------|
| **BibTeX / Biber** | 参考文献管理 | 已包含在 TeX Live 中 |
| **Inkscape** | 矢量图编辑 | https://inkscape.org |
| **ImageMagick** | 图像处理 | https://imagemagick.org |
| **Perl** | 部分宏包依赖 | 已包含在 TeX Live 中 |

## 2. VS Code 扩展安装

`Ctrl+Shift+X` 打开扩展面板，安装以下扩展：

| 扩展名 | ID | 说明 |
|--------|-----|------|
| **LaTeX Workshop** | `James-Yu.latex-workshop` | LaTeX 核心扩展（必装） |
| **LaTeX Utilities** | `tecosaur.latex-utilities` | 增强功能（补全、格式化等） |
| **Spell Right** | `ban.spellright` | 拼写检查 |
| **Grammarly** | `grammarly.grammarly` | 语法检查（英文） |
| **Image Preview** | `kisstkondoros.vscode-gutter-preview` | 图像预览 |

### LaTeX Workshop 安装后设置

LaTeX Workshop 安装后即可工作，但建议进行以下配置以获得最佳体验。

## 3. 配置 TeX 编译工具链

### 3.1 自动检测

LaTeX Workshop 会自动检测系统中安装的 TeX 发行版。如果没有自动检测到：

1. `Ctrl+Shift+P` → `LaTeX Workshop: Select language server`
2. 重新加载窗口

### 3.2 手动配置工具链

在 `.vscode/settings.json` 中配置：

```json
{
    "latex-workshop.latex.tools": [
        {
            "name": "xelatex",
            "command": "xelatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "%DOC%"
            ]
        },
        {
            "name": "pdflatex",
            "command": "pdflatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "%DOC%"
            ]
        },
        {
            "name": "lualatex",
            "command": "lualatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "%DOC%"
            ]
        },
        {
            "name": "bibtex",
            "command": "bibtex",
            "args": [
                "%DOCFILE%"
            ]
        },
        {
            "name": "biber",
            "command": "biber",
            "args": [
                "%DOCFILE%"
            ]
        },
        {
            "name": "makeglossaries",
            "command": "makeglossaries",
            "args": [
                "%DOCFILE%"
            ]
        }
    ],
    "latex-workshop.latex.recipes": [
        {
            "name": "XeLaTeX → BibTeX → XeLaTeX → XeLaTeX",
            "tools": [
                "xelatex",
                "bibtex",
                "xelatex",
                "xelatex"
            ]
        },
        {
            "name": "XeLaTeX",
            "tools": [
                "xelatex"
            ]
        },
        {
            "name": "pdfLaTeX → BibTeX → pdfLaTeX → pdfLaTeX",
            "tools": [
                "pdflatex",
                "bibtex",
                "pdflatex",
                "pdflatex"
            ]
        },
        {
            "name": "pdfLaTeX",
            "tools": [
                "pdflatex"
            ]
        },
        {
            "name": "LuaLaTeX → Biber → LuaLaTeX → LuaLaTeX",
            "tools": [
                "lualatex",
                "biber",
                "lualatex",
                "lualatex"
            ]
        }
    ]
}
```

### 3.3 XeLaTeX vs pdfLaTeX vs LuaLaTeX

| 编译器 | 中文支持 | Unicode | 字体 | 推荐场景 |
|--------|----------|---------|------|----------|
| **XeLaTeX** | ✅ 原生支持 | ✅ | 系统字体 | 中文文档（推荐） |
| **pdfLaTeX** | ⚠️ 需要 CJK 宏包 | ❌ | 有限 | 纯英文文档 |
| **LuaLaTeX** | ✅ 原生支持 | ✅ | 系统字体 | 高级排版需求 |

**推荐中文用户使用 XeLaTeX。**

## 4. 配置构建任务（tasks.json）

### 4.1 LaTeX Workshop 内置任务

LaTeX Workshop 已经自动配置了构建任务，通常不需要手动创建 `tasks.json`。

使用快捷键 `Ctrl+Alt+B` 编译当前 LaTeX 文件。

### 4.2 手动创建（高级需求）

如果需要自定义构建流程，创建 `.vscode/tasks.json`：

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "编译 LaTeX (XeLaTeX)",
            "type": "shell",
            "command": "xelatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "${file}"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": ["$latex"],
            "presentation": {
                "reveal": "always",
                "panel": "dedicated"
            }
        },
        {
            "label": "编译完整文档 (XeLaTeX + BibTeX)",
            "dependsOn": ["XeLaTeX 第一遍", "BibTeX", "XeLaTeX 第二遍", "XeLaTeX 第三遍"],
            "group": "build"
        },
        {
            "label": "XeLaTeX 第一遍",
            "type": "shell",
            "command": "xelatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "${file}"
            ],
            "problemMatcher": ["$latex"]
        },
        {
            "label": "BibTeX",
            "type": "shell",
            "command": "bibtex",
            "args": [
                "${fileDirname}/${fileBasenameNoExtension}"
            ],
            "problemMatcher": ["$bibtex"]
        },
        {
            "label": "XeLaTeX 第二遍",
            "type": "shell",
            "command": "xelatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "${file}"
            ],
            "problemMatcher": ["$latex"]
        },
        {
            "label": "XeLaTeX 第三遍",
            "type": "shell",
            "command": "xelatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "${file}"
            ],
            "problemMatcher": ["$latex"]
        }
    ]
}
```

## 5. 配置预览和正向/反向搜索

### 5.1 PDF 预览

LaTeX Workshop 内置 PDF 预览器，无需额外配置。

**使用方式**：
- `Ctrl+Alt+V`：在 VS Code 内打开 PDF 预览
- 编译后自动更新预览

### 5.2 正向搜索（从 .tex 到 PDF）

在 `.tex` 文件中定位到某一行，按 `Ctrl+Alt+J`，PDF 预览器会跳转到对应位置。

### 5.3 反向搜索（从 PDF 到 .tex）

在 PDF 预览中双击某处，VS Code 会跳转到对应的 `.tex` 源文件位置。

### 5.4 配置外部 PDF 查看器（可选）

如果需要使用外部 PDF 查看器（如 SumatraPDF）进行正向/反向搜索：

```json
{
    "latex-workshop.view.pdf.viewer": "external",
    "latex-workshop.view.pdf.ref.viewer": "external",
    "latex-workshop.view.pdf.external.viewer.command": "C:\\Program Files\\SumatraPDF\\SumatraPDF.exe",
    "latex-workshop.view.pdf.external.viewer.args": [
        "-reuse-instance",
        "-forward-search",
        "%TEX%",
        "%LINE%",
        "%PDF%"
    ],
    "latex-workshop.view.pdf.external.synctex.keymap": "Ctrl+Alt+Click"
}
```

**SumatraPDF 下载**: https://www.sumatrapdfreader.org/download-free-pdf-viewer

### 5.5 配置 VS Code 内置预览器

```json
{
    "latex-workshop.view.pdf.viewer": "tab",
    "latex-workshop.view.pdf.tab": {
        "prescale": 1.5,
        "backgroundColor": "#ffffff"
    }
}
```

## 6. 常用快捷键和设置

### 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+Alt+B` | 编译 LaTeX 文件 |
| `Ctrl+Alt+V` | 打开 PDF 预览 |
| `Ctrl+Alt+J` | 正向搜索（.tex → PDF） |
| `Ctrl+Alt+C` | 清理辅助文件 |
| `Ctrl+Space` | 代码补全 |
| `Ctrl+Shift+X` | 注释环境 |

### LaTeX Workshop 命令面板

`Ctrl+Shift+P` → 输入 `LaTeX Workshop` 可以看到所有可用命令：

| 命令 | 说明 |
|------|------|
| `LaTeX Workshop: Build with recipe` | 选择编译方案 |
| `LaTeX Workshop: Clean up` | 清理辅助文件 |
| `LaTeX Workshop: Select language server` | 选择语言服务器 |

### 推荐 settings.json

```json
{
    "latex-workshop.latex.autoBuild.run": "onSave",
    "latex-workshop.latex.autoBuild.clean.enabled": true,
    "latex-workshop.latex.clean.fileTypes": [
        "*.aux", "*.bbl", "*.blg", "*.idx", "*.ind",
        "*.lof", "*.lot", "*.out", "*.toc", "*.acn",
        "*.acr", "*.alg", "*.glg", "*.glo", "*.gls",
        "*.fls", "*.log", "*.fdb_latexmk", "*.synctex.gz",
        "*.snm", "*.nav", "*.vrb"
    ],
    "latex-workshop.latex.recipe.default": "first",
    "latex-workshop.view.pdf.viewer": "tab",
    "latex-workshop.latexindent.path": "latexindent",
    "editor.wordWrap": "on",
    "editor.bracketPairColorization.enabled": true,
    "[latex]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true,
        "editor.formatOnSave": false
    },
    "files.associations": {
        "*.tex": "latex",
        "*.sty": "latex",
        "*.cls": "latex",
        "*.bib": "bibtex",
        "*.bbl": "bibtex"
    }
}
```

## 7. 示例项目配置

### 7.1 项目目录结构

```
my_paper/
├── .vscode/
│   ├── settings.json
│   └── tasks.json
├── chapters/
│   ├── introduction.tex
│   ├── methodology.tex
│   ├── results.tex
│   └── conclusion.tex
├── figures/
│   ├── figure1.pdf
│   └── figure2.pdf
├── references.bib
├── main.tex
├── main.pdf
└── template.cls (可选)
```

### 7.2 示例 main.tex（中文文档）

```latex
% !TEX program = xelatex
\documentclass[12pt, a4paper]{article}

% ---- 中文支持 ----
\usepackage{ctex}

% ---- 数学公式 ----
\usepackage{amsmath, amssymb, amsthm}

% ---- 图表 ----
\usepackage{graphicx}
\usepackage{float}
\usepackage{subcaption}
\usepackage{booktabs}

% ---- 参考文献 ----
\usepackage[backend=biber, style=gb7714-2015]{biblatex}
\addbibresource{references.bib}

% ---- 页面设置 ----
\usepackage{geometry}
\geometry{left=2.5cm, right=2.5cm, top=3cm, bottom=3cm}

% ---- 超链接 ----
\usepackage[colorlinks=true, linkcolor=blue, citecolor=red]{hyperref}

% ---- 代码 ----
\usepackage{listings}
\lstset{
    basicstyle=\small\ttfamily,
    breaklines=true,
    frame=single,
    numbers=left
}

\title{论文标题}
\author{作者姓名}
\date{\today}

\begin{document}

\maketitle

\begin{abstract}
这是摘要内容。摘要应简明扼要地概述研究目的、方法、结果和结论。
\end{abstract}

\tableofcontents
\newpage

\section{引言}
\label{sec:introduction}

引言内容。参考文献引用示例 \cite{knuth1984}。

\section{方法}
\label{sec:methodology}

方法论内容。公式示例：
\begin{equation}
    E = mc^2
    \label{eq:einstein}
\end{equation}

\section{结果}
\label{sec:results}

结果内容。图表示例见图 \ref{fig:example}。

\begin{figure}[H]
    \centering
    % \includegraphics[width=0.8\textwidth]{figures/example.pdf}
    \caption{示例图表}
    \label{fig:example}
\end{figure}

\section{结论}
\label{sec:conclusion}

结论内容。

% ---- 参考文献 ----
\printbibliography[title={参考文献}]

\end{document}
```

### 7.3 示例 references.bib

```bibtex
@article{knuth1984,
  title={Literate Programming},
  author={Knuth, Donald E.},
  journal={The Computer Journal},
  volume={27},
  number={2},
  pages={97--111},
  year={1984},
  publisher={Oxford University Press}
}

@book{lamport1994,
  title={LaTeX: A Document Preparation System},
  author={Lamport, Leslie},
  year={1994},
  publisher={Addison-Wesley},
  address={Reading, MA}
}
```

### 7.4 使用 biblatex + biber（推荐）

现代 LaTeX 推荐使用 `biblatex` + `biber` 代替传统 `bibtex`：

```latex
\usepackage[backend=biber, style=gb7714-2015]{biblatex}
\addbibresource{references.bib}
% ... 正文中引用 \cite{key}
\printbibliography
```

编译流程：XeLaTeX → Biber → XeLaTeX → XeLaTeX

### 7.5 中文模板示例（学位论文）

```latex
\documentclass[UTF8, a4paper, 12pt]{ctexbook}

\usepackage{geometry}
\geometry{
    top=3cm,
    bottom=3cm,
    left=3cm,
    right=2.5cm
}

\ctexset{
    section = {
        format = \Large\bfseries\centering,
        name = {第,节},
        number = \chinese{section}
    },
    subsection = {
        format = \large\bfseries,
        name = {,),
},
        number = \arabic{subsection}
    }
}
```

## 8. 常见问题和解决方案

### Q1: 编译报错 "Package ctex error: File 'ctex.sty' not found"
**原因**: 缺少 ctex 宏包（中文支持）  
**解决**:
```bash
# TeX Live
tlmgr install ctex

# MiKTeX（会自动安装，或手动）
mpm --install ctex
```

### Q2: 编译报错 "Biber failed: No output file"
**原因**: biber 缓存问题  
**解决**:
1. 删除辅助文件：`Ctrl+Alt+C`
2. 手动清理：删除 `.aux`, `.bbl`, `.bcf`, `.blg` 等文件
3. 重新编译

### Q3: PDF 预览不显示中文
**原因**: 使用了 pdfLaTeX 而非 XeLaTeX  
**解决**:
1. 确保使用 XeLaTeX 编译
2. 在文档开头添加 `% !TEX program = xelatex`
3. 使用 `\usepackage{ctex}` 而非 `\usepackage{CJK}`

### Q4: 正向/反向搜索不工作
**解决**:
1. 确保编译时启用了 `-synctex=1` 选项
2. 使用 VS Code 内置 PDF 预览器（而非外部）
3. 删除 `.synctex.gz` 文件后重新编译

### Q5: 代码补全不工作 / 反应慢
**解决**:
1. `Ctrl+Shift+P` → `LaTeX Workshop: Select language server` → 选择 `texlab`
2. 安装 texlab 语言服务器（LaTeX Workshop 会自动安装）
3. 重启 VS Code

### Q6: "No package xxx.sty found"
**解决**:
```bash
# TeX Live：安装缺失的包
tlmgr install <package-name>

# 或搜索包名
tlmgr search --file xxx.sty

# MiKTeX：通常自动安装，或使用包管理器手动安装
```

### Q7: 编译速度太慢
**解决**:
1. 减少不必要的宏包
2. 使用 `\includeonly{}` 只编译需要的章节
3. 避免频繁编译整个文档
4. 使用 `-draftmode` 选项检查语法

```json
{
    "latex-workshop.latex.autoBuild.run": "onSave",
    "latex-workshop.latex.autoBuild.delay": 2000
}
```

### Q8: 如何使用 Overleaf 在线模板
1. 从 Overleaf 下载模板
2. 解压到本地目录
3. 使用 VS Code + LaTeX Workshop 编辑
4. 编译后将 PDF 上传到 Overleaf 或直接提交

### Q9: 如何配置 LaTeXindent 格式化
1. 安装 latexindent（已包含在 TeX Live 中）
2. 配置：
```json
{
    "latex-workshop.latexindent.path": "latexindent",
    "editor.defaultFormatter": "James-Yu.latex-workshop",
    "[latex]": {
        "editor.formatOnSave": true
    }
}
```

### Q10: 如何管理大型项目（多文件）
1. 使用 `\input{}` 或 `\include{}` 引入子文件
2. 在主文件（main.tex）中编译
3. 配置 `TEXINPUTS` 环境变量：
```json
{
    "terminal.integrated.env.windows": {
        "TEXINPUTS": ".:./sty:./cls:"
    }
}
```

### Q11: 如何使用 LaTeX 的 Git 版本控制
推荐 `.gitignore` 内容：
```gitignore
# LaTeX 辅助文件
*.aux
*.bbl
*.blg
*.idx
*.ind
*.lof
*.lot
*.out
*.toc
*.acn
*.acr
*.alg
*.glg
*.glo
*.gls
*.fls
*.log
*.fdb_latexmk
*.synctex.gz
*.snm
*.nav
*.vrb
*.bcf
*.run.xml

# 编译输出
*.pdf
*.dvi
*.ps
```

---

> **最后更新**: 2026年  
> **适用平台**: Windows 10/11  
> **编辑器版本**: VS Code 1.90+  
> **推荐发行版**: TeX Live 2025

---

## 相关配置

- **其他语言**：[[C++配置指南|C++]] | [[Python配置指南|Python]] | [[R配置指南|R]]
- **LaTeX 学习**：[[../../写作与排版/LaTeX教程/00-LaTeX教程MOC|LaTeX 完整教程]]
- **LaTeX 入门**：[[../../写作与排版/LaTeX入门指南/Chapter1.tex|LaTeX 入门指南]]
