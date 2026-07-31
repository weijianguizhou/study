# 层次分析法（AHP）

参考：[[../代数/Linear algebra|线性代数]]

---

## 一、概述

层次分析法（Analytic Hierarchy Process, AHP）由 Thomas L. Saaty 在 20 世纪 70 年代提出，是**定性与定量相结合**的多准则决策方法。

三大核心操作：
1. **层次化**：将决策问题分解为目标—准则—方案三层结构
2. **两两比较**：在每一层对因素的两两相对重要性进行判断
3. **综合排序**：逐层合成权重，确定各方案的总排序

---

## 二、层次结构模型

```
目标层 (G): 决策的最终目标
    |
准则层 (C): C₁, C₂, ..., Cₙ (评价准则)
    |
方案层 (P): P₁, P₂, ..., Pₘ (候选方案)
```

---

## 三、判断矩阵

### 3.1 Saaty 1-9 标度

对同一上层元素的 $n$ 个子元素进行两两比较，用数值 $a_{ij}$ 表示 $i$ 相对于 $j$ 的重要程度：

| 标度 $a_{ij}$ | 含义 |
|:-:|:--|
| 1 | $i$ 与 $j$ 同等重要 |
| 3 | $i$ 比 $j$ 稍微重要 |
| 5 | $i$ 比 $j$ 明显重要 |
| 7 | $i$ 比 $j$ 强烈重要 |
| 9 | $i$ 比 $j$ 极端重要 |
| 2,4,6,8 | 相邻判断的中间值 |
| 倒数 | 若 $a_{ij} = k$，则 $a_{ji} = 1/k$ |

### 3.2 判断矩阵的结构

$$
\mathbf{A} = \begin{pmatrix}
1 & a_{12} & \cdots & a_{1n} \\
a_{21} & 1 & \cdots & a_{2n} \\
\vdots & \vdots & \ddots & \vdots \\
a_{n1} & a_{n2} & \cdots & 1
\end{pmatrix}
$$

基本性质：
- **正性**：$a_{ij} > 0$
- **互反性**：$a_{ij} = 1/a_{ji}$
- **单位对角线**：$a_{ii} = 1$

若还满足**一致性** $a_{ij} \cdot a_{jk} = a_{ik}$（$\forall i,j,k$），则 $\mathbf{A}$ 称为完全一致判断矩阵。

---

## 四、权重计算方法

### 4.1 特征值法（最精确）

判断矩阵是正互反矩阵，根据 Perron-Frobenius 定理，最大特征值 $\lambda_{\max}$ 为正实数且为单根，对应的特征向量 $\mathbf{w}$ 的各分量均为正。

$$
\mathbf{A}\mathbf{w} = \lambda_{\max} \mathbf{w}
$$

归一化后得到权重向量：

$$
w_i = \frac{w_i^*}{\sum_{j=1}^{n} w_j^*}
$$

**理论依据**：若 $\mathbf{A}$ 完全一致，则 $\lambda_{\max} = n$，且 $\mathbf{w}$ 各分量正比于真实权重。

**完全一致性的证明**：

完全一致性意味着 $a_{ik} = w_i / w_k$，则：

$$
(\mathbf{A}\mathbf{w})_i = \sum_{k=1}^{n} a_{ik} w_k = \sum_{k=1}^{n} \frac{w_i}{w_k} w_k = n w_i
$$

所以 $\lambda_{\max} = n$，$\mathbf{w}$ 正是特征向量。

### 4.2 几何平均法（简便近似）

**步骤**：
1. 计算每行元素的几何平均值：

$$
\bar{w}_i = \left( \prod_{j=1}^{n} a_{ij} \right)^{1/n}
$$

2. 归一化：

$$
w_i = \frac{\bar{w}_i}{\sum_{j=1}^{n} \bar{w}_j}
$$

**推导直觉**：在完全一致矩阵中，$a_{ij} = w_i / w_j$，则：

$$
\prod_{j=1}^{n} a_{ij} = \prod_{j=1}^{n} \frac{w_i}{w_j} = w_i^n / \prod_j w_j
$$

开 $n$ 次方并归一化后即恢复 $w_i$。

