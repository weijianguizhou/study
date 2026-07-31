# 19-CMake基础

VS的项目文件（`.vcxproj`）只能在Windows上用VS打开。如果你要和Linux/Mac协作，或者用CI/CD自动构建——你需要**CMake**。它是一个跨平台构建工具，你写一个`CMakeLists.txt`描述怎么编译，CMake帮你生成对应平台的构建文件（VS的`.sln`、Linux的`Makefile`……）。

---

# 一、最简单的CMakeLists.txt

假设你的项目只有一个文件`main.cpp`：

```
my_project/
├── main.cpp
└── CMakeLists.txt
```

`CMakeLists.txt`的内容：

```cmake
cmake_minimum_required(VERSION 3.15)    # CMake最低版本
project(MyApp VERSION 1.0)              # 项目名和版本

set(CMAKE_CXX_STANDARD 17)              # 用C++17
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(my_app main.cpp)         # 从main.cpp生成可执行文件my_app(.exe)
```

---

# 二、构建过程

CMake的构建分两步：**配置**（生成构建文件）+ **构建**（实际编译）。

```bash
# 在项目根目录下：
mkdir build && cd build        # 强烈建议在build子目录里构建（不乱污染源码）
cmake ..                        # 配置（..指向父目录的CMakeLists.txt）
cmake --build .                 # 构建（调VS或make来实际编译）
```

```powershell
# Windows上用MSVC的话：
cmake .. -G "Visual Studio 17 2022"   # 指定生成器
cmake --build . --config Release       # Release模式构建
```

---

# 三、多文件项目

```
my_project/
├── CMakeLists.txt
├── src/
│   ├── main.cpp
│   └── utils.cpp
└── include/
    └── utils.h
```

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyApp VERSION 1.0)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(my_app
    src/main.cpp
    src/utils.cpp
)

target_include_directories(my_app PRIVATE include)   # 头文件搜索路径
```

---

# 四、静态库和动态库

```cmake
# 把utils编译成静态库
add_library(utils STATIC
    src/utils.cpp
)
target_include_directories(utils PUBLIC include)

# 主程序链接这个库
add_executable(my_app src/main.cpp)
target_link_libraries(my_app PRIVATE utils)
```

`STATIC`换成`SHARED`就是动态库（Windows的`.dll`、Linux的`.so`）。

---

# 五、用Eigen举例

```cmake
cmake_minimum_required(VERSION 3.15)
project(EigenDemo)

# 告诉CMake Eigen头文件在哪
include_directories(D:/Libraries/eigen-3.4.0)

add_executable(demo main.cpp)
```

Eigen是纯头文件库，不用链接，只要告诉编译器头文件在哪就行。

---

# 六、CMake + VS Code

VS Code装**CMake Tools**扩展后，打开带`CMakeLists.txt`的文件夹：

1. 按`Ctrl+Shift+P` → 搜索 `CMake: Configure`
2. 选择编译器（Kit）→ 比如`GCC 13.2.0`
3. 底部状态栏出现Build按钮 → 点一下编译
4. 点旁边的三角形 → 运行

全程不用离开编辑器。VS Code + CMake Tools = 轻量跨平台开发体验。

---

## 下一步

- [[20-多文件项目管理|多文件项目管理]]
- [[21-实战-学生管理系统|实战：学生管理系统]]
