# 10-CMake与vcpkg集成

在 Visual Studio 2026 里写 C++，项目系统有两条路：MSBuild 的 `.vcxproj` 与 CMake。前者是 Windows 的原生项目系统，后者是跨平台的构建描述标准。本章不教 CMake 语法——那是 [[../CMake使用指南/CMake使用指南|CMake 使用指南]] 的活——只讲两件事：**VS 2026 怎么消费 CMake 项目**，以及**怎么让 vcpkg 自动把第三方库接进这套流程**。

---

## 1. 为什么在 VS 里用 CMake

### 1.1 `.vcxproj` 的边界与 CMake 的一等公民地位

MSBuild 项目把源文件清单、编译链接选项、以及 Windows 专属属性（平台工具集、SDK 版本、配置与平台映射）都写死在 XML 里。它在 Windows 上很成熟（见 [[06-项目属性与编译配置|第 06 章]]），但**只在 MSBuild 里成立**：一旦需要 Linux/macOS 构建——哪怕只是让 CI 跑一遍 Linux 单测——就得另维护一份 Makefile 或 CMake，两份描述迟早漂移。相比之下，CMake 在 VS 2026 里是**一等公民**，不是插件：

- **不需要任何扩展**：**文件 > 打开 > 文件夹** 就能直接开工。
- **CMake 目标视图**与解决方案资源管理器同级，目标直接列出，右键即可生成、调试。
- 调试、IntelliSense、测试资源管理器、性能探查器、clang-tidy、AddressSanitizer 对 CMake 项目**全部可用**。
- **自带 CMake 4.1.1**，也允许改用你自己安装的版本，并直接读取 **`CMakePresets.json`** 这一跨编辑器标准格式。

> **提示**：只要项目要在 Windows 之外构建，或团队里有人用 VS Code/CLion，第一天就选 CMake。MSBuild 只适合"确定一辈子只在 Windows 上"的场景。

### 1.2 两条路的能力对比

| 能力维度 | MSBuild 项目（`.vcxproj`） | CMake 项目 |
|----------|---------------------------|------------|
| 项目文件 | `.sln` + `.vcxproj` + `.filters`，XML | `CMakeLists.txt`，纯文本 |
| 跨平台构建 | ❌ 只能由 MSBuild 在 Windows 上构建 | ✅ Windows / Linux / macOS 通吃 |
| VS 中的界面 | 解决方案资源管理器、属性页、属性表 | 文件夹视图 + CMake 目标视图，无属性页 |
| 选项配置入口 | 图形化属性页（字段极多） | `target_*` 命令 + `CMakePresets.json` |
| 多配置支持 | 原生（Debug/Release 各有一套属性） | 取决于生成器：VS 生成器支持，Ninja 单配置 |
| 依赖管理 | NuGet、手工配置 | `find_package`、FetchContent、**vcpkg** |

> **注意**：两条路**不是互斥的**。CMake 能反向生成 `.sln`/`.vcxproj`（见第 5.2 节），"CMake 做主干 + 生成项目文件交给只有 MSBuild 的 CI"完全成立。

---

## 2. 在 VS 中打开 CMake 项目

### 2.1 用"打开文件夹"，不是"打开项目"

CMake 项目**没有 `.sln` 可打开**，这是新手第一个卡点。正确入口是 **文件 > 打开 > 文件夹**，选中含根 `CMakeLists.txt` 的目录。打开后 VS 会：

1. 把根 `CMakeLists.txt` 当作构建描述入口；
2. 找 **`CMakePresets.json`**（首选）或 **`CMakeSettings.json`**（旧格式）生成配置列表；
3. 找 **`vcpkg.json`**，若存在就准备激活 vcpkg 环境（见第 8 节）；
4. 读取 `.editorconfig`、`.gitignore` 与 `.vs/` 里的状态。

> **提示**：一个工作区只应有一个构建入口。多个互不相关的项目塞进同一文件夹会让配置下拉变乱，多项目请用 `add_subdirectory()` 组织。

### 2.2 文件夹视图与 CMake 目标视图

解决方案资源管理器左上角有**视图切换下拉**，在两套视角之间切换：

```text
解决方案资源管理器（CMake 项目的两种视角）
┌──────────────────────────┬──────────────────────────┐
│ 文件夹视图                │ CMake 目标视图            │
├──────────────────────────┼──────────────────────────┤
│ ▾ MyApp/                 │ ▾ CMake Targets          │
│   ▾ src/main.cpp         │   ▾ MyApp                │
│   ▾ include/math.h       │     myapp.exe  ← 启动项   │
│   CMakeLists.txt         │   ▾ libs                 │
│   CMakePresets.json      │     geometry_lib (STATIC) │
│   vcpkg.json             │                          │
└──────────────────────────┴──────────────────────────┘
     编辑源码、增删文件的视角    构建、调试、选启动项的视角
```

两套视角**可以不一致**：磁盘上有文件但没被任何目标引用，就只在文件夹视图里出现；目标生成的中间产物则只在目标视图里有意义。

### 2.3 首次配置与工具包（Kit）选择

