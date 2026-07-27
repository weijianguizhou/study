# Linux 概述与安装

> **本章目标**：理解什么是 Linux、它的历史与哲学，掌握在本地和云端安装 Linux 的方法，完成第一次命令行交互。

---

## 什么是 Linux

### 操作系统的基本角色

操作系统（Operating System, OS）是计算机系统中最底层的系统软件。它的核心职责可以用三个词概括：

1. **管理硬件** — CPU 调度、内存分配、磁盘读写、网络收发……所有硬件资源都由操作系统统一管理
2. **提供接口** — 为上层应用程序提供统一、抽象的调用接口（系统调用 + 标准库），应用程序无需关心底层硬件细节
3. **运行程序** — 加载可执行文件到内存、创建进程、维护进程的隔离与通信

简单来说，操作系统是硬件和应用软件之间的"中间人"：

```
┌──────────────────────────────────┐
│        应用程序（浏览器、编辑器、游戏）    │
├──────────────────────────────────┤
│        系统库（libc, glibc 等）          │
├──────────────────────────────────┤
│        操作系统内核（Kernel）            │
├──────────────────────────────────┤
│        硬件（CPU、内存、磁盘、网络）      │
└──────────────────────────────────┘
```

**内核（Kernel）** 和 **操作系统（OS）** 的区别值得注意：
- **内核** 是操作系统最核心的部分，负责直接与硬件交互
- **操作系统** = 内核 + 系统工具 + 用户界面 + 应用程序

Linux 严格来说只是**内核**，但日常交流中我们说的"Linux"通常指**基于 Linux 内核的完整操作系统**。

---

### Unix 的诞生

Linux 的故事必须从 Unix 讲起。

#### 背景：Multics 项目

1960 年代，MIT、Bell 实验室和通用电气（GE）联合开发 **Multics**（多路信息与计算服务）操作系统。Multics 的设计目标非常超前：分时共享、多用户、高安全性。但也因此过于复杂，进度严重滞后。

1969 年，Bell 实验室退出 Multics 项目。

#### 两位天才的业余项目

Bell 实验室的研究员 **Ken Thompson**（肯·汤普森）在 Multics 上开发了一款太空旅行游戏 *Space Travel*。Multics 停掉后，他没法玩游戏了，于是找来一台闲置的 PDP-7 小型计算机，开始在上面重写这个游戏。

为了让游戏在新机器上跑起来，Thompson 需要一个操作系统环境。他在妻子带着孩子回娘家度假的一个月里，用汇编语言先后写了：

- 一个内核雏形
- 一个 shell（命令解释器）
- 一个编辑器
- 一个汇编器

这些组件合在一起，构成了一个基本的操作系统。同事开玩笑称这套系统为 **Unics**（相对的 Multics — Multiplexed 变成 Uniplexed），后来拼写正式定为 **Unix**。

> **关键人物**：Ken Thompson（Unix 之父，后来也共同发明了 Go 语言和 UTF-8 编码）

#### C 语言的诞生

Dennis Ritchie（丹尼斯·里奇）加入了 Thompson 的工作。他注意到 Unix 是用 PDP-7 汇编写的，每换一种机器就要重写一次。于是 Ritchie 发明了 **C 语言**，并用 C 语言将 Unix 内核重写了一遍。

这使得 Unix 成为第一个用高级语言编写的操作系统，具有了前所未有的**可移植性**——只需为不同硬件平台重新编译 C 代码即可移植。

> **关键人物**：Dennis Ritchie（C 语言之父，Unix 共同发明人）

#### Unix 的传播

由于 AT&T（Bell 实验室母公司）受到反垄断协议限制，不能销售计算机软件，Unix 以极低的价格将源代码授权给大学。加州大学伯克利分校（UC Berkeley）的计算机系统研究组在 Unix 基础上添加了 TCP/IP 网络栈、虚拟内存等特性，发布了 **BSD**（Berkeley Software Distribution）。

这催生了两个 Unix 分支：
- **System V**：AT&T 的商业版本
- **BSD**：伯克利的学术版本

现代 macOS/iOS 的 Darwin 内核就是从 BSD 演化而来的。

---

### GNU 计划

#### 1983 年：自由软件运动

进入 1980 年代，Unix 逐渐闭源商业化，源代码不再公开。MIT 人工智能实验室的研究员 **Richard Stallman**（理查德·斯托曼）对此深感不满。他认为分享代码、自由使用软件是程序员的基本道德权利。

1983 年 9 月 27 日，Stallman 在 Usenet 新闻组上宣布了 **GNU 计划**：

> "GNU's Not Unix!" — 目标是创建一个完全自由的、类 Unix 的操作系统。

#### 自由软件的四项基本自由

Stallman 定义的"自由软件"（Free Software）中的 "free" 指的是"自由"而非"免费"。四项目由包括：

| 编号 | 自由 | 说明 |
|:---:|------|------|
| 0 | 自由运行 | 为任何目的运行程序的自由 |
| 1 | 自由研究 | 研究程序如何工作，并按需修改的自由（前提：能获取源代码） |
| 2 | 自由分发 | 复制并分发副本，帮助他人的自由 |
| 3 | 自由改进 | 修改程序并公开发布改进版的自由（前提：能获取源代码） |

#### GPL 许可证

1989 年，Stallman 起草了 **GNU General Public License（GPL）**，俗称"通用公共许可证"。GPL 的核心是 **Copyleft（版权开放）** 机制：

- 你可以自由使用、修改、分发 GPL 软件
- 但如果你分发修改后的版本，你必须同样以 GPL 协议公开源代码
- 这意味着自由软件的自由具有"传染性"，不会被后来的开发者"私有化"

GPL 对后续所有开源许可证（MIT、Apache、BSD 等）都产生了深远影响。

#### FSF 和 GNU 工具链

1985 年，Stallman 创立了 **自由软件基金会（Free Software Foundation, FSF）**，为 GNU 计划提供法律和资金支持。

GNU 计划陆续完成了大量高质量的 Unix 替代品：

