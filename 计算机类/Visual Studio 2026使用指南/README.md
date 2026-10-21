# Visual Studio 2026 使用教程（C++ 开发）

> **Visual Studio 2026** 是微软于 2025 年 11 月 11 日正式发布的新一代 IDE，内部版本号为 **18.x**（上一代 Visual Studio 2022 为 17.x）。这一代最大的变化有三点：**MSVC 编译器版本与 IDE 版本解耦**、**新建 C++ 项目默认使用 C++20**、**AI（GitHub Copilot）深度集成到日常开发流程**。
>
> 本教程面向**用 C++ 写代码的人**，从安装配置讲到工程化发布，覆盖 IDE 的每一个关键环节。所有内容基于 Visual Studio 2026（18.x）与 MSVC Build Tools 14.5x。

> **LaTeX / PDF 版**：同目录 [`LaTeX/`](LaTeX/) 下是内容一致的 LaTeX 版本——`main.tex` + `preamble.tex` + 封面 + 前言/绪论/附录 + `Chapter01~13.tex`，用 XeLaTeX 编译可得 **186 页 PDF**（已随附 `main.pdf`）。编译方式见 `LaTeX/main.tex` 头部注释。

---

## 目录

### 第一部分：入门

| 章号 | 标题 | 核心内容 | 难度 |
|:---:|------|----------|:---:|
| 01 | [[01-VS2026概览与版本选择\|VS 2026 概览与版本选择]] | 18.x 版本谱系、Community/Professional/Enterprise 对比、Stable 与 Insiders 通道、MSVC 版本解耦、面向 C++ 的新特性总览、破坏性变更 | ★☆☆☆☆ |
| 02 | [[02-安装与环境配置\|安装与环境配置]] | 系统要求、安装器用法、工作负荷与单个组件、MSVC 工具集与 Windows SDK、安装位置规划、多版本并存、更新与卸载 | ★☆☆☆☆ |
| 03 | [[03-界面与工作区\|界面与工作区]] | 起始窗口、解决方案资源管理器、编辑器、工具窗口体系、窗口布局与多显示器、主题与字体、快捷键体系 | ★☆☆☆☆ |
| 04 | [[04-第一个C++项目\|第一个 C++ 项目]] | 创建控制台应用、项目文件结构解析、编译与运行、F5 与 Ctrl+F5 的区别、命令行构建（MSBuild/devenv） | ★★☆☆☆ |

### 第二部分：C++ 开发核心

| 章号 | 标题 | 核心内容 | 难度 |
|:---:|------|----------|:---:|
| 05 | [[05-项目与解决方案管理\|项目与解决方案管理]] | `.sln`/`.vcxproj`/`.filters` 文件结构、多项目解决方案、项目引用与依赖、静态库/动态库项目、配置与平台映射、属性表、SLNX 新格式 | ★★★☆☆ |
| 06 | [[06-项目属性与编译配置\|项目属性与编译配置]] | 属性页全解、包含目录与库目录、`/std` 语言标准、运行库 `/MD` 与 `/MT`、优化开关、警告等级、预编译头、多核编译 | ★★★☆☆ |
| 07 | [[07-代码编辑与IntelliSense\|代码编辑与 IntelliSense]] | IntelliSense 引擎、补全与快速信息、导航与查找、重构、代码片段、格式化与 `.editorconfig`、未使用 `#include` 清理、Copilot 辅助 | ★★☆☆☆ |
| 08 | [[08-调试技术详解\|调试技术详解]] | 断点体系（条件/筛选器/数据/函数）、单步执行、监视与即时窗口、调用堆栈与多线程、内存与反汇编、异常设置、附加到进程、转储调试 | ★★★★☆ |

### 第三部分：诊断与工程化

