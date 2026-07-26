# 岭回归与LASSO

## 一、概述

当多元线性回归面临**多重共线性**、**过拟合**或**特征过多**等问题时，正则化（Regularization）方法通过在损失函数中添加惩罚项来约束模型复杂度。岭回归（Ridge Regression）和 LASSO 是两种最基本的正则化方法。

### 1.1 偏差-方差权衡

对于模型预测误差，可以分解为：

$$\text{MSE} = \text{Bias}^2 + \text{Variance} + \text{Irreducible Error}$$

- **简单模型（高偏差、低方差）**：欠拟合
- **复杂模型（低偏差、高方差）**：过拟合
- **正则化**的核心是通过引入适量偏差来大幅降低方差，从而降低总预测误差

---

## 二、普通最小二乘回归的局限

### 2.1 OLS 目标函数

$$\hat{\boldsymbol{\beta}}_{OLS} = \arg\min_{\boldsymbol{\beta}} \|\mathbf{y} - \mathbf{X}\boldsymbol{\beta}\|^2$$

解为：

$$\hat{\boldsymbol{\beta}}_{OLS} = (\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}^T\mathbf{y}$$

### 2.2 问题

1. **多重共线性**：当 $\mathbf{X}^T\mathbf{X}$ 接近奇异时，$(\mathbf{X}^T\mathbf{X})^{-1}$ 不稳定，系数估计值可能非常大
2. **过拟合**：特征数 $p$ 接近或超过样本量 $n$ 时，模型会过拟合
3. **解释性差**：过多变量导致模型难以解释

---

## 三、岭回归（Ridge Regression, L2 正则化）

### 3.1 目标函数

$$\hat{\boldsymbol{\beta}}_{Ridge} = \arg\min_{\boldsymbol{\beta}} \left\{ \|\mathbf{y} - \mathbf{X}\boldsymbol{\beta}\|^2 + \lambda \|\boldsymbol{\beta}\|_2^2 \right\}$$

其中 $\lambda \geq 0$ 为正则化参数，$\|\boldsymbol{\beta}\|_2^2 = \sum_{j=1}^{p} \beta_j^2$。

### 3.2 解析解

$$\hat{\boldsymbol{\beta}}_{Ridge} = (\mathbf{X}^T\mathbf{X} + \lambda \mathbf{I})^{-1}\mathbf{X}^T\mathbf{y}$$

**关键观察**：$\lambda \mathbf{I}$ 的添加使 $\mathbf{X}^T\mathbf{X} + \lambda \mathbf{I}$ 总是可逆的，即使 $\mathbf{X}^T\mathbf{X}$ 不可逆。

### 3.3 几何解释

岭回归的约束域为**超球面**：

$$\|\boldsymbol{\beta}\|_2^2 \leq t$$

在二维情况下，约束域是一个圆。OLS 解的等高线（椭圆）与圆的切点就是岭回归解。由于圆的边界是光滑的，切点通常不在坐标轴上，因此**岭回归不会产生完全为零的系数**。

### 3.4 SVD 视角

对 $\mathbf{X} = \mathbf{U}\mathbf{D}\mathbf{V}^T$ 做 SVD 分解：

$$\hat{\boldsymbol{\beta}}_{Ridge} = \sum_{j=1}^{p} \frac{d_j^2}{d_j^2 + \lambda} \frac{\mathbf{u}_j^T \mathbf{y}}{d_j} \mathbf{v}_j$$

当 $d_j^2 \ll \lambda$ 时，$\frac{d_j^2}{d_j^2 + \lambda} \approx 0$，对应方向的系数被大幅收缩。

---

## 四、LASSO（L1 正则化）

### 4.1 目标函数

$$\hat{\boldsymbol{\beta}}_{LASSO} = \arg\min_{\boldsymbol{\beta}} \left\{ \|\mathbf{y} - \mathbf{X}\boldsymbol{\beta}\|^2 + \lambda \|\boldsymbol{\beta}\|_1 \right\}$$

