# 层次分析法（AHP）

## 一、概述

层次分析法（Analytic Hierarchy Process，AHP）是由美国运筹学家 Thomas L. Saaty 于 20 世纪 70 年代提出的一种**定性与定量相结合**的多准则决策方法。该方法将复杂的决策问题分解为若干层次和因素，通过两两比较的方式确定各因素的相对重要性，从而为决策提供量化依据。

AHP 的核心思想：

- 将复杂的决策问题**层次化**，构建层次结构模型
- 通过**两两比较**确定各因素的相对权重
- 通过**一致性检验**保证判断的逻辑合理性
- 综合各层信息得出最终决策

适用场景：

- 评价指标权重的确定
- 方案优选与排序
- 资源分配与配置
- 政策制定与评估

## 二、基本原理

### 2.1 层次结构模型

AHP 首先将决策问题分解为三个层次：

```
目标层（G）    ——决策的最终目的
    |
准则层（C）    ——评价的准则和标准
    |
方案层（P）    ——待选的备选方案
```

设目标层为 $G$，准则层包含 $n$ 个准则 $C_1, C_2, \ldots, C_n$，方案层包含 $m$ 个方案 $P_1, P_2, \ldots, P_m$。

### 2.2 构造判断矩阵

在每一层次上，对属于同一上层元素的下层元素进行两两比较，确定其相对重要性。Saaty 提出了 1-9 标度法：

| 标度 $a_{ij}$ | 含义 |
|:-:|:--|
| 1 | 两个因素同等重要 |
| 3 | 前者比后者稍微重要 |
| 5 | 前者比后者明显重要 |
| 7 | 前者比后者强烈重要 |
| 9 | 前者比后者极端重要 |
| 2, 4, 6, 8 | 上述相邻判断的中间值 |
| 倒数 | 若 $a_{ij} = k$，则 $a_{ji} = 1/k$ |

判断矩阵 $A$ 的形式为：

$$
A = \begin{pmatrix} 
a_{11} & a_{12} & \cdots & a_{1n} \\
a_{21} & a_{22} & \cdots & a_{2n} \\
\vdots & \vdots & \ddots & \vdots \\
a_{n1} & a_{n2} & \cdots & a_{nn}
\end{pmatrix}
$$

其中 $a_{ij}$ 表示因素 $i$ 相对于因素 $j$ 的重要性程度，且满足：

$$
a_{ij} > 0, \quad a_{ij} = \frac{1}{a_{ji}}, \quad a_{ii} = 1
$$

### 2.3 权重计算方法

#### 方法一：特征值法（精确方法）

求解判断矩阵 $A$ 的最大特征值 $\lambda_{\max}$ 及其对应的特征向量 $\mathbf{w}$：

$$
A \mathbf{w} = \lambda_{\max} \mathbf{w}
$$

将特征向量归一化后即为各因素的权重向量：

$$
w_i = \frac{w_i^*}{\sum_{j=1}^{n} w_j^*}
$$

#### 方法二：几何平均法（近似方法）

1. 计算判断矩阵每行元素的几何平均值：

$$
\bar{w}_i = \left( \prod_{j=1}^{n} a_{ij} \right)^{1/n}
$$

2. 归一化得到权重：

$$
w_i = \frac{\bar{w}_i}{\sum_{j=1}^{n} \bar{w}_j}
$$

#### 方法三：算术平均法（近似方法）

1. 将判断矩阵按列归一化：

$$
\bar{a}_{ij} = \frac{a_{ij}}{\sum_{k=1}^{n} a_{kj}}
$$

2. 按行求和并归一化：

$$
w_i = \frac{\sum_{j=1}^{n} \bar{a}_{ij}}{\sum_{k=1}^{n} \sum_{j=1}^{n} \bar{a}_{kj}}
$$

## 三、一致性检验

### 3.1 一致性的概念

完全一致的判断矩阵应满足：

$$
a_{ij} \cdot a_{jk} = a_{ik}, \quad \forall\, i, j, k
$$

此时 $\lambda_{\max} = n$，其余特征值均为 0。

### 3.2 一致性指标（CI）

$$
CI = \frac{\lambda_{\max} - n}{n - 1}
$$

- $CI = 0$：完全一致
- $CI$ 越大，不一致程度越严重

### 3.3 随机一致性指标（RI）

Saaty 通过大量随机试验给出了平均随机一致性指标：

| $n$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| $RI$ | 0 | 0 | 0.58 | 0.90 | 1.12 | 1.24 | 1.32 | 1.41 | 1.45 | 1.49 |

### 3.4 一致性比率（CR）

$$
CR = \frac{CI}{RI}
$$

