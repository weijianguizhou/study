# DBSCAN 密度聚类算法

## 1. 算法概述

DBSCAN（Density-Based Spatial Clustering of Applications with Noise）是一种基于**密度**的聚类算法，由 Martin Ester 等人于 1996 年提出。与 K-means 和层次聚类不同，DBSCAN 不假设簇的形状，能够发现**任意形状**的簇，并能有效识别**噪声点**（异常值）。

### 核心思想

DBSCAN 的核心思想是：**簇是由密度可达的点组成的最大集合**。高密度区域被低密度区域分隔，形成不同的簇。

### 与基于距离的聚类的区别

| 特性 | K-means | DBSCAN |
|------|---------|--------|
| 簇形状 | 球形 | 任意形状 |
| 需要指定 $K$ | 是 | 否 |
| 噪声处理 | 所有点都必须归属某个簇 | 可识别噪声点 |
| 对异常值 | 敏感 | 较鲁棒 |
| 变密度簇 | 可能效果不好 | 基本参数下也不擅长 |

---

## 2. 基本概念

### 2.1 $\epsilon$-邻域

点 $x_i$ 的 $\epsilon$-邻域定义为：

$$N_\epsilon(x_i) = \{ x_j \in X : d(x_i, x_j) \leq \epsilon \}$$

其中 $\epsilon > 0$ 是邻域半径参数，$d(\cdot, \cdot)$ 是距离度量。

### 2.2 核心点（Core Point）

如果点 $x_i$ 的 $\epsilon$-邻域内至少包含 $\text{MinPts}$ 个数据点（包括自身），则 $x_i$ 是核心点：

$$|N_\epsilon(x_i)| \geq \text{MinPts}$$

### 2.3 边界点（Border Point）

- $x_i$ 不是核心点（即 $|N_\epsilon(x_i)| < \text{MinPts}$）
- 但 $x_i$ 位于某个核心点的 $\epsilon$-邻域内

即：存在核心点 $x_j$ 使得 $x_i \in N_\epsilon(x_j)$。

### 2.4 噪声点（Noise Point）

既不是核心点也不是边界点的数据点：

$$x_i \text{ 是噪声点} \Leftrightarrow x_i \notin \text{核心点} \cup \text{边界点}$$

---

## 3. 密度可达与密度相连

### 3.1 密度直达（Directly Density-Reachable）

如果点 $x_j$ 在核心点 $x_i$ 的 $\epsilon$-邻域内，则称 $x_j$ 从 $x_i$ **密度直达**：

$$x_j \text{ 从 } x_i \text{ 密度直达} \Leftrightarrow x_j \in N_\epsilon(x_i) \wedge |N_\epsilon(x_i)| \geq \text{MinPts}$$

**注意：** 密度直达关系是非对称的。如果 $x_j$ 是边界点，则 $x_j$ 不能密度直达其他点。

### 3.2 密度可达（Density-Reachable）

如果存在点的链 $x_i = p_0, p_1, \dots, p_m = x_j$，使得每个 $p_{k+1}$ 从 $p_k$ 密度直达，则称 $x_j$ 从 $x_i$ **密度可达**：

$$x_j \text{ 从 } x_i \text{ 密度可达} \Leftrightarrow \exists \, p_0, p_1, \dots, p_m : p_0 = x_i, \, p_m = x_j, \, p_{k+1} \text{ 从 } p_k \text{ 密度直达}$$

密度可达关系是**传递的**，但仍然**非对称**。

### 3.3 密度相连（Density-Connected）

如果存在核心点 $x_k$，使得 $x_i$ 和 $x_j$ 都从 $x_k$ 密度可达，则称 $x_i$ 和 $x_j$ **密度相连**：

$$x_i \leftrightarrow x_j \text{ 密度相连} \Leftrightarrow \exists \, x_k \in X : x_i \text{ 从 } x_k \text{ 密度可达} \wedge x_j \text{ 从 } x_k \text{ 密度可达}$$

密度相连关系是对称的。

---

## 4. DBSCAN 算法流程

### 4.1 簇的定义

DBSCAN 中的簇定义为：

$$C = \{ x_i \in X : \exists \, x_j \in C, x_i \text{ 从 } x_j \text{ 密度可达} \}$$

或者等价地：

$$C = \{ x_i, x_j \in X : x_i \text{ 和 } x_j \text{ 密度相连} \}$$

### 4.2 完整算法

**输入：** 数据集 $X$，邻域半径 $\epsilon$，最小点数 $\text{MinPts}$

**输出：** 簇集合 $\{C_1, C_2, \dots, C_K\}$ 和噪声点集合 $N$

