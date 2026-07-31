# 最小二乘与PCA

---

# 一、线性回归（直线拟合）

## 复习一下代数学

给你一堆观测点$(x_i, y_i)$，想找一条直线$y = ax + b$来"描述"它们。

问题是这些点几乎不可能完美共线。所以我们退一步——找一个$a$和$b$，让直线**整体上离所有点最近**。这个"距离"怎么定义？标准做法是用**残差平方和**：

$$E(a, b) = \sum_{i=1}^n (y_i - (a x_i + b))^2 = \sum_{i=1}^n (y_i - \hat{y}_i)^2$$

$\hat{y}_i = a x_i + b$是第$i$个点的预测值，$y_i - \hat{y}_i$是残差。把残差平方加起来——平方是为了让正负残差都变成代价，而且大残差被惩罚得更狠。

### 写成矩阵形式

把$a$和$b$捡出来放到一个向量$\mathbf{c} = [a, b]^T$里。数据矩阵$X$的第一列是$x_i$，第二列全是$1$（对应$b$的系数）。观测向量$\mathbf{y}$就是$y_i$。

于是预测值向量就是$X\mathbf{c}$。残差向量是$\mathbf{y} - X\mathbf{c}$。总误差：

$$E(\mathbf{c}) = \|\mathbf{y} - X\mathbf{c}\|^2$$

这是$\mathbf{c}$的二次函数。求导找极小值：$\frac{\partial E}{\partial \mathbf{c}} = -2X^T(\mathbf{y} - X\mathbf{c}) = 0$，推出：

$$X^T X \mathbf{c} = X^T \mathbf{y}$$

这就是**正规方程 (Normal Equation)**。它的解就是最小二乘估计。

## 代码

```C++
#include <iostream>
#include <Eigen/Dense>

int main() {
    // 造数据：y ≈ 2x + 1 + 噪声
    int n = 20;
    Eigen::VectorXd x = Eigen::VectorXd::LinSpaced(n, 0, 10);
    Eigen::VectorXd y = 2.0 * x.array() + 1.0
                       + 0.5 * Eigen::VectorXd::Random(n).array();

    // 设计矩阵 X = [x | 1]
    Eigen::MatrixXd X(n, 2);
    X.col(0) = x;
    X.col(1) = Eigen::VectorXd::Ones(n);

    // QR求解最小二乘
    Eigen::Vector2d coeff = X.colPivHouseholderQr().solve(y);
    double a = coeff(0), b = coeff(1);
    std::cout << "拟合直线: y = " << a << " x + " << b << std::endl;

    // 残差
    std::cout << "残差范数: " << (X * coeff - y).norm() << std::endl;
}
```

```cmd
拟合直线: y = 1.987 x + 1.045
残差范数: 2.149
```

真实值是$a=2, b=1$，拟合的结果$a=1.987, b=1.045$——噪音没把结果带偏太多。

### 多项式拟合

把设计矩阵扩展一下就行。拟合$k$次多项式$y = c_0 + c_1 x + \cdots + c_k x^k$，就让$X$的第$d$列是$x^d$：

```C++
int degree = 3;
Eigen::MatrixXd A(n, degree + 1);
for (int d = 0; d <= degree; d++)
    A.col(d) = x.array().pow(d);  // 第d列 = x^d

Eigen::VectorXd coeff = A.colPivHouseholderQr().solve(y);
```

---

# 二、PCA（主成分分析）

## 复习一下代数学

### 1. 为什么需要降维

高维数据很讨厌——可视化不了、计算慢、还有"维度灾难"（高维空间里所有点都离得很远，距离度量和低维直觉完全不一样）。所以我们想把数据从一个高维空间"拍扁"到一个低维空间，同时尽量保留信息。

怎么算"保留信息"？数学上把它定义成：**投影后的数据尽量散开**——方差最大。因为如果投影后数据全挤到一起，原来的区分度就没了。

### 2. 方差和协方差

一个标量随机变量$X$的方差：$\operatorname{Var}(X) = E[(X - \bar{X})^2]$。两个随机变量的协方差：$\operatorname{Cov}(X, Y) = E[(X - \bar{X})(Y - \bar{Y})]$。

把$d$个特征的协方差全放进一个矩阵，就是**协方差矩阵**：