其中 $\|\boldsymbol{\beta}\|_1 = \sum_{j=1}^{p} |\beta_j|$。

### 4.2 几何解释

LASSO 的约束域为**超菱形**：

$$\|\boldsymbol{\beta}\|_1 \leq t$$

在二维情况下，约束域是一个菱形。菱形的顶点在坐标轴上，OLS 解的等高线更容易与菱形的顶点或边上相交，因此**LASSO 可能产生恰好为零的系数**，实现自动特征选择。

### 4.3 坐标下降求解

LASSO 没有闭式解，常用坐标下降法求解。对 $\beta_j$ 的更新（固定其他参数）：

$$\beta_j \leftarrow \frac{S\left(\frac{1}{n}\sum_{i=1}^{n} x_{ij}(y_i - \hat{y}_i^{(-j)}), \; \lambda/n\right)}{\frac{1}{n}\sum_{i=1}^{n} x_{ij}^2}$$

其中 $S(z, \gamma)$ 为软阈值函数：

$$S(z, \gamma) = \text{sign}(z) \cdot \max(|z| - \gamma, 0) = \begin{cases} z - \gamma & z > \gamma \\ 0 & |z| \leq \gamma \\ z + \gamma & z < -\gamma \end{cases}$$

---

## 五、Elastic Net

### 5.1 目标函数

$$\hat{\boldsymbol{\beta}}_{EN} = \arg\min_{\boldsymbol{\beta}} \left\{ \|\mathbf{y} - \mathbf{X}\boldsymbol{\beta}\|^2 + \lambda_1 \|\boldsymbol{\beta}\|_1 + \lambda_2 \|\boldsymbol{\beta}\|_2^2 \right\}$$

等价地，用混合参数 $\alpha \in [0, 1]$：

$$\hat{\boldsymbol{\beta}}_{EN} = \arg\min_{\boldsymbol{\beta}} \left\{ \|\mathbf{y} - \mathbf{X}\boldsymbol{\beta}\|^2 + \lambda \left[\alpha \|\boldsymbol{\beta}\|_1 + \frac{1-\alpha}{2} \|\boldsymbol{\beta}\|_2^2\right] \right\}$$

- $\alpha = 1$：退化为 LASSO
- $\alpha = 0$：退化为 Ridge
- $0 < \alpha < 1$：介于两者之间

### 5.2 Elastic Net 的优势

1. 同时具有 LASSO 的特征选择能力和 Ridge 的稳定性
2. 当特征高度相关时，LASSO 倾向于随机选择一个，Elastic Net 则倾向于将相关特征一起选入或排除
3. 当 $p > n$ 时，Elastic Net 最多选择 $n$ 个特征（LASSO 的限制）

---

## 六、Ridge vs LASSO 对比

### 6.1 数学对比

| 特征 | Ridge (L2) | LASSO (L1) |
|------|------------|------------|
| 惩罚项 | $\lambda \sum \beta_j^2$ | $\lambda \sum |\beta_j|$ |
| 约束域 | 超球面 | 超菱形 |
| 解析解 | 有 | 无 |
| 系数收缩 | 连续收缩，不为零 | 可能为零（稀疏解） |
| 特征选择 | 否 | 是 |
| 处理相关特征 | 倾向均等分配 | 倾向选一个 |
| 计算效率 | 高（闭式解） | 中（迭代算法） |
| 适用场景 | 多重共线性、防止过拟合 | 特征选择、高维数据 |

### 6.2 偏差-方差特性

- **Ridge**：引入较小偏差，显著降低方差。系数趋向于零但不等于零
- **LASSO**：可以将不重要变量的系数压缩为零（无偏地选择变量），但可能引入较大偏差
- **Elastic Net**：在两者之间取得平衡

---

## 七、正则化参数选择

### 7.1 交叉验证

