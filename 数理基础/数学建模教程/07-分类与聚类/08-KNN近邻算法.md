# KNN 近邻算法

## 1. 算法概述

KNN（K-Nearest Neighbors，K 近邻）是一种基于**实例的学习**（instance-based learning）或**懒惰学习**（lazy learning）算法。其核心思想极为简单：一个数据点的类别由其最近的 $K$ 个邻居的多数投票决定。

### 核心思想

给定训练集 $D = \{(x_i, y_i)\}_{i=1}^{n}$，对新样本 $x$：

1. 计算 $x$ 与训练集中所有样本的距离
2. 选出距离最近的 $K$ 个样本
3. 这 $K$ 个样本中出现最多的类别即为 $x$ 的预测类别

$$\hat{y} = \arg\max_{c} \sum_{i \in N_K(x)} \mathbb{1}(y_i = c)$$

其中 $N_K(x)$ 是 $x$ 的 $K$ 个最近邻的索引集合。

---

## 2. 距离度量

### 2.1 闵可夫斯基距离（Minkowski Distance）

$$d(x_i, x_j) = \left(\sum_{k=1}^{d} |x_{ik} - x_{jk}|^p\right)^{1/p}$$

| $p$ 值 | 名称 | 公式 |
|--------|------|------|
| $p = 1$ | 曼哈顿距离 | $d = \sum_k \|x_{ik} - x_{jk}\|$ |
| $p = 2$ | 欧氏距离 | $d = \sqrt{\sum_k (x_{ik} - x_{jk})^2}$ |
| $p \to \infty$ | 切比雪夫距离 | $d = \max_k \|x_{ik} - x_{jk}\|$ |

### 2.2 余弦相似度

$$\cos(x_i, x_j) = \frac{x_i \cdot x_j}{\|x_i\| \cdot \|x_j\|}$$

余弦距离：$d_{\cos}(x_i, x_j) = 1 - \cos(x_i, x_j)$

### 2.3 汉明距离（Hamming Distance）

用于分类特征，计算不同特征值的个数：

$$d_H(x_i, x_j) = \frac{1}{d}\sum_{k=1}^{d} \mathbb{1}(x_{ik} \neq x_{jk})$$

### 2.4 马氏距离（Mahalanobis Distance）

考虑特征之间的相关性：

$$d_M(x_i, x_j) = \sqrt{(x_i - x_j)^T \Sigma^{-1} (x_i - x_j)}$$

其中 $\Sigma$ 是数据的协方差矩阵。

### 2.5 距离度量对比

| 距离度量 | 适用场景 | 特点 |
|---------|---------|------|
| 欧氏距离 | 连续特征，各维度同等重要 | 最常用 |
| 曼哈顿距离 | 高维稀疏数据 | 对异常值更鲁棒 |
| 余弦距离 | 文本、高维向量 | 关注方向而非大小 |
| 马氏距离 | 特征相关时 | 考虑了数据的分布 |
| 汉明距离 | 分类/二值特征 | 计数不同特征值 |

---

## 3. K 值选择

### 3.1 K 值对模型的影响

| K 值 | 模型复杂度 | 偏差 | 方差 | 决策边界 |
|------|-----------|------|------|---------|
| $K = 1$ | 最高 | 最低 | 最高 | 完全贴合训练数据 |
| $K$ 小 | 高 | 低 | 高 | 复杂、不规则 |
| $K$ 大 | 低 | 高 | 低 | 平滑、简单 |
| $K = n$ | 最低 | 最高 | 最低 | 总是预测多数类 |

### 3.2 交叉验证选择 K

通过交叉验证选择使泛化误差最小的 $K$ 值：

$$K^* = \arg\min_K \text{CV\_Error}(K)$$

通常绘制 **K - 误差曲线**，选择误差开始稳定的点。

### 3.3 经验准则

- $K$ 通常取奇数（避免投票平局）
- $K \approx \sqrt{n}$ 是一个常用的起点
- 数据量大时 $K$ 可以取更大值

---

## 4. 加权 KNN

### 4.1 基本思想