```
1. 标记所有点为"未访问"
2. for each 未访问点 x_i do:
3.   标记 x_i 为"已访问"
4.   N_ε(x_i) = {x_j ∈ X : d(x_i, x_j) ≤ ε}
5.   if |N_ε(x_i)| < MinPts then:
6.     标记 x_i 为噪声（暂时）
7.   else:
8.     创建新簇 C_k
9.     将 N_ε(x_i) 中的点加入 C_k
10.    创建种子集合 S = N_ε(x_i) \ {x_i}
11.    for each 点 x_j in S do:
12.      标记 x_j 为"已访问"
13.      N_ε(x_j) = {x ∈ X : d(x_j, x) ≤ ε}
14.      if |N_ε(x_j)| ≥ MinPts then:
15.        将 N_ε(x_j) 中的未分配点加入 S
16.      end if
17.      if x_j 不属于任何簇 then:
18.        将 x_j 加入 C_k
19.      end if
20.    end for
21.  end if
22. end for
23. 将仍标记为噪声的点归为噪声集合 N
```

### 4.3 算法时间复杂度

| 复杂度类型 | 值 | 说明 |
|-----------|-----|------|
| 暴力实现 | $O(n^2)$ | 需要计算所有点对距离 |
| 使用空间索引 | $O(n \log n)$ | 使用 KD-tree 或 Ball-tree |
| 最坏情况 | $O(n^2)$ | 高维数据中 KD-tree 退化 |

---

## 5. 参数选择

### 5.1 MinPts 的选择

$\text{MinPts}$ 的经验准则：

- 一般取 $\text{MinPts} \geq d + 1$，其中 $d$ 是数据维度
- 实践中常取 $\text{MinPts} = 2 \times d$
- 对于有噪声的数据集，较大的 $\text{MinPts}$ 可以更好地抑制噪声

### 5.2 $\epsilon$ 的选择 — k-距离图

**k-距离图（k-distance plot）** 是选择 $\epsilon$ 的主要工具：

1. 对每个点 $x_i$，计算到其第 $k$ 个最近邻的距离，其中 $k = \text{MinPts} - 1$
2. 将所有点的 $k$-距离按升序排序并绘制
3. 曲线的"拐点"（elbow）对应的 $y$ 值即为推荐的 $\epsilon$

**数学原理：** 在核心点密集区域，第 $k$ 个近邻距离较小且变化缓慢；在噪声区域，该距离突然增大。

### 5.3 参数敏感性

$$\epsilon \uparrow \text{ 或 } \text{MinPts} \downarrow \Rightarrow \text{更少噪声，更大更少的簇}$$
$$\epsilon \downarrow \text{ 或 } \text{MinPts} \uparrow \Rightarrow \text{更多噪声，更多更小的簇}$$

---

## 6. DBSCAN 的数学性质

### 6.1 密度的定义

DBSCAN 使用**基于计数的密度估计**：

$$\hat{\rho}(x) = \frac{|N_\epsilon(x)|}{V_d \cdot \epsilon^d}$$

其中 $V_d$ 是 $d$ 维单位球的体积：$V_d = \frac{\pi^{d/2}}{\Gamma(d/2 + 1)}$

### 6.2 与核密度估计的关系

DBSCAN 的密度概念可以看作是均匀核密度估计的阈值化：

$$\hat{f}(x) = \frac{1}{n h^d} \sum_{i=1}^{n} K\left(\frac{x - x_i}{h}\right)$$

其中 $K(u) = \mathbb{1}(\|u\| \leq 1)$ 是均匀核函数，$h = \epsilon$。

DBSCAN 等价于：$\hat{f}(x) \geq \frac{\text{MinPts}}{n V_d \epsilon^d}$ 的连通区域即为簇。

---

## 7. DBSCAN 的变体

### 7.1 HDBSCAN（层次 DBSCAN）

HDBSCAN 将 DBSCAN 与层次聚类结合，自动处理不同密度的簇：

**核心思想：**
1. 构建核心距离和互达距离的层次结构
2. 提取最稳定的簇

**核心距离（core distance）：**

$$\text{core}_k(x) = d(x, x_{(k)})$$

其中 $x_{(k)}$ 是 $x$ 的第 $k$ 个最近邻。

**互达距离（mutual reachability distance）：**

$$d_{\text{mreach-k}}(x, y) = \max\{\text{core}_k(x), \text{core}_k(y), d(x, y)\}$$

**优点：**
- 只需要一个参数 $\text{MinPts}$
- 能处理**变密度**数据
- 通过稳定性指标自动选择簇

### 7.2 OPTICS（ Ordering Points To Identify the Clustering Structure）

OPTICS 不直接生成簇，而是生成一个**排序**，表示点的密度结构：

**关键概念：**

**可达距离（reachability distance）：**