最常用的方法是 **K 折交叉验证**选择最优 $\lambda$：

```python
# 选择使交叉验证误差最小的 lambda
lambda_optimal = lambda_values[np.argmin(cv_errors)]
```

### 7.2 信息准则

$$\text{AIC} = n \ln(\text{RSS}/n) + 2p_{\text{eff}}$$
$$\text{BIC} = n \ln(\text{RSS}/n) + p_{\text{eff}} \ln(n)$$

其中有效参数个数 $p_{\text{eff}}$ 需要根据正则化类型计算。

### 7.3 正则化路径

$\lambda$ 从大到小变化时，系数从零逐渐增大。绘制正则化路径可以直观看到各变量的"进入"顺序。

---

## 八、Python 实现

### 8.1 从零实现 Ridge 和 LASSO

```python
import numpy as np
from scipy.optimize import minimize

class RidgeRegression:
    def __init__(self, alpha=1.0):
        self.alpha = alpha
        self.coef_ = None
        self.intercept_ = None
    
    def fit(self, X, y):
        n, p = X.shape
        X_with_intercept = np.column_stack([np.ones(n), X])
        
        # 加入 L2 惩罚（不惩罚截距）
        I = np.eye(p + 1)
        I[0, 0] = 0  # 不惩罚截距
        
        XtX = X_with_intercept.T @ X_with_intercept
        Xty = X_with_intercept.T @ y
        theta = np.linalg.solve(XtX + self.alpha * I, Xty)
        
        self.intercept_ = theta[0]
        self.coef_ = theta[1:]
        return self
    
    def predict(self, X):
        return X @ self.coef_ + self.intercept_


class LassoRegression:
    def __init__(self, alpha=1.0, max_iter=1000, tol=1e-4):
        self.alpha = alpha
        self.max_iter = max_iter
        self.tol = tol
        self.coef_ = None
        self.intercept_ = None
    
    def soft_threshold(self, z, gamma):
        return np.sign(z) * np.maximum(np.abs(z) - gamma, 0)
    
    def fit(self, X, y):
        n, p = X.shape
        self.coef_ = np.zeros(p)
        self.intercept_ = np.mean(y)
        
        for iteration in range(self.max_iter):
            coef_old = self.coef_.copy()
            
            for j in range(p):
                r_j = y - self.intercept_ - X @ self.coef_ + X[:, j] * self.coef_[j]
                rho_j = X[:, j] @ r_j / n
                z_j = X[:, j] @ X[:, j] / n
                self.coef_[j] = self.soft_threshold(rho_j, self.alpha / n) / z_j
            
            if np.max(np.abs(self.coef_ - coef_old)) < self.tol:
                break
        
        self.intercept_ = np.mean(y - X @ self.coef_)
        return self
    
    def predict(self, X):
        return X @ self.coef_ + self.intercept_


# 测试
from sklearn.datasets import make_regression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error

X, y = make_regression(n_samples=200, n_features=20, n_informative=5, 
                       noise=10, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
X_train_s = scaler.fit_transform(X_train)
X_test_s = scaler.transform(X_test)

# Ridge
ridge = RidgeRegression(alpha=1.0)
ridge.fit(X_train_s, y_train)
y_pred_ridge = ridge.predict(X_test_s)
print(f"Ridge MSE: {mean_squared_error(y_test, y_pred_ridge):.4f}")

# LASSO
lasso = LassoRegression(alpha=0.5)
lasso.fit(X_train_s, y_train)
y_pred_lasso = lasso.predict(X_test_s)
print(f"LASSO MSE: {mean_squared_error(y_test, y_pred_lasso):.4f}")
print(f"LASSO 非零系数: {np.sum(np.abs(lasso.coef_) > 1e-6)}/{len(lasso.coef_)}")
```

### 8.2 使用 scikit-learn

