# VS Code C++ 配置完全指南（Windows）

> 适用于 VS Code 1.90+（2026年）

## 1. 前提条件

### 必需软件
| 软件 | 用途 | 下载地址 |
|------|------|----------|
| **VS Code** | 代码编辑器 | https://code.visualstudio.com |
| **MinGW-w64** 或 **MSVC** | C++ 编译器 | MinGW: https://www.mingw-w64.org / MSVC: Visual Studio Build Tools |
| **CMake**（可选） | 构建系统 | https://cmake.org/download/ |

### 安装编译器（推荐 MinGW-w64）

**方法一：使用 MSYS2（推荐）**
```bash
# 安装 MSYS2 后，在 MSYS2 终端中执行
pacman -S mingw-w64-ucrt-x86_64-gcc
pacman -S mingw-w64-ucrt-x86_64-gdb
```

**方法二：使用 w64devkit**
1. 下载 w64devkit: https://github.com/skeeto/w64devkit/releases
2. 解压到 `C:\w64devkit`
3. 将 `C:\w64devkit\bin` 添加到系统 PATH

### 验证安装
```bash
g++ --version
gdb --version
```

## 2. VS Code 扩展安装

打开 VS Code，安装以下扩展：

| 扩展名 | ID | 说明 |
|--------|-----|------|
| **C/C++** | `ms-vscode.cpptools` | Microsoft 官方 C/C++ 扩展（必装） |
| **C/C++ Extension Pack** | `ms-vscode.cpptools-extension-pack` | 扩展包（含 IntelliSense、调试等） |
| **CMake Tools** | `ms-vscode.cmake-tools` | CMake 支持（如使用 CMake） |
| **Code Runner** | `formulahendry.code-runner` | 快速运行代码 |
| **Better C++ Syntax** | `jeff-hykin.better-cpp-syntax` | 更好的语法高亮 |

安装方式：`Ctrl+Shift+X` → 搜索扩展名 → 点击安装

## 3. 配置编译器

### 3.1 配置 IntelliSense

1. `Ctrl+Shift+P` → 输入 `C/C++: Edit Configurations (UI)`
2. 配置如下选项：
   - **Compiler path**: `C:/w64devkit/bin/g++.exe`（根据实际路径修改）
   - **IntelliSense mode**: `windows-gcc-x64`
   - **C++ standard**: `c++17` 或 `c++20`

这会在 `.vscode/c_cpp_properties.json` 中生成配置：

```json
{
    "configurations": [
        {
            "name": "Win32",
            "includePath": [
                "${workspaceFolder}/**"
            ],
            "defines": [
                "_DEBUG",
                "UNICODE",
                "_UNICODE"
            ],
            "windowsSdkVersion": "10.0.19041.0",
            "compilerPath": "C:/w64devkit/bin/g++.exe",
            "cStandard": "c17",
            "cppStandard": "c++17",
            "intelliSenseMode": "windows-gcc-x64"
        }
    ],
    "version": 4
}
```

### 3.2 配置 PATH（如编译器不在 PATH 中）

编辑 `.vscode/settings.json`：
```json
{
    "terminal.integrated.env.windows": {
        "PATH": "C:\\w64devkit\\bin;${env:PATH}"
    }
}
```

## 4. 配置构建任务（tasks.json）

### 4.1 自动生成

1. `Ctrl+Shift+P` → `Tasks: Configure Task`
2. 选择 `C/C++: g++.exe 生成活动文件`

### 4.2 手动创建

创建 `.vscode/tasks.json`：

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "type": "cppbuild",
            "label": "C/C++: g++.exe 生成活动文件",
            "command": "C:\\w64devkit\\bin\\g++.exe",
            "args": [
                "-fdiagnostics-color=always",
                "-g",
                "-Wall",
                "-Wextra",
                "-std=c++17",
                "${file}",
                "-o",
                "${fileDirname}\\${fileBasenameNoExtension}.exe"
            ],
            "options": {
                "cwd": "${fileDirname}"
            },
            "problemMatcher": [
                "$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "detail": "编译器: C:\\w64devkit\\bin\\g++.exe"
        }
    ]
}
```

### 4.3 多文件项目构建

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "type": "cppbuild",
            "label": "C/C++: 构建整个项目",
            "command": "C:\\w64devkit\\bin\\g++.exe",
            "args": [
                "-g",
                "-Wall",
                "-Wextra",
                "-std=c++17",
                "${workspaceFolder}\\src\\*.cpp",
                "-I",
                "${workspaceFolder}\\include",
                "-o",
                "${workspaceFolder}\\bin\\${fileBasenameNoExtension}.exe"
            ],
            "options": {
                "cwd": "${workspaceFolder}"
            },
            "problemMatcher": [
                "$gcc"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        }
    ]
}
```

使用快捷键 `Ctrl+Shift+B` 执行默认构建任务。

## 5. 配置调试器（launch.json）

### 5.1 自动生成

1. `F5` 或 `Ctrl+Shift+P` → `Debug: Select and Start Debugging`
2. 选择 `C/C++: g++.exe 生成和调试活动文件`

### 5.2 手动创建

创建 `.vscode/launch.json`：

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "C/C++: g++.exe 生成和调试活动文件",
            "type": "cppdbg",
            "request": "launch",
            "program": "${fileDirname}\\${fileBasenameNoExtension}.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${fileDirname}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "miDebuggerPath": "C:\\w64devkit\\bin\\gdb.exe",
            "setupCommands": [
                {
                    "description": "为 gdb 启用 pretty-printing",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description": "将 UnqualifiedId 设置为 gdb 的反引号引用",
                    "text": "set disassembly-flavor intel",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "C/C++: g++.exe 生成活动文件"
        }
    ]
}
```

### 5.3 带参数调试

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "调试带参数的程序",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}\\bin\\main.exe",
            "args": ["arg1", "arg2", "--flag"],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "miDebuggerPath": "C:\\w64devkit\\bin\\gdb.exe",
            "preLaunchTask": "C/C++: g++.exe 生成活动文件"
        }
    ]
}
```

## 6. 常用快捷键和设置

### 快捷键

| 快捷键 | 功能 |
|--------|------|
| `F5` | 开始调试 |
| `Ctrl+Shift+B` | 运行构建任务 |
| `F7` | 编译（Build） |
| `F8` | 跳转到下一个错误 |
| `F12` | 转到定义 |
| `Ctrl+Shift+F12` | 查看所有引用 |
| `Alt+Shift+F` | 格式化代码 |
| `Ctrl+/` | 注释/取消注释 |
| `Ctrl+Shift+/` | 块注释 |

### 推荐设置

在 `.vscode/settings.json` 中添加：

```json
{
    "C_Cpp.default.cppStandard": "c++17",
    "editor.suggestSelection": "first",
    "editor.tabSize": 4,
    "editor.formatOnSave": true,
    "files.associations": {
        "*.cpp": "cpp",
        "*.h": "cpp",
        "*.hpp": "cpp"
    },
    "files.encoding": "utf8",
    "terminal.integrated.defaultProfile.windows": "PowerShell",
    "code-runner.runInTerminal": true,
    "code-runner.executorMap": {
        "cpp": "cd $dir && g++ -std=c++17 -Wall $fileName -o $fileNameWithoutExt.exe && $dir$fileNameWithoutExt.exe"
    }
}
```

## 7. Qt 与 CMake 配置

### 7.1 前提条件

| 软件 | 用途 | 下载地址 |
|------|------|----------|
| **Qt 5.x** | Qt 库和工具 | https://www.qt.io/download-qt-installer |
| **CMake 3.16+** | 构建系统 | https://cmake.org/download/ |
| **VS Code 扩展** | CMake 支持 | CMake Tools, Qt Support |

### 7.2 安装 Qt

**方法一：使用 Qt Online Installer（推荐）**
1. 下载 Qt Online Installer
2. 登录 Qt 账号（需注册）
3. 选择组件：`Qt 5.x` → `MSVC 2019 64-bit` 或 `MinGW 64-bit`
4. 安装路径建议：`C:\Qt`

**方法二：使用 vcpkg（可选）**
```bash
vcpkg install qt6[core,widgets,quick]:x64-windows
```

### 7.3 配置环境变量

1. 将 Qt 的 bin 目录添加到系统 PATH：
   - MinGW: `C:\Qt\5.x.x\mingw_64\bin`
   - MSVC: `C:\Qt\5.x.x\msvc2019_64\bin`
2. 设置 `Qt_DIR` 环境变量：
   ```
   Qt_DIR=C:\Qt\5.x.x\mingw_64\lib\cmake\Qt5
   ```

### 7.4 VS Code 扩展安装

| 扩展名 | ID | 说明 |
|--------|-----|------|
| **CMake Tools** | `ms-vscode.cmake-tools` | CMake 支持（必装） |
| **Qt Support** | `tonka3000.qtwin` | Qt 智能提示和 UI 文件支持 |
| **C/C++** | `ms-vscode.cpptools` | IntelliSense 支持 |

### 7.5 配置 CMake 项目

创建 `CMakeLists.txt`：

```cmake
cmake_minimum_required(VERSION 3.16)
project(QtApp VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找 Qt 包
find_package(Qt5 REQUIRED COMPONENTS Widgets Quick)
# 或者使用 find_package(Qt5 REQUIRED COMPONENTS Widgets Quick)

# 启用 Qt 的 MOC、UIC、RCC
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# 添加可执行文件
add_executable(${PROJECT_NAME}
    src/main.cpp
    src/mainwindow.cpp
    src/mainwindow.h
)

# 链接 Qt 库
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt5::Widgets
    Qt5::Quick
)
```