| 组件 | 说明 |
|------|------|
| **GCC**（GNU Compiler Collection） | C/C++/Fortran 等语言的编译器 |
| **GDB** | 调试器 |
| **GNU Bash** | Bourne Again Shell |
| **GNU Coreutils** | `ls` `cp` `mv` `cat` 等核心命令 |
| **GNU Emacs** | 可编程的文本编辑器 |
| **GNU Make** | 构建自动化工具 |
| **glibc** | GNU C 标准库 |

到 1990 年代初期，GNU 几乎完成了完整操作系统的所有组件——只差一个关键部分：**内核**。

GNU 自己的内核叫 **Hurd**，但 Hurd 的设计过于复杂（微内核架构），开发进度缓慢，迟迟未能达到可用状态。这为 Linux 的登场埋下了伏笔。

---

### Linux 内核

#### 1991 年：一个芬兰学生的"爱好"

**Linus Torvalds**（林纳斯·托瓦兹）是芬兰赫尔辛基大学的一名 21 岁计算机系学生。1991 年初，他购买了一台 Intel 80386 的个人电脑。当时流行的教学系统 Minix（Andrew Tanenbaum 编写的一个微型 Unix 克隆）不能充分利用 386 的保护模式和任务切换能力，而且 Minix 的许可证限制商业使用。

Torvalds 决定自己动手写一个操作系统内核。

1991 年 8 月 25 日，他在 Minix 新闻组 `comp.os.minix` 上发了一封著名的帖子：

> *"Hello everybody out there using minix — I'm doing a (free) operating system (just a hobby, won't be big and professional like gnu) for 386(486) AT clones. ..."*

翻译：

> "各位 Minix 用户大家好——我正在做一个（免费的）操作系统（只是一个爱好，不会像 GNU 那样大且专业），面向 386(486) AT 兼容机……"

这段话后来成了科技史上最著名的"低调预言"。Linus 当时完全没有想到，他的"爱好项目"会在三十年后运行在全球 90% 以上的服务器、100% 的超级计算机和数十亿台 Android 手机上。

#### 1991 年 9 月：Linux 0.01 发布

第一个版本仅包含约 10,000 行代码，功能极其简陋：
- 只能在 80386 处理器上运行
- 只支持芬兰键盘布局
- 使用 Minix 文件系统

#### 许可证转变：从"禁止商用"到 GPL

Linus 最初将 Linux 0.01 的许可设为"禁止商业使用"。但在 1992 年初，他做出了一个关键决定：**将 Linux 的许可证改为 GNU GPL**。

这个决定让 Linux 内核与 GNU 工具链在许可证层面完美兼容。开发者可以自由地将 GNU 的工具和 Linux 内核组合成一个完整的操作系统，并进行商业分发。

> 如果没有这个许可证转变，Red Hat、SUSE 等 Linux 商业公司根本不会诞生。

#### 协作开发模式的诞生

Linus 开放了贡献通道后，全球开发者开始向 Linux 提交补丁和驱动。Linus 本人以"仁慈的独裁者"（Benevolent Dictator for Life）的身份把控着内核的质量。

1996 年，Linux 内核用企鹅 **Tux** 作为官方吉祥物。传说 Linus 在澳大利亚被一只企鹅咬过，因此选择企鹅作为标志。

到今天，Linux 内核已有超过 **3,000 万行代码**，来自全球数千名贡献者，每天都有数百个补丁被合并。Git 版本控制系统（也是 Linus 写的）就是为管理 Linux 内核开发而创建的。

---

### GNU/Linux：为什么常被称为 GNU/Linux

当人们说"Linux 操作系统"时，他们实际上在使用：

```
GNU/Linux = Linux 内核 + GNU 工具集 + 其他自由软件
```

**Linux 只是内核**。没有 GNU 的工具（bash、gcc、coreutils 等），内核自己无法与用户交互。一个完整的可启动系统通常包括：

| 层次 | 组成 | 来源 |
|------|------|------|
| 内核 | 进程调度、内存管理、驱动程序、文件系统 | **Linux**（Linus Torvalds） |
| 系统库 | C 标准库、数学库、线程库 | **GNU glibc**（FSF） |
| 基本工具 | shell、文件操作、文本处理 | **GNU Coreutils**（FSF） |
| 编译器 | C/C++/Fortran 编译器 | **GNU GCC**（FSF） |
| 桌面/服务器软件 | GNOME、KDE、Apache、MySQL | 各开源社区 |

Richard Stallman 和 FSF 一直主张将这个系统称为 **GNU/Linux**，以体现 GNU 项目的贡献。但社区中大多数人为了简便直接说"Linux"。两种称呼都没有错，但了解背后的区别有助于理解这个操作系统的构成。

> Torvalds 本人对此的态度比较务实：他认为"Linux"比"GNU/Linux"更方便，但不反对别人使用后一种称呼。

---

### 开源哲学

#### Linux 与自由软件运动的关系

Linux 的内核采用 **GPL v2** 许可证，这是自由软件运动的法律基石。但 Linux 的社区文化更偏向"开放源代码"（Open Source）的技术实用主义，而非自由软件的道德理想主义。

两者的核心差异：

| 维度 | 自由软件（Free Software） | 开源软件（Open Source） |
|------|----------------------|---------------------|
| 核心主张 | 用户的自由是道德权利 | 开放协作产生更好的软件 |
| 代表人物 | Richard Stallman | Eric S. Raymond |
| 核心理念 | 软件应该自由，闭源是不道德的 | 开放源代码是更好的开发方法论 |
| 典型许可证 | GPL（强 Copyleft） | MIT、Apache（宽松） |

在实践中，两种理念共同促成了今天繁荣的 Linux 生态。

#### 开源的好处

1. **安全性**：任何人都可以审查代码，后门更容易被发现
2. **可靠性**：全球开发者共同维护，Bug 修复迅速
3. **可定制性**：用户可以根据需要修改源代码
4. **低成本**：绝大多数开源软件免费使用
5. **知识自由**：学生可以阅读真实的工业级代码来学习

---

### Linux 不是 Windows/macOS

#### 哲学差异