工具栏的**配置下拉**列出可用配置；第一次配置时 VS 会给出模板供选择（本机 MSVC、本机 Clang、WSL、远程 Linux 等），选定后自动跑一次 **configure**，输出在 **输出 > 显示输出自 > CMake**，成功的标志是构建目录里出现 `CMakeCache.txt`。

| 菜单命令 | 等价命令 | 用途 |
|----------|----------|------|
| **项目 > 配置缓存** | `cmake -S . -B <dir>` | 重新 configure，改 `CMakeLists.txt` 会自动触发 |
| **项目 > 生成** / **全部生成** | `cmake --build <dir>` | 增量构建启动目标 / 构建所有目标 |
| **项目 > 删除缓存并重新配置** | 删 `CMakeCache.txt` 后重配 | 换生成器、工具链、工具集后必做 |

> **注意**：`CMakeCache.txt` 存的是**第一次 configure 时确定的值**（生成器、编译器路径、工具链文件、各种 `-D` 变量）。只点"配置"不会刷新它们——这是第 11 节头号坑的来源，也是下一节推荐 Presets 的原因。

---

## 3. CMakePresets.json：团队协作的推荐方式

### 3.1 为什么它取代了 CMakeSettings.json

`CMakeSettings.json` 是 **VS 私有**格式；`CMakePresets.json` 是 **CMake 官方标准**，`cmake --preset <名字>`、VS Code、CLion、CI 都认。

| 维度 | `CMakeSettings.json`（旧） | `CMakePresets.json`（推荐） |
|------|---------------------------|----------------------------|
| 归属 | Visual Studio 私有 | CMake 官方标准格式 |
| 命令行 / 其它编辑器 | ❌ 都不可用 | ✅ `cmake --preset x64-debug`，VS Code、CLion 通用 |
| 继承与 CI | 复用能力有限，CI 得另写命令 | ✅ `inherits` 多层继承，CI 复用同一个 preset |

> **注意**：**两者同时存在时 VS 以 `CMakePresets.json` 为准**，`CMakeSettings.json` 被忽略。迁移时先把旧文件删掉或改名，免得改了不生效还找不到原因。

### 3.2 一份可用的 CMakePresets.json

放在工作区根目录，与 `CMakeLists.txt` 同级：

```json
{
  "version": 3,
  "configurePresets": [
    {
      "name": "windows-base",
      "hidden": true,
      "generator": "Visual Studio 18 2026",
      "binaryDir": "${sourceDir}/out/build/${presetName}",
      "cacheVariables": {
        "CMAKE_GENERATOR_PLATFORM": "x64",
        "CMAKE_GENERATOR_TOOLSET": "version=14.5x",
        "VCPKG_PLATFORM_TOOLSET_VERSION": "14.5x",
        "CMAKE_TOOLCHAIN_FILE": "$env{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
      }
    },
    { "name": "x64-debug", "displayName": "x64 Debug（VS 2026）",
      "inherits": "windows-base", "cacheVariables": { "CMAKE_BUILD_TYPE": "Debug" } },
    { "name": "x64-release", "inherits": "windows-base",
      "cacheVariables": { "CMAKE_BUILD_TYPE": "RelWithDebInfo" } }
  ],
  "buildPresets": [
    { "name": "x64-debug", "configurePreset": "x64-debug", "configuration": "Debug" },
    { "name": "x64-release", "configurePreset": "x64-release", "configuration": "RelWithDebInfo" }
  ]
}
```

| 字段 | 必需 | 作用 |
|------|:---:|------|
| `version` | ✅ | **预设 schema 的版本**，不是文档版本。数值越大解锁字段越多，对 CMake 最低版本要求也越高——团队里取"所有人都能满足的最低值" |
| `configurePresets` | ✅ | 配置预设数组，每项描述"怎么跑一次 configure" |
| `name` / `hidden` | ✅ / ❌ | 预设的唯一标识（供 `inherits` 与 `cmake --preset` 引用）；`hidden` 为 `true` 时不出现在下拉里，只作基类 |
| `generator` / `binaryDir` | ❌ | 生成器名；构建目录，支持 `${sourceDir}`、`${presetName}` 宏 |
| `cacheVariables` / `inherits` | ❌ | 以 `-D` 传给 CMake 的缓存变量；继承另一预设，子项覆盖父项 |
| `buildPresets` / `testPresets` | ❌ | 构建预设（用 `configurePreset` 回指，`configuration` 选配置）、测试预设（见 [[11-单元测试与代码质量|第 11 章]]） |

> **提示**：`CMAKE_GENERATOR_PLATFORM` 与 `CMAKE_GENERATOR_TOOLSET` 分别对应命令行的 `-A x64` 与 `-T`，比用某些 schema 版本才有的图形字段更稳；`displayName` 是下拉里给人看的名字，VS 优先显示它。

保存 Presets 后，VS 会立刻在工具栏**配置下拉**里列出所有非隐藏预设，同时 **项目 > 配置 <项目名>** 也列出同一批；文件被监视，一保存就自动重新 configure。整条链路上，**Presets 是配置的唯一真源**，VS 只负责把它翻译成一次 configure 调用。

---

## 4. CMake 设置编辑器

