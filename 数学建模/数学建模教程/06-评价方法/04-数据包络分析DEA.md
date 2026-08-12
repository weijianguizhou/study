# 数据包络分析（DEA）

## 一、概述

数据包络分析（Data Envelopment Analysis，DEA）是由美国运筹学家 A. Charnes、W.W. Cooper 和 E. Rhodes 于 1978 年提出的一种效率评价方法。DEA 以**相对效率**概念为基础，利用线性规划技术评价具有多输入和多输出的决策单元（Decision Making Unit, DMU）之间的相对有效性。

核心思想：

- 每个被评价对象视为一个**决策单元（DMU）**
- 通过线性组合找到**效率前沿面**
- DMU 在前沿面上则为有效（效率值为 1），否则为无效
- 不需要预设生产函数的具体形式

优点：

- 无需知道输入输出之间的函数关系
- 无需对数据进行无量纲化处理
- 可同时处理多个输入和多个输出
- 能指出无效 DMU 的改进方向和改进量

## 二、基本模型

### 2.1 CCR 模型（固定规模报酬）

#### 包络形式（对偶模型）

设有 $n$ 个 DMU，每个 DMU 有 $m$ 种输入和 $s$ 种输出。对 DMU$_0$ 的评价模型为：

$$
\begin{aligned}
\min \quad & \theta \\
\text{s.t.} \quad & \sum_{j=1}^{n} \lambda_j x_{ij} \leq \theta \, x_{i0}, \quad i = 1, 2, \ldots, m \\
& \sum_{j=1}^{n} \lambda_j y_{rj} \geq y_{r0}, \quad r = 1, 2, \ldots, s \\
& \lambda_j \geq 0, \quad j = 1, 2, \ldots, n
\end{aligned}
$$

其中：

- $\theta$ 为 DMU$_0$ 的效率值
- $\lambda_j$ 为第 $j$ 个 DMU 的权重系数
- $x_{ij}$ 为第 $j$ 个 DMU 的第 $i$ 种输入
- $y_{rj}$ 为第 $j$ 个 DMU 的第 $r$ 种输出

#### 乘数形式（对偶模型）

$$
\begin{aligned}
\max \quad & \mathbf{u}^T \mathbf{y}_0 \\
\text{s.t.} \quad & \mathbf{v}^T \mathbf{x}_0 = 1 \\
& \mathbf{u}^T Y - \mathbf{v}^T X \leq \mathbf{0} \\
& \mathbf{u} \geq \mathbf{0}, \, \mathbf{v} \geq \mathbf{0}
\end{aligned}
$$

其中 $\mathbf{u}$ 为输出权重向量，$\mathbf{v}$ 为输入权重向量。

#### 效率判定

- $\theta = 1$：DMU 为 CCR 有效（技术有效）
- $\theta < 1$：DMU 为 CCR 无效

### 2.2 BCC 模型（可变规模报酬）

在 CCR 模型基础上增加凸性约束 $\sum_{j=1}^{n} \lambda_j = 1$：

$$
\begin{aligned}
\min \quad & \theta \\
\text{s.t.} \quad & \sum_{j=1}^{n} \lambda_j x_{ij} \leq \theta \, x_{i0}, \quad i = 1, \ldots, m \\
& \sum_{j=1}^{n} \lambda_j y_{rj} \geq y_{r0}, \quad r = 1, \ldots, s \\
& \sum_{j=1}^{n} \lambda_j = 1 \\
& \lambda_j \geq 0, \quad j = 1, \ldots, n
\end{aligned}
$$

BCC 模型评价的是**纯技术效率**。

#### 效率分解

$$
\text{规模效率} = \frac{\text{CCR 效率}}{\text{BCC 效率}} = \frac{\theta_{\text{CCR}}}{\theta_{\text{BCC}}}
$$

- 规模效率 $= 1$：规模报酬不变
- 规模效率 $< 1$：规模报酬可变

### 2.3 规模报酬状态判断

设 CCR 模型最优解为 $(\theta^*, \lambda^*)$，令 $S = \sum_{j=1}^{n} \lambda_j^*$：

- $S = 1$：规模报酬不变（CRS）
- $S < 1$：规模报酬递增（IRS）
- $S > 1$：规模报酬递减（DRS）

## 三、松弛变量与投影

### 3.1 松弛变量

引入松弛变量 $s_i^-$ 和 $s_r^+$：

$$
\begin{aligned}
\sum_{j=1}^{n} \lambda_j x_{ij} + s_i^- = \theta \, x_{i0} \\
\sum_{j=1}^{n} \lambda_j y_{rj} - s_r^+ = y_{r0}
\end{aligned}
$$

- $s_i^-$：输入冗余（可减少的输入量）
- $s_r^+$：输出不足（可增加的输出量）