| 章号 | 标题 | 核心内容 | 难度 |
|:---:|------|----------|:---:|
| 09 | [[09-性能分析与诊断\|性能分析与诊断]] | 诊断工具窗口、性能探查器（CPU/内存/插桩）、Build Insights、静态分析、clang-tidy、AddressSanitizer、CRT 内存泄漏检测 | ★★★★☆ |
| 10 | [[10-CMake与vcpkg集成\|CMake 与 vcpkg 集成]] | VS 直接打开 CMake 项目、`CMakePresets.json`、CMake 目标视图与调试、vcpkg 清单模式、WSL/容器/远程 Linux 开发 | ★★★★☆ |
| 11 | [[11-单元测试与代码质量\|单元测试与代码质量]] | 测试资源管理器、Microsoft 原生单元测试框架、Google Test/Boost.Test/Catch2 接入、测试适配器、代码覆盖率、CI 集成 | ★★★☆☆ |
| 12 | [[12-发布与部署\|发布与部署]] | Debug 与 Release 差异、`/MD` 与 `/MT` 取舍、静态链接、依赖 DLL 收集、VC++ 可再发行程序包、安装包制作、发布检查清单 | ★★★☆☆ |
| 13 | [[13-常见问题与效率技巧\|常见问题与效率技巧]] | 编译链接错误速查表、中文乱码专题、IntelliSense 不一致、路径规范、快捷键总表、效率技巧集 | ★★☆☆☆ |

---

## 环境要求

| 项目 | 要求 |
|------|------|
| **主机操作系统** | **Windows 11**（家庭版 / 专业版 / 专业教育版 / 专业工作站版 / 企业版 / 教育版，含 **ARM64** 版），或 Windows Server 2025 / 2022 / 2019。**Windows 10 不在官方支持列表内**；也不支持 32 位系统、ARM32、Windows 10 ARM64、S 模式、IoT 与 LTSC 版本 |
| **目标系统下限** | 这是**另一回事**：MSVC Build Tools 14.50 起，生成的**可执行文件**最低可运行于 Windows 10 / Windows Server 2016；不再支持 Windows 7 / 8 / 8.1 |
| **硬件** | 内存最低 4 GB、推荐 16 GB；四核以上 CPU（推荐 16 核以上）；磁盘典型占用 20–50 GB，官方给出的空间区间为 2.5–210 GB；显示器最低 1366×768 |
| **IDE 运行时依赖** | .NET Framework 4.7.2 以上（安装）、4.8（运行）、WebView2 运行时 |
| **IDE 版本** | Visual Studio 2026 18.x（本教程写作时最新为 18.10.3） |
| **编译器** | MSVC Build Tools 14.50（长期支持）/ 14.51 / 14.52（预览），平台工具集 `v145` |
| **C++ 标准** | 新建项目默认 **C++20**；可选 C++14 / C++17 / C++20 / C++23（`/std:c++23preview`）/ `/std:c++latest` |

