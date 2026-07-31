# K-means 聚类算法

> **理论基础** → 参见 [[../../机器学习数学基础/聚类分析|聚类分析]]

K-means是最经典的划分式聚类算法，通过迭代更新簇中心和分配数据点，适合球状分布的大数据集聚类。

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

## 跨领域关联
- **人工智能**：[[../../../../人工智能/机器学习与深度学习/1.机器学习概述|机器学习（无监督学习核心算法）]]
- **计算机类**：[[../../../../计算机类/python学习/01-Python基础与数据类型|Python sklearn.cluster.KMeans 实现]] | [[../../../../计算机类/MATLAB学习/50-系统工程与总结|MATLAB kmeans]]
