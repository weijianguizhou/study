# Linux 使用教程 · 索引

> **Map of Content** — 本系列教程面向 Linux 初学者，从零开始系统学习 Linux 操作系统。
> 建议按顺序阅读，每章配有大量实操示例和习题。

---

## 章节总览

| 章号 | 标题 | 核心内容概要 |
|:---:|------|-------------|
| 01 | [[01-Linux概述与安装\|Linux概述与安装]] | 操作系统概念、Unix/GNU/Linux 历史、开源哲学、发行版对比、WSL2/虚拟机/云服务器安装、终端初体验 |
| 02 | [[02-文件系统与目录结构\|文件系统与目录结构]] | "一切皆文件"理念、七种文件类型、FHS 目录树标准（/、/etc、/proc、/usr 等）、绝对/相对路径、inode 与硬链接/软链接 |
| 03 | 基本命令 · 文件操作 | `ls` `cd` `pwd` `mkdir` `rmdir` `cp` `mv` `rm` `touch` `stat`——增删改查一站式掌握 |
| 04 | 基本命令 · 文本处理 | `cat` `tac` `more` `less` `head` `tail` `grep` `wc` `sort` `uniq` `cut` `paste` `diff`——文本查看、过滤、统计、比较 |
| 05 | 用户与权限管理 | 用户/组概念、`/etc/passwd` `/etc/shadow` `/etc/group`、`useradd` `usermod` `userdel` `groupadd`、`chmod` `chown` `chgrp`、rwx 权限体系、SUID/SGID/Sticky Bit |
| 06 | 输入输出重定向与管道 | 标准输入/输出/错误流（stdin/stdout/stderr）、`>` `>>` `<` `2>` `&>`、管道 `\|`、`tee`、`xargs`、here document、here string |
| 07 | Shell 与脚本编程 | Shell 类型（bash/zsh/fish）、变量与参数、条件判断（`if`/`case`）、循环（`for`/`while`/`until`）、函数、数组、`cron` 定时任务 |
| 08 | 软件包管理 | APT（Ubuntu/Debian）、DNF/YUM（Fedora/RHEL）、Pacman（Arch）、源码编译安装（`./configure && make && make install`）、依赖管理 |
| 09 | 进程与服务管理 | 进程概念、`ps` `top` `htop` `kill` `nice`、前台/后台/守护进程、`systemctl` 服务管理、`journalctl` 日志 |
| 10 | 网络管理与远程连接 | `ip` `ping` `ss` `netstat` `curl` `wget`、SSH 远程登录与密钥认证、`scp` `rsync` 文件传输、`ufw`/`iptables` 防火墙基础 |

---

## 参考书目

| 书名 | 作者 | 说明 |
|------|------|------|
| 《鸟哥的 Linux 私房菜——基础学习篇》 | 鸟哥（蔡德明） | 华人世界最经典的 Linux 入门书，示例丰富，语言风趣 |
| 《The Linux Command Line》 | William Shotts | 英文最佳命令行入门书，免费 PDF，循序渐进 |
| 《UNIX 环境高级编程》（APUE） | W. Richard Stevens | 进阶必读，深入理解系统调用和 UNIX 编程模型 |
| 《Linux 内核设计与实现》 | Robert Love | 从内核开发者视角理解 Linux 内部机制 |
| 《How Linux Works》 | Brian Ward | 讲解 Linux 系统各组件如何协同工作 |
| 《Linux 命令行与 shell 脚本编程大全》 | Richard Blum | Shell 编程大全，从基础到高级技巧 |

---

## 学习路线建议

### 阶段一：入门上手（第 1-4 章）
1. 阅读 [[01-Linux概述与安装|第 1 章]]，了解 Linux 的来龙去脉，安装 WSL2 或虚拟机环境
2. 阅读 [[02-文件系统与目录结构|第 2 章]]，理解文件系统和目录树——这是 Linux 的骨架
3. 练习 [[#^tab-ch3|第 3 章]] 文件操作命令，每天操作 30 分钟
4. 练习 [[#^tab-ch4|第 4 章]] 文本处理命令，利用管道组合命令解决问题

### 阶段二：基础巩固（第 5-6 章）
5. 学习 [[#^tab-ch5|第 5 章]] 权限管理，理解多用户协作模型
6. 掌握 [[#^tab-ch6|第 6 章]] 重定向和管道，这是 UNIX 哲学的精华

### 阶段三：自动化与效率（第 7-8 章）
7. 学习 [[#^tab-ch7|第 7 章]] Shell 脚本，用脚本代替重复操作
8. 掌握 [[#^tab-ch8|第 8 章]] 包管理，学会安装、更新、卸载软件

### 阶段四：系统运维（第 9-10 章）
9. 学习 [[#^tab-ch9|第 9 章]] 进程与服务，理解系统的运行时状态
10. 掌握 [[#^tab-ch10|第 10 章]] 网络与远程，进军服务器领域

---

## 实验环境准备

- **Windows 用户**：推荐 WSL2（Windows Subsystem for Linux），详见 [[01-Linux概述与安装#WSL2 上手实战|第 1 章]]
- **macOS 用户**：macOS 自带终端和大多数 GNU 工具，也可安装 Homebrew + 虚拟机
- **云服务器**：学生可申请阿里云/腾讯云学生优惠，获取一台真实的 Linux 云主机用于练习

---

> **提示**：遇到不认识的命令时，随时使用 `man <命令>` 或 `<命令> --help` 查看帮助文档。学会自己阅读手册是成为 Linux 高手的必经之路。
