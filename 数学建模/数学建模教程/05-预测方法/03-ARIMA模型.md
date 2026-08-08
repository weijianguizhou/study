# ARIMA 时间序列预测模型

> **理论基础** → 参见 [[../../时间序列分析/ARIMA模型|ARIMA模型]]

ARIMA模型将自回归(AR)、差分(I)、移动平均(MA)结合，是处理非平稳时间序列的经典预测方法。

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
