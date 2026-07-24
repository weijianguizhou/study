这是一份我自己使用`Git`的使用指南。包含了常见命令和曾经有过的报错。
# 零、`Git `官网从零安装 + 全局配置全套教程

## 1. 官网纯净下载（

Git 官方唯一地址：[https://git-scm.com/](https://git-scm.com/)

1. 打开官网，页面自动识别 Windows 系统，点击 **Download for Windows**

2. 选择 **64-bit Git for Windows Setup** 自动下载最新安装包

3. 下载完成后得到 `Git-xxx-64-bit.exe` 安装程序

## 2. 安装关键步骤

双击安装包启动安装，所有关键配置严格按照以下选择，避免后续报错：

1. 许可证页面：直接 **Next**

2. 安装路径：建议安装到 **D盘**（避免占用C盘空间），路径无中文、无空格，点击 **Next**

3. 组件选择：默认全部勾选，无需修改，**Next**

4. 开始菜单目录：默认即可，**Next**

5. 默认编辑器：推荐选择**Vim 默认** 或自行选择 VS Code，**Next**

6. 仓库默认分支：选择 **Let Git decide**（默认 master 分支，适配国内代码托管平台），**Next**

7. PATH 环境配置：选择 **Git from the command line and also from 3rd-party software**（核心！让CMD、PowerShell、VS Code终端都能识别git命令），**Next**

8. HTTPS 传输配置：默认 OpenSSL 即可，**Next**

9. 换行符配置：选择 **Checkout Windows-style, commit Unix-style line endings**（完美适配Windows开发，杜绝LF/CRLF报错），**Next**

10. 终端模拟器：默认 **MinTTY**（体验更佳），**Next**

11. 其余页面全部默认，最后点击 **Install** 完成安装

## 3. 全局账号配置

安装完成后，打开 Git Bash，执行以下全局配置（替换为自己的用户名和Gitee/注册邮箱），只需配置一次，永久生效

```bash
# 配置全局用户名（自定义，建议和Gitee昵称一致）
git config --global user.name "你的用户名"

# 配置全局邮箱（Gitee/GitHub注册邮箱）
git config --global user.email "你的邮箱@xxx.com"
```

## 4. 校验安装 & 配置是否成功

```bash
# 查看Git版本，验证安装成功
git --version

# 查看全局配置，验证账号配置生效
git config --global --list
```

出现版本号、用户名、邮箱信息，说明安装+配置完全成功。


### 6. 安装后常见问题排查

**问题1：终端提示 git 不是内部或外部命令**

原因：安装时未勾选PATH环境配置，重启终端；若无效重新安装，严格按照上述PATH选型配置。

**问题2：中文文件名乱码、状态显示异常**

执行上方 `core.quotepath false` 优化命令即可修复。

**问题3：推送无上游分支报错**

执行上方 `push.autoSetupRemote true` 永久配置，彻底解决。

---

# 一、首次项目初始化（仅第一次执行）

用于**本地文件夹首次关联远程 Git 仓库**

```bash
# 1. 初始化本地 Git 仓库
git init

# 2. 关联远程 Gitee 仓库
git remote add origin https://gitee.com/aichisha/machine-learning.git

# 3. 拉取远程仓库文件（解决新旧仓库不关联冲突）
git pull origin master --allow-unrelated-histories
```

---

# 二、日常开发标准工作流

**每次改完代码必执行**，完成一次版本存档+云端备份

```bash
# 1. 查看当前文件状态（可选，建议养成习惯）
git status

# 2. 将所有修改加入暂存区
git add .

# 3. 生成本地版本（打快照，务必写清楚更新内容）
git commit -m "更新：新增特征训练代码、模型文件"

# 4. 推送至云端 Gitee
git push
```

### 命令作用详解

- `git status`：查看哪些文件修改、新增、未提交
    
- `git add .`：暂存**全部**改动文件
    
- `git commit`：生成本地版本记录，相当于**游戏存档**
    
- `git push`：把本地存档同步到云端，防止代码丢失
    

---

# 三、版本回溯 & 高级操作

## 1. 查看所有历史版本

```bash
git log
```

作用：查看所有提交记录、版本号、修改时间，用于回退版本。

## 2. 代码改错，回退到历史版本（救急）

```bash
git reset --hard 你的版本号
```

作用：**强制还原**到指定版本，当前所有改动清空（谨慎使用）。

## 3. 本地代码乱了，用远程仓库覆盖本地

```bash
git fetch --all && git reset --hard origin/master
```

---

# 四、常见报错解决方案

## 1. 报错：remote origin already exists（远程仓库已存在）

```bash
git remote remove origin
```

执行后重新关联远程仓库即可。

## 2. 报错：fetch first / 远程有新代码冲突

```bash
git pull origin master --allow-unrelated-histories
```

## 3. 换行符 LF/CRLF 警告（Windows 必出现，无害）

```bash
git config core.autocrlf true
```

## 4. 报错：No configured push destination

原因：本地仓库未绑定任何远程推送地址

```bash
git remote add origin 你的仓库地址
git push -u origin master
```

## 5. 报错：当前分支无上游分支（master has no upstream branch）

**报错完整提示**：`fatal: The current branch master has no upstream branch.`

**报错原因**：本地 master 分支已关联远程仓库，但**未绑定推送追踪分支**，Git 不知道代码要推送到远程哪个分支。

**临时解决（单次生效）**

```bash
git push --set-upstream origin master
```

作用：绑定本地 master 与远程 master 分支，本次推送成功，后续可直接用 `git push`。

**永久解决**

```bash
git config --global push.autoSetupRemote true
```

作用：后续所有新分支推送时，自动绑定上游分支，再也不会报此错误。

## 6. 报错：rejected master -> master (fetch first)

**报错完整提示**：`error: failed to push some refs ... rejected master -> master (fetch first)`

**报错原因**：远程仓库（Gitee）自带初始化的 README 文件，**远程代码比本地新**，本地版本落后，Git 禁止直接覆盖推送，防止代码丢失。

**标准安全解决（推荐，保留远程+本地所有代码）**

```bash
# 拉取远程代码并合并，允许新旧仓库无关联合并
git pull origin master --allow-unrelated-histories
# 合并完成后正常推送
git push
```

**强制解决（新手极速用，覆盖远程初始化文件）**

```bash
git push -f origin master
```

注意：强制推送会覆盖远程仓库初始文件，仅全新空项目可用，已有重要代码严禁使用。

## 7. 报错：Your local changes would be overwritten by merge

**报错完整提示**：`error: Your local changes to the following files would be overwritten by merge`

**报错原因**：本地存在**未提交、未暂存的修改**，Git 检测到合并远程代码会覆盖本地改动，为保护数据终止合并。

**安全解决方案（保留本地修改，推荐）**

```bash
# 先保存本地所有修改
git add .
git commit -m "暂存本地修改"
# 再拉取远程合并
git pull origin master --allow-unrelated-histories
git push
```



**快速解决方案**

```bash
# 临时储藏本地改动
git stash
# 拉取远程合并
git pull origin master --allow-unrelated-histories
```

## 8. 合并自动进入 Vim 编辑界面（一堆波浪线）

**现象**：pull 合并后自动进入满屏 ~ 的编辑窗口，无法输入命令

**原因**：Git 需要你确认本次合并记录，属于正常流程不是报错

**退出方法（固定万能操作）**

键盘依次按下：**Esc** → 输入 **:wq** → **回车**

含义：保存合并信息并退出编辑界面

**退出后执行收尾命令**

```bash
git add .
git push
```

## 9. 报错：non-fast-forward 推送被拒

**报错完整提示**：`error: failed to push some refs ... non-fast-forward`

**报错核心原因**：远程仓库存在本地没有的提交记录（Gitee 初始化的 README、配置文件），本地分支版本落后于远程，Git 禁止直接覆盖推送，避免代码丢失。

**标准安全解法**

```bash
# 拉取远程代码并合并，兼容新旧无关联仓库
git pull origin master --allow-unrelated-histories
# 合并完成、解决冲突后，正常推送
git push
```

**全新项目极速解法（仅空仓库使用）**

```bash
# 强制覆盖远程初始化文件，适配全新本地项目
git push -f origin master
```

重要禁忌：仓库已有他人提交、重要远程代码时，**绝对禁止强制推送**，会清空远程代码。

---

# 五、项目干净配置：.gitignore 文件

在项目根目录新建 `.gitignore`，粘贴以下内容，自动忽略缓存、模型、配置文件，仓库整洁不杂乱。

```bash
# Python 缓存文件
__pycache__/
*.pyc
*.pyo

# 模型文件
*.tflite
*.h
*.h5
*.pth

# 编辑器配置
.idea/
.vscode/

# 系统文件 & 日志
build/
*.log
.DS_Store
```

---

# 六、极简总结（日常只背这4条）

```bash
git status
git add .
git commit -m "更新说明"
git push
```

---

# 七、完整首次上传全流程（一键复刻）

```bash
git init
git remote add origin https://gitee.com/aichisha/machine-learning.git
git pull origin master --allow-unrelated-histories
git add .
git commit -m "初次提交：完整机器学习项目代码"
git push
```

---

# 八、Windows 高频踩坑专属解决方案（重点）

### 1. 致命错误：git add. 报错

**错误写法（必报错）**

```bash
git add.
```

**正确写法（必须有空格）**

```bash
git add .
```

原因：Git 严格区分空格，`add.` 是非法命令，`add .` 才是添加所有文件。

## 2. 提交没效果、commit 提示 no changes

原因：**没有执行 git add**，所有修改未进入暂存区。

解决方案：先 add、再 commit、最后 push

## 3. 报错：fatal: No configured push destination

原因：本地 Git 仓库**未关联远程仓库**

解决方案：

```bash
git remote add origin 你的远程仓库地址
git push -u origin master
```

## 4. 中文文件名乱码 \347\250\240 问题

现象：git status 显示一堆数字编码，看不到中文文件名

解决方案（一键修复中文显示）：

```bash
git config --global core.quotepath false
```

作用：关闭 Git 中文转义，正常显示中文文件名。

## 5. Windows 换行符警告彻底关闭

```bash
git config --global core.autocrlf true
```

---

## 相关笔记

- [[数据结构|数据结构]]（代码版本管理）
- [[CMake使用指南/CMake使用指南|CMake 使用指南]]（项目的 Git + CMake 协作流程）
- [[Eigen库使用指南/README|Eigen 库]]（C++ 库项目的 Git 管理）
- [[TensorFlow/0.说明|TensorFlow 环境搭建]]（深度学习项目的版本控制）
```