### 4.3 算术平均法（列归一化法）

**步骤**：
1. 列归一化：$\bar{a}_{ij} = a_{ij} / \sum_{k=1}^{n} a_{kj}$
2. 行平均：$w_i = \frac{1}{n} \sum_{j=1}^{n} \bar{a}_{ij}$

### 4.4 三种方法的比较

| 方法 | 精度 | 计算复杂度 | 适用场景 |
|------|------|------------|----------|
| 特征值法 | 最高 | 需特征分解 | 精确求解 |
| 几何平均法 | 高 | 低（乘幂） | 手工计算/Excel |
| 算术平均法 | 中 | 低 | 快速近似 |

三种方法在判断矩阵完全一致时给出相同结果。

---

## 五、一致性检验

### 5.1 一致性的概念

完全一致矩阵满足 $a_{ij} \cdot a_{jk} = a_{ik}$（传递性）。实际中判断通常不完全一致，需度量不一致程度。

### 5.2 一致性指标 CI

$$
\boxed{CI = \frac{\lambda_{\max} - n}{n - 1}}
$$

- 完全一致时 $\lambda_{\max} = n$，$CI = 0$
- $\lambda_{\max}$ 越大，$CI$ 越大，不一致程度越严重

### 5.3 随机一致性指标 RI

Saaty 通过大量随机正互反矩阵实验得到的平均 RI 值：

| $n$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| $RI$ | 0 | 0 | 0.52 | 0.89 | 1.12 | 1.26 | 1.36 | 1.41 | 1.46 | 1.49 | 1.52 | 1.54 |

### 5.4 一致性比率 CR

$$
\boxed{CR = \frac{CI}{RI}}
$$

**判定标准**：
- $CR < 0.10$：判断矩阵具有满意一致性（通过检验）
- $CR \geq 0.10$：需调整判断矩阵

$n=1,2$ 时无需检验（始终一致）。

### 5.5 不一致矩阵的修正策略

1. 计算**偏差矩阵** $\mathbf{D}$，其中 $d_{ij} = a_{ij} \cdot (w_j / w_i)$
2. 定位最不一致的元素对（$|d_{ij} - 1|$ 最大者）
3. 重新评估 $a_{ij}$ 并调整至 $a_{ij} \approx w_i / w_j$
4. 迭代至 $CR < 0.10$

---

## 六、层次总排序

### 6.1 综合权重的计算

设准则层对目标层的权重为 $\mathbf{w}^{(2)} = (w_1^{(2)}, \ldots, w_n^{(2)})^T$，方案层对准则 $C_j$ 的权重为 $\mathbf{w}_j^{(3)} = (w_{1j}^{(3)}, \ldots, w_{mj}^{(3)})^T$。

方案 $P_i$ 相对于目标 $G$ 的总权重：

$$
\boxed{W_i = \sum_{j=1}^{n} w_j^{(2)} \cdot w_{ij}^{(3)}}
$$

矩阵形式：

$$
\mathbf{W} = W^{(3)} \cdot \mathbf{w}^{(2)}
$$

其中 $W^{(3)}_{m \times n} = [\mathbf{w}_1^{(3)}, \mathbf{w}_2^{(3)}, \ldots, \mathbf{w}_n^{(3)}]$。

### 6.2 层次总排序一致性检验

方案层对准则 $C_j$ 的一致性指标为 $CI_j$，随机一致性指标为 $RI_j$。

总排序的 $CR$：

$$
CR_{\text{总}} = \frac{\sum_{j=1}^{n} w_j^{(2)} \cdot CI_j}{\sum_{j=1}^{n} w_j^{(2)} \cdot RI_j}
$$

当 $CR_{\text{总}} < 0.10$ 时，层次总排序结果具有满意的一致性。

---

## 七、群组 AHP

多位专家各自给出判断矩阵，整合方法：

### 7.1 判断矩阵的几何平均

先对各专家的判断矩阵按元素取几何平均，再计算权重：

$$
a_{ij}^{\text{群}} = \left( \prod_{k=1}^{K} a_{ij}^{(k)} \right)^{1/K}
$$

此方法保持判断矩阵的互反性。

### 7.2 权重的几何平均

