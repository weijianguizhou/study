在`Eigen`库里，所有的矩阵和向量都是`Matrix`类的对象。
# `Matrix`类的参数
`Matrix`类总共接受六个参数。前三个参数分别是`Matrix<typename Scalar, int RowsAtCompileTime, int ColsAtCompileTime>`(一般不能不填)
1. `Scalar`是标量类型，就是矩阵里面量的数据类型(`int`,`double`,`float`啥的)
2. `RowsAtCompileTime`和`ColsAtCompileTime`是编译的时候你告诉编译器的矩阵的行数和列数

下面举个例子：
我现在要定义一个$4\times 4$的浮点数矩阵，我们可以这么定义：
```C++
typedef Matrix<float, 4, 4> Matrix4f;
```

我们知道，向量是一类特殊的矩阵，于是我们可以这么定义向量：
一个列向量：
```C++
typedef Matrix<float,3,1> Vector3f;
```

一个行向量：
```C++
typedef Matrix<float,1,2> RowVector2i;
```

## 动态特殊值
这么看来，我必须得在编译的时候知道矩阵的维数？`Eigen`库很牛逼，它为我们提供了一个牛逼的参数`Dynamic`,这样在编译的时候这个矩阵就可以是一个动态的大小,(Dynamic Size)

举个🌰：
```C++
typedef Matrix<double, Dynamic, Dynamic> MatrixXd;
```
当然，也可以让行固定参数而列动态参数。或者反过来。
如：
```C++
Matrix<float, 3, Dynamic> Sibuxiang
```

# 构造函数(Constructors)
默认构造函数始终可用，它从不执行任何动态内存分配，也从不初始化矩阵系数。
于是我们可以这样：
```C++
Matrix3f a;
MatrixXf b;
```
这里：
- a是一个$3\times 3$的矩阵，里面有9个未初始化参数的浮点值；
- b现在是一个$0 \times 0$的矩阵，里面的值也没有初始化。

也可以传递初始矩阵大小：
```C++
MatrixXf a(10,15);
VectorXf b(30);
```
这里：
-  `a`是一个$10 \times 15$动态大小的矩阵，具有已分配但目前尚未初始化的系数。
- `b`是一个大小为 $30$ 的动态大小（列）向量，具有已分配但当前未初始化的系数。

为了统一API(Application Programming Interface，应用编程接口),也可以对确定维数的矩阵进行上述操作，合法，但没用。

我们还可以这样初始化一个矩阵(C++11以上)，通过传递任意数量的系数来初始化任意大小的固定大小的列向量或行向量:
```C++
Vector2i a(1, 2);                       // 包含元素 {1, 2} 的列向量
Matrix<int, 5, 1> b {1, 2, 3, 4, 5};    // 包含元素 {1, 2, 3, 4, 5} 的列向量
Matrix<int, 1, 5> c = {1, 2, 3, 4, 5}; // 包含元素 {1, 2, 3, 4, 5} 的行向量
```

对于一般情况下大小固定或运行时可变的矩阵和向量，系数必须按行分组，并以初始化列表的初始化列表的形式传递:
```C++
MatrixXi a {       // 构造一个 2x2 矩阵
      {1, 2},      // 第一行
      {3, 4}       // 第二行
};
Matrix<double, 2, 3> b {
      {2, 3, 4},
      {5, 6, 7},
};
```

对于列向量或行向量，允许隐式转置。这意味着列向量可以从单行初始化：
```C++
VectorXd a {{1.5, 2.5, 3.5}};              // 一个包含 3 个系数的列向量
RowVectorXd b {{1.0, 2.0, 3.0, 4.0}};      // 一个包含 4 个系数的行向量
```

# 系数访问器 （Coefficient accessors）
`Eigen`中的主要系数访问器和修改器是重载的括号运算符。对于矩阵，行索引始终先传递。对于向量，只需传递一个索引。编号从 0 开始。
```C++
#include <iostream>
#include <Eigen/Dense>

int main() {
  Eigen::MatrixXd m(2, 2);
  m(0, 0) = 3;
  m(1, 0) = 2.5;
  m(0, 1) = -1;
  m(1, 1) = m(1, 0) + m(0, 1);
  std::cout << "这是矩阵 m：\n" << m << std::endl;
  Eigen::VectorXd v(2);
  v(0) = 4;
  v(1) = v(0) - 1;
  std::cout << "这是向量 v：\n" << v << std::endl;
}
```
输出结果：
```bash
矩阵 m 如下：
  3-1
2.5 1.5
这是向量 v：
4
3
```
请注意，此语法`m(index)`不仅限于向量，也适用于一般矩阵，即通过索引访问系数数组。但这取决于矩阵的存储顺序。所有特征矩阵默认采用列优先存储顺序，但可以更改为行优先。后面再说，这里按下不表。

# 逗号初始化(Comma-initialization)
可以使用所谓的逗号初始化语法方便地设置矩阵和向量系数。只需了解以下示例即可：
```C++
Eigen::Matrix3f m;
  m << 1, 2, 3, 4, 5, 6, 7, 8, 9;
  std::cout << m;
```
```shell
1 2 3
4 5 6
7 8 9
```

# 调整大小
可以使用`rows()`、`cols()`和`size()`方法获取矩阵的当前大小。这些方法分别返回行数、列数和系数个数。动态矩阵的大小调整可以通过`resize()`方法完成。
```C++
#include <iostream>
#include <Eigen/Dense>

int main() {
  Eigen::MatrixXd m(2, 5);
  m.resize(4, 3);
  std::cout << "矩阵 m 的大小为 " << m.rows() << "x" << m.cols() << std::endl;
  std::cout << "它有 " << m.size() << " 个系数" << std::endl;
  Eigen::VectorXd v(2);
  v.resize(5);
  std::cout << "向量 v 的大小为 " << v.size() << std::endl;
  std::cout << "作为一个矩阵，v 的大小为 " << v.rows() << "x" << v.cols() << std::endl;
}
```
```Shell
矩阵 m 的大小为 4x3
它有12个系数
向量 v 的大小为 5
矩阵 v 的大小为 5x1
```
为了保持 API 的一致性，所有这些方法仍然适用于固定大小的矩阵。当然，你实际上无法调整固定大小矩阵的大小。尝试将固定大小更改为实际不同的值会触发断言失败；但以下代码是合法的：
```C++
#include <iostream>
#include <Eigen/Dense>

int main() {
  Eigen::Matrix4d m;
  m.resize ( 4, 4);   // 无操作
  std::cout << "矩阵 m 的大小为 " << m.rows() << "x" << m.cols() << std::endl;
}
```

```cmd
矩阵 m 的大小为 4x4
```

# 赋值操作
赋值操作是指将一个矩阵复制到另一个矩阵中`operator=`。Eigen会自动调整左侧矩阵的大小，使其与右侧矩阵的大小匹配。例如：
```C++
MatrixXf a(2, 2);
std::cout << "a 的大小为 " << a.rows() << "x" << a.cols() << std::endl;
MatrixXf b(3, 3);
a = b；
std::cout << "a 现在的大小为 " << a.rows() << "x" << a.cols() << std::endl;
```

```cmd
a 的尺寸为 2x2
a 现在的大小为 3x3
```