### 3.2 投影分析

无效 DMU 在效率前沿面上的投影（目标值）：

$$
\hat{x}_{i0} = \theta^* x_{i0} - s_i^{-*}
$$

$$
\hat{y}_{r0} = y_{r0} + s_r^{+*}
$$

### 3.3 改进方向

输入指标的改进比例：

$$
\Delta x_{i0} = x_{i0} - \hat{x}_{i0} = (1 - \theta^*) x_{i0} + s_i^{-*}
$$

输出指标的改进量：

$$
\Delta y_{r0} = \hat{y}_{r0} - y_{r0} = s_r^{+*}
$$

## 四、Python 实现

### 4.1 基于 PuLP 的 DEA 求解

```python
import numpy as np
from scipy.optimize import linprog

def dea_ccr(inputs, outputs, dmu_index):
    """
    CCR-DEA 模型求解
    :param inputs: 输入矩阵 (n x m), n个DMU, m种输入
    :param outputs: 输出矩阵 (n x s), n个DMU, s种输出
    :param dmu_index: 要评价的 DMU 索引
    :return: 效率值, 权重, 松弛变量
    """
    n, m = inputs.shape
    _, s = outputs.shape
    
    # 目标函数系数 (min theta)
    c = np.zeros(n + m + s + 1)
    c[0] = 1  # theta
    
    # 等式约束: -theta * x_i0 + sum(lambda_j * x_ij) + s_minus = 0
    #           sum(lambda_j * y_rj) - s_plus = y_r0
    A_eq = np.zeros((m + s, n + m + s + 1))
    b_eq = np.zeros(m + s)
    
    x0 = inputs[dmu_index]
    y0 = outputs[dmu_index]
    
    for i in range(m):
        A_eq[i, 0] = -x0[i]  # -theta * x_i0
        for j in range(n):
            A_eq[i, j + 1] = inputs[j, i]  # lambda_j * x_ij
        A_eq[i, n + 1 + i] = 1  # s_i^-
    
    for r in range(s):
        A_eq[m + r, n + 1 + m + r] = -1  # -s_r^+
        for j in range(n):
            A_eq[m + r, j + 1] = outputs[j, r]  # lambda_j * y_rj
        b_eq[m + r] = y0[r]
    
    # 变量边界
    bounds = [(1e-6, None)]  # theta >= 0
    bounds += [(None, None)] * n  # lambda_j >= 0
    bounds += [(None, None)] * m  # s_i^- >= 0
    bounds += [(None, None)] * s  # s_r^+ >= 0
    
    result = linprog(c, A_eq=A_eq, b_eq=b_eq, bounds=bounds, method='highs')
    
    if result.success:
        theta = result.x[0]
        lambdas = result.x[1:n+1]
        s_minus = result.x[n+1:n+1+m]
        s_plus = result.x[n+1+m:]
        return theta, lambdas, s_minus, s_plus
    else:
        return None, None, None, None


def dea_bcc(inputs, outputs, dmu_index):
    """
    BCC-DEA 模型求解
    """
    n, m = inputs.shape
    _, s = outputs.shape
    
    # 目标函数
    c = np.zeros(n + m + s + 1)
    c[0] = 1
    
    # 等式约束（增加凸性约束）
    A_eq = np.zeros((m + s + 1, n + m + s + 1))
    b_eq = np.zeros(m + s + 1)
    
    x0 = inputs[dmu_index]
    y0 = outputs[dmu_index]
    
    for i in range(m):
        A_eq[i, 0] = -x0[i]
        for j in range(n):
            A_eq[i, j + 1] = inputs[j, i]
        A_eq[i, n + 1 + i] = 1
    
    for r in range(s):
        A_eq[m + r, n + 1 + m + r] = -1
        for j in range(n):
            A_eq[m + r, j + 1] = outputs[j, r]
        b_eq[m + r] = y0[r]
    
    # 凸性约束: sum(lambda_j) = 1
    for j in range(n):
        A_eq[m + s, j + 1] = 1
    b_eq[m + s] = 1
    
    bounds = [(1e-6, None)]
    bounds += [(None, None)] * n
    bounds += [(None, None)] * m
    bounds += [(None, None)] * s
    
    result = linprog(c, A_eq=A_eq, b_eq=b_eq, bounds=bounds, method='highs')
    
    if result.success:
        theta = result.x[0]
        lambdas = result.x[1:n+1]
        s_minus = result.x[n+1:n+1+m]
        s_plus = result.x[n+1+m:]
        return theta, lambdas, s_minus, s_plus
    else:
        return None, None, None, None


# 示例：银行分支机构效率评价
np.random.seed(42)
n_dmus = 8
n_inputs = 2  # 员工数, 营业面积
n_outputs = 2  # 贷款额, 存款额

inputs = np.array([
    [100, 500],
    [150, 600],
    [80,  400],
    [200, 800],
    [120, 550],
    [90,  450],
    [180, 700],
    [110, 520]
], dtype=float)

outputs = np.array([
    [5000, 8000],
    [6000, 9000],
    [4500, 7000],
    [7000, 10000],
    [5500, 8500],
    [4800, 7500],
    [6500, 9500],
    [5200, 8200]
], dtype=float)

dmu_names = [f'支行{i+1}' for i in range(n_dmus)]

print("CCR-DEA 效率评价结果")
print("=" * 60)
print(f"{'DMU':<8}{'CCR效率':<10}{'BCC效率':<10}{'规模效率':<10}{'状态':<10}")
print("-" * 60)

for i in range(n_dmus):
    theta_ccr, _, _, _ = dea_ccr(inputs, outputs, i)
    theta_bcc, _, _, _ = dea_bcc(inputs, outputs, i)
    
    if theta_ccr and theta_bcc:
        scale_eff = theta_ccr / theta_bcc if theta_bcc > 0 else 0
        status = '有效' if abs(theta_ccr - 1) < 0.001 else '无效'
        print(f"{dmu_names[i]:<8}{theta_ccr:<10.4f}{theta_bcc:<10.4f}"
              f"{scale_eff:<10.4f}{status:<10}")
```

