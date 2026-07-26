# ARIMA 时间序列预测模型

## 一、时间序列分析基础

### 1.1 时间序列的定义

时间序列是按时间顺序排列的一组观测值 $X_1, X_2, \ldots, X_t, \ldots$。时间序列分析的目标是：

1. **描述**：理解数据的生成机制
2. **解释**：识别变量之间的关系
3. **预测**：对未来值进行预测

### 1.2 平稳性

**严平稳**：序列的联合概率分布不随时间平移而改变。

**宽平稳（弱平稳）**：满足以下三个条件：
- $E(X_t) = \mu$（常数均值）
- $\text{Var}(X_t) = \sigma^2$（常数方差）
- $\text{Cov}(X_t, X_{t+k}) = \gamma_k$（自协协只与滞后 $k$ 有关）

### 1.3 自相关函数与偏自相关函数

**自协协方差函数**：

$$\gamma_k = \text{Cov}(X_t, X_{t+k})$$

**自相关函数（ACF）**：

$$\rho_k = \frac{\gamma_k}{\gamma_0} = \frac{\text{Cov}(X_t, X_{t+k})}{\text{Var}(X_t)}$$

**偏自相关函数（PACF）**：在给定 $X_{t-1}, \ldots, X_{t-k+1}$ 的条件下，$X_t$ 与 $X_{t-k}$ 的条件相关性。

$$\phi_{kk} = \text{Corr}(X_t, X_{t-k} \mid X_{t-1}, \ldots, X_{t-k+1})$$

### 1.4 白噪声过程

若 $\{X_t\}$ 满足：
- $E(X_t) = 0$
- $\text{Var}(X_t) = \sigma^2$
- $\text{Cov}(X_t, X_s) = 0, \quad \forall t \neq s$

则称 $\{X_t\}$ 为白噪声过程，记为 $X_t \sim WN(0, \sigma^2)$。

---

## 二、ARMA 模型

### 2.1 AR(p) 模型 — 自回归模型

$p$ 阶自回归模型：

$$X_t = c + \phi_1 X_{t-1} + \phi_2 X_{t-2} + \cdots + \phi_p X_{t-p} + \varepsilon_t$$

其中 $\varepsilon_t \sim WN(0, \sigma^2)$，$\phi_1, \ldots, \phi_p$ 为自回归系数。

使用滞后算子 $B$（$BX_t = X_{t-1}$）表示：

$$\Phi(B)X_t = c + \varepsilon_t$$

其中 $\Phi(B) = 1 - \phi_1 B - \phi_2 B^2 - \cdots - \phi_p B^p$。

**平稳条件**：特征方程 $\Phi(z) = 0$ 的所有根在单位圆外（$|z| > 1$）。

### 2.2 MA(q) 模型 — 移动平均模型

$q$ 阶移动平均模型：

$$X_t = \mu + \varepsilon_t + \theta_1 \varepsilon_{t-1} + \theta_2 \varepsilon_{t-2} + \cdots + \theta_q \varepsilon_{t-q}$$

使用滞后算子表示：

$$X_t = \mu + \Theta(B)\varepsilon_t$$

其中 $\Theta(B) = 1 + \theta_1 B + \theta_2 B^2 + \cdots + \theta_q B^q$。

**可逆条件**：特征方程 $\Theta(z) = 0$ 的所有根在单位圆外。

### 2.3 ARMA(p, q) 模型

自回归移动平均模型：

$$X_t = c + \sum_{i=1}^{p}\phi_i X_{t-i} + \varepsilon_t + \sum_{j=1}^{q}\theta_j \varepsilon_{t-j}$$

$$\Phi(B)X_t = c + \Theta(B)\varepsilon_t$$

ARMA模型的ACF和PACF特征：

| 模型 | ACF | PACF |
|------|-----|------|
| AR(p) | 拖尾（指数衰减/阻尼正弦） | $p$ 步截尾 |
| MA(q) | $q$ 步截尾 | 拖尾 |
| ARMA(p,q) | 拖尾 | 拖尾 |

---

## 三、ARIMA 模型

### 3.1 差分运算

**一阶差分**：

$$\nabla X_t = X_t - X_{t-1} = (1 - B)X_t$$

