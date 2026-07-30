# DBSCAN 密度聚类算法

> **理论基础** → 参见 [[../../机器学习数学基础/聚类分析|聚类分析]]

DBSCAN基于密度的空间聚类算法，能发现任意形状的簇并自动识别噪声点，对噪声数据鲁棒。

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
