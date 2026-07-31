# VS Code Python 配置完全指南（Windows）

> 适用于 VS Code 1.90+（2026年）

## 1. 前提条件

### 必需软件
| 软件 | 用途 | 下载地址 |
|------|------|----------|
| **VS Code** | 代码编辑器 | https://code.visualstudio.com |
| **Python 3.10+** | Python 解释器 | https://www.python.org/downloads/ |

### 安装 Python

1. 从官网下载 Python 3.10 或更高版本
2. 安装时 **务必勾选** "Add Python to PATH"
3. 自定义安装路径，例如 `C:\Python312`

### 验证安装
```bash
python --version
# 或
python3 --version

pip --version
```

### 推荐：使用虚拟环境管理工具
| 工具 | 说明 |
|------|------|
| **venv** | Python 内置虚拟环境（推荐入门使用） |
| **conda** | Anaconda/Miniconda，适合数据科学 |
| **uv** | 新一代 Python 包管理器，速度极快 |
| **Poetry** | 依赖管理和打包工具 |

## 2. VS Code 扩展安装

`Ctrl+Shift+X` 打开扩展面板，安装以下扩展：

| 扩展名 | ID | 说明 |
|--------|-----|------|
| **Python** | `ms-python.python` | Microsoft 官方 Python 扩展（必装） |
| **Pylance** | `ms-python.vscode-pylance` | 高性能 Python 语言服务器 |
| **Python Debugger** | `ms-python.debugpy` | Python 调试器 |
| **Ruff** | `charliermarsh.ruff` | 超快 Python linter + formatter |
| **Black Formatter** | `ms-python.black-formatter` | 代码格式化（可选） |
| **isort** | `ms-python.isort` | import 排序 |
| **Jupyter** | `ms-toolsai.jupyter` | Jupyter Notebook 支持 |
| **Pylint** | `ms-python.pylint` | 代码检查（可选） |

## 3. 配置解释器

### 3.1 选择 Python 解释器

1. `Ctrl+Shift+P` → `Python: Select Interpreter`
2. 选择你安装的 Python 版本

VS Code 会在工作区 `.vscode/settings.json` 中记录：
```json
{
    "python.defaultInterpreterPath": "C:\\Python312\\python.exe"
}
```

### 3.2 使用虚拟环境

**创建 venv 虚拟环境**：
```bash
# 在项目根目录执行
python -m venv .venv
```

**激活虚拟环境**：
```bash
# PowerShell
.\.venv\Scripts\Activate.ps1

# Command Prompt
.\.venv\Scripts\activate.bat
```

**在 VS Code 中选择虚拟环境的解释器**：
- `Ctrl+Shift+P` → `Python: Select Interpreter`
- 选择 `.venv\Scripts\python.exe`

VS Code 会自动检测并提示安装推荐扩展到虚拟环境中。

### 3.3 使用 Conda 环境

```bash
conda create -n myenv python=3.12
conda activate myenv
```

在 VS Code 中选择对应的 conda 环境即可。

### 3.4 使用 uv（推荐）

```bash
# 安装 uv
pip install uv

# 创建虚拟环境并安装依赖
uv venv
uv pip install -r requirements.txt

# 或直接运行脚本
uv run main.py
```

## 4. 配置构建/运行任务（tasks.json）

### 4.1 运行当前 Python 文件

创建 `.vscode/tasks.json`：

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "运行当前 Python 文件",
            "type": "shell",
            "command": "${config:python.defaultInterpreterPath}",
            "args": [
                "${file}"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "problemMatcher": []
        },
        {
            "label": "运行 Python 文件（在终端）",
            "type": "shell",
            "command": "${config:python.defaultInterpreterPath}",
            "args": [
                "-u",
                "${file}"
            ],
            "group": "build",
            "problemMatcher": [],
            "presentation": {
                "reveal": "always",
                "panel": "dedicated"
            }
        }
    ]
}
```

### 4.2 Code Runner 配置

如果安装了 **Code Runner** 扩展，在 `settings.json` 中配置：

```json
{
    "code-runner.executorMap": {
        "python": "${config:python.defaultInterpreterPath} -u"
    },
    "code-runner.runInTerminal": true,
    "code-runner.saveFileBeforeRun": true
}
```

使用 `Ctrl+Alt+N` 快速运行当前文件。

## 5. 配置调试器（launch.json）

### 5.1 自动生成

1. 打开 Python 文件
2. `F5` 或点击侧边栏调试图标
3. 选择 **"Python File"** 或 **"Python Current File"**

### 5.2 手动创建

创建 `.vscode/launch.json`：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "调试当前文件",
            "type": "debugpy",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal",
            "cwd": "${fileDirname}",
            "env": {},
            "args": []
        },
        {
            "name": "调试模块",
            "type": "debugpy",
            "request": "launch",
            "module": "模块名",
            "console": "integratedTerminal",
            "cwd": "${workspaceFolder}",
            "args": ["--arg1", "value1"]
        },
        {
            "name": "附加到进程",
            "type": "debugpy",
            "request": "attach",
            "connect": {
                "host": "localhost",
                "port": 5678
            }
        }
    ]
}
```