**$d$ 阶差分**：

$$\nabla^d X_t = (1 - B)^d X_t = \sum_{i=0}^{d}(-1)^i \binom{d}{i} X_{t-i}$$

### 3.2 ARIMA(p, d, q) 模型

$$\Phi(B)(1-B)^d X_t = c + \Theta(B)\varepsilon_t$$

其中：
- $p$：自回归阶数
- $d$：差分阶数
- $q$：移动平均阶数

**建模步骤**：

1. **平稳性检验**：ADF检验
2. **差分处理**：对非平稳序列进行差分
3. **模型识别**：通过ACF/PACF确定 $p$ 和 $q$
4. **参数估计**：极大似然估计
5. **模型检验**：残差白噪声检验
6. **预测**

### 3.3 ADF 检验（Augmented Dickey-Fuller）

检验假设：
- $H_0$：序列有单位根（非平稳）
- $H_1$：序列平稳

回归方程：

$$\Delta X_t = \alpha + \beta t + \gamma X_{t-1} + \sum_{i=1}^{p}\delta_i \Delta X_{t-i} + \varepsilon_t$$

若 $\gamma = 0$，则存在单位根（非平稳）。

---

## 四、Box-Jenkins 方法论

### 4.1 模型识别

**确定 $d$**：观察序列图和ADF检验结果，逐步差分直至平稳。

**确定 $p$ 和 $q$**：观察差分后序列的ACF和PACF图：

| ACF表现 | PACF表现 | 模型建议 |
|---------|----------|----------|
| 截尾于 $q$ | 拖尾 | MA(q) |
| 拖尾 | 截尾于 $p$ | AR(p) |
| 拖尾 | 拖尾 | ARMA(p,q) |

**信息准则**：

$$AIC = -2\ln L + 2k$$

$$BIC = -2\ln L + k\ln n$$

其中 $L$ 为似然函数，$k$ 为参数个数，$n$ 为样本量。选择AIC或BIC最小的模型。

### 4.2 参数估计

**极大似然估计（MLE）**：

$$\hat{\theta}_{MLE} = \arg\max_{\theta} \prod_{t=1}^{n}f(X_t \mid X_{t-1}, \ldots, X_1; \theta)$$

对于高斯ARMA模型：

$$L(\theta) = (2\pi\sigma^2)^{-n/2} \exp\left(-\frac{1}{2\sigma^2}\sum_{t=1}^{n}\varepsilon_t^2(\theta)\right)$$

### 4.3 模型诊断

**残差检验**：检验残差是否为白噪声。

Ljung-Box检验统计量：

$$Q(m) = n(n+2)\sum_{k=1}^{m}\frac{\hat{\rho}_k^2}{n-k} \sim \chi^2(m-p-q)$$

若 $Q(m)$ 不显著，说明残差为白噪声，模型拟合良好。

---

## 五、Python 实现

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from statsmodels.tsa.stattools import adfuller, acf, pacf
from statsmodels.tsa.arima.model import ARIMA
from statsmodels.graphics.tsaplots import plot_acf, plot_pacf
from statsmodels.stats.diagnostic import acorr_ljungbox
import warnings
warnings.filterwarnings('ignore')

# ============ 平稳性检验 ============
def adf_test(series, name=""):
    """ADF单位根检验"""
    result = adfuller(series.dropna(), autolag='AIC')
    print(f"=== ADF检验: {name} ===")
    print(f"ADF统计量: {result[0]:.4f}")
    print(f"p值: {result[1]:.4f}")
    print(f"滞后阶数: {result[2]}")
    for key, val in result[4].items():
        print(f"  临界值({key}): {val:.4f}")
    
    if result[1] < 0.05:
        print("结论: 序列平稳 (拒绝原假设)")
        return True
    else:
        print("结论: 序列非平稳 (不拒绝原假设)")
        return False