分别计算各专家的权重向量后再取几何平均：

$$
w_i^{\text{群}} = \left( \prod_{k=1}^{K} w_i^{(k)} \right)^{1/K}
$$

---

## 八、模糊 AHP（扩展）

将精确的 1-9 标度替换为三角模糊数：

$$
\tilde{a}_{ij} = (l_{ij}, m_{ij}, u_{ij})
$$

其中 $l_{ij} \leq m_{ij} \leq u_{ij}$。利用模糊数扩展原理进行权重计算，适用于专家判断模糊或犹豫的情况。

---

## 九、注意事项与局限性

| 优势 | 局限 |
|------|------|
| 结构清晰、直观易用 | 指标过多（$n > 9$）时判断矩阵难一致 |
| 定性与定量结合 | 1-9 标度较粗糙，主观性强 |
| 一致性检验保障合理逻辑 | 仅适用于层次结构问题 |
| 群决策整合方便 | 排序翻转（Rank Reversal）现象 |
| 应用广泛（评价、资源分配） | 大样本量下效率低 |

**使用建议**：
1. 准则数控制在 $2 \leq n \leq 9$
2. 当 $CR$ 不满足时，重新审视判断而非强行修正
3. 结合熵权法等客观赋权方法降低主观性偏差
4. 群组决策以几何平均法整合专家意见

---

## 十、Python 实现

### 10.1 核心 AHP 计算函数

```python
import numpy as np

def ahp_weight(matrix):
    """特征值法计算AHP权重及一致性检验"""
    n = matrix.shape[0]
    
    # 特征值分解
    eigenvalues, eigenvectors = np.linalg.eig(matrix)
    max_idx = np.argmax(eigenvalues.real)
    lambda_max = eigenvalues[max_idx].real
    
    # 权重向量（归一化）
    w = eigenvectors[:, max_idx].real
    w = w / w.sum()
    
    # 一致性检验
    CI = (lambda_max - n) / (n - 1) if n > 1 else 0
    RI_table = {1:0, 2:0, 3:0.52, 4:0.89, 5:1.12,
                6:1.26, 7:1.36, 8:1.41, 9:1.46, 10:1.49}
    RI = RI_table.get(n, 1.49)
    CR = CI / RI if RI > 0 else 0
    
    return w, lambda_max, CI, CR

def geometric_mean_weight(matrix):
    """几何平均法"""
    n = matrix.shape[0]
    row_geom = np.prod(matrix, axis=1) ** (1.0/n)
    return row_geom / row_geom.sum()

def arithmetic_mean_weight(matrix):
    """算术平均法（列归一化后行平均）"""
    col_sum = matrix.sum(axis=0)
    normalized = matrix / col_sum
    return normalized.mean(axis=1)

# 示例：准则层判断矩阵
A = np.array([
    [1,    1/2,  4,    3  ],
    [2,    1,    7,    5  ],
    [1/4,  1/7,  1,    1/2],
    [1/3,  1/5,  2,    1  ]
])

# 三种方法对比
w_eig, lam, ci, cr = ahp_weight(A)
w_geom = geometric_mean_weight(A)
w_arith = arithmetic_mean_weight(A)

print("特征值法:", np.round(w_eig, 4))
print("几何平均法:", np.round(w_geom, 4))
print("算术平均法:", np.round(w_arith, 4))
print(f"λ_max={lam:.4f}, CI={ci:.4f}, CR={cr:.4f}, {'通过' if cr<0.1 else '未通过'}")
```

### 10.2 完整 AHP 评价系统