### 4.1 界面构成与 Presets 的取舍

**项目 > CMake 设置** 打开 **CMake 设置编辑器**——一个为 `CMakeSettings.json` 设计的图形界面：左栏是配置列表（可增删）；中栏是选中配置的字段（名称、生成器、平台、工具集、构建根目录、CMake 与构建命令参数）；下栏是**缓存变量表**，逐行填"名字 / 类型 / 值"（`BOOL`/`STRING`/`PATH`/`FILEPATH`），与 `cacheVariables` 一一对应。它的价值在于**不用背 JSON 字段名**，但**只覆盖一部分字段**：存在 `CMakePresets.json` 时，`inherits`、`hidden`、`buildPresets`、条件表达式这类结构性内容无法在图形界面里表达，只能直接编 JSON。

| 你的处境 | 建议 |
|----------|------|
| 新建项目、团队协作、要接 CI | 直接用 `CMakePresets.json`，编辑器只当"看一眼缓存变量"的工具 |
| 已有 `CMakeSettings.json` 且在跑 | 先别动；等要接 CI 或 VS Code 时一次性迁移到 Presets |

> **提示**：只要是**缓存变量**，改完都要重新配置。VS 一般会提示"CMake 缓存已过期，是否重新配置"——选是，别选忽略。

---

## 5. 生成器与工具集

### 5.1 `Visual Studio 18 2026` 生成器、`-T` 与自带的 CMake

CMake 为 VS 2026 提供的生成器名是 **`Visual Studio 18 2026`**（与 VS 2022 的 `Visual Studio 17 2022` 同一命名规律）。在 VS 里通常不必敲命令行，把 `generator` 写进 Presets 即可，效果一致：

```bat
:: 用 VS 2026 生成器配置；-A 指定平台，-T 指定工具集版本
cmake -S . -B out\build\vs -G "Visual Studio 18 2026" -A x64 -T "version=14.5x"
cmake --build out\build\vs --config Release      :: 多配置生成器必须带 --config
```

- `-T "version=14.5x"` 里的 `14.5x` 代表 **14.50 / 14.51 这一档**；想精确锁死就写完整版本号（如 `version=14.50.35717`），构建才可复现。**指定的工具集必须已安装**，否则配置阶段直接失败——用 VS 安装程序补装"MSVC v145 生成工具"；在 VS 的 CMake 项目里它对应缓存变量 **`CMAKE_GENERATOR_TOOLSET`**，最终同样变成 `-T`。
- 别把两件事搞混：**`v145` 是平台工具集家族**，`14.50`/`14.51` 是家族内的具体版本（见 [[01-VS2026概览与版本选择|第 1 章]]）。

VS 2026 还在安装目录的 `Common7\IDE\CommonExtensions\Microsoft\CMake\` 子树里自带一份 **CMake 4.1.1**，所以**不装 CMake 也能直接开工**；想改用自己安装的版本，在 VS 的选项里搜索 `CMake` 指定可执行文件路径。

> **注意**：CMake 4.x 移除了对 `cmake_minimum_required(VERSION < 3.5)` 的兼容。老项目里写着 `cmake_minimum_required(VERSION 3.0)` 的，用自带的 CMake 配置会直接报错——把版本号提到 3.5 以上即可。这是升级到 VS 2026 后 CMake 项目最常见的第一个报错。

### 5.2 反向：从 CMake 生成并构建 Visual Studio 项目

链路是双向的。用 VS 生成器 configure 之后，构建目录里就是货真价实的 `.sln` + `.vcxproj`，可以用 MSBuild 构建，也可以直接双击打开；VS 2026 支持新的 **SLNX** 解决方案格式，这套"CMake 生成 VS 解决方案 → 在 VS 里构建"的流程在这一代更顺畅。需要它的场合：CI 上只有 MSBuild、想用 MSBuild 侧的完整项目系统工具、要给不用 CMake 的同事交付。

> **注意**：生成出来的 `.sln` / `.vcxproj` 是**产物而非源码**，手工改了下次 configure 就被覆盖。要长期生效的修改一律写回 `CMakeLists.txt`。

---

## 6. 构建与调试 CMake 目标

### 6.1 选择启动项、断点与 F5

VS 需要知道 F5 启动哪个 exe：打开 **CMake 目标视图**，对目标右键 **设为启动项**（工具栏绿色三角旁的下拉也能切换），启动配置会写进 `.vs` 目录下的 `launch.vs.json`——**这是本机状态，应加入 `.gitignore`**。之后调试体验与 `.vcxproj` 项目完全一致：`F9` 断点、`F5` 启动、`F10`/`F11` 单步，**监视**/**调用堆栈**/**即时窗口**全部可用，工具栏还能直接填**命令行参数与工作目录**。唯一区别是"调试器怎么找到 exe"：VS 从 CMake 目标信息推断输出路径，而不是读 `.vcxproj` 的 `OutDir`——你在 `CMakeLists.txt` 里设了 `RUNTIME_OUTPUT_DIRECTORY`，调试器也会跟着走。

### 6.2 调试 `CMakeLists.txt` 脚本本身

CMake 脚本可以被调试，很多人不知道：在 `CMakeLists.txt`（或任何被 `include()` 的 `.cmake` 文件）里按 `F9` 设断点，然后执行 **项目 > 使用 CMake 调试配置缓存**。VS 会以"调试脚本"的方式跑 configure，停在断点时可查看 `${}` 变量的实际值、单步走 `if()` 分支。

| 症状 | 在断点处看什么 |
|------|---------------|
| `find_package` 找不到包 | `XXX_FOUND`、`XXX_DIR` 到底是什么 |
| 条件分支走错 / 路径拼接错误 | 参与 `if()` 判断的变量；`${CMAKE_CURRENT_SOURCE_DIR}`、`${CMAKE_BINARY_DIR}` |

> **注意**：脚本调试只覆盖 configure 阶段；构建阶段的问题（编译、链接报错）仍按 [[08-调试技术详解|第 08 章]] 排查。按 `F10` 会让根 `CMakeLists.txt` 每一行都停一下，长脚本优先用条件断点。

### 6.3 CMake 模块的 IntelliSense

VS 对 CMake 语言本身提供编辑器支持：`include(...)` 引入的 **CMake 模块有补全**，鼠标悬停在命令、模块、变量上有**快速信息**（签名与说明），`${}` 变量引用有补全与跳转。能做到这些，是因为 VS 在后台持续通过 CMake 的文件 API 解析项目结构。

> **实战场景**：一个项目在 Windows 上 `find_package(Qt6)` 正常、配到 WSL 就失败。与其反复加 `message()` 重配，不如在 `find_package` 后面打个断点，用 **项目 > 使用 CMake 调试配置缓存** 跑一次——两分钟就能看清是 `Qt6_DIR` 为空，还是 Linux 侧的 `CMAKE_PREFIX_PATH` 没设。

---

## 7. CMake 项目的多配置

### 7.1 单配置与多配置生成器的差别

| 生成器 | 类型 | 说明 |
|--------|------|------|
| `Ninja` / `Unix Makefiles` | **单配置** | 一个构建目录只对应一个配置，编译快，WSL/远程 Linux 的默认选择 |
| `Visual Studio 18 2026` | **多配置** | 一个构建目录装下 Debug/Release/RelWithDebInfo，由 MSBuild 管理 |
| `Ninja Multi-Config` | **多配置** | Ninja 的多配置版本，跨平台，兼顾速度与多配置 |

```text
单配置（Ninja）                     多配置（Visual Studio 18 2026）
out/build/                          out/build/
├── x64-debug/                      └── vs-x64/
│   ├── CMakeCache.txt                  ├── CMakeCache.txt
│   └── myapp.exe        ← Debug        ├── MyApp.sln
└── x64-release/                        ├── Debug/myapp.exe
    ├── CMakeCache.txt                  └── RelWithDebInfo/myapp.exe
    └── myapp.exe        ← Release
 每个配置一个构建目录                  一个构建目录装下全部配置
（各有一份 CMAKE_BUILD_TYPE）         （靠 --config / 配置下拉切换）
```

| 动作 | 单配置（Ninja） | 多配置（Visual Studio 生成器） |
|------|----------------|------------------------------|
| 选配置的时机 | **configure 时**定死 | **build 时**决定 |
| 用什么指定 | `-DCMAKE_BUILD_TYPE=Release` | `--config Release` |
| `CMAKE_BUILD_TYPE` 是否有效 | ✅ | ❌ **被忽略**，不报错也不生效 |
| 同时要 Debug 与 Release | 开两个构建目录 | 同一目录切配置（VS 里就是工具栏配置下拉） |

> **注意**：**"多配置生成器里写 `CMAKE_BUILD_TYPE` 不生效"是最常见的沉默失败**——不报错，只是被忽略。用多配置生成器时，配置一律通过 `buildPresets` 的 `configuration` 字段或 `--config` 指定。生成器表达式 `$<CONFIG:...>` 在两种生成器下都可用。

---

## 8. vcpkg 集成

### 8.1 清单模式与经典模式

| 维度 | 经典模式（Classic） | 清单模式（Manifest，推荐） |
|------|--------------------|---------------------------|
| 依赖声明位置 | 无，靠命令行 `vcpkg install` | 项目根目录的 **`vcpkg.json`** |
| 库安装到哪 | vcpkg 安装目录的 `installed/` | **项目构建目录**下的 `vcpkg_installed/` |
| 版本可复现 | ❌ 换个时间装可能拿到别的版本 | ✅ 由 `builtin-baseline` 锁定 |
| 机器间一致性 | 靠文档与口头约定 | 依赖清单**提交进版本库**即可 |
| 多项目共存 | 全局安装的库互相干扰 | 各项目独立，互不影响 |
| VS 中的体验 | 需手工配工具链 | **检测到 `vcpkg.json` 后自动生效** |

也就是说，只要工作区根目录有 `vcpkg.json`，VS 就会自动把它自带的 vcpkg 接进 CMake 配置——**不需要你手写 `CMAKE_TOOLCHAIN_FILE`**，输出窗口的 CMake 面板里能看到 vcpkg 正在解析清单、安装依赖。想改用你自己克隆的 vcpkg（团队统一版本时常用），设置环境变量 **`VCPKG_ROOT`** 指向那份克隆即可。

> **注意**：**vcpkg 首次配置可能极慢**。依赖没有预编译二进制时 vcpkg 会从源码编译，带 GUI/网络依赖的库编译半小时以上很常见，而且**每个配置各编一份**。第一次配完就去做别的事，别中途反复取消重配，那只会更慢。

### 8.2 一份 vcpkg.json 示例

```json
{
  "name": "myapp",
  "version": "1.0.0",
  "dependencies": [
    "fmt",
    { "name": "curl", "default-features": false, "features": [ "ssl" ] }
  ],
  "builtin-baseline": "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0",
  "overrides": [ { "name": "fmt", "version": "10.2.1" } ],
  "features": {
    "tests": { "description": "构建单元测试", "dependencies": [ "gtest" ] }
  }
}
```

| 字段 | 作用 |
|------|------|
| `name` / `version` | 项目自身标识，清单模式要求 |
| `dependencies` | 依赖列表。可只写包名，也可写成对象以精确控制特性；`default-features` 设 `false` 可避免拖进用不到的东西 |
| `builtin-baseline` | **锁定基线**：vcpkg 仓库的某个提交号，决定所有依赖解析到的版本。**必须换成你自己 vcpkg 仓库的真实提交号**（`git -C <vcpkg目录> rev-parse HEAD`） |
| `overrides` | 强制某依赖用指定版本，优先级高于基线，用于临时绕开有问题的版本 |
| `features` | 顶层 `features` 是**本项目对外暴露的特性**（消费方可用 `"myapp[core,tests]"` 引入）；依赖对象里的 `features` 则是只启用该依赖的指定特性 |

> **提示**：特性名（如示例里的 `ssl`）以你所用的基线为准——`vcpkg search <包名>`，或直接查看官方 ports 目录里该包的 `vcpkg.json` 最可靠。

### 8.3 vcpkg-configuration.json 与注册表

`vcpkg.json` 管"要什么"，`vcpkg-configuration.json` 管"从哪儿拿"：

```json
{
  "default-registry": { "kind": "builtin", "baseline": "a1b2c3…" },
  "registries": [
    { "kind": "git", "repository": "https://example.com/your-org/vcpkg-registry.git",
      "baseline": "f0e1d2c3b4a5968778695a4b3c2d1e0f1a2b3c4d",
      "packages": [ "your-company-lib" ] }
  ]
}
```

概念上分三类：**内置注册表（builtin）** 指 vcpkg 自带的官方 ports 集合；**git 注册表** 指你自己或公司维护的 ports 仓库，用来分发私有库与打过补丁的第三方库；**`baseline`** 是注册表的基线提交号，与清单里的 `builtin-baseline` 同一套机制——**没有基线，版本就不可复现**。`packages` 声明该注册表负责哪些包，其余仍走默认注册表；同一个包只能由一个注册表提供，重叠声明会报错，私有包记得加组织前缀避免与官方包重名。

### 8.4 工具集对齐与 `CMAKE_TOOLCHAIN_FILE`

vcpkg 编译依赖时用的编译器必须与主项目一致，否则会出现"依赖用 v143 编、主程序用 v145 链"的诡异错误。**`VCPKG_PLATFORM_TOOLSET_VERSION`** 就是给 vcpkg 指定 MSVC 平台工具集版本的缓存变量，取值与 `-T` 的 `version=` 同一套版本号；把它与 `CMAKE_GENERATOR_TOOLSET` 写成同一个数并提交进 Presets 最省事：

```json
"cacheVariables": {
  "VCPKG_PLATFORM_TOOLSET_VERSION": "14.50",
  "CMAKE_GENERATOR_TOOLSET": "version=14.50",
  "CMAKE_TOOLCHAIN_FILE": "$env{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake",
  "VCPKG_TARGET_TRIPLET": "x64-windows"
}
```

在 VS 里用清单模式通常不必写工具链文件，但**命令行构建、CI、以及不用 VS 内置 vcpkg 的场景**必须自己指定：

```bat
cmake -S . -B out\build\vs -G "Visual Studio 18 2026" -A x64 ^
      -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake ^
      -DVCPKG_TARGET_TRIPLET=x64-windows
```

- **`CMAKE_TOOLCHAIN_FILE`** 指向 vcpkg 的工具链脚本，它让 `find_package` 自动找到 vcpkg 装的库；`$env{VCPKG_ROOT}` 是预设里的环境变量宏，路径分隔符统一用 `/`。
- **`VCPKG_TARGET_TRIPLET`** 指定三元组（平台 + 运行时 + 链接方式）：`x64-windows` 是动态链接，静态链接用 `x64-windows-static`。**三元组必须与项目的运行库设置一致**，否则链接期会爆重复符号或找不到符号（见 [[12-发布与部署|第 12 章]]）。
- 工具链文件是**缓存变量，只在第一次 configure 时生效**，改了它必须 **项目 > 删除缓存并重新配置**。

---

## 9. 手动管理第三方库的替代方案

### 9.1 直接改目录，或者用 NuGet

最原始的办法是把路径手工填进构建系统：MSBuild 项目在 **项目 > 属性 > C/C++ > 常规 > 附加包含目录** 填头文件目录、**链接器 > 常规 > 附加库目录** 填 `.lib` 目录、**链接器 > 输入 > 附加依赖项** 写库名（字段详情见 [[06-项目属性与编译配置|第 06 章]]）；CMake 项目本质相同，只是换成 `target_include_directories()` 与 `target_link_libraries()`。它的问题随规模放大：**路径写死**（换机器就要重配）、**Debug/Release 各配一遍**（`fmtd.lib` 与 `fmt.lib` 容易错配）、**传递依赖要手工补**、**版本信息不在仓库里**（新人不知道装哪个版本）。NuGet 则是另一条路，但用在 C++ 上限制明显：包必须提供 `.props`/`.targets` 才能自动接线，C++ 包数量远少于 vcpkg 且大量 Windows-only，**对 CMake 项目的支持也弱**（原生集成主要面向 MSBuild 项目）。

### 9.2 为什么推荐 vcpkg

| 方案 | 版本可复现 | 跨平台 | 传递依赖 | 与 CMake 配合 | 适合场景 |
|------|:---:|:---:|:---:|:---:|------|
| 手工改包含/库目录 | ❌ | ❌ | ❌ | 一般 | 一次性小工具、单个头文件库 |
| NuGet | ✅ | ❌ | ✅ | 弱 | MSBuild 项目 + Windows 专属包 |
| FetchContent 拉源码 | ✅（锁 tag） | ✅ | ✅ | ✅ | 依赖少、愿意每次编译依赖 |
| **vcpkg 清单模式** | ✅ | ✅ | ✅ | ✅ | **正式项目的默认选择** |

> **提示**：vcpkg 生态里找不到的库比想象中少，但确实存在（许可证受限、内部私有库）。私有库用第 8.3 节的**自定义 git 注册表**解决，比退回手工配路径划算得多。

---

## 10. WSL / 容器 / 远程 Linux 开发

### 10.1 WSL

① 在 VS 安装程序里勾选工作负荷 **"使用 C++ 的 Linux、Mac 和嵌入式开发"**（旧名 "C++ Linux"，本代改了名，按新名字搜）；② 在 WSL 发行版里装工具链 `sudo apt install build-essential gdb cmake ninja-build`；③ **文件 > 打开 > 文件夹** 打开项目，在**配置下拉**里选面向 WSL 的配置（或在 Presets 里加一个使用 WSL 工具包的配置）；④ 构建并 `F5`，调试由 WSL 里的 `gdb` 承担，断点、单步、调用堆栈与本地一致。关键是 **IntelliSense 也在 Linux 侧运行**，Linux 特有的头文件路径与宏才准确，否则会看到一堆"找不到 `<unistd.h>`"的假报错。

> **提示**：项目放 WSL 的**原生文件系统**（`/home/<用户>/...`）而不是 `/mnt/c/...`。跨文件系统访问的 I/O 开销很大，大型项目的构建与 IntelliSense 速度差距非常明显。

### 10.2 Dev Containers（Docker 与 Podman）

容器路线把"开发环境"本身纳入版本控制：仓库里放一个 `.devcontainer/devcontainer.json` 描述基础镜像、工具链与挂载；打开该文件夹后 VS 提供**在容器中打开**的入口，之后的编辑、构建、调试都在容器内进行。**Docker 与 Podman 都支持**，不是只有 Docker 一条路；VS 2026 的**附加到进程**从 18.10 起支持 **Podman** 容器，并且**可以调试容器内的 C++ 与 .NET 进程**。

> **注意**：容器里必须装有调试工具链（`gdb`、编译器等），否则只能构建不能调试；容器内外的**路径映射**也要对上，`devcontainer.json` 的挂载写错，断点就会变成空心的。

### 10.3 远程 Linux（SSH）与远程单元测试

连一台真正的 Linux 机器（物理机、虚拟机或服务器）：在 **工具 > 选项 > 跨平台 > 连接管理器** 里添加 SSH 连接（菜单名在不同版本间略有差异，找不到就在选项里搜"跨平台"）；在配置下拉里选该远程连接对应的配置，或自己写一个指定远程编译器与 Ninja 生成器的预设；configure 与 build 在远端执行，调试通过远端 `gdbserver` 完成。**测试资源管理器还能发现并运行远端机器上的单元测试**（远程单元测试），配合测试预设更好用（见 [[11-单元测试与代码质量|第 11 章]]）。三条路线怎么选：**WSL** 适合个人在 Windows 与 Linux 间来回切，最省事；**Dev Containers** 适合团队要求"环境一致、开箱即用"；**远程 Linux（SSH）** 适合目标就是真实服务器、发行版或交叉编译的场景。

> **实战场景**：一个只在 Windows 上维护的项目要接 Linux CI。与其在 CI 里重写构建脚本，不如先在 VS 里连一台 Linux 跑通 configure——**同一份 `CMakeLists.txt` 与 `CMakePresets.json`，Windows 侧用 VS 生成器，Linux 侧加一个 Ninja 预设**，CI 里直接 `cmake --preset linux-release` 即可。这正是第 3 节推荐 Presets 的根本原因。

---

## 11. 常见坑

| 现象 | 原因 | 处置 |
|------|------|------|
| 找不到编译器，或配置过了但构建命令跑不起来 | **生成器与 Kit 不匹配**：Ninja 配了 MSVC 工具集，或 VS 生成器却指定 Linux 的 gcc | 生成器与编译器必须成对：VS 生成器 ↔ MSVC，Ninja ↔ 显式指定 `CMAKE_CXX_COMPILER` |
| 改了工具链、工具集或某个 `-D` 变量却完全不生效 | **`CMakeCache.txt` 脏了**：缓存变量只写一次 | **项目 > 删除缓存并重新配置**，或删掉构建目录里的 `CMakeCache.txt` |
| 路径报错、找不到文件、输出乱码 | **路径含中文或空格**：脚本与工具的引号处理不一致 | 项目路径只用 ASCII 字母、数字、下划线与短横线，避开 `C:\Program Files` 这类目录 |
| 报"找不到指定版本的 MSVC 工具集" | **工具集版本对不上**：`-T version=14.5x` 指定的版本没装 | 用安装程序补装，或改成已安装的版本；同时核对 `VCPKG_PLATFORM_TOOLSET_VERSION` |
| 首次配置卡几十分钟，像死了一样 | **vcpkg 首次构建极慢**：依赖要源码编译，且每个配置一份 | 耐心等完第一次，别中途取消；减少 `dependencies`、关掉用不到的 `features` |
| Debug 里混进 Release 产物，或产物路径到处散落 | **多配置目录混乱**：多配置生成器里写了 `CMAKE_BUILD_TYPE`，或 `binaryDir` 没带 `${presetName}` | 多配置一律用 `--config`／配置下拉；`binaryDir` 统一写 `${sourceDir}/out/build/${presetName}` |

---

## 12. 端到端实战：从零到 F5

### 12.1 目录结构

做一个用 `fmt` 打印格式化输出的控制台程序：Windows 上用 VS 2026 构建，依赖交给 vcpkg，配置由 Presets 描述。

```text
MyApp/                          ← 用 VS 打开的就是这个文件夹
├── CMakeLists.txt              ← 构建描述
├── CMakePresets.json           ← 配置描述（提交）
├── vcpkg.json                  ← 依赖清单（提交）
├── src/main.cpp
└── out/build/x64-debug/        ← 全部产物，不进版本库
    ├── vcpkg_installed/x64-windows/{include,lib}   ← vcpkg 在这里装依赖
    └── Debug/myapp.exe                             ← F5 启动的就是它
```

> **提示**：`.gitignore` 里写 `/out/`、`/.vs/`、`/vcpkg_installed/` 三行就够。构建目录与 vcpkg 安装目录都是**可再生**的，提交它们只会制造冲突。

### 12.2 三个文件

`CMakeLists.txt`——注意这里只有标准 CMake 写法，**没有任何 vcpkg 专属命令**：

```cmake
cmake_minimum_required(VERSION 3.20)
project(MyApp VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)          # 对应属性页里的 /std:c++20
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(myapp src/main.cpp)
find_package(fmt CONFIG REQUIRED)   # vcpkg 装上 fmt 后就能直接找到
target_link_libraries(myapp PRIVATE fmt::fmt)
```

`CMakePresets.json`——实战先留一个最小配置（完整字段与解释见第 3.2 节），因为根目录有 `vcpkg.json`，VS 会自动注入 vcpkg 工具链：

```json
{
  "version": 3,
  "configurePresets": [
    { "name": "x64-debug", "generator": "Visual Studio 18 2026",
      "binaryDir": "${sourceDir}/out/build/${presetName}",
      "cacheVariables": { "CMAKE_GENERATOR_PLATFORM": "x64" } }
  ],
  "buildPresets": [
    { "name": "x64-debug", "configurePreset": "x64-debug", "configuration": "Debug" }
  ]
}
```

`vcpkg.json`——把 `builtin-baseline` 换成你自己 vcpkg 仓库的真实提交号（`git -C %VCPKG_ROOT% rev-parse HEAD`）：

```json
{ "name": "myapp", "version": "1.0.0", "dependencies": [ "fmt" ],
  "builtin-baseline": "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0" }
```

```cpp
#include <fmt/core.h>
#include <string>

int main() {
    std::string name = "VS 2026";
    fmt::print("Hello, {}!\n", name);
}
```

### 12.3 在 VS 中配置、构建、调试

1. **打开项目**：**文件 > 打开 > 文件夹**，选中 `MyApp` 目录。
2. **选择配置**：工具栏配置下拉里选 `x64-debug`，VS 自动跑第一次 configure。这一步会**下载并编译 `fmt`**，可能要等几分钟，进度在 **输出 > 显示输出自 > CMake**。
3. **确认配置成功**：构建目录里出现 `CMakeCache.txt` 与 `vcpkg_installed/x64-windows/include/fmt/`。
4. **设启动项并调试**：解决方案资源管理器切到 **CMake 目标视图**，右键 `myapp` → **设为启动项**；在 `src/main.cpp` 的 `fmt::print` 行按 `F9`，按 `F5`，停在断点后在**监视**里看一眼 `name`，`F10` 单步，`F5` 继续。
5. **验证命令行一致**：在开发者命令提示符里跑 `cmake --preset x64-debug` 与 `cmake --build --preset x64-debug`，确认同一份 Presets 在 IDE 之外也能跑通。

> **实战场景**：走到第 5 步时你已经具备接入 CI 的全部条件——**依赖声明在 `vcpkg.json`，配置在 `CMakePresets.json`，命令是 `cmake --preset ... && cmake --build --preset ...`**。构建机上只要装 VS Build Tools、设好 `VCPKG_ROOT`，就能得到与本地一致的结果，不需要任何人肉步骤。

---

## 小结

- **CMake 在 VS 2026 里是一等公民**：无需扩展，**文件 > 打开 > 文件夹** 即可获得目标视图、调试、IntelliSense 与测试支持；跨平台或多人协作优先选它，`.vcxproj` 留给纯 Windows 场景。
- 解决方案资源管理器可在**文件夹视图**（编辑）与 **CMake 目标视图**（构建、调试、选启动项）之间切换。
- **`CMakePresets.json` 是推荐的配置方式**：标准格式、支持 `inherits`、命令行与 CI 都能复用；存在时 VS 以它为准并忽略旧的 `CMakeSettings.json`，图形化的 **CMake 设置编辑器**只适合临时改缓存变量。
- VS 2026 **自带 CMake 4.1.1**，生成器是 **`Visual Studio 18 2026`**；用 **`-T "version=14.5x"`**（或缓存变量 `CMAKE_GENERATOR_TOOLSET`）选工具集版本，vcpkg 侧对应 `VCPKG_PLATFORM_TOOLSET_VERSION`。注意 CMake 4.x 不再兼容 `cmake_minimum_required(VERSION < 3.5)`。
- 在 CMakeLists.txt 里设断点 + **项目 > 使用 CMake 调试配置缓存** 可以调试 CMake 脚本本身，是排查 `find_package` 失败的利器；CMake 模块（`include(...)`）还有补全与快速信息。
- **多配置生成器（Visual Studio）用 `--config` 选配置，`CMAKE_BUILD_TYPE` 会被静默忽略**；单配置生成器（Ninja）则必须在 configure 时用 `CMAKE_BUILD_TYPE` 定死。
- **vcpkg 清单模式优于经典模式**：依赖装进项目的 `vcpkg_installed/`，版本由 `builtin-baseline` 锁定，`vcpkg-configuration.json` 可接私有 git 注册表；VS 检测到 `vcpkg.json` 会自动激活环境，无需手写工具链文件。
- **WSL、Dev Containers（Docker 与 Podman）、远程 Linux（SSH）** 三条路线都能在 Windows 上开发 Linux 目标；工作负荷已改名为 **"使用 C++ 的 Linux、Mac 和嵌入式开发"**，且附加到进程已支持 Podman 容器、可调试 C++ 容器进程。

---

## 练习题

1. 用 **文件 > 打开 > 文件夹** 打开一个含 `CMakeLists.txt` 的目录，在**文件夹视图**与 **CMake 目标视图**间来回切换，记录两边"多出来"和"少掉"的条目并解释原因。
2. 手写一份含 `inherits` 的 `CMakePresets.json`：一个 `hidden` 基类预设加两个继承它的子预设，确认 VS 的配置下拉里只出现两个子预设。
3. 用 `Ninja` 与 `Visual Studio 18 2026` 把同一项目配到两个构建目录并各构建一次；在单配置那份里改 `CMAKE_BUILD_TYPE` 观察生效，在多配置那份里做同样的事并观察**不生效**。
4. 在 `CMakeLists.txt` 的 `find_package` 处设断点，用 **项目 > 使用 CMake 调试配置缓存** 启动，查看包目录变量在断点处的实际值，并说明它由谁设置。
5. 给项目加上 `vcpkg.json` 引入一个依赖，把 `builtin-baseline` 改成你本机 vcpkg 的真实提交号；记录首次配置耗时，删掉 `vcpkg_installed/` 再配一次，比较两次差异。
6. 用 `-T "version=14.50"` 与不指定 `-T` 各配置一次，在 `CMakeCache.txt` 或诊断输出里确认实际使用的工具集版本，写出结论。
7. 给含单元测试的项目补上 `testPresets`，并给 Linux 侧加一个 Ninja 预设；在 Windows 与 Linux（WSL 或 SSH 均可）各跑一次测试，确认同一份 Presets 两边都能工作。

---

## 相关笔记

- **本教程**：[[README|Visual Studio 2026 使用教程]]
- **上一章**：[[09-性能分析与诊断|性能分析与诊断]]
- **下一章**：[[11-单元测试与代码质量|单元测试与代码质量]]
- **CMake 使用指南**：[[../CMake使用指南/CMake使用指南|CMake 使用指南]]
- **VS Code 中 CMake**：[[../CMake使用指南/VS code中Cmake使用指南|VS Code 中 CMake 使用指南]]
