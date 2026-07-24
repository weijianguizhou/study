# AI 编写教程 —— 工作流、规则与经验总结

> 供 AI 在后续对话开始时快速读取，避免重复犯错、减少 token 浪费。

---

## 1. 通用目录约定

```
数理基础/        ← 所有纯数学笔记（向量微积分、张量分析、ODE/PDE 等）
力学/
  流体力学/
    LaTeX/       ← .tex 源文件
    Figure/      ← TikZ 图缓存
    00-流体力学MOC.md     ← 内容索引
    01-引言与数学基础.md  ← 直白中文命名
    02-流体静力学.md
    ...           ← 全部中文名，不用 ChapterXX.md
    力学.md       ← 各领域 MOC 总汇
```

**核心原则**：
- 笔记文件命名 **直白中文**，带数字前缀排序（`01-标题.md`）
- 纯数学内容放在 `数理基础/`，学科笔记链接过去而非重复
- LaTeX 教程统一放在对应目录的 `LaTeX/` 下

---

## 2. 创建 LaTeX 教程的工作流

### 阶段 A：准备（单线程，不可并行）
1. 确认目录结构存在（`学科/LaTeX/Figure/`）
2. 写 `main.tex`：从已有教程（如 RL/DL 教程）复制导言区，修改书名
3. 关键：导言区必须完整定义所有宏包、tcolorbox 环境、TikZ 样式

### 阶段 B：写章节（可并行，多个 task agent）
1. 每个 task agent 分配 3-4 章
2. 给 agent 的 prompt 必须包含所有**硬性规则**（见 §3）
3. agent 写完后必须验证：无 `\end{chapter}`、无 `\dfrac` 行内、无 `\begin{equation*}` 在 `myformula` 内
4. 每章 4+ 个 TikZ 图 + Python 代码块

### 阶段 C：编译与修复（单线程）
1. `xelatex -interaction=nonstopmode main.tex` 首次编译
2. 收集所有 Error（忽略 Warning）
3. 批量修复（见 §4 常见错误表）
4. 两次编译：先 `-halt-on-error`，再 `-interaction=nonstopmode`

### 阶段 D：写 Markdown 笔记（可并行）
1. 每章对应一个 `.md` 文件，使用 Obsidian wiki-links
2. 数学内容链接到 `../../数理基础/` 下的对应笔记
3. 章节间通过 `[[XX-中文名]]` 相互引用

### 阶段 E：更新索引

---

## 3. LaTeX 硬性规则（违反即编译报错）

### 3.1 禁止使用的命令
| 禁止项 | 替代方案 | 原因 |
|--------|---------|------|
| `\T` 或 `^\T` | `^{\top}` | `\T` 宏未定义 |
| `\end{chapter}` | 不需要 | 语法错误 |
| `\dfrac` 在行内 | `\frac` | 行内公式使用 `\dfrac` 导致行距异常 |
| `\begin{equation*}` 在 `myformula` 内 | 直接写 `\[...\]` 或 `$$...$$` | 嵌套 equation 环境报错 |
| `\newtcbtheorem[]{myformula}{...}` 带括号标题 | `\newtcbtheorem[]{myformula}{}{...}` | tcolorbox 标题中的 `)` 导致参数解析错误 |
| tcolorbox 标题文本含中文/英文括号 `(.*)` 或 `（.*）` | 将括号部分裹入 `{}`，如 `{极点配置定理{(Wonham, 1967)}}` | 括号被当作 tcb key 解析 |
| `\iddots` | `\ddots` | `\iddots` 不存在，反向对角点也用 `\ddots` |

### 3.2 环境名称（大小写敏感）
```
正确: myTheorem (大写 T), mydefinition, myalgorithm, mycode, myformula, example, proof, remark
错误: mytheorem, myTheoremBox, algorithm
```

### 3.3 TikZ 规则
- **样式名必须加前缀**（如 `fluidNeuron` 而非 `neuron`，`ch09shock` 而非 `shock`）
- 节点中换行：`align=center` + `\\`，不能在 LR 模式直接用 `\\`
- 所有 `.tikz` 图片必须在 `main.tex` 中通过 `\input{}` 加载
- **电路图**（如 RLC 电路）：需 `\usepackage{circuitikz}`，提供 `V`/`R`/`L`/`C` 等组件键
- **画弹簧/线圈**：`decoration={coil,...}` 需要加载 `decorations.pathmorphing` 库
- **函数绘图**（Bode 图等）：domain 中的 `10^(\x)` 避免超出约 16000 的上限，否则触发 `Dimension too large`
- **浮点计算**：TikZ 内部用 TeX 维度（上限约 16384pt），大数值需 `fpu` 库：
  ```latex
  \pgfkeys{/pgf/fpu=true,/pgf/fpu/output format=fixed}
  \draw[style, domain=..., samples=...] plot (\x, {表达式});
  \pgfkeys{/pgf/fpu=false}
  ```
  （`atan2` 虽不直接溢出，但中间量的 `10^(2*\x)` 仍会超限，一并包住）

