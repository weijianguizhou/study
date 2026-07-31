# Logistic回归

## 一、概述

Logistic 回归（Logistic Regression）是一种广义线性模型，用于处理因变量为**分类变量**（尤其是二分类）的回归问题。尽管名称中有"回归"，它实际上是用于分类的方法。

### 1.1 为什么不用线性回归处理分类问题

1. **预测值超出 [0, 1] 范围**：线性回归的预测值可能超出概率的合法范围
2. **误差不满足正态分布**：二分类数据的误差是伯努利分布，非正态
3. **方差不恒定**：方差随均值变化，$Var(Y|X) = p(1-p)$

### 1.2 Logistic 回归的核心思想

通过 **logit 变换** 将线性回归的输出映射到 $(0, 1)$ 区间：

$$\text{logit}(p) = \ln\left(\frac{p}{1-p}\right) = \beta_0 + \beta_1 x_1 + \cdots + \beta_k x_k$$

等价地：

$$p = P(Y=1|X) = \frac{1}{1 + e^{-(\beta_0 + \beta_1 x_1 + \cdots + \beta_k x_k)}}$$

---

## 二、二分类 Logistic 回归

### 2.1 模型设定

**Logistic 函数（Sigmoid 函数）：**

$$\sigma(z) = \frac{1}{1 + e^{-z}}$$

其中 $z = \beta_0 + \boldsymbol{\beta}^T \mathbf{x}$。

**概率模型：**

$$P(Y=1|\mathbf{x}) = \frac{e^{\beta_0 + \boldsymbol{\beta}^T \mathbf{x}}}{1 + e^{\beta_0 + \boldsymbol{\beta}^T \mathbf{x}}}$$

### 2.2 优势比（Odds Ratio）

**优势**（Odds）：事件发生概率与不发生概率之比

$$\text{Odds} = \frac{p}{1-p} = e^{\beta_0 + \boldsymbol{\beta}^T \mathbf{x}}$$

**优势比**（Odds Ratio, OR）：两个不同条件下的优势之比

$$OR = \frac{\text{Odds}(X=x+1)}{\text{Odds}(X=x)} = e^{\beta_j}$$

- $OR > 1$：$x_j$ 增加一单位，事件发生概率增大
- $OR = 1$：$x_j$ 对事件概率无影响
- $OR < 1$：$x_j$ 增加一单位，事件发生概率减小

### 2.3 决策边界

Logistic 回归的决策边界是线性的：

$$\beta_0 + \beta_1 x_1 + \cdots + \beta_k x_k = 0$$

边界一侧预测为正类，另一侧预测为负类。

---

## 三、参数估计

### 3.1 极大似然估计

对于 $n$ 个独立观测 $(x_i, y_i)$，$y_i \in \{0, 1\}$：

**似然函数：**

$$L(\boldsymbol{\beta}) = \prod_{i=1}^{n} p_i^{y_i} (1-p_i)^{1-y_i}$$

**对数似然函数：**

$$\ell(\boldsymbol{\beta}) = \sum_{i=1}^{n} \left[ y_i \ln(p_i) + (1-y_i) \ln(1-p_i) \right]$$

$$= \sum_{i=1}^{n} \left[ y_i (\beta_0 + \boldsymbol{\beta}^T \mathbf{x}_i) - \ln(1 + e^{\beta_0 + \boldsymbol{\beta}^T \mathbf{x}_i}) \right]$$

### 3.2 梯度上升求解

$$\frac{\partial \ell}{\partial \beta_j} = \sum_{i=1}^{n} (y_i - p_i) x_{ij}$$

**矩阵形式：**

$$\frac{\partial \ell}{\partial \boldsymbol{\beta}} = \mathbf{X}^T (\mathbf{y} - \mathbf{p})$$

**Newton-Raphson 迭代：**

$$\boldsymbol{\beta}^{(t+1)} = \boldsymbol{\beta}^{(t)} - \mathbf{H}^{-1} \nabla \ell(\boldsymbol{\beta}^{(t)})$$

其中 Hessian 矩阵为：

$$\mathbf{H} = -\mathbf{X}^T \mathbf{W} \mathbf{X}$$

$\mathbf{W}$ 为对角矩阵，$W_{ii} = p_i(1-p_i)$。

### 3.3 交叉熵损失