```python
import numpy as np
from sklearn.linear_model import Ridge, Lasso, ElasticNet, RidgeCV, LassoCV
from sklearn.datasets import make_regression
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, r2_score

np.random.seed(42)

# 生成数据（含多重共线性）
n_samples, n_features = 200, 30
X, y, true_coef = make_regression(n_samples=n_samples, n_features=n_features,
                                   n_informative=10, noise=10, coef=True, random_state=42)

# 添加相关特征
X[:, 20] = X[:, 0] + np.random.normal(0, 0.1, n_samples)  # X20 与 X0 高度相关
X[:, 21] = X[:, 1] + np.random.normal(0, 0.1, n_samples)  # X21 与 X1 高度相关

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

scaler = StandardScaler()
X_train_s = scaler.fit_transform(X_train)
X_test_s = scaler.transform(X_test)

# === OLS ===
from sklearn.linear_model import LinearRegression
ols = LinearRegression().fit(X_train_s, y_train)
print(f"OLS:  R² = {ols.score(X_test_s, y_test):.4f}, MSE = {mean_squared_error(y_test, ols.predict(X_test_s)):.4f}")
print(f"  非零系数: {np.sum(np.abs(ols.coef_) > 1e-6)}/{n_features}")

# === Ridge ===
ridge_cv = RidgeCV(alphas=np.logspace(-3, 3, 100), cv=5).fit(X_train_s, y_train)
print(f"\nRidge (α={ridge_cv.alpha_:.4f}):  R² = {ridge_cv.score(X_test_s, y_test):.4f}, "
      f"MSE = {mean_squared_error(y_test, ridge_cv.predict(X_test_s)):.4f}")
print(f"  非零系数: {np.sum(np.abs(ridge_cv.coef_) > 1e-6)}/{n_features}")

# === LASSO ===
lasso_cv = LassoCV(alphas=np.logspace(-3, 1, 100), cv=5, random_state=42).fit(X_train_s, y_train)
print(f"\nLASSO (α={lasso_cv.alpha_:.4f}):  R² = {lasso_cv.score(X_test_s, y_test):.4f}, "
      f"MSE = {mean_squared_error(y_test, lasso_cv.predict(X_test_s)):.4f}")
print(f"  非零系数: {np.sum(np.abs(lasso_cv.coef_) > 1e-6)}/{n_features}")
print(f"  选中的特征: {np.where(np.abs(lasso_cv.coef_) > 1e-6)[0]}")

# === Elastic Net ===
from sklearn.linear_model import ElasticNetCV
enet_cv = ElasticNetCV(l1_ratio=[0.1, 0.3, 0.5, 0.7, 0.9, 0.99], 
                       alphas=np.logspace(-3, 1, 50), cv=5, random_state=42).fit(X_train_s, y_train)
print(f"\nElastic Net (α={enet_cv.alpha_:.4f}, l1_ratio={enet_cv.l1_ratio_:.2f}):  "
      f"R² = {enet_cv.score(X_test_s, y_test):.4f}, "
      f"MSE = {mean_squared_error(y_test, enet_cv.predict(X_test_s)):.4f}")
print(f"  非零系数: {np.sum(np.abs(enet_cv.coef_) > 1e-6)}/{n_features}")

# 系数对比
print(f"\n=== 系数对比（真实非零: {np.where(np.abs(true_coef) > 1e-6)[0]}）===")
print(f"{'特征':>4} {'OLS':>10} {'Ridge':>10} {'LASSO':>10} {'ElasticNet':>10} {'真实值':>10}")
for i in range(n_features):
    print(f"X{i:<3} {ols.coef_[i]:>10.4f} {ridge_cv.coef_[i]:>10.4f} "
          f"{lasso_cv.coef_[i]:>10.4f} {enet_cv.coef_[i]:>10.4f} {true_coef[i]:>10.4f}")
```

### 8.3 正则化路径可视化