### 3.4 字体规则
- **楷体 (`\kaishu`) 和仿宋 (`\fangsong`) 无粗体变体**。`\textbf{}`/`\bfseries` 不能与它们同时使用
- 中文加粗：使用 `\heiti{...}`（黑体），或 `\sffamily\bfseries ...`
- **等宽字体**（`lmmono`/`\ttfamily`）不含希腊字符，代码注释中避免使用 `ε` 等希腊字母
- 章标题中 `\kaishu` + `\bfseries` 会导致字体回退警告：移除 `\bfseries` 或改用 `\heiti`
- **`proof` 环境标题定义**：不能用 `{\kaishu\uline{\textbf{#1.}}}` 组合（楷体无粗体）。直接用 `{\heiti\uline{#1.}}`，黑体本身就有强调效果

### 3.5 其他
- `\mathbf` 仅在数学模式内使用
- `\item` 仅在 `enumerate` 或 `itemize` 内使用
- 标题（section/subsection/tcolorbox title）中不能出现数学公式
- `\intro{}` 用于章节开头的简介
- `\chapter{}` 后立即接 `\intro{}`
- 章节编号由 `\chapter{}` 自动生成，不要在 `\chapter` 内手动编号

### 3.6 导言区必含宏包
```
\usepackage{amsmath,amssymb,amsfonts,amsthm}
\usepackage{esint}           % \oiint 二重闭曲面积分
\usepackage{mathtools}
\usepackage{bm}
\usepackage{unicode-math}
\usepackage{tikz,pgfplots}
\usetikzlibrary{arrows.meta,shapes,calc,decorations.pathmorphing,positioning}
\usepackage{circuitikz}      % 电路图组件 (V, R, L, C)
\usepackage{tcolorbox}
\tcbuselibrary{skins,breakable,listings}  % listings 必须含，否则 # 报错
```
- 定义数学运算符：`\DeclareMathOperator{\Res}{Res}`（留数）、`\DeclareMathOperator{\sgn}{sgn}` 等

---

## 4. 常见编译错误及修复

| # | 错误信息 | 原因 | 修复 |
|---|---------|------|------|
| 1 | `Undefined control sequence \oiint` | 缺少 `esint` 宏包 | `\usepackage{esint}` |
| 2 | `! Illegal parameter number in definition of \tcobox` | Python 代码中 `#` 被当作宏参数 | 将 `mycode` 改为 `\newtcblisting`（逐字环境）+ 加载 `listings` 库 |
| 3 | `! Package PGF Math Error: Unknown function 'erf'` | TikZ/pgfmath 不支持 `erf` | 用 `tanh(1.128x)` 近似定义 `\pgfmathdeclarefunction{erf}` |
| 4 | `! Dimension too large` | 三角函数参数超过 TeX 内部上限 | 用 `\begin{scope}[fpu=true]` 启用浮点计算 |
| 5 | `! Package pgf Error: No shape named ...` | TikZ 样式/颜色未定义 | 在导言区批量 `\definecolor` 和 `\tikzset` 提供默认值 |
| 6 | `! LaTeX Error: Environment myenum undefined` | 自定义环境未定义 | `\newenvironment{myenum}{\begin{enumerate}}{\end{enumerate}}` |
| 7 | `! Not allowed in LR mode` | `\\` 在 TikZ node 内未设 `align=center` | 给节点样式加 `align=center` |
| 8 | `! Undefined control sequence \end{Chapter01}` | 错误的 `\end{Chapter01}` | 删除 `\end{...}`，LaTeX 章节不需要 `\end` |
| 9 | `! Undefined control sequence \Res` | 留数运算符未定义 | `\DeclareMathOperator{\Res}{Res}` |
| 10 | `Package pgfkeys Error: I do not know the key '/tikz/V' (or /R, /L, /C)` | 缺少 `circuitikz` 宏包 | `\usepackage{circuitikz}` |
| 11 | `Package pgfkeys Error: I do not know the key '/pgf/decoration/coil'` | 缺少 `decorations.pathmorphing` 库 | 在 `\usetikzlibrary` 中加入 `decorations.pathmorphing` |
| 12 | xelatex 报 `unrecognized option '-pdf'` | XeTeX 已默认输出 PDF，不用 `-pdf` | 直接用 `xelatex` 不加该选项 |
| 13 | `Font shape 'TU/KaiTi(0)/b/n' undefined` | 楷体/仿宋无粗体变体，`\textbf{}`/`\bfseries` 与 `\kaishu`/`\fangsong` 冲突 | 中文加粗改用 `\heiti{...}`（黑体），或移除粗体 |
| 14 | `Missing character: There is no ε in font lmmono` | 等宽字体 `lmmono` 不含希腊字符 | 代码注释中避免用希腊字母，改用英文如 `eps` |
| 15 | PGF Math 报 `sqrt of negative number` + `Dimension too large` | `10^(2*\x)` 在高频端超 TeX 维度上限 | ① 缩减 domain（如 `-1:1.5`）；② 用 `\pgfkeys{/pgf/fpu=true}` 包住整条 `\draw[...] plot (...)`，画完后 `\pgfkeys{/pgf/fpu=false}` |
| 16 | `Overfull \vbox (56pt too high)` | 长 `lstlisting` 代码块无法在当前页放下 | 在其前插入 `\newpage` 强制分页 |
| 17 | `proof` 环境标题触发 `TU/KaiTi(0)/b/n' undefined` | 定义 `{\kaishu\uline{\textbf{#1.}}}` 中 kaishu 内嵌 `\textbf` | 改为 `{\heiti\uline{#1.}}`，黑体自带强调无需 `\textbf` |
| 18 | `Undefined control sequence \iddots` | `\iddots` 不存在，拼写错误 | 改为 `\ddots`（无论正向/反向对角点均用这个） |
| 19 | `Package pgfkeys Error: '/tcb/1967）'` | tcolorbox 标题 `极点配置定理（Wonham, 1967）` 中括号被解析为 key | 括号部分裹入 `{}`：`极点配置定理{(Wonham, 1967)}` |