Logistic 回归的优化目标等价于最小化**交叉熵损失**：

$$J(\boldsymbol{\beta}) = -\frac{1}{n}\sum_{i=1}^{n}\left[y_i \ln(p_i) + (1-y_i)\ln(1-p_i)\right]$$

---

## 四、多分类 Logistic 回归

### 4.1 多项 Logistic 回归（Multinomial Logistic Regression）

对于 $K$ 个类别，以第 $K$ 类为参考：

$$\ln\frac{P(Y=k|\mathbf{x})}{P(Y=K|\mathbf{x})} = \beta_{k0} + \boldsymbol{\beta}_k^T \mathbf{x}, \quad k=1,\ldots,K-1$$

$$P(Y=k|\mathbf{x}) = \frac{e^{\beta_{k0} + \boldsymbol{\beta}_k^T \mathbf{x}}}{1 + \sum_{j=1}^{K-1} e^{\beta_{j0} + \boldsymbol{\beta}_j^T \mathbf{x}}}$$

### 4.2 Softmax 函数

$$P(Y=k|\mathbf{x}) = \frac{e^{\mathbf{w}_k^T \mathbf{x} + b_k}}{\sum_{j=1}^{K} e^{\mathbf{w}_j^T \mathbf{x} + b_j}}$$

---

## 五、模型诊断

### 5.1 模型评估指标

**混淆矩阵：**

|  | 预测正 | 预测负 |
|--|--------|--------|
| 实际正 | TP（真阳性） | FN（假阴性） |
| 实际负 | FP（假阳性） | TN（真阴性） |

**准确率：**

$$\text{Accuracy} = \frac{TP + TN}{TP + TN + FP + FN}$$

**精确率和召回率：**

$$\text{Precision} = \frac{TP}{TP + FP}, \quad \text{Recall} = \frac{TP}{TP + FN}$$

**F1 分数：**

$$F_1 = \frac{2 \cdot \text{Precision} \cdot \text{Recall}}{\text{Precision} + \text{Recall}}$$

**ROC 曲线与 AUC：**

ROC 曲线是以不同阈值下的 **假阳性率（FPR）** 为横轴、**真阳性率（TPR）** 为纵轴绘制的曲线。AUC 为曲线下面积，$AUC = 0.5$ 表示随机猜测，$AUC = 1$ 表示完美分类。

### 5.2 模型拟合优度

**Hosmer-Lemeshow 检验：**

将样本按预测概率分组，检验每组的实际比例与预测比例是否一致：

$$HL = \sum_{g=1}^{G} \frac{(O_g - n_g \bar{p}_g)^2}{n_g \bar{p}_g (1 - \bar{p}_g)}$$

$HL \sim \chi^2(G-2)$，$p > 0.05$ 时模型拟合良好。

### 5.3 多重共线性

使用 VIF（方差膨胀因子）检测：

$$\text{VIF}_j = \frac{1}{1 - R_j^2}$$

$\text{VIF} > 10$ 表示严重的多重共线性。

---

## 六、Python 实现

### 6.1 从零实现 Logistic 回归

```python
import numpy as np
from scipy.optimize import minimize

class LogisticRegression:
    def __init__(self, learning_rate=0.01, n_iter=1000):
        self.lr = learning_rate
        self.n_iter = n_iter
        self.weights = None
        self.bias = None
        self.losses = []
    
    def sigmoid(self, z):
        z = np.clip(z, -500, 500)
        return 1 / (1 + np.exp(-z))
    
    def fit(self, X, y):
        n_samples, n_features = X.shape
        self.weights = np.zeros(n_features)
        self.bias = 0
        
        for _ in range(self.n_iter):
            z = X @ self.weights + self.bias
            predictions = self.sigmoid(z)
            
            # 梯度
            dw = (1/n_samples) * X.T @ (predictions - y)
            db = (1/n_samples) * np.sum(predictions - y)
            
            self.weights -= self.lr * dw
            self.bias -= self.lr * db
            
            # 记录损失
            loss = -np.mean(y * np.log(predictions + 1e-15) + 
                           (1-y) * np.log(1 - predictions + 1e-15))
            self.losses.append(loss)
    
    def predict_proba(self, X):
        return self.sigmoid(X @ self.weights + self.bias)
    
    def predict(self, X, threshold=0.5):
        return (self.predict_proba(X) >= threshold).astype(int)

# 使用示例
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

X, y = make_classification(n_samples=500, n_features=5, n_informative=3,
                           n_redundant=1, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

model = LogisticRegression(learning_rate=0.1, n_iter=1000)
model.fit(X_train_scaled, y_train)

y_pred = model.predict(X_test_scaled)
y_proba = model.predict_proba(X_test_scaled)

accuracy = np.mean(y_pred == y_test)
print(f"准确率: {accuracy:.4f}")
print(f"权重: {model.weights}")
print(f"偏置: {model.bias}")
```

