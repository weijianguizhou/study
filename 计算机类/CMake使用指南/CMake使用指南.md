## 一、CMake 简介与核心概念

CMake 是一个跨平台的构建系统生成工具，它不直接构建项目，而是根据平台和编译器的不同生成相应的构建文件（如 Unix 下的 Makefile、Windows 下的 Visual Studio 工程文件）。CMake 本身使用 `CMakeLists.txt` 文件描述构建规则，具有语言简洁、模块化强、支持现代 C++ 特性等优点。

核心概念包括：
- **目标**：可执行文件、库文件（静态库 `.a/.lib`，动态库 `.so/.dll`）都是目标
- **属性**：目标的头文件路径、链接库、编译选项等
- **生成器表达式**：在构建时求值的表达式，用于条件化配置
- **预设（Presets）**：CMake 3.19+ 引入，用于统一配置命令行选项

## 二、安装与环境配置

### 1. 安装 CMake
- **Linux**：`sudo apt install cmake`（Ubuntu/Debian）或 `sudo yum install cmake`（CentOS）
- **macOS**：`brew install cmake`
- **Windows**：从官网下载安装包，安装时勾选“Add CMake to system PATH”

验证安装：`cmake --version`

### 2. 推荐工具
- **构建工具**：Unix Makefiles（默认）、Ninja（更快）、Visual Studio
- **生成器指定**：`-G "Ninja"`
- **IDE 集成**：CLion、VS Code（CMake Tools 插件）、Visual Studio 2017+

## 三、基础语法与常用命令

### 1. 最小示例
```cmake
cmake_minimum_required(VERSION 3.15)   # 声明最低版本
project(HelloWorld)                     # 项目名称

add_executable(hello main.cpp)         # 添加可执行文件
```

### 2. 关键命令速查表

| 命令 | 作用 |
|------|------|
| `add_executable(target src...)` | 生成可执行文件 |
| `add_library(target STATIC/SHARED src...)` | 生成静态/动态库 |
| `target_include_directories(target PRIVATE/PUBLIC dir...)` | 指定头文件路径 |
| `target_link_libraries(target lib1 lib2...)` | 链接库 |
| `target_compile_definitions(target PRIVATE MACRO=value)` | 添加宏定义 |
| `target_compile_options(target PRIVATE -Wall -O2)` | 添加编译选项 |
| `find_package(package REQUIRED)` | 查找外部包（如 OpenCV、Boost） |
| `add_subdirectory(subdir)` | 添加子目录（子项目） |
| `set(variable value CACHE TYPE "doc")` | 设置缓存变量（用户可配置） |
| `option(option_name "描述" DEFAULT_VALUE)` | 提供 ON/OFF 选项 |

### 3. 作用域关键字
- **PRIVATE**：仅目标自身需要（如内部使用的库）
- **PUBLIC**：目标及其依赖都需要（如头文件路径）
- **INTERFACE**：仅依赖需要（如纯头文件库）

示例：
```cmake
target_include_directories(myLib PUBLIC include)   # myLib 的使用者也可见
target_include_directories(myLib PRIVATE src)      # 仅 myLib 内部使用
```

## 四、完整项目示例

### 项目结构
```
my_project/
├── CMakeLists.txt
├── src/
│   ├── main.cpp
│   ├── math.cpp
│   └── math.h
├── libs/
│   └── geometry/
│       ├── CMakeLists.txt
│       ├── circle.cpp
│       └── circle.h
└── external/
    └── fmt/          # 第三方库（源码或二进制）
```

### 根目录 `CMakeLists.txt`
```cmake
cmake_minimum_required(VERSION 3.15)
project(MyApp VERSION 1.0.0 LANGUAGES CXX)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 选项：是否构建测试
option(BUILD_TESTS "Build unit tests" OFF)

# 添加子项目（子目录中的 CMakeLists.txt）
add_subdirectory(libs/geometry)

# 添加可执行文件
add_executable(myapp src/main.cpp src/math.cpp)

# 链接子项目库和外部库
target_link_libraries(myapp PRIVATE geometry_lib)

# 如果使用外部 fmt 库（假设已 find_package）
find_package(fmt CONFIG REQUIRED)
target_link_libraries(myapp PRIVATE fmt::fmt)

# 头文件路径
target_include_directories(myapp PRIVATE src)

# 条件构建测试
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# 安装规则
install(TARGETS myapp DESTINATION bin)
install(FILES src/math.h DESTINATION include)
```

### 子目录 `libs/geometry/CMakeLists.txt`
```cmake
add_library(geometry_lib STATIC circle.cpp)
target_include_directories(geometry_lib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_compile_features(geometry_lib PUBLIC cxx_std_17)  # 传递 C++17 要求
```

## 五、高级特性

### 1. 生成器表达式
在构建时动态判断：使用 `$<condition:value>` 语法

```cmake
# 只在 Debug 配置下添加定义
target_compile_definitions(myapp PRIVATE $<CONFIG:Debug>:DEBUG_MODE=1)

# 不同平台链接不同库
target_link_libraries(myapp PRIVATE
    $<IF:$<PLATFORM_ID:Windows>, ws2_32, pthread>)

# 获取所有源文件的 .cpp 文件
file(GLOB_RECURSO SRC_FILES "src/*.cpp")
```

注意：不推荐使用 `GLOB` 收集源文件（新增文件不自动触发 CMake 重配），应显式列出。