---

## 5. Markdown 笔记规则

### 5.1 文件名
```
✗ Chapter01.md, chapter1.md
✓ 01-引言与数学基础.md
```

### 5.2 wiki-link 规范
```
引用同目录其他笔记: [[02-流体静力学|静力学]]
引用数理基础:       [[../../数理基础/向量微积分|向量微积分]]
引用同级目录:       [[../力学.md|力学总索引]]
```
禁止使用 `[[ChapterXX]]` 格式。

### 5.3 内容结构
- 每篇以 `# 标题` 开头
- `##` / `###` 分层
- `## 总结` 收尾
- 关键公式用 `$$...$$`

---

## 6. 数学内容归属原则

| 内容 | 应归入 | 说明 |
|------|--------|------|
| 张量/指标记法/应力张量 | `数理基础/张量分析.md` | 纯数学工具 |
| 梯度/散度/旋度 | `数理基础/向量微积分.md` | 场论基础 |
| 曲线坐标公式 | `数理基础/向量微积分.md` | 数学工具 |
| ODE/PDE 解法 | `数理基础/ODE常微分方程.md` / `数理基础/偏微分方程.md` | 数学工具 |
| 物质导数/雷诺输运 | 流体力学章节中 | 学科专用概念 |
| NS 方程/Bernoulli | 流体力学章节中 | 学科核心内容 |

---

## 7. 目录 & 文件管理

```
学习笔记/
├── 00-知识索引.md         ← 全库入口
├── AI写教程.md            ← 本文件
├── 数理基础/              ← 纯数学笔记
├── 力学/
│   ├── 力学.md            ← 力学 MOC
│   ├── 流体力学/
│   │   ├── 00-流体力学MOC.md
│   │   ├── 01-引言与数学基础.md
│   │   ├── LaTeX/
│   │   │   ├── main.tex
│   │   │   └── ChapterXX.tex
```

---

## 8. 并行工作策略

| 任务 | 并行度 | 说明 |
|------|--------|------|
| 目录准备 | 1 | 需确认存在性 |
| main.tex 编写 | 1 | 需一致性 |
| 章节 .tex 初稿 | 3-4 agents | 每 agent 3-4 章，prompt 要包含完整规则 |
| 编译修复 | 1 | 需串行排查 |
| .md 笔记 | 2-4 agents | 按章节分组，指定 wiki-link 命名 |
| 索引更新 | 1 | 最后串行 |

---

## 9. 脚本与工具

- **编译**：`xelatex -interaction=nonstopmode main.tex`（两次，第二次不加 `-halt-on-error`）
- **重命名**：PowerShell `Rename-Item -LiteralPath src dst`
- **批量替换**：`(Get-Content file -Raw).Replace(old, new)` 或 `-replace` 正则
- **验证命名**：`Select-String -Pattern "\[\[Chapter" *.md` 确认无残留旧链接

---

## 附录：流体力学教程数据

| 指标 | 值 |
|------|-----|
| .tex 章数 | 12 |
| .md 笔记数 | 13（12 章 + MOC） |
| PDF 页数 | 62 |
| TikZ 图数 | ~48 |
| Python 代码块 | ~20 |
| .md 总大小 | ~200 KB |
| 总文件 | 13 .md + 1 main.tex + 12 chapter .tex |

---

> 下次 AI 对话开始时，先读此文件以了解完整的工作流和规则，可节省大量试错时间。
> 合并自：`LaTeX报错修复说明.md`（原始 LaTeX 错误修复记录已整合到 §4 常见错误表）