### 7.6 配置 CMake Tools 扩展

1. `Ctrl+Shift+P` → `CMake: Configure`
2. 选择编译器：
   - MinGW: `MinGW Makefiles`
   - MSVC: `Visual Studio 17 2022`
3. `Ctrl+Shift+P` → `CMake: Build`

### 7.7 配置 tasks.json（CMake 构建）

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "CMake: Configure",
            "type": "shell",
            "command": "cmake",
            "args": [
                "-B", "${workspaceFolder}/build",
                "-S", "${workspaceFolder}",
                "-DCMAKE_BUILD_TYPE=Debug"
            ],
            "options": {
                "cwd": "${workspaceFolder}"
            },
            "problemMatcher": []
        },
        {
            "label": "CMake: Build",
            "type": "shell",
            "command": "cmake",
            "args": [
                "--build", "${workspaceFolder}/build",
                "--config", "Debug"
            ],
            "options": {
                "cwd": "${workspaceFolder}"
            },
            "problemMatcher": ["$gcc"],
            "dependsOn": "CMake: Configure"
        },
        {
            "label": "CMake: Clean",
            "type": "shell",
            "command": "cmake",
            "args": [
                "--build", "${workspaceFolder}/build",
                "--target", "clean"
            ],
            "options": {
                "cwd": "${workspaceFolder}"
            },
            "problemMatcher": []
        }
    ]
}
```

### 7.8 配置 launch.json（Qt 调试）

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "CMake: Debug Qt App",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build/QtApp.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [
                {
                    "name": "QT_QPA_PLATFORM",
                    "value": "windows"
                }
            ],
            "externalConsole": false,
            "MIMode": "gdb",
            "miDebuggerPath": "C:/w64devkit/bin/gdb.exe",
            "setupCommands": [
                {
                    "description": "启用 pretty-printing",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "CMake: Build"
        }
    ]
}
```

### 7.9 Qt 项目目录结构

```
qt_project/
├── .vscode/
│   ├── settings.json
│   ├── launch.json
│   └── tasks.json
├── src/
│   ├── main.cpp
│   ├── mainwindow.cpp
│   └── mainwindow.h
├── qml/
│   └── Main.qml
├── resources/
│   └── resources.qrc
├── CMakeLists.txt
└── build/
    └── (CMake 生成的文件)
```

### 7.10 示例 Qt 项目

**src/main.cpp**:
```cpp
#include <QApplication>
#include "mainwindow.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    
    MainWindow window;
    window.show();
    
    return app.exec();
}
```

**src/mainwindow.h**:
```cpp
#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QPushButton>
#include <QLabel>

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);

private slots:
    void onButtonClicked();

private:
    QLabel *label;
    QPushButton *button;
};

#endif
```

**src/mainwindow.cpp**:
```cpp
#include "mainwindow.h"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent) {
    setWindowTitle("Qt App");
    resize(400, 300);
    
    QWidget *centralWidget = new QWidget(this);
    QVBoxLayout *layout = new QVBoxLayout(centralWidget);
    
    label = new QLabel("Hello, Qt!", this);
    button = new QPushButton("Click Me", this);
    
    layout->addWidget(label);
    layout->addWidget(button);
    
    connect(button, &QPushButton::clicked, this, &MainWindow::onButtonClicked);
    
    setCentralWidget(centralWidget);
}

void MainWindow::onButtonClicked() {
    label->setText("Button clicked!");
}
```

## 8. 示例项目配置

### 8.1 项目目录结构

```
my_project/
├── .vscode/
│   ├── c_cpp_properties.json
│   ├── launch.json
│   ├── tasks.json
│   └── settings.json
├── include/
│   └── utils.h
├── src/
│   ├── main.cpp
│   └── utils.cpp
├── bin/
│   └── (编译输出)
└── CMakeLists.txt  (可选)
```

### 8.2 完整的 .vscode/settings.json

```json
{
    "C_Cpp.default.configurationProvider": "ms-vscode.cpptools",
    "C_Cpp.default.cppStandard": "c++17",
    "C_Cpp.default.compilerPath": "C:/w64devkit/bin/g++.exe",
    "C_Cpp.default.intelliSenseMode": "windows-gcc-x64",
    "editor.tabSize": 4,
    "editor.formatOnSave": true,
    "files.associations": {
        "*.h": "cpp",
        "*.hpp": "cpp"
    }
}
```

### 8.3 示例 main.cpp