$$\text{rd}_\epsilon(x, y) = \begin{cases} \max(\epsilon, d(x, y)) & \text{if } |N_\epsilon(y)| \geq \text{MinPts} \\ \infty & \text{otherwise} \end{cases}$$

OPTICS 生成的可达性图（reachability plot）中的"谷"对应簇。

### 7.3 DBSCAN++ 

使用采样加速 $\epsilon$ 的选择过程，降低时间复杂度。

---

## 8. Python 实现

### 8.1 基本 DBSCAN

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import DBSCAN
from sklearn.datasets import make_moons, make_circles
from sklearn.metrics import silhouette_score

X, y_true = make_moons(n_samples=500, noise=0.08, random_state=42)

dbscan = DBSCAN(eps=0.2, min_samples=10)
y_pred = dbscan.fit_predict(X)

n_clusters = len(set(y_pred)) - (1 if -1 in y_pred else 0)
n_noise = list(y_pred).count(-1)
print(f"簇数: {n_clusters}")
print(f"噪声点数: {n_noise} ({n_noise/len(y_pred)*100:.1f}%)")

if n_clusters > 1:
    mask = y_pred != -1
    print(f"轮廓系数 (排除噪声): {silhouette_score(X[mask], y_pred[mask]):.4f}")

fig, ax = plt.subplots(figsize=(8, 6))
unique_labels = set(y_pred)
colors = plt.cm.viridis(np.linspace(0, 1, len(unique_labels)))

for label, color in zip(unique_labels, colors):
    if label == -1:
        color = 'red'
        marker = 'x'
        label_name = '噪声'
    else:
        marker = 'o'
        label_name = f'簇 {label}'
    mask = y_pred == label
    ax.scatter(X[mask, 0], X[mask, 1], c=[color], marker=marker, s=30, alpha=0.7, label=label_name)

ax.set_title(f'DBSCAN 聚类 (ε=0.2, MinPts=10)')
ax.legend()
plt.tight_layout()
plt.show()
```

### 8.2 k-距离图选择 $\epsilon$

```python
from sklearn.neighbors import NearestNeighbors

def k_distance_plot(X, k):
    nn = NearestNeighbors(n_neighbors=k)
    nn.fit(X)
    distances, _ = nn.kneighbors(X)
    k_distances = np.sort(distances[:, -1])

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.plot(k_distances, 'b-')
    ax.set_xlabel('样本索引 (按距离排序)')
    ax.set_ylabel(f'第 {k} 个最近邻距离')
    ax.set_title(f'k-距离图 (k={k})')
    ax.grid(True, alpha=0.3)

    diffs = np.diff(k_distances)
    diffs_smooth = np.convolve(diffs, np.ones(10)/10, mode='valid')
    elbow_idx = np.argmax(diffs_smooth) + 10
    epsilon_recommended = k_distances[elbow_idx]
    ax.axhline(y=epsilon_recommended, color='r', linestyle='--',
               label=f'推荐 ε ≈ {epsilon_recommended:.3f}')
    ax.legend()
    plt.tight_layout()
    plt.show()

    return epsilon_recommended

k = 10
epsilon = k_distance_plot(X, k)
print(f"推荐的 ε 值: {epsilon:.3f}")
```

### 8.3 参数搜索

```python
def dbscan_parameter_search(X, eps_range, min_samples_range):
    results = []
    for eps in eps_range:
        for min_samples in min_samples_range:
            db = DBSCAN(eps=eps, min_samples=min_samples)
            labels = db.fit_predict(X)
            n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
            n_noise = list(labels).count(-1)

            if n_clusters > 1:
                mask = labels != -1
                if len(set(labels[mask])) > 1:
                    sil = silhouette_score(X[mask], labels[mask])
                else:
                    sil = -1
            else:
                sil = -1

            results.append({
                'eps': eps,
                'min_samples': min_samples,
                'n_clusters': n_clusters,
                'n_noise': n_noise,
                'noise_ratio': n_noise / len(labels),
                'silhouette': sil
            })

    import pandas as pd
    df = pd.DataFrame(results)
    best = df[df['n_clusters'] > 1].sort_values('silhouette', ascending=False).head(1)
    print("最佳参数组合:")
    print(best.to_string(index=False))
    return df

eps_range = np.arange(0.1, 0.5, 0.02)
min_samples_range = range(5, 20, 2)
results_df = dbscan_parameter_search(X, eps_range, min_samples_range)
```

### 8.4 HDBSCAN 实现

```python
import hdbscan

clusterer = hdbscan.HDBSCAN(min_cluster_size=15, min_samples=5, metric='euclidean')
y_hdbscan = clusterer.fit_predict(X)

