# 49-MATLAB与C++混合编程

MATLAB开发快但跑得慢。C++跑得快但开发慢。**混合编程**让关键计算用C++跑，其余用MATLAB写。

---

# 一、MEX文件

MEX是MATLAB调用C/C++的桥梁。把`.c`/`.cpp`编译成`.mexw64`（Windows），MATLAB可以像普通函数一样调它。

```cpp
// my_add.cpp
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    double a = mxGetScalar(prhs[0]);
    double b = mxGetScalar(prhs[1]);
    plhs[0] = mxCreateDoubleScalar(a + b);
}
```

```matlab
mex my_add.cpp          % 编译
result = my_add(3, 5);  % 直接用
```

---

# 二、MATLAB Coder

把MATLAB函数自动转成C/C++——不需要手写MEX。

```matlab
codegen my_function -args {zeros(3,1), 0.01}
% 生成 my_function_mex.mexw64
```

要求函数里所有变量类型确定、不用动态内存。对纯数值计算非常好用。

---

# 三、从C++调用MATLAB（Engine API）

反过来，C++程序可以启动MATLAB引擎在里面执行MATLAB命令：

```cpp
#include "engine.h"
Engine *ep = engOpen(NULL);
engEvalString(ep, "x = 0:0.1:2*pi; y = sin(x); plot(x,y);");
```

---

# 四、什么时候混合

| 场景 | 方案 |
|------|------|
| 某个循环太慢了 | 用MATLAB Coder把那部分转MEX |
| 已有C++库想用 | 写MEX包装 |
| 想把MATLAB代码部署 | MATLAB Compiler打成exe/dll |
| 想把算法跑在嵌入式上 | MATLAB Coder → C → 交叉编译 |

---

## 下一步

- [[50-系统工程与总结|系统工程与总结]]
