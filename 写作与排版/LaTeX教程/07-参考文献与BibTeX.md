# 第7章：参考文献与 BibTeX

学术写作离不开文献引用。LaTeX 提供了从简单的 `thebibliography` 到强大的 BibTeX / biblatex 等多种文献管理方案。

---

## 7.1 thebibliography 环境

### 7.1.1 基本用法

`thebibliography` 适合文献量较少的文档（如课程报告），直接写在 `.tex` 文件中：

```latex
\begin{thebibliography}{⟨最宽标签⟩}
  \bibitem[⟨自定义标签⟩]{⟨引用键⟩} ⟨文献条目⟩
\end{thebibliography}
```

参数 `⟨最宽标签⟩`（如 `99`）用于对齐编号的宽度。

**完整示例：**

```latex
\documentclass{article}
\begin{document}

本文研究了深度学习在图像识别中的应用\cite{goodfellow2016}。

\begin{thebibliography}{99}
  \bibitem{goodfellow2016}
    I. Goodfellow, Y. Bengio, and A. Courville.
    \textit{Deep Learning}.
    MIT Press, 2016.
\end{thebibliography}

\end{document}
```

在正文中使用 `\cite{goodfellow2016}` 即可生成引用标记。

### 7.1.2 局限性

- 文献数据与正文混合，不便复用
- 无法自动按作者名或年份排序
- 不便于维护大型文献数据库

---

## 7.2 BibTeX 工作流

### 7.2.1 .bib 数据库文件

BibTeX 将文献数据与格式分离，所有条目保存在一个或多个 `.bib` 文件中：

```bibtex
@book{knuth1986tex,
  author    = {Donald E. Knuth},
  title     = {The TeXbook},
  publisher = {Addison-Wesley},
  year      = {1986}
}

@article{lamport1986,
  author  = {Leslie Lamport},
  title   = {Document Production: Visual or Logical?},
  journal = {TUGboat},
  volume  = {7},
  number  = {3},
  pages   = {155--158},
  year    = {1986}
}

@inproceedings{lecun2015,
  author    = {Yann LeCun and Yoshua Bengio and Geoffrey Hinton},
  title     = {Deep Learning},
  booktitle = {Nature},
  volume    = {521},
  pages     = {436--444},
  year      = {2015}
}
```

### 7.2.2 常用条目类型

| 条目类型 | 用途 | 必填字段 |
|----------|------|----------|
| `@book` | 书籍 | author/title, publisher, year |
| `@article` | 期刊论文 | author, title, journal, year |
| `@inproceedings` | 会议论文 | author, title, booktitle, year |
| `@phdthesis` | 博士论文 | author, title, school, year |
| `@misc` | 杂项（如网页） | 无必填字段 |

### 7.2.3 引用样式

BibTeX 内置的 `.bst` 样式文件：

| 样式 | 编号方式 | 排序方式 |
|------|----------|----------|
| `plain` | [1], [2], … | 按作者字母序 |
| `unsrt` | [1], [2], … | 按引用顺序 |
| `alpha` | [Knu86], [Lam86] | 按作者字母序 |
| `abbrv` | [1], [2], … | 按作者字母序，名缩写 |

在文档中使用 `\bibliographystyle` 指定样式：

```latex
\bibliographystyle{plain}
\bibliography{refs}  % 对应 refs.bib（无需 .bib 后缀）
```

### 7.2.4 编译流程

BibTeX 的编译需要四步才能完成所有交叉引用和文献的解析：

```
xelatex        % 第一遍：写入 .aux 文件，记录引用请求
bibtex         % 第二遍：读取 .aux 和 .bib，生成 .bbl
xelatex        % 第三遍：回填引用编号
xelatex        % 第四遍：修正全部交叉引用
```

### 7.2.5 natbib 宏包：增强引用命令

`natbib` 宏包提供了两种引用风格：

```latex
\usepackage[numbers]{natbib}
```

```latex
\citet{knuth1986tex}  →  Knuth [1]     % 作者在句内
\citep{knuth1986tex}  →  [1]           % 作者在括号外
```

使用 `authoryear` 模式时：

```latex
\usepackage[authoryear]{natbib}
```

```latex
\citet{knuth1986tex}  →  Knuth (1986)
\citep{knuth1986tex}  →  (Knuth, 1986)
\citeauthor{knuth1986tex} → Knuth
\citeyear{knuth1986tex}  → 1986
```

> 刘海洋《LaTeX 入门》第 7 章指出，natbib 的 `authoryear` 模式在人文社科领域被广泛采用，而 `numbers` 模式在理工科更为普遍。

### 7.2.6 完整示例

```latex
\documentclass{article}
\usepackage[authoryear]{natbib}
\begin{document}

深度学习的发展可追溯至 LeCun 等的研究\citep{lecun2015}。
而 Knuth 的经典著作\citet{knuth1986tex}为数字排版奠定了基础。

\bibliographystyle{plainnat}
\bibliography{refs}
\end{document}
```

---

## 7.3 biblatex 简介（现代方案）

### 7.3.1 基本设置

`biblatex` 是新一代参考文献排版方案，配合 `biber`（替代 BibTeX）提供更强大的功能：

```latex
\usepackage[style=authoryear, backend=biber]{biblatex}
\addbibresource{refs.bib}
```

```latex
\documentclass{article}
\usepackage[style=ieee, backend=biber]{biblatex}
\addbibresource{refs.bib}
\begin{document}
文献引用实验\cite{knuth1986tex}。
\printbibliography[title=参考文献]
\end{document}
```

### 7.3.2 编译流程

biblatex + biber 的工作流与 BibTeX 类似，但第二步调用 biber 替代 bibtex：

```
xelatex → biber → xelatex → xelatex
```

### 7.3.3 biblatex 的核心优势

| 特性 | biblatex | BibTeX |
|------|----------|--------|
| Unicode 原生支持 | ✓ | ✗（需转义） |
| 多 .bib 文件动态过滤 | ✓ | 有限 |
| 拆分/筛选文献 | `\printbibliography` 丰富选项 | 单一 `\bibliography` |
| 自定义样式难度 | 低（key-value 配置） | 高（需编写 .bst） |
| 支持多引用列表 | ✓ | ✗ |

### 7.3.4 高级筛选功能

biblatex 支持按条件动态输出文献：

```latex
\printbibliography[type=book, title=参考书籍]
\printbibliography[type=article, title=期刊论文]
\printbibliography[notkeyword=次要, title=核心文献]
```

> Oetiker 等 *The Not So Short Introduction to LaTeX2ε* 第 12 章建议，对于大型项目应优先采用 biblatex + biber 方案，以获得更好的 Unicode 支持和灵活的筛选能力。但对于投稿期刊，仍需检查是否支持 biblatex。

---

> **参考文献**
> - 刘海洋. *LaTeX 入门*. 电子工业出版社, 2013. 第7章.
> - Oetiker, T. et al. *The Not So Short Introduction to LaTeX2ε*. 第12章.
> - Mittelbach, F. et al. *The LaTeX Companion*. 2nd ed., Addison-Wesley, 2004. 第14章.
