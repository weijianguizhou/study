# 46-Simulink进阶技巧

---

# 一、模型引用与库

- **Model Reference**：把一个大模型拆成子模型，各自独立编译。改一个子模型不需要重编整个系统。
- **Library**：可复用的模块仓库。拖出来用，改库里的源模块，所有实例同步更新。

---

# 二、回调函数 (Callbacks)

在模型属性里可以设置：
```matlab
% InitFcn —— 模型加载时执行
% StopFcn —— 仿真停止时执行
% 比如自动加载参数、保存结果到MAT文件
```

---

# 三、S-Function（自定义模块）

当MATLAB Function块太慢时，用C/C++/Fortran写S-Function直接编译进Simulink。

```matlab
mex my_sfunction.c       % 编译C的S-Function
```

---

# 四、加速仿真

1. **`Simulink.Accelerator`**：JIT编译，不用改动模型
2. **`Simulink.RapidAccelerator`**：编译成独立可执行文件
3. **定步长代替变步长**：如果精度允许，定步长快得多
4. **用`Signal Specification`块避免代数环**
5. **`Data Store Memory`代替`Goto/From`**：减少连线混乱

---

# 五、代码生成 (Embedded Coder)

Simulink模型可以直接生成C/C++代码部署到嵌入式设备：

```matlab
slbuild('my_model');
```

生成的代码有：`my_model.c`、`my_model.h`，能直接烧进单片机跑。

---

## 下一步

- [[47-参数优化与自动调参|参数优化与自动调参]]