| 维度 | Windows | macOS | Linux |
|------|---------|-------|-------|
| 设计哲学 | 用户友好、向后兼容、一揽子方案 | 体验至上、软硬一体、封闭生态 | 开放自由、模块化、用户掌控一切 |
| 用户界面 | 图形界面（GUI）为主 | 图形界面（GUI）为主 | CLI（命令行）和 GUI 并重，CLI 才是灵魂 |
| 文件系统 | 盘符（C: D: E:） | 类 Unix 层级树（用户不可见） | 单根目录 `/` 层级树 |
| 软件安装 | .exe/.msi 安装包 | .dmg 拖拽 / App Store | 包管理器（apt/dnf/pacman），一条命令搞定 |
| 硬件支持 | 最广泛的驱动支持 | 仅支持 Apple 硬件 | 服务器硬件支持极好，桌面外围设备偶有问题 |
| 自定义程度 | 低（注册表复杂难改） | 极低（系统高度锁定） | 极高（源代码在手，万物可改） |
| 用户群体 | 桌面/办公/游戏 | 创意工作者/开发者 | 服务器/嵌入式/超级计算机/Android |
| 命令行地位 | 辅助工具（PowerShell/cmd） | 辅助工具（Terminal + zsh） | **一等公民**——没有命令行的 Linux 不是真正的 Linux |

#### 为什么服务器几乎全是 Linux

今天的互联网底层基础设施——Web 服务器、数据库、容器、微服务——几乎全部运行在 Linux 上：

- **免费**：没有授权费用，大幅降低运营成本
- **稳定**：可以连续运行数年无需重启
- **高效**：资源占用少，同等硬件跑更多服务
- **生态**：Docker/Kubernetes、Nginx、MySQL、Redis——都是为 Linux 优先设计的
- **安全**：开源透明，庞大的安全社区

> 据 W3Techs 统计，全球约 80% 的网站服务器运行在 Linux/Unix 系统上。

---

## Linux 发行版

### 什么是发行版

**Linux 发行版（Distribution）** = Linux 内核 + 软件包集合 + 包管理器 + 配置工具 + （可选）桌面环境 + 社区支持

直接将 Linux 内核源码下载下来是没法用的——你需要编译内核、配置 init 系统、安装 GNU 工具、设置用户环境、处理依赖关系……每一项对新手来说都是巨大的门槛。

发行版帮你做了所有这些工作：
- **Canonical** 将 Linux 内核 + GNU 工具 + Debian 的包管理体系打包成了 **Ubuntu**
- **Red Hat** 将 Linux 内核 + GNU 工具 + RPM 包管理体系打包成了 **RHEL**

发行版的核心差异化要素：
1. **包管理器**：软件的安装/卸载/更新方式
2. **发布模型**：固定版本（如 Ubuntu 22.04 LTS）vs 滚动更新（如 Arch Linux）
3. **目标用户**：桌面用户 / 服务器管理员 / 安全研究员 / 极简主义者
4. **默认配置**：桌面环境、预装软件、系统设置

---

### 主流发行版家族

#### Debian 系

**Debian** 由 Ian Murdock 于 1993 年创立（Debian = Deb(ra) + Ian，他和他女朋友的名字）。Debian 以稳定性著称，其 `stable` 分支中的软件经过严格测试，非常适合生产服务器。

包管理器：`apt`（Advanced Package Tool），底层使用 `dpkg`，软件包格式 `.deb`

Debian 的版本节奏非常慢（约 2 年一个稳定版），确保每个版本都经过充分测试。

代表发行版：

| 发行版 | 特点 | 适用场景 |
|--------|------|---------|
| **Ubuntu** | 基于 Debian 的"不稳定"分支，每 6 个月发新版，2 年发一个 LTS（长期支持版）。Canonical 公司商业支持。 | **新手首选**，桌面 + 服务器 |
| **Linux Mint** | 基于 Ubuntu，更传统的桌面体验（Cinnamon 桌面），预装多媒体编解码器。 | 从 Windows 迁移的桌面用户 |
| **Kali Linux** | 基于 Debian testing，预装数百种渗透测试和安全审计工具。 | 安全测试、渗透测试 |
| **Raspberry Pi OS** | 树莓派官方系统，基于 Debian，针对 ARM 架构优化。 | 树莓派等单板计算机 |

**APT 常用命令示例**：

```bash
# 更新软件包列表
sudo apt update

# 升级所有已安装的软件包
sudo apt upgrade

# 安装软件包
sudo apt install nginx

# 卸载软件包（保留配置文件）
sudo apt remove nginx

# 彻底卸载（包括配置文件）
sudo apt purge nginx

# 搜索软件包
apt search "web server"

# 查看软件包信息
apt show nginx

# 清理不再需要的依赖包
sudo apt autoremove
```

#### Red Hat 系

**Red Hat Enterprise Linux（RHEL）** 是商业 Linux 的老大哥，面向企业提供付费技术支持。Red Hat 公司（现已被 IBM 收购）是开源商业化的标杆——通过提供订阅服务赚钱，软件本身开放源代码。

包管理器：`dnf`（Dandified YUM，新版）/ `yum`（旧版），底层使用 `rpm`，软件包格式 `.rpm`

代表发行版：

| 发行版 | 特点 | 适用场景 |
|--------|------|---------|
| **RHEL** | 商业付费，提供 10 年支持周期，面向银行、政府等要求极高的场景。 | 大型企业生产环境 |
| **CentOS Stream** | RHEL 的"上游"滚动版（原 CentOS 已停更，改为 CentOS Stream），介于 Fedora 和 RHEL 之间。 | 开发/测试，预览下一版 RHEL |
| **Fedora** | Red Hat 赞助的社区版，技术最激进，最新特性和最新内核。Linus Torvalds 本人使用 Fedora。 | 开发者桌面，尝试最新技术 |
| **Rocky Linux / AlmaLinux** | CentOS 停更后社区发起的 RHEL 兼容替代品。 | 原 CentOS 用户的迁移目标 |

**DNF 常用命令示例**：

```bash
# 更新所有软件包
sudo dnf update

# 安装软件包
sudo dnf install nginx

# 卸载软件包
sudo dnf remove nginx

# 搜索软件包
dnf search "web server"

# 查看软件包信息
dnf info nginx

# 查看历史操作
dnf history

# 撤销最近一次操作
sudo dnf history undo last
```

#### Arch 系

