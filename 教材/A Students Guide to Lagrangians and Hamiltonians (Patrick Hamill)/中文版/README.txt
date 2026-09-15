《拉格朗日量与哈密顿量学生指南》—— LaTeX 源文件（中文版）
=====================================================

作者:  Patrick Hamill
出处:  Cambridge University Press（2014）

本目录是原书 LaTeX 源文件的中文译本，按章节组织，
所有插图均已提取到 Figures/ 目录。

目录结构
---------
main.tex                 — 主文档（XeLaTeX + ctexbook）
chapters/
  Ch_intro.tex           — 绪论与致谢
  Ch1.tex                — 第 1 章：基本概念
  Ch2.tex                — 第 2 章：变分法
  Ch3.tex                — 第 3 章：拉格朗日动力学
  Ch4.tex                — 第 4 章：哈密顿方程
  Ch5.tex                — 第 5 章：正则变换；泊松括号
  Ch6.tex                — 第 6 章：哈密顿-雅可比理论
  Ch7.tex                — 第 7 章：连续系统
Figures/                 — 全部插图（PNG 格式）
build.sh                 — Linux/macOS 编译脚本
build.cmd                — Windows 编译脚本

编译方法
---------
需要 XeLaTeX（推荐 TeX Live 2020 或更新版本），并包含
ctex 中文排版宏包。

  Windows:  双击 build.cmd（或在命令行运行 build.cmd）
  Linux:    bash build.sh
  或手动:
    xelatex main.tex
    xelatex main.tex

需编译两次以解决交叉引用和目录（TOC）。

依赖宏包
---------
  ctex, fontspec, graphicx, amsmath, amssymb, amsthm,
  fancyhdr, titlesec, caption, subcaption, hyperref, enumitem

字体
-----
- 西文:  TeX Gyre Termes（衬线）、TeX Gyre Cursor（等宽）
- 中文:  SimSun 宋体（正文）、SimHei 黑体（无衬线）、FangSong 仿宋（等宽）
  —— Windows 系统自带；如需更换请在 main.tex 中修改
  \setmainfont、\setmonofont、\setCJKmainfont 等设置。

说明
-----
- 封面、版权页以及参考文献/解答部分按原书要求省略。
- 全部插图通过 \includegraphics{fig_X_Y} 引用，
  由 \graphicspath{{./Figures/}} 解析。
- 本中文版根据英文版源文件翻译整理；原英文版源文件系从 PDF
  提取，个别公式在提取过程中有所缺损，翻译时已按物理内容
  尽量复原（个别处依据上下文做了合理推断）。
- 若需更换字体，请修改 main.tex 中的相应 fontspec/ctex 设置。