> **注意**：**"主机要求 Windows 11"和"程序要跑在 Windows 10 上"并不矛盾**。前者约束的是你运行 IDE 的机器，后者约束的是你编译出来的 `.exe`。这两件事经常被混淆，详见 [[01-VS2026概览与版本选择#6.3 目标平台下限提高|第 1 章]]。

> **提示**：VS 2026 安装到 `C:\Program Files\Microsoft Visual Studio\18\<版本>`，与 VS 2022 的 `...\2022\<版本>` 目录相互独立，因此可以并存。VS 2026 自身的月度更新是**就地更新**（in-place），无需卸载重装；后续年度版本同样采用就地更新而非并排安装。若老项目仍依赖 `v143` 工具集，可在安装器中把旧工具集一并勾选。

---

## 学习路线建议

```
第 1 阶段：装好、跑起来（第 01-04 章）
    ├── 认识版本差异，选对 SKU 与安装通道
    ├── 安装"使用 C++ 的桌面开发"工作负荷
    ├── 熟悉界面与快捷键
    └── 跑通第一个控制台程序（F5 / Ctrl+F5）

第 2 阶段：会用 IDE 干活（第 05-08 章）
    ├── 组织多项目解决方案与属性表
    ├── 掌握属性页配置（语言标准、运行库、优化）
    ├── 用 IntelliSense 高效写代码
    └── 用断点调试代替 printf 排查

第 3 阶段：写出工程级代码（第 09-12 章）
    ├── 用性能探查器与静态分析找问题
    ├── 接入 CMake 与 vcpkg 管理依赖
    ├── 写单元测试并测量覆盖率
    └── 正确发布 Release 版本

第 4 阶段：形成肌肉记忆（第 13 章）
    └── 把错误速查表与快捷键表贴在脑子里
```

---

## 本教程的约定

- **菜单路径**用 ` > ` 连接，例如 **调试 > 窗口 > 断点**。
- **快捷键**用行内代码表示，例如 `Ctrl+F5`、`F11`。
- **编译器开关**直接写 MSVC 形式，例如 `/std:c++20`、`/MD`。
- 属性页路径统一写成 **项目 > 属性 > C/C++ > 语言**（对应"配置属性"下的树形节点）。
- 文中出现的"VS 2026"均指 Visual Studio 2026（18.x）。

---

## 与 Visual Studio Code 的关系

本仓库另有一份 [[../VS code 配置指南/C++配置指南|VS Code C++ 配置指南]]。两者的定位完全不同：

| 维度 | Visual Studio 2026 | Visual Studio Code |
|------|--------------------|--------------------|
| 类型 | 完整 IDE（集成开发环境） | 代码编辑器 + 扩展 |
| C++ 编译器 | 自带 MSVC 工具集 | 需自行安装 MSVC / MinGW |
| 项目系统 | MSBuild（`.vcxproj`）、CMake | CMake / 自行配置 |
| 调试器 | 内置，功能最全 | 通过 C/C++ 扩展提供 |
| 体积 | 数 GB | 数百 MB |
| 适合场景 | Windows 桌面/游戏/大型 C++ 工程 | 轻量编辑、跨平台、脚本语言 |

简单说：**写 Windows 上的大型 C++ 项目用 Visual Studio，写跨平台小工具或顺手改几个文件用 VS Code。**

---

## 参考资料

### 官方文档

- [Visual Studio 2026 发行说明](https://learn.microsoft.com/zh-cn/visualstudio/releases/2026/release-notes) — 每月更新内容与已知问题
- [MSVC Build Tools 新增功能](https://learn.microsoft.com/zh-cn/cpp/overview/what-s-new-for-msvc) — 每个工具集版本的 C++ 特性清单
- [MSVC 编译器版本对照表](https://learn.microsoft.com/zh-cn/cpp/overview/compiler-versions) — `_MSC_VER` 与工具集版本
- [`/std` 语言标准开关](https://learn.microsoft.com/zh-cn/cpp/build/reference/std-specify-language-standard-version) — 各标准档位的含义
- [C++ 二进制兼容性](https://learn.microsoft.com/zh-cn/cpp/porting/binary-compat-2015-2017) — 跨 VS 版本混用二进制库的规则
- [C++ 团队博客](https://devblogs.microsoft.com/cppblog/) — 新特性深度解读

### 关键版本节点

| 版本 | 发布时间 | 要点 |
|------|----------|------|
| Visual Studio 2026 18.0 | 2025 年 11 月 11 日 | 正式发布（GA），携带 MSVC 14.50 与 `v145` 工具集 |
| Visual Studio 2026 18.6 | 2026 年 5 月 | 携带 MSVC 14.51，新增 `<flat_map>`/`<flat_set>`、ARM64 NEON 向量化、Arm SVE |
| Visual Studio 2026 18.10.3 | 2026 年 9 月 29 日 | 写作本教程时的最新版本 |

---

## 相关笔记

- **C++ 语言**：[[../C++学习/01-从Hello World开始|C++ 教程（21 篇）]]
- **VS 快速入门**：[[../C++学习/18-Visual Studio入门|Visual Studio 入门]]
- **CMake**：[[../CMake使用指南/CMake使用指南|CMake 使用指南]]
- **Eigen 库**：[[../Eigen库使用指南/README|Eigen 库使用指南]]
- **Git**：[[../常用Git 命令|常用 Git 命令]]
- **VS Code 对照**：[[../VS code 配置指南/C++配置指南|VS Code C++ 配置指南]]
- **全库索引**：[[../../00-知识索引|知识索引]]