### 4.2 超效率 DEA

```python
import numpy as np
from scipy.optimize import linprog

def super_efficiency_dea(inputs, outputs, dmu_index):
    """
    超效率 DEA 模型（Andersen & Petersen, 1993）
    有效 DMU 的效率值可以大于 1
    """
    n, m = inputs.shape
    _, s = outputs.shape
    
    c = np.zeros(n + m + s + 1)
    c[0] = 1
    
    A_eq = np.zeros((m + s, n + m + s + 1))
    b_eq = np.zeros(m + s)
    
    x0 = inputs[dmu_index]
    y0 = outputs[dmu_index]
    
    for i in range(m):
        A_eq[i, 0] = -x0[i]
        idx = 0
        for j in range(n):
            if j != dmu_index:
                A_eq[i, 1 + idx] = inputs[j, i]
                idx += 1
        A_eq[i, n + i] = 1
    
    for r in range(s):
        idx = 0
        for j in range(n):
            if j != dmu_index:
                A_eq[m + r, 1 + idx] = outputs[j, r]
                idx += 1
        A_eq[m + r, n + m + r] = -1
        b_eq[m + r] = y0[r]
    
    bounds = [(1e-6, None)]
    bounds += [(None, None)] * (n - 1)
    bounds += [(None, None)] * m
    bounds += [(None, None)] * s
    
    result = linprog(c, A_eq=A_eq, b_eq=b_eq, bounds=bounds, method='highs')
    
    if result.success:
        return result.x[0]
    return None


# 超效率评价
print("\n超效率 DEA 评价结果")
print("=" * 40)
for i in range(n_dmus):
    theta = super_efficiency_dea(inputs, outputs, i)
    if theta is not None:
        print(f"{dmu_names[i]}: {theta:.4f}")
```

## 五、Malmquist 生产率指数

### 5.1 基本概念

Malmquist 指数用于衡量不同时期的生产率变化：

$$
M = \frac{D^t(x^{t+1}, y^{t+1})}{D^t(x^t, y^t)} \cdot \frac{D^{t+1}(x^{t+1}, y^{t+1})}{D^{t+1}(x^t, y^t)}
$$

### 5.2 分解

$$
M = EC \times TC
$$

- $EC$（效率变化）：$EC = \frac{D^{t+1}(x^{t+1}, y^{t+1})}{D^t(x^t, y^t)}$
- $TC$（技术变化）：$TC = \sqrt{\frac{D^t(x^{t+1}, y^{t+1})}{D^{t+1}(x^{t+1}, y^{t+1})} \cdot \frac{D^t(x^t, y^t)}{D^{t+1}(x^t, y^t)}}$

- $M > 1$：生产率提高
- $M = 1$：生产率不变
- $M < 1$：生产率下降

## 六、实际案例：高校院系效率评价