```python
import numpy as np
from sklearn.linear_model import lasso_path, ridge_path
from sklearn.preprocessing import StandardScaler
from sklearn.datasets import make_regression

# 生成数据
np.random.seed(42)
X, y, true_coef = make_regression(n_samples=100, n_features=15, 
                                   n_informative=5, noise=5, coef=True, random_state=42)
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# LASSO 正则化路径
alphas_lasso, coefs_lasso, _ = lasso_path(X_scaled, y, n_alphas=100)

# Ridge 正则化路径
alphas_ridge, coefs_ridge = ridge_path(X_scaled, y, alphas=np.logspace(-2, 4, 100))

print("=== LASSO 正则化路径（部分 α 值）===")
print(f"{'α':>10} {'非零系数数':>10} {'MSE':>10}")
for i in range(0, len(alphas_lasso), len(alphas_lasso)//5):
    n_nonzero = np.sum(np.abs(coefs_lasso[:, i]) > 1e-6)
    from sklearn.metrics import mean_squared_error
    y_pred = X_scaled @ coefs_lasso[:, i]
    mse = mean_squared_error(y, y_pred)
    print(f"{alphas_lasso[i]:>10.4f} {n_nonzero:>10} {mse:>10.4f}")

print(f"\n=== Ridge 正则化路径（部分 α 值）===")
print(f"{'α':>10} {'系数范数':>10}")
for i in range(0, len(alphas_ridge), len(alphas_ridge)//5):
    coef_norm = np.linalg.norm(coefs_ridge[:, i])
    print(f"{alphas_ridge[i]:>10.4f} {coef_norm:>10.4f}")
```

### 8.4 岭迹图

```python
import numpy as np
from sklearn.linear_model import Ridge
from sklearn.preprocessing import StandardScaler
from sklearn.datasets import make_regression

np.random.seed(42)
X, y = make_regression(n_samples=100, n_features=8, n_informative=4, noise=10, random_state=42)
feature_names = [f'X{i+1}' for i in range(8)]

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# 计算不同 alpha 下的系数
alphas = np.logspace(-2, 4, 200)
coefs = []
for a in alphas:
    ridge = Ridge(alpha=a)
    ridge.fit(X_scaled, y)
    coefs.append(ridge.coef_.copy())
coefs = np.array(coefs)

print("=== 岭迹图数据（部分 α 值）===")
print(f"{'α':>10}", end="")
for name in feature_names:
    print(f" {name:>8}", end="")
print()
for i in range(0, len(alphas), len(alphas)//8):
    print(f"{alphas[i]:>10.2f}", end="")
    for j in range(len(feature_names)):
        print(f" {coefs[i,j]:>8.3f}", end="")
    print()
```

---

## 九、数学建模中的应用

### 9.1 何时使用哪种方法

```
数据特点                        推荐方法
│
├── 多重共线性严重，所有变量都重要 → Ridge
├── 特征数远大于样本数（p >> n）  → LASSO 或 Elastic Net
├── 特征中有大量噪声变量          → LASSO（自动特征选择）
├── 特征间高度相关                → Elastic Net
├── 需要解释模型                  → LASSO（稀疏解）
└── 预测精度优先                  → Ridge
```

### 9.2 数学建模案例