- 当 $CR < 0.10$ 时，认为判断矩阵具有满意的一致性
- 当 $CR \geq 0.10$ 时，需要调整判断矩阵

### 3.5 不一致矩阵的修正

当判断矩阵不满足一致性要求时，可按以下步骤修正：

1. 找出最大不一致的元素对 $(i, j)$
2. 重新评估 $a_{ij}$ 的取值
3. 重新计算一致性比率
4. 重复直到 $CR < 0.10$

## 四、层次总排序

### 4.1 层次排序权重

设准则层对目标层的权重向量为 $\mathbf{w}^{(2)} = (w_1^{(2)}, w_2^{(2)}, \ldots, w_n^{(2)})^T$，方案层对各准则的权重矩阵为 $W^{(3)}$，则方案层对目标层的综合权重为：

$$
\mathbf{W} = W^{(3)} \cdot \mathbf{w}^{(2)}
$$

### 4.2 层次总排序一致性检验

设方案层对准则 $C_j$ 的一致性指标为 $CI_j$，随机一致性指标为 $RI_j$，则总排序的一致性比率：

$$
CR_{\text{总}} = \frac{\sum_{j=1}^{n} w_j^{(2)} \cdot CI_j}{\sum_{j=1}^{n} w_j^{(2)} \cdot RI_j}
$$

当 $CR_{\text{总}} < 0.10$ 时，总排序结果具有满意的一致性。

## 五、Python 实现

### 5.1 基本 AHP 计算

```python
import numpy as np

def ahp_calculation(matrix):
    """
    AHP 权重计算与一致性检验
    :param matrix: 判断矩阵 (n x n numpy array)
    :return: 权重向量, 最大特征值, CI, CR
    """
    n = matrix.shape[0]
    
    # 方法：特征值法
    eigenvalues, eigenvectors = np.linalg.eig(matrix)
    
    # 找最大特征值及其对应的特征向量
    max_idx = np.argmax(eigenvalues.real)
    lambda_max = eigenvalues[max_idx].real
    w = eigenvectors[:, max_idx].real
    
    # 归一化
    w = w / w.sum()
    
    # 一致性指标
    CI = (lambda_max - n) / (n - 1) if n > 1 else 0
    
    # 随机一致性指标表
    RI_table = {1: 0, 2: 0, 3: 0.58, 4: 0.90, 5: 1.12,
                6: 1.24, 7: 1.32, 8: 1.41, 9: 1.45, 10: 1.49}
    RI = RI_table.get(n, 1.49)
    
    # 一致性比率
    CR = CI / RI if RI > 0 else 0
    
    return w, lambda_max, CI, CR


def geometric_mean_method(matrix):
    """
    几何平均法计算权重
    """
    n = matrix.shape[0]
    row_geom = np.prod(matrix, axis=1) ** (1.0 / n)
    w = row_geom / row_geom.sum()
    return w


def arithmetic_mean_method(matrix):
    """
    算术平均法计算权重
    """
    n = matrix.shape[0]
    col_sum = matrix.sum(axis=0)
    normalized = matrix / col_sum
    w = normalized.sum(axis=1) / n
    return w


# 示例：准则层判断矩阵
A = np.array([
    [1,   1/2,   4,   3],
    [2,   1,     7,   5],
    [1/4, 1/7,   1,   1/2],
    [1/3, 1/5,   2,   1]
])

w, lambda_max, CI, CR = ahp_calculation(A)

print("=" * 50)
print("AHP 权重计算结果")
print("=" * 50)
print(f"权重向量:  {np.round(w, 4)}")
print(f"最大特征值: {lambda_max:.4f}")
print(f"CI:        {CI:.4f}")
print(f"CR:        {CR:.4f}")
print(f"一致性检验: {'通过' if CR < 0.1 else '未通过'}")
print("=" * 50)

# 验证：多种方法对比
w_geom = geometric_mean_method(A)
w_arith = arithmetic_mean_method(A)
print(f"\n几何平均法: {np.round(w_geom, 4)}")
print(f"算术平均法: {np.round(w_arith, 4)}")
```

### 5.2 完整 AHP 评价系统