### 6.2 使用 scikit-learn

```python
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import (classification_report, confusion_matrix, 
                             roc_auc_score, roc_curve)

# 生成数据
X, y = make_classification(n_samples=500, n_features=10, n_informative=5,
                           n_redundant=2, random_state=42)
feature_names = [f'X{i+1}' for i in range(X.shape[1])]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, 
                                                      random_state=42, stratify=y)

scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# 训练模型
model = LogisticRegression(penalty='l2', C=1.0, max_iter=1000, random_state=42)
model.fit(X_train_scaled, y_train)

# 预测
y_pred = model.predict(X_test_scaled)
y_proba = model.predict_proba(X_test_scaled)[:, 1]

# 评估
print("=== 模型评估 ===")
print(f"准确率: {model.score(X_test_scaled, y_test):.4f}")
print(f"AUC: {roc_auc_score(y_test, y_proba):.4f}")
print(f"\n分类报告:\n{classification_report(y_test, y_pred)}")
print(f"混淆矩阵:\n{confusion_matrix(y_test, y_pred)}")

# 交叉验证
cv_scores = cross_val_score(model, scaler.transform(X), y, cv=5, scoring='accuracy')
print(f"\n5折交叉验证准确率: {cv_scores.mean():.4f} ± {cv_scores.std():.4f}")

# 特征重要性（系数）
print(f"\n特征系数:")
for name, coef in zip(feature_names, model.coef_[0]):
    print(f"  {name}: {coef:.4f}")
print(f"  截距: {model.intercept_[0]:.4f}")

# 优势比
print(f"\n优势比 (OR = e^β):")
for name, coef in zip(feature_names, model.coef_[0]):
    print(f"  {name}: OR = {np.exp(coef):.4f}")
```

### 6.3 ROC 曲线绘制

```python
import numpy as np
from sklearn.metrics import roc_curve, auc

def plot_roc_components(y_true, y_scores):
    """计算 ROC 曲线数据"""
    fpr, tpr, thresholds = roc_curve(y_true, y_scores)
    roc_auc = auc(fpr, tpr)
    
    # 找到最优阈值（Youden's J）
    j_scores = tpr - fpr
    optimal_idx = np.argmax(j_scores)
    optimal_threshold = thresholds[optimal_idx]
    
    print(f"AUC = {roc_auc:.4f}")
    print(f"最优阈值 (Youden's J): {optimal_threshold:.4f}")
    print(f"  对应 TPR = {tpr[optimal_idx]:.4f}")
    print(f"  对应 FPR = {fpr[optimal_idx]:.4f}")
    
    return fpr, tpr, thresholds

# 使用
from sklearn.datasets import make_classification
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

X, y = make_classification(n_samples=500, n_features=5, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

scaler = StandardScaler()
X_train_s = scaler.fit_transform(X_train)
X_test_s = scaler.transform(X_test)

model = LogisticRegression(max_iter=1000)
model.fit(X_train_s, y_train)
y_proba = model.predict_proba(X_test_s)[:, 1]

fpr, tpr, thresholds = plot_roc_components(y_test, y_proba)
```

---

## 七、数学建模案例：信用评分模型

