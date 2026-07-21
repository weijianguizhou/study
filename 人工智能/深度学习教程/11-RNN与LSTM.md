# RNN与LSTM

## 1. 序列建模的挑战

### 1.1 为什么需要RNN？

传统前馈网络假设输入之间是**独立同分布**的，无法捕捉时间依赖关系。序列数据的特点：

- **可变长度**：序列长度不固定
- **时间依赖**：当前位置的输出依赖于之前的上下文
- **参数共享**：需要跨时间步共享模式（平移不变性）

应用场景：自然语言处理、语音识别、时间序列预测、视频理解、音乐生成。

### 1.2 序列建模基础

给定输入序列 $\mathbf{x}_{1:T} = (\mathbf{x}_1, \mathbf{x}_2, ..., \mathbf{x}_T)$，目标是：

- **序列到序列** (Seq2Seq)：$\mathbf{y}_{1:T} = f(\mathbf{x}_{1:T})$ —— 机器翻译、词性标注
- **序列到向量** (Seq2Vec)：$\mathbf{y} = f(\mathbf{x}_{1:T})$ —— 情感分类、文本分类
- **向量到序列** (Vec2Seq)：$\mathbf{y}_{1:T} = f(\mathbf{x})$ —— 图像描述生成

## 2. 循环神经网络 (RNN)

### 2.1 数学定义

RNN在每个时间步共享参数，维护一个**隐藏状态** $\mathbf{h}_t$ 来存储历史信息：

$$
\begin{aligned}
\mathbf{h}_t &= \tanh(\mathbf{W}_{xh}\mathbf{x}_t + \mathbf{W}_{hh}\mathbf{h}_{t-1} + \mathbf{b}_h) \\
\mathbf{y}_t &= \mathbf{W}_{hy}\mathbf{h}_t + \mathbf{b}_y
\end{aligned}
$$

其中：
- $\mathbf{W}_{xh}$：输入到隐藏层的权重矩阵
- $\mathbf{W}_{hh}$：隐藏层到隐藏层的**循环权重**（核心！）
- $\mathbf{h}_t$：$t$ 时刻的隐藏状态，编码了从 $1$ 到 $t$ 的信息

### 2.2 展开图

```
    y₁      y₂      y₃      y₄
    ↑       ↑       ↑       ↑
    h₀ → h₁ → h₂ → h₃ → h₄
    ↑    ↑    ↑    ↑    ↑
    x₁   x₂   x₃   x₄
```

RNN按时间展开后，形成一个深度为 $T$ 的网络。所有时间步共享同一组参数 $\mathbf{W}_{xh}, \mathbf{W}_{hh}, \mathbf{W}_{hy}$。

### 2.3 通过时间的反向传播 (BPTT)

BPTT本质上是在时间展开的网络上应用反向传播。以MSE损失为例：

对于输出损失 $L = \sum_{t=1}^T L_t$，关于 $\mathbf{W}_{hh}$ 的梯度：

$$
\frac{\partial L}{\partial \mathbf{W}_{hh}} = \sum_{t=1}^T \frac{\partial L_t}{\partial \mathbf{W}_{hh}}
$$

对于单个时间步 $t$，通过链式法则：

$$
\frac{\partial L_t}{\partial \mathbf{W}_{hh}} = \sum_{k=1}^t \frac{\partial L_t}{\partial \mathbf{h}_t} \cdot \frac{\partial \mathbf{h}_t}{\partial \mathbf{h}_k} \cdot \frac{\partial \mathbf{h}_k}{\partial \mathbf{W}_{hh}}
$$

其中雅可比矩阵 $\frac{\partial \mathbf{h}_t}{\partial \mathbf{h}_k}$ 是一个大乘积：

$$
\frac{\partial \mathbf{h}_t}{\partial \mathbf{h}_k} = \prod_{j=k+1}^t \frac{\partial \mathbf{h}_j}{\partial \mathbf{h}_{j-1}}
$$