**Arch Linux** 由 Judd Vinet 于 2002 年创建。它的核心哲学是 **KISS（Keep It Simple, Stupid）**——不是"傻瓜式简单"，而是"最小化的简单"。

包管理器：`pacman`（Package Manager），软件包格式 `.pkg.tar.zst`

Arch 的特点：
- **滚动更新**：没有版本号，安装一次永久更新
- **极简安装**：只安装最基本的核心系统，用户自己选择一切
- **AUR（Arch User Repository）**：社区维护的巨大软件仓库
- **Arch Wiki**：公认的 Linux 最佳文档，即使不用 Arch 也值得参考

代表发行版：

| 发行版 | 特点 | 适用场景 |
|--------|------|---------|
| **Arch Linux** | 极简、滚动更新、完全 DIY。安装过程没有图形界面，全命令行操作。 | 想深入理解 Linux 的进阶用户 |
| **Manjaro** | 基于 Arch，提供图形化安装器和 Calamares 安装程序，预装桌面环境，比 Arch 保留了数周的测试延迟。 | 想要 Arch 的灵活性但不想折腾 |

> **一句话总结**：Ubuntu 帮你装好一切；Arch 让你自己装一切。两者都是了解 Linux 的好途径，只是路径不同。

**Pacman 常用命令示例**：

```bash
# 同步并更新系统
sudo pacman -Syu

# 安装软件包
sudo pacman -S nginx

# 卸载软件包
sudo pacman -R nginx

# 卸载软件包及其依赖
sudo pacman -Rns nginx

# 搜索软件包
pacman -Ss "web server"

# 查看已安装的软件包
pacman -Q

# 清理软件包缓存
sudo pacman -Scc
```

#### 其他值得了解的发行版

| 发行版 | 特点 |
|--------|------|
| **openSUSE** | 德国品质，YaST 配置工具非常好用，Tumbleweed（滚动版）和 Leap（稳定版）双线并行 |
| **Gentoo** | 源码编译型发行版，几乎一切从源代码编译安装。Portage 包管理器用 USE flags 精细控制编译选项。极限性能与极限折腾并存 |
| **Alpine Linux** | 极致轻量（约 5MB），用 musl libc 和 BusyBox 取代 glibc 和 GNU Coreutils。Docker 容器的首选基础镜像 |
| **NixOS** | 声明式配置和原子升级，整个系统由一份配置文件定义，类似 IaC（基础设施既代码）的理念应用于操作系统 |

#### 发行版选择建议

| 你的情况 | 推荐发行版 | 原因 |
|----------|-----------|------|
| 初次接触 Linux | **Ubuntu LTS** | 文档最多，社区最大，出问题最容易 Google 到答案 |
| Windows 用户想尝鲜 | **WSL2 + Ubuntu** | 无需安装双系统，Windows 内一站式体验 |
| 企业就业导向 | **RHEL / CentOS Stream** | 企业标配，RHCSA/RHCE 认证很有含金量 |
| 喜欢折腾，深入理解 | **Arch Linux** | 安装过程就是最好的学习过程 |
| 老电脑 / 低配置 | **Linux Mint Xfce** | 桌面轻量，对硬件要求极低 |
| 安全测试方向 | **Kali Linux** | 预装全套渗透测试工具 |

---

## 如何获取和使用 Linux

### WSL2（Windows Subsystem for Linux）—— 强烈推荐

WSL2 是 Windows 10/11 内置的 Linux 子系统，让你在不安装虚拟机、不重启电脑的情况下，在 Windows 里直接运行一个完整的 Linux 环境。

**WSL2 vs WSL1 的关键差异**：

| 特性 | WSL1 | WSL2 |
|------|------|------|
| 架构 | 系统调用翻译层（Linux 调用 → Windows 调用） | 真实的 Linux 内核运行在轻量级 Hyper-V 虚拟机中 |
| 性能 | 文件系统性能一般，网络栈不完整 | 完整的 Linux 内核，接近原生性能 |
| 兼容性 | 部分软件不兼容 | 几乎完整的系统调用兼容（可以运行 Docker！） |
| 跨文件系统性能 | WSL1 访问 Windows 文件较快 | WSL2 访问 Linux 文件极快，但跨文件系统较慢 |

> **注意**：WSL2 需要 Windows 10 版本 2004 或更高（内部版本 19041 以上），或 Windows 11 任意版本。

#### 方式一：命令行安装（推荐）

以**管理员身份**打开 PowerShell，执行：

```powershell
# 安装 WSL2（如果尚未安装）
wsl --install
```

这条命令会自动完成：
1. 启用"虚拟机平台"和"适用于 Linux 的 Windows 子系统"可选功能
2. 下载并安装 Linux 内核更新包
3. 将 WSL2 设为默认版本
4. 安装 Ubuntu 发行版

执行过程中会要求重启电脑。重启后会自动弹出 Ubuntu 终端窗口，提示创建 Linux 用户名和密码。

```powershell
# 如果已经安装了 WSL1，升级到 WSL2
wsl --set-default-version 2

# 查看已安装的 WSL 发行版
wsl --list --verbose
```

输出示例：
```
  NAME      STATE           VERSION
* Ubuntu    Running         2
```

```powershell
# 将现有发行版转换为 WSL2
wsl --set-version Ubuntu 2
```

#### 方式二：Microsoft Store 安装

1. 打开 **Microsoft Store**
2. 搜索 "Ubuntu"
3. 选择需要的版本（推荐 Ubuntu 22.04 LTS 或 24.04 LTS）
4. 点击"安装"
5. 安装完成后点击"打开"，设置用户名和密码

#### WSL2 日常使用命令

```powershell
# 进入 WSL2（在 PowerShell 中执行）
wsl

# 以特定用户进入
wsl -u root

# 以特定发行版进入（安装了多个时）
wsl -d Ubuntu-24.04

# 关机（停止 WSL 虚拟机）
wsl --shutdown

# 终止特定发行版
wsl --terminate Ubuntu

# 导出 WSL 发行版（备份/迁移）
wsl --export Ubuntu D:\backup\ubuntu.tar

# 导入 WSL 发行版（恢复/迁移）
wsl --import Ubuntu D:\wsl\ubuntu D:\backup\ubuntu.tar
```

#### WSL2 的文件互通

