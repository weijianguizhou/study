# K-means 聚类算法

## 1. 算法概述

K-means 是一种经典的**无监督学习**算法，用于将 $n$ 个数据点划分为 $K$ 个簇（cluster），使每个数据点属于距其最近的簇中心（centroid）对应的簇。该算法的目标是最小化簇内平方误差和（Within-Cluster Sum of Squares, WCSS）。

### 核心思想

给定数据集 $X = \{x_1, x_2, \dots, x_n\}$，其中 $x_i \in \mathbb{R}^d$，K-means 试图找到 $K$ 个簇中心 $\mu_1, \mu_2, \dots, \mu_K$，使得目标函数最小化：

$$J = \sum_{k=1}^{K} \sum_{x_i \in C_k} \| x_i - \mu_k \|^2$$

其中 $C_k$ 表示第 $k$ 个簇中数据点的集合，$\mu_k$ 是簇 $C_k$ 的中心（均值）。

---

## 2. 算法流程

### 2.1 基本步骤

K-means 算法采用**迭代优化**策略，交替执行以下两个步骤：

**步骤 1：分配（Assignment Step）**

将每个数据点分配到距其最近的簇中心：

$$C_k = \{ x_i : \| x_i - \mu_k \| \leq \| x_i - \mu_j \|, \quad \forall j = 1, \dots, K \}$$

**步骤 2：更新（Update Step）**

重新计算每个簇的中心：

$$\mu_k = \frac{1}{|C_k|} \sum_{x_i \in C_k} x_i$$

**步骤 3：收敛判断**

重复步骤 1 和步骤 2，直到簇中心不再发生变化（或变化小于阈值 $\epsilon$），或达到最大迭代次数。

### 2.2 完整伪代码

```
输入: 数据集 X, 簇数 K
输出: 簇分配结果 C, 簇中心 μ

1. 随机初始化 K 个簇中心 μ_1, μ_2, ..., μ_K
2. repeat:
3.   for each x_i in X do:
4.     j = argmin_k ||x_i - μ_k||^2
5.     将 x_i 分配到簇 C_j
6.   end for
7.   for each cluster k = 1, ..., K do:
8.     μ_k = (1/|C_k|) * Σ_{x_i ∈ C_k} x_i
9.   end for
10. until μ_k 不再变化 or 达到最大迭代次数
```

---

## 3. K-means 的数学性质

### 3.1 期望最大化（EM）视角

K-means 可以看作高斯混合模型（GMM）在协方差矩阵 $\Sigma = \sigma^2 I$ 且 $\sigma \to 0$ 时的特例。从 EM 角度看：

- **E 步**（分配）：计算每个数据点对各簇的后验概率，在硬聚类下退化为最近中心分配
- **M 步**（更新）：最大化期望对数似然，得到簇中心为均值

### 3.2 Lloyd 算法的收敛性

K-means 算法（Lloyd 算法）保证：

1. 每次迭代目标函数 $J$ **单调不增**
2. 由于 $J$ 有下界（$J \geq 0$），算法必然在**有限步内收敛**
3. 收敛到的可能是**局部最优**，而非全局最优

### 3.3 时间复杂度

| 复杂度类型 | 值 |
|-----------|-----|
| 单次迭代 | $O(nKd)$ |
| 总复杂度 | $O(nKdT)$ |
| 空间复杂度 | $O(nK + nd)$ |

其中 $n$ 为数据点数，$K$ 为簇数，$d$ 为维度，$T$ 为迭代次数。

---

## 4. 簇数选择方法

### 4.1 肘部法则（Elbow Method）

肘部法通过绘制不同 $K$ 值下的 WCSS 曲线来选择最佳簇数：

$$WCSS(K) = \sum_{k=1}^{K} \sum_{x_i \in C_k} \| x_i - \mu_k \|^2$$

随着 $K$ 增大，WCSS 单调递减。当 $K$ 达到某个值后，WCSS 的下降幅度明显减缓，形成"肘部"，该点即为推荐的 $K$ 值。

### 4.2 轮廓系数（Silhouette Score）

轮廓系数综合衡量了簇的**凝聚度**和**分离度**。对每个数据点 $x_i$：

$$s(i) = \frac{b(i) - a(i)}{\max\{a(i), b(i)\}}$$

其中：
- $a(i)$：$x_i$ 到同簇其他点的平均距离（**簇内紧凑度**）
- $b(i)$：$x_i$ 到最近其他簇中所有点的平均距离（**簇间分离度**）

$$a(i) = \frac{1}{|C_k| - 1} \sum_{x_j \in C_k, j \neq i} \| x_i - x_j \|$$

$$b(i) = \min_{l \neq k} \frac{1}{|C_l|} \sum_{x_j \in C_l} \| x_i - x_j \|$$

轮廓系数的取值范围为 $[-1, 1]$：

| 值域 | 含义 |
|------|------|
| $s(i) \approx 1$ | 数据点远离相邻簇，聚类效果好 |
| $s(i) \approx 0$ | 数据点在两个簇的边界上 |
| $s(i) \approx -1$ | 数据点被错误分配到当前簇 |

