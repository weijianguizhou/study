# 学习笔记

> 个人学习笔记库，覆盖数学、物理、力学、机器人学、人工智能、深度学习、强化学习等领域。
> 使用 [Obsidian](https://obsidian.md/) 管理 Markdown 笔记，配合 LaTeX 撰写系统性教程。

---

## 如何使用

### 浏览笔记（推荐）

用 **Obsidian** 打开此文件夹作为 Vault，即可使用：

- **图谱视图**：可视化 430+ 条笔记之间的关联网络
- **双向链接 `[[...]]`**：点击跳转相关知识点
- **全文搜索**：快速定位任意概念
- **LaTeX 公式渲染**：`$...$` 和 `$$...$$` 开箱即用

### 编译 LaTeX 教程

部分系统性教程为 `.tex` 文件，需用 **XeLaTeX** 编译：

```bash
# 以深度学习教程为例
cd 人工智能/深度学习教程/LaTeX
xelatex -interaction=nonstopmode main.tex
xelatex -interaction=nonstopmode main.tex   # 二次编译生成目录
```

> 要求：TeX Live 2024+，已配置中文字体（ctex 宏包）。

---

## 目录结构

```
├── README.md                          # 本文件
├── 00-知识索引.md                     # 全库 MOC（Map of Content）
│
├── 数理基础/                          # 数学各分支
│   ├── 数理基础.md                    #   数学 MOC
│   ├── 数学分析.md                    #   极限、导数、积分、级数
│   ├── 代数/                          #   线性代数、多项式、Hurwitz 矩阵
│   ├── 概率论.md                      #   概率空间、随机变量、大数定律
│   ├── 数理统计.md                    #   参数估计、假设检验
│   ├── ODE常微分方程.md               #   存在唯一性、线性系统
│   ├── 微分方程与动力系统.md          #   平衡解、稳定性、极限环
│   ├── 随机微分方程SDE.md             #   Itô 积分、布朗运动
│   ├── 向量微积分.md                  #   梯度、散度、旋度
│   ├── 微分几何.md                    #   Frenet 标架、曲率
│   ├── 凸优化.md                      #   凸集、KKT、梯度下降
│   ├── 工程数学/                      #   Laplace/Fourier/Z 变换、复变函数、场论
│   └── 统计学分析方法/                #   熵权法、TOPSIS、差分方程
│
├── 力学/                              # 理论力学、材料力学、动力学
│   ├── 力学.md                        #   力学 MOC
│   ├── 静力学/                        #   静力学基础、公理、约束
│   ├── 动力学/                        #   质点动力学、动量/动量矩/动能定理
│   ├── 理论力学/                      #   桁架零杆判断
│   ├── 分析力学笔记.tex               #   拉格朗日力学
│   ├── 矢量力学笔记.tex               #   牛顿力学
│   ├── 材料力学/                      #   完整材料力学教程（.tex，多章节）
│   ├── 多体系统传递矩阵法.md          #   传递矩阵、坐标变换
│   ├── 生物力学.md                    #   三大解剖平面
│   ├── 系统动力学建模与仿真/          #   .tex 教程（10 章）
│   └── Spacecraft_Dynamics/           #   航天器动力学（.tex）
│
├── 机器人学/                          # 机器人运动学与动力学
│   ├── 现代机器人学笔记.tex           #   位形空间、运动学
│   └── DH参数法/                      #   DH 参数法完整教程（.tex + .md）
│
├── 刚体动力学算法/                    # Featherstone 刚体动力学
│   ├── 刚体动力学算法.tex             #   主教程
│   └── 空间向量代数/                  #   空间速度、空间力、Plücker 坐标
│
├── 人工智能/                          # AI/ML/RL/DL 综合
│   ├── 人工智能.md                    #   AI MOC
│   │
│   ├── 深度学习教程/                  #   深度学习系统教程
│   │   ├── 00-深度学习索引.md         #       教程 MOC
│   │   ├── 01~12 .md 笔记            #       线代→微积分→CNN→Transformer→大模型
│   │   └── LaTeX/                     #       172 页完整 LaTeX 教程
│   │
│   ├── 强化学习系统教程/              #   强化学习系统教程
│   │   ├── main.tex                   #       102 页 LaTeX 教程（12 章）
│   │   └── Chapter01~12.tex           #       数学基础→MDP→DP→DQN→PPO→机器人控制
│   │
│   ├── 马尔可夫决策过程.md            #   MDP 完整推导（Bellman 方程）
│   ├── RL-PPO理论.md                  #   PPO 完整推导（策略梯度→Clip→GAE）
│   ├── RL-动态规划与TD.md             #   DP/MC/TD/SARSA/Q-Learning
│   ├── RL-DQN与值函数近似.md          #   DQN/Double/Dueling/PER/Rainbow
│   ├── RL-策略梯度.md                 #   Policy Gradient/Actor-Critic/GAE
│   ├── RL-机器人控制.md              #   MuJoCo/Sim-to-Real/域随机化
│   ├── 基于Agent的建模.md             #   ABM
│   ├── 时间序列预测.md                #   ARIMA、深度学习预测
│   └── 机器学习与深度学习/            #   绪论、符号表
│
├── 普通物理/                          # 电磁学、量子力学
│   ├── 电磁学.md                      #   静电场、磁场、Maxwell 方程组
│   ├── 量子光学.md                    #   黑体辐射、Compton 散射
│   ├── 原子的量子理论笔记.md          #   氢原子光谱、Bohr 模型
│   └── 量子世界/                      #   波函数、薛定谔方程、不确定性原理
│
├── 自动控制原理/                      # 控制理论
│   └── 自动控制原理基础/              #   .tex 教程
│
├── 电类/                              # 模拟电路
│   └── 模拟电路/                      #   BJT、FET、放大电路（.md + .tex）
│
├── 机械/                              # 机械原理、制图
│   ├── 机械原理/                      #   连杆/凸轮/齿轮机构（.tex）
│   └── 机械制图/                      #   SOLIDWORKS 使用指南
│
├── 计算机类/                          # 计算机基础
│   ├── 计算机/                        #   数据结构、作业
│   ├── TensorFlow/                    #   神经网络计算
│   ├── 机器学习/                      #   K-means、YOLO（.tex）
│   └── R语言/                         #   R 自学笔记（.tex）
│
├── Mujoco/                            # MuJoCo 仿真引擎
│   ├── Overview.md                    #   概述
│   ├── Modeling 建模.md              #   MJCF 建模
│   ├── Benchmark 基准.md             #   强化学习环境
│   └── 代码设计的方法论.md            #   控制与可视化代码
│
└── 学术汇报/                          # 学术报告
    ├── 讲稿.tex
    ├── 英文学术汇报.tex
    └── ALL you need is attention.tex
```

---

## 特色内容

### 深度学习（172 页 LaTeX + 12 章 .md）

从线性代数基础到 CNN、Transformer、BERT、GPT、Llama、DeepSeek。每章含 Python 代码示例。

📂 `人工智能/深度学习教程/`

### 强化学习（102 页 LaTeX + 6 篇 .md）

从 MDP 的 Bellman 方程开始，经 DP/MC/TD/DQN/Policy Gradient，到 PPO/SAC 在机器人控制中的应用。

📂 `人工智能/强化学习系统教程/`

### DH 参数法（26 页 LaTeX + .md 速查）

Denavit-Hartenberg 参数法的完整推导，含标准 DH 与改进 DH（Craig）对比、PUMA 560 实例。

📂 `机器人学/DH参数法/`

### 材料力学（完整 LaTeX 教程）

轴向拉压 → 剪切 → 扭转 → 弯曲 → 应力状态 → 组合变形 → 压杆稳定 → 能量法。

📂 `力学/材料力学/`

---

## 技术栈

| 用途 | 工具 |
|------|------|
| 笔记管理 | Obsidian + Wiki-link |
| 系统教程 | LaTeX (XeLaTeX + ctex + TikZ) |
| 编程示例 | Python (NumPy, PyTorch) |
| 版本管理 | Git + Gitee |

---

## 关联

- 个人网站：[https://www.rethink.fun](https://www.rethink.fun)（深度学习教程来源）
- B 站：[RethinkFun](https://space.bilibili.com/18235884)
- 深度学习参考书：《大模型核心技术和应用》（清华大学出版社）