而 $\frac{\partial \mathbf{h}_j}{\partial \mathbf{h}_{j-1}} = \text{diag}(\tanh'(\cdot)) \cdot \mathbf{W}_{hh}$。

**问题**：这个乘积导致梯度消失（当 $\|\mathbf{W}_{hh}\| < 1$）或梯度爆炸（当 $\|\mathbf{W}_{hh}\| > 1$）。

### 2.4 RNN的梯度问题详解

令 $\mathbf{J}_t = \frac{\partial \mathbf{h}_t}{\partial \mathbf{h}_{t-1}}$。假设 $\mathbf{W}_{hh}$ 可对角化：

$$
\mathbf{J}_t = \mathbf{V} \text{diag}(\lambda_1, ..., \lambda_d) \mathbf{V}^{-1} \cdot \text{diag}(\tanh'(\cdot))
$$

长期依赖 $\frac{\partial \mathbf{h}_T}{\partial \mathbf{h}_k}$ 包含 $\mathbf{J}_t$ 的连乘，其范数以 $|\lambda_{\max}|^{T-k}$ 缩放：
- 若 $|\lambda_{\max}| < 1$：梯度指数衰减（梯度消失）
- 若 $|\lambda_{\max}| > 1$：梯度指数增长（梯度爆炸）

```python
# RNN从零实现 (Numpy)
import numpy as np
import matplotlib.pyplot as plt

class RNN_Numpy:
    """Numpy实现的简单RNN"""

    def __init__(self, input_size, hidden_size, output_size):
        self.hidden_size = hidden_size

        # 权重初始化
        self.W_xh = np.random.randn(input_size, hidden_size) * 0.01
        self.W_hh = np.random.randn(hidden_size, hidden_size) * 0.01
        self.b_h = np.zeros((1, hidden_size))
        self.W_hy = np.random.randn(hidden_size, output_size) * 0.01
        self.b_y = np.zeros((1, output_size))

    def forward(self, inputs, h_prev=None):
        """
        inputs: 时间步列表 [(1, input_size), ...]
        Returns: hiddens, outputs
        """
        T = len(inputs)
        if h_prev is None:
            h_prev = np.zeros((1, self.hidden_size))

        hiddens = {0: h_prev}
        outputs = {}

        h = h_prev
        for t in range(1, T + 1):
            x = inputs[t-1]
            h = np.tanh(x @ self.W_xh + h @ self.W_hh + self.b_h)
            y = h @ self.W_hy + self.b_y
            hiddens[t] = h
            outputs[t] = y

        return hiddens, outputs

    def backward(self, inputs, targets, hiddens, outputs, lr=0.01):
        """BPTT实现"""
        T = len(inputs)

        # 初始化梯度
        dW_xh = np.zeros_like(self.W_xh)
        dW_hh = np.zeros_like(self.W_hh)
        db_h = np.zeros_like(self.b_h)
        dW_hy = np.zeros_like(self.W_hy)
        db_y = np.zeros_like(self.b_y)

        dh_next = np.zeros((1, self.hidden_size))  # 从未来传递来的隐藏梯度

        # 从后往前遍历时间步
        for t in range(T, 0, -1):
            # 输出层梯度
            dy = outputs[t] - targets[t-1]  # dL/dy
            dW_hy += hiddens[t].T @ dy
            db_y += dy

            # 隐藏层梯度 (从输出和未来状态两部分)
            dh = dy @ self.W_hy.T + dh_next

            # tanh导数
            dtanh = 1 - hiddens[t] ** 2
            dz = dh * dtanh  # dL/dz (z = W_xh·x + W_hh·h + b_h)

            # 计算各权重梯度
            dW_xh += inputs[t-1].T @ dz
            dW_hh += hiddens[t-1].T @ dz
            db_h += dz

            # 将梯度传递到上一个隐藏状态
            dh_next = dz @ self.W_hh.T

        # 梯度裁剪（防止梯度爆炸）
        max_norm = 5.0
        for grad in [dW_xh, dW_hh, db_h, dW_hy, db_y]:
            norm = np.linalg.norm(grad)
            if norm > max_norm:
                grad *= max_norm / norm

        # 更新参数
        self.W_xh -= lr * dW_xh
        self.W_hh -= lr * dW_hh
        self.b_h -= lr * db_h
        self.W_hy -= lr * dW_hy
        self.b_y -= lr * db_y


# 使用RNN进行正弦波预测
def generate_sine_data(seq_length=100, n_sequences=500):
    """生成正弦波预测数据: 用前10个点预测第11个点"""
    X, y = [], []
    for _ in range(n_sequences):
        freq = np.random.uniform(0.5, 3.0)
        phase = np.random.uniform(0, 2 * np.pi)
        t = np.arange(seq_length) * 0.1
        wave = np.sin(freq * t + phase)

        X.append(wave[:-1].reshape(-1, 1, 1))
        y.append(wave[1:].reshape(-1, 1, 1))

    return np.vstack(X), np.vstack(y)


# 训练小RNN
np.random.seed(42)

# 生成简单序列数据
seq_data = generate_sine_data(seq_length=20, n_sequences=200)
X_data, y_data = seq_data

# 使用PyTorch进行完整训练
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, TensorDataset

class SimpleRNN(nn.Module):
    def __init__(self, input_size=1, hidden_size=32, output_size=1, num_layers=1):
        super().__init__()
        self.rnn = nn.RNN(input_size, hidden_size, num_layers,
                          batch_first=True, nonlinearity='tanh')
        self.fc = nn.Linear(hidden_size, output_size)

    def forward(self, x):
        out, _ = self.rnn(x)
        out = self.fc(out)
        return out


# 正弦波预测演示
def demo_rnn_wave_prediction():
    torch.manual_seed(42)

    # 生成正弦波序列
    t = np.linspace(0, 4 * np.pi, 200)
    wave = np.sin(t) + 0.1 * np.random.randn(200)

    # 构建监督学习数据: 用 seq_len 个点预测下一个
    seq_len = 20

    def create_sequences(data, seq_len):
        X, y = [], []
        for i in range(len(data) - seq_len):
            X.append(data[i:i+seq_len])
            y.append(data[i+seq_len])
        return (np.array(X).reshape(-1, seq_len, 1).astype(np.float32),
                np.array(y).reshape(-1, 1).astype(np.float32))

    X, y = create_sequences(wave, seq_len)
    X_train, y_train = X[:140], y[:140]
    X_test, y_test = X[140:], y[140:]

    X_train_t = torch.from_numpy(X_train)
    y_train_t = torch.from_numpy(y_train)
    X_test_t = torch.from_numpy(X_test)
    y_test_t = torch.from_numpy(y_test)

    # 训练RNN
    model = SimpleRNN(input_size=1, hidden_size=32, output_size=1)
    optimizer = optim.Adam(model.parameters(), lr=0.01)
    criterion = nn.MSELoss()

    losses = []
    for epoch in range(300):
        optimizer.zero_grad()
        pred = model(X_train_t)
        loss = criterion(pred[:, -1, :], y_train_t)
        loss.backward()
        optimizer.step()
        losses.append(loss.item())
        if epoch % 50 == 0:
            print(f'Epoch {epoch:3d}, Loss: {loss.item():.6f}')

    # 评估
    model.eval()
    with torch.no_grad():
        test_pred = model(X_test_t)[:, -1, :].numpy()
        test_loss = np.mean((test_pred - y_test) ** 2)

    # 可视化
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    axes[0].plot(wave, 'b-', alpha=0.5, label='真实波形')
    axes[0].axvline(x=140+seq_len-1, color='red', linestyle='--', label='训练/测试分界')

    # 测试集预测
    test_predictions = np.full_like(wave, np.nan)
    test_predictions[140+seq_len:] = test_pred.flatten()
    axes[0].plot(test_predictions, 'r-', linewidth=2, label='RNN预测')
    axes[0].set_title(f'正弦波预测 (Test MSE: {test_loss:.6f})')
    axes[0].set_xlabel('时间步')
    axes[0].set_ylabel('幅值')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(losses)
    axes[1].set_title('训练损失')
    axes[1].set_xlabel('Epoch')
    axes[1].set_ylabel('MSE Loss')
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.show()

demo_rnn_wave_prediction()
```

## 3. 长短期记忆网络 (LSTM)

### 3.1 核心问题

RNN的隐藏状态 $\mathbf{h}_t$ 每次被完全重写，没有机制选择性地保留或遗忘信息。LSTM通过**门控机制**显式控制信息流。

### 3.2 LSTM的门控机制

LSTM维持两个状态：
- **细胞状态** $\mathbf{c}_t$：长期记忆管线（信息高速公路）
- **隐藏状态** $\mathbf{h}_t$：当前时刻的输出

三个门控制信息流：

#### 遗忘门 (Forget Gate)
$$
\mathbf{f}_t = \sigma(\mathbf{W}_f \cdot [\mathbf{h}_{t-1}, \mathbf{x}_t] + \mathbf{b}_f)
$$
决定从细胞状态中遗忘多少旧信息（0=全部遗忘，1=全部保留）。

#### 输入门 (Input Gate)
$$
\begin{aligned}
\mathbf{i}_t &= \sigma(\mathbf{W}_i \cdot [\mathbf{h}_{t-1}, \mathbf{x}_t] + \mathbf{b}_i) \\
\tilde{\mathbf{c}}_t &= \tanh(\mathbf{W}_c \cdot [\mathbf{h}_{t-1}, \mathbf{x}_t] + \mathbf{b}_c)
\end{aligned}
$$
$\mathbf{i}_t$ 决定哪些新信息写入细胞状态；$\tilde{\mathbf{c}}_t$ 是新候选值。

#### 细胞状态更新
$$
\mathbf{c}_t = \mathbf{f}_t \odot \mathbf{c}_{t-1} + \mathbf{i}_t \odot \tilde{\mathbf{c}}_t
$$

#### 输出门 (Output Gate)
$$
\begin{aligned}
\mathbf{o}_t &= \sigma(\mathbf{W}_o \cdot [\mathbf{h}_{t-1}, \mathbf{x}_t] + \mathbf{b}_o) \\
\mathbf{h}_t &= \mathbf{o}_t \odot \tanh(\mathbf{c}_t)
\end{aligned}
$$

### 3.3 为什么LSTM缓解梯度消失？

在反向传播时，细胞状态的梯度为：

$$
\frac{\partial \mathbf{c}_t}{\partial \mathbf{c}_{t-1}} = \mathbf{f}_t
$$

这是一个逐元素乘法（而非矩阵乘法），梯度可以通过遗忘门 $\mathbf{f}_t$ 在时间维度上有效地传播——如果 $\mathbf{f}_t \approx 1$，梯度无损传递。

```python
# LSTM从零实现 (Numpy)
import numpy as np

def sigmoid(x):
    return 1 / (1 + np.exp(-np.clip(x, -500, 500)))

class LSTM_Numpy:
    """Numpy实现LSTM (用于教育目的)"""

    def __init__(self, input_size, hidden_size):
        self.hidden_size = hidden_size

        # 合并权重 (四个门一起)
        concat_size = input_size + hidden_size
        # 遗忘门, 输入门, 细胞候选, 输出门 → 4倍
        self.W = np.random.randn(concat_size, 4 * hidden_size) * 0.01
        self.b = np.zeros((1, 4 * hidden_size))

    def forward(self, x, h_prev=None, c_prev=None):
        """
        x: (1, input_size)
        h_prev: (1, hidden_size), 上一时刻隐藏状态
        c_prev: (1, hidden_size), 上一时刻细胞状态
        """
        if h_prev is None:
            h_prev = np.zeros((1, self.hidden_size))
        if c_prev is None:
            c_prev = np.zeros((1, self.hidden_size))

        # 拼接输入与隐藏状态
        concat = np.hstack([h_prev, x])  # (1, input_size + hidden_size)

        # 一次矩阵乘法计算四个门
        gates = concat @ self.W + self.b  # (1, 4 * hidden_size)

        # 分割
        i = sigmoid(gates[:, 0 * self.hidden_size:1 * self.hidden_size])
        f = sigmoid(gates[:, 1 * self.hidden_size:2 * self.hidden_size])
        o = sigmoid(gates[:, 2 * self.hidden_size:3 * self.hidden_size])
        g = np.tanh(gates[:, 3 * self.hidden_size:4 * self.hidden_size])

        # 更新状态
        c = f * c_prev + i * g
        h = o * np.tanh(c)

        # 缓存中间值供反向传播使用
        self.cache = (x, h_prev, c_prev, concat, i, f, o, g, c, h)

        return h, c


# PyTorch LSTM示例
import torch
import torch.nn as nn

class LSTMModel(nn.Module):
    """PyTorch LSTM模型"""

    def __init__(self, input_size, hidden_size, num_layers, output_size,
                 dropout=0.0, bidirectional=False):
        super(LSTMModel, self).__init__()
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        self.bidirectional = bidirectional

        self.lstm = nn.LSTM(
            input_size=input_size,
            hidden_size=hidden_size,
            num_layers=num_layers,
            batch_first=True,
            dropout=dropout if num_layers > 1 else 0,
            bidirectional=bidirectional
        )

        D = 2 if bidirectional else 1
        self.fc = nn.Linear(D * hidden_size, output_size)

    def forward(self, x):
        lstm_out, (h_n, c_n) = self.lstm(x)
        # 取最后一个时间步的输出（或全局平均池化）
        out = lstm_out[:, -1, :]  # (batch, hidden_size * D)
        out = self.fc(out)
        return out


# 测试LSTM
model = LSTMModel(input_size=10, hidden_size=64, num_layers=2,
                   output_size=3, dropout=0.3, bidirectional=True)
x = torch.randn(32, 20, 10)  # (batch, seq_len, input_size)
y = model(x)
print(f"LSTM: {x.shape} → {y.shape}")
print(f"参数量: {sum(p.numel() for p in model.parameters()):,}")

# LSTM内部参数结构
lstm_cell = nn.LSTMCell(10, 64)
print(f"\nLSTMCell参数 (input_size=10, hidden_size=64):")
print(f"  W_ih: {lstm_cell.weight_ih.shape} (4*hidden × input)")
print(f"  W_hh: {lstm_cell.weight_hh.shape} (4*hidden × hidden)")
print(f"  b_ih: {lstm_cell.bias_ih.shape}")
print(f"  b_hh: {lstm_cell.bias_hh.shape}")
```

## 4. 门控循环单元 (GRU)

### 4.1 GRU vs LSTM

GRU是LSTM的简化版，只有两个门（重置门和更新门），没有独立的细胞状态：

$$
\begin{aligned}
\mathbf{r}_t &= \sigma(\mathbf{W}_r \cdot [\mathbf{h}_{t-1}, \mathbf{x}_t]) \quad \text{重置门} \\
\mathbf{z}_t &= \sigma(\mathbf{W}_z \cdot [\mathbf{h}_{t-1}, \mathbf{x}_t]) \quad \text{更新门} \\
\tilde{\mathbf{h}}_t &= \tanh(\mathbf{W} \cdot [\mathbf{r}_t \odot \mathbf{h}_{t-1}, \mathbf{x}_t]) \quad \text{候选隐藏状态} \\
\mathbf{h}_t &= (1 - \mathbf{z}_t) \odot \mathbf{h}_{t-1} + \mathbf{z}_t \odot \tilde{\mathbf{h}}_t
\end{aligned}
$$

| 方面 | LSTM | GRU |
|------|------|-----|
| 门数量 | 3 (f, i, o) | 2 (r, z) |
| 状态数量 | 2 (c, h) | 1 (h) |
| 参数量 | 较多 | 较少 (~75%) |
| 训练速度 | 较慢 | 较快 |
| 效果 | 略好（大数据集） | 相当（小数据集） |

## 5. 双向LSTM (BiLSTM)

BiLSTM在序列上同时运行两个方向的LSTM：

$$
\begin{aligned}
\overrightarrow{\mathbf{h}}_t &= \text{LSTM}_\rightarrow(\mathbf{x}_t, \overrightarrow{\mathbf{h}}_{t-1}) \\
\overleftarrow{\mathbf{h}}_t &= \text{LSTM}_\leftarrow(\mathbf{x}_t, \overleftarrow{\mathbf{h}}_{t+1}) \\
\mathbf{h}_t^{\text{bi}} &= [\overrightarrow{\mathbf{h}}_t; \overleftarrow{\mathbf{h}}_t]
\end{aligned}
$$

双向LSTM能够同时访问前后上下文，在序列标注（NER、POS）等任务中至关重要。

## 6. 注意力机制 (Attention)

### 6.1 编码器-解码器的问题

传统的Seq2Seq模型将整个输入序列压缩为一个固定长度的**上下文向量** $\mathbf{c}$（编码器最后的隐藏状态），这导致：
- 信息瓶颈：长序列信息丢失
- 无法对齐：不知道输出的每个词应该"关注"输入的哪些部分

### 6.2 Bahdanau 注意力 (Additive Attention)

$$
\begin{aligned}
e_{t,j} &= \mathbf{v}^T \tanh(\mathbf{W}_a \mathbf{s}_{t-1} + \mathbf{U}_a \mathbf{h}_j) \\
\alpha_{t,j} &= \frac{\exp(e_{t,j})}{\sum_{k=1}^T \exp(e_{t,k})} \\
\mathbf{c}_t &= \sum_{j=1}^T \alpha_{t,j} \mathbf{h}_j
\end{aligned}
$$

其中 $\mathbf{s}_{t-1}$ 是解码器状态，$\mathbf{h}_j$ 是编码器第 $j$ 步的隐藏状态，$\alpha_{t,j}$ 是**注意力权重**。

### 6.3 Luong 注意力 (Multiplicative Attention)

$$
\begin{aligned}
\text{score}(\mathbf{s}_t, \mathbf{h}_j) &= \begin{cases}
\mathbf{s}_t^T \mathbf{h}_j & \text{(dot)} \\
\mathbf{s}_t^T \mathbf{W}_a \mathbf{h}_j & \text{(general)} \\
\mathbf{W}_a[\mathbf{s}_t; \mathbf{h}_j] & \text{(concat)}
\end{cases}
\end{aligned}
$$

Luong注意力计算更高效（矩阵乘法），且将注意力放在计算当前解码器状态 $\mathbf{s}_t$ 之后。

```python
# 注意力机制实现
import torch
import torch.nn as nn
import torch.nn.functional as F

class BahdanauAttention(nn.Module):
    """Bahdanau (Additive) 注意力"""

    def __init__(self, hidden_size):
        super().__init__()
        self.W_a = nn.Linear(hidden_size * 2, hidden_size, bias=False)
        self.v = nn.Linear(hidden_size, 1, bias=False)

    def forward(self, decoder_hidden, encoder_outputs):
        """
        decoder_hidden: (batch, hidden_size)
        encoder_outputs: (batch, seq_len, hidden_size)
        Returns: context_vector, attention_weights
        """
        seq_len = encoder_outputs.size(1)

        # 扩展decoder_hidden以匹配序列长度
        decoder_hidden = decoder_hidden.unsqueeze(1).repeat(1, seq_len, 1)

        # 拼接并计算注意力分数
        concat = torch.cat((decoder_hidden, encoder_outputs), dim=2)
        energy = self.v(torch.tanh(self.W_a(concat))).squeeze(2)  # (batch, seq_len)

        # Softmax得到注意力权重
        attn_weights = F.softmax(energy, dim=1)  # (batch, seq_len)

        # 加权求和得到上下文向量
        context = torch.bmm(attn_weights.unsqueeze(1), encoder_outputs)
        context = context.squeeze(1)  # (batch, hidden_size)

        return context, attn_weights


class LuongAttention(nn.Module):
    """Luong (Multiplicative) 注意力"""

    def __init__(self, hidden_size, method='general'):
        super().__init__()
        self.method = method
        if method == 'general':
            self.W_a = nn.Linear(hidden_size, hidden_size, bias=False)

    def forward(self, decoder_hidden, encoder_outputs):
        """
        decoder_hidden: (batch, hidden_size)
        encoder_outputs: (batch, seq_len, hidden_size)
        """
        if self.method == 'dot':
            # 点积注意力
            scores = torch.bmm(
                decoder_hidden.unsqueeze(1),  # (batch, 1, hidden)
                encoder_outputs.transpose(1, 2)  # (batch, hidden, seq_len)
            ).squeeze(1)  # (batch, seq_len)

        elif self.method == 'general':
            # 一般注意力
            scores = torch.bmm(
                self.W_a(decoder_hidden).unsqueeze(1),
                encoder_outputs.transpose(1, 2)
            ).squeeze(1)

        attn_weights = F.softmax(scores, dim=1)
        context = torch.bmm(attn_weights.unsqueeze(1), encoder_outputs).squeeze(1)

        return context, attn_weights


# 测试注意力机制
batch_size, seq_len, hidden = 4, 10, 128
encoder_out = torch.randn(batch_size, seq_len, hidden)
decoder_h = torch.randn(batch_size, hidden)

bahdanau = BahdanauAttention(hidden)
context_b, weights_b = bahdanau(decoder_h, encoder_out)
print(f"Bahdanau Attention: context={context_b.shape}, weights={weights_b.shape}")

luong = LuongAttention(hidden, method='general')
context_l, weights_l = luong(decoder_h, encoder_out)
print(f"Luong Attention: context={context_l.shape}, weights={weights_l.shape}")
```

## 7. 文本分类实战

```python
# 文本分类: BiLSTM + Attention
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import DataLoader, Dataset
import numpy as np
from collections import Counter

# ========== 数据处理 ==========
class TextDataset(Dataset):
    def __init__(self, texts, labels, vocab=None, max_len=100, min_freq=2):
        self.max_len = max_len

        # 构建词表
        if vocab is None:
            word_counts = Counter()
            for text in texts:
                word_counts.update(text.lower().split())
            self.vocab = {'<PAD>': 0, '<UNK>': 1}
            for word, count in word_counts.items():
                if count >= min_freq:
                    self.vocab[word] = len(self.vocab)
        else:
            self.vocab = vocab

        # 分词转换为索引
        self.data = []
        for text, label in zip(texts, labels):
            tokens = text.lower().split()[:max_len]
            indices = [self.vocab.get(token, 1) for token in tokens]  # 1 = <UNK>
            # 填充
            if len(indices) < max_len:
                indices += [0] * (max_len - len(indices))  # 0 = <PAD>
            self.data.append((torch.LongTensor(indices), label))

        self.num_classes = len(set(labels))

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        return self.data[idx]


# ========== 模型: BiLSTM + Attention ==========
class BiLSTM_Attention(nn.Module):
    def __init__(self, vocab_size, embed_dim, hidden_dim, num_classes,
                 num_layers=2, dropout=0.5):
        super(BiLSTM_Attention, self).__init__()

        self.embedding = nn.Embedding(vocab_size, embed_dim, padding_idx=0)
        self.lstm = nn.LSTM(
            embed_dim, hidden_dim, num_layers,
            batch_first=True, bidirectional=True,
            dropout=dropout if num_layers > 1 else 0
        )
        self.attention = nn.Sequential(
            nn.Linear(hidden_dim * 2, hidden_dim),
            nn.Tanh(),
            nn.Linear(hidden_dim, 1, bias=False)
        )
        self.dropout = nn.Dropout(dropout)
        self.fc = nn.Linear(hidden_dim * 2, num_classes)

        # 初始化
        nn.init.uniform_(self.embedding.weight, -0.1, 0.1)
        for name, param in self.lstm.named_parameters():
            if 'weight' in name:
                nn.init.orthogonal_(param)

    def forward(self, x):
        # x: (batch, seq_len)
        embedded = self.dropout(self.embedding(x))  # (batch, seq, embed)

        lstm_out, (h_n, c_n) = self.lstm(embedded)  # (batch, seq, 2*hidden)

        # 注意力机制
        attn_scores = self.attention(lstm_out).squeeze(2)  # (batch, seq)

        # 创建mask，忽略padding位置
        mask = (x != 0).float()
        attn_scores = attn_scores.masked_fill(mask == 0, -1e9)
        attn_weights = F.softmax(attn_scores, dim=1)  # (batch, seq)

        # 加权求和
        context = torch.bmm(attn_weights.unsqueeze(1), lstm_out).squeeze(1)

        out = self.fc(context)
        return out, attn_weights


# ========== 训练 ==========
def train_text_classifier():
    """演示文本分类训练的完整流程"""

    # 模拟数据
    sample_texts = [
        "the movie was great and fantastic wonderful amazing brilliant",
        "i really enjoyed this film it was beautiful",
        "the acting was superb and the story was touching",
        "this is the best movie i have ever seen truly magnificent",
        "an excellent film with outstanding performances",
        "i loved every moment of this movie it was perfect",
        "this film was terrible and boring a waste of time",
        "i hated this movie it was awful and disappointing",
        "the worst film i have ever watched completely dreadful",
        "absolute garbage dont waste your money on this rubbish",
        "the plot was nonexistent and the acting was atrocious",
        "i walked out of the theater it was that bad horrible movie",
    ]
    labels = [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0]  # 1=正面, 0=负面

    dataset = TextDataset(sample_texts, labels, max_len=20)
    loader = DataLoader(dataset, batch_size=4, shuffle=True)

    model = BiLSTM_Attention(
        vocab_size=len(dataset.vocab), embed_dim=64,
        hidden_dim=128, num_classes=2, num_layers=2, dropout=0.3
    )

    optimizer = optim.Adam(model.parameters(), lr=0.001)
    criterion = nn.CrossEntropyLoss()

    losses = []
    for epoch in range(50):
        epoch_loss = 0
        for x_batch, y_batch in loader:
            optimizer.zero_grad()
            logits, attn = model(x_batch)
            loss = criterion(logits, y_batch)
            loss.backward()
            optimizer.step()
            epoch_loss += loss.item()
        losses.append(epoch_loss / len(loader))
        if epoch % 10 == 0:
            print(f'Epoch {epoch}: Loss = {losses[-1]:.4f}')

    # 测试
    model.eval()
    test_text = "this movie was really great and amazing"
    test_tokens = test_text.lower().split()[:20]
    test_ids = [dataset.vocab.get(t, 1) for t in test_tokens]
    test_ids = test_ids + [0] * (20 - len(test_ids))
    test_tensor = torch.LongTensor(test_ids).unsqueeze(0)

    with torch.no_grad():
        logits, attn_weights = model(test_tensor)
        pred = logits.argmax(1).item()
        print(f'\n测试文本: "{test_text}"')
        print(f'预测: {"正面" if pred == 1 else "负面"} '
              f'(置信度: {torch.softmax(logits, dim=1)[0, pred].item():.4f})')
        print(f'注意力分布: {attn_weights[0, :len(test_tokens)].numpy()}')

    # 可视化注意力
    fig, ax = plt.subplots(figsize=(10, 2))
    ax.bar(range(len(test_tokens)), attn_weights[0, :len(test_tokens)].numpy())
    ax.set_xticks(range(len(test_tokens)))
    ax.set_xticklabels(test_tokens, rotation=45)
    ax.set_ylabel('Attention Weight')
    ax.set_title('词级别注意力权重')
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.show()


train_text_classifier()
```

## 相关笔记

- [[01-数学基础-线性代数|线性代数]] — 矩阵乘法与参数矩阵
- [[02-数学基础-微积分|微积分]] — BPTT中的链式法则
- [[07-神经网络|神经网络]] — 神经网络基础
- [[08-优化方法|优化方法]] — 梯度裁剪与优化器选择
- [[12-Transformer与大模型|Transformer与大模型]] — 自注意力机制
- [[06-PyTorch入门|PyTorch]] — PyTorch框架
- [[../../数理基础/概率论|概率论]] — 序列模型的概率视角
- [[LaTeX/main|LaTeX完整教程]] — 公式排版
