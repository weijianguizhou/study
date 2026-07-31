# VS Code R 配置完全指南（Windows）

> 适用于 VS Code 1.90+（2026年）

## 1. 前提条件

### 必需软件
| 软件 | 用途 | 下载地址 |
|------|------|----------|
| **VS Code** | 代码编辑器 | https://code.visualstudio.com |
| **R** | R 语言解释器 | https://cran.r-project.org/bin/windows/base/ |
| **Rtools**（可选） | 编译 R 包（Windows 必需） | https://cran.r-project.org/bin/windows/Rtools/ |

### 安装 R

1. 从 CRAN 下载 R for Windows: https://cran.r-project.org/bin/windows/base/
2. 运行安装程序，建议安装到默认路径 `C:\Program Files\R\R-4.x.x`
3. 安装时勾选 "Add R to the system PATH"（如有此选项）

### 安装 Rtools（编译包需要）

1. 下载与 R 版本匹配的 Rtools: https://cran.r-project.org/bin/windows/Rtools/
2. 运行安装程序，默认安装到 `C:\rtools4x`
3. 安装完成后重启终端

### 安装常用 R 包

```r
# 在 R 控制台中运行
install.packages(c("IRkernel", "tidyverse", "devtools", "languageserver"))
IRkernel::installspec(user = TRUE)
```

### 验证安装
```bash
R --version
Rscript --version
```

## 2. VS Code 扩展安装

`Ctrl+Shift+X` 打开扩展面板，安装以下扩展：

| 扩展名 | ID | 说明 |
|--------|-----|------|
| **R** | `REditorSupport.r` | R 语言核心扩展（必装） |
| **R Language Server** | `REditorSupport.r` | R 语言智能补全（已包含在上面） |
| **R Debugger** | `REditorSupport.r-debugger` | R 调试器 |
| **Quarto** | `quarto.quarto` | Quarto 文档支持（替代 R Markdown） |
| **R LSP Client** | `reditorsupport.r` | 语言服务器客户端 |
| **DataFrame Viewer** | `vscode.r` | 数据框查看器（已包含在 R 扩展中） |
| **Plot Viewer** | `vscode.r` | 图表查看器（已包含在 R 扩展中） |

### R 扩展依赖

安装以下 R 包（用于增强功能）：
```r
install.packages(c(
  "languageserver",    # LSP 语言服务器
  "lintr",             # 代码检查
  "styler",            # 代码格式化
  "jsonlite",          # JSON 支持
  "httpgd",            # 图形设备
  "IRkernel",          # Jupyter 内核
  "readr",             # 数据读取
  "dplyr",             # 数据处理
  "ggplot2"            # 绑图
))
```

## 3. 配置 R 解释器

### 3.1 自动检测

R 扩展会自动检测系统中的 R 安装。如果没有自动检测到：

1. `Ctrl+Shift+P` → `R: Select R Installation`
2. 选择 R 的安装路径（如 `C:\Program Files\R\R-4.3.2`）

### 3.2 手动配置

在 `.vscode/settings.json` 中设置：

```json
{
    "r.rpath.windows": "C:\\Program Files\\R\\R-4.3.2\\bin\\Rscript.exe",
    "r.rprofile": "C:\\Program Files\\R\\R-4.3.2\\etc\\Rprofile.site"
}
```

### 3.3 配置 R terminal

```json
{
    "terminal.integrated.profiles.windows": {
        "R": {
            "path": "C:\\Program Files\\R\\R-4.3.2\\bin\\R.exe",
            "icon": "terminal-r"
        }
    },
    "terminal.integrated.defaultProfile.windows": "R"
}
```

## 4. 配置构建/运行任务（tasks.json）

### 4.1 运行 R 脚本

