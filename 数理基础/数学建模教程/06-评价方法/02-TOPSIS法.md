# TOPSIS 法

> **理论基础** → 参见 [[../../统计学分析方法/优劣解距离法（TOPSIS）|TOPSIS理论]]

TOPSIS法通过计算各方案与正负理想解的距离进行排序，是最直观易用的多属性决策方法之一。

## 三、完整计算步骤
1. **构建原始决策矩阵** $X_{m \times n}$
2. **指标正向化处理**：将所有指标统一为效益型
3. **向量标准化**：消除量纲影响
4. **确定指标权重**：可用 AHP、熵权法等
5. **构造加权标准化矩阵**
6. **确定正理想解和负理想解**
7. **计算各方案到正负理想解的距离**
8. **计算相对贴近度并排序**

## 四、Python 实现
### 4.1 基本 TOPSIS 算法

```python
import numpy as np

class TOPSIS:
    """TOPSIS 综合评价方法"""
    
    def __init__(self, decision_matrix, weights, cost_indices=None):
        """
        :param decision_matrix: 原始决策矩阵 (m x n)
        :param weights: 指标权重向量 (长度为 n)
        :param cost_indices: 成本型指标的索引列表
        """
        self.raw = np.array(decision_matrix, dtype=float)
        self.weights = np.array(weights, dtype=float)
        self.weights = self.weights / self.weights.sum()
        self.cost_indices = cost_indices if cost_indices else []
        self.m, self.n = self.raw.shape
    
    def normalize(self):
        """向量标准化"""
        norm = np.sqrt((self.raw ** 2).sum(axis=0))
        self.norm_matrix = self.raw / norm
        return self.norm_matrix
    
    def weight_normalize(self):
        """加权标准化"""
        self.normalize()
        self.weighted = self.norm_matrix * self.weights
        return self.weighted
    
    def ideal_solutions(self):
        """确定正负理想解"""
        self.weight_normalize()
        
        # 正理想解
        self.A_plus = np.zeros(self.n)
        # 负理想解
        self.A_minus = np.zeros(self.n)
        
        for j in range(self.n):
            if j in self.cost_indices:
                # 成本型：取最小为正理想
                self.A_plus[j] = self.weighted[:, j].min()
                self.A_minus[j] = self.weighted[:, j].max()
            else:
                # 效益型：取最大为正理想
                self.A_plus[j] = self.weighted[:, j].max()
                self.A_minus[j] = self.weighted[:, j].min()
        
        return self.A_plus, self.A_minus
    
    def distances(self):
        """计算欧氏距离"""
        self.ideal_solutions()
        
        D_plus = np.sqrt(((self.weighted - self.A_plus) ** 2).sum(axis=1))
        D_minus = np.sqrt(((self.weighted - self.A_minus) ** 2).sum(axis=1))
        
        return D_plus, D_minus
    
    def closeness_coefficient(self):
        """计算相对贴近度"""
        D_plus, D_minus = self.distances()
        
        # 防止分母为零
        self.C = D_minus / (D_plus + D_minus + 1e-10)
        return self.C
    
    def rank(self):
        """排序并返回结果"""
        C = self.closeness_coefficient()
        ranking = np.argsort(-C)  # 降序排列
        return ranking, C

# 使用示例
decision_matrix = [
    [85, 90, 78, 92],
    [78, 85, 88, 80],
    [92, 75, 82, 88],
    [88, 82, 90, 85],
    [75, 92, 85, 90]
]

weights = [0.3, 0.25, 0.25, 0.2]
cost_indices = []  # 所有指标都是效益型

topsis = TOPSIS(decision_matrix, weights, cost_indices)
ranking, scores = topsis.rank()

print("TOPSIS 评价结果:")
print("-" * 40)
for rank_idx, i in enumerate(ranking):
    print(f"  第{rank_idx + 1}名: 方案{i+1}, 贴近度={scores[i]:.4f}")
```

### 4.2 带熵权法的 TOPSIS

```python
import numpy as np

def entropy_weight(matrix):
    """熵权法计算指标权重"""
    m, n = matrix.shape
    # 归一化
    P = matrix / matrix.sum(axis=0)
    # 计算信息熵
    k = 1 / np.log(m)
    E = -k * (P * np.log(P + 1e-10)).sum(axis=0)
    # 计算权重
    D = 1 - E
    w = D / D.sum()
    return w

def topsis_with_entropy(data, cost_indices=None):
    """TOPSIS + 熵权法"""
    data = np.array(data, dtype=float)
    
    # 熵权法确定权重
    weights = entropy_weight(data)
    print(f"熵权法权重: {np.round(weights, 4)}")
    
    # TOPSIS 评价
    evaluator = TOPSIS(data, weights, cost_indices)
    ranking, scores = evaluator.rank()
    
    return ranking, scores, weights

# 示例：学生综合评价
scores_data = [
    [85, 90, 78, 92, 88],
    [78, 85, 88, 80, 82],
    [92, 75, 82, 88, 90],
    [88, 82, 90, 85, 78],
    [75, 92, 85, 90, 85],
    [90, 88, 80, 78, 92]
]

ranking, scores, w = topsis_with_entropy(scores_data)
print("\n学生综合评价排名:")
for rank, idx in enumerate(ranking):
    print(f"  第{rank+1}名: 学生{idx+1}, 得分={scores[idx]:.4f}")
```