```python
class AHPSystem:
    """完整的 AHP 评价系统"""
    
    def __init__(self):
        self.criteria_matrix = None
        self.criteria_names = []
        self.alt_matrices = {}  # {criterion_name: matrix}
        self.alt_names = []
    
    def set_criteria(self, names, matrix):
        self.criteria_names = names
        self.criteria_matrix = np.array(matrix, dtype=float)
    
    def set_alternatives(self, names, matrices):
        self.alt_names = names
        self.alt_matrices = matrices
    
    def _calc(self, mat):
        n = mat.shape[0]
        evals, evecs = np.linalg.eig(mat)
        idx = np.argmax(evals.real)
        lam = evals[idx].real
        w = evecs[:, idx].real / evecs[:, idx].real.sum()
        CI = (lam - n) / (n - 1) if n > 1 else 0
        RI_t = {1:0,2:0,3:0.52,4:0.89,5:1.12,6:1.26,7:1.36,8:1.41,9:1.46}
        RI = RI_t.get(n, 1.49)
        CR = CI / RI if RI > 0 else 0
        return w, lam, CI, CR
    
    def evaluate(self):
        # 准则层权重
        w_c, lam_c, CI_c, CR_c = self._calc(self.criteria_matrix)
        print(f"准则层权重: CR={CR_c:.4f} {'✓' if CR_c<0.1 else '✗'}")
        for i, name in enumerate(self.criteria_names):
            print(f"  {name}: {w_c[i]:.4f}")
        
        # 方案层权重矩阵
        n_alt = len(self.alt_names)
        n_crit = len(self.criteria_names)
        W_alt = np.zeros((n_alt, n_crit))
        CI_list, RI_list = [], []
        
        for j, cname in enumerate(self.criteria_names):
            mat = np.array(self.criteria_matrices.get(cname,
                           self.alt_matrices.get(cname)), dtype=float)
            w_a, lam_a, ci_a, cr_a = self._calc(mat)
            W_alt[:, j] = w_a
            n_a = mat.shape[0]
            CI_list.append(ci_a)
            RI_t = {1:0,2:0,3:0.52,4:0.89,5:1.12,6:1.26}
            RI_list.append(RI_t.get(n_a, 1.49))
        
        # 综合权重
        final_w = W_alt @ w_c
        
        # 总排序一致性
        CI_arr = np.array(CI_list)
        RI_arr = np.array(RI_list)
        CR_total = np.dot(w_c, CI_arr) / np.dot(w_c, RI_arr)
        
        print(f"\n综合排序 CR_total={CR_total:.4f} {'✓' if CR_total<0.1 else '✗'}")
        ranking = np.argsort(-final_w)
        for rank, idx in enumerate(ranking):
            print(f"  第{rank+1}名: {self.alt_names[idx]} ({final_w[idx]:.4f})")
        
        return final_w


# 示例：旅游目的地选择
evaluator = AHPSystem()
evaluator.set_criteria(
    ['景色', '费用', '交通', '住宿'],
    [[1,1/2,4,3], [2,1,7,5], [1/4,1/7,1,1/2], [1/3,1/5,2,1]]
)

alt_mats = {
    '景色': [[1,1/2,3], [2,1,5], [1/3,1/5,1]],
    '费用': [[1,3,5], [1/3,1,2], [1/5,1/2,1]],
    '交通': [[1,1/3,1/5], [3,1,1/2], [5,2,1]],
    '住宿': [[1,1/2,3], [2,1,5], [1/3,1/5,1]],
}
evaluator.alt_names = ['桂林', '三亚', '昆明']
evaluator.alt_matrices = alt_mats

final = evaluator.evaluate()
```

---

## 十一、关键公式汇总

| 项目 | 公式 |
|------|------|
| 判断矩阵性质 | $a_{ij} > 0, \; a_{ij} = 1/a_{ji}, \; a_{ii} = 1$ |
| 特征值法 | $\mathbf{A}\mathbf{w} = \lambda_{\max} \mathbf{w}$ |
| 几何平均法 | $w_i = \left( \prod_j a_{ij} \right)^{1/n} / \sum_k \left( \prod_j a_{kj} \right)^{1/n}$ |
| 一致性指标 | $CI = (\lambda_{\max} - n) / (n - 1)$ |
| 一致性比率 | $CR = CI / RI$ |
| CR 判定 | $CR < 0.10$ |
| 总排序权重 | $W_i = \sum_j w_j^{(2)} w_{ij}^{(3)}$ |
| 总排序 CR | $\sum_j w_j^{(2)} CI_j / \sum_j w_j^{(2)} RI_j$ |
| 群组判断 | $a_{ij}^{\text{群}} = \left( \prod_{k} a_{ij}^{(k)} \right)^{1/K}$ |