```python
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import classification_report, roc_auc_score

np.random.seed(42)

# 模拟信用评分数据
n = 1000
income = np.random.lognormal(10, 0.5, n)  # 收入
age = np.random.normal(35, 10, n).clip(18, 70)  # 年龄
debt_ratio = np.random.beta(2, 5, n)  # 负债比
credit_history = np.random.poisson(5, n)  # 信用历史长度
num_accounts = np.random.poisson(3, n)  # 账户数

# 生成违约标签（与特征相关）
logit = (-2 + 0.3 * np.log(income/10000) - 0.01 * age + 
         3 * debt_ratio - 0.1 * credit_history + 0.2 * num_accounts)
prob_default = 1 / (1 + np.exp(-logit))
default = np.random.binomial(1, prob_default)

print(f"违约率: {default.mean():.2%}")

# 构建特征矩阵
X = np.column_stack([np.log(income), age, debt_ratio, credit_history, num_accounts])
feature_names = ['log(收入)', '年龄', '负债比', '信用历史', '账户数']

X_train, X_test, y_train, y_test = train_test_split(X, default, test_size=0.3, 
                                                      random_state=42, stratify=default)

scaler = StandardScaler()
X_train_s = scaler.fit_transform(X_train)
X_test_s = scaler.transform(X_test)

# 训练模型
model = LogisticRegression(penalty='l2', C=1.0, max_iter=1000)
model.fit(X_train_s, y_train)

# 预测与评估
y_pred = model.predict(X_test_s)
y_proba = model.predict_proba(X_test_s)[:, 1]

print(f"\n=== 信用评分模型结果 ===")
print(f"AUC: {roc_auc_score(y_test, y_proba):.4f}")
print(f"\n{classification_report(y_test, y_pred)}")

# 特征分析
print(f"=== 特征系数与优势比 ===")
for name, coef in zip(feature_names, model.coef_[0]):
    print(f"  {name}: β = {coef:.4f}, OR = {np.exp(coef):.4f}")

# 风险评分计算
def compute_credit_score(proba, base_score=600, pdo=50):
    """将违约概率转换为信用评分"""
    odds = proba / (1 - proba)
    reference_odds = 0.05 / 0.95
    score = base_score + pdo / np.log(2) * (np.log(reference_odds) - np.log(odds))
    return np.clip(score, 300, 850)

test_scores = compute_credit_score(y_proba)
print(f"\n信用评分统计:")
print(f"  均值: {np.mean(test_scores):.0f}")
print(f"  标准差: {np.std(test_scores):.0f}")
print(f"  范围: [{np.min(test_scores):.0f}, {np.max(test_scores):.0f}]")
```

---

## 八、Logistic 回归的扩展

### 8.1 带正则化的 Logistic 回归

$$\min_{\boldsymbol{\beta}} \left[ -\ell(\boldsymbol{\beta}) + \lambda \|\boldsymbol{\beta}\|_p^p \right]$$

- $p=1$：LASSO（L1），产生稀疏解
- $p=2$：Ridge（L2），控制系数大小
- Elastic Net：L1 + L2 混合

### 8.2 条件 Logistic 回归

用于配对或分层数据，如病例对照研究中的匹配设计。

### 8.3 广义线性模型视角

Logistic 回归是广义线性模型的特例：
- **随机成分**：$Y \sim \text{Bernoulli}(p)$
- **系统成分**：$\eta = \mathbf{X}\boldsymbol{\beta}$
- **连接函数**：$\text{logit}(p) = \eta$（典则连接）

---

## 关键要点

1. Logistic 回归通过 **logit 连接函数** 将线性预测映射到 $(0,1)$ 概率空间
2. **优势比** $OR = e^{\beta_j}$ 直观解释各变量对事件概率的影响方向和大小
3. 参数通过**极大似然估计**（MLE）求解，优化交叉熵损失函数
4. **决策边界是线性的**，无法直接处理非线性可分问题
5. 模型评估不应只看准确率，应结合 **AUC、精确率、召回率、F1** 等指标
6. 二分类 Logistic 回归可推广为**多项 Logistic 回归**（Softmax 回归）处理多分类
7. 正则化（L1/L2）可防止过拟合，**交叉验证**选择最优正则化参数
8. Logistic 回归假设**线性 logit 关系**，可通过特征工程（多项式、交互项）扩展

## 跨领域关联
- **人工智能**：[[../../../../人工智能/机器学习与深度学习/1.机器学习概述|机器学习（二分类基线模型）]] | [[../../../../人工智能/深度学习教程/00-深度学习索引|深度学习（Softmax 多分类扩展）]]
- **计算机类**：[[../../../../计算机类/python学习/01-Python基础与数据类型|Python sklearn.linear_model.LogisticRegression 实现]] | [[../../../../计算机类/MATLAB学习/50-系统工程与总结|MATLAB fitglm]]
