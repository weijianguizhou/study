# Python基础与数据类型

编程语言本质上就干两件事：**存数据**和**处理数据**。这篇先搞定"存数据"——Python里怎么表示数字、文字、真假值，以及它们之间的转换。

---

# 一、变量——给数据贴个标签

在Python里，你不需要提前声明"这个变量是整数"——Python自己会猜。你把一个值赋给它，它就变成那个类型。

```python
x = 42          # Python一看：哦，整数
y = 3.14        # 浮点数
name = "张三"    # 字符串
flag = True     # 布尔值
```

跟C/C++最大的不同：**不声明类型，不写分号**。赋值就是绑定的过程——`x = 42`意思是"把标签`x`贴到整数`42`上"。之后你可以把这个标签撕下来贴到别的东西上：

```python
x = 42
x = "hello"     # x 现在变成了字符串，完全合法
```

这叫**动态类型**。方便是方便，但你自己心里要清楚变量存的是啥，不然容易懵。

---

# 二、数字类型

Python有三种基本数字类型：`int`、`float`、`complex`。

## 2.1 整数 int

Python的整数**没有上限**（不像C的int只能到$2^{31}-1$），只要内存够大，多大的数都能算。

```python
a = 10
b = 0b1010     # 二进制，也是10
c = 0o12       # 八进制，还是10
d = 0xA        # 十六进制，依然是10

big = 2 ** 100  # 1267650600228229401496703205376，轻轻松松
print(big)
```

```cmd
1267650600228229401496703205376
```

**算术运算**：

```python
print(10 + 3)    # 13  加
print(10 - 3)    # 7   减
print(10 * 3)    # 30  乘
print(10 / 3)    # 3.3333333333333335  除（注意：结果总是浮点数！）
print(10 // 3)   # 3   整除（地板除）
print(10 % 3)    # 1   取余
print(10 ** 3)   # 1000  幂
```

```cmd
13
7
30
3.3333333333333335
3
1
1000
```

`/`永远给你浮点数，即使能整除。`//`才是真正的整数除法（C/C++里`/`的行为）。

## 2.2 浮点数 float

浮点数是`float`——就是带小数点的数。本质上是IEEE 754标准的双精度浮点数（和C的`double`一样，64位）。

```python
pi = 3.14159
sci = 1.5e-3    # 科学计数法 = 0.0015

print(0.1 + 0.2)   # 猜猜是多少？
```

```cmd
0.30000000000000004
```

**经典浮点坑**：`0.1 + 0.2`不等于精确的`0.3`。这不是Python的bug，是所有语言用二进制表示十进制小数的通病——0.1在二进制里是一个无限循环小数（就像十进制的$1/3 = 0.333\ldots$一样），截断后就差那么一丁点。

别用`==`比较浮点数，用`abs(a - b) < 1e-9`这种容差。

## 2.3 复数 complex

```python
z = 3 + 4j
print(z.real)    # 3.0
print(z.imag)    # 4.0
print(abs(z))    # 5.0  (√(3² + 4²))
```

## 2.4 类型转换

```python
print(int(3.14))       # 3  截断小数
print(float(10))       # 10.0
print(int("42"))       # 42  字符串转整数
print(str(100))        # '100'
print(bin(10))         # '0b1010'  转二进制字符串
print(hex(255))        # '0xff'    转十六进制
```

```cmd
3
10.0
42
100
0b1010
0xff
```

---

# 三、字符串

## 3.1 基础操作

三种引号都行：

```python
s1 = 'hello'
s2 = "world"
s3 = '''多行
字符串'''    # 三引号可以跨行
```

```python
s = "Hello World"
print(len(s))           # 11  长度
print(s[0])             # H   第0个字符（索引从0开始）
print(s[-1])            # d   倒数第一个
print(s[0:5])           # Hello  切片[始:终)（含左不含右）
print(s.upper())        # HELLO WORLD
print(s.lower())        # hello world
print(s.replace("World", "Python"))  # Hello Python
```

```cmd
11
H
d
Hello
HELLO WORLD
hello world
Hello Python
```

## 3.2 f-string（Python 3.6+）

字符串插值，在字符串前面写个`f`，大括号里能放变量甚至表达式：

```python
name = "张三"
age = 20
print(f"我叫{name}，明年{age + 1}岁")
```

```cmd
我叫张三，明年21岁
```

比`"我叫%s" % name`和`"我叫{}".format(name)`简洁太多了。能用f-string就用f-string。

## 3.3 常用字符串方法

```python
s = "  Hello,World,Python  "

print(s.strip())              # "Hello,World,Python"  去首尾空格
print(s.split(","))           # ['  Hello', 'World', 'Python  ']  按逗号切
print(",".join(["a","b"]))    # "a,b"  用逗号粘
print("abc123".isdigit())     # False  全是数字？
print("123".isdigit())        # True
print("hello".capitalize())   # "Hello"
```

---

# 四、布尔与比较

```python
a = True
b = False

print(10 > 5)      # True
print(10 == 10)    # True
print(10 != 5)     # True
print(5 < 3)       # False

# 逻辑运算
print(True and False)   # False
print(True or False)    # True
print(not True)         # False

# 数字也能当布尔用：0是False，非0是True
print(bool(0))      # False
print(bool(42))     # True
print(bool(""))     # False  空字符串
print(bool("hi"))   # True   非空
```

---

# 五、输入输出

```python
# 输出
print("Hello", "World", sep="-", end="!\n")  # Hello-World!

# 输入
name = input("你叫什么名字？")
print(f"你好，{name}！")
```

```cmd
Hello-World!
你叫什么名字？张三
你好，张三！
```

---

## 下一步

- [[02-控制流与函数|控制流与函数]] — if/else、for/while、函数定义
- [[03-数据结构|数据结构]] — list、tuple、dict、set