创建 `.vscode/tasks.json`：

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "运行 R 脚本",
            "type": "shell",
            "command": "Rscript",
            "args": [
                "${file}"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": [],
            "presentation": {
                "reveal": "always",
                "panel": "dedicated"
            }
        },
        {
            "label": "运行 R 脚本（交互模式）",
            "type": "shell",
            "command": "R",
            "args": [
                "--no-save",
                "--no-restore",
                "-e",
                "source('${file}')"
            ],
            "group": "build",
            "problemMatcher": []
        }
    ]
}
```

### 4.2 执行选中文本

R 扩展支持直接发送选中代码到 R 终端：
1. 选中代码
2. `Ctrl+Enter` 发送到 R 终端
3. 或使用快捷键 `Ctrl+Shift+S` 运行选中行

## 5. 配置调试器（launch.json）

### 5.1 自动生成

1. 打开 R 脚本
2. `F5` 或点击调试图标
3. 选择 **"R: Debug R Script"**

### 5.2 手动创建

创建 `.vscode/launch.json`：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "调试 R 脚本",
            "type": "R",
            "request": "launch",
            "script": "${file}",
            "cwd": "${fileDirname}",
            "workingDirectory": "${workspaceFolder}",
            "showEvaluatedSymbol": true
        },
        {
            "name": "调试 R 函数",
            "type": "R",
            "request": "launch",
            "script": "${file}",
            "args": ["--vanilla"],
            "debugger": "RDebugger"
        },
        {
            "name": "调试 Shiny 应用",
            "type": "R",
            "request": "launch",
            "debugType": "Shiny",
            "url": "http://127.0.0.1:7654",
            "path": "${workspaceFolder}"
        }
    ]
}
```

### 5.3 使用 R LSP 调试器

如果使用 R Debugger 扩展，配置如下：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "R Debugger - 当前文件",
            "type": "rDebugger",
            "request": "launch",
            "rDebugger.runtime": "Rscript",
            "rDebugger.script": "${file}",
            "rDebugger.name": "Debug Current Script"
        }
    ]
}
```

## 6. 常用快捷键和设置

### 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+Enter` | 运行当前行/选中代码 |
| `Ctrl+Shift+Enter` | 运行当前段落（以空行分隔） |
| `F5` | 运行/调试脚本 |
| `Ctrl+F5` | 无调试运行 |
| `Ctrl+Shift+R` | 运行所有代码 |
| `Ctrl+Alt+R` | 运行当前行并移动到下一行 |
| `Ctrl+Shift+S` | 运行选中文本 |
| `Ctrl+Shift+A` | 运行上方所有代码（到光标位置） |

### 推荐 settings.json

```json
{
    "r.rpath.windows": "C:\\Program Files\\R\\R-4.3.2\\bin\\Rscript.exe",
    "r.bracketedPaste": true,
    "r.rterm": "R",
    "r.rterm.sendSelection": "selectionOrLine",
    "r.rterm.lsp": true,
    "r.plot.useHttpgd": true,
    "r.lsp.debug": false,
    "r.lsp.diagnostics": true,
    "[r]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true,
        "editor.formatOnSave": false
    },
    "[rmd]": {
        "editor.tabSize": 2,
        "editor.insertSpaces": true
    },
    "files.associations": {
        "*.Rmd": "rmd",
        "*.Rproj": "r"
    },
    "terminal.integrated.env.windows": {
        "PATH": "C:\\Program Files\\R\\R-4.3.2\\bin\\x64;${env:PATH}"
    }
}
```

### Styler 格式化配置

```json
{
    "[r]": {
        "editor.defaultFormatter": "REditorSupport.r",
        "editor.formatOnSave": true
    }
}
```

## 7. 示例项目配置

### 7.1 项目目录结构

```
my_r_project/
├── .vscode/
│   ├── launch.json
│   ├── tasks.json
│   └── settings.json
├── R/
│   ├── main.R
│   ├── utils.R
│   └── analysis.R
├── data/
│   └── sample.csv
├── output/
│   └── (图表和结果)
├── renv.lock           # 依赖管理
├── .Rprofile
└── README.md
```

### 7.2 使用 renv 管理依赖

```r
# 初始化 renv
renv::init()

# 安装包
renv::install("tidyverse")

# 保存当前环境
renv::snapshot()

# 恢复环境
renv::restore()
```

### 7.3 示例 main.R

```r
# 加载必要包
library(tidyverse)

# ---- 函数定义 ----
# 在这里设置断点进行调试
calculate_stats <- function(x) {
  list(
    mean = mean(x),
    sd = sd(x),
    n = length(x)
  )
}

# ---- 数据分析 ----
main <- function() {
  # 示例数据
  data <- tibble(
    id = 1:100,
    value = rnorm(100, mean = 50, sd = 10)
  )

  # 计算统计量（调试时查看 data 和 stats）
  stats <- calculate_stats(data$value)
  cat("Mean:", stats$mean, "\n")
  cat("SD:", stats$sd, "\n")
  cat("N:", stats$n, "\n")

  # 绘图
  p <- ggplot(data, aes(x = value)) +
    geom_histogram(bins = 20, fill = "steelblue", alpha = 0.7) +
    theme_minimal() +
    labs(title = "Value Distribution", x = "Value", y = "Count")

  # 保存图表
  ggsave("output/plot.png", p, width = 8, height = 6)
  cat("Plot saved to output/plot.png\n")
}

# 运行主函数
main()
```