## 五、实际案例：供应商评价
### 5.1 问题描述

某企业需要从 5 家供应商中选择最优供应商，评价指标包括：

| 指标 | 类型 | 权重 |
|:--|:--|:-:|
| 产品质量 | 效益型 | 0.30 |
| 价格 | 成本型 | 0.25 |
| 交货期 | 成本型 | 0.20 |
| 服务水平 | 效益型 | 0.15 |
| 技术能力 | 效益型 | 0.10 |

### 5.2 完整计算

```python
import numpy as np

# 供应商评价数据
suppliers = ['供应商A', '供应商B', '供应商C', '供应商D', '供应商E']
indicators = ['质量', '价格', '交货期', '服务', '技术']

# 原始数据: [质量(分), 价格(万元), 交货期(天), 服务(分), 技术(分)]
X = np.array([
    [90, 12, 15, 85, 88],
    [85, 10, 10, 90, 82],
    [88, 14, 12, 80, 90],
    [82, 9,  18, 88, 85],
    [92, 13, 8,  82, 92]
])

weights = np.array([0.30, 0.25, 0.20, 0.15, 0.10])
cost_indices = [1, 2]  # 价格和交货期为成本型

# Step 1: 向量标准化
norm = np.sqrt((X ** 2).sum(axis=0))
R = X / norm

# Step 2: 加权标准化
V = R * weights

# Step 3: 正负理想解
A_plus = np.zeros(5)
A_minus = np.zeros(5)
for j in range(5):
    if j in cost_indices:
        A_plus[j] = V[:, j].min()
        A_minus[j] = V[:, j].max()
    else:
        A_plus[j] = V[:, j].max()
        A_minus[j] = V[:, j].min()

# Step 4: 距离计算
D_plus = np.sqrt(((V - A_plus) ** 2).sum(axis=1))
D_minus = np.sqrt(((V - A_minus) ** 2).sum(axis=1))

# Step 5: 贴近度
C = D_minus / (D_plus + D_minus)

# Step 6: 排序
ranking = np.argsort(-C)

print("供应商评价结果:")
print("=" * 50)
print(f"{'排名':<6}{'供应商':<10}{'贴近度':<10}{'D+':<12}{'D-':<12}")
print("-" * 50)
for rank, i in enumerate(ranking):
    print(f"{rank+1:<6}{suppliers[i]:<10}{C[i]:<10.4f}{D_plus[i]:<12.4f}{D_minus[i]:<12.4f}")

print(f"\n最优供应商: {suppliers[ranking[0]]}")
```

## 七、与其他方法的比较
| 特征 | TOPSIS | AHP | 熵权法 |
|:--|:--|:--|:--|
| 权重来源 | 外部给定/熵权法 | 专家打分 | 数据驱动 |
| 主客观性 | 客观 | 主观 | 客观 |
| 数据要求 | 需要精确数值 | 只需两两比较 | 需要精确数值 |
| 计算复杂度 | 低 | 中 | 低 |
| 排序能力 | 强 | 中 | 弱（仅权重） |

## 八、注意事项
1. **指标正向化**：评价前必须将所有指标统一为效益型（越大越好）
2. **标准化方法选择**：向量标准化保留了原始数据的相对关系，是最常用的方法
3. **权重确定**：权重对结果影响很大，建议用熵权法或 AHP 结合确定
4. **异常值处理**：极端值可能影响正负理想解的确定，需要预处理
5. **评价指标数量**：指标过多可能导致各方案贴近度趋于均匀，建议控制在 5-10 个

## 九、关键要点总结
| 要点 | 内容 |
|:--|:--|
| 核心思想 | 最接近正理想解、最远离负理想解 |
| 标准化方法 | 向量标准化 $r_{ij} = x_{ij} / \sqrt{\sum x_{ij}^2}$ |
| 贴近度公式 | $C_i = D_i^- / (D_i^+ + D_i^-)$ |
| 指标处理 | 效益型取最大，成本型取最小 |
| 权重来源 | AHP、熵权法、CRITIC 等 |
| 排序依据 | $C_i$ 越大越优 |
| 优势 | 计算简单、含义明确、适用性广 |
| 局限 | 对数据标准化方式敏感、不考虑指标间相关性 |

TOPSIS 是一种高效、直观的多属性决策方法，在数学建模中应用广泛。掌握其基本原理和实现方法，结合合适的权重确定手段，可以解决大多数综合评价问题。