```cpp
#include <iostream>
#include <vector>
#include <string>

// 断点调试：在行号左侧点击添加断点，按 F5 开始调试

int main() {
    std::vector<std::string> messages = {"Hello", "World"};

    for (const auto& msg : messages) {
        std::cout << msg << " ";
    }
    std::cout << std::endl;

    // 调试时可以在 Variables 面板查看变量
    int result = 42;
    std::cout << "Result: " << result << std::endl;

    return 0;
}
```

## 9. 常见问题和解决方案

### Q1: IntelliSense 报红但编译正常
**原因**: IntelliSense 配置不正确  
**解决**:
```bash
Ctrl+Shift+P → C/C++: Reset IntelliSense Database
```
并检查 `c_cpp_properties.json` 中的 `compilerPath` 是否正确。

### Q2: 编译时报错 "g++: not found"
**原因**: 编译器不在 PATH 中  
**解决**:
1. 确认编译器安装路径
2. 在 `settings.json` 中配置 `terminal.integrated.env.windows`
3. 或将编译器目录添加到系统 PATH

### Q3: 调试时断点不生效
**解决**:
1. 确保使用 `-g` 编译选项（已在 tasks.json 中配置）
2. 编译选项设置为 `-O0`（无优化），避免调试信息被优化掉
3. 重新构建项目

### Q4: 中文乱码
**解决**:
1. 源文件保存为 UTF-8 编码（VS Code 右下角可查看/切换）
2. 在 `settings.json` 中添加：
```json
{
    "files.encoding": "utf8"
}
```
3. Windows 终端编码问题：在 tasks.json 的 args 中添加 `-fexec-charset=GBK`（如终端为 GBK 编码）

### Q5: 头文件包含路径错误
**解决**: 在 `c_cpp_properties.json` 的 `includePath` 中添加：
```json
{
    "includePath": [
        "${workspaceFolder}/**",
        "${workspaceFolder}/include"
    ]
}
```

### Q6: 如何使用 CMake 构建项目
1. 安装 **CMake Tools** 扩展
2. 创建 `CMakeLists.txt`：
```cmake
cmake_minimum_required(VERSION 3.10)
project(MyProject)

set(CMAKE_CXX_STANDARD 17)

add_executable(main src/main.cpp src/utils.cpp)
target_include_directories(main PRIVATE include)
```
3. `Ctrl+Shift+P` → `CMake: Configure` → 选择编译器
4. `Ctrl+Shift+P` → `CMake: Build`

### Q7: WSL 远程开发
1. 安装 WSL 和 Linux 发行版
2. VS Code 安装 **Remote - WSL** 扩展
3. 在 WSL 终端中用 `code .` 打开项目
4. VS Code 会自动安装 Linux 版 C/C++ 扩展

### Q8: 配置 Clang 编译器
1. 安装 LLVM: https://releases.llvm.org/
2. 在 `c_cpp_properties.json` 中修改：
```json
{
    "compilerPath": "C:/Program Files/LLVM/bin/clang++.exe",
    "intelliSenseMode": "windows-clang-x64"
}
```

### Q9: Qt 项目找不到头文件
**原因**: Qt 头文件路径未配置  
**解决**:
1. 确保已安装 Qt VS 扩展
2. 在 `c_cpp_properties.json` 的 `includePath` 中添加：
```json
{
    "includePath": [
        "${workspaceFolder}/**",
        "C:/Qt/5.x.x/mingw_64/include/**"
    ]
}
```
3. 或在 CMakeLists.txt 中使用 `target_include_directories`

### Q10: CMake 配置 Qt 项目失败
**原因**: Qt 包未正确找到  
**解决**:
1. 确保已设置 `Qt_DIR` 环境变量
2. 在 CMakeLists.txt 中添加：
```cmake
set(CMAKE_PREFIX_PATH "C:/Qt/5.x.x/mingw_64")
find_package(Qt5 REQUIRED COMPONENTS Widgets)
```
3. 或在 CMake 配置时指定 `-DCMAKE_PREFIX_PATH=C:/Qt/5.x.x/mingw_64`

### Q11: Qt 调试时界面不显示
**原因**: 平台插件缺失或环境变量未设置  
**解决**:
1. 确保 Qt 的 bin 目录在 PATH 中
2. 在 launch.json 的 environment 中添加：
```json
{
    "name": "QT_QPA_PLATFORM",
    "value": "windows"
}
```
3. 或设置系统环境变量 `QT_QPA_PLATFORM=windows`

### Q12: CMake 构建时出现 "No such file or directory"
**原因**: 源文件路径错误或 CMakeLists.txt 配置不正确  
**解决**:
1. 检查 CMakeLists.txt 中的 `add_executable` 路径
2. 确保源文件存在
3. 清理构建目录：`rm -rf build` 后重新配置

---

> **最后更新**: 2026年  
> **适用平台**: Windows 10/11  
> **编辑器版本**: VS Code 1.90+