### 7.4 示例分析脚本

```r
# 读取数据并进行分析
library(tidyverse)

analyze_data <- function(file_path) {
  # 读取数据
  df <- read_csv(file_path) %>%
    glimpse()

  # 基础统计
  summary_stats <- df %>%
    summarise(across(where(is.numeric), list(
      mean = ~mean(., na.rm = TRUE),
      sd = ~sd(., na.rm = TRUE),
      min = ~min(., na.rm = TRUE),
      max = ~max(., na.rm = TRUE)
    )))

  return(summary_stats)
}
```

## 8. 常见问题和解决方案

### Q1: R 扩展安装后无法识别 R 路径
**解决**:
1. `Ctrl+Shift+P` → `R: Select R Installation`
2. 手动选择 R 安装路径
3. 检查 `r.rpath.windows` 设置

### Q2: 图形不显示 / 图形窗口不弹出
**解决**:
1. 推荐安装 httpgd 包：`install.packages("httpgd")`
2. 设置 `"r.plot.useHttpgd": true`
3. 或使用传统 X11 设备：在 R 终端中 `dev.new()`

### Q3: 代码补全 / LSP 不工作
**解决**:
1. 确保安装了 `languageserver` 包：`install.packages("languageserver")`
2. `Ctrl+Shift+P` → `R: Restart R Language Server`
3. 检查 `"r.lsp.debug": true` 查看日志

### Q4: Rterm 无法启动 / "R is not recognized"
**原因**: R 不在系统 PATH 中  
**解决**:
1. 将 R 的 bin 目录添加到系统 PATH
2. 或在 `settings.json` 中配置 `"r.rpath.windows"` 和 `"r.rterm"`

### Q5: 中文显示乱码
**解决**:
1. 在 R 脚本开头设置编码：
```r
Sys.setlocale("LC_ALL", "Chinese")
options(encoding = "UTF-8")
```
2. 终端编码设置：
```json
{
    "terminal.integrated.env.windows": {
        "PYTHONIOENCODING": "utf-8",
        "LC_ALL": "en_US.UTF-8"
    }
}
```

### Q6: 编译 R 包时找不到 Rtools
**解决**:
1. 确保安装了匹配版本的 Rtools
2. 设置环境变量：
```r
Sys.setenv(RTOOLS = "C:\\rtools43")
```
3. 或在 `.Renviron` 中添加：
```
RTOOLS43=C:/rtools43
PATH=${RTOOLS43}/usr/bin;${PATH}
```

### Q7: Shiny 应用调试
1. 安装 Shiny：`install.packages("shiny")`
2. 在 launch.json 中配置 Shiny 调试
3. 在代码中添加断点
4. `F5` 启动调试，浏览器会自动打开 Shiny 应用

### Q8: Quarto 文档渲染
1. 安装 Quarto: https://quarto.org/docs/get-started/
2. 安装 VS Code Quarto 扩展
3. 使用 `Ctrl+Shift+K` 渲染文档
4. 配置 Quarto 使用 R 内核

### Q9: 远程服务器连接
使用 Remote-SSH 扩展连接远程 R 环境：
1. 安装 Remote-SSH 扩展
2. 连接到远程服务器
3. 在远程服务器上安装 R 和 R 扩展
4. VS Code 会自动在远程安装 R 扩展

### Q10: 性能优化（大文件处理）
```json
{
    "r.lsp.diagnostics": false,
    "r.lsp.debug": false,
    "editor.wordWrap": "off",
    "editor.minimap.enabled": false
}
```

---

> **最后更新**: 2026年  
> **适用平台**: Windows 10/11  
> **编辑器版本**: VS Code 1.90+  
> **R 版本**: 4.3+

---

## 相关配置

- **其他语言**：[[C++配置指南|C++]] | [[Python配置指南|Python]] | [[LaTeX配置指南|LaTeX]]
