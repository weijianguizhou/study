# Eigen 库使用指南

**Eigen** 是一个开源的 C++ 模板库，专注于**线性代数**、**矩阵运算**及**数值算法**。纯头文件、高性能（SIMD + 表达式模板）、跨平台零依赖。

- 官网：[https://eigen.tuxfamily.org](https://eigen.tuxfamily.org)
- 源码：[https://gitlab.com/libeigen/eigen](https://gitlab.com/libeigen/eigen)
- API 文档（5.0）：[https://libeigen.gitlab.io/eigen/docs-5.0/](https://libeigen.gitlab.io/eigen/docs-5.0/)
- 许可证：MPL 2.0

### 核心特点

- **纯头文件 (Header-only)**：`#include` 即用，无需编译链接
- **高性能**：表达式模板 + SSE/AVX/NEON 等 SIMD 指令集
- **直观语法**：`+` `-` `*` `/` `.transpose()` `.inverse()` `.solve()` 
- **功能丰富**：稠密/稀疏矩阵、LU/QR/Cholesky/SVD/特征值、几何变换
- **C++14+**（5.x 起）

---

## 目录（按学习顺序）

### 第一部分：基础入门
| 编号 | 文件 | 内容 |
|------|------|------|
| 01 | [[稠密矩阵和数组操作/01-Matrix类|Matrix 类]] | 模板参数、构造、系数访问、逗号初始化、resize |
| 02 | [[稠密矩阵和数组操作/02-矩阵和向量运算|矩阵和向量运算]] | 加减乘除、转置、点积、叉积（含完整代数推导） |
| 03 | [[稠密矩阵和数组操作/03-数组类和系数运算|数组类与系数运算]] | 逐元素运算、Array vs Matrix 互转 |

### 第二部分：高级操作
| 编号 | 文件 | 内容 |
|------|------|------|
| 04 | [[稠密矩阵和数组操作/04-块操作|块操作]] | block、行列角、head/tail/segment |
| 05 | [[稠密矩阵和数组操作/05-高级初始化|高级初始化]] | 逗号初始化器、Zero/Ones/Identity/Random/LinSpaced |
| 06 | [[稠密矩阵和数组操作/06-切片和索引操作|切片与索引操作]] | seq/seqN/last、反向切片、自定义填充 |
| 07 | [[稠密矩阵和数组操作/07-归约、访问者与广播|归约、访问者与广播]] | 范数、布尔归约、minCoeff、colwise/rowwise、广播 |

### 第三部分：线性求解与矩阵分解
| 编号 | 文件 | 内容 |
|------|------|------|
| 08 | [[08-分解概述与选择|分解概述与选择]] | Gauss消元原理、分解速查表、决策树、误差估计 |
| 09 | [[09-LU分解|LU 分解]] | PartialPivLU（普通方阵）、FullPivLU（秩/零空间）、选主元原理 |
| 10 | [[10-QR分解与最小二乘|QR 分解与最小二乘]] | Householder反射推导、最小二乘正规方程 |
| 11 | [[11-Cholesky分解|Cholesky 分解]] | 正定性定义、LLT（极速）、LDLT（半正定/复用） |
| 12 | [[12-SVD分解|SVD 分解]] | 奇异值几何意义、BDCSVD、JacobiSVD、低秩近似 |
| 13 | [[13-特征值与特征向量|特征值与特征向量]] | SelfAdjointEigenSolver、对称矩阵性质 |

### 第四部分：几何变换
| 编号 | 文件 | 内容 |
|------|------|------|
| 14 | [[14-旋转的表达|旋转的表达]] | AngleAxis、Quaternion、Euler角、Slerp、四种互转 |
| 15 | [[15-仿射变换|仿射变换 (Affine)]] | Translation、Scaling、齐次矩阵、点vs向量、法向量 |
| 16 | [[16-几何实战|几何实战]] | 手眼标定、DH参数推导、航迹推演、针孔相机模型 |

### 第五部分：实战应用
| 编号 | 文件 | 内容 |
|------|------|------|
| 17 | [[17-最小二乘与PCA|最小二乘与PCA]] | 正规方程推导、Lagrange乘子证PCA、多项式拟合 |
| 18 | [[18-卡尔曼滤波与点云配准|卡尔曼滤波与点云配准]] | 完整KF类、ICP SVD解析推导 |
| 19 | [[19-数值求解与性能技巧|数值求解与性能技巧]] | Taylor展开证RK4、noalias、预分配、行列优先 |

---

## 快速开始

```cpp
#include <Eigen/Dense>
using namespace Eigen;

MatrixXd m(2, 2);
m(0, 0) = 3;
m(1, 0) = 2.5;
m(0, 1) = -1;
m(1, 1) = m(1, 0) + m(0, 1);
std::cout << m << std::endl;
// 输出:  3  -1
//       2.5 1.5
```

**编译**（纯头文件，无需链接）：
```bash
g++ -I /path/to/eigen/ program.cpp -o program
```

---

## 相关笔记

- [[../数据结构|数据结构]]（稀疏矩阵压缩、图邻接矩阵）
- [[../../数理基础/代数/Linear algebra|线性代数]]（向量空间、矩阵运算、SVD、特征值的数学基础）
- [[../CMake使用指南/CMake使用指南|CMake 使用指南]]（Eigen 项目的构建配置）