# ============ 模型定阶 ============
def determine_order(series, max_p=5, max_q=5):
    """通过ACF和PACF确定模型阶数"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    plot_acf(series.dropna(), ax=axes[0], lags=30, alpha=0.05)
    axes[0].set_title('ACF（自相关函数）')
    
    plot_pacf(series.dropna(), ax=axes[1], lags=30, alpha=0.05)
    axes[1].set_title('PACF（偏自相关函数）')
    
    plt.tight_layout()
    plt.show()

# ============ ARIMA建模 ============
class ARIMAModel:
    """ARIMA时间序列预测模型"""
    
    def __init__(self, data, order=(1, 1, 1)):
        """
        参数:
            data: 时间序列数据
            order: (p, d, q) 阶数
        """
        self.data = np.array(data, dtype=float)
        self.order = order
        self.model = None
        self.results = None
        
    def check_stationarity(self):
        """检查并报告平稳性"""
        result = adfuller(self.data, autolag='AIC')
        return {
            'statistic': result[0],
            'p_value': result[1],
            'critical_values': result[4],
            'is_stationary': result[1] < 0.05
        }
    
    def difference(self, d=None):
        """差分处理"""
        if d is None:
            d = self.order[1]
        
        series = self.data.copy()
        for _ in range(d):
            series = np.diff(series)
        return series
    
    def fit(self, method='innovations'):
        """拟合ARIMA模型"""
        self.model = ARIMA(self.data, order=self.order)
        self.results = self.model.fit(method=method)
        return self
    
    def predict(self, steps=1, alpha=0.05):
        """预测未来值"""
        forecast = self.results.get_forecast(steps=steps)
        mean = forecast.predicted_mean
        conf_int = forecast.conf_int(alpha=alpha)
        
        return {
            'mean': mean,
            'lower': conf_int[:, 0],
            'upper': conf_int[:, 1]
        }
    
    def diagnostic(self):
        """模型诊断"""
        residuals = self.results.resid
        
        fig, axes = plt.subplots(2, 2, figsize=(14, 10))
        
        # 残差时序图
        axes[0, 0].plot(residuals)
        axes[0, 0].set_title('残差时序图')
        axes[0, 0].axhline(y=0, color='r', linestyle='--')
        
        # 残差直方图
        axes[0, 1].hist(residuals, bins=30, edgecolor='black', alpha=0.7, density=True)
        x = np.linspace(min(residuals), max(residuals), 100)
        axes[0, 1].plot(x, 1/(np.std(residuals)*np.sqrt(2*np.pi)) * 
                        np.exp(-0.5*((x-np.mean(residuals))/np.std(residuals))**2),
                        'r-', linewidth=2)
        axes[0, 1].set_title('残差分布')
        
        # 残差ACF
        plot_acf(residuals.dropna() if hasattr(residuals, 'dropna') else residuals, 
                ax=axes[1, 0], lags=30)
        axes[1, 0].set_title('残差ACF')
        
        # 残差Q-Q图
        from scipy import stats
        stats.probplot(residuals, dist="norm", plot=axes[1, 1])
        axes[1, 1].set_title('Q-Q图')
        
        plt.tight_layout()
        plt.show()
        
        # Ljung-Box检验
        lb_test = acorr_ljungbox(residuals, lags=10, return_df=True)
        print("\nLjung-Box检验:")
        print(lb_test)
        
        return residuals
    
    def summary(self):
        """输出模型摘要"""
        print("=" * 60)
        print(f"ARIMA{self.order} 模型摘要")
        print("=" * 60)
        print(self.results.summary())
        print("=" * 60)
    
    def aic_bic_search(self, max_p=4, max_d=2, max_q=4):
        """网格搜索最优阶数"""
        results = []
        
        for p in range(max_p + 1):
            for d in range(max_d + 1):
                for q in range(max_q + 1):
                    if p == 0 and q == 0:
                        continue
                    try:
                        model = ARIMA(self.data, order=(p, d, q))
                        fit = model.fit(method='innovations')
                        results.append({
                            'order': (p, d, q),
                            'aic': fit.aic,
                            'bic': fit.bic
                        })
                    except:
                        continue
        
        results_df = pd.DataFrame(results)
        print("\n=== AIC/BIC 模型选择 ===")
        print(results_df.sort_values('aic').head(10).to_string(index=False))
        
        best_aic = results_df.loc[results_df['aic'].idxmin()]
        best_bic = results_df.loc[results_df['bic'].idxmin()]
        
        print(f"\n最优AIC模型: ARIMA{best_aic['order']}")
        print(f"最优BIC模型: ARIMA{best_bic['order']}")
        
        return results_df


# ============ 示例：空气质量指数预测 ============
np.random.seed(42)

# 模拟AQI数据（含趋势和季节性）
n = 200
t = np.arange(n)
trend = 0.1 * t
seasonal = 10 * np.sin(2 * np.pi * t / 365 * 30)  # 月度周期
noise = np.random.normal(0, 5, n)
aqi = 50 + trend + seasonal + noise

# Step 1: 平稳性检验
print("原始序列:")
stationary = adf_test(pd.Series(aqi), "AQI原始序列")

# Step 2: 差分
aqi_diff = np.diff(aqi)
print("\n一阶差分后:")
stationary_diff = adf_test(pd.Series(aqi_diff), "AQI一阶差分")

# Step 3: 查看ACF/PACF
determine_order(pd.Series(aqi_diff))

# Step 4: AIC/BIC搜索
arima_model = ARIMAModel(aqi, order=(1, 1, 1))
search_results = arima_model.aic_bic_search(max_p=3, max_d=2, max_q=3)

# Step 5: 拟合最优模型
best_order = (1, 1, 1)  # 根据搜索结果选择
best_model = ARIMAModel(aqi, order=best_order)
best_model.fit()
best_model.summary()

# Step 6: 诊断
residuals = best_model.diagnostic()

# Step 7: 预测
forecast = best_model.predict(steps=30)
print("\n未来30期预测:")
for i in range(0, 30, 5):
    print(f"  第{i+1}期: 预测={forecast['mean'][i]:.2f}, "
          f"95%CI=[{forecast['lower'][i]:.2f}, {forecast['upper'][i]:.2f}]")

# 绘图
plt.figure(figsize=(14, 6))
plt.plot(range(n), aqi, 'b-', label='历史数据', alpha=0.7)
plt.plot(range(n, n+30), forecast['mean'], 'r-', label='预测值', linewidth=2)
plt.fill_between(range(n, n+30), forecast['lower'], forecast['upper'],
                color='red', alpha=0.2, label='95%置信区间')
plt.axvline(x=n-1, color='gray', linestyle='--', alpha=0.5)
plt.xlabel('时间')
plt.ylabel('AQI')
plt.title(f'ARIMA{best_order} 预测结果')
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()
```

---

## 六、实际案例：某市月度用电量预测

### 6.1 数据准备

```python
import pandas as pd
import numpy as np

# 模拟某市月度用电量数据（2018-2023年）
np.random.seed(123)
months = pd.date_range('2018-01', '2023-12', freq='MS')
n_months = len(months)

# 趋势 + 季节性 + 噪声
trend = np.linspace(100, 180, n_months)
seasonal = 30 * np.sin(2 * np.pi * np.arange(n_months) / 12) + \
           10 * np.cos(2 * np.pi * np.arange(n_months) / 6)
noise = np.random.normal(0, 5, n_months)
electricity = trend + seasonal + noise

# 构建DataFrame
df = pd.DataFrame({'date': months, 'electricity': electricity})
df.set_index('date', inplace=True)

print("数据概况:")
print(df.describe())
```

### 6.2 建模流程

```python
# Step 1: 时序图观察
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# 时序图
axes[0, 0].plot(df['electricity'])
axes[0, 0].set_title('月度用电量时序图')

# 自相关图
plot_acf(df['electricity'], ax=axes[0, 1], lags=36)
axes[0, 1].set_title('ACF')

# 一阶差分
df['electricity_diff1'] = df['electricity'].diff()
axes[1, 0].plot(df['electricity_diff1'])
axes[1, 0].set_title('一阶差分')

# 季节差分（滞后12）
df['electricity_diff12'] = df['electricity_diff1'].diff(12)
axes[1, 1].plot(df['electricity_diff12'])
axes[1, 1].set_title('一阶差分 + 季节差分')

plt.tight_layout()
plt.show()

# Step 2: ADF检验
print("一阶差分+季节差分后:")
adf_test(df['electricity_diff12'].dropna())

# Step 3: 拟合SARIMA模型
from statsmodels.tsa.statespace.sarimax import SARIMAX

# SARIMA(p,d,q)(P,D,Q,s)
# s=12（月度季节性）
model = SARIMAX(df['electricity'], 
                order=(1, 1, 1),
                seasonal_order=(1, 1, 1, 12),
                enforce_stationarity=False,
                enforce_invertibility=False)
results = model.fit(disp=False)

print(results.summary())

# Step 4: 残差诊断
residuals = results.resid
fig, axes = plt.subplots(1, 2, figsize=(14, 5))
plot_acf(residuals.dropna(), ax=axes[0], lags=36)
plot_pacf(residuals.dropna(), ax=axes[1], lags=36)
plt.suptitle('残差ACF和PACF')
plt.tight_layout()
plt.show()

# Step 5: 预测
forecast = results.get_forecast(steps=24)
pred_mean = forecast.predicted_mean
conf_int = forecast.conf_int(alpha=0.05)

# 绘制预测结果
plt.figure(figsize=(14, 6))
plt.plot(df['electricity'], 'b-', label='历史数据')
plt.plot(pred_mean.index, pred_mean, 'r-', label='预测值', linewidth=2)
plt.fill_between(pred_mean.index, 
                conf_int.iloc[:, 0], conf_int.iloc[:, 1],
                color='red', alpha=0.2, label='95%置信区间')
plt.title('SARIMA月度用电量预测')
plt.xlabel('日期')
plt.ylabel('用电量')
plt.legend()
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()
```

### 6.3 预测精度评估

```python
from sklearn.metrics import mean_absolute_error, mean_squared_error

# 训练集/测试集分割
train = df['electricity'][:-12]
test = df['electricity'][-12:]

# 重新拟合
model_eval = SARIMAX(train, order=(1,1,1), seasonal_order=(1,1,1,12),
                     enforce_stationarity=False, enforce_invertibility=False)
results_eval = model_eval.fit(disp=False)

# 预测测试集
forecast_eval = results_eval.get_forecast(steps=12)
pred = forecast_eval.predicted_mean

# 计算误差
mae = mean_absolute_error(test, pred)
rmse = np.sqrt(mean_squared_error(test, pred))
mape = np.mean(np.abs((test - pred) / test)) * 100

print(f"MAE: {mae:.2f}")
print(f"RMSE: {rmse:.2f}")
print(f"MAPE: {mape:.2f}%")
```

---

## 七、季节性 SARIMA 模型

### 7.1 SARIMA(p,d,q)(P,D,Q)$_s$ 模型

$$\Phi_P(B^s)\Phi(B)(1-B^s)^D(1-B)^d X_t = \Theta_Q(B^s)\Theta(B)\varepsilon_t$$

其中：
- $s$：季节周期（月度数据 $s=12$，季度数据 $s=4$）
- $P, D, Q$：季节性自回归、差分、移动平均阶数
- $\Phi_P(B^s) = 1 - \Phi_1 B^s - \cdots - \Phi_P B^{Ps}$
- $\Theta_Q(B^s) = 1 + \Theta_1 B^s + \cdots + \Theta_Q B^{Qs}$

### 7.2 模型选择策略

1. 先确定 $d$ 和 $D$：通过ADF检验和观察时序图
2. 再确定 $p, q, P, Q$：通过ACF/PACF和信息准则
3. 使用网格搜索结合AIC/BIC选择最优参数

---

## 八、关键要点总结

1. **平稳性是ARIMA模型的前提**：非平稳序列需先差分
2. **ACF/PACF是模型定阶的关键工具**：
   - AR模型：PACF截尾
   - MA模型：ACF截尾
   - ARMA模型：ACF和PACF均拖尾
3. **差分阶数 $d$ 通常不超过2**：过度差分会导致方差增大
4. **信息准则（AIC/BIC）**用于模型选择，平衡拟合优度与复杂度
5. **残差必须通过白噪声检验**：Ljung-Box检验
6. **季节性数据用SARIMA**：引入季节差分和季节性AR/MA项
7. **预测精度用MAE、RMSE、MAPE评估**
8. **ARIMA的局限**：只能捕捉线性关系，对非线性模式无能为力