全局轮廓系数为所有点轮廓系数的均值：$S = \frac{1}{n}\sum_{i=1}^{n} s(i)$

### 4.3 Gap Statistic

Gap Statistic 将实际 WCSS 与随机均匀分布数据的期望 WCSS 进行比较：

$$\text{Gap}(K) = E[\log(W_{K}^*)] - \log(W_K)$$

其中 $W_K^*$ 是随机参考数据集的 WCSS，选择使 $\text{Gap}(K)$ 最大的 $K$ 值。

---

## 5. 初始化策略

### 5.1 随机初始化的问题

K-means 的目标函数 $J$ 是非凸的，随机初始化可能导致较差的局部最优。如下图所示，不同的初始中心可能收敛到完全不同的结果。

### 5.2 K-means++ 初始化

K-means++ 通过概率加权选择初始中心，使得初始中心尽可能分散：

**算法步骤：**

1. 随机选择第一个中心 $\mu_1$ 从 $X$ 中
2. 对每个数据点 $x_i$，计算 $D(x_i) = \min_{k} \| x_i - \mu_k \|^2$
3. 以概率 $P(x_i) = \frac{D(x_i)^2}{\sum_{j=1}^{n} D(x_j)^2}$ 选择下一个中心
4. 重复步骤 2-3 直到选出 $K$ 个中心

**性质：** K-means++ 保证目标函数的期望值为 $O(\log K)$ 倍的最优值。

---

## 6. K-means 的变体

### 6.1 K-medoids（PAM）

用实际数据点（medoid）代替均值作为簇中心，对异常值更鲁棒：

$$J_{med} = \sum_{k=1}^{K} \sum_{x_i \in C_k} \| x_i - m_k \|$$

其中 $m_k \in C_k$ 是第 $k$ 个簇的 medoid。

### 6.2 Mini-batch K-means

每次迭代使用小批量（mini-batch）数据更新中心，加速大规模数据聚类：

$$\mu_k \leftarrow \mu_k + \eta (x_i - \mu_k)$$

其中 $\eta$ 为学习率，通常取 $\eta = \frac{1}{N_k}$（$N_k$ 为已分配到簇 $k$ 的样本数）。

### 6.3 Bisecting K-means（二分 K-means）

自顶向下的层次化 K-means：

1. 初始时将所有数据作为一个簇
2. 选择当前簇中 SSE 最大的进行二分（$K=2$ 的 K-means）
3. 重复直到达到 $K$ 个簇

### 6.4 K-means 与球面聚类

对归一化后的向量数据，可以使用余弦距离的 K-means 变体：

$$\mu_k = \frac{\sum_{x_i \in C_k} x_i}{\left\| \sum_{x_i \in C_k} x_i \right\|}$$

---

## 7. Python 实现

### 7.1 基本 K-means

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
from sklearn.datasets import make_blobs
from sklearn.metrics import silhouette_score, silhouette_samples
from sklearn.preprocessing import StandardScaler

X, y_true = make_blobs(n_samples=300, centers=4, cluster_std=0.60, random_state=0)

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

kmeans = KMeans(n_clusters=4, init='k-means++', n_init=10, max_iter=300, random_state=42)
y_pred = kmeans.fit_predict(X_scaled)

print(f"惯性 (Inertia): {kmeans.inertia_:.2f}")
print(f"轮廓系数: {silhouette_score(X_scaled, y_pred):.4f}")

fig, ax = plt.subplots(figsize=(8, 6))
scatter = ax.scatter(X_scaled[:, 0], X_scaled[:, 1], c=y_pred, cmap='viridis', s=50, alpha=0.7)
centers = kmeans.cluster_centers_
ax.scatter(centers[:, 0], centers[:, 1], c='red', marker='X', s=200, edgecolors='black', label='聚类中心')
ax.set_title('K-means 聚类结果')
ax.legend()
plt.tight_layout()
plt.show()
```

### 7.2 肘部法则选择 K

```python
inertias = []
sil_scores = []
K_range = range(2, 11)

for k in K_range:
    km = KMeans(n_clusters=k, init='k-means++', n_init=10, random_state=42)
    km.fit(X_scaled)
    inertias.append(km.inertia_)
    sil_scores.append(silhouette_score(X_scaled, km.labels_))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

ax1.plot(K_range, inertias, 'bo-', linewidth=2, markersize=8)
ax1.set_xlabel('簇数 K')
ax1.set_ylabel('WCSS (惯性)')
ax1.set_title('肘部法则')
ax1.grid(True, alpha=0.3)