```python
import numpy as np

class AHPEvaluator:
    """完整的层次分析法评价系统"""
    
    def __init__(self):
        self.criteria_matrix = None
        self.criteria_names = []
        self.alternatives_matrices = {}
        self.alternatives_names = []
    
    def set_criteria(self, names, matrix):
        """设置准则层判断矩阵"""
        self.criteria_names = names
        self.criteria_matrix = np.array(matrix, dtype=float)
    
    def set_alternatives(self, names, matrices):
        """
        设置方案层判断矩阵
        matrices: dict, {criterion_name: matrix}
        """
        self.alternatives_names = names
        for crit_name, mat in matrices.items():
            self.alternatives_matrices[crit_name] = np.array(mat, dtype=float)
    
    def _calc_weights(self, matrix):
        """计算权重和一致性指标"""
        n = matrix.shape[0]
        eigenvalues, eigenvectors = np.linalg.eig(matrix)
        max_idx = np.argmax(eigenvalues.real)
        lambda_max = eigenvalues[max_idx].real
        w = eigenvectors[:, max_idx].real
        w = w / w.sum()
        
        CI = (lambda_max - n) / (n - 1) if n > 1 else 0
        RI_table = {1: 0, 2: 0, 3: 0.58, 4: 0.90, 5: 1.12,
                    6: 1.24, 7: 1.32, 8: 1.41, 9: 1.45, 10: 1.49}
        RI = RI_table.get(n, 1.49)
        CR = CI / RI if RI > 0 else 0
        
        return w, lambda_max, CI, CR
    
    def evaluate(self):
        """执行完整的 AHP 评价"""
        # 1. 计算准则层权重
        w_criteria, lam, CI, CR = self._calc_weights(self.criteria_matrix)
        print("准则层权重计算:")
        print("-" * 40)
        for i, name in enumerate(self.criteria_names):
            print(f"  {name}: {w_criteria[i]:.4f}")
        print(f"  λ_max={lam:.4f}, CI={CI:.4f}, CR={CR:.4f}")
        print(f"  一致性检验: {'通过' if CR < 0.1 else '未通过'}\n")
        
        # 2. 计算方案层权重
        n_alt = len(self.alternatives_names)
        n_crit = len(self.criteria_names)
        W = np.zeros((n_alt, n_crit))
        
        CI_list = []
        RI_list = []
        
        print("方案层权重计算:")
        print("-" * 40)
        for j, crit_name in enumerate(self.criteria_names):
            mat = self.alternatives_matrices[crit_name]
            w_alt, lam, ci, cr = self._calc_weights(mat)
            W[:, j] = w_alt
            
            CI_list.append(ci)
            n_mat = mat.shape[0]
            RI_table = {1: 0, 2: 0, 3: 0.58, 4: 0.90, 5: 1.12,
                        6: 1.24, 7: 1.32, 8: 1.41, 9: 1.45, 10: 1.49}
            RI_list.append(RI_table.get(n_mat, 1.49))
            
            print(f"  准则 {crit_name}: CR={cr:.4f}, "
                  f"{'通过' if cr < 0.1 else '未通过'}")
        
        # 3. 综合权重
        final_weights = W @ w_criteria
        
        # 4. 总排序一致性检验
        RI_arr = np.array(RI_list)
        CI_arr = np.array(CI_list)
        CR_total = np.dot(w_criteria, CI_arr) / np.dot(w_criteria, RI_arr)
        
        print(f"\n综合权重计算:")
        print("-" * 40)
        results = list(zip(self.alternatives_names, final_weights))
        results.sort(key=lambda x: x[1], reverse=True)
        for rank, (name, weight) in enumerate(results, 1):
            print(f"  第{rank}名: {name} -> {weight:.4f}")
        print(f"\n总排序一致性比率 CR={CR_total:.4f}, "
              f"{'通过' if CR_total < 0.1 else '未通过'}")
        
        return results


# 使用示例：选择旅游目的地
evaluator = AHPEvaluator()

# 准则：景色、费用、交通、住宿
evaluator.set_criteria(
    ['景色', '费用', '交通', '住宿'],
    [
        [1,   1/2,   4,   3],
        [2,   1,     7,   5],
        [1/4, 1/7,   1,   1/2],
        [1/3, 1/5,   2,   1]
    ]
)

# 方案：桂林、三亚、昆明
evaluator.set_alternatives(
    ['桂林', '三亚', '昆明'],
    {
        '景色': [
            [1,   1/2,   3],
            [2,   1,     5],
            [1/3, 1/5,   1]
        ],
        '费用': [
            [1,   3,     5],
            [1/3, 1,     2],
            [1/5, 1/2,   1]
        ],
        '交通': [
            [1,   1/3,   1/5],
            [3,   1,     1/2],
            [5,   2,     1]
        ],
        '住宿': [
            [1,   1/2,   3],
            [2,   1,     5],
            [1/3, 1/5,   1]
        ]
    }
)

results = evaluator.evaluate()
```

## 六、实际案例：城市宜居性评价

### 6.1 问题描述

评价 4 座城市的宜居性，准则包括：经济发展、教育水平、医疗条件、生态环境。

### 6.2 判断矩阵构建