```python
import numpy as np

def university_efficiency():
    """高校院系效率 DEA 评价"""
    
    departments = ['数学系', '物理系', '化学系', '生物系', 
                   '计算机系', '经济系', '文学系', '历史系']
    
    # 输入：教职工数, 科研经费(万元), 教学时数
    inputs = np.array([
        [45,  200, 1200],
        [50,  350, 1000],
        [40,  300, 1100],
        [35,  250, 900],
        [60,  500, 1500],
        [30,  150, 800],
        [25,  80,  700],
        [20,  60,  600]
    ], dtype=float)
    
    # 输出：发表论文数, 毕业生数, 科研获奖数
    outputs = np.array([
        [120, 200, 8],
        [150, 180, 12],
        [130, 160, 10],
        [90,  140, 6],
        [200, 250, 15],
        [80,  180, 5],
        [60,  150, 3],
        [40,  120, 2]
    ], dtype=float)
    
    n = len(departments)
    
    print("高校院系 DEA 效率评价")
    print("=" * 70)
    print(f"{'院系':<8}{'CCR效率':<10}{'BCC效率':<10}{'规模效率':<10}{'规模报酬':<10}")
    print("-" * 70)
    
    results = []
    for i in range(n):
        theta_ccr, lambdas_ccr, _, _ = dea_ccr(inputs, outputs, i)
        theta_bcc, lambdas_bcc, _, _ = dea_bcc(inputs, outputs, i)
        
        if theta_ccr and theta_bcc:
            scale_eff = theta_ccr / theta_bcc if theta_bcc > 0 else 0
            S = sum(lambdas_ccr) if lambdas_ccr is not None else 1
            
            if abs(S - 1) < 0.1:
                scale_status = '不变'
            elif S < 1:
                scale_status = '递增'
            else:
                scale_status = '递减'
            
            status = '有效' if abs(theta_ccr - 1) < 0.001 else '无效'
            
            print(f"{departments[i]:<8}{theta_ccr:<10.4f}{theta_bcc:<10.4f}"
                  f"{scale_eff:<10.4f}{scale_status:<10}")
            
            results.append({
                'name': departments[i],
                'ccr': theta_ccr,
                'bcc': theta_bcc,
                'scale': scale_eff,
                'status': status
            })
    
    # 汇总统计
    ccr_eff = sum(1 for r in results if r['status'] == '有效')
    print(f"\nCCR 有效院系数: {ccr_eff}/{n}")
    print(f"平均效率: {np.mean([r['ccr'] for r in results]):.4f}")

university_efficiency()
```

## 七、DEA 模型扩展

### 7.1 非径向模型（SBM）

松弛变量直接纳入目标函数的 SBM 模型：

$$
\min \quad \rho = 1 - \frac{1}{m} \sum_{i=1}^{m} \frac{s_i^-}{x_{i0}}
$$

$$
\text{s.t.} \quad x_0 = X\lambda + s^-, \quad y_0 = Y\lambda - s^+
$$

### 7.2 交叉效率 DEA

每个 DMU 使用自己的最优权重评价其他 DMU：

$$
E_{kj} = \frac{\sum_{r=1}^{s} u_r^* y_{rj}}{\sum_{i=1}^{m} v_i^* x_{ij}}
$$

交叉效率矩阵的第 $j$ 列平均值为 DMU$_j$ 的交叉效率得分。

### 7.3 三阶段 DEA

1. **第一阶段**：初始 DEA 分析
2. **第二阶段**：SFA 回归分析环境因素和随机噪声
3. **第三阶段**：调整后的 DEA 分析

## 八、注意事项

1. **DMU 数量要求**：通常要求 DMU 数量至少是输入输出指标总数的 2-3 倍
2. **指标选择**：输入输出指标应有明确的因果关系
3. **数据正值要求**：DEA 模型要求所有数据为正值
4. **效率值解释**：CCR 效率 1 不一定是真正的最优，只是相对有效
5. **规模报酬假设**：根据实际问题选择 CCR 或 BCC 模型

## 九、关键要点总结

| 要点 | 内容 |
|:--|:--|
| 核心思想 | 相对效率评价，前沿面分析 |
| CCR 模型 | 固定规模报酬，技术效率 |
| BCC 模型 | 可变规模报酬，纯技术效率 |
| 规模效率 | $SE = \theta_{CCR} / \theta_{BCC}$ |
| 松弛变量 | 输入冗余和输出不足 |
| 投影分析 | 无效 DMU 的改进方向 |
| 超效率 | 有效 DMU 进一步排序 |
| 数据要求 | DMU 数量 $\geq 2 \times (m + s)$ |

DEA 是评价多输入多输出系统效率的有力工具，特别适合于公共服务部门、教育机构、医院等的效率评价。在实际应用中，应结合具体问题选择合适的模型，并辅以投影分析为无效 DMU 提供改进建议。

## 跨领域关联
- **人工智能**：[[../../../../人工智能/机器学习与深度学习/1.机器学习概述|机器学习（效率前沿与 Pareto 最优）]]
- **计算机类**：[[../../../../计算机类/python学习/01-Python基础与数据类型|Python scipy.optimize.linprog 实现]] | [[../../../../计算机类/MATLAB学习/50-系统工程与总结|MATLAB linprog]]
