# 卷积神经网络 (CNN)

## 1. 视觉问题的特殊性

### 1.1 为什么全连接网络不适合图像？

考虑一张 $224 \times 224 \times 3$ 的RGB图像，第一层如果有1024个神经元：

参数数量：$224 \times 224 \times 3 \times 1024 \approx 154\text{M}$

**问题链**：
1. **参数量爆炸**：15亿参数，需要海量数据防止过拟合
2. **空间结构丢失**：将2D图像展平为1D向量，破坏了像素间的空间关系
3. **平移不变性缺失**：同一物体在不同位置的像素分布差异巨大，全连接网络无法共享检测模式
4. **计算冗余**：每个输出神经元都要处理所有输入像素

### 1.2 卷积网络的核心思想

CNN通过三个关键设计解决上述问题：

| 机制 | 原理 | 解决的问题 |
|------|------|-----------|
| 稀疏连接 (Sparse Connectivity) | 每个神经元只连接局部区域 | 参数爆炸 |
| 参数共享 (Parameter Sharing) | 同一个卷积核在整张图上滑动 | 平移等变性 |
| 下采样 (Pooling/Stride) | 逐步减小特征图尺寸 | 计算效率、感受野扩大 |

### 1.3 平移等变性

卷积操作具有**平移等变性**：如果输入平移 $\Delta$，则输出也平移 $\Delta$：

$$
\text{Conv}(\text{shift}_{\Delta}(I)) = \text{shift}_{\Delta}(\text{Conv}(I))
$$

这意味着网络在图像的任意位置都能检测到相同的模式（边缘、纹理、物体部件）。

## 2. 卷积的数学定义

### 2.1 一维卷积

离散序列的一维卷积：

$$
(f * g)[n] = \sum_{m=-\infty}^{\infty} f[m] \cdot g[n-m]
$$

在深度学习实践中，我们使用**互相关（Cross-Correlation）**操作（不翻转核）：

$$
y[n] = \sum_{m=0}^{K-1} w[m] \cdot x[n+m]
$$

### 2.2 二维卷积（核心）

对于输入 $\mathbf{X} \in \mathbb{R}^{H \times W}$ 和卷积核 $\mathbf{K} \in \mathbb{R}^{k_h \times k_w}$：

$$
\mathbf{Y}[i, j] = \sum_{p=0}^{k_h-1} \sum_{q=0}^{k_w-1} \mathbf{K}[p, q] \cdot \mathbf{X}[i + p, j + q]
$$

加上**步长 (Stride)** $s$ 和**填充 (Padding)** $p$ 后，输出尺寸：

$$
H_{\text{out}} = \left\lfloor \frac{H_{\text{in}} + 2p_h - k_h}{s_h} \right\rfloor + 1
$$
$$
W_{\text{out}} = \left\lfloor \frac{W_{\text{in}} + 2p_w - k_w}{s_w} \right\rfloor + 1
$$

### 2.3 扩张卷积 (Dilated Convolution)

在卷积核元素之间插入空洞（hole），等效于增大感受野而不增加参数量：

$$
\mathbf{Y}[i, j] = \sum_{p=0}^{k_h-1} \sum_{q=0}^{k_w-1} \mathbf{K}[p, q] \cdot \mathbf{X}[i + p \cdot d, j + q \cdot d]
$$

其中 $d$ 是扩张率（dilation rate）。

感受野计算（含扩张）：$k' = k + (k-1)(d-1)$

**应用场景**：
- 语义分割（DeepLab系列）：获取多尺度上下文
- 时序模型（WaveNet）：指数级感受野增长

```python
# 卷积操作的可视化理解
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

def visualize_conv2d_operation():
    """可视化2D卷积的滑动过程"""
    # 创建简单的输入和卷积核
    input_data = np.array([
        [1, 2, 0, 3, 1],
        [0, 1, 2, 1, 0],
        [3, 0, 1, 2, 1],
        [2, 1, 0, 1, 3],
        [1, 2, 3, 0, 2]
    ], dtype=float)

    kernel = np.array([
        [1, 0, -1],
        [1, 0, -1],
        [1, 0, -1]
    ], dtype=float)  # 垂直边缘检测器

    H, W = input_data.shape
    kH, kW = kernel.shape
    out_H = H - kH + 1
    out_W = W - kW + 1
    output = np.zeros((out_H, out_W))

    for i in range(out_H):
        for j in range(out_W):
            patch = input_data[i:i+kH, j:j+kW]
            output[i, j] = np.sum(patch * kernel)

    # 可视化
    fig, axes = plt.subplots(2, 4, figsize=(16, 8))

    # 输入图像
    im0 = axes[0, 0].imshow(input_data, cmap='viridis', aspect='equal')
    axes[0, 0].set_title('输入 5×5')
    plt.colorbar(im0, ax=axes[0, 0])

    # 卷积核
    im1 = axes[0, 1].imshow(kernel, cmap='RdBu', aspect='equal')
    axes[0, 1].set_title('卷积核 3×3 (垂直边缘)')
    plt.colorbar(im1, ax=axes[0, 1])

    # 可视化滑动过程 (4个位置)
    positions = [(0, 0), (0, 2), (2, 0), (2, 2)]
    for idx, (i, j) in enumerate(positions):
        ax = axes[1, idx]
        ax.imshow(input_data, cmap='viridis', aspect='equal')
        rect = patches.Rectangle((j-0.5, i-0.5), kW, kH,
                                  linewidth=3, edgecolor='red',
                                  facecolor='none')
        ax.add_patch(rect)
        ax.set_title(f'位置({i},{j}): 输出={output[i,j]:.0f}')

    # 输出特征图
    im2 = axes[0, 2].imshow(output, cmap='RdBu', aspect='equal')
    axes[0, 2].set_title(f'输出 {out_H}×{out_W}')
    plt.colorbar(im2, ax=axes[0, 2])

    # 示意说明
    axes[0, 3].axis('off')
    axes[0, 3].text(0.5, 0.5,
        '输出[i, j] = Σ(K ⊙ X[i:i+kh, j:j+kw])\n\n'
        f'输入尺寸: {H}×{W}\n'
        f'核尺寸: {kH}×{kW}\n'
        f'输出尺寸: {out_H}×{out_W}\n'
        f'参数数量: {kH*kW}=9',
        fontsize=11, ha='center', va='center',
        transform=axes[0, 3].transAxes)

    plt.suptitle('2D卷积的滑动窗口过程', fontsize=14)
    plt.tight_layout()
    plt.show()

visualize_conv2d_operation()


# Stride和Padding对输出尺寸的影响
def compute_output_size(H_in, W_in, kernel_size, stride, padding):
    H_out = (H_in + 2 * padding - kernel_size) // stride + 1
    W_out = (W_in + 2 * padding - kernel_size) // stride + 1
    return H_out, W_out

# Padding方式
print("=" * 60)
print("Padding方式对比:")
print("-" * 60)
print("Valid Padding (p=0): 无填充，输出尺寸缩小")
print(f"  224x224 -> k=3, s=1, p=0: "
      f"{compute_output_size(224, 224, 3, 1, 0)}")
print(f"  224x224 -> k=3, s=2, p=0: "
      f"{compute_output_size(224, 224, 3, 2, 0)}")
print()
print("Same Padding (p=(k-1)/2): 输出尺寸不变")
print(f"  224x224 -> k=3, s=1, p=1: "
      f"{compute_output_size(224, 224, 3, 1, 1)}")
print(f"  224x224 -> k=5, s=1, p=2: "
      f"{compute_output_size(224, 224, 5, 1, 2)}")
print()
print("Full Padding: 输出尺寸扩大")
print(f"  224x224 -> k=3, s=1, p=2: "
      f"{compute_output_size(224, 224, 3, 1, 2)}")
print("=" * 60)
```

## 3. 多通道卷积

### 3.1 单输入多通道

输入 $\mathbf{X} \in \mathbb{R}^{C_{\text{in}} \times H \times W}$，每个输入通道使用独立的2D卷积核，然后求和：

$$
\mathbf{Y}[j] = \sum_{c=0}^{C_{\text{in}}-1} \mathbf{K}[c] * \mathbf{X}[c] + b[j]
$$

第 $j$ 个输出通道的卷积核 $\mathbf{K}[j] \in \mathbb{R}^{C_{\text{in}} \times k_h \times k_w}$。

### 3.2 多输出通道

一个卷积层有 $C_{\text{out}}$ 个输出通道，每个输出通道有一个完整的 $C_{\text{in}} \times k_h \times k_w$ 卷积核：

总参数量：$C_{\text{out}} \times C_{\text{in}} \times k_h \times k_w$

### 3.3 1×1 卷积

当 $k_h = k_w = 1$ 时，卷积退化为逐位置的通道间线性混合：

$$
\mathbf{Y}[b, j, i, j'] = \sum_{c=0}^{C_{\text{in}}-1} \mathbf{K}[j, c] \cdot \mathbf{X}[b, c, i, j']
$$

**作用**：
- **降维/升维**：改变通道数而不改变空间维度
- **参数量控制**：在3×3卷积前用1×1降低通道数（Inception中的Bottleneck）
- **增加非线性**：在1×1后接激活函数

```python
# 多通道卷积的可视化与实现
import torch
import torch.nn as nn
import torch.nn.functional as F

# 多通道卷积示例
def multichannel_conv_demo():
    # 创建模拟RGB图像: batch=1, channels=3, H=6, W=6
    rgb_image = torch.tensor([[
        [[1., 2., 3., 0., 1., 2.],
         [0., 1., 2., 3., 0., 1.],
         [3., 0., 1., 2., 3., 0.],
         [2., 3., 0., 1., 2., 3.],
         [1., 2., 3., 0., 1., 2.],
         [0., 1., 2., 3., 0., 1.]],

        [[0., 1., 0., 2., 0., 1.],
         [2., 0., 1., 0., 2., 0.],
         [0., 2., 0., 1., 0., 2.],
         [1., 0., 2., 0., 1., 0.],
         [0., 1., 0., 2., 0., 1.],
         [2., 0., 1., 0., 2., 0.]],

        [[3., 2., 1., 0., 3., 2.],
         [1., 0., 3., 2., 1., 0.],
         [2., 1., 0., 3., 2., 1.],
         [0., 3., 2., 1., 0., 3.],
         [3., 2., 1., 0., 3., 2.],
         [1., 0., 3., 2., 1., 0.]]
    ]])

    print(f"输入张量形状: {rgb_image.shape}")
    print(f"  Batch={rgb_image.shape[0]}, Channels={rgb_image.shape[1]}, "
          f"H={rgb_image.shape[2]}, W={rgb_image.shape[3]}")

    # 卷积层: 3输入通道 -> 2输出通道, 3x3核
    conv1 = nn.Conv2d(in_channels=3, out_channels=2, kernel_size=3,
                      stride=1, padding=0, bias=True)
    conv1.weight.data = torch.randn_like(conv1.weight.data) * 0.5

    output = conv1(rgb_image)
    print(f"\n输出张量形状: {output.shape}")
    print(f"  Batch={output.shape[0]}, Channels={output.shape[1]}, "
          f"H={output.shape[2]}, W={output.shape[3]}")
    print(f"\n参数量: {sum(p.numel() for p in conv1.parameters())}")
    print(f"  权重: {conv1.weight.shape} = "
          f"out_ch × in_ch × k_h × k_w = "
          f"{2} × {3} × {3} × {3}")

    # 1x1卷积示例
    print("\n" + "="*50)
    print("1×1 卷积 (通道混合)")
    conv1x1 = nn.Conv2d(3, 2, kernel_size=1)
    print(f"  1×1 卷积核形状: {conv1x1.weight.shape}")
    print(f"  参数量: {sum(p.numel() for p in conv1x1.parameters())}")
    output_1x1 = conv1x1(rgb_image)
    print(f"  1×1 卷积输出形状: {output_1x1.shape}")
    print(f"  输入形状: {rgb_image.shape} -> 输出形状: {output_1x1.shape}")

multichannel_conv_demo()
```

## 4. 池化 (Pooling)

### 4.1 最大池化 (Max Pooling)

在 $k \times k$ 窗口内取最大值：

$$
\mathbf{Y}[i, j] = \max_{p=0}^{k-1}\max_{q=0}^{k-1} \mathbf{X}[i \cdot s + p, j \cdot s + q]
$$

反向传播：梯度只传递到最大值位置（稀疏梯度）。

### 4.2 平均池化 (Average Pooling)

$$
\mathbf{Y}[i, j] = \frac{1}{k^2}\sum_{p=0}^{k-1}\sum_{q=0}^{k-1} \mathbf{X}[i \cdot s + p, j \cdot s + q]
$$

### 4.3 全局池化 (Global Pooling)

对整个特征图进行池化，输出 $1 \times 1$ 的空间尺寸。

**全局平均池化 (GAP)** 在分类网络中常替代全连接层，优点：
- 消除参数量巨大的FC层
- 强制特征图与类别之间的对应关系
- 天然接受任意尺寸输入

```python
# 池化层对比
import torch.nn.functional as F

tensor = torch.tensor([[
    [[1., 3., 2., 4.],
     [5., 6., 7., 8.],
     [9., 1., 2., 4.],
     [5., 6., 1., 8.]]
]])

print("输入张量:")
print(tensor[0, 0])
print()

# Max Pooling
max_pool = F.max_pool2d(tensor, kernel_size=2, stride=2)
print("Max Pooling (2×2, stride=2):")
print(max_pool[0, 0])

# Average Pooling
avg_pool = F.avg_pool2d(tensor, kernel_size=2, stride=2)
print("\nAverage Pooling (2×2, stride=2):")
print(avg_pool[0, 0])

# Adaptive Pooling (输出固定尺寸)
adaptive_pool = F.adaptive_avg_pool2d(tensor, (1, 1))
print("\nGlobal Average Pooling (输出1×1):")
print(adaptive_pool[0, 0])

# Pooling with stride vs convolution with stride
print("\n" + "="*50)
print("下采样方案对比:")
print("1. Pooling: 无参数，简单高效")
print("2. Conv s=2: 有参数，可学习下采样")
print("3. Conv s=1 + Pooling: 经典组合 (AlexNet, VGG)")
print("4. Conv s=2 (no pooling): 现代做法 (ResNet)")
```

## 5. 深度可分离卷积与分组卷积

### 5.1 分组卷积 (Grouped Convolution)

将输入通道分成 $G$ 组，每组独立卷积：

参数量：$\frac{C_{\text{out}}}{G} \times \frac{C_{\text{in}}}{G} \times k_h \times k_w \times G = \frac{C_{\text{out}} \times C_{\text{in}} \times k_h \times k_w}{G}$

标准卷积：$G=1$；Depthwise卷积：$G=C_{\text{in}}=C_{\text{out}}$。

### 5.2 深度可分离卷积

将标准卷积分解为两步：

**步骤1 - Depthwise卷积**：每个输入通道独立进行空间卷积（$G=C_{\text{in}}$）

**步骤2 - Pointwise卷积**：$1 \times 1$ 卷积混合通道信息

参数量对比（$k_h=k_w=3, C_{\text{in}}=C_{\text{out}}=C$）：
- 标准卷积：$3 \times 3 \times C \times C = 9C^2$
- 深度可分离：$3 \times 3 \times C + C \times C = 9C + C^2$

比值：$\frac{9C + C^2}{9C^2} = \frac{1}{C} + \frac{1}{9} \approx \frac{1}{9}$ (大C时)

**节省约9倍参数和计算量！**

## 6. 感受野 (Receptive Field)

### 6.1 定义

网络中第 $l$ 层某个位置的激活值所"看到"的输入图像区域大小。

### 6.2 递推公式

$$
RF_l = RF_{l-1} + (k_l - 1) \times \prod_{i=1}^{l-1} s_i
$$

其中 $RF_0 = 1$（输入层一个像素的感受野是1）。

**直觉理解**：每增加一层 $k \times k$ 卷积，感受野扩张 $(k-1)$ 乘以之前所有步长的乘积。

### 6.3 有效感受野

理论感受野内不同位置的像素对输出的贡献不是均匀的——中心像素比边缘像素贡献大得多，贡献呈高斯分布。这称为**有效感受野**（ERF）。

```python
# 感受野计算工具
def calculate_receptive_field(layers):
    """
    layers: [(kernel_size, stride), ...] 从输入到输出
    Returns: 每层结束时的感受野
    """
    rf = 1
    jump = 1  # 当前层相邻特征点对应输入像素的距离
    results = []

    for i, (k, s) in enumerate(layers):
        jump *= s
        rf += (k - 1) * (jump // s)
        results.append((rf, jump))

    return results


# VGG16的感受野
vgg_layers = [
    (3, 1), (3, 2),   # Block 1
    (3, 1), (3, 2),   # Block 2
    (3, 1), (3, 1), (3, 2),  # Block 3
    (3, 1), (3, 1), (3, 2),  # Block 4
    (3, 1), (3, 1), (3, 2),  # Block 5
]

print("VGG16 感受野分析:")
print("=" * 60)
rf_results = calculate_receptive_field(vgg_layers)
for i, (rf, jump) in enumerate(rf_results):
    if i < len(vgg_layers):
        k, s = vgg_layers[i]
        print(f"Layer {i+1:2d} (k={k}, s={s}): RF={rf:3d}, Jump={jump:2d}")
    if rf >= 200 and (i == 0 or rf_results[i-1][0] < 200):
        print(f"  >>> 感受野达到 {rf} 像素 [{i+1}层卷积]")

print(f"\n最终感受野: {rf_results[-1][0]} 像素")
print(f"输出特征图一个像素对应输入的 {rf_results[-1][1]} 个像素间隔")


# ResNet50的感受野（不含skip connection的重叠效应）
resnet_layers = [
    (7, 2),   # conv1
    (3, 2),   # maxpool
    (1, 1), (3, 1), (1, 1),  # Bottleneck ×3
    (1, 2), (3, 1), (1, 1),  # Bottleneck ×4
    (1, 2), (3, 1), (1, 1),  # Bottleneck ×6
    (1, 2), (3, 1), (1, 1),  # Bottleneck ×3
]

print("\nResNet50 感受野分析:")
print("=" * 60)
rf_res = calculate_receptive_field(resnet_layers)
print(f"最终感受野: {rf_res[-1][0]} 像素")
```

## 7. 从零实现 Conv2d (前向 + 反向)

```python
# 从零实现卷积 Conv2d - 包含前向和反向传播
import numpy as np
import matplotlib.pyplot as plt

class Conv2d:
    """Numpy实现的全功能2D卷积层(前向+反向)"""

    def __init__(self, in_channels, out_channels, kernel_size,
                 stride=1, padding=0, dilation=1, bias=True):
        if isinstance(kernel_size, int):
            kernel_size = (kernel_size, kernel_size)
        if isinstance(stride, int):
            stride = (stride, stride)
        if isinstance(padding, int):
            padding = (padding, padding)

        self.in_channels = in_channels
        self.out_channels = out_channels
        self.kernel_size = kernel_size
        self.stride = stride
        self.padding = padding
        self.dilation = dilation

        # He初始化
        fan_in = in_channels * kernel_size[0] * kernel_size[1]
        scale = np.sqrt(2.0 / fan_in)
        self.W = np.random.randn(out_channels, in_channels,
                                  kernel_size[0], kernel_size[1]) * scale
        self.b = np.zeros(out_channels) if bias else None

        # 梯度缓存
        self.dW = np.zeros_like(self.W)
        self.db = np.zeros_like(self.b) if bias else None

    def forward(self, X):
        """
        X: (N, C_in, H, W)
        Returns: (N, C_out, H_out, W_out)
        """
        self.X = X
        N, C_in, H, W = X.shape
        kH, kW = self.kernel_size
        sH, sW = self.stride
        pH, pW = self.padding

        H_out = (H + 2 * pH - kH) // sH + 1
        W_out = (W + 2 * pW - kW) // sW + 1

        # Padding
        X_padded = np.pad(X, ((0, 0), (0, 0), (pH, pH), (pW, pW)),
                          mode='constant')

        self.X_padded = X_padded
        output = np.zeros((N, self.out_channels, H_out, W_out))

        # Im2Col: 将滑动窗口展开为矩阵列
        # 对于小规模的可读实现使用显式循环
        for n in range(N):
            for oc in range(self.out_channels):
                for i in range(H_out):
                    for j in range(W_out):
                        i_start = i * sH
                        j_start = j * sW
                        patch = X_padded[n, :, i_start:i_start+kH,
                                         j_start:j_start+kW]
                        output[n, oc, i, j] = np.sum(
                            patch * self.W[oc]) + (self.b[oc] if self.b is not None else 0)

        return output

    def backward(self, dout, lr=0.01):
        """
        dout: (N, C_out, H_out, W_out) 上游梯度
        Returns: (N, C_in, H, W) 下游梯度
        """
        N, C_out, H_out, W_out = dout.shape
        kH, kW = self.kernel_size
        sH, sW = self.stride
        pH, pW = self.padding

        X_padded = self.X_padded

        # 初始化梯度
        dx_padded = np.zeros_like(X_padded)
        self.dW = np.zeros_like(self.W)
        if self.db is not None:
            self.db = np.zeros_like(self.b)

        # 计算梯度
        for n in range(N):
            for oc in range(C_out):
                for i in range(H_out):
                    for j in range(W_out):
                        dout_val = dout[n, oc, i, j]
                        i_start = i * sH
                        j_start = j * sW

                        # dW: 输入patch × 上游梯度
                        patch = X_padded[n, :, i_start:i_start+kH,
                                         j_start:j_start+kW]
                        self.dW[oc] += patch * dout_val

                        # dx_padded: 卷积核 × 上游梯度
                        dx_padded[n, :, i_start:i_start+kH,
                                  j_start:j_start+kW] += self.W[oc] * dout_val

                # db: 上游梯度求和
                if self.db is not None:
                    self.db[oc] += np.sum(dout[n, oc])

        # 去除padding得到dx
        if pH > 0 or pW > 0:
            dx = dx_padded[:, :, pH:-pH, pW:-pW] if pH > 0 else dx_padded[:, :, :, :]
            if pW > 0 and pH == 0:
                dx = dx_padded[:, :, :, pW:-pW]
        else:
            dx = dx_padded

        # 更新参数
        self.W -= lr * self.dW / N
        if self.b is not None:
            self.b -= lr * self.db / N

        return dx


# 测试Conv2d
np.random.seed(42)

# 创建简单数据
X_test = np.random.randn(2, 3, 8, 8)  # 2张3通道8x8图像
conv = Conv2d(in_channels=3, out_channels=4, kernel_size=3,
              stride=1, padding=1)

# 前向传播
out = conv.forward(X_test)
print(f"输入形状: {X_test.shape}")
print(f"卷积参数: in=3, out=4, k=3, s=1, p=1")
print(f"输出形状: {out.shape}")
print(f"权重形状: {conv.W.shape}")

# 反向传播测试
dout = np.random.randn(*out.shape)
dx = conv.backward(dout, lr=0.01)
print(f"dX形状: {dx.shape}")
print(f"dW形状: {conv.dW.shape}")

# 验证：通过numpy的卷积函数验证输出正确性
import numpy.lib.stride_tricks as stride_tricks

def verify_conv_forward(conv, X):
    """使用scipy验证卷积输出"""
    from scipy.signal import correlate2d

    N, C_in, H, W = X.shape
    pH, pW = conv.padding
    X_pad = np.pad(X, ((0, 0), (0, 0), (pH, pH), (pW, pW)))
    H_out = (H + 2*pH - conv.kernel_size[0]) // conv.stride[0] + 1
    W_out = (W + 2*pW - conv.kernel_size[1]) // conv.stride[1] + 1

    ref_out = np.zeros((N, conv.out_channels, H_out, W_out))
    for n in range(N):
        for oc in range(conv.out_channels):
            for ic in range(C_in):
                ref_out[n, oc] += correlate2d(
                    X_pad[n, ic],
                    conv.W[oc, ic],
                    mode='valid'
                )[::conv.stride[0], ::conv.stride[1]]
            ref_out[n, oc] += conv.b[oc]

    our_out = conv.forward(X)
    diff = np.abs(ref_out - our_out).max()
    print(f"前向传播验证: 最大差异 = {diff:.10f}")
    return diff

try:
    verify_conv_forward(conv, X_test)
except:
    print("(验证需要安装scipy)")
```

## 8. PyTorch CIFAR-10 完整训练 Pipeline

```python
# CIFAR-10 完整的CNN训练Pipeline
import torch
import torch.nn as nn
import torch.optim as optim
import torch.nn.functional as F
from torch.utils.data import DataLoader, random_split
from torchvision import datasets, transforms
from torch.optim.lr_scheduler import CosineAnnealingLR
import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import classification_report, confusion_matrix
import seaborn as sns
from tqdm import tqdm
import time
import os

# ========== 配置 ==========
torch.manual_seed(42)
np.random.seed(42)
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f'设备: {device}')

# ========== 数据增强与加载 ==========
# 训练集增强
train_transform = transforms.Compose([
    transforms.RandomCrop(32, padding=4),
    transforms.RandomHorizontalFlip(),
    transforms.ColorJitter(brightness=0.1, contrast=0.1, saturation=0.1),
    transforms.RandomRotation(15),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.4914, 0.4822, 0.4465],
                         std=[0.2470, 0.2435, 0.2616])
])

# 测试集变换
test_transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.4914, 0.4822, 0.4465],
                         std=[0.2470, 0.2435, 0.2616])
])

# 加载CIFAR-10
try:
    full_train_dataset = datasets.CIFAR10(
        root='./data', train=True, download=True, transform=train_transform)
    test_dataset = datasets.CIFAR10(
        root='./data', train=False, download=True, transform=test_transform)
except:
    print("离线模式: 使用随机数据模拟训练")
    # 创建模拟数据用于代码演示
    from torch.utils.data import TensorDataset
    X_sim = torch.randn(5000, 3, 32, 32)
    y_sim = torch.randint(0, 10, (5000,))
    full_train_dataset = TensorDataset(X_sim, y_sim)
    X_test_sim = torch.randn(1000, 3, 32, 32)
    y_test_sim = torch.randint(0, 10, (1000,))
    test_dataset = TensorDataset(X_test_sim, y_test_sim)

# 划分训练/验证集
train_size = int(0.85 * len(full_train_dataset))
val_size = len(full_train_dataset) - train_size
train_dataset, val_dataset = random_split(
    full_train_dataset, [train_size, val_size],
    generator=torch.Generator().manual_seed(42))

# 验证集用测试变换
val_dataset.dataset.transform = test_transform

BATCH_SIZE = 128
train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE,
                          shuffle=True, num_workers=2, pin_memory=True)
val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE,
                        shuffle=False, num_workers=2, pin_memory=True)
test_loader = DataLoader(test_dataset, batch_size=BATCH_SIZE,
                         shuffle=False, num_workers=2, pin_memory=True)

# 类别名称
classes = ('airplane', 'automobile', 'bird', 'cat', 'deer',
           'dog', 'frog', 'horse', 'ship', 'truck')

print(f'训练: {train_size}, 验证: {val_size}, 测试: {len(test_dataset)}')


# ========== CNN模型 ==========
class CIFAR10_CNN(nn.Module):
    """改进的CIFAR-10 CNN架构: 受VGG/ResNet启发"""

    def __init__(self, num_classes=10, dropout_rate=0.3):
        super(CIFAR10_CNN, self).__init__()

        # Block 1
        self.conv1_1 = nn.Conv2d(3, 64, 3, padding=1)
        self.bn1_1 = nn.BatchNorm2d(64)
        self.conv1_2 = nn.Conv2d(64, 64, 3, padding=1)
        self.bn1_2 = nn.BatchNorm2d(64)
        self.pool1 = nn.MaxPool2d(2, 2)
        self.drop1 = nn.Dropout2d(dropout_rate * 0.5)

        # Block 2
        self.conv2_1 = nn.Conv2d(64, 128, 3, padding=1)
        self.bn2_1 = nn.BatchNorm2d(128)
        self.conv2_2 = nn.Conv2d(128, 128, 3, padding=1)
        self.bn2_2 = nn.BatchNorm2d(128)
        self.pool2 = nn.MaxPool2d(2, 2)
        self.drop2 = nn.Dropout2d(dropout_rate * 0.75)

        # Block 3
        self.conv3_1 = nn.Conv2d(128, 256, 3, padding=1)
        self.bn3_1 = nn.BatchNorm2d(256)
        self.conv3_2 = nn.Conv2d(256, 256, 3, padding=1)
        self.bn3_2 = nn.BatchNorm2d(256)
        self.conv3_3 = nn.Conv2d(256, 256, 3, padding=1)
        self.bn3_3 = nn.BatchNorm2d(256)
        self.pool3 = nn.MaxPool2d(2, 2)
        self.drop3 = nn.Dropout2d(dropout_rate)

        # Block 4 (1x1卷积降维 + 3x3)
        self.conv4_1 = nn.Conv2d(256, 256, 1)
        self.bn4_1 = nn.BatchNorm2d(256)
        self.conv4_2 = nn.Conv2d(256, 512, 3, padding=1)
        self.bn4_2 = nn.BatchNorm2d(512)
        self.pool4 = nn.MaxPool2d(2, 2)
        self.drop4 = nn.Dropout2d(dropout_rate)

        # 全局平均池化 + 分类器
        self.gap = nn.AdaptiveAvgPool2d(1)
        self.fc = nn.Linear(512, num_classes)

        self._init_weights()

    def _init_weights(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode='fan_out',
                                        nonlinearity='relu')
                if m.bias is not None:
                    nn.init.constant_(m.bias, 0)
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)
            elif isinstance(m, nn.Linear):
                nn.init.kaiming_normal_(m.weight)
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        # Block 1
        x = F.relu(self.bn1_1(self.conv1_1(x)))
        x = F.relu(self.bn1_2(self.conv1_2(x)))
        x = self.pool1(x)
        x = self.drop1(x)

        # Block 2
        x = F.relu(self.bn2_1(self.conv2_1(x)))
        x = F.relu(self.bn2_2(self.conv2_2(x)))
        x = self.pool2(x)
        x = self.drop2(x)

        # Block 3
        x = F.relu(self.bn3_1(self.conv3_1(x)))
        x = F.relu(self.bn3_2(self.conv3_2(x)))
        x = F.relu(self.bn3_3(self.conv3_3(x)))
        x = self.pool3(x)
        x = self.drop3(x)

        # Block 4
        x = F.relu(self.bn4_1(self.conv4_1(x)))
        x = F.relu(self.bn4_2(self.conv4_2(x)))
        x = self.pool4(x)
        x = self.drop4(x)

        # Global Average Pooling
        x = self.gap(x)
        x = x.view(x.size(0), -1)
        x = self.fc(x)

        return x


model = CIFAR10_CNN(num_classes=10, dropout_rate=0.3).to(device)
print(f'\n模型参数量: {sum(p.numel() for p in model.parameters()):,}')
print(f'可训练参数: {sum(p.numel() for p in model.parameters() if p.requires_grad):,}')


# ========== 训练设置 ==========
criterion = nn.CrossEntropyLoss(label_smoothing=0.1)
optimizer = optim.AdamW(model.parameters(), lr=0.003,
                        weight_decay=5e-4, betas=(0.9, 0.999))
scheduler = CosineAnnealingLR(optimizer, T_max=80, eta_min=1e-6)

# 混合精度训练（如果可用）
scaler = torch.cuda.amp.GradScaler() if device.type == 'cuda' else None


def train_epoch(model, loader, criterion, optimizer, device, scaler=None):
    model.train()
    total_loss, correct, total = 0.0, 0, 0

    pbar = tqdm(loader, desc='Training', leave=False)
    for inputs, targets in pbar:
        inputs, targets = inputs.to(device), targets.to(device)

        optimizer.zero_grad()

        if scaler:
            with torch.cuda.amp.autocast():
                outputs = model(inputs)
                loss = criterion(outputs, targets)
            scaler.scale(loss).backward()
            scaler.unscale_(optimizer)
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            scaler.step(optimizer)
            scaler.update()
        else:
            outputs = model(inputs)
            loss = criterion(outputs, targets)
            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            optimizer.step()

        total_loss += loss.item() * inputs.size(0)
        _, predicted = outputs.max(1)
        total += targets.size(0)
        correct += predicted.eq(targets).sum().item()

        pbar.set_postfix({
            'loss': f'{loss.item():.3f}',
            'acc': f'{100.*correct/total:.1f}%'
        })

    return total_loss / total, 100. * correct / total


def evaluate(model, loader, criterion, device):
    model.eval()
    total_loss, correct, total = 0.0, 0, 0
    all_preds, all_labels = [], []

    with torch.no_grad():
        for inputs, targets in tqdm(loader, desc='Evaluating', leave=False):
            inputs, targets = inputs.to(device), targets.to(device)
            outputs = model(inputs)
            loss = criterion(outputs, targets)

            total_loss += loss.item() * inputs.size(0)
            _, predicted = outputs.max(1)
            total += targets.size(0)
            correct += predicted.eq(targets).sum().item()

            all_preds.extend(predicted.cpu().numpy())
            all_labels.extend(targets.cpu().numpy())

    return total_loss / total, 100. * correct / total, all_preds, all_labels


# ========== 训练循环 ==========
EPOCHS = 80
PATIENCE = 15
history = {'train_loss': [], 'train_acc': [], 'val_loss': [], 'val_acc': []}
best_acc, best_epoch, patience_counter = 0.0, 0, 0

os.makedirs('checkpoints', exist_ok=True)

for epoch in range(EPOCHS):
    start_time = time.time()

    # 训练
    train_loss, train_acc = train_epoch(
        model, train_loader, criterion, optimizer, device, scaler)

    # 验证
    val_loss, val_acc, _, _ = evaluate(
        model, val_loader, criterion, device)

    # 学习率调度
    scheduler.step()

    # 记录
    history['train_loss'].append(train_loss)
    history['train_acc'].append(train_acc)
    history['val_loss'].append(val_loss)
    history['val_acc'].append(val_acc)

    epoch_time = time.time() - start_time

    # 打印
    lr = optimizer.param_groups[0]['lr']
    print(f'Epoch {epoch+1:3d}/{EPOCHS} | '
          f'Train: {train_acc:.2f}% ({train_loss:.4f}) | '
          f'Val: {val_acc:.2f}% ({val_loss:.4f}) | '
          f'LR: {lr:.2e} | Time: {epoch_time:.1f}s')

    # 早停与模型保存
    if val_acc > best_acc:
        best_acc = val_acc
        best_epoch = epoch + 1
        patience_counter = 0
        torch.save({
            'epoch': epoch,
            'model_state_dict': model.state_dict(),
            'optimizer_state_dict': optimizer.state_dict(),
            'best_acc': best_acc,
            'history': history,
        }, 'checkpoints/best_model.pth')
        print(f'  >>> 最佳模型已保存 (Acc: {best_acc:.2f}%)')
    else:
        patience_counter += 1
        if patience_counter >= PATIENCE:
            print(f'\n早停触发! 最佳验证准确率: {best_acc:.2f}% @ Epoch {best_epoch}')
            break

# 加载最佳模型
checkpoint = torch.load('checkpoints/best_model.pth')
model.load_state_dict(checkpoint['model_state_dict'])

# ========== 测试集评估 ==========
test_loss, test_acc, test_preds, test_labels = evaluate(
    model, test_loader, criterion, device)
print(f'\n{"="*50}')
print(f'测试集结果:')
print(f'Loss: {test_loss:.4f}')
print(f'准确率: {test_acc:.2f}%')
print(f'{"="*50}')

# 分类报告
print('\n分类报告:')
print(classification_report(test_labels, test_preds, target_names=classes))

# 混淆矩阵
cm = confusion_matrix(test_labels, test_preds)
cm_norm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]

fig, ax = plt.subplots(figsize=(10, 8))
sns.heatmap(cm_norm, annot=True, fmt='.2f', cmap='Blues',
            xticklabels=classes, yticklabels=classes,
            vmin=0, vmax=1, ax=ax)
ax.set_xlabel('预测类别')
ax.set_ylabel('真实类别')
ax.set_title(f'CIFAR-10 混淆矩阵 (归一化)\n测试准确率: {test_acc:.2f}%')
plt.tight_layout()
plt.show()

# 训练曲线
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

axes[0].plot(history['train_loss'], label='训练', linewidth=2)
axes[0].plot(history['val_loss'], label='验证', linewidth=2)
axes[0].set_xlabel('Epoch')
axes[0].set_ylabel('Loss')
axes[0].set_title('损失曲线')
axes[0].legend()
axes[0].grid(True, alpha=0.3)
axes[0].axvline(x=best_epoch-1, color='red', linestyle='--', alpha=0.5,
                label=f'Best@{best_epoch}')

axes[1].plot(history['train_acc'], label='训练', linewidth=2)
axes[1].plot(history['val_acc'], label='验证', linewidth=2)
axes[1].set_xlabel('Epoch')
axes[1].set_ylabel('准确率 (%)')
axes[1].set_title('准确率曲线')
axes[1].legend()
axes[1].grid(True, alpha=0.3)
axes[1].axvline(x=best_epoch-1, color='red', linestyle='--', alpha=0.5)

plt.suptitle(f'CIFAR-10 CNN 训练曲线 (最佳: {best_acc:.2f}%)', fontsize=14)
plt.tight_layout()
plt.show()
```

## 9. 特征图可视化

```python
# 卷积特征图与卷积核可视化
import torch
import torchvision
import matplotlib.pyplot as plt
import numpy as np

def visualize_feature_maps(model, image, layer_names, max_filters=16):
    """
    可视化CNN中间层的特征图
    Args:
        model: 训练好的CNN模型
        image: 输入图像 (经过预处理)
        layer_names: 要可视化的层名称列表
    """
    model.eval()
    activations = {}

    def get_activation(name):
        def hook(model, input, output):
            activations[name] = output.detach()
        return hook

    # 注册hook
    hooks = []
    for name, module in model.named_modules():
        if name in layer_names:
            hooks.append(module.register_forward_hook(get_activation(name)))

    # 前向传播
    with torch.no_grad():
        _ = model(image.unsqueeze(0).to(device))

    # 移除hook
    for h in hooks:
        h.remove()

    # 可视化
    for name in layer_names:
        if name not in activations:
            continue

        act = activations[name][0]  # (C, H, W)
        n_filters = min(act.shape[0], max_filters)
        n_cols = 8
        n_rows = (n_filters + n_cols - 1) // n_cols

        fig, axes = plt.subplots(n_rows, n_cols, figsize=(16, 2 * n_rows))
        axes = axes.flatten()

        for i in range(n_filters):
            feat_map = act[i].cpu().numpy()
            axes[i].imshow(feat_map, cmap='viridis')
            axes[i].axis('off')
            axes[i].set_title(f'F{i+1}', fontsize=8)

        for i in range(n_filters, len(axes)):
            axes[i].axis('off')

        plt.suptitle(f'特征图可视化: {name}', fontsize=14)
        plt.tight_layout()
        plt.show()


def visualize_kernels(model, layer_names):
    """可视化卷积核权重"""
    for name, module in model.named_modules():
        if name in layer_names and isinstance(module, nn.Conv2d):
            weight = module.weight.data.cpu()
            # weight: (out_channels, in_channels, kH, kW)
            out_c, in_c, kH, kW = weight.shape

            if in_c == 1:
                # 灰度核，直接显示
                n_cols = 8
                n_rows = (out_c + n_cols - 1) // n_cols
                fig, axes = plt.subplots(n_rows, n_cols, figsize=(12, 1.5 * n_rows))
                axes = axes.flatten()

                vmin, vmax = weight.min(), weight.max()
                for i in range(out_c):
                    axes[i].imshow(weight[i, 0], cmap='RdBu_r',
                                   vmin=vmin, vmax=vmax)
                    axes[i].axis('off')
                for i in range(out_c, len(axes)):
                    axes[i].axis('off')
                plt.suptitle(f'卷积核: {name}', fontsize=14)
                plt.tight_layout()
                plt.show()
            elif in_c == 3:
                # RGB核，显示为彩色图像
                n_cols = 8
                n_rows = (min(out_c, 16) + n_cols - 1) // n_cols
                fig, axes = plt.subplots(n_rows, n_cols, figsize=(12, 1.5 * n_rows))
                axes = axes.flatten()

                for i in range(min(out_c, 16)):
                    # 归一化到[0,1]
                    w = weight[i].permute(1, 2, 0).numpy()
                    w = (w - w.min()) / (w.max() - w.min() + 1e-8)
                    axes[i].imshow(w)
                    axes[i].axis('off')
                for i in range(min(out_c, 16), len(axes)):
                    axes[i].axis('off')
                plt.suptitle(f'卷积核 (RGB): {name}', fontsize=14)
                plt.tight_layout()
                plt.show()


# 使用示例
try:
    # 从训练好的模型中加载
    sample_img, _ = next(iter(test_loader))
    sample_img = sample_img[0]

    # 反归一化以便imshow显示
    mean = torch.tensor([0.4914, 0.4822, 0.4465]).view(3, 1, 1)
    std = torch.tensor([0.2470, 0.2435, 0.2616]).view(3, 1, 1)
    img_display = sample_img * std + mean
    img_display = img_display.clamp(0, 1)

    # 可视化最初几层的特征图
    layer_to_vis = ['conv1_1', 'conv2_1', 'conv3_1']
    visualize_feature_maps(model, sample_img.to(device), layer_to_vis, max_filters=16)

    # 可视化第一层卷积核
    visualize_kernels(model, ['conv1_1'])
except Exception as e:
    print(f"可视化需要完整训练: {e}")
```

## 10. 图像增强 (Data Augmentation)

```python
# 图像增强全面演示
from torchvision import transforms
from PIL import Image
import random

def visualize_augmentations():
    """展示各种图像增强技术"""
    # 创建简单的测试图像（模拟CIFAR-10图像）
    np.random.seed(42)
    test_img_np = np.random.randint(0, 255, (32, 32, 3), dtype=np.uint8)
    test_img_np[:10, :10] = [255, 0, 0]  # 红色方块（用于检测裁剪、旋转等）
    test_img_np[20:30, 20:30] = [0, 255, 0]
    test_img = Image.fromarray(test_img_np)

    augmentations = {
        '原图': transforms.Compose([]),
        '随机水平翻转': transforms.RandomHorizontalFlip(p=1.0),
        '随机旋转(±15°)': transforms.RandomRotation(15),
        '颜色抖动': transforms.ColorJitter(
            brightness=0.5, contrast=0.5, saturation=0.5, hue=0.1),
        '随机裁剪+填充': transforms.RandomCrop(32, padding=4),
        '随机仿射变换': transforms.RandomAffine(degrees=0, translate=(0.2, 0.2)),
        '随机透视': transforms.RandomPerspective(distortion_scale=0.3, p=1.0),
        'RandomErasing': transforms.Compose([
            transforms.ToTensor(),
            transforms.RandomErasing(p=1.0, scale=(0.1, 0.3), ratio=(0.3, 3.3)),
        ]),
        'AutoAugment(CIFAR10)': transforms.AutoAugment(
            transforms.AutoAugmentPolicy.CIFAR10) if hasattr(transforms, 'AutoAugment') else transforms.Compose([]),
    }

    n_items = len(augmentations)
    fig, axes = plt.subplots(2, (n_items + 1) // 2, figsize=(16, 7))
    axes = axes.flatten()

    for ax, (name, aug) in zip(axes, augmentations.items()):
        try:
            aug_img = aug(test_img)
            if isinstance(aug_img, torch.Tensor):
                aug_img = aug_img.permute(1, 2, 0).numpy()
                if aug_img.max() <= 1.0:
                    aug_img = (aug_img * 255).astype(np.uint8)
            else:
                aug_img = np.array(aug_img)
            ax.imshow(aug_img)
        except Exception as e:
            ax.text(0.5, 0.5, f'Error: {e}', ha='center', va='center',
                    transform=ax.transAxes)
        ax.set_title(name, fontsize=10)
        ax.axis('off')

    for i in range(len(augmentations), len(axes)):
        axes[i].axis('off')

    plt.suptitle('图像增强(Data Augmentation)技术展示', fontsize=14)
    plt.tight_layout()
    plt.show()

visualize_augmentations()


# CutMix / MixUp 示例
def mixup_data(x, y, alpha=0.2):
    """MixUp: 线性插值混合两个样本"""
    if alpha > 0:
        lam = np.random.beta(alpha, alpha)
    else:
        lam = 1.0

    batch_size = x.size(0)
    index = torch.randperm(batch_size).to(x.device)

    mixed_x = lam * x + (1 - lam) * x[index]
    y_a, y_b = y, y[index]
    return mixed_x, y_a, y_b, lam


def mixup_criterion(criterion, pred, y_a, y_b, lam):
    """MixUp损失"""
    return lam * criterion(pred, y_a) + (1 - lam) * criterion(pred, y_b)


def cutmix_data(x, y, alpha=1.0):
    """CutMix: 剪切粘贴混合"""
    lam = np.random.beta(alpha, alpha)
    batch_size, _, H, W = x.shape
    index = torch.randperm(batch_size).to(x.device)

    # 生成随机框
    cx = np.random.randint(W)
    cy = np.random.randint(H)
    cut_w = int(W * np.sqrt(1 - lam))
    cut_h = int(H * np.sqrt(1 - lam))

    x1 = np.clip(cx - cut_w // 2, 0, W)
    y1 = np.clip(cy - cut_h // 2, 0, H)
    x2 = np.clip(cx + cut_w // 2, 0, W)
    y2 = np.clip(cy + cut_h // 2, 0, H)

    # 粘贴
    x[:, :, y1:y2, x1:x2] = x[index, :, y1:y2, x1:x2]
    lam = 1 - ((x2 - x1) * (y2 - y1) / (H * W))

    return x, y, y[index], lam

print("\n数据增强总结:")
print("=" * 60)
print("基础增强: Flip, Crop, Rotation, ColorJitter")
print("高级增强: CutMix, MixUp, RandomErasing")
print("自动增强: AutoAugment, RandAugment, TrivialAugment")
print("最新进展: 基于学习的增强(如DiffAugment)")
```

## 相关笔记

- [[01-数学基础-线性代数|线性代数]] — 卷积运算的矩阵形式
- [[02-数学基础-微积分|微积分]] — 反向传播的链式法则
- [[07-神经网络|神经网络]] — 神经网络基础知识
- [[08-优化方法|优化方法]] — 训练CNN的优化器选择
- [[10-经典CNN架构|经典CNN架构]] — 里程碑式CNN架构详解
- [[06-PyTorch入门|PyTorch]] — PyTorch深度学习框架
- [[LaTeX/main.tex|LaTeX完整教程]] — 论文公式排版