n_clusters = len(set(y_hdbscan)) - (1 if -1 in y_hdbscan else 0)
n_noise = list(y_hdbscan).count(-1)
print(f"HDBSCAN 簇数: {n_clusters}")
print(f"噪声点数: {n_noise}")

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

ax = axes[0]
for label in set(y_hdbscan):
    if label == -1:
        ax.scatter(X[y_hdbscan == label, 0], X[y_hdbscan == label, 1],
                   c='red', marker='x', s=20, alpha=0.5, label='噪声')
    else:
        ax.scatter(X[y_hdbscan == label, 0], X[y_hdbscan == label, 1],
                   s=30, alpha=0.7, label=f'簇 {label}')
ax.set_title('HDBSCAN 聚类结果')
ax.legend(fontsize=8)

ax = axes[1]
clusterer.condensed_tree_.plot(select_clusters=True, selection_palette='viridis', ax=ax)
ax.set_title('HDBSCAN 紧凑树')

plt.tight_layout()
plt.show()
```

### 8.5 DBSCAN vs K-means 对比

```python
from sklearn.cluster import KMeans

X_circle, _ = make_circles(n_samples=500, noise=0.05, factor=0.5, random_state=42)

kmeans = KMeans(n_clusters=2, random_state=42, n_init=10)
y_kmeans = kmeans.fit_predict(X_circle)

dbscan = DBSCAN(eps=0.15, min_samples=10)
y_dbscan = dbscan.fit_predict(X_circle)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
axes[0].scatter(X_circle[:, 0], X_circle[:, 1], c=y_kmeans, cmap='viridis', s=30)
axes[0].set_title('K-means (无法识别环形簇)')
axes[1].scatter(X_circle[:, 0], X_circle[:, 1], c=y_dbscan, cmap='viridis', s=30)
axes[1].set_title('DBSCAN (成功识别环形簇)')
plt.tight_layout()
plt.show()
```

---

## 9. 实际案例：异常检测

```python
from sklearn.neighbors import LocalOutlierFactor

np.random.seed(42)
n_normal = 300
n_anomaly = 20

X_normal = np.random.randn(n_normal, 2) * 0.5
X_normal += np.array([2, 2])
X_anomaly = np.random.uniform(-2, 6, size=(n_anomaly, 2))
X_detect = np.vstack([X_normal, X_anomaly])

dbscan = DBSCAN(eps=0.3, min_samples=10)
labels = dbscan.fit_predict(X_detect)

noise_mask = labels == -1
anomaly_detected = sum(noise_mask[n_normal:])
print(f"DBSCAN 检测到的异常点: {anomaly_detected}/{n_anomaly}")

fig, ax = plt.subplots(figsize=(8, 6))
ax.scatter(X_detect[~noise_mask, 0], X_detect[~noise_mask, 1],
           c='blue', s=20, alpha=0.6, label='正常点')
ax.scatter(X_detect[noise_mask, 0], X_detect[noise_mask, 1],
           c='red', marker='x', s=50, label='检测到的噪声/异常')
ax.set_title('DBSCAN 异常检测')
ax.legend()
plt.tight_layout()
plt.show()
```

---

## 10. 优缺点总结

### 优点

1. **无需指定簇数** $K$
2. **任意形状簇**：可以发现非球形、不规则形状的簇
3. **噪声检测**：自动将离群点标记为噪声
4. **对初始值不敏感**：确定性算法，结果可复现
5. **参数意义直观**：$\epsilon$ 和 $\text{MinPts}$ 有明确的物理意义

### 缺点

1. **变密度问题**：难以处理密度差异较大的数据集
2. **高维灾难**：在高维空间中，距离度量变得不可靠
3. **边界点不确定性**：边界点的分配依赖于处理顺序
4. **参数敏感**：$\epsilon$ 和 $\text{MinPts}$ 的选择对结果影响大

---

## 11. 关键要点总结

| 要点 | 说明 |
|------|------|
| 核心概念 | 基于密度的聚类，发现任意形状簇 |
| 核心参数 | $\epsilon$（邻域半径）和 $\text{MinPts}$（最小点数） |
| 点分类 | 核心点、边界点、噪声点 |
| 密度关系 | 密度直达 → 密度可达 → 密度相连 |
| 参数选择 | $\text{MinPts} \geq d+1$，$\epsilon$ 通过 k-距离图选择 |
| 时间复杂度 | $O(n \log n)$（使用空间索引）或 $O(n^2)$ |
| 适用场景 | 不规则形状簇、含噪声数据、不确定簇数 |
| 变体 | HDBSCAN（处理变密度）、OPTICS（排序式） |
| 不适用场景 | 高维数据、密度差异大的数据 |

DBSCAN 作为密度聚类的代表算法，在实际应用中非常广泛，特别是在地理空间数据分析、异常检测和图像分割等领域。