### 5.3 远程调试（调试远程服务器上的代码）

1. 在远程机器安装 debugpy：
```bash
pip install debugpy
```

2. 在远程代码中添加：
```python
import debugpy
debugpy.listen(("0.0.0.0", 5678))
print("Waiting for debugger attach...")
debugpy.wait_for_client()
```

3. launch.json 配置：
```json
{
    "name": "远程调试",
    "type": "debugpy",
    "request": "attach",
    "connect": {
        "host": "远程IP",
        "port": 5678
    },
    "pathMappings": [
        {
            "localRoot": "${workspaceFolder}",
            "remoteRoot": "/remote/path"
        }
    ]
}
```

### 5.4 pytest 调试

```json
{
    "name": "调试 pytest",
    "type": "debugpy",
    "request": "launch",
    "module": "pytest",
    "args": [
        "${file}",
        "-v"
    ],
    "console": "integratedTerminal",
    "cwd": "${workspaceFolder}"
}
```

## 6. 常用快捷键和设置

### 快捷键

| 快捷键 | 功能 |
|--------|------|
| `F5` | 运行/调试 |
| `Ctrl+F5` | 无调试运行 |
| `F9` | 切换断点 |
| `F10` | 单步跳过 |
| `F11` | 单步进入 |
| `Shift+F11` | 单步跳出 |
| `Ctrl+Shift+I` | 格式化文档 |
| `Ctrl+.` | 快速修复 |
| `Alt+Shift+F` | 格式化代码 |

### 推荐 settings.json

```json
{
    "python.defaultInterpreterPath": "C:\\Python312\\python.exe",
    "python.analysis.typeCheckingMode": "basic",
    "python.analysis.autoImportCompletions": true,
    "editor.formatOnSave": true,
    "[python]": {
        "editor.defaultFormatter": "charliermarsh.ruff",
        "editor.codeActionsOnSave": {
            "source.fixAll.ruff": "explicit",
            "source.organizeImports.ruff": "explicit"
        },
        "editor.tabSize": 4,
        "editor.insertSpaces": true
    },
    "files.exclude": {
        "**/__pycache__": true,
        "**/.pytest_cache": true,
        "**/*.pyc": true,
        "**/.mypy_cache": true
    },
    "terminal.integrated.env.windows": {
        "PYTHONIOENCODING": "utf-8"
    }
}
```

### Ruff 配置（推荐）

在项目根目录创建 `pyproject.toml`：

```toml
[tool.ruff]
line-length = 88
target-version = "py312"

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "UP",  # pyupgrade
    "B",   # flake8-bugbear
    "SIM", # flake8-simplify
]
ignore = ["E501"]

[tool.ruff.lint.isort]
known-first-party = ["src"]
```

## 7. 示例项目配置

### 7.1 项目目录结构

```
my_project/
├── .vscode/
│   ├── launch.json
│   ├── tasks.json
│   └── settings.json
├── .venv/                # 虚拟环境
├── src/
│   ├── __init__.py
│   └── main.py
├── tests/
│   └── test_main.py
├── pyproject.toml
├── requirements.txt
└── README.md
```

### 7.2 requirements.txt 示例

```
requests>=2.31.0
pandas>=2.0.0
numpy>=1.24.0
pytest>=7.4.0
```

### 7.3 示例 main.py

