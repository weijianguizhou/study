/* ============================================================================
 *  古典控制理论（控制工程基础）· 学习笔记
 *  模板：dvdtyp 1.0.1 本地适配版（见 dvd.typ，字体与中文环境已适配）
 *  内容来源：《控制工程基础》课程课件（第 1—8 章 PPT）与课堂讲义（第 01—05 讲），
 *           并参考了原 LaTeX 版笔记。语言从简，推导从略，保留核心知识点。
 *
 *  编译：typst compile 古典控制理论笔记.typ
 *  依赖：Typst ≥ 0.13；首次编译需要网络下载 ctheorems / showybox。
 * ============================================================================ */

#import "dvd.typ": *

#show: dvdtyp.with(
  title: "古典控制理论",
  subtitle: "控制工程基础 · 学习笔记",
  author: "魏舟",
  abstract: [
    教材：董景新等《控制工程基础》（第 4 版），清华大学出版社。\
    本笔记按课程八章结构整理：概论、数学模型、时域响应、频率特性、稳定性、\
    误差分析、综合与校正、根轨迹法。整理以课件为准，公式推导从简。
  ],
)

#outline()

#pagebreak()

#include "content/ch1.typ"
#include "content/ch2.typ"
#include "content/ch3.typ"
#include "content/ch4.typ"
#include "content/ch5.typ"
#include "content/ch6.typ"
#include "content/ch7.typ"
#include "content/ch8.typ"