```python
import numpy as np
from sklearn.linear_model import Ridge, Lasso, ElasticNet, RidgeCV, LassoCV
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import mean_squared_error, r2_score

np.random.seed(42)

# 模拟：预测城市空气质量（20 个候选特征，部分无关）
n = 150
# 有意义的特征
pm25_emission = np.random.normal(50, 15, n)  # PM2.5 排放量
traffic = np.random.normal(1000, 200, n)      # 交通流量
temperature = np.random.normal(25, 8, n)      # 温度
humidity = np.random.normal(60, 15, n)        # 湿度
wind_speed = np.random.normal(3, 1.5, n)      # 风速
industrial = np.random.normal(200, 50, n)     # 工业产出

# 噪声特征
noise_features = np.random.normal(0, 1, (n, 14))

# 目标变量
aqi = (0.8 * pm25_emission + 0.3 * traffic / 100 - 0.5 * wind_speed + 
       0.2 * industrial / 100 - 0.1 * temperature + np.random.normal(0, 5, n))

X = np.column_stack([pm25_emission, traffic, temperature, humidity, 
                     wind_speed, industrial, noise_features])
feature_names = ['PM25排放', '交通流量', '温度', '湿度', '风速', '工业产出'] + \
                [f'噪声{i+1}' for i in range(14)]

X_train, X_test, y_train, y_test = train_test_split(X, aqi, test_size=0.3, random_state=42)
scaler = StandardScaler()
X_train_s = scaler.fit_transform(X_train)
X_test_s = scaler.transform(X_test)

# 模型比较
print("=== 空气质量预测模型比较 ===\n")

# OLS
from sklearn.linear_model import LinearRegression
ols = LinearRegression().fit(X_train_s, y_train)
ols_pred = ols.predict(X_test_s)
print(f"{'模型':<15} {'R²':>8} {'MSE':>10} {'非零系数':>8}")
print(f"{'OLS':<15} {r2_score(y_test, ols_pred):>8.4f} {mean_squared_error(y_test, ols_pred):>10.4f} "
      f"{np.sum(np.abs(ols.coef_) > 1e-6):>8}")

# Ridge
ridge_cv = RidgeCV(cv=5).fit(X_train_s, y_train)
ridge_pred = ridge_cv.predict(X_test_s)
print(f"{'Ridge':<15} {r2_score(y_test, ridge_pred):>8.4f} {mean_squared_error(y_test, ridge_pred):>10.4f} "
      f"{np.sum(np.abs(ridge_cv.coef_) > 1e-6):>8}")

# LASSO
lasso_cv = LassoCV(cv=5, random_state=42).fit(X_train_s, y_train)
lasso_pred = lasso_cv.predict(X_test_s)
print(f"{'LASSO':<15} {r2_score(y_test, lasso_pred):>8.4f} {mean_squared_error(y_test, lasso_pred):>10.4f} "
      f"{np.sum(np.abs(lasso_cv.coef_) > 1e-6):>8}")

# Elastic Net
from sklearn.linear_model import ElasticNetCV
enet = ElasticNetCV(cv=5, random_state=42).fit(X_train_s, y_train)
enet_pred = enet.predict(X_test_s)
print(f"{'Elastic Net':<15} {r2_score(y_test, enet_pred):>8.4f} {mean_squared_error(y_test, enet_pred):>10.4f} "
      f"{np.sum(np.abs(enet.coef_) > 1e-6):>8}")

print(f"\nLASSO 选中的特征:")
for name, coef in zip(feature_names, lasso_cv.coef_):
    if abs(coef) > 1e-6:
        print(f"  {name}: {coef:.4f}")
```

---

## 关键要点

1. **Ridge 回归（L2）**通过 $\lambda\|\boldsymbol{\beta}\|_2^2$ 惩罚使系数收缩但不为零，适合多重共线性场景
2. **LASSO（L1）**通过 $\lambda\|\boldsymbol{\beta}\|_1$ 惩罚可将系数压缩为零，实现自动特征选择
3. **Elastic Net** 结合 L1 和 L2，适合 $p > n$ 和高度相关特征的场景
4. **偏差-方差权衡**是正则化的理论基础：引入偏差以降低方差，从而降低总 MSE
5. **正则化参数 $\lambda$** 通过交叉验证（如 RidgeCV、LassoCV）选择
6. Ridge 有**解析解** $(\mathbf{X}^T\mathbf{X} + \lambda\mathbf{I})^{-1}\mathbf{X}^T\mathbf{y}$，LASSO 需**迭代求解**
7. 标准化数据后再进行正则化，确保惩罚对所有变量公平
8. 数学建模中，正则化方法有助于从大量候选变量中筛选出关键影响因素