```python
"""示例 Python 项目"""

from pathlib import Path


def greet(name: str) -> str:
    """返回问候语"""
    # 在这里设置断点，按 F5 调试
    return f"Hello, {name}!"


def calculate_sum(numbers: list[int]) -> int:
    """计算列表元素之和"""
    total = 0  # 调试时查看这个变量的值
    for num in numbers:
        total += num
    return total


def main() -> None:
    message = greet("World")
    print(message)

    nums = [1, 2, 3, 4, 5]
    result = calculate_sum(nums)
    print(f"Sum: {result}")


if __name__ == "__main__":
    main()
```

### 7.4 示例 test_main.py

```python
"""单元测试示例"""

from src.main import greet, calculate_sum


def test_greet():
    assert greet("Alice") == "Hello, Alice!"
    assert greet("Bob") == "Hello, Bob!"


def test_calculate_sum():
    assert calculate_sum([1, 2, 3]) == 6
    assert calculate_sum([]) == 0
    assert calculate_sum([10]) == 10
```

## 8. 常见问题和解决方案

### Q1: IntelliSense 不工作 / 代码补全慢
**解决**:
1. `Ctrl+Shift+P` → `Python: Restart Language Server`
2. 确认 Pylance 扩展已安装且启用
3. 检查 `python.analysis.typeCheckingMode` 设置

### Q2: "ModuleNotFoundError: No module named ..."
**原因**: 使用了错误的 Python 解释器  
**解决**:
1. `Ctrl+Shift+P` → `Python: Select Interpreter` 切换正确的解释器
2. 检查终端使用的 Python 是否与 VS Code 一致

### Q3: 中文乱码 / UnicodeEncodeError
**解决**:
1. 在代码开头添加：
```python
import sys
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
```
2. 或在 `settings.json` 中添加：
```json
{
    "terminal.integrated.env.windows": {
        "PYTHONIOENCODING": "utf-8"
    }
}
```
3. Windows 终端默认使用 GBK，设置环境变量 `PYTHONUTF8=1`

### Q4: 调试时断点不生效 / 提示 "Unable to find Python"
**解决**:
1. 确保安装了 **Python Debugger** 扩展 (`ms-python.debugpy`)
2. `Ctrl+Shift+P` → `Python: Select Interpreter` 重新选择
3. 重启 VS Code

### Q5: pip install 速度慢
**解决**: 使用国内镜像源
```bash
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple 包名
```

永久配置：
```bash
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

### Q6: ruff 格式化报错
**解决**: 安装 ruff：
```bash
pip install ruff
```
或使用 VS Code 内置安装：`Ctrl+Shift+P` → `Extensions: Install Extensions`

### Q7: 多 Python 版本管理
**推荐**: 使用 [pyenv-win](https://github.com/pyenv-win/pyenv-win) 或 [uv](https://github.com/astral-sh/uv)

```bash
# uv 安装和管理 Python 版本
uv python install 3.12
uv python install 3.11
uv python list
uv python pin 3.12
```

### Q8: Jupyter Notebook 配置
1. 安装 **Jupyter** 扩展
2. 创建 `.ipynb` 文件
3. VS Code 会提示选择 Python 内核
4. 推荐在虚拟环境中安装 `ipykernel`：
```bash
pip install ipykernel
python -m ipykernel install --user --name myenv
```

### Q9: Django/Flask 项目调试

**Flask 调试配置**：
```json
{
    "name": "Flask 调试",
    "type": "debugpy",
    "request": "launch",
    "module": "flask",
    "args": [
        "run",
        "--reload",
        "--debugger"
    ],
    "env": {
        "FLASK_APP": "app.py",
        "FLASK_ENV": "development"
    }
}
```

**Django 调试配置**：
```json
{
    "name": "Django 调试",
    "type": "debugpy",
    "request": "launch",
    "program": "${workspaceFolder}/manage.py",
    "args": [
        "runserver",
        "--noreload"
    ],
    "django": true,
    "env": {
        "DJANGO_SETTINGS_MODULE": "项目名.settings"
    }
}
```

---

> **最后更新**: 2026年  
> **适用平台**: Windows 10/11  
> **编辑器版本**: VS Code 1.90+  
> **Python 版本**: 3.10+

---

## 相关配置

- **其他语言**：[[C++配置指南|C++]] | [[LaTeX配置指南|LaTeX]] | [[R配置指南|R]]
- **Python 学习**：[[../python学习/01-Python基础与数据类型|Python 教程]]
- **TensorFlow**：[[../../人工智能/TensorFlow/TensorFlow入门|TensorFlow 环境配置]]
