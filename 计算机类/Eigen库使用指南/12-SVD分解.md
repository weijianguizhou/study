# SVD 分解（奇异值分解）

---

# 复习一下代数学

## SVD是啥

**任何**一个$m\times n$矩阵$A$（不管它方不方、满不满秩、对称不对称），都可以写成：

$$A = U \Sigma V^T$$

其中：
- $U$是$m\times m$的正交矩阵。列向量叫**左奇异向量**。
- $V$是$n\times n$的正交矩阵。列向量叫**右奇异向量**。
- $\Sigma$是$m\times n$的"对角矩阵"：$\Sigma_{ii} = \sigma_i$（$i=1,\dots,\min(m,n)$），其余位置全是0。

对角线上的$\sigma_1 \geq \sigma_2 \geq \cdots \geq \sigma_r > 0 = \sigma_{r+1} = \cdots$叫做**奇异值**。$r$就是$A$的秩。

SVD是线性代数里的"终极分解"——它不挑矩阵，给你最丰富的信息，数值上最稳定。代价就是比LU/QR/Cholesky都慢。

## 奇异值的含义

把$A$看成从$\mathbb{R}^n$到$\mathbb{R}^m$的线性映射。SVD告诉我们，这个映射本质上干了三件事：

1. $V^T$：把输入旋转到一个"好的坐标系"
2. $\Sigma$：在每个坐标轴上分别拉伸（拉伸比就是奇异值）
3. $U$：再旋转到输出空间

单位球经过$A$映射后变成一个**椭球**——奇异值就是这个椭球在各主轴上的半轴长。最大的奇异值$\sigma_1$就是$A$的2-范数（最大拉伸比）。

---

# Eigen 里的 SVD

Eigen给了两种SVD实现：

| 实现 | 特点 |
|------|------|
| `BDCSVD` | 分治算法。大矩阵快，小矩阵自动退回Jacobi。**日常推荐** |
| `JacobiSVD` | 双边Jacobi旋转。精度最高，但慢 |

## 起手式

```C++
#include <iostream>
#include <Eigen/Dense>

int main() {
    Eigen::MatrixXf A = Eigen::MatrixXf::Random(3, 2);
    Eigen::VectorXf b = Eigen::VectorXf::Random(3);

    std::cout << "A (3x2):\n" << A << std::endl;

    // 最少代码：一行搞定最小二乘
    Eigen::VectorXf x = A.bdcSvd(Eigen::ComputeThinU | Eigen::ComputeThinV).solve(b);
    std::cout << "SVD最小二乘解: " << x.transpose() << std::endl;
}
```

`ComputeThinU`和`ComputeThinV`是啥？它们是告诉SVD你要算哪个部分的标志：

- `ComputeFullU`：算完整的$m\times m$的$U$
- `ComputeThinU`：只算前$\min(m,n)$列，省内存
- `ComputeFullV`：算完整的$n\times n$的$V$
- `ComputeThinV`：只算前$\min(m,n)$列

你如果只是解方程，`ComputeThinU | ComputeThinV`就够了。如果你想分析奇异值和奇异向量，就用`ComputeFullU | ComputeFullV`。

## 把 U、Σ、V 拿出来

```C++
#include <iostream>
#include <Eigen/Dense>

int main() {
    Eigen::Matrix3f A = Eigen::Matrix3f::Random();

    Eigen::BDCSVD<Eigen::Matrix3f> svd(A, Eigen::ComputeFullU | Eigen::ComputeFullV);

    // 奇异值（排好序的，从大到小）
    std::cout << "奇异值: " << svd.singularValues().transpose() << std::endl;

    // U 和 V
    Eigen::Matrix3f U = svd.matrixU();
    Eigen::Matrix3f V = svd.matrixV();

    // 重拼 Σ（对角矩阵）
    Eigen::Matrix3f Sigma = svd.singularValues().asDiagonal();

    // 验证 A = U * Σ * V^T
    Eigen::Matrix3f A_reconstructed = U * Sigma * V.transpose();
    std::cout << "重建误差: " << (A - A_reconstructed).norm() << std::endl;
}
```

```cmd
奇异值: 1.847 0.978 0.432
重建误差: 5.96e-08
```

误差在$10^{-8}$量级，完美。

## 通过奇异值判断秩

```C++
Eigen::BDCSVD<Eigen::MatrixXf> svd(A, Eigen::ComputeThinU | Eigen::ComputeThinV);

// 设阈值——小于这个的奇异值算作0
svd.setThreshold(1e-5);
std::cout << "A的秩: " << svd.rank() << std::endl;
```

默认阈值是用最大的奇异值乘以机器精度再乘矩阵大小。

---

# 低秩近似（数据压缩）

SVD有一个特别漂亮的应用：把小的奇异值扔掉，得到一个低秩的近似矩阵。这在图像压缩、数据降噪、推荐系统里天天用。

数学上，如果你只保留前$k$个最大的奇异值（和对应的奇异向量），你就得到了$A$的**秩-$k$最佳近似**（在Frobenius范数/谱范数下都是最优的）：

$$A_k = U_{:,1:k} \cdot \Sigma_{1:k,1:k} \cdot V_{:,1:k}^T$$

```C++
#include <iostream>
#include <Eigen/Dense>

int main() {
    // 造一个 10×10 的矩阵
    Eigen::MatrixXd A = Eigen::MatrixXd::Random(10, 10);

    Eigen::JacobiSVD<Eigen::MatrixXd> svd(A, Eigen::ComputeThinU | Eigen::ComputeThinV);

    std::cout << "原始奇异值:" << std::endl;
    std::cout << svd.singularValues().transpose() << std::endl;

    // 只保留前3个奇异值
    int k = 3;
    Eigen::MatrixXd A_k = svd.matrixU().leftCols(k)
                        * svd.singularValues().head(k).asDiagonal()
                        * svd.matrixV().leftCols(k).transpose();

    double err = (A - A_k).norm() / A.norm();
    std::cout << "秩-" << k << " 近似的相对误差: " << err << std::endl;

    // 原来的数据量：10×10 = 100 个数
    // 压缩后的数据量（U的前k列 + k个奇异值 + V的前k列）= 10×3 + 3 + 10×3 = 63 个数
    std::cout << "压缩比: " << (10.0*3 + 3 + 10*3) / (10.0*10) << std::endl;
}
```

```cmd
原始奇异值:
4.08 3.62 3.12 2.81 2.52 1.89 1.52 1.23 0.87 0.38
秩-3 近似的相对误差: 0.427
压缩比: 0.63
```

---

# BDCSVD vs JacobiSVD

| 场景 | 用啥 |
|------|------|
| 日常求解、最小二乘 | `BDCSVD`，快 |
| 大矩阵（比如 1000×1000）| `BDCSVD`，分治算法优势明显 |
| 需要最高精度 | `JacobiSVD` |
| 小矩阵（$\leq 16\times 16$）| 随便，差异不大 |

如果你拿不准，就用`BDCSVD`。它是Eigen推荐的默认SVD。

---

## 相关笔记

- [[08-分解概述与选择|分解概述与选择]] — 啥时候用SVD
- [[13-特征值与特征向量|特征值与特征向量]] — 特征分解（对称矩阵用这个更快）
- [[18-卡尔曼滤波与点云配准|点云配准]] — SVD在ICP中的应用