```bash
# 在 WSL2 中访问 Windows 文件
ls /mnt/c/Users/你的用户名/Desktop/

# 在 Windows 中访问 WSL2 文件
# 在文件管理器地址栏输入：
\\wsl$\Ubuntu\home\你的用户名
```

> **重要**：在 WSL2 中操作 Windows 文件（`/mnt/c/` 下）性能较差。尽量把项目文件放在 WSL2 的 Linux 文件系统（`/home/用户名/`）中。

---

### 虚拟机方式

如果你不想用 WSL2，或者想要完整的图形界面体验，虚拟机是个好选择。

#### VirtualBox + Ubuntu 安装

**步骤一：下载软件**

1. 从 [virtualbox.org](https://www.virtualbox.org) 下载 VirtualBox 安装包
2. 从 [ubuntu.com/download](https://ubuntu.com/download) 下载 Ubuntu LTS 的 ISO 镜像文件（约 4-5 GB）

**步骤二：安装 VirtualBox**

双击安装包，一路 Next 即可。过程中会提示安装网络组件，允许即可。

**步骤三：创建虚拟机**

1. 打开 VirtualBox，点击 **"新建"**
2. 输入名称（如 "Ubuntu 24.04"），类型选择 **Linux**，版本选择 **Ubuntu (64-bit)**
3. 分配内存：建议至少 **2048 MB**（2 GB），如果宿主机内存充裕可分配 4096 MB
4. 选择 **"现在创建虚拟硬盘"**，硬盘类型 **VDI**，大小建议 **25 GB** 以上（动态分配）
5. 创建完成后，点击 **"设置"** → **"存储"** → 选择光驱图标 → **"选择虚拟光盘文件"** → 选择下载的 Ubuntu ISO

**步骤四：安装 Ubuntu**

1. 点击 **"启动"**，虚拟机将从 ISO 镜像引导
2. 选择 **"Install Ubuntu"**
3. 选择键盘布局（Chinese 或 English）
4. 安装类型选择 **"正常安装"**（Normal installation）
5. 分区选择 **"擦除磁盘并安装 Ubuntu"**（Erase disk and install Ubuntu）——放心，这里的"磁盘"是虚拟硬盘，不影响宿主机
6. 设置时区、用户名和密码
7. 等待安装完成，重启虚拟机
8. 安装完成后，记得在 VirtualBox 菜单 **"设备" → "安装增强功能"**（Guest Additions），以获得更好的显示效果、共享剪贴板和无缝鼠标切换

```bash
# 在虚拟机中安装 Guest Additions
# 首先挂载 Guest Additions 光盘镜像（设备 → 安装增强功能）
# 然后在终端中执行：
sudo apt update
sudo apt install build-essential dkms linux-headers-$(uname -r)
sudo mount /dev/cdrom /mnt
cd /mnt
sudo ./VBoxLinuxAdditions.run
sudo reboot
```

---

### 云服务器方式

拥有一台真实的云服务器是做实验的绝佳方式。你可以从任何地方 SSH 连接它，体验真实的服务器管理。

#### 学生优惠

| 云厂商 | 优惠方案 |
|--------|---------|
| **阿里云** | "飞天加速计划"：学生认证后可免费领取 1-6 个月的 ECS 云服务器（1 核 2G 配置） |
| **腾讯云** | "云 + 校园"计划：学生优惠价约 10 元/月 |

#### 连接云服务器

购买云服务器后，运维面板会提供公网 IP 地址和初始 root 密码。

**Windows SSH 客户端**：

Windows 10/11 内置了 OpenSSH 客户端，可以直接在 PowerShell 或 cmd 中使用：

```powershell
ssh root@你的服务器IP地址
```

首次连接会提示确认指纹，输入 `yes`，然后输入密码。

更多选择：**Windows Terminal**（微软商店免费下载）比传统 cmd 好用得多，支持多标签、分屏、自定义配色。推荐搭配 PowerShell 一起使用。

**macOS / Linux 终端 SSH**：

```bash
ssh root@你的服务器IP地址
```

**使用 SSH 密钥登录（更安全）**：

```bash
# 在本地电脑生成密钥对（如果还没有）
ssh-keygen -t ed25519 -C "你的邮箱"

# 将公钥复制到远程服务器
ssh-copy-id root@你的服务器IP地址

# 之后 SSH 连接无需输入密码
ssh root@你的服务器IP地址
```

#### 云服务器初始设置

```bash
# 连接上云服务器后，首先创建普通用户（不要总用 root！）
adduser myuser
usermod -aG sudo myuser

# 切换为普通用户
su - myuser

# 更新系统
sudo apt update
sudo apt upgrade -y

# 设置主机名
sudo hostnamectl set-hostname my-server

# 查看系统信息
uname -a
lsb_release -a
```

---

### 双系统（简要说明）

双系统指在一台电脑上同时安装 Windows 和 Linux，开机时通过引导菜单（GRUB）选择启动哪个系统。

**优点**：获得原生硬件性能，适合重度 Linux 桌面使用者。

**缺点**：
- 安装过程复杂，需要手动分区
- 可能因引导程序冲突导致系统无法启动
- 切换系统需要重启电脑

> **建议**：初学者优先使用 WSL2 或虚拟机。当你已经熟练使用 Linux 半年以上，再考虑双系统也不迟。

---

## 第一次进入 Linux

### 终端是什么

**终端（Terminal）** 是人与操作系统交互的文本界面。早期的 Unix 系统通过物理终端机（一台显示器 + 键盘，像 VT-100 这样的设备）连接到主机。今天我们使用的"终端"是**终端模拟器**（Terminal Emulator）——一个软件窗口，模拟了那些老式终端的功能。

在终端里面运行的程序叫做 **Shell**（壳）。Shell 是一个命令解释器，它接收你输入的命令，翻译后交给内核执行，然后将结果返回给你。

```
用户输入命令 → Shell 解释 → 系统调用 → 内核执行 → 结果返回 → Shell 显示
```

Shell 有很多种：

| Shell | 全称 | 说明 |
|-------|------|------|
| `sh` | Bourne Shell | 最早的 Unix shell，Stephen Bourne 开发 |
| `bash` | Bourne Again Shell | GNU 对 sh 的增强版本，**Linux 默认 shell** |
| `zsh` | Z Shell | bash 的增强版，macOS 默认 shell，支持强大插件生态 |
| `fish` | Friendly Interactive Shell | 开箱即用的友好 shell，自动补全和语法高亮极佳 |
| `dash` | Debian Almquist Shell | 轻量 sh，Debian/Ubuntu 中 `/bin/sh` 指向它 |

查看当前使用的 shell：

```bash
echo $SHELL
```

输出示例：
```
/bin/bash
```

查看系统安装了哪些 shell：

```bash
cat /etc/shells
```

输出示例：
```
# /etc/shells: valid login shells
/bin/sh
/bin/bash
/usr/bin/bash
/bin/rbash
/usr/bin/rbash
/bin/dash
/usr/bin/dash
```

---

### 提示符的含义

打开终端后，你会看到类似这样的提示符：

```bash
john@ubuntu:~$
```

拆解如下：

| 部分 | 含义 | 示例值 |
|------|------|--------|
| `john` | 当前登录的用户名 | john |
| `@` | 分隔符，读作 "at" | — |
| `ubuntu` | 主机名（hostname） | ubuntu |
| `:` | 分隔符 | — |
| `~` | 当前工作目录（`~` = 家目录） | /home/john |
| `$` | 提示符结束符：`$` 表示普通用户，`#` 表示 root 用户 | `$` |

完整示例对比：

```bash
# 普通用户在自家目录
john@ubuntu:~$

# 普通用户在 /etc 目录
john@ubuntu:/etc$

# root 用户在自家目录
root@ubuntu:~#
```

查看并修改提示符：

```bash
# 查看当前提示符的变量
echo $PS1

# 临时改为简单提示符
PS1='\$ '

# 恢复（重新登录即可，或重新加载配置）
source ~/.bashrc
```

输出示例（`echo $PS1`）：
```
\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$
```

> 这串代码看着复杂，其实是给提示符加了颜色。简单来说 `\u` = 用户名，`\h` = 主机名，`\w` = 当前路径。

---

### 第一条命令

现在，输入你的第一条 Linux 命令：

```bash
echo "Hello, Linux!"
```

输出：
```
Hello, Linux!
```

`echo` 是最简单的命令之一——它把参数原样输出到屏幕上。

再试几条：

```bash
# 查看当前日期和时间
date
```

输出示例：
```
Mon Jul 27 15:30:42 CST 2026
```

```bash
# 查看当前有哪些用户登录
who
```

输出示例：
```
john     pts/0        2026-07-27 15:28 (172.26.128.1)
```

```bash
# 查看当前所在的目录
pwd
```

输出示例：
```
/home/john
```

```bash
# 查看当前目录下的文件
ls -la
```

输出示例：
```
total 28
drwxr-x--- 3 john john 4096 Jul 27 15:28 .
drwxr-xr-x 3 root root 4096 Jul 27 15:10 ..
-rw-r--r-- 1 john john  220 Jul 27 15:10 .bash_logout
-rw-r--r-- 1 john john 3771 Jul 27 15:10 .bashrc
drwxr-xr-x 2 john john 4096 Jul 27 15:10 .landscape
-rw-r--r-- 1 john john  807 Jul 27 15:10 .profile
```

---

### 退出终端和注销

```bash
# 退出当前 shell（关闭终端窗口）
exit

# 或者使用快捷键
# Ctrl + D
```

`exit` 和 `Ctrl+D` 的区别：
- `exit` 是一个 shell 内置命令
- `Ctrl+D` 向 shell 发送 EOF（End of File）信号，shell 收到后自动退出

两者效果相同。

```bash
# 注销（从图形界面登出）
# 在桌面环境中，点击右上角电源图标 → 注销
# 在纯终端（tty）中：
logout
```

---

## WSL2 上手实战

> 本节假设你已按前面 [[#WSL2（Windows Subsystem for Linux）—— 强烈推荐|WSL2 章节]] 完成了安装。如果还没有，请先完成安装再回来。

### 启动 WSL2

在 Windows 中打开 **Windows Terminal**（或 PowerShell），输入：

```powershell
wsl
```

你将看到类似下面的输出：
```
Welcome to Ubuntu 24.04.1 LTS (GNU/Linux 5.15.153.1-microsoft-standard-WSL2 x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Mon Jul 27 15:30:00 CST 2026

  System load:  0.0                Processes:             20
  Usage of /:   0.1% of 250.98GB   Users logged in:       1
  Memory usage: 1%                 IPv4 address for eth0: 172.26.128.1
  Swap usage:   0%

This message is shown once a day. To disable it with:
touch /home/john/.hushlogin

john@DESKTOP-ABC:~$
```

### 更新系统

第一步永远是更新系统——获取最新的软件包列表和安全补丁。

```bash
# 更新软件包列表
sudo apt update
```

输出示例：
```
[sudo] password for john:
Hit:1 http://archive.ubuntu.com/ubuntu noble InRelease
Get:2 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Get:3 http://archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:4 http://archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
Fetched 378 kB in 1s (295 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
7 packages can be upgraded. Run 'apt list --upgradable' to see them.
```

注意输出末尾的 `7 packages can be upgraded.`——说明有 7 个软件包可以升级。

```bash
# 查看有哪些包可以升级
apt list --upgradable
```

输出示例：
```
Listing... Done
openssh-client/noble-updates 1:9.6p1-3ubuntu13.5 amd64 [upgradable from: 1:9.6p1-3ubuntu13]
python3-update-manager/noble-updates 1:24.04.7 all [upgradable from: 1:24.04.2]
...
```

```bash
# 升级所有可升级的包
sudo apt upgrade -y
```

输出示例：
```
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Calculating upgrade... Done
The following packages will be upgraded:
  openssh-client python3-update-manager
  ... (省略中间输出)
7 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Need to get 2,456 kB of archives.
After this operation, 0 B of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 openssh-client ...
...
Setting up openssh-client (1:9.6p1-3ubuntu13.5) ...
Processing triggers for man-db (2.12.0-4build2) ...
```

`-y` 参数表示自动回答 "yes"，跳过升级确认。

### 创建第一个文件

```bash
# 确认当前目录
pwd
```

输出：
```
/home/john
```

```bash
# 创建一个文件
echo "hello" > test.txt
```

`>` 是重定向符号，将 `echo "hello"` 的输出写入到 `test.txt` 文件中（如果文件不存在则创建）。

```bash
# 查看文件内容
cat test.txt
```

输出：
```
hello
```

```bash
# 往文件追加内容
echo "world" >> test.txt
```

`>>` 是追加重定向，将内容追加到文件末尾（不会覆盖原有内容）。

```bash
# 再次查看文件内容
cat test.txt
```

输出：
```
hello
world
```

### 创建第一个目录

```bash
# 创建一个名为 my_first_folder 的目录
mkdir my_first_folder

# 确认目录已创建
ls -l
```

输出示例：
```
total 4
drwxr-xr-x 2 john john 4096 Jul 27 15:35 my_first_folder
-rw-r--r-- 1 john john   12 Jul 27 15:34 test.txt
```

注意 `d` 开头的那行——`d` 表示这是一个目录（directory）。

```bash
# 进入目录
cd my_first_folder

# 在目录内创建一个文件
echo "I'm inside a folder" > inside.txt

# 返回上级目录
cd ..

# 查看目录内文件
ls my_first_folder
```

输出：
```
inside.txt
```

### 探索系统

现在来做一些探索，熟悉一下 Linux 的"地盘"。

```bash
# 查看内核版本
uname -a
```

输出示例：
```
Linux DESKTOP-ABC 5.15.153.1-microsoft-standard-WSL2 #1 SMP Fri Mar 29 23:14:13 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
```

```bash
# 查看发行版信息
lsb_release -a
```

输出示例：
```
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 24.04.1 LTS
Release:        24.04
Codename:       noble
```

```bash
# 查看磁盘使用情况
df -h
```

输出示例：
```
Filesystem      Size  Used Avail Use% Mounted on
none            3.9G     0  3.9G   0% /mnt/wsl
/dev/sdc        251G  2.7G  236G   2% /
...
```

```bash
# 查看内存使用情况
free -h
```

输出示例：
```
               total        used        free      shared  buff/cache   available
Mem:           7.7Gi       253Mi       7.2Gi       3.0Mi       483Mi       7.5Gi
Swap:          2.0Gi          0B       2.0Gi
```

```bash
# 查看 CPU 信息
cat /proc/cpuinfo | grep "model name" | head -1
```

输出示例：
```
model name      : Intel(R) Core(TM) i7-10750H CPU @ 2.60GHz
```

### 安装第一个软件

```bash
# 安装 neofetch（系统信息展示工具）
sudo apt install neofetch -y
```

安装完成后运行：

```bash
neofetch
```

输出示例（ASCII 艺术 Logo + 系统信息）：
```
            .-/+oossssoo+/-.
        `:+ssssssssssssssssss+:`           john@DESKTOP-ABC
      -+ssssssssssssssssssyyssss+-         ----------------
    .ossssssssssssssssssdMMMNysssso.       OS: Ubuntu 24.04.1 LTS on Windows 10 x86_64
   /ssssssssssshdmmNNmmyNMMMMhssssss/      Kernel: 5.15.153.1-microsoft-standard-WSL2
  +ssssssssshmydMMMMMMMNddddyssssssss+     Uptime: 5 mins
 /sssssssshNMMMyhhyyyyhmNMMMNhssssssss/    Packages: 523 (dpkg)
.ssssssssdMMMNhsssssssssshNMMMdssssssss.   Shell: bash 5.2.21
+sssshhhyNMMNyssssssssssssyNMMMysssssss+   Terminal: Windows Terminal
ossyNMMMNyMMhsssssssssssssshmmmhssssssso   CPU: Intel i7-10750H (12) @ 2.592GHz
ossyNMMMNyMMhsssssssssssssshmmmhssssssso   Memory: 253MiB / 7886MiB
+sssshhhyNMMNyssssssssssssyNMMMysssssss+
.ssssssssdMMMNhsssssssssshNMMMdssssssss.
 /sssssssshNMMMyhhyyyyhhNMMMNhssssssss/
  +ssssssssshmydMMMMMMMNddddyssssssss+
   /ssssssssssshdmmNNmmyNMMMMhssssss/
    .ossssssssssssssssssdMMMNysssso.
      -+sssssssssssssssssyyyssss+-
        `:+ssssssssssssssssss+:`
            .-/+oossssoo+/-.
```

---

## 终端快捷键速查

在继续学习之前，掌握以下快捷键能极大提升你的终端效率：

| 快捷键 | 功能 |
|--------|------|
| `Ctrl + C` | 终止当前正在运行的命令 |
| `Ctrl + D` | 退出当前 shell 或发送 EOF（文件结束符） |
| `Ctrl + L` | 清屏（相当于执行 `clear` 命令） |
| `Ctrl + A` | 光标跳到命令行开头 |
| `Ctrl + E` | 光标跳到命令行结尾 |
| `Ctrl + U` | 删除光标之前的所有内容 |
| `Ctrl + K` | 删除光标之后的所有内容 |
| `Ctrl + W` | 删除光标前的一个单词 |
| `Ctrl + R` | 反向搜索历史命令 |
| `Ctrl + Z` | 将当前进程挂起到后台 |
| `↑ / ↓` | 浏览上一条/下一条历史命令 |
| `Tab` | 自动补全命令或文件名 |

实践一下：

```bash
# 按 Ctrl+R，然后输入 "apt" 搜索历史命令
# (reverse-i-search)`apt': sudo apt update
```

```bash
# 用 Tab 补全：输入 "ls /etc/apa"，然后按 Tab
# 会补全为 "ls /etc/apache2/"（如果有这个目录的话）
```

---

## 常用帮助命令

学习 Linux 最重要的能力不是记住所有命令，而是**知道如何查帮助**。

### `--help` — 最快的帮助

大多数命令都支持 `--help` 参数，输出简短的使用说明：

```bash
ls --help
```

输出示例（部分）：
```
Usage: ls [OPTION]... [FILE]...
List information about the FILEs (the current directory by default).
Sort entries alphabetically if none of -cftuvSUX nor --sort is specified.

Mandatory arguments to long options are mandatory for short options too.
  -a, --all                  do not ignore entries starting with .
  -A, --almost-all           do not list implied . and ..
      --author               with -l, print the author of each file
  -l                         use a long listing format
  -h, --human-readable       with -l and -s, print sizes like 1K 234M 2G
...
```

### `man` — 完整的参考手册

`man`（manual 的缩写）显示命令的完整手册页：

```bash
man ls
```

进入 man 页面后的操作：

| 按键 | 功能 |
|------|------|
| `↑ / ↓` 或 `j / k` | 上下滚动一行 |
| `Space` 或 `f` | 向下翻一页 |
| `b` | 向上翻一页 |
| `/搜索词` | 搜索关键词（按 `n` 下一个，`N` 上一个） |
| `g` | 跳到开头 |
| `G` | 跳到末尾 |
| `q` | 退出 |

**man 手册的分节**：

```
1   用户命令（如 ls, cp, cat）
2   系统调用（如 open, read, write）
3   库函数（如 printf, malloc）
4   特殊文件（如 /dev/null, /dev/zero）
5   文件格式和约定（如 /etc/passwd 的格式）
6   游戏（如 fortune）
7   杂项（如 tcp, ip, socket）
8   系统管理命令（如 mount, fdisk, useradd）
```

```bash
# 查看特定节的手册
man 5 passwd    # 查看 /etc/passwd 文件的格式说明
man 8 mount     # 查看 mount 命令（系统管理版）
```

### `info` — 超文本手册

GNU 项目提供了 `info` 格式的文档，比 man 更详细，支持超链接跳转：

```bash
info ls
```

### `tldr` — 常见用法速查（推荐安装）

`tldr`（Too Long; Didn't Read）提供了命令的简洁示例，比 man 友好得多：

```bash
# 先安装 tldr
sudo apt install tldr -y

# 使用
tldr ls
```

输出示例：
```
  ls
  List directory contents.
  More information: https://www.gnu.org/software/coreutils/ls.

  - List files one per line:
    ls -1

  - List all files, including hidden files:
    ls -a

  - Long format list (permissions, ownership, size and modification date) of all files:
    ls -la

  - Long format list with size displayed using human-readable units (KiB, MiB, GiB):
    ls -lh

  - Long format list sorted by size (descending):
    ls -lS

  - Long format list sorted by modification time (oldest first):
    ls -ltr
```

### `whatis` 和 `apropos` — 搜索命令

```bash
# 查看命令的简短描述
whatis ls
```

输出：
```
ls (1)               - list directory contents
```

```bash
# 根据关键词搜索相关命令
apropos "directory"
```

输出示例（部分）：
```
basename (1)         - strip directory and suffix from filenames
chdir (2)            - change working directory
dir (1)              - list directory contents
ls (1)               - list directory contents
mkdir (1)            - make directories
pwd (1)              - print name of current/working directory
rmdir (1)            - remove empty directories
```

---

## 总结

本章带你完成了 Linux 世界的"入门仪式"：

1. **理解了 Linux 的起源**：从 Unix → GNU → Linux 的三段式历史，认识了 Ken Thompson、Dennis Ritchie、Richard Stallman、Linus Torvalds 四位关键人物
2. **理解了"自由"的含义**：自由软件 ≠ 免费软件，四项基本自由构成了整个开源运动的思想基础
3. **认识了主流发行版**：Debian 系（Ubuntu/Mint）、Red Hat 系（RHEL/Fedora）、Arch 系三种流派，以及各自的包管理器
4. **动手安装了 Linux**：WSL2（首选）、虚拟机、云服务器、双系统四种方式，每种都有具体的操作步骤
5. **完成了第一次命令行交互**：认识了提示符、执行了第一条命令、学会了退出终端
6. **完成了 WSL2 上手实战**：更新系统、创建文件/目录、探索系统信息、安装了第一个软件
7. **学会了求助**：`--help`、`man`、`tldr`、`whatis`、`apropos` 五件套，从此不再因为记不住命令而困扰

---

## 习题与实践

### 基础题

1. 用自己的话解释：什么是操作系统？内核和完整的操作系统有什么区别？
2. GNU 计划的目标是什么？为什么 Stallman 要发起这个计划？
3. 什么是开源软件的四项基本自由？
4. Linux、Unix、GNU/Linux 三者的关系是什么？用一段话概括。
5. 简述 Debian 系、Red Hat 系、Arch 系的区别：它们的包管理器分别是什么？各自适合什么场景？

### 动手题

1. 在 WSL2（或虚拟机）中完成以下操作，并记录每一步的输出：
   - 更新软件包列表
   - 升级所有软件包
   - 安装 `tree` 软件包（`sudo apt install tree`）
   - 在家目录下创建一个名为 `linux_practice` 的目录
   - 在该目录下创建三个文件：`a.txt`、`b.txt`、`c.txt`
   - 用 `tree` 命令查看目录结构
   - 用 `cat` 命令查看其中一个文件的内容

2. 使用 `man ls` 命令浏览 `ls` 的手册页，找到以下参数的含义：
   - `-l` 参数的作用
   - `-a` 参数的作用
   - `-h` 参数的作用
   - `-t` 参数的作用
   - `-r` 参数的作用
   然后用实际文件测试这些参数的效果。

3. 搜索练习：
   - 使用 `apropos` 搜索与 "network" 相关的命令
   - 使用 `tldr` 查看 `grep` 命令的常见用法
   - 使用 `whatis` 查看 `top` 命令的简短描述

4. 探索系统：
   - 用 `uname -a` 查看内核版本
   - 用 `df -h` 查看磁盘空间
   - 用 `free -h` 查看内存信息
   - 用 `cat /proc/cpuinfo | head -20` 查看 CPU 详细信息
   - 用 `who` 查看当前登录用户

### 思考题

1. 有人认为 Linux 的成功主要是因为"免费"。你同意这个观点吗？除了价格因素，Linux 还有哪些特质使其成为服务器领域的主导者？
2. 如果你要向一位只使用过 Windows 的朋友推荐 Linux，你会推荐哪个发行版？请说明理由。
3. WSL2 和虚拟机各有什么优缺点？在什么情况下你会选择 WSL2，什么情况下选择虚拟机？