在标准 KNN 中，所有 $K$ 个邻居的投票权重相同。加权 KNN 根据距离赋予不同权重，距离越近的邻居投票权重越大：

$$\hat{y} = \arg\max_{c} \sum_{i \in N_K(x)} w_i \cdot \mathbb{1}(y_i = c)$$

### 4.2 常见权重函数

**距离倒数权重：**

$$w_i = \frac{1}{d(x, x_i)}$$

**高斯核权重：**

$$w_i = \exp\left(-\frac{d(x, x_i)^2}{2\sigma^2}\right)$$

其中 $\sigma$ 可以取为 $K$ 个近邻距离的均值。

**一般核函数权重：**

$$w_i = K_h(d(x, x_i)) = \frac{1}{h} K\left(\frac{d(x, x_i)}{h}\right)$$

---

## 5. 理论分析

### 5.1 1-NN 的误差界

Cover 和 Hart (1967) 证明了著名的 **Cover-Hart 不等式**：

$$R^* \leq R_{1\text{-NN}} \leq 2R^* - \frac{K}{K+1}(R^*)^2$$

其中 $R^*$ 是贝叶斯最优错误率，$R_{1\text{-NN}}$ 是 1-NN 的错误率。

**含义：** 1-NN 的错误率不超过贝叶斯最优错误率的两倍。

### 5.2 渐近性质

当 $n \to \infty$ 时：

$$R_{K\text{-NN}} \to R^* + O\left(\frac{1}{\sqrt{K}}\right)$$

且当 $K \to \infty$ 时（$K$ 随 $n$ 增长但 $K/n \to 0$）：

$$R_{K\text{-NN}} \to R^*$$

### 5.3 维度灾难

在高维空间中，KNN 面临**维度灾难**（curse of dimensionality）：

$$\frac{d_{\max} - d_{\min}}{d_{\min}} \to 0 \quad \text{as } d \to \infty$$

其中 $d_{\max}$ 和 $d_{\min}$ 分别是数据点到查询点的最大和最小距离。这意味着在高维空间中，所有点之间的距离趋于相同，KNN 失去区分能力。

### 5.4 降维的必要性

为缓解维度灾难，可采用：
- **特征选择**：选择最相关的特征
- **降维**：PCA、t-SNE 等
- **距离度量学习**：学习适合任务的距离函数

---

## 6. KNN 的变体

### 6.1 Ball Tree

使用超球体层次结构组织数据，查询时只需搜索可能包含最近邻的球体分支：

- 构建时间：$O(n \log n)$
- 查询时间：$O(\log n)$（平均）

### 6.2 KD-Tree

使用超平面层次结构递归分割空间：

- 构建时间：$O(n \log n)$
- 查询时间：$O(\log n)$（低维），$O(n)$（高维退化）

### 6.3 Brute Force

暴力搜索所有距离：

- 查询时间：$O(nd)$

### 6.4 各算法适用维度

| 算法 | 最佳维度 | 特点 |
|------|---------|------|
| KD-Tree | $d < 20$ | 低维高效 |
| Ball Tree | 中等维度 | 处理高维比 KD-Tree 好 |
| Brute Force | 任意维度 | 高维时可能更快 |
| FAISS | 超高维 | GPU 加速近似搜索 |

---

## 7. Python 实现

### 7.1 基本 KNN

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.neighbors import KNeighborsClassifier, KNeighborsRegressor
from sklearn.datasets import make_classification, make_moons
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import accuracy_score, classification_report
from sklearn.preprocessing import StandardScaler

