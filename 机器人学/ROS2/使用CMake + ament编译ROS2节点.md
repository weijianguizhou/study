# 使用CMake + ament编译ROS2节点
## 编写节点
编写一个ROS2的C++节点非常简单，只需几行代码。

打开终端，创建`chapt2/basic`目录，用VSCODE打开d2lros2目录。

```bash
mkdir -p d2lros2/chapt2/basic/
code d2lros2
```
接着在左侧chapt2/basic下新建`src/firstnode.cpp`，然后在firstnode.cpp中输入下面的代码。
```cpp
#include "rclcpp/rclcpp.hpp"
int main(int argc, char **argv)
{
    // 调用rclcpp的初始化函数
    rclcpp::init(argc, argv);
    // 调用rclcpp的循环运行我们创建的first_node节点
    rclcpp::spin(std::make_shared<rclcpp::Node>("first_node"));
    return 0;
}
```
## 初学误区：直接g++编译
有人会尝试直接用g++编译，在VS CODE里按Ctrl+Shift+B，选择**C/C++: gcc 生成活动文件**：

```bash
/usr/bin/gcc -fdiagnostics-color=always -g firstnode.cpp -o firstnode
```
报错：
```bash
firstnode.cpp:1:10: fatal error: rclcpp/rclcpp.hpp: 没有那个文件或目录
    1 | #include "rclcpp/rclcpp.hpp"
      |          ^~~~~~~~~~~~~~~~~~~
compilation terminated.
```

没有那个文件或目录。常见报错，因为g++编译器没有找到**rclcpp/rclcpp.hpp**这个头文件。

有人会想到"告诉编译器头文件的位置"，找到`/opt/ros/lyrical/include/rclcpp/rclcpp/rclcpp.hpp`后加上`-I`参数。但这样仍然会继续报出几十个缺失的头文件、链接错误。**根本原因**是：ROS2的C++包（rclcpp）依赖 ament/CMake 提供的完整头文件路径、依赖库和`RMW_IMPLEMENTATION`等宏定义，单文件g++编译是行不通的。

## 正确做法：构建一个ament包
ROS2 C++节点必须以标准 ament 包的形式用 CMake 构建。

### 1. 创建标准配置文件
目录结构如下：

```
chapt2/basic/
├── CMakeLists.txt
├── package.xml
└── src/
    └── firstnode.cpp
```

在`basic`目录下新建**CMakeLists.txt**：

```cmake
cmake_minimum_required(VERSION 3.8)
project(firstnode)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)

add_executable(firstnode src/firstnode.cpp)
target_link_libraries(firstnode rclcpp::rclcpp)

install(TARGETS
  firstnode
  DESTINATION lib/${PROJECT_NAME})

ament_package()
```


再新建**package.xml**：

```xml
<?xml version="1.0"?>
<package format="3">
  <name>firstnode</name>
  <version>0.0.1</version>
  <description>ROS2 first node example</description>
  <maintainer email="weizhou@todo.todo">weizhou</maintainer>
  <license>Apache-2.0</license>

  <buildtool_depend>ament_cmake</buildtool_depend>
  <depend>rclcpp</depend>

  <export>
    <build_type>ament_cmake</build_type>
  </export>
</package>
```


### 2. 配置VS CODE构建任务
修改`/home/weizhou/d2lros2/.vscode/tasks.json`，把默认的*gcc 生成活动文件*替换为CMake构建任务：

```json
{
    "tasks": [
        {
            "type": "shell",
            "label": "CMake 构建 (ROS2)",
            "command": "/usr/bin/cmake -B build -DCMAKE_INSTALL_PREFIX=install -DCMAKE_PREFIX_PATH=/opt/ros/lyrical -DPython3_EXECUTABLE=/usr/bin/python3 -DPython_EXECUTABLE=/usr/bin/python3 -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && /usr/bin/cmake --build build",
            "options": {
                "cwd": "${fileDirname}"
            },
            "problemMatcher": [ "$gcc" ],
            "group": { "kind": "build", "isDefault": true },
            "detail": "配置并构建当前目录下的 ament 包"
        }
    ],
    "version": "2.0.0"
}
```

在`firstnode.cpp`里按**Ctrl+Shift+B**即可编译，成功后生成`build/firstnode`。

同时配置`.vscode/c_cpp_properties.json`让IntelliSense识别ROS2头文件、消除红波浪线：

```json
{
    "configurations": [
        {
            "name": "ROS2 Lyrical",
            "includePath": [
                "/opt/ros/lyrical/include/**",
                "${workspaceFolder}/**"
            ],
            "cStandard": "c17",
            "cppStandard": "c++17",
            "intelliSenseMode": "linux-gcc-x64",
            "compileCommands": "${fileDirname}/build/compile_commands.json"
        }
    ],
    "version": 4
}
```

### 3. 命令行编译
```bash
cd d2lros2/chapt2/basic
cmake -B build -DCMAKE_INSTALL_PREFIX=install \
      -DCMAKE_PREFIX_PATH=/opt/ros/lyrical \
      -DPython3_EXECUTABLE=/usr/bin/python3 \
      -DPython_EXECUTABLE=/usr/bin/python3 \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
```

## 运行节点
```bash
source /opt/ros/lyrical/setup.bash
export PATH=/usr/bin:$PATH
./build/firstnode
```
节点启动后（Ctrl+C结束）输出：
```bash
[INFO] ... [rclcpp]: signal_handler(signum=15)
```

> 注意：本机ROS2发行版是lyrical，不是老教程误写的humble，安装目录是`/opt/ros/lyrical`。

## 常见坑汇总
| 报错 | 原因 | 解决 |
|------|------|------|
| `fatal error: rclcpp/rclcpp.hpp: 没有那个文件或目录` | 用gcc单文件编译，缺ament提供的include路径 | 改用CMake/ament构建（本文方案） |
| `Unknown CMake command "ament_target_dependencies"` | 新版ament_cmake移除了该函数 | 改用`target_link_libraries(firstnode rclcpp::rclcpp)` |
| `File .../package.xml does not exist` | ament包缺少package.xml | 补上package.xml |
| `ModuleNotFoundError: No module named 'catkin_pkg'` | Anaconda的Python抢占PATH | 指定`-DPython3_EXECUTABLE=/usr/bin/python3 -DPython_EXECUTABLE=/usr/bin/python3` |

> 之后每新增一个节点，不要直接g++，而是在`src/`下放源码，在`CMakeLists.txt`里加对应的`add_executable`和`target_link_libraries`，再按Ctrl+Shift+B。