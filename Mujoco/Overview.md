# Introduction 简介
**MuJoCo** 代表 **Mu**lti-**Jo**int dynamics with **Co**ntact。它是一款通用物理引擎，旨在促进机器人学、生物力学、图形与动画、机器学习以及其他需要快速且精确模拟关节结构与环境交互的领域的研发。最初由 Roboti LLC 开发，2021 年 10 月被 DeepMind 收购并[免费提供](https://github.com/google-deepmind/mujoco/blob/main/LICENSE) ，并于 2022 年 5 月开源。MuJoCo 代码库可在 GitHub 上的 [google-deepmind/mujoco](https://github.com/google-deepmind/mujoco) 仓库中获取。因为我们并不是仿真引擎的开发者，所以我们对于源码并不关心，予以忽略。

MuJoCo 是一个带有 C API 的 C/C++ 库，面向研究人员和开发者。运行时仿真模块经过优化以最大化性能，并运行于由内置 XML 解析器和编译器预先分配的低级数据结构上。用户用原生的 MJCF 场景描述语言定义模型——这是一种旨在尽可能让人类可读和编辑的 XML 文件格式。也可以加载 URDF 模型文件。该库包含带有原生图形界面的交互式可视化，并以 OpenGL 渲染。MuJoCo 进一步揭示了大量用于计算物理相关量的效用函数。

MuJoCo 可用于实现基于模型的计算，如控制综合、状态估计、系统识别、机制设计、通过逆动力学进行数据分析以及机器学习应用中的并行采样。它也可以作为更传统的模拟器使用，包括游戏和互动虚拟环境。

# Key features 主要特征
MuJoCo 拥有丰富的功能列表。这里我们概述了最著名的几项。

## Generalized coordinates combined with modern contact dynamics广义坐标系与现代接触动力学的结合
物理理引擎传统上分为两类。机器人和生物力学引擎在广义坐标或联合坐标系中使用高效且准确的递归算法。但它们要么省略接触动力学，要么依赖早期的弹簧阻尼方法，后者需要非常小的时间步长。游戏引擎采用更现代的方法，通过求解优化问题来求接触力。然而，它们常常采用过度指定的笛卡尔表示法，即在数值上施加联合约束，导致在涉及复杂运动学结构时产生不准确性和不稳定性。MuJoCo 是首个将广义坐标模拟与基于优化的接触动力学两者结合的通用引擎。其他模拟器最近也被改编为采用 MuJoCo 的方法，但由于它们从一开始就并非为此设计，通常并不兼容所有功能。

## Soft, convex and analytically-invertible contact dynamics软接触、凸接触和解析可逆接触动力学
在现代接触动力学方法中，摩擦接触引起的力或冲量通常被定义为$\color{red}\text{线性或非线性互补问题（LCP 或 NCP）}$的解，这两种问题都是 NP-hard（**Non-deterministic Polynomial-time hard**（多项式复杂程度非确定性问题））的。MuJoCo 基于另一种接触物理的表述，该表述简化为凸优化问题，详见[计算章节](https://mujoco.readthedocs.io/en/stable/computation/index.html) 。我们的模型允许软接触及其他约束，并具有唯一定义的逆函数，便于数据分析和控制应用。有多种优化算法可供选择，包括对投影高斯-塞德尔方法(Gauss-Seidel method)的推广，可以处理椭圆摩擦锥。求解器统一处理摩擦接触，包括扭转摩擦和滚动摩擦、无摩擦接触、关节和肌腱极限、关节和肌腱中的干摩擦，以及多种等式约束。

## Tendon geometry肌腱几何结构
MuJoCo 可以模拟肌腱的三维几何形状——肌腱是遵循包裹和经点约束的最小路径长度弦。该机制类似于 OpenSim，但实现了更为有限的封闭形式包裹选项，以加快计算速度。它还提供机器人专用结构，如滑轮和耦合自由度。肌腱既可用于驱动，也可用于对腱长度施加不等式或等式约束。

## General actuation model普适驱动模型
在使用模型无关的 API 的情况下设计足够丰富的驱动模型是一项挑战。MuJoCo 通过采用抽象驱动模型实现这一目标，该模型可以具有不同类型的传递、力产生和内部动力学（即使整体动力学达到三阶的状态变量）。这些组件可以被实例化，统一建模电机、气动和液压缸、PD 控制器、生物肌肉及许多其他执行器。

## Reconfigurable computation pipeline可重构计算流水线
MuJoCo 有一个顶层步进函数 [mj_step](https://mujoco.readthedocs.io/en/stable/APIreference/APIfunctions.html#mj-step)，可以运行整个前向动力学并推进仿真状态。然而，在许多非仿真应用中，能够运行计算流水线的部分是有益的。为此，MuJoCo 提供了大量可任意组合设置的[标志](https://mujoco.readthedocs.io/en/stable/XMLreference.html#option-flag) ，允许用户根据需要重新配置流水线，而不仅仅是通过[选项](https://mujoco.readthedocs.io/en/stable/XMLreference.html#option)选择算法和算法参数。此外，许多底层函数也可以直接调用。用户自定义回调可以实现自定义力场、执行器、碰撞程序和反馈控制器。

## Model compilation模型编译
如上所述，用户用一种称为 MJCF 的 XML 文件格式定义 MuJoCo 模型。该模型随后由内置编译器编译为低级数据结构 [mjModel](https://mujoco.readthedocs.io/en/stable/APIreference/APItypes.html#mjmodel)，该结构经过交叉索引并优化以适应运行时计算。编译后的模型也可以保存在二进制 MJB 文件中。

## Separation of model and data模型与数据的分离
MuJoCo 在运行时将仿真参数分为两个数据结构（C 结构体）：

- [mjModel](https://mujoco.readthedocs.io/en/stable/APIreference/APItypes.html#mjmodel) 包含模型描述，并期望保持不变。它还嵌入了其他结构，包含仿真和可视化选项，这些选项需要偶尔更改，但这由用户自行完成。
- 
-  [mjData](https://mujoco.readthedocs.io/en/stable/APIreference/APItypes.html#mjdata) 包含所有动态变量和中间结果。它被用作临时记录，所有函数读取输入并写入输出——这些输出随后成为模拟流水线后续阶段的输入。它还包含一个预分配且内部管理的栈，因此运行时模块在模型初始化后无需调用内存分配函数。
[mjModel](https://mujoco.readthedocs.io/en/stable/APIreference/APItypes.html#mjmodel) 由编译器构建。[mjData](https://mujoco.readthedocs.io/en/stable/APIreference/APItypes.html#mjdata) 是在运行时构造的，给定 [mjModel](https://mujoco.readthedocs.io/en/stable/APIreference/APItypes.html#mjmodel)。这种分离使得模拟多个模型以及每个模型的多个状态和控制变得容易，从而促进了[多线程](https://mujoco.readthedocs.io/en/stable/programming/simulation.html#simultithread)采样和[有限差](https://mujoco.readthedocs.io/en/stable/APIreference/APIfunctions.html#mjd-transitionfd)分的实现。顶层 API 函数反映了这一基本分离，格式如下：
`void mj_step(const mjModel* m, mjData* d);`

## Interactive simulation and visualization交互式仿真与可视化
原生 [3D 可视化工具](https://mujoco.readthedocs.io/en/stable/programming/visualization.html#visualization)提供网格和几何原图元、纹理的渲染， 反射、阴影、雾、透明、线框、天空盒、立体可视化（在支持 Video Card 的视频卡上） 四缓冲 OpenGL）。该功能用于生成 3D 渲染，帮助用户深入了解 物理仿真，包括自动生成的模型骨架、等效惯性盒等视觉辅助， 接触位置和法线，可分为法向和切向分量的接触力，外部 扰动力、局部框架、关节轴和执行轴，以及文本标签。可视化工具期望一个通用窗口 并配有 OpenGL 渲染上下文，从而允许用户采用自己选择的图形界面库。代码示例 [simulate.cc](https://mujoco.readthedocs.io/en/stable/programming/samples.html#sasimulate) MuJoCo 分发的 GLFW 库展示了如何实现这一点。一个相关的可用性功能是能够“进入”模拟，推动物体并观察物理反应。用户选择外部力和力矩将施加的物体，实时看到扰动及其动态后果的渲染。这可以用来视觉调试模型，测试反馈控制器的响应，或将模型配置成理想的姿态。

## Powerful yet intuitive modeling language强大而直观的建模语言
MuJoCo 拥有自己的建模语言，称为 MJCF。MJCF 的目标是提供 MuJoCo 所有计算能力的访问，同时让用户能够快速开发新模型并进行实验。这一目标在很大程度上得益于其广泛的[默认设置](https://mujoco.readthedocs.io/en/stable/modeling.html#cdefault)机制，类似于用 HTML 内嵌的级联样式表（CSS）。虽然 MJCF 包含许多元素和属性，但用户在任何模型中需要设置的元素和属性出乎意料地少。这使得 MJCF 文件比许多其他格式更短更易读。

## Automated generation of composite flexible objects合成柔性对象的自动生成
MuJoCo 的软约束可用于建模绳索、布料和可变形的三维物体。这需要大量规则的身体、关节、肌腱和约束体协同工作。建模语言具有高级宏，模型编译器会自动展开为所需的标准模型元素集合。重要的是，这些产生的柔性对象能够与模拟的其他部分完全交互。

# Model instances  模型实例
MuJoCo 中有几个被称为“模型”的实体。用户在用 MJCF 或 URDF 编写的 XML 文件中定义模型。软件随后可以在不同介质（文件或内存）和不同描述层级（高或低）创建同一模型的多个实例。所有组合均可实现，如下表所示：

|        | High level     | Low level   |
| ------ | -------------- | ----------- |
| File   | MJCF/URDF(XML) | MJB(binary) |
| Memory | mjSpec         | mjModel     |
所有运行时计算均使用 [mjModel](https://mujoco.readthedocs.io/en/stable/APIreference/APItypes.html#mjmodel)，该程序过于复杂，无法手动创建。这就是为什么我们有两个建模层次。高层模型存在是为了用户方便：其唯一目的是被编译成一个低层模型，以便进行计算。生成的 [mjModel](https://mujoco.readthedocs.io/en/stable/APIreference/APItypes.html#mjmodel) 可以加载并保存到二进制文件（MJB），但这些二进制文件是版本特定的，无法反编译，因此模型应始终以 XML 文件形式维护。

[mjSpec](https://mujoco.readthedocs.io/en/stable/APIreference/APItypes.html#mjspec) C 结构体与 MJCF 文件格式一一对应。XML 加载器解释 MJCF 或 URDF 文件，生成对应的 [mjSpec](https://mujoco.readthedocs.io/en/stable/APIreference/APItypes.html#mjspec)，并将其编译为 [mjModel](https://mujoco.readthedocs.io/en/stable/APIreference/APItypes.html#mjmodel)。用户可以创建 然后保存到 MJCF 或编译。过程式模型的创建和编辑在[模型编辑](https://mujoco.readthedocs.io/en/stable/programming/modeledit.html)章节中有详细介绍。

下图展示了获得 [mj Model](https://mujoco.readthedocs.io/en/stable/APIreference/APItypes.html#mjmodel)的不同路径：
- (text editor) → MJCF/URDF file → (MuJoCo parser → mjSpec → compiler) → mjModel  

- (user code) → mjSpec → (MuJoCo compiler) → mjModel  

- MJB file → (model loader) → mjModel  

# Examples 示例
这里有一个 MuJoCo 的 MJCF 格式模型。它定义了一个固定在世界的平面，一个用来更好地照亮物体和投射阴影的灯光，以及一个带有 6 个自由度的漂浮盒子（这就是“自由”关节的作用）。
```
<mujoco>
  <worldbody>
    <light diffuse=".5 .5 .5" pos="0 0 3" dir="0 0 -1"/>
    <geom type="plane" size="1 1 0.1" rgba=".9 0 0 1"/>
    <body pos="0 0 1">
      <joint type="free"/>
      <geom type="box" size=".1 .2 .3" rgba="0 .9 0 1"/>
    </body>
  </worldbody>
</mujoco>
```
内置的 OpenGL 可视化工具将该模型渲染为：![[hello.webp|500]]

别说，还怪好看的嘞。


如果模拟这个模型，盒子会掉落到地上。下面给出了无源动力学（不含渲染）的基本仿真代码。
```
#include "mujoco.h"
#include "stdio.h"

char error[1000];
mjModel* m;
mjData* d;

int main(void) {
  // load model from file and check for errors
  m = mj_loadXML("hello.xml", NULL, error, 1000);
  if (!m) {
    printf("%s\n", error);
    return 1;
  }

  // make data corresponding to model
  d = mj_makeData(m);

  // run simulation for 10 seconds
  while (d->time < 10)
    mj_step(m, d);

  // free model and data
  mj_deleteData(d);
  mj_deleteModel(m);

  return 0;
}
```

这技术上是 C 文件，但它也是合法的 C++文件。事实上，MuJoCo API 兼容 C 和 C++。通常用户代码会用 C++编写，因为这增加了便利性，且不会牺牲效率，因为计算瓶颈存在于已经高度优化的模拟器中。

函数 [mj_step](https://mujoco.readthedocs.io/en/stable/APIreference/APIfunctions.html#mj-step) 是顶层函数，将仿真状态推进一个时间步。这个例子当然只是被动动力系统。当用户指定控制或施加力并开始与系统互动时，事情会变得更有趣。

接下来，我们提供一个更详细的例子，说明 MJCF 的若干特征。请考虑以下内容 [example.xml](https://mujoco.readthedocs.io/en/stable/_static/example.xml)：
```
<mujoco model="example">
  <default>
    <geom rgba=".8 .6 .4 1"/>
  </default>

  <asset>
    <texture type="skybox" builtin="gradient" rgb1="1 1 1" rgb2=".6 .8 1" width="256" height="256"/>
  </asset>

  <worldbody>
    <light pos="0 1 1" dir="0 -1 -1" diffuse="1 1 1"/>
    <body pos="0 0 1">
      <joint type="ball"/>
      <geom type="capsule" size="0.06" fromto="0 0 0  0 0 -.4"/>
      <body pos="0 0 -0.4">
        <joint axis="0 1 0"/>
        <joint axis="1 0 0"/>
        <geom type="capsule" size="0.04" fromto="0 0 0  .3 0 0"/>
        <body pos=".3 0 0">
          <joint axis="0 1 0"/>
          <joint axis="0 0 1"/>
          <geom pos=".1 0 0" size="0.1 0.08 0.02" type="ellipsoid"/>
          <site name="end1" pos="0.2 0 0" size="0.01"/>
        </body>
      </body>
    </body>

    <body pos="0.3 0 0.1">
      <joint type="free"/>
      <geom size="0.07 0.1" type="cylinder"/>
      <site name="end2" pos="0 0 0.1" size="0.01"/>
    </body>
  </worldbody>

  <tendon>
    <spatial limited="true" range="0 0.6" width="0.005">
      <site site="end1"/>
      <site site="end2"/>
    </spatial>
  </tendon>
</mujoco>
```
该型号是一个7自由度臂，“握住”一根绳子，另一端连接一个圆柱体。该字符串为 以长度限制的腱形式实现。肩部有球形关节，肘部有成对铰链关节 还有手腕。圆柱体内的盒子表示一个自由的“接头”。XML 中的外体元素是所需的 世界体 。注意，在两个实体之间使用多个关节并不意味着创建虚拟实体。

MJCF 文件包含指定模型所需的最小信息。胶囊由空间中的线段定义——此时只需胶囊的半径。车架的位置和方向是根据其所属的几何推断出来的。惯性性质是在均匀密度假设下从几何形状推断出来的。这两个部位之所以被命名，是因为腱的定义需要引用它们，但除此之外没有其他部位的名称。接头轴仅定义于铰链接头，而不定义球接头。碰撞规则是自动定义的。摩擦属性、重力、仿真时间步等都设置为默认值。顶部指定的默认几何颜色适用于所有几何。

除了将编译后的模型保存为二进制 MJB 格式外，我们还可以将其保存为 MJCF 格式或人类可读的文本格式；参见 [example_saved.xml](https://mujoco.readthedocs.io/en/stable/_static/example_saved.xml) 和 [example_saved.txt](https://mujoco.readthedocs.io/en/stable/_static/example_saved.txt) 分别对应。XML 版本与原始版本类似，而文本版本则包含所有信息。 `mjModel` 。将文本版本与 XML 版本进行比较，可以发现模型编译器为我们做了多少工作。

编译器辛苦了

# Model elements  模型元素
本节简要描述了 MuJoCo 模型中可以包含的所有要素。稍后我们将详细解释。 更详细地介绍底层计算、MJCF 中元素的指定方式及其表示方法。 `mjModel` 。

## Options
每个模型都包含以下三组选项，这些选项始终包含在模型中。如果 XML 文件中未指定这些选项的值，则使用默认值。这些选项的设计允许用户在每个仿真时间步之前更改其值。但是，在同一时间步内，任何选项都不应更改。
### mjOption
该结构包含所有影响物理模拟的选项。它用于选择算法并设置其参数，启用和禁用模拟流程的不同部分，以及调整系统级物理属性，例如重力。

### mjVisual
此结构包含所有可视化选项。还有其他 OpenGL 渲染选项，但这些选项与会话相关，不属于此模型的一部分。

### mjStatistic
该结构包含有关模型的统计信息，这些信息由编译器计算得出：平均体重、模型的空间范围等。包含此结构是为了提供信息，也是因为可视化工具使用它来进行自动缩放。


## Assets 资源
Assets本身并非模型元素。模型元素可以引用Assets，在这种情况下，Assets会以某种方式改变引用元素的属性。一个Assets可以被多个模型元素引用。由于包含Assets的唯一目的就是引用它，而引用只能通过名称进行，因此每个Assets都有一个名称（在适用情况下，可以从文件名推断出来）。相比之下，常规元素的名称可以留空。
### Mesh  网
MuJoCo 可以从 OBJ 文件和二进制 STL 文件加载三角网格。可以使用 [MeshLab](https://www.meshlab.net/) 等软件将其他格式转换为三角网格。虽然任何三角形集合都可以加载并可视化为网格，但碰撞检测器仅针对凸包进行工作。编译时提供了缩放网格以及将原始几何形状拟合到网格的选项。网格还可以用于自动推断惯性属性——将其视为三角锥的并集，并结合它们的质量和惯性。请注意，网格本身没有颜色，而是使用参考几何体的材质属性来着色。相反，所有空间属性均由网格数据决定。MuJoCo 支持 OBJ 和自定义二进制文件格式（用于法线和纹理坐标）。网格也可以直接嵌入到 XML 中。

### Skin  蒙皮
蒙皮网格（或称蒙皮）是指其形状可在运行时变形的网格。它们的顶点连接到刚体（此处称为骨骼），每个顶点可以属于多个骨骼，从而实现蒙皮的平滑变形。蒙皮纯粹是可视化对象，不影响物理效果，但仍然可以显著增强视觉真实感。蒙皮可以从自定义二进制文件加载，也可以像网格一样直接嵌入到 XML 中。在自动生成复合柔性对象时，模型编译器也会为这些对象生成蒙皮。

### Height field  高度场
高度场可以从 PNG 文件（内部转换为灰度图像）或稍后描述的自定义二进制格式文件中加载。高度场是一个矩形网格的高程数据。编译器会将数据归一化到 $[0-1]$ 范围内。高度场的实际空间范围由引用几何体的尺寸参数决定。高度场只能被附加到世界对象的几何体引用。为了渲染和碰撞检测，网格矩形会自动进行三角剖分，因此高度场被视为三角棱柱的并集。原则上，对这种复合对象进行碰撞检测可能会为单个几何体对生成大量接触点。如果发生这种情况，则仅保留前 64 个接触点。这样做的理由是，高度场应该用于模拟地形图，其空间特征相对于模拟中的其他对象而言较大，因此对于设计良好的模型，接触点的数量会很少。

### Texture  质地
纹理可以从 PNG 文件加载，也可以由编译器根据用户定义的程序参数合成。此外，还可以选择在创建模型时将纹理留空，并在运行时进行更改——例如，在 MuJoCo 模拟中渲染视频或创建其他动态效果。可视化工具支持两种纹理映射类型：2D 和立方体。2D 映射适用于平面和高度场。立方体映射适用于将纹理“包裹”在 3D 对象周围，而无需指定纹理坐标。它还可用于创建天空盒。立方体的六个面可以从单独的图像文件加载，也可以从单个合成图像文件加载，或者通过重复同一图像生成。与其他所有直接从模型元素引用的资源不同，纹理只能从另一个资源（即材质）引用，然后该材质再被模型元素引用。

### Material  材质
材质用于控制几何体、地点和肌腱的外观。这是通过引用相应模型元素的材质来实现的。外观包括纹理映射以及其他与 OpenGL 灯光交互的属性，例如：RGBA、镜面反射、光泽度和自发光。材质还可以用于使物体具有反射效果。目前，反射仅渲染在平面和立方体的 Z+ 面上。请注意，模型元素还可以拥有用于设置颜色的局部 RGBA 参数。如果同时指定了材质和局部 RGBA，则局部定义优先。

# Kinematic tree  运动学树
MuJoCo 模拟一组刚体的动力学，这些刚体的运动通常受到约束。系统状态以关节坐标表示，刚体被显式地组织成运动学树。树结构由 `mjModel.body_parentid` 给出，这是一个长度为 `nbody >= 1` 的整数数组。顶层“世界”刚体始终存在（id 为 `0` ），并且是其自身的父刚体，因此 `body_parentid[0] == 0` ，并且对于所有其他 `i` `body_parentid[i] < i` 。请注意，世界刚体和其他静态（无关节）子刚体构成一个独特的“静态树”，该树没有关联的自由度。在此顶层静态树之下，可以附加多个运动学树，请参见下面的 [“树”部分](https://mujoco.readthedocs.io/en/stable/overview.html#elemtree) 。

运动学回路是不允许的；如果需要环形关节，则应使用等式约束进行建模。因此，MuJoCo 模型的核心是由嵌套的实体定义构成的一个或多个运动学树；一个孤立的浮动实体也算作一棵树。下面列出的其他几个元素定义在实体内部，并属于该实体。这与后面列出的独立元素形成对比，独立元素不能与单个实体关联。

## Body  物体
物体具有质量和惯性属性，但不具有任何几何属性。取而代之的是，几何形状（或几何体）被附加到物体上。每个物体都有两个坐标系：一个用于定义物体本身以及确定其他元素相对于物体的位置的坐标系，以及一个以物体质心为中心并与其主轴方向一致的惯性坐标系。因此，物体在该惯性坐标系中是呈对角线的。在每个时间步，MuJoCo 递归地计算正向运动学，从而得到所有物体在全局笛卡尔坐标系中的位置和姿态。这为所有后续计算提供了基础。物体的数量由 `mjModel.nbody` 给出。

## Joint 关节
关节定义在物体内部。它们在物体与其父物体之间创建运动自由度 (DOF)。如果没有关节，物体将与其父物体“焊接”在一起。这与使用过完备笛卡尔坐标的游戏引擎相反，在游戏引擎中，关节会移除自由度而不是增加自由度。关节有四种类型：球形关节、滑动关节、铰链关节和“自由关节”（用于创建浮动物体）。单个物体可以有多个关节。这样，复合关节就可以自动创建，而无需定义虚拟物体。球形关节和自由关节的方向分量用单位四元数表示，MuJoCo 中的所有计算都遵循四元数的属性。关节的数量由 `mjModel.njnt` 给出。

### Joint reference  关节参考姿态
参考姿态是一个存储在 `mjModel.qpos0` 中的关节位置向量。它对应于模型处于初始状态时各关节的数值。在我们之前的示例中，肘关节被创建为 90° 弯曲状态。但是 MuJoCo 无法识别肘关节，因此默认情况下，它将此关节状态的数值视为 0。我们可以使用[关节](https://mujoco.readthedocs.io/en/stable/XMLreference.html#body-joint)的 ref 属性来覆盖默认行为，并指定初始状态对应于 90°。所有关节的参考值都会被组合成向量 `mjModel.qpos0` 。每当仿真重置时，关节状态都会发生变化。 `mjData.qpos` 被设置为 `mjModel.qpos0` 。运行时，关节位置向量是相对于参考姿态进行解释的。具体来说，关节应用的空间变换量为 `mjData.qpos - mjModel.qpos0` 。此变换是在存储在 `mjModel` 主体元素中的父子平移和旋转偏移量之外的额外变换。ref 属性仅适用于标量关节（滑动​​关节和铰链关节）。对于球形关节，保存在 `mjModel.qpos0` 中的四元数始终为 (1,0,0,0)，这对应于零旋转。对于自由关节，浮动体的全局 3D 位置和四元数保存在 `mjModel.qpos0` 中。

### Spring reference 弹簧参考姿态
这是所有关节和肌腱弹簧达到其静止长度时的姿态。当关节构型偏离弹簧参考姿态时，会产生弹簧力，且弹簧力与偏离量呈线性关系。弹簧参考姿态保存在 `mjModel.qpos_spring` 中。对于滑动关节和铰链关节，弹簧参考姿态由属性 springref 指定。对于球形关节和自由关节，弹簧参考姿态对应于模型的初始构型。

## DOF  自由度
自由度与关节密切相关，但并非一一对应，因为球形关节和自由关节都具有多个自由度。可以将关节理解为指定位置信息，而将自由度理解为指定速度和力信息。更正式地说，关节位置是系统构型流形上的坐标，而关节速度是当前位置处该流形切空间上的坐标。自由度具有与速度相关的属性，例如摩擦损失、阻尼和电枢惯性。作用于系统的所有广义力都用自由度空间表示。相比之下，关节具有与位置相关的属性，例如极限和弹簧刚度。自由度并非由用户直接指定，而是由编译器根据关节信息自动生成。自由度的数量由 `mjModel.nv` 指定。

## Tree  树
[如上所述](https://mujoco.readthedocs.io/en/stable/overview.html#kinematic) ，运动的物体被组织成运动树。运动树或“树”是 _一个可移动的物体及其所有后代_ 。因此，世界和其他静态物体都位于全局树结构中，但并不与任何_树_关联。由于全局树结构采用深度优先组织方式，因此属于同一棵树的所有物体、关节和自由度始终是顺序的。请注意，与物体（如果是静态的）不与任何树关联不同，关节和自由度始终与一棵树关联。 [island discovery](https://mujoco.readthedocs.io/en/stable/computation/index.html#soisland)和[island sleeping](https://mujoco.readthedocs.io/en/stable/computation/index.html#sleeping)在树的基础上进行运作

树的数量由 `mjModel.ntree` 给出。例如，一个包含三个自由体和一个[标准人形体的](https://github.com/google-deepmind/mujoco/blob/main/model/humanoid/humanoid.xml)模型，其 `ntree = 4` 需要注意的是，虽然这些树确实是全局树（其根节点为世界）的子树，但这不应与专门用于指代每个自由体部分树的术语 `subtree` 混淆。因此， `mjModel.body_subtreemass` 给出的是每个自由体下部分树的总质量，适用于所有自由体。


## Geom  几何
几何体是刚性连接到物体上的三维形状。多个几何体可以连接到同一个物体上。鉴于 MuJoCo 仅支持凸几何体之间的碰撞，而创建非凸物体的唯一方法是将其表示为凸几何体的并集，因此几何体的功能尤为重要。除了碰撞检测和后续的接触力计算之外，几何体还用于渲染，以及在省略物体质量和惯性时自动推断物体的质量和惯性。MuJoCo 支持几种基本几何形状：平面、球体、胶囊体、椭球体、圆柱体和长方体。几何体也可以是网格或高度场；这可以通过引用相应的资源来实现。几何体具有许多材质属性，这些属性会影响模拟和可视化效果。几何体的数量由 `mjModel.ngeom` 指定。

## Site  站点
站点本质上是轻量级几何体，代表本体坐标系内感兴趣的位置。站点不参与碰撞检测或惯性属性的自动计算，但可用于指定其他对象（例如传感器、肌腱路径和滑块曲柄端点）的空间属性。站点数量由 `mjModel.nsite` 给出。

## Camera  摄像机
模型中可以定义多个摄像机。始终会有一个默认摄像机，用户可以在交互式可视化工具中使用鼠标自由移动它。然而，通常情况下，定义额外的摄像机会更方便，这些摄像机可以固定在场景中，也可以附着在某个物体上并随其移动。除了摄像机的位置和方向之外，用户还可以调整垂直视场角和瞳距以进行立体渲染，以及创建立体虚拟环境所需的倾斜投影。在对具有不完美光学元件的真实摄像机进行建模时，可以分别指定水平和垂直方向的焦距以及非中心主点。摄像机的数量由 `mjModel.ncam` 指定。

## Light  光
灯光可以固定在世界物体上，也可以附加到移动物体上。可视化工具提供对 OpenGL 中完整光照模型（固定功能）的访问，包括环境光、漫反射光和镜面反射光分量、衰减和截止、位置光照和方向光照以及雾效。灯光（或者更确切地说，是被灯光照亮的物体）也可以投射阴影。但是，与材质反射类似，每个投射阴影的灯光都会增加一次渲染，因此应谨慎使用此功能。

# Stand-alone
在这里，我们描述不属于单个物体的模型元素，因此在运动学树之外进行描述。

## Tendon  肌腱
肌腱是标量长度单元，可用于驱动、施加限制和等式约束，或创建弹簧阻尼器和摩擦损失。肌腱分为两种类型：固定腱索和空间腱索。固定肌腱是（标量）关节位置的线性组合，适用于模拟机械耦合。空间肌腱定义为穿过一系列指定点（或过路点）或环绕指定几何体的最短路径。仅支持球体和圆柱体作为环绕几何体，且圆柱体在环绕时被视为无限长。为避免肌腱从环绕几何体的一侧突然跳到另一侧，用户还可以指定首选侧。如果肌腱路径中存在多个环绕几何体，则必须通过点来分隔它们，以避免使用迭代求解器。空间肌腱还可以使用滑轮分成多个分支。

## Actuator  执行器
MuJoCo 提供了一种灵活的执行器模型，包含三个可独立指定的组件。这三个组件共同决定了执行器的工作原理。通过协调地指定这些组件，可以获得常见的执行器类型。这三个组件分别是传动、激活动力学和力生成。传动组件指定了执行器如何连接到系统的其余部分；可用的类型包括关节、肌腱和滑块曲柄。激活动力学可用于模拟气动或液压缸以及生物肌肉的内部激活状态；使用此类执行器可将整个系统的动力学特性提升至三阶。力生成机制决定了如何将作为执行器输入的标量控制信号映射到标量力，该标量力又如何通过从传动组件推断出的力臂映射到广义力。

## Sensor  传感器
MuJoCo 可以生成模拟传感器数据，并将其保存在全局数组 `mjData.sensordata` 中。该结果不会用于任何内部计算；提供该结果是因为用户可能需要它进行自定义计算或数据分析。可用的传感器类型包括触摸传感器、惯性测量单元 (IMU)、力矩传感器、关节和肌腱位置及速度传感器、执行器位置、速度和力传感器、运动捕捉标记位置和四元数以及磁力计。其中一些需要额外的计算，而另一些则直接从 `mjData` 的相应字段复制。此外，还有一个用户传感器，允许用户代码在传感器数据数组中插入任何其他感兴趣的量。MuJoCo 还具有离屏渲染功能，可以轻松模拟彩色和深度相机传感器。

## Equality  等式
等式约束可以在运动学树结构及其定义的关节/自由度之外施加额外的约束。它们可用于创建环形关节，或用于模拟机械耦合。用于强制执行这些约束的内力与其他所有约束力一起计算。可用的等式约束类型包括：将两个物体连接于一点（在运动学树外部创建球形关节）；将两个物体焊接在一起；固定关节或肌腱的位置；通过三次多项式耦合两个关节或两条肌腱的位置；将柔性体（即可变形网格）的边约束到其初始长度。

## Flex 柔性体
柔性体代表可变形网格，可以是 1 维、2 维或 3 维的（因此其元素是胶囊体、三角形或四面体）。与刚性连接到单个实体的静态几何体不同，柔性体的元素是可变形的：它们通过连接多个实体构建，因此实体的位置和方向决定了柔性体元素在运行时的形状。这些可变形元素支持碰撞和接触力，并生成被动和约束力，从而柔和地保持可变形实体的形状。系统提供自动化功能，可以从文件中加载网格，构建与网格顶点对应的实体，构建与网格面（或线或四面体，取决于维度）对应的柔性体元素，并获得相应的可变形网格。

## Contact pair  接触对
MuJoCo 中的接触生成是一个复杂的过程。用于检查接触的几何体对可以来自两个来源：自动邻近测试和其他统称为“动态”的过滤器，以及模型中提供的显式几何体对列表。后者是一种独立的模型元素类型。由于接触涉及两个几何体的组合，显式指定允许用户以动态机制无法实现的方式定义接触参数。它还有助于微调接触模型，特别是添加被严格过滤方案移除的接触对。接触机制现在已扩展到柔性元素，柔性元素可以创建两个以上物体之间的接触交互。但是，此类碰撞是自动的，无法使用接触对进行微调。

## Contact exclude  
这与接触对相反：它指定应从候选接触对生成中排除的实体对（而非几何体）。这对于禁用几何体之间因几何形状而导致不必要的永久接触的实体之间的接触非常有用。请注意，MuJoCo 还有其他机制来处理这种情况（特别是，如果几何体属于同一实体或父子实体，则它们不会发生碰撞），但有时这些自动机制不足以应对这种情况，需要显式排除。

## Custom numeric  自定义数字
在 MuJoCo 仿真中，有三种方法可以输入自定义数值。首先，可以在 XML 中定义全局数值字段。这些字段包含一个名称和一个实数值数组。其次，可以通过在 XML 元素中设置 `nuser_XXX` 属性，来扩展某些模型元素的定义，使其包含特定于该元素的自定义数组。 第三，还有 `size` `mjData.userdata` ，它不被任何 MuJoCo 计算使用。用户可以 将自定义计算的结果存储在那里；请记住，所有随时间变化的内容都应该存储在那里。 `mjData` 不在 `mjModel` 中。

## Custom text  自定义文本
自定义文本字段可以保存在模型中。它们可用于自定义计算——既可以指定关键字命令，也可以提供其他文本信息。但请勿将它们用于注释；在编译后的模型中保存注释没有任何好处。XML 有其自身的注释机制（MuJoCo 的解析器和编译器会忽略它），这种机制更适合用于注释

## Custom tuple  自定义元组
自定义元组是 MuJoCo 模型元素的列表，其中可能包含其他元组。它们不被仿真器使用，但可用于指定用户代码所需的元素组。例如，可以使用元组来定义用于自定义接触处理的实体对。
## Keyframe  关键帧

关键帧是仿真状态变量的快照。它包含关节位置向量、关节速度向量、执行器激活值（如有）以及仿真时间。模型可以包含一个关键帧库。关键帧可用于将系统状态重置到感兴趣的点。请注意，关键帧并非用于在模型中存储轨迹数据；轨迹数据应使用外部文件存储。
---

## 相关笔记

- [[Modeling 建模|建模]] — MuJoCo 场景建模
- [[代码设计的方法论Methodology|代码设计方法论]] — 控制与可视化
- [[Benchmark 基准|Benchmark]] — 简化模型与强化学习环境
- [[../刚体动力学算法/刚体动力学算法|刚体动力学算法]] — 数学基础
- [[../机器人学/DH参数法/DH参数法|DH 参数法]] — 机器人运动学建模