X, y = make_classification(n_samples=500, n_features=2, n_redundant=0,
                           n_informative=2, n_clusters_per_class=1, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

scaler = StandardScaler()
X_train_s = scaler.fit_transform(X_train)
X_test_s = scaler.transform(X_test)

knn = KNeighborsClassifier(n_neighbors=5, weights='uniform', metric='minkowski', p=2)
knn.fit(X_train_s, y_train)

y_pred = knn.predict(X_test_s)
print(f"KNN 准确率 (K=5): {accuracy_score(y_test, y_pred):.4f}")
print(classification_report(y_test, y_pred))
```

### 7.2 K 值选择

```python
K_range = range(1, 31)
train_scores = []
test_scores = []
cv_scores_list = []

for k in K_range:
    knn = KNeighborsClassifier(n_neighbors=k)
    knn.fit(X_train_s, y_train)
    train_scores.append(accuracy_score(y_train, knn.predict(X_train_s)))
    test_scores.append(accuracy_score(y_test, knn.predict(X_test_s)))
    cv = cross_val_score(KNeighborsClassifier(n_neighbors=k), X_train_s, y_train, cv=5)
    cv_scores_list.append(cv.mean())

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

ax1.plot(K_range, train_scores, 'b-o', label='训练集', markersize=4)
ax1.plot(K_range, test_scores, 'r-o', label='测试集', markersize=4)
ax1.plot(K_range, cv_scores_list, 'g-o', label='CV 均值', markersize=4)
ax1.set_xlabel('K 值')
ax1.set_ylabel('准确率')
ax1.set_title('K 值 vs 准确率')
ax1.legend()
ax1.grid(True, alpha=0.3)

test_errors = [1 - s for s in test_scores]
ax2.plot(K_range, test_errors, 'ro-', markersize=4)
best_k = K_range[np.argmax(cv_scores_list)]
ax2.axvline(x=best_k, color='b', linestyle='--', label=f'最佳 K = {best_k}')
ax2.set_xlabel('K 值')
ax2.set_ylabel('测试误差')
ax2.set_title('K 值 vs 测试误差')
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.show()
print(f"最佳 K 值 (CV): {best_k}")
```

### 7.3 决策边界可视化

```python
X_moons, y_moons = make_moons(n_samples=300, noise=0.2, random_state=42)
X_tr_m, X_te_m, y_tr_m, y_te_m = train_test_split(X_moons, y_moons, test_size=0.3, random_state=42)

fig, axes = plt.subplots(2, 3, figsize=(18, 10))
k_values = [1, 3, 5, 10, 20, 50]
weights_options = ['uniform', 'distance']

for idx, k in enumerate(k_values):
    ax = axes[idx // 3, idx % 3]
    knn = KNeighborsClassifier(n_neighbors=k, weights='uniform')
    knn.fit(X_tr_m, y_tr_m)

    xx, yy = np.meshgrid(
        np.linspace(X_moons[:, 0].min() - 0.5, X_moons[:, 0].max() + 0.5, 300),
        np.linspace(X_moons[:, 1].min() - 0.5, X_moons[:, 1].max() + 0.5, 300))
    Z = knn.predict(np.c_[xx.ravel(), yy.ravel()]).reshape(xx.shape)

    ax.contourf(xx, yy, Z, alpha=0.3, cmap='RdBu')
    ax.scatter(X_tr_m[y_tr_m == 0, 0], X_tr_m[y_tr_m == 0, 1], c='blue', s=15, alpha=0.5)
    ax.scatter(X_tr_m[y_tr_m == 1, 0], X_tr_m[y_tr_m == 1, 1], c='red', s=15, alpha=0.5)
    acc = accuracy_score(y_te_m, knn.predict(X_te_m))
    ax.set_title(f'K={k} (准确率: {acc:.3f})')

plt.suptitle('KNN 决策边界随 K 值变化', fontsize=14)
plt.tight_layout()
plt.show()
```

### 7.4 Uniform vs Distance Weighted

```python
X_2d, y_2d = make_classification(n_samples=400, n_features=2, n_redundant=0,
                                  n_informative=2, random_state=42)
Xtr, Xte, ytr, yte = train_test_split(X_2d, y_2d, test_size=0.3, random_state=42)

fig, axes = plt.subplots(1, 2, figsize=(14, 5))
for ax, weights in zip(axes, ['uniform', 'distance']):
    knn = KNeighborsClassifier(n_neighbors=10, weights=weights)
    knn.fit(Xtr, ytr)

    xx, yy = np.meshgrid(
        np.linspace(X_2d[:, 0].min() - 1, X_2d[:, 0].max() + 1, 300),
        np.linspace(X_2d[:, 1].min() - 1, X_2d[:, 1].max() + 1, 300))
    Z = knn.predict(np.c_[xx.ravel(), yy.ravel()]).reshape(xx.shape)

    ax.contourf(xx, yy, Z, alpha=0.3, cmap='RdBu')
    ax.scatter(Xte[yte == 0, 0], Xte[yte == 0, 1], c='blue', s=20, alpha=0.6)
    ax.scatter(Xte[yte == 1, 0], Xte[yte == 1, 1], c='red', s=20, alpha=0.6)
    acc = accuracy_score(yte, knn.predict(Xte))
    ax.set_title(f'K=10, weights={weights} (准确率: {acc:.3f})')

plt.tight_layout()
plt.show()
```

### 7.5 不同距离度量对比

```python
from sklearn.datasets import load_iris

iris = load_iris()
X_iris, y_iris = iris.data, iris.target
Xtr_i, Xte_i, ytr_i, yte_i = train_test_split(X_iris, y_iris, test_size=0.3, random_state=42)

sc_i = StandardScaler()
Xtr_is = sc_i.fit_transform(Xtr_i)
Xte_is = sc_i.transform(Xte_i)

metrics = {
    'euclidean': {'p': 2},
    'manhattan': {'p': 1},
    'chebyshev': {},
    'cosine': {},
}

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
for ax, (metric, params) in zip(axes.flat, metrics.items()):
    knn = KNeighborsClassifier(n_neighbors=5, metric=metric, **params)
    knn.fit(Xtr_is, ytr_i)

    cv_scores = cross_val_score(knn, Xtr_is, ytr_i, cv=5)
    test_acc = accuracy_score(yte_i, knn.predict(Xte_is))

    K_range = range(1, 21)
    cv_list = []
    for k in K_range:
        knn_k = KNeighborsClassifier(n_neighbors=k, metric=metric, **params)
        cv_list.append(cross_val_score(knn_k, Xtr_is, ytr_i, cv=5).mean())

    ax.plot(K_range, cv_list, 'bo-')
    best_k_m = list(K_range)[np.argmax(cv_list)]
    ax.axvline(x=best_k_m, color='r', linestyle='--', label=f'best K={best_k_m}')
    ax.set_xlabel('K')
    ax.set_ylabel('CV Accuracy')
    ax.set_title(f'{metric} (test: {test_acc:.3f})')
    ax.legend()
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.show()
```

### 7.6 KNN 回归

```python
from sklearn.neighbors import KNeighborsRegressor
from sklearn.metrics import mean_squared_error, r2_score

np.random.seed(42)
X_reg = np.sort(5 * np.random.rand(200, 1), axis=0)
y_reg = np.sin(X_reg).ravel() + np.random.normal(0, 0.2, X_reg.shape[0])

Xtr_r, Xte_r, ytr_r, yte_r = train_test_split(X_reg, y_reg, test_size=0.3, random_state=42)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
X_plot = np.linspace(X_reg.min(), X_reg.max(), 500).reshape(-1, 1)

for ax, k, w in zip(axes.flat, [1, 5, 15, 50], ['uniform', 'uniform', 'uniform', 'uniform']):
    knn_r = KNeighborsRegressor(n_neighbors=k, weights=w)
    knn_r.fit(Xtr_r, ytr_r)
    y_plot = knn_r.predict(X_plot)
    y_pred_r = knn_r.predict(Xte_r)
    r2 = r2_score(yte_r, y_pred_r)

    ax.scatter(Xtr_r, ytr_r, s=10, alpha=0.4, label='train')
    ax.scatter(Xte_r, yte_r, s=10, alpha=0.4, label='test')
    ax.plot(X_plot, y_plot, 'r-', linewidth=2, label='prediction')
    ax.set_title(f'K={k}, weights={w} (R2={r2:.3f})')
    ax.legend(fontsize=8)

plt.suptitle('KNN 回归', fontsize=14)
plt.tight_layout()
plt.show()
```

---

## 8. 实际案例：手写数字识别

```python
from sklearn.datasets import load_digits
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay

digits = load_digits()
X_d, y_d = digits.data, digits.target
Xtr_d, Xte_d, ytr_d, yte_d = train_test_split(X_d, y_d, test_size=0.3, random_state=42)

sc_d = StandardScaler()
Xtr_ds = sc_d.fit_transform(Xtr_d)
Xte_ds = sc_d.transform(Xte_d)

knn_digits = KNeighborsClassifier(n_neighbors=3, weights='distance', metric='euclidean')
knn_digits.fit(Xtr_ds, ytr_d)
y_pred_d = knn_digits.predict(Xte_ds)

print(f"准确率: {accuracy_score(yte_d, y_pred_d):.4f}")

fig, ax = plt.subplots(figsize=(10, 8))
cm = confusion_matrix(yte_d, y_pred_d)
ConfusionMatrixDisplay(cm, display_labels=digits.target_names).plot(ax=ax, cmap='Blues')
ax.set_title('KNN 手写数字识别混淆矩阵')
plt.tight_layout()
plt.show()

misclassified = np.where(y_pred_d != yte_d)[0]
fig, axes = plt.subplots(2, 5, figsize=(12, 5))
for ax, idx in zip(axes.flat, misclassified[:10]):
    ax.imshow(Xte_d[idx].reshape(8, 8), cmap='gray')
    ax.set_title(f'真实: {yte_d[idx]}, 预测: {y_pred_d[idx]}')
    ax.axis('off')
plt.suptitle('误分类样本')
plt.tight_layout()
plt.show()
```

---

## 9. KNN 与其他算法对比

| 特性 | KNN | SVM | 决策树 | 朴素贝叶斯 |
|------|-----|-----|--------|-----------|
| 训练速度 | 极快（无训练） | 慢 | 快 | 极快 |
| 预测速度 | 慢 | 快 | 快 | 极快 |
| 模型大小 | 大（存全部数据） | 小（支持向量） | 小 | 极小 |
| 可解释性 | 中 | 低 | 高 | 中 |
| 对噪声敏感 | 高 | 中 | 中 | 低 |
| 对特征缩放 | 敏感 | 敏感 | 不敏感 | 不敏感 |
| 处理非线性 | 天然支持 | 需要核 | 天然支持 | 需要假设 |
| 维度灾难 | 严重 | 中等 | 中等 | 有 |

---

## 10. 优缺点总结

### 优点

1. **简单直观**：算法原理容易理解
2. **无需训练**：懒惰学习，没有显式的训练过程
3. **天然支持多分类**
4. **对非线性数据有效**
5. **可随新数据增量更新**
6. **理论基础扎实**：渐近收敛到贝叶斯最优

### 缺点

1. **预测速度慢**：需要计算与所有训练样本的距离
2. **存储开销大**：需要存储全部训练数据
3. **维度灾难**：高维空间中距离度量失效
4. **对特征缩放敏感**：需要标准化
5. **对不平衡数据敏感**：多数类主导投票
6. **对噪声和异常值敏感**（K 小时）

---

## 11. 关键要点总结

| 要点 | 说明 |
|------|------|
| 核心原理 | 投票最近的 K 个邻居 |
| 距离度量 | 欧氏最常用，文本用余弦，高维需注意 |
| K 值选择 | 交叉验证，通常取奇数，$\sqrt{n}$ 作为起点 |
| 加权 KNN | 距离越近权重越大，通常优于均匀投票 |
| 维度灾难 | 高维时距离失去区分力，需要降维 |
| Cover-Hart | 1-NN 错误率不超过贝叶斯最优的 2 倍 |
| 空间索引 | KD-Tree、Ball-Tree 加速搜索 |
| 特征缩放 | 必须标准化/归一化 |
| 适用场景 | 小到中等数据量、低到中维度、非线性边界 |
| 核心局限 | 预测慢、维度灾难、存储大 |

KNN 虽然简单，但其思想是许多复杂算法的基础。理解 KNN 有助于深入理解距离度量、最近邻搜索和非参数统计等核心概念。