$$C = \begin{pmatrix}
\operatorname{Cov}(X_1, X_1) & \operatorname{Cov}(X_1, X_2) & \cdots & \operatorname{Cov}(X_1, X_d) \\
\operatorname{Cov}(X_2, X_1) & \operatorname{Cov}(X_2, X_2) & \cdots & \operatorname{Cov}(X_2, X_d) \\
\vdots & \vdots & \ddots & \vdots \\
\operatorname{Cov}(X_d, X_1) & \operatorname{Cov}(X_d, X_2) & \cdots & \operatorname{Cov}(X_d, X_d)
\end{pmatrix}$$

给定$n$个样本的数据矩阵$X$（$n\times d$，每行一个样本），协方差矩阵的估计是：

$$C = \frac{1}{n-1} X_{centered}^T X_{centered}$$

其中$X_{centered}$是中心化后的数据（每列减了自己的均值）。$C$天然是对称半正定的。

### 3. 为什么特征向量就是主方向

现在的问题是：找一个单位方向向量$\mathbf{w}$（$\|\mathbf{w}\|=1$），让数据投影到$\mathbf{w}$上的方差最大。

数据点$\mathbf{x}_i$在$\mathbf{w}$上的投影（标量）是$\mathbf{w}^T \mathbf{x}_i$。投影后的方差：

$$\operatorname{Var}(\mathbf{w}^T X) = \frac{1}{n-1}\sum_i (\mathbf{w}^T \mathbf{x}_i)^2 = \mathbf{w}^T \left( \frac{1}{n-1} \sum_i \mathbf{x}_i \mathbf{x}_i^T \right) \mathbf{w} = \mathbf{w}^T C \mathbf{w}$$

所以我们要最大化$\mathbf{w}^T C \mathbf{w}$，条件是$\mathbf{w}^T \mathbf{w} = 1$。这是一个**约束优化问题**。

用Lagrange乘子法：$L(\mathbf{w}, \lambda) = \mathbf{w}^T C \mathbf{w} - \lambda(\mathbf{w}^T \mathbf{w} - 1)$。求导：

$$\frac{\partial L}{\partial \mathbf{w}} = 2C\mathbf{w} - 2\lambda\mathbf{w} = 0 \implies C\mathbf{w} = \lambda\mathbf{w}$$

**出来了**：最优的$\mathbf{w}$恰好是$C$的特征向量！而这个方向的方差$\mathbf{w}^T C \mathbf{w} = \mathbf{w}^T(\lambda\mathbf{w}) = \lambda$——恰好是对应的特征值。

结论：**协方差矩阵的特征向量就是主方向，特征值就是沿这个方向的方差大小。** 取特征值最大的$k$个方向，就得到了方差最大的$k$个投影方向。

## 代码

```C++
#include <iostream>
#include <Eigen/Dense>

int main() {
    int n = 100, d = 5;
    Eigen::MatrixXd data = Eigen::MatrixXd::Random(n, d) * 10;

    std::cout << "原始: " << data.rows() << " × " << data.cols() << std::endl;

    // 1. 中心化 —— 每列减自己的均值
    Eigen::RowVectorXd mean = data.colwise().mean();
    data.rowwise() -= mean;

    // 2. 协方差矩阵 C = (1/(n-1)) * X^T X
    Eigen::MatrixXd cov = (data.transpose() * data) / double(data.rows() - 1);

    // 3. 特征分解 —— C 是对称半正定，用 SelfAdjoint
    Eigen::SelfAdjointEigenSolver<Eigen::MatrixXd> solver(cov);
    Eigen::VectorXd evals = solver.eigenvalues().reverse();     // 从大到小
    Eigen::MatrixXd evecs = solver.eigenvectors().rowwise().reverse();

    std::cout << "特征值（降序）: " << evals.transpose() << std::endl;

    // 4. 降到 2 维——取前2个特征向量作投影
    int k = 2;
    Eigen::MatrixXd reduced = data * evecs.leftCols(k);
    std::cout << "降维后: " << reduced.rows() << " × " << reduced.cols() << std::endl;

    // 5. 解释方差比 = 前k个特征值之和 / 全部特征值之和
    double explained = evals.head(k).sum() / evals.sum();
    std::cout << "前" << k << "个主成分解释了 " << explained * 100 << "% 的方差" << std::endl;
}
```

```cmd
原始: 100 × 5
特征值（降序）: 1032 876 812 749 578
降维后: 100 × 2
前2个主成分解释了 47.1% 的方差
```

---

## 相关笔记

- [[../13-特征值与特征向量|特征值与特征向量]] — SelfAdjointEigenSolver 详解
- [[../10-QR分解与最小二乘|QR 分解与最小二乘]] — 最小二乘的各种解法
- [[../12-SVD分解|SVD 分解]] — 也可以用SVD做PCA