### 2. 查找第三方包
```cmake
# 使用 find_package 的两种模式
find_package(OpenCV REQUIRED)               # Module 模式（FindOpenCV.cmake）
find_package(TBB CONFIG REQUIRED)           # Config 模式（TBBConfig.cmake）

target_link_libraries(myapp PRIVATE ${OpenCV_LIBS})
target_include_directories(myapp PRIVATE ${OpenCV_INCLUDE_DIRS})

# 手动查找库（备选方案）
find_library(MATH_LIB NAMES m libm PATHS /usr/lib)
target_link_libraries(myapp PRIVATE ${MATH_LIB})
```

### 3. 多配置生成器（Visual Studio、Xcode）
CMake 生成单个构建目录支持所有配置，使用 `CMAKE_CONFIGURATION_TYPES`：

```cmake
set(CMAKE_CONFIGURATION_TYPES "Debug;Release;RelWithDebInfo" CACHE STRING "" FORCE)

# 不同配置不同编译选项
target_compile_options(myapp PRIVATE
    $<$<CONFIG:Debug>:-g -O0>
    $<$<CONFIG:Release>:-O3 -DNDEBUG>
)
```

### 4. 自定义命令与目标
```cmake
# 构建前自动生成文件
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/version.h
    COMMAND ${CMAKE_COMMAND} -E echo "#define VERSION \"1.0\"" > version.h
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/version.txt
    COMMENT "Generating version.h"
)

add_custom_target(generate_version DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/version.h)
add_dependencies(myapp generate_version)   # myapp 依赖该自定义目标
```

### 5. 打包与安装
结合 CPack 生成安装包：
```cmake
include(CPack)
set(CPACK_GENERATOR "ZIP;NSIS")  # Windows 用 NSIS，Linux 用 DEB/RPM
set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
```

打包命令：`cpack`

## 六、最佳实践

### 1. 目录结构规范
```
project/
├── .gitignore
├── CMakeLists.txt
├── cmake/                 # 存放自定义 .cmake 模块
│   └── FindMyLib.cmake
├── src/
│   ├── CMakeLists.txt
│   └── ...
├── include/               # 公共头文件
│   └── project/
├── tests/
├── examples/
└── third_party/           # 使用 FetchContent 管理
```

### 2. 使用 FetchContent 管理依赖
避免手动下载第三方源码：
```cmake
include(FetchContent)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        release-1.12.1
)
FetchContent_MakeAvailable(googletest)

target_link_libraries(tests PRIVATE gtest_main)
```

### 3. 避免全局变量污染
- 不使用 `include_directories()` 等全局命令（影响所有后续目标）
- 每个目标独立使用 `target_*` 命令

### 4. 区分构建目录
始终使用 **out-of-source** 构建：
```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --parallel 4
```

### 5. 为库设定别名
```cmake
add_library(geometry STATIC geometry.cpp)
add_library(Project::geometry ALIAS geometry)  # 别名便于引用
```

### 6. 预设（Presets）简化命令行
`CMakePresets.json`：
```json
{
  "version": 3,
  "configurePresets": [
    {
      "name": "default",
      "generator": "Ninja",
      "binaryDir": "${sourceDir}/build",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_CXX_STANDARD": "17"
      }
    }
  ]
}
```
使用：`cmake --preset default`

## 七、调试与排错

### 常用调试技巧

1. **打印变量**：
   ```cmake
   message(STATUS "MY_VAR: ${MY_VAR}")
   message(WARNING "This is a warning")
   ```

2. **查看所有变量**：`cmake --trace-expand ..`（追踪每个命令）

3. **生成图形化依赖**：
   ```bash
   cmake --graphviz=deps.dot ..
   dot -Tpng deps.dot -o deps.png
   ```

4. **清理缓存**：删除 `build/CMakeCache.txt` 或整个 `build` 目录

5. **使用 --graphviz 查看目标关系**。

## 八、典型问题与解决方案

### 问题1：找不到头文件
- 检查 `target_include_directories` 路径是否正确，尤其注意 `PRIVATE/PUBLIC`
- 确认生成器表达式下的路径是否包含

### 问题2：链接时 undefined reference
- 检查库链接顺序（静态库依赖关系需从左到右）
- 使用 `target_link_libraries(A PRIVATE B)` 确保 B 被传递

### 问题3：CMake 版本过低
- 使用 `cmake_minimum_required(VERSION ...)` 并升级 CMake
- 或使用 `cmake_policy(VERSION ...)` 设置策略

### 问题4：不同编译器需要不同选项
```cmake
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(myapp PRIVATE -Wall -Wextra)
elseif(MSVC)
    target_compile_options(myapp PRIVATE /W4)
endif()
```

## 九、总结

CMake 是现代 C++ 项目构建的标准工具，其核心理念是**基于目标的配置**和**生成器表达式**。掌握以下要点即可有效使用：

- 每个 `add_executable` / `add_library` 都是一个独立目标
- 使用 `target_` 系列命令而非全局命令
- 保持构建目录与源码分离
- 善用 `FetchContent` 管理依赖
- 为不同平台/配置使用生成器表达式

随着 CMake 版本迭代（当前最新 3.28+），现代 CMake 更强调简洁性和可维护性，建议避免使用古老命令（如 `add_definitions`、`include_directories` 无作用域修饰）。通过本文指南，你可以从零开始构建跨平台的 C/C++ 项目，并适应从单文件到大型多模块项目的需求。

---

**参考资源**：
- 官方文档：https://cmake.org/documentation/
- 现代 CMake 教程：https://cliutils.gitlab.io/modern-cmake/

---

## 相关笔记

- [[../Eigen库使用指南/README|Eigen 库]]（C++ 线性代数库的 CMake 集成）
- [[../常用Git 命令|Git 命令]]（版本控制与 CMake 项目的协作）
- [[../数据结构|数据结构]]（C/C++ 项目中的算法实现与编译构建）
- 实战项目：GitHub 上搜索 `cmake-example`