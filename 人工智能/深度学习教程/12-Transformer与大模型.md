# Transformer与大模型

## 1. 从RNN到Transformer

### 1.1 RNN的根本局限

RNN/LSTM的核心问题在于**顺序计算**——每步计算依赖前一步的结果，无法并行：

```
x₁ → h₁ → x₂ → h₂ → x₃ → h₃ → ... → x_T → h_T
```

这导致了：
- **训练效率低**：无法充分利用GPU并行
- **长程依赖困难**：即使LSTM，超过100步的依赖仍难捕捉
- **梯度传播路径长**：BPTT需要沿时间步反向传播

### 1.2 Transformer的核心创新

Transformer（2017, Vaswani et al.）完全放弃了循环结构，使用**自注意力机制**（Self-Attention）直接建模任意两个位置之间的关系：

- **并行计算**：所有位置同时处理
- **全局依赖**：任意两个位置之间的最短路径长度为 $O(1)$
- **可解释性**：注意力权重提供直观的可解释性

## 2. 自注意力机制 (Self-Attention)

### 2.1 核心思想

对于序列中的每个元素，动态计算它与所有其他元素的相关性，然后加权聚合信息：

$$
\text{Attention}(\mathbf{Q}, \mathbf{K}, \mathbf{V}) = \text{softmax}\left(\frac{\mathbf{Q}\mathbf{K}^T}{\sqrt{d_k}}\right)\mathbf{V}
$$

### 2.2 Q, K, V 的物理意义

输入序列 $\mathbf{X} \in \mathbb{R}^{n \times d}$，通过线性变换得到三个矩阵：

$$
\begin{aligned}
\mathbf{Q} &= \mathbf{X}\mathbf{W}^Q \quad \text{(Query: 我要查什么)} \\
\mathbf{K} &= \mathbf{X}\mathbf{W}^K \quad \text{(Key: 我有什么)} \\
\mathbf{V} &= \mathbf{X}\mathbf{W}^V \quad \text{(Value: 我提供什么)}
\end{aligned}
$$

**直观理解**（类比数据库检索）：
- Query：表示"查询向量"——当前元素"想要"关注什么
- Key：表示"键向量"——所有元素"能提供"什么
- Value：表示"值向量"——实际被聚合的信息

注意力权重通过Query和Key的点积计算：$A = \text{softmax}(\mathbf{Q}\mathbf{K}^T / \sqrt{d_k})$。

### 2.3 缩放因子 $\sqrt{d_k}$ 的作用

点积 $\mathbf{q} \cdot \mathbf{k}$ 的方差随维度 $d_k$ 线性增长（假设q和k各分量独立，方差为1）：

$$
\text{Var}(\mathbf{q} \cdot \mathbf{k}) = \sum_{i=1}^{d_k} \text{Var}(q_i k_i) = d_k
$$

若不缩放，大 $d_k$ 会导致点积值过大，使 softmax 进入饱和区（梯度趋近于0），缩放 $\sqrt{d_k}$ 保持方差约为1。

### 2.4 自注意力的矩阵形式与计算流程

输入 $\mathbf{X} \in \mathbb{R}^{n \times d_{\text{model}}}$，假设 $d_k = d_v = d_{\text{model}} = d$：

**步骤1**：生成 Q, K, V
$$
\mathbf{Q} = \mathbf{X}\mathbf{W}^Q \in \mathbb{R}^{n \times d}, \quad
\mathbf{K} = \mathbf{X}\mathbf{W}^K \in \mathbb{R}^{n \times d}, \quad
\mathbf{V} = \mathbf{X}\mathbf{W}^V \in \mathbb{R}^{n \times d}
$$

**步骤2**：计算注意力分数矩阵
$$
\mathbf{S} = \frac{\mathbf{Q}\mathbf{K}^T}{\sqrt{d}} \in \mathbb{R}^{n \times n}
$$

**步骤3**：Softmax 归一化（行方向）
$$
\mathbf{A} = \text{softmax}(\mathbf{S}) \quad \text{其中 } A_{ij} = \frac{\exp(S_{ij})}{\sum_{k=1}^n \exp(S_{ik})}
$$

**步骤4**：加权聚合
$$
\mathbf{O} = \mathbf{A}\mathbf{V} \in \mathbb{R}^{n \times d}
$$

计算复杂度：$O(n^2 d)$ —— 序列长度平方，序列很长时是瓶颈。

```python
# Self-Attention的完整数学推导与实现
import torch
import torch.nn as nn
import torch.nn.functional as F
import matplotlib.pyplot as plt
import numpy as np

class SelfAttention(nn.Module):
    """单头自注意力 (Scaled Dot-Product Attention)"""

    def __init__(self, d_model, d_k=None, d_v=None):
        super().__init__()
        if d_k is None:
            d_k = d_model
        if d_v is None:
            d_v = d_model

        self.d_k = d_k
        self.W_q = nn.Linear(d_model, d_k, bias=False)
        self.W_k = nn.Linear(d_model, d_k, bias=False)
        self.W_v = nn.Linear(d_model, d_v, bias=False)

    def forward(self, x, mask=None):
        """
        x: (batch, seq_len, d_model)
        mask: (batch, seq_len) 或 (batch, 1, seq_len), 1=保留, 0=遮挡
        """
        Q = self.W_q(x)  # (B, n, d_k)
        K = self.W_k(x)  # (B, n, d_k)
        V = self.W_v(x)  # (B, n, d_v)

        # 计算注意力分数
        scores = torch.matmul(Q, K.transpose(-2, -1)) / np.sqrt(self.d_k)
        # (B, n, n)

        # 应用mask
        if mask is not None:
            if mask.dim() == 2:
                mask = mask.unsqueeze(1)  # (B, 1, n)
            scores = scores.masked_fill(mask == 0, -1e9)

        # Softmax
        attn_weights = F.softmax(scores, dim=-1)

        # 加权求和
        output = torch.matmul(attn_weights, V)  # (B, n, d_v)

        return output, attn_weights


# 逐步展示Self-Attention的计算过程
def demo_self_attention_step_by_step():
    torch.manual_seed(42)

    # 创建示例: 4个词, 每个词6维嵌入
    seq_len, d_model = 4, 6
    X = torch.randn(1, seq_len, d_model)

    # 模拟词嵌入: ["我", "爱", "北京", "天安门"]
    words = ["我", "爱", "北京", "天安门"]

    # 步骤1: 生成Q, K, V
    d_k = d_model // 2  # 3
    W_q = nn.Linear(d_model, d_k, bias=False)
    W_k = nn.Linear(d_model, d_k, bias=False)
    W_v = nn.Linear(d_model, d_k, bias=False)

    Q = W_q(X)  # (1, 4, 3)
    K = W_k(X)  # (1, 4, 3)
    V = W_v(X)  # (1, 4, 3)

    # 步骤2: 计算原始分数
    scores = torch.matmul(Q, K.transpose(-2, -1))  # (1, 4, 4)
    scaled_scores = scores / np.sqrt(d_k)

    # 步骤3: Softmax
    attn_weights = F.softmax(scaled_scores, dim=-1)

    # 步骤4: 加权输出
    output = torch.matmul(attn_weights, V)

    # 可视化注意力矩阵
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))

    # Q可视化
    im0 = axes[0, 0].imshow(Q[0].detach().numpy(), aspect='auto', cmap='Blues')
    axes[0, 0].set_title('Query Matrix (Q)\n形状: (4, 3)')
    axes[0, 0].set_yticks(range(4))
    axes[0, 0].set_yticklabels(words)
    axes[0, 0].set_xlabel('d_k = 3')
    plt.colorbar(im0, ax=axes[0, 0])

    # K可视化
    im1 = axes[0, 1].imshow(K[0].detach().numpy(), aspect='auto', cmap='Reds')
    axes[0, 1].set_title('Key Matrix (K)\n形状: (4, 3)')
    axes[0, 1].set_yticks(range(4))
    axes[0, 1].set_yticklabels(words)
    axes[0, 1].set_xlabel('d_k = 3')
    plt.colorbar(im1, ax=axes[0, 1])

    # V可视化
    im2 = axes[0, 2].imshow(V[0].detach().numpy(), aspect='auto', cmap='Greens')
    axes[0, 2].set_title('Value Matrix (V)\n形状: (4, 3)')
    axes[0, 2].set_yticks(range(4))
    axes[0, 2].set_yticklabels(words)
    axes[0, 2].set_xlabel('d_v = 3')
    plt.colorbar(im2, ax=axes[0, 2])

    # 注意力权重
    im3 = axes[1, 0].imshow(attn_weights[0].detach().numpy(), aspect='auto',
                              cmap='YlOrRd', vmin=0, vmax=1)
    axes[1, 0].set_title(f'Attention Weights A\nQ·K^T / √d_k → Softmax')
    axes[1, 0].set_xticks(range(4))
    axes[1, 0].set_xticklabels(words, rotation=45)
    axes[1, 0].set_yticks(range(4))
    axes[1, 0].set_yticklabels(words)
    axes[1, 0].set_xlabel('Key Position')
    axes[1, 0].set_ylabel('Query Position')
    plt.colorbar(im3, ax=axes[1, 0])

    # 输出
    im4 = axes[1, 1].imshow(output[0].detach().numpy(), aspect='auto', cmap='Purples')
    axes[1, 1].set_title(f'Output = A × V\n形状: (4, 3)')
    axes[1, 1].set_yticks(range(4))
    axes[1, 1].set_yticklabels(words)
    axes[1, 1].set_xlabel('d_v = 3')
    plt.colorbar(im4, ax=axes[1, 1])

    # 公式
    axes[1, 2].axis('off')
    axes[1, 2].text(0.1, 0.5,
        'Self-Attention 公式:\n\n'
        'Attention(Q,K,V) =\n'
        '  softmax(QK^T/√d_k) V\n\n'
        'Q = X·W_Q\n'
        'K = X·W_K\n'
        'V = X·W_V',
        fontsize=12, va='center', fontfamily='monospace',
        transform=axes[1, 2].transAxes)

    plt.suptitle('Self-Attention 计算过程逐步可视化', fontsize=14)
    plt.tight_layout()
    plt.show()

    # 数值验证
    print("注意力权重矩阵 A:")
    print(attn_weights[0].detach().numpy())
    print(f"\n每行和: {attn_weights[0].sum(dim=1).detach().numpy()} (应全为1)")

demo_self_attention_step_by_step()
```

## 3. 多头注意力 (Multi-Head Attention)

### 3.1 原理

单一注意力头可能只关注某一种模式（如语法关系），多头注意力让模型同时关注来自不同表示子空间的信息：

$$
\begin{aligned}
\text{MultiHead}(\mathbf{Q}, \mathbf{K}, \mathbf{V}) &= \text{Concat}(\text{head}_1, ..., \text{head}_h)\mathbf{W}^O \\
\text{head}_i &= \text{Attention}(\mathbf{X}\mathbf{W}_i^Q, \mathbf{X}\mathbf{W}_i^K, \mathbf{X}\mathbf{W}_i^V)
\end{aligned}
$$

其中每个head的维度 $d_k = d_v = d_{\text{model}} / h$（通常 $h=8$ 或 $16$）。

```python
class MultiHeadAttention(nn.Module):
    """完整的多头注意力实现"""

    def __init__(self, d_model, num_heads, dropout=0.1):
        super().__init__()
        assert d_model % num_heads == 0

        self.d_model = d_model
        self.num_heads = num_heads
        self.d_k = d_model // num_heads  # 每个头的维度

        # 合并所有头的Q, K, V投影
        self.W_q = nn.Linear(d_model, d_model, bias=False)
        self.W_k = nn.Linear(d_model, d_model, bias=False)
        self.W_v = nn.Linear(d_model, d_model, bias=False)
        self.W_o = nn.Linear(d_model, d_model, bias=False)

        self.dropout = nn.Dropout(dropout)

    def _split_heads(self, x):
        """将d_model维度拆分为num_heads × d_k"""
        B, N = x.shape[:2]
        x = x.view(B, N, self.num_heads, self.d_k)
        return x.transpose(1, 2)  # (B, num_heads, N, d_k)

    def _merge_heads(self, x):
        """合并heads"""
        B, H, N, D = x.shape
        x = x.transpose(1, 2).contiguous()  # (B, N, H, D)
        return x.view(B, N, self.d_model)  # (B, N, d_model)

    def forward(self, query, key, value, mask=None):
        B = query.size(0)

        # 线性投影
        Q = self.W_q(query)  # (B, N, d_model)
        K = self.W_k(key)
        V = self.W_v(value)

        # 拆分为多头
        Q = self._split_heads(Q)  # (B, h, N, d_k)
        K = self._split_heads(K)
        V = self._split_heads(V)

        # 计算注意力
        scores = torch.matmul(Q, K.transpose(-2, -1)) / np.sqrt(self.d_k)

        if mask is not None:
            if mask.dim() == 2:
                mask = mask.unsqueeze(1).unsqueeze(2)  # (B, 1, 1, N)
            scores = scores.masked_fill(mask == 0, -1e9)

        attn = F.softmax(scores, dim=-1)
        attn = self.dropout(attn)
        output = torch.matmul(attn, V)  # (B, h, N, d_k)

        # 合并多头
        output = self._merge_heads(output)  # (B, N, d_model)
        output = self.W_o(output)

        return output, attn


# 测试多头注意力
mha = MultiHeadAttention(d_model=512, num_heads=8)
x = torch.randn(2, 10, 512)
output, attn = mha(x, x, x)
print(f"Multi-Head Attention: {x.shape} → {output.shape}")
print(f"Attention weights: {attn.shape} (B, heads, N, N)")

# 可视化多头注意力的每个头
def visualize_multi_head_attention():
    """可视化多个注意力头"""
    sample = torch.randn(1, 8, 64)
    words = ['The', 'cat', 'sat', 'on', 'the', 'mat', '.', '<EOS>']

    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    colors = plt.cm.tab10(np.linspace(0, 1, 8))

    for i, ax in enumerate(axes.flatten()):
        # 模拟不同头的注意力模式
        # 头0-2: 关注相邻词 (local)
        # 头3-4: 关注特殊位置 (global)
        # 头5-7: 混合模式
        if i < 2:
            pattern = np.eye(8) * 0.6 + np.eye(8, k=1) * 0.4
        elif i < 4:
            pattern = np.ones(8) / 8
            pattern = np.tile(pattern, (8, 1))
        else:
            pattern = np.random.dirichlet(np.ones(8), size=8)

        im = ax.imshow(pattern, cmap='YlOrRd', vmin=0, vmax=1)
        ax.set_title(f'Head {i+1}')
        ax.set_xticks(range(8))
        ax.set_xticklabels(words, rotation=45, fontsize=7)
        ax.set_yticks(range(8))
        ax.set_yticklabels(words, fontsize=7)

    plt.suptitle('多头注意力: 不同头关注不同的关系模式', fontsize=14)
    plt.tight_layout()
    plt.show()

visualize_multi_head_attention()
```

## 4. 位置编码 (Positional Encoding)

### 4.1 为什么需要位置编码？

自注意力是**置换等变**的——打乱输入顺序，输出也会以相同方式打乱。模型本身没有内置的位置概念。

### 4.2 正弦位置编码

原始Transformer使用正弦/余弦函数：

$$
\begin{aligned}
PE_{(pos, 2i)} &= \sin\left(\frac{pos}{10000^{2i/d_{\text{model}}}}\right) \\
PE_{(pos, 2i+1)} &= \cos\left(\frac{pos}{10000^{2i/d_{\text{model}}}}\right)
\end{aligned}
$$

其中 $pos$ 是位置索引，$i$ 是维度索引。

**优点**：
- 允许模型推断比训练更长的序列（线性外推）
- 相对位置关系可通过三角恒等式学习
- $PE_{pos+k}$ 可以表示为 $PE_{pos}$ 的线性函数

### 4.3 可学习位置编码

BERT、GPT等模型使用可学习的位置嵌入矩阵 $\mathbf{W}_{\text{pos}} \in \mathbb{R}^{\text{max\_len} \times d_{\text{model}}}$。

### 4.4 旋转位置编码 (RoPE)

Llama、Qwen等现代模型使用的RoPE（Rotary Position Embedding），通过旋转矩阵对Query和Key施加位置信息：

$$
\tilde{\mathbf{q}}_m = \mathbf{R}_{\Theta, m} \mathbf{q}_m
$$

优势：相对位置信息自然编码在Q和K的内积中（$(\mathbf{R}_{\Theta, m}\mathbf{q})^T (\mathbf{R}_{\Theta, n}\mathbf{k}) = \mathbf{q}^T \mathbf{R}_{\Theta, n-m} \mathbf{k}$）。

```python
class PositionalEncoding(nn.Module):
    """正弦位置编码"""

    def __init__(self, d_model, max_len=5000, dropout=0.1):
        super().__init__()
        self.dropout = nn.Dropout(dropout)

        # 创建位置编码矩阵
        pe = torch.zeros(max_len, d_model)
        position = torch.arange(0, max_len).unsqueeze(1).float()
        div_term = torch.exp(torch.arange(0, d_model, 2).float() *
                             (-np.log(10000.0) / d_model))

        pe[:, 0::2] = torch.sin(position * div_term)
        pe[:, 1::2] = torch.cos(position * div_term)
        pe = pe.unsqueeze(1)  # (max_len, 1, d_model) 用于batch_first=False

        self.register_buffer('pe', pe)

    def forward(self, x):
        x = x + self.pe[:x.size(0), :]
        return self.dropout(x)


# 位置编码可视化
def visualize_positional_encoding():
    d_model, max_len = 64, 100
    pe = PositionalEncoding(d_model, max_len)
    pe_matrix = pe.pe.squeeze(1).numpy()  # (max_len, d_model)

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # 完整位置编码
    axes[0].imshow(pe_matrix, aspect='auto', cmap='RdBu_r')
    axes[0].set_xlabel('Embedding Dimension')
    axes[0].set_ylabel('Position')
    axes[0].set_title('Positional Encoding Matrix')

    # 位置编码向量示例
    for pos in [0, 20, 50, 80]:
        axes[1].plot(pe_matrix[pos], alpha=0.7, label=f'pos={pos}')
    axes[1].set_xlabel('Dimension')
    axes[1].set_ylabel('Encoding Value')
    axes[1].set_title('不同位置的编码向量')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    axes[1].set_xlim(0, d_model)

    # 位置间余弦相似度
    similarity = np.dot(pe_matrix, pe_matrix.T)
    # 归一化
    norms = np.linalg.norm(pe_matrix, axis=1, keepdims=True)
    similarity = similarity / (norms @ norms.T)

    im = axes[2].imshow(similarity, cmap='viridis', vmin=-1, vmax=1)
    axes[2].set_xlabel('Position')
    axes[2].set_ylabel('Position')
    axes[2].set_title('位置编码余弦相似度')
    plt.colorbar(im, ax=axes[2])

    plt.suptitle('正弦位置编码分析', fontsize=14)
    plt.tight_layout()
    plt.show()

    # 关键性质：相对位置相似
    print("位置编码性质:")
    print(f"  PE[0] vs PE[1] 余弦相似度: {similarity[0, 1]:.4f}")
    print(f"  PE[0] vs PE[10] 余弦相似度: {similarity[0, 10]:.4f}")
    print(f"  PE[10] vs PE[20] 余弦相似度: {similarity[10, 20]:.4f}")
    print("  (相邻位置相似度高, 距离越远相似度越低)")

visualize_positional_encoding()
```

## 5. Transformer架构

### 5.1 Encoder

Transformer编码器由 $N$ 个相同层堆叠，每层包含：

1. **多头自注意力子层**：
   $$
   \mathbf{Z} = \text{LayerNorm}(\mathbf{X} + \text{MultiHead}(\mathbf{X}, \mathbf{X}, \mathbf{X}))
   $$

2. **前馈网络子层**：
   $$
   \mathbf{Y} = \text{LayerNorm}(\mathbf{Z} + \text{FFN}(\mathbf{Z}))
   $$
   其中 $\text{FFN}(\mathbf{x}) = \text{GELU}(\mathbf{x}\mathbf{W}_1 + \mathbf{b}_1)\mathbf{W}_2 + \mathbf{b}_2$

两个关键组件：
- **残差连接**：$\mathbf{X} + \text{Sublayer}(\mathbf{X})$，稳定梯度、加速训练
- **Layer Normalization**：Post-LN（原始）vs Pre-LN（现代更常用）

### 5.2 Decoder

Transformer解码器同样由 $N$ 个层堆叠，每层包含三个子层：

1. **带掩码的多头自注意力**：防止关注未来位置（因果性）
2. **交叉注意力**：Query来自Decoder，Key/Value来自Encoder
3. **前馈网络**

### 5.3 训练时的掩码

- **填充掩码 (Padding Mask)**：忽略 `<PAD>` token 的位置
- **因果掩码 (Causal Mask)**：下三角矩阵，防止Decoder看到未来信息

```python
class TransformerEncoderLayer(nn.Module):
    """Transformer编码器层 (Pre-LN架构)"""

    def __init__(self, d_model, num_heads, d_ff, dropout=0.1):
        super().__init__()
        self.self_attn = MultiHeadAttention(d_model, num_heads, dropout)
        self.ffn = nn.Sequential(
            nn.Linear(d_model, d_ff),
            nn.GELU(),
            nn.Dropout(dropout),
            nn.Linear(d_ff, d_model),
            nn.Dropout(dropout)
        )
        self.norm1 = nn.LayerNorm(d_model)
        self.norm2 = nn.LayerNorm(d_model)
        self.dropout = nn.Dropout(dropout)

    def forward(self, x, mask=None):
        # 自注意力 + 残差
        x_norm = self.norm1(x)
        attn_out, _ = self.self_attn(x_norm, x_norm, x_norm, mask)
        x = x + self.dropout(attn_out)

        # FFN + 残差
        x_norm = self.norm2(x)
        ffn_out = self.ffn(x_norm)
        x = x + ffn_out

        return x


class TransformerEncoder(nn.Module):
    """完整的Transformer编码器"""

    def __init__(self, vocab_size, d_model, num_heads, d_ff,
                 num_layers, max_len, dropout=0.1):
        super().__init__()
        self.embedding = nn.Embedding(vocab_size, d_model)
        self.pos_encoding = PositionalEncoding(d_model, max_len, dropout)
        self.layers = nn.ModuleList([
            TransformerEncoderLayer(d_model, num_heads, d_ff, dropout)
            for _ in range(num_layers)
        ])
        self.norm = nn.LayerNorm(d_model)

    def forward(self, x, mask=None):
        x = self.embedding(x) * np.sqrt(self.embedding.embedding_dim)
        x = self.pos_encoding(x)
        for layer in self.layers:
            x = layer(x, mask)
        return self.norm(x)


# 测试
encoder = TransformerEncoder(
    vocab_size=30000, d_model=512, num_heads=8, d_ff=2048,
    num_layers=6, max_len=512
)
x = torch.randint(0, 30000, (4, 50))
output = encoder(x)
print(f"Encoder: {x.shape} → {output.shape}")
print(f"参数量: {sum(p.numel() for p in encoder.parameters()):,}")

# Transformer各组件参数量分布
def analyze_transformer_params(d_model=768, num_heads=12, d_ff=3072,
                                 num_layers=12, vocab_size=30000):
    """分析Transformer参数分布 (类似BERT-base)"""
    d_k = d_model // num_heads

    # Embedding
    embed_params = vocab_size * d_model  # Token Embedding

    # 每层参数
    mha_params = 4 * d_model * d_model  # Q, K, V, O投影
    ffn_params = 2 * d_model * d_ff + d_ff + d_model  # W1, W2 + biases
    ln_params = 4 * d_model  # 两个LayerNorm

    layer_params = mha_params + ffn_params + ln_params
    total_params = embed_params + num_layers * layer_params

    print(f"\nTransformer参数分析 (d_model={d_model}, h={num_heads}, "
          f"d_ff={d_ff}, L={num_layers}):")
    print(f"  Embedding: {embed_params/1e6:.1f}M")
    print(f"  MHA/层: {mha_params/1e6:.2f}M")
    print(f"  FFN/层: {ffn_params/1e6:.2f}M")
    print(f"  总计: {total_params/1e6:.1f}M")

analyze_transformer_params()
```

## 6. BERT (Bidirectional Encoder Representations from Transformers)

### 6.1 BERT的核心创新

BERT (Devlin et al., 2018) 证明了在大量无标签文本上预训练、再在下游任务上微调的有效性。

**核心是双向上下文**：与GPT的单向语言模型不同，BERT使用Transformer的Encoder，能同时看到左右两侧的上下文。

### 6.2 预训练任务

**MLM (Masked Language Model)**：
- 随机遮盖15%的token
  - 80%：替换为 `[MASK]`
  - 10%：替换为随机token
  - 10%：保持不变
- 模型预测被遮盖的原始token

**NSP (Next Sentence Prediction)**：
- 50%的样本：句子B是句子A的下一句
- 50%的样本：句子B是随机选择的
- 模型预测B是否是A的下一句

（后续研究如RoBERTa证明NSP用处有限，MLM即可）

### 6.3 BERT的输入表示

$$
\text{Input} = \text{Token Embedding} + \text{Segment Embedding} + \text{Position Embedding}
$$

特殊token：
- `[CLS]`：序列开始，其最终隐藏状态用于分类
- `[SEP]`：句子分隔符
- `[MASK]`：遮盖token

### 6.4 微调

```python
# BERT微调示例
from transformers import BertTokenizer, BertModel
import torch
import torch.nn as nn

class BertForClassification(nn.Module):
    """BERT分类微调"""

    def __init__(self, pretrained_model='bert-base-uncased',
                 num_classes=2, dropout=0.1):
        super().__init__()
        self.bert = BertModel.from_pretrained(pretrained_model)
        self.dropout = nn.Dropout(dropout)
        self.classifier = nn.Linear(self.bert.config.hidden_size, num_classes)

    def forward(self, input_ids, attention_mask, token_type_ids=None):
        outputs = self.bert(
            input_ids=input_ids,
            attention_mask=attention_mask,
            token_type_ids=token_type_ids
        )
        # 使用[CLS]的隐藏状态进行分类
        cls_output = outputs.last_hidden_state[:, 0, :]
        cls_output = self.dropout(cls_output)
        logits = self.classifier(cls_output)
        return logits


# 测试（模拟）
print("BERT架构信息:")
print("  BERT-base: L=12, H=768, A=12, 参数=110M")
print("  BERT-large: L=24, H=1024, A=16, 参数=340M")
print("  训练数据: BooksCorpus(800M词) + English Wikipedia(2500M词)")
print("  预训练任务: MLM + NSP")

# 创建和测试BERT分类模型
try:
    model = BertForClassification(pretrained_model='bert-base-uncased',
                                   num_classes=2)
    print(f"  BERT分类模型参数量: {sum(p.numel() for p in model.parameters()):,}")
except Exception as e:
    print(f"  需要安装transformers库: pip install transformers")
```

## 7. GPT系列

### 7.1 GPT (Generative Pre-trained Transformer)

GPT是自回归语言模型的里程碑，使用Transformer的**Decoder**结构（只有单向注意力）：

**GPT-1** (2018):
- 12层Transformer Decoder
- 无监督预训练（语言建模）+ 有监督微调
- 117M参数

**GPT-2** (2019):
- 48层，1.5B参数
- 提出zero-shot能力——不微调，仅通过提示词完成下游任务
- 证明了"规模足够大时，语言模型本身就能学会多任务"

**GPT-3** (2020):
- 175B参数，96层
- In-context learning / Few-shot learning
- 通过prompt而非微调来完成任务

**GPT-4** (2023):
- 多模态（图文理解）
- 强大的推理能力
- 预估约1.7T参数（未公开）

### 7.2 自回归语言建模

GPT的核心训练目标：

$$
L(\theta) = -\sum_{i=1}^{N} \log P(x_i | x_{<i}; \theta)
$$

使用因果掩码确保每个token只能看到之前的token。

```python
# GPT风格的因果自注意力
def create_causal_mask(seq_len):
    """创建因果掩码 (下三角矩阵)"""
    mask = torch.tril(torch.ones(seq_len, seq_len))
    return mask  # 1=保留, 0=遮挡

# 演示
mask = create_causal_mask(6)
print("因果掩码 (Causal Mask):")
print(mask.numpy().astype(int))
print("\nToken 0 只能看到自身")
print("Token 3 可以看到 Token 0,1,2,3")

# GPT风格的简化Transformer
class GPTLayer(nn.Module):
    """GPT解码器层"""

    def __init__(self, d_model, num_heads, d_ff, dropout=0.1):
        super().__init__()
        self.self_attn = MultiHeadAttention(d_model, num_heads, dropout)
        self.ffn = nn.Sequential(
            nn.Linear(d_model, d_ff),
            nn.GELU(),
            nn.Linear(d_ff, d_model),
            nn.Dropout(dropout)
        )
        self.norm1 = nn.LayerNorm(d_model)
        self.norm2 = nn.LayerNorm(d_model)

    def forward_batch(self, x):
        # Pre-LN
        x_norm = self.norm1(x)
        causal_mask = create_causal_mask(x.size(1)).to(x.device)
        attn_out, _ = self.self_attn(x_norm, x_norm, x_norm, causal_mask)
        x = x + attn_out

        x_norm = self.norm2(x)
        x = x + self.ffn(x_norm)
        return x


class MiniGPT(nn.Module):
    """简化的GPT模型"""

    def __init__(self, vocab_size, d_model=256, num_heads=8,
                 d_ff=1024, num_layers=4, max_len=256):
        super().__init__()
        self.token_embed = nn.Embedding(vocab_size, d_model)
        self.pos_embed = nn.Embedding(max_len, d_model)
        self.layers = nn.ModuleList([
            GPTLayer(d_model, num_heads, d_ff) for _ in range(num_layers)
        ])
        self.norm = nn.LayerNorm(d_model)
        self.lm_head = nn.Linear(d_model, vocab_size, bias=False)

        # 权重共享: embedding和lm_head
        self.lm_head.weight = self.token_embed.weight

    def forward(self, input_ids):
        B, T = input_ids.shape
        device = input_ids.device

        # Token + Position Embeddings
        tok_emb = self.token_embed(input_ids)  # (B, T, d_model)
        pos = torch.arange(0, T, dtype=torch.long, device=device).unsqueeze(0)
        pos_emb = self.pos_embed(pos)  # (1, T, d_model)

        x = tok_emb + pos_emb

        # Transformer层
        for layer in self.layers:
            x = layer.forward_batch(x)

        x = self.norm(x)
        logits = self.lm_head(x)  # (B, T, vocab_size)
        return logits

    @torch.no_grad()
    def generate(self, input_ids, max_new_tokens, temperature=1.0,
                  top_k=None, top_p=None):
        """自回归生成"""
        for _ in range(max_new_tokens):
            # 如果序列太长，截取最后max_len个token
            seq = input_ids if input_ids.size(1) <= 256 else input_ids[:, -256:]

            logits = self(seq)  # (B, T, vocab)
            logits = logits[:, -1, :] / temperature  # 最后一个位置的logits

            # Top-K采样
            if top_k is not None:
                v, _ = torch.topk(logits, min(top_k, logits.size(-1)))
                logits[logits < v[:, [-1]]] = -float('Inf')

            # Top-P (Nucleus)采样
            if top_p is not None:
                sorted_logits, sorted_indices = torch.sort(logits,
                                                           descending=True)
                cumulative_probs = torch.cumsum(
                    F.softmax(sorted_logits, dim=-1), dim=-1)
                sorted_indices_to_remove = cumulative_probs > top_p
                sorted_indices_to_remove[:, 1:] = \
                    sorted_indices_to_remove[:, :-1].clone()
                sorted_indices_to_remove[:, 0] = 0
                indices_to_remove = sorted_indices_to_remove.scatter(
                    1, sorted_indices, sorted_indices_to_remove)
                logits[indices_to_remove] = -float('Inf')

            probs = F.softmax(logits, dim=-1)
            next_token = torch.multinomial(probs, num_samples=1)

            input_ids = torch.cat([input_ids, next_token], dim=1)

        return input_ids


# 测试
mini_gpt = MiniGPT(vocab_size=1000, d_model=256)
print(f"MiniGPT 参数量: {sum(p.numel() for p in mini_gpt.parameters()):,}")
```

## 8. Llama: 开源大模型的基石

Llama (Meta, 2023-2024) 是开源大语言模型的重要里程碑：

### 8.1 关键架构改进

| 改进 | 描述 |
|------|------|
| **Pre-Normalization** | RMSNorm 替代 LayerNorm（更快） |
| **SwiGLU 激活** | $\text{SwiGLU}(x) = (x\mathbf{W}_1 \odot \text{SiLU}(x\mathbf{W}_2))\mathbf{W}_3$ |
| **RoPE** | 旋转位置编码，编码相对位置 |
| **GQA (Grouped Query Attention)** | 减少KV头数量以节省推理内存 |
| **大规模预训练数据** | Llama2: 2T tokens; Llama3: 15T+ tokens |

### 8.2 RMSNorm

$$
\text{RMSNorm}(\mathbf{x}) = \frac{\mathbf{x}}{\text{RMS}(\mathbf{x})} \odot \gamma
$$

$$
\text{RMS}(\mathbf{x}) = \sqrt{\frac{1}{d}\sum_{i=1}^{d} x_i^2 + \epsilon}
$$

相比LayerNorm，去掉了均值的计算和偏移参数，更快且效果相当。

```python
# RMSNorm实现
class RMSNorm(nn.Module):
    """RMS Layer Normalization (Llama使用)"""

    def __init__(self, d_model, eps=1e-6):
        super().__init__()
        self.eps = eps
        self.weight = nn.Parameter(torch.ones(d_model))

    def forward(self, x):
        # x: (..., d_model)
        rms = torch.sqrt(torch.mean(x ** 2, dim=-1, keepdim=True) + self.eps)
        return x * self.weight / rms


# SwiGLU实现
class SwiGLU(nn.Module):
    """SwiGLU激活函数 (Llama/PaLM使用)"""

    def __init__(self, d_model, d_ff):
        super().__init__()
        # SwiGLU需要两个上投影（比标准FFN多一倍参数）
        self.w1 = nn.Linear(d_model, d_ff, bias=False)
        self.w2 = nn.Linear(d_model, d_ff, bias=False)
        self.w3 = nn.Linear(d_ff, d_model, bias=False)

    def forward(self, x):
        return self.w3(F.silu(self.w1(x)) * self.w2(x))
```

## 9. DeepSeek与混合专家模型 (MoE)

### 9.1 MoE的核心思想

混合专家模型(Mixture of Experts)将FFN层替换为多个"专家"子网络，每个token只激活其中的一小部分：

$$
\mathbf{y} = \sum_{i=1}^{N} G(\mathbf{x})_i \cdot E_i(\mathbf{x})
$$

其中 $G(\mathbf{x}) = \text{softmax}(\text{TopK}(\mathbf{x} \mathbf{W}_g))$ 是门控路由，$E_i$ 是第 $i$ 个专家。

**关键优势**：总参数量可以极大（如DeepSeek-V3有671B参数），但每个token只激活约37B参数，大幅降低推理成本。

### 9.2 DeepSeek的创新

- **Multi-head Latent Attention (MLA)**：对KV做低秩压缩，大幅减少KV缓存
- **DeepSeekMoE**：细粒度专家分割 + 共享专家隔离
- **Auxiliary-loss-free load balancing**：动态偏置调整，无需辅助损失
- **Multi-Token Prediction**：预测多个未来token，提升数据效率

```python
# 简化的MoE实现
class MoELayer(nn.Module):
    """混合专家层 (简化版)"""

    def __init__(self, d_model, d_ff, num_experts=8, top_k=2):
        super().__init__()
        self.num_experts = num_experts
        self.top_k = top_k

        # 门控网络
        self.gate = nn.Linear(d_model, num_experts, bias=False)

        # 多个专家网络
        self.experts = nn.ModuleList([
            nn.Sequential(
                nn.Linear(d_model, d_ff),
                nn.GELU(),
                nn.Linear(d_ff, d_model)
            ) for _ in range(num_experts)
        ])

    def forward(self, x):
        """
        x: (batch, seq_len, d_model)
        """
        B, T, D = x.shape
        x_flat = x.view(-1, D)  # (B*T, D)

        # 门控分数
        gate_logits = self.gate(x_flat)  # (B*T, num_experts)

        # Top-K选择
        top_k_logits, top_k_indices = torch.topk(gate_logits, self.top_k, dim=-1)
        top_k_weights = F.softmax(top_k_logits, dim=-1)

        # 初始化输出
        output = torch.zeros_like(x_flat)

        # 对每个专家计算并聚合（实际实现会更高效）
        for expert_idx in range(self.num_experts):
            # 找到路由到该专家的token
            mask = (top_k_indices == expert_idx).any(dim=-1)
            if not mask.any():
                continue

            token_batch = x_flat[mask]
            expert_out = self.experts[expert_idx](token_batch)

            # 加权
            weight_idx = (top_k_indices[mask] == expert_idx).float()
            weight_values = (top_k_weights[mask] * weight_idx).sum(dim=-1)

            output[mask] += expert_out * weight_values.unsqueeze(-1)

        return output.view(B, T, D)

    def compute_load_balance_loss(self, gate_logits):
        """计算负载均衡损失"""
        # 简化: 鼓励所有专家均匀使用
        probs = F.softmax(gate_logits, dim=-1)
        avg_prob = probs.mean(dim=0)
        balance_loss = torch.sum(avg_prob * torch.log(avg_prob * self.num_experts))
        return balance_loss


# 测试MoE
moe = MoELayer(d_model=512, d_ff=2048, num_experts=8, top_k=2)
x = torch.randn(2, 10, 512)
y = moe(x)
print(f"MoE Layer: {x.shape} → {y.shape}")
# 总参数量 = 门控 + N×专家
total_params = sum(p.numel() for p in moe.parameters())
active_params_approx = total_params / 8 * 2  # 近似: 只有2/8专家被激活
print(f"总参数: {total_params:,}")
print(f"每次前向激活参数 (约): {active_params_approx:,.0f}")
```

## 10. HuggingFace 实战

```python
# HuggingFace Transformers 实战
from transformers import (
    AutoModel, AutoTokenizer, AutoModelForSequenceClassification,
    AutoModelForCausalLM, AutoModelForSeq2SeqLM,
    TrainingArguments, Trainer, DataCollatorWithPadding,
    pipeline, BitsAndBytesConfig
)
from datasets import Dataset, load_dataset
import torch
import numpy as np
from sklearn.metrics import accuracy_score, f1_score

# ========== 1. 文本分类 (BERT) ==========
def bert_classification_demo():
    """使用BERT进行文本分类"""
    print("=" * 60)
    print("BERT 文本分类")
    print("=" * 60)

    # 模拟数据
    texts = [
        "I love this movie, it was fantastic!",
        "What a terrible film, I hated every minute.",
        "The acting was superb and the story touching.",
        "Awful movie, complete waste of time and money.",
        "Best film I have seen in years, simply amazing!",
        "I cannot believe how bad this was, worst ever.",
    ]
    labels = [1, 0, 1, 0, 1, 0]  # 1=正, 0=负

    train_texts, eval_texts = texts[:4], texts[4:]
    train_labels, eval_labels = labels[:4], labels[4:]

    # 创建Dataset
    train_dataset = Dataset.from_dict({'text': train_texts, 'label': train_labels})
    eval_dataset = Dataset.from_dict({'text': eval_texts, 'label': eval_labels})

    # 加载tokenizer和模型
    try:
        tokenizer = AutoTokenizer.from_pretrained('bert-base-uncased')
        model = AutoModelForSequenceClassification.from_pretrained(
            'bert-base-uncased', num_labels=2)

        # Tokenization
        def tokenize_fn(examples):
            return tokenizer(examples['text'], truncation=True,
                             padding='max_length', max_length=128)

        train_dataset = train_dataset.map(tokenize_fn, batched=True)
        eval_dataset = eval_dataset.map(tokenize_fn, batched=True)

        # 训练
        training_args = TrainingArguments(
            output_dir='./bert_results',
            per_device_train_batch_size=4,
            per_device_eval_batch_size=4,
            num_train_epochs=3,
            logging_steps=1,
            evaluation_strategy='epoch',
            save_strategy='epoch',
            load_best_model_at_end=True,
            report_to='none',
        )

        def compute_metrics(eval_pred):
            logits, labels = eval_pred
            preds = np.argmax(logits, axis=-1)
            return {
                'accuracy': accuracy_score(labels, preds),
                'f1': f1_score(labels, preds, average='weighted')
            }

        trainer = Trainer(
            model=model,
            args=training_args,
            train_dataset=train_dataset,
            eval_dataset=eval_dataset,
            compute_metrics=compute_metrics,
            data_collator=DataCollatorWithPadding(tokenizer),
        )

        trainer.train()

        # 推理
        test_text = "This movie was really good and I enjoyed it"
        inputs = tokenizer(test_text, return_tensors='pt', truncation=True,
                           padding=True)
        model.eval()
        with torch.no_grad():
            outputs = model(**inputs)
            pred = torch.argmax(outputs.logits, dim=-1).item()
        print(f"\n测试文本: '{test_text}'")
        print(f"预测: {'正面' if pred == 1 else '负面'} "
              f"(置信度: {torch.softmax(outputs.logits, dim=-1)[0, pred]:.4f})")

    except ImportError:
        print("需要安装: pip install transformers datasets accelerate")
    except Exception as e:
        print(f"错误: {e}")


# ========== 2. 文本生成 (GPT-2 / Llama) ==========
def text_generation_demo():
    """使用GPT-2进行文本生成"""
    print("\n" + "=" * 60)
    print("GPT-2 文本生成")
    print("=" * 60)

    try:
        generator = pipeline(
            'text-generation',
            model='gpt2',
            device=0 if torch.cuda.is_available() else -1
        )

        prompt = "Once upon a time, in a land far far away"
        result = generator(
            prompt,
            max_length=100,
            num_return_sequences=2,
            temperature=0.8,
            top_p=0.9,
            do_sample=True,
        )

        for i, r in enumerate(result):
            print(f"\n生成 #{i+1}:")
            print(r['generated_text'])

    except Exception as e:
        print(f"需要安装: pip install transformers")


# ========== 3. 量化加载大型模型 ==========
def load_quantized_llama_demo():
    """演示如何4-bit量化加载Llama模型"""
    print("\n" + "=" * 60)
    print("量化加载Llama模型 (4-bit)")
    print("=" * 60)

    print("""
使用BitsAndBytesConfig进行4-bit量化加载:

```python
from transformers import BitsAndBytesConfig

quant_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.float16,
    bnb_4bit_use_double_quant=True,
    bnb_4bit_quant_type='nf4'  # NormalFloat4, 信息论最优4-bit量化
)

model = AutoModelForCausalLM.from_pretrained(
    'meta-llama/Llama-3-8B',
    quantization_config=quant_config,
    device_map='auto',
    torch_dtype=torch.float16
)
```

量化效果:
- Llama-3-8B: FP16需要~16GB显存
- 4-bit量化: 约需~6GB显存
- 可在单张RTX 3060 (12GB)上运行
""")

# 运行演示
bert_classification_demo()
text_generation_demo()
load_quantized_llama_demo()
```

## 11. 大模型技术全景总结

| 模型 | 年份 | 参数量 | 核心创新 | 特点 |
|------|------|--------|---------|------|
| Transformer | 2017 | 65M (base) | Self-Attention | 序列建模范式变革 |
| BERT | 2018 | 110M/340M | MLM预训练 | 双向理解 |
| GPT-2 | 2019 | 1.5B | Zero-shot | 大就是好 |
| GPT-3 | 2020 | 175B | In-context learning | 涌现能力 |
| T5 | 2020 | 11B | Text-to-Text | 统一框架 |
| Llama 2 | 2023 | 7/13/70B | 开源, GQA, RoPE | 开源里程碑 |
| GPT-4 | 2023 | ~1.7T(估) | 多模态, RLHF | AGI雏形 |
| Llama 3 | 2024 | 8/70/405B | 15T tokens训练 | 开源最强 |
| DeepSeek-V3 | 2024 | 671B (37B活跃) | MoE + MLA | 低成本极致性能 |

## 相关笔记

- [[01-数学基础-线性代数|线性代数]] — 注意力机制中的矩阵运算
- [[02-数学基础-微积分|微积分]] — Softmax与交叉熵的梯度
- [[07-神经网络|神经网络]] — 前馈网络、LayerNorm等基础组件
- [[08-优化方法|优化方法]] — AdamW优化器与学习率调度
- [[11-RNN与LSTM|RNN与LSTM]] — 从RNN到注意力的演进
- [[06-PyTorch入门|PyTorch]] — PyTorch框架与模型部署
- [[../RL-PPO理论|PPO]] — RLHF中使用的PPO算法
- [[../../数理基础/概率论|概率论]] — 自回归语言模型与概率视角
- [[LaTeX/main|LaTeX完整教程]] — 论文排版