假设专家判断如下（准则层对目标层）：

$$
A_{\text{准则}} = \begin{pmatrix}
1 & 1/2 & 2 & 1/3 \\
2 & 1 & 3 & 1/2 \\
1/2 & 1/3 & 1 & 1/4 \\
3 & 2 & 4 & 1
\end{pmatrix}
$$

```python
import numpy as np

# 城市评价示例
criteria_matrix = np.array([
    [1,     1/2,   2,     1/3],
    [2,     1,     3,     1/2],
    [1/2,   1/3,   1,     1/4],
    [3,     2,     4,     1]
])

# 各准则下的城市比较矩阵
economy_matrix = np.array([
    [1,   2,   3,   4],
    [1/2, 1,   2,   3],
    [1/3, 1/2, 1,   2],
    [1/4, 1/3, 1/2, 1]
])

education_matrix = np.array([
    [1,   1/2, 1/3, 2],
    [2,   1,   1/2, 3],
    [3,   2,   1,   4],
    [1/2, 1/3, 1/4, 1]
])

medical_matrix = np.array([
    [1,   3,   2,   5],
    [1/3, 1,   1/2, 2],
    [1/2, 2,   1,   3],
    [1/5, 1/2, 1/3, 1]
])

ecology_matrix = np.array([
    [1,   1/4, 1/3, 1/2],
    [4,   1,   2,   3],
    [3,   1/2, 1,   2],
    [2,   1/3, 1/2, 1]
])

# 计算各矩阵权重
def calc_weight(matrix):
    eigenvalues, eigenvectors = np.linalg.eig(matrix)
    max_idx = np.argmax(eigenvalues.real)
    w = eigenvectors[:, max_idx].real
    return w / w.sum()

w_criteria = calc_weight(criteria_matrix)
w_eco = calc_weight(economy_matrix)
w_edu = calc_weight(education_matrix)
w_med = calc_weight(medical_matrix)
w_eco = calc_weight(ecology_matrix)

# 综合评价矩阵
W = np.column_stack([w_eco, w_edu, w_med, w_eco])
final = W @ w_criteria

cities = ['北京', '上海', '广州', '成都']
print("城市宜居性评价结果:")
for city, score in zip(cities, final):
    print(f"  {city}: {score:.4f}")
```

## 七、AHP 的扩展方法

### 7.1 群组 AHP

多位专家分别给出判断矩阵，取几何平均：

$$
a_{ij}^{\text{群}} = \left( \prod_{k=1}^{K} a_{ij}^{(k)} \right)^{1/K}
$$

其中 $K$ 为专家人数，$a_{ij}^{(k)}$ 为第 $k$ 位专家的判断值。

### 7.2 模糊 AHP

将精确的标度扩展为区间数或三角模糊数：

$$
\tilde{a}_{ij} = (l_{ij}, m_{ij}, u_{ij})
$$

利用模糊数的运算规则进行权重计算。

### 7.3 最小二乘法 AHP

通过最小化残差来求解权重：

$$
\min \sum_{i=1}^{n} \sum_{j=1}^{n} \left( a_{ij} - \frac{w_i}{w_j} \right)^2
$$

## 八、注意事项与局限性

### 8.1 优点

- 结构清晰，易于理解和操作
- 适合处理定性与定量混合的问题
- 具有数学理论支撑
- 一致性检验保证了判断的合理性

### 8.2 局限性

- 当指标过多时（$n > 9$），判断矩阵难以保持一致性
- 1-9 标度较为粗糙，主观性较强
- 只能处理层次结构的问题
- 权重可能受到极端值的影响

### 8.3 使用建议

- 指标数量控制在 $2 \leq n \leq 9$
- 当判断矩阵不一致时，不要强行修正，而应重新审视判断
- 可与其他方法（如熵权法）结合使用，减少主观性
- 群组决策时，建议采用几何平均法整合专家意见

## 九、关键要点总结

| 要点 | 内容 |
|:--|:--|
| 核心思想 | 分层、比较、综合 |
| 1-9 标度 | 定量描述两两比较的相对重要性 |
| 一致性检验 | $CR < 0.10$ 为满意一致性 |
| 权重计算 | 特征值法最精确，几何平均法最简便 |
| 总排序检验 | 需要对层次总排序进行一致性检验 |
| 适用规模 | 准则数 $n$ 不超过 9 |
| 典型应用 | 方案选优、指标权重确定、资源分配 |

AHP 是数学建模竞赛中最常用的基础评价方法之一，掌握其原理和实现对于解决实际评价问题具有重要意义。在实际应用中，建议将 AHP 与其他客观赋权方法结合使用，以获得更为合理和稳健的评价结果。
