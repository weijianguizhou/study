# Cholesky 分解

---

# 复习一下代数学

## 正定矩阵

一个对称矩阵$A$，如果对**任意**非零向量$x$都有：
$$x^T A x > 0$$
就称$A$是**正定的**。

直观理解：正定矩阵就像一个"永远向上的碗"——把它用在二次型$x^T A x$上，不管$x$往哪个方向走，函数值始终是正的（除了$x=0$时为零）。

协方差矩阵、Hessian矩阵（在极小值附近）、$X^T X$ 都是正定矩阵。工程师和学机器学习的天天跟正定矩阵打交道。

## Cholesky分解是啥

如果$A$是对称正定矩阵，那它可以被分解成：

$$A = LL^T$$

$L$是下三角矩阵。这就叫**Cholesky分解**。

为什么牛逼？想想LU分解要算两个三角矩阵$L$和$U$，而且还要选主元。Cholesky只算一个$L$，$U$直接就是$L^T$，计算量直接减半。而且对称正定矩阵天然不需要选主元——对角元永远是非零的（甚至全是正的），天生稳定。

## 存在唯一性

只要$A$对称正定，Cholesky分解就**存在且唯一**（如果不要求$L$对角元为正的话，差一个正负号；一般约定对角元取正）。

---

# Eigen 里的 LLT（标准Cholesky）

Eigen里最标准的Cholesky叫`LLT`。你只要给它一个对称正定矩阵，它就能帮你搞定。

```C++
#include <iostream>
#include <Eigen/Dense>

int main() {
    Eigen::Matrix2d A;
    A << 2, -1,
        -1,  3;    // 对称正定

    Eigen::Vector2d b(1, 2);

    // 做分解 + 求解
    Eigen::LLT<Eigen::Matrix2d> llt(A);

    // 先查一下分解成功没
    if (llt.info() == Eigen::Success)
        std::cout << "分解成功，矩阵正定" << std::endl;
    else
        std::cout << "分解失败，矩阵不正定！" << std::endl;

    std::cout << "解 x: " << llt.solve(b).transpose() << std::endl;

    // 把 L 拿出来看看
    Eigen::Matrix2d L = llt.matrixL();
    std::cout << "下三角 L:\n" << L << std::endl;

    // 验算：L * L^T 应该等于 A
    std::cout << "L * L^T:\n" << L * L.transpose() << std::endl;
}
```

```cmd
分解成功，矩阵正定
解 x: 1.2 1.4
下三角 L:
 1.41421       0
-0.707107  1.58114
L * L^T:
 2 -1
-1  3
```

完美还原。对角元$l_{11} = \sqrt{a_{11}} = \sqrt{2} \approx 1.414$，$l_{21} = a_{21}/l_{11} = -1/1.414 \approx -0.707$，$l_{22} = \sqrt{a_{22} - l_{21}^2} = \sqrt{3 - 0.5} \approx 1.581$。

**`llt.info()`**返回`Eigen::Success`才说明分解成功。如果矩阵不正定，中间的平方根会碰到负数，分解就失败了。这算是Cholesky自带的正定性检验。

---

# Eigen 里的 LDLT

`LLT`虽然快，但它需要开平方根——$l_{ii} = \sqrt{a_{ii} - \sum_{k=1}^{i-1} l_{ik}^2}$。开根号会引入额外的浮点误差，而且如果矩阵半正定（某些特征值恰好为零），根号下的东西可能恰好是零或很小的负数，数值上会崩。

`LDLT`避开了根号。它把$A$分解成：

$$A = L D L^T$$

- $L$是**单位下三角**（对角元全是1）
- $D$是**对角矩阵**，对角元$d_i$存放了"不用开根号的中间结果"

不需要开根号，而且对半正定/半负定矩阵也能处理（$D$的对角元会出现0或负数）。

```C++
#include <iostream>
#include <Eigen/Dense>

int main() {
    Eigen::Matrix2d A;
    A << 2, -1,
        -1,  3;
    Eigen::Vector2d b(1, 2);

    Eigen::LDLT<Eigen::Matrix2d> ldlt(A);

    std::cout << "解 x: " << ldlt.solve(b).transpose() << std::endl;

    // D 的对角元单独拿出来是一个向量
    Eigen::Vector2d D_diag = ldlt.vectorD();
    std::cout << "D 的对角元: " << D_diag.transpose() << std::endl;

    // 单位下三角 L
    std::cout << "L:\n" << ldlt.matrixL() << std::endl;
}
```

```cmd
解 x: 1.2 1.4
D 的对角元: 2 2.5
L:
   1 0
-0.5 1
```

验算：$LDL^T$：
$$\begin{pmatrix} 1 & 0 \\ -0.5 & 1 \end{pmatrix} \begin{pmatrix} 2 & 0 \\ 0 & 2.5 \end{pmatrix} \begin{pmatrix} 1 & -0.5 \\ 0 & 1 \end{pmatrix} = \begin{pmatrix} 2 & -1 \\ -1 & 3 \end{pmatrix} = A$$

**一句话**：能用LLT就用LLT（更快，而且自动检验正定性），怕数值问题或者矩阵半正定就上LDLT。

---

# 复用分解器

如果你的循环里反复解不同$A$的方程（但$A$大小不变），可以把分解器预分配好，避免每次重新分配内存：

```C++
Eigen::LLT<Eigen::MatrixXf> llt(4);  // 给4×4矩阵预分配存储

for (int iter = 0; iter < 1000; iter++) {
    Eigen::MatrixXf A = /* 每次迭代构造的新对称正定矩阵 */;
    llt.compute(A);               // 重新分解，不分配新内存
    Eigen::VectorXf x = llt.solve(b);
}
```

预分配大小必须和实际矩阵大小一致，不然会触发动态分配。

---

# 正规方程的最小二乘

最小二乘问题$\min_x \|Ax - b\|^2$的正规方程是$A^T A x = A^T b$。$A^T A$天生对称半正定——如果$A$列满秩则正定。这时候你可以用Cholesky解：

```C++
Eigen::VectorXf x = (A.transpose() * A).ldlt().solve(A.transpose() * b);
```

**注意**：这个方法在$A$条件数很大的时候会放大误差（因为$A^T A$的条件数是$A$的条件数的平方）。一般还是推荐直接对$A$做QR或SVD求解，除非你确定$A$比较良态。

---

## 相关笔记

- [[08-分解概述与选择|分解概述与选择]] — 怎么选分解
- [[09-LU分解|LU 分解]] — 给非对称方阵的
- [[10-QR分解与最小二乘|QR 分解]] — 给长方形矩阵 + 最小二乘