ax2.plot(K_range, sil_scores, 'rs-', linewidth=2, markersize=8)
ax2.set_xlabel('簇数 K')
ax2.set_ylabel('轮廓系数')
ax2.set_title('轮廓系数法')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.show()
```

### 7.3 轮廓系数可视化

```python
def plot_silhouette(X, labels, n_clusters):
    silhouette_avg = silhouette_score(X, labels)
    sample_silhouette_values = silhouette_samples(X, labels)

    fig, ax = plt.subplots(figsize=(8, 6))
    y_lower = 10
    for i in range(n_clusters):
        cluster_values = sample_silhouette_values[labels == i]
        cluster_values.sort()
        size_cluster = cluster_values.shape[0]
        y_upper = y_lower + size_cluster
        color = plt.cm.viridis(float(i) / n_clusters)
        ax.fill_betweenx(np.arange(y_lower, y_upper), 0, cluster_values, facecolor=color, alpha=0.7)
        ax.text(-0.05, y_lower + 0.5 * size_cluster, str(i))
        y_lower = y_upper + 10

    ax.axvline(x=silhouette_avg, color='red', linestyle='--', label=f'平均轮廓系数: {silhouette_avg:.3f}')
    ax.set_xlabel('轮廓系数值')
    ax.set_ylabel('簇标签')
    ax.set_title('轮廓系数图')
    ax.legend()
    plt.tight_layout()
    plt.show()

best_k = K_range[np.argmax(sil_scores)]
print(f"最佳簇数 K = {best_k}")
```

### 7.4 肘部法则完整封装

```python
class ElbowMethod:
    def __init__(self, X, k_range=range(2, 11)):
        self.X = X
        self.k_range = k_range
        self.inertias = []
        self.sil_scores = []
        self.davies_bouldin = []

    def compute(self):
        from sklearn.metrics import davies_bouldin_score
        for k in self.k_range:
            km = KMeans(n_clusters=k, init='k-means++', n_init=10, random_state=42)
            labels = km.fit_predict(self.X)
            self.inertias.append(km.inertia_)
            self.sil_scores.append(silhouette_score(self.X, labels))
            self.davies_bouldin.append(davies_bouldin_score(self.X, labels))
        return self

    def best_k_by_silhouette(self):
        return list(self.k_range)[np.argmax(self.sil_scores)]

    def plot(self):
        fig, axes = plt.subplots(1, 3, figsize=(18, 5))
        axes[0].plot(self.k_range, self.inertias, 'bo-')
        axes[0].set_title('肘部法则 (WCSS)')
        axes[0].set_xlabel('K')
        axes[0].set_ylabel('Inertia')

        axes[1].plot(self.k_range, self.sil_scores, 'rs-')
        axes[1].set_title('轮廓系数 (越大越好)')
        axes[1].set_xlabel('K')

        axes[2].plot(self.k_range, self.davies_bouldin, 'g^-')
        axes[2].set_title('Davies-Bouldin 指数 (越小越好)')
        axes[2].set_xlabel('K')

        plt.tight_layout()
        plt.show()
```

---

## 8. 实际案例：客户细分

```python
import pandas as pd
from sklearn.preprocessing import StandardScaler

np.random.seed(42)
n_customers = 500
data = pd.DataFrame({
    '年消费额': np.concatenate([
        np.random.normal(5000, 1000, 200),
        np.random.normal(15000, 2000, 180),
        np.random.normal(50000, 8000, 120)
    ]),
    '访问频次': np.concatenate([
        np.random.poisson(5, 200),
        np.random.poisson(15, 180),
        np.random.poisson(30, 120)
    ]),
    '平均停留时长': np.concatenate([
        np.random.normal(10, 3, 200),
        np.random.normal(25, 5, 180),
        np.random.normal(45, 10, 120)
    ])
})

scaler = StandardScaler()
X_scaled = scaler.fit_transform(data)

em = ElbowMethod(X_scaled, k_range=range(2, 9)).compute()
em.plot()
best_k = em.best_k_by_silhouette()
print(f"推荐簇数: {best_k}")

kmeans_final = KMeans(n_clusters=best_k, init='k-means++', n_init=10, random_state=42)
data['客户类型'] = kmeans_final.fit_predict(X_scaled)

print(data.groupby('客户类型').mean())
```

---

## 9. K-means 的优缺点

### 优点

1. 算法简单，易于实现和理解
2. 时间复杂度较低，适用于大规模数据
3. 对球形簇效果好
4. 可扩展性强（Mini-batch 变体）

### 缺点

1. 需要预先指定 $K$ 值
2. 对初始中心敏感（K-means++ 可缓解）
3. 对异常值敏感
4. 只能发现球形簇，无法处理任意形状
5. 不适用于簇大小差异悬殊的情况

---

## 10. 关键要点总结

| 要点 | 说明 |
|------|------|
| 目标函数 | 最小化簇内平方误差和 $J = \sum_{k=1}^{K}\sum_{x_i \in C_k}\|x_i - \mu_k\|^2$ |
| 核心步骤 | 分配 → 更新 → 收敛判断 |
| K 值选择 | 肘部法、轮廓系数、Gap Statistic |
| 初始化 | K-means++ 优于随机初始化 |
| 时间复杂度 | $O(nKdT)$，$T$ 为迭代次数 |
| 适用场景 | 簇形状近似球形、维度不高的数据 |
| 不适用场景 | 非球形簇、噪声数据多、簇大小悬殊 |
| 关键局限 | 只能保证局部最优，对初始化敏感 |

K-means 作为最基础的聚类算法，是理解更复杂聚类方法的起点。在实际应用中，通常需要结合数据特点和业务需求，选择合适的聚类方法。
