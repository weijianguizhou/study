# Anaconda 使用教程

## 一、什么是 Anaconda

**Anaconda** 是一个开源的 Python/R 发行版，专门用于**科学计算**和**数据科学**。它解决了原生 Python 最头疼的几个问题：

- **包管理麻烦**：`pip install` 经常遇到依赖冲突、编译失败
- **环境隔离困难**：项目 A 需要 TensorFlow 1.x，项目 B 需要 TensorFlow 2.x，互相冲突
- **预装大量库**：安装 Anaconda 后直接拥有 NumPy、Pandas、Matplotlib、Jupyter 等 1500+ 科学计算包

核心组件：

| 组件 | 说明 |
|------|------|
| **Conda** | 包管理器与环境管理器（核心） |
| **Anaconda Navigator** | 图形化界面（新手友好） |
| **Jupyter Notebook / Lab** | 交互式编程环境 |
| **Spyder** | 科学计算 IDE |

> 注意区别：**Anaconda** 是完整发行版（约 3GB，预装大量包），**Miniconda** 是精简版（仅包含 Conda + Python，约 400MB，按需安装包）。日常开发推荐 Miniconda。

---

## 二、下载与安装

### 2.1 下载

- **官网下载（较慢）**：https://www.anaconda.com/download
- **清华镜像（国内推荐）**：https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/
- **Miniconda 下载**：https://docs.anaconda.com/miniconda/

选择对应操作系统（Windows / macOS / Linux）和 Python 版本（推荐 Python 3.10+）的安装包。

### 2.2 安装步骤（Windows）

1. 双击安装包 → **Next**
2. 同意协议 → **I Agree**
3. 选择安装类型：
   - **Just Me**（仅当前用户，推荐）
   - **All Users**（所有用户，需管理员权限）
4. 选择安装路径（**路径不要有中文和空格**，如 `C:\anaconda3`）
5. **关键选项**（安装过程中的 Advanced Options）：
   - ☑ **Add Anaconda to my PATH environment variable**（建议勾选，新手省心）
   - ☑ **Register Anaconda as my default Python**（建议勾选）
6. 点击 **Install** 等待完成

### 2.3 验证安装

打开终端（CMD / PowerShell / Terminal），运行：

```bash
conda --version
# 输出示例: conda 24.9.2

python --version
# 输出示例: Python 3.12.4
```

### 2.4 配置国内镜像源（加速下载）

创建或修改 conda 配置文件 `%USERPROFILE%\.condarc`（Windows）或 `~/.condarc`（Linux/macOS）：

```bash
# 生成 .condarc 文件（如果不存在）
conda config --set show_channel_urls yes
```

然后编辑 `.condarc`，写入以下内容（使用清华镜像）：

```yaml
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
```

清除缓存使配置生效：

```bash
conda clean -i
```

---

## 三、Conda 基本使用

### 3.1 环境管理（核心技能）

Conda 最强大的功能是**创建隔离的 Python 环境**，不同项目使用不同环境，互不干扰。

```bash
# 创建一个名为 myenv 的环境，指定 Python 版本
conda create -n myenv python=3.10

# 创建环境并同时安装包
conda create -n myenv python=3.10 numpy pandas

# 查看所有环境
conda env list

# 激活环境（Windows）
conda activate myenv

# 激活环境（Linux/macOS）
# conda activate myenv

# 退出当前环境
conda deactivate

# 删除环境
conda remove -n myenv --all

# 克隆环境
conda create -n newenv --clone oldenv
```

### 3.2 包管理

```bash
# 安装包
conda install numpy

# 安装指定版本
conda install numpy=1.26.0

# 安装多个包
conda install numpy pandas matplotlib

# 从 conda-forge 频道安装（包更全）
conda install -c conda-forge opencv

# 卸载包
conda remove numpy

# 更新包
conda update numpy

# 更新所有包
conda update --all

# 查看当前环境已安装的包
conda list

# 查看某个包的信息
conda info numpy

# 搜索可用的版本
conda search numpy
```

### 3.3 在 conda 环境中使用 pip

有些包在 conda 中找不到，需要用 pip 安装：

```bash
conda activate myenv
pip install flask django
```

> **原则**：优先用 `conda install`，conda 中没有再用 `pip install`。混用时尽量先装完所有 conda 包再装 pip 包，避免冲突。

---

## 四、实战示例

### 4.1 创建一个数据科学项目环境

```bash
# 1. 创建环境
conda create -n ds_project python=3.10

# 2. 激活环境
conda activate ds_project

# 3. 安装常用库
conda install numpy pandas matplotlib seaborn scikit-learn jupyter

# 4. 启动 Jupyter
jupyter notebook
```

### 4.2 创建 PyTorch / TensorFlow 深度学习环境

```bash
# PyTorch（根据 CUDA 版本选择命令，详见 pytorch.org）
conda create -n pytorch_env python=3.10
conda activate pytorch_env
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia

# TensorFlow
conda create -n tf_env python=3.10
conda activate tf_env
conda install tensorflow
```

### 4.3 导出与导入环境（项目共享）

```bash
# 导出当前环境的所有包到文件
conda env export > environment.yml

# 从文件创建环境（别人拿到你的项目后）
conda env create -f environment.yml

# 仅导出显式安装的包（轻量级）
conda list --explicit > spec-file.txt
conda create -n myenv --file spec-file.txt
```

---

## 五、常见问题

### 5.1 conda 命令找不到

- 安装时未勾选 "Add to PATH" → 手动将 `{安装目录}\Scripts` 和 `{安装目录}\condabin` 添加到系统 PATH
- 或在开始菜单打开 **Anaconda Prompt**（已自动配置环境）

### 5.2 下载速度慢 / 网络错误

- 按 2.4 节配置国内镜像源
- 或使用 `-c` 指定频道：`conda install -c conda-forge 包名`

### 5.3 conda 与 pip 冲突

同一个包先用 conda 装，再用 pip 装可能会覆盖或冲突。解决方法：**为每个项目创建独立环境**，不要在 base 环境中装太多包。

### 5.4 磁盘空间不足

```bash
# 清理包缓存（最有效）
conda clean -a

# 列出所有环境，删除不再使用的
conda env list
conda remove -n 旧环境 --all
```

---

## 六、推荐工作流程

```
为每个项目创建独立环境
  ↓
先用 conda install 安装包
  ↓
conda 中没有的再用 pip install
  ↓
完成开发后导出 environment.yml
  ↓
推送到 Git 仓库，方便他人复现
```

**命名规范建议**：

| 环境名 | 用途 |
|--------|------|
| `base` | 仅作入口，不安装项目包 |
| `ds_project` | 数据科学项目 |
| `pytorch_env` | 深度学习（PyTorch） |
| `tf_env` | 深度学习（TensorFlow） |
| `web_dev` | Web 开发（Django/Flask） |

---

## 参考链接

- [Anaconda 官方文档](https://docs.anaconda.com/)
- [Conda 用户指南](https://docs.conda.io/projects/conda/en/latest/user-guide/)
- [清华镜像站 Anaconda 帮助](https://mirrors.tuna.tsinghua.edu.cn/help/anaconda/)
