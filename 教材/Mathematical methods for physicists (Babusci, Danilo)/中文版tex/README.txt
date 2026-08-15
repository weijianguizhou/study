物理学家用数学方法 —— XeLaTeX 中文版工程
=========================================

原著作者: Danilo Babusci, Giuseppe Dattoli,
                 Silvia Licciardi, Elio Sabia
LaTeX 转写: AI 辅助转写，关键方程手工排版
中文翻译: 在英文版 tex 基础上逐章翻译

目录结构:
  main.tex      XeLaTeX 主文件（编译此文件）
  ch1.tex       第 1 章 矩阵、指数算子及其物理应用
  ch2.tex       第 2 章 常微分与偏微分方程、演化算子方法及其应用
  ch3.tex       第 3 章 Hermite 多项式及其应用
  ch4.tex       第 4 章 Laguerre 多项式、积分算子及其应用
  ch5.tex       第 5 章 练习与补充 I
  ch6.tex       第 6 章 练习与补充 II
  ch7.tex       第 7 章 练习与补充 III
  ch8.tex       第 8 章 练习与补充 IV
  ch9.tex       第 9 章 特殊函数、Umbral 方法及其应用
  ch10.tex      第 10 章 初窥 Feynman 图的数学
  figures/      各章插图（自英文版复制）

编译方法（Windows / VS Code）:
  1. 安装 TeX Live (https://tug.org/texlive/) 或 MiKTeX
  2. 在 VS Code 中配合 LaTeX Workshop 插件打开 main.tex
  3. 确认首行为:  % !TEX program = xelatex
  4. 点击 "Build LaTeX project" → 选择 XeLaTeX
  5. 编译两次（第一次生成 .aux，第二次解析 \ref）

命令行编译:
  cd <本目录>
  xelatex main.tex
  xelatex main.tex

中文支持:
  main.tex 使用 ctex 宏包支持中文（XeLaTeX 下编译）。
  定理类环境名称已中文化：定理、命题、练习。

自定义宏（定义于 main.tex）:
  \mat{...}      → pmatrix 简写
  \spp, \smm    → σ₊, σ₋ 升降算子
  \sigx, \sigy, \sigz → σ_x, σ_y, σ_z
  \vect{v}        → 粗体矢量
  \tr, \sinc, \sincf, \diag  → 标准算子
  \erfi, \erfc    → 误差函数（虚误差函数 / 余误差函数）

与英文版的差异:
  - 全部正文、小节标题、图题、练习与注记均已译成中文；
    公式、标签与引用编号保持不变。
  - 删除了英文版 ch1、ch2 末尾的 "Transcribed Notes (raw OCR, verbatim)"
    原始 OCR 补充段落。
  - 参考文献条目保留原文（书刊名与作者名按惯例不译）。

许可说明:
  本 LaTeX 转写仅用于个人学习研究。
  原著版权 © 2020 World Scientific Publishing。
  请勿将编译后的 PDF 用于商业分发。
