# 01-从Hello World开始

C/C++是编译型语言——你得先把代码翻译成机器能直接执行的二进制文件，然后才能跑。这跟Python那种"写完就run"不一样。这篇从最简程序开始，让你知道编译是怎么回事、程序的基本骨架长啥样。

---

# 一、第一个程序

```c
#include <stdio.h>

int main() {
    printf("Hello World\n");
    return 0;
}
```

保存为`hello.c`。然后编译运行：

```bash
# GCC 编译
gcc hello.c -o hello
./hello
```

```cmd
Hello World
```

如果用的是Windows：

```powershell
# MinGW / MSYS2
gcc hello.c -o hello.exe
.\hello.exe
```

## 这一小段代码里藏着什么？

**`#include <stdio.h>`**——"包含头文件"。`stdio`全称是Standard Input/Output（标准输入输出）。`printf`函数就定义在这个头文件里。你不include它，编译器不知道`printf`是什么东西——报错`implicit declaration`。

**`int main()`**——主函数，程序的入口。不管你写了多少个函数，程序启动后第一个执行的永远是`main`。

**`return 0`**——向操作系统汇报"我正常结束了"。`0`表示成功，非零表示出错了。

C语言里每条语句末尾分号`;`是必须的。忘写的话编译器会给你一大坨摸不着头脑的错误——习惯了就好了。

---

# 二、编译过程到底发生了什么

从你写的`.c`文件到最终的可执行文件，中间隔了三步：

```
源代码(.c)  →  预处理  →  编译  →  汇编  →  链接  →  可执行文件(.exe)
```

**预处理**：把`#include`的内容直接粘过来，把`#define`的宏展开。说白了就是文本替换。这一步产出一个纯净的`.i`文件。

**编译**：把C代码翻译成汇编代码（`.s`文件）。这是翻译的硬核部分——编译器要理解你的语法、语法树、做各种优化。

**汇编**：把汇编翻译成机器码（`.o`目标文件）。每条汇编指令对应一条机器码。

**链接**：把多个`.o`文件拼成一个可执行文件。`printf`的代码不在你的`.c`文件里——它在标准库里。链接器把标准库里的`printf`的机器码和你的代码粘在一起。

一条`gcc hello.c -o hello`就自动走完这四步。但你也可以分步看：

```bash
gcc -E hello.c -o hello.i    # 只看预处理结果
gcc -S hello.c -o hello.s    # 只看汇编结果
gcc -c hello.c -o hello.o    # 只编译+汇编，不链接
gcc hello.o -o hello         # 链接多个.o
```

---

# 三、C++的Hello World

```cpp
#include <iostream>

int main() {
    std::cout << "Hello World" << std::endl;
    return 0;
}
```

编译用`g++`代替`gcc`：

```bash
g++ hello.cpp -o hello
./hello
```

`iostream`是C++的输入输出流头文件（C++里`stdio.h`改成了`cstdio`，但一般不直接用C的IO了）。`std::cout`是标准输出流，`<<`是输出运算符——把右边的东西"送进"输出流。`std::endl`是换行。

C++的文件后缀一般是`.cpp`或`.cc`。

---

# 四、注释

```c
// 这是单行注释（C99以后支持）

/*
   这是多行注释
   可以跨很多行
*/
```

注释是用来解释**为什么**这样写，不是解释**写了什么**。`i++; // i加1`这种注释是废话。

---

# 五、用VS Code搭建环境

你不用装庞大的Visual Studio。一个轻量的方案：

1. 装 [MSYS2](https://www.msys2.org)，然后在MSYS2的终端里装GCC：
   ```bash
   pacman -S mingw-w64-ucrt-x86_64-gcc
   ```

2. 把`C:\msys64\ucrt64\bin`加到系统环境变量PATH里。

3. 装VS Code + C/C++扩展插件。

4. 新建`.c`文件，按F5（或点右上角运行按钮），VS Code会自动调GCC编译运行。

验证环境：

```bash
gcc --version
```

---

## 下一步

- [[02-变量与数据类型|变量与数据类型]] — int、float、char、sizeof
