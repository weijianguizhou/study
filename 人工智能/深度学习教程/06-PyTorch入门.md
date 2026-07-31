# PyTorch 入门 — 从安装到 MNIST

PyTorch 是深度学习研究和实践中最流行的框架。它的动态计算图、Pythonic API 和丰富的生态系统使开发变得高效灵活。本章从安装配置开始，逐步深入到 Tensor 操作、自动微分、模块化建模和完整训练流程。

---

## 1. 安装与环境配置

### 1.1 安装命令

```bash
# CPU 版本
pip install torch torchvision torchaudio

# CUDA 11.8
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# CUDA 12.1
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

### 1.2 验证安装

```python
import torch
import torchvision

print(f"PyTorch 版本: {torch.__version__}")
print(f"TorchVision 版本: {torchvision.__version__}")
print(f"CUDA 可用: {torch.cuda.is_available()}")
print(f"CUDA 版本: {torch.version.cuda}")

if torch.cuda.is_available():
    print(f"GPU 数量: {torch.cuda.device_count()}")
    print(f"当前 GPU: {torch.cuda.get_device_name(0)}")
    print(f"GPU 内存: {torch.cuda.get_device_properties(0).total_mem / 1024**3:.1f} GB")

# 检测 Apple Silicon (MPS)
if hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
    print(f"MPS (Apple GPU) 可用")
```

### 1.3 设备管理

```python
import torch

# 最佳设备选择函数
def get_device():
    if torch.cuda.is_available():
        return torch.device('cuda')
    elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
        return torch.device('mps')
    else:
        return torch.device('cpu')

device = get_device()
print(f"使用设备: {device}")

# 张量移动到设备
x = torch.tensor([1.0, 2.0, 3.0])
x_gpu = x.to(device)
print(f"原始设备: {x.device}, 移动后: {x_gpu.device}")

# 推荐写法: 创建时直接指定设备
x = torch.randn(100, 100, device=device)
```

---

## 2. Tensor 操作大全

### 2.1 创建 Tensor

```python
import torch
import numpy as np

print("=" * 60)
print("Tensor 创建方法")
print("=" * 60)

# 从列表创建
t1 = torch.tensor([1, 2, 3])
print(f"从列表: {t1}")

# 从 NumPy 创建（共享内存）
np_arr = np.array([[1.0, 2.0], [3.0, 4.0]])
t2 = torch.from_numpy(np_arr)
print(f"从 NumPy:\n{t2}")

# 特殊张量
print(f"\n全零: {torch.zeros(2, 3)}")
print(f"全一: {torch.ones(2, 3)}")
print(f"单位矩阵:\n{torch.eye(3)}")
print(f"均匀分布: {torch.rand(3, 4)}")
print(f"标准正态: {torch.randn(3, 4)}")
print(f"整数范围: {torch.arange(0, 10, 2)}")
print(f"线性间隔: {torch.linspace(0, 1, 5)}")

# 指定数据类型
print(f"\nFloat32: {torch.tensor([1, 2, 3], dtype=torch.float32)}")
print(f"Float64: {torch.tensor([1, 2, 3], dtype=torch.float64)}")
print(f"Int64:   {torch.tensor([1, 2, 3], dtype=torch.int64)}")
print(f"Bool:    {torch.tensor([1, 0, 1], dtype=torch.bool)}")

# 创建与已有张量相同形状/类型的张量
template = torch.randn(3, 5)
print(f"\n与模板同形状: {torch.zeros_like(template)}")
print(f"与模板同形状 (随机): {torch.randn_like(template)}")
```

### 2.2 Tensor 属性

```python
import torch

x = torch.randn(2, 3, 4)

print(f"形状 (shape):   {x.shape}")
print(f"大小 (size):    {x.size()}")
print(f"维度数 (ndim):  {x.ndim}")
print(f"元素数 (numel): {x.numel()}")
print(f"数据类型 (dtype): {x.dtype}")
print(f"设备 (device):  {x.device}")
print(f"是否需要梯度:   {x.requires_grad}")

# 主要数据类型
dtypes = {
    'torch.float32': torch.float32,
    'torch.float64': torch.float64,
    'torch.int32': torch.int32,
    'torch.int64': torch.int64,
    'torch.bool': torch.bool,
}

print(f"\nFloat32 范围: {torch.finfo(torch.float32)}")
print(f"Int32 范围: {torch.iinfo(torch.int32)}")
```

### 2.3 索引与切片

```python
import torch

x = torch.arange(24).reshape(2, 3, 4)
print(f"原始张量:\n{x}")

# 基本索引
print(f"\nx[0]:\n{x[0]}")         # 第一个矩阵
print(f"\nx[0, 1]: {x[0, 1]}")    # 第一矩阵的第二行
print(f"\nx[0, 1, 2]: {x[0, 1, 2]}")  # 单个元素

# 切片
print(f"\nx[:, 1:, 1:3]:\n{x[:, 1:, 1:3]}")
print(f"\nx[..., -1]:\n{x[..., -1]}")  # 最后一维取最后一个

# 花式索引
indices = torch.tensor([0, 2])
print(f"\nx[0, :, indices]:\n{x[0, :, indices]}")

# 布尔索引
mask = x > 10
print(f"\n大于10的元素: {x[mask]}")

# 高级: gather 和 scatter
src = torch.arange(1, 11).reshape(2, 5)
index = torch.tensor([[4, 3, 2, 1, 0], [0, 1, 2, 3, 4]])
gathered = torch.gather(src, dim=1, index=index)
print(f"\ngather 结果:\n{gathered}")
```

### 2.4 变形与重塑

```python
import torch

x = torch.arange(12)

# view — 返回新视图（要求内存连续）
print(f"x.view(3, 4):\n{x.view(3, 4)}")
print(f"x.view(3, -1):\n{x.view(3, -1)}")

# reshape — 总是安全的（copy if needed）
print(f"\nx.reshape(4, 3):\n{x.reshape(4, 3)}")

# 添加维度
print(f"\nunsqueeze(0): shape={x.unsqueeze(0).shape}")  # (1, 12)
print(f"unsqueeze(1): shape={x.unsqueeze(1).shape}")  # (12, 1)

# 移除维度
y = x.unsqueeze(0).unsqueeze(-1)  # (1, 12, 1)
print(f"\nsqueeze: shape={y.squeeze().shape}")  # (12,)

# 展平
x_2d = torch.randn(2, 3, 4)
print(f"\nflatten: shape={x_2d.flatten().shape}")    # (24,)
print(f"flatten(start_dim=1): shape={x_2d.flatten(start_dim=1).shape}")  # (2, 12)

# 转置与 permute
print(f"\n转置前: {x_2d.shape}")
print(f"transpose(0,2): {x_2d.transpose(0, 2).shape}")  # (4, 3, 2)
print(f"permute(2,0,1): {x_2d.permute(2, 0, 1).shape}") # (4, 2, 3)

# 向量拼接
a = torch.randn(2, 3)
b = torch.randn(2, 3)
print(f"\ncat(dim=0): {torch.cat([a, b], dim=0).shape}")  # (4, 3)
print(f"cat(dim=1): {torch.cat([a, b], dim=1).shape}")  # (2, 6)
print(f"stack(dim=0): {torch.stack([a, b], dim=0).shape}") # (2, 2, 3)

# 分割
x = torch.arange(12).reshape(3, 4)
chunks = torch.chunk(x, chunks=3, dim=0)
print(f"\nchunk(3): {[c.shape for c in chunks]}")
splits = torch.split(x, split_size_or_sections=[1, 2], dim=1)
print(f"split([1,2]): {[s.shape for s in splits]}")
```

### 2.5 数学运算

```python
import torch

a = torch.randn(3, 4)
b = torch.randn(3, 4)

# 逐元素运算
print(f"加法: a + b")
print(f"减法: a - b")
print(f"乘法 (逐元素): a * b")
print(f"除法: a / b")
print(f"幂: a ** 2")
print(f"指数: torch.exp(a)")
print(f"对数: torch.log(torch.abs(a))")

# 矩阵运算
A = torch.randn(3, 4)
B = torch.randn(4, 5)
print(f"\n矩阵乘法 A @ B: {torch.matmul(A, B).shape}")  # (3, 5)
print(f"批量矩阵乘法: {torch.bmm(torch.randn(2,3,4), torch.randn(2,4,5)).shape}")  # (2,3,5)

# 归约操作
x = torch.randn(3, 4)
print(f"\n求和: {x.sum()}")
print(f"均值: {x.mean()}")
print(f"标准差: {x.std()}")
print(f"最大值: {x.max()}")
print(f"最小值: {x.min()}")
print(f"按行求和: {x.sum(dim=1)}")
print(f"按列求均值: {x.mean(dim=0)}")

# argmax / topk
print(f"\n每行 argmax: {x.argmax(dim=1)}")
print(f"每行 top-2 值:\n{x.topk(2, dim=1).values}")
print(f"每行 top-2 索引:\n{x.topk(2, dim=1).indices}")

# 比较运算
print(f"\na > 0: {a > 0}")
print(f"全部 > 0: {torch.all(a > 0)}")
print(f"存在 > 0: {torch.any(a > 0)}")
print(f"等于比较: torch.eq(a, b)")
print(f"where: {torch.where(a > 0, a, torch.zeros_like(a))}")
```

### 2.6 内存布局与性能

```python
import torch
import time

# 连续内存
x = torch.randn(100, 100)
x_t = x.T

print(f"x 是否连续: {x.is_contiguous()}")
print(f"x.T 是否连续: {x_t.is_contiguous()}")

# view 要求连续性
try:
    x_t.view(-1)
except RuntimeError as e:
    print(f"非连续张量 view 报错: {e}")

# 解决方法: contiguous()
print(f"contiguous() 后使用 view: {x_t.contiguous().view(-1).shape}")

# NumPy 共享内存
np_arr = x.numpy()  # 共享内存
np_arr[0, 0] = 999
print(f"修改 NumPy 后 PyTorch 值: {x[0, 0]:.0f}")  # 应该为 999

# 性能对比: 原地操作 vs 新建
n = 1000
tensor = torch.randn(n, n)

start = time.time()
for _ in range(100):
    tensor = tensor + 1
print(f"新建操作: {time.time() - start:.4f}s")

start = time.time()
for _ in range(100):
    tensor.add_(1)  # 原地操作
print(f"原地操作: {time.time() - start:.4f}s")
```

---

## 3. Autograd 自动微分

### 3.1 基本用法

```python
import torch

# 创建需要梯度的张量
x = torch.tensor([2.0, 3.0], requires_grad=True)
w = torch.tensor([0.5, -0.2], requires_grad=True)
b = torch.tensor(0.1, requires_grad=True)

# 计算图: z = sigmoid(w·x + b)
y = torch.dot(w, x) + b
z = torch.sigmoid(y)

print(f"前向传播: y = {y.item():.4f}, z = {z.item():.4f}")
print(f"z 的 grad_fn: {z.grad_fn}")  # <SigmoidBackward0>
print(f"y 的 grad_fn: {y.grad_fn}")  # <AddBackward0>

# 反向传播
z.backward()

print(f"\ndz/dw = {w.grad}")
print(f"dz/dx = {x.grad}")
print(f"dz/db = {b.grad}")

# 手动梯度验证
z_val = z.item()
with torch.no_grad():
    s_prime = z_val * (1 - z_val)
    print(f"\n手动: dz/dw0 = σ' * x0 = {s_prime * 2.0:.6f}")
    print(f"自动: dz/dw0 = {w.grad[0]:.6f}")
```

### 3.2 梯度相关设置

```python
import torch

# requires_grad_() 原地设置
x = torch.randn(3)
print(f"初始 requires_grad: {x.requires_grad}")
x.requires_grad_(True)
print(f"设置后 requires_grad: {x.requires_grad}")

# detach() — 从计算图中分离
y = x ** 2
y_detached = y.detach()
print(f"\ny requires_grad: {y.requires_grad}")
print(f"y_detached requires_grad: {y_detached.requires_grad}")

# torch.no_grad() — 上下文管理器禁用梯度
with torch.no_grad():
    z = x ** 3
    print(f"\nno_grad 中: requires_grad = {z.requires_grad}")

# retain_graph — 保留计算图用于多次反向传播
x = torch.tensor(2.0, requires_grad=True)

y = x ** 3
y.backward(retain_graph=True)  # 保留图
print(f"\n第一次 backward: dy/dx = {x.grad}")  # 12

y.backward(retain_graph=True)  # 梯度累积!
print(f"第二次 backward: dy/dx = {x.grad}")  # 24 (累积了)

x.grad.zero_()  # 清零
y.backward()
print(f"清零后 backward: dy/dx = {x.grad}")  # 12
```

### 3.3 梯度钩子

```python
import torch
import torch.nn as nn

# 前向钩子
def forward_hook(module, input, output):
    print(f"[Forward] {module.__class__.__name__}: input={input[0].shape}, output={output.shape}")

# 反向钩子（监视梯度）
def backward_hook(module, grad_input, grad_output):
    for i, g in enumerate(grad_output):
        if g is not None:
            print(f"[Backward] {module.__class__.__name__} grad_output[{i}]: "
                  f"mean={g.mean():.6f}, std={g.std():.6f}")

model = nn.Sequential(
    nn.Linear(10, 20),
    nn.ReLU(),
    nn.Linear(20, 5),
)

# 注册钩子
for module in model:
    module.register_forward_hook(forward_hook)
    module.register_full_backward_hook(backward_hook)

# 测试
x = torch.randn(3, 10, requires_grad=True)
y = model(x)
loss = y.sum()
loss.backward()

# 梯度裁剪钩子
def grad_clip_hook(grad, max_norm=1.0):
    norm = grad.norm()
    if norm > max_norm:
        return grad * max_norm / (norm + 1e-6)
    return grad

x = torch.randn(10, requires_grad=True)
x.register_hook(lambda g: grad_clip_hook(g, max_norm=0.5))

y = (100 * x).sum()
y.backward()
print(f"\n梯度裁剪后范数: {x.grad.norm():.4f}")
```

---

## 4. nn.Module 模块化

### 4.1 创建自定义模块

```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class MLP(nn.Module):
    """多层感知机"""

    def __init__(self, input_dim, hidden_dims, output_dim, dropout=0.2):
        super().__init__()

        layers = []
        prev_dim = input_dim
        for hidden_dim in hidden_dims:
            layers.extend([
                nn.Linear(prev_dim, hidden_dim),
                nn.BatchNorm1d(hidden_dim),
                nn.ReLU(inplace=True),
                nn.Dropout(dropout),
            ])
            prev_dim = hidden_dim

        self.features = nn.Sequential(*layers)
        self.classifier = nn.Linear(prev_dim, output_dim)

        self._init_weights()

    def _init_weights(self):
        for m in self.modules():
            if isinstance(m, nn.Linear):
                nn.init.kaiming_normal_(m.weight, mode='fan_out', nonlinearity='relu')
                if m.bias is not None:
                    nn.init.constant_(m.bias, 0)
            elif isinstance(m, nn.BatchNorm1d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        x = self.features(x)
        x = self.classifier(x)
        return x


# 使用
model = MLP(input_dim=784, hidden_dims=[512, 256, 128], output_dim=10, dropout=0.3)
print(model)
print(f"\n总参数量: {sum(p.numel() for p in model.parameters()):,}")

# 测试前向传播
x = torch.randn(32, 784)
y = model(x)
print(f"输入: {x.shape}, 输出: {y.shape}")

# 遍历所有参数
for name, param in model.named_parameters():
    print(f"  {name}: {param.shape}, requires_grad={param.requires_grad}")
    break  # 只打印第一个
```

### 4.2 常用层

```python
import torch
import torch.nn as nn

# ===== 线性层 =====
linear = nn.Linear(in_features=10, out_features=5)
x = torch.randn(32, 10)
print(f"Linear: {linear(x).shape}")  # (32, 5)

# ===== 卷积层 =====
conv1d = nn.Conv1d(in_channels=3, out_channels=16, kernel_size=3, padding=1)
conv2d = nn.Conv2d(in_channels=3, out_channels=16, kernel_size=3, padding=1)

x_1d = torch.randn(8, 3, 100)
x_2d = torch.randn(8, 3, 32, 32)

print(f"Conv1d: {conv1d(x_1d).shape}")  # (8, 16, 100)
print(f"Conv2d: {conv2d(x_2d).shape}")  # (8, 16, 32, 32)

# ===== 池化层 =====
maxpool = nn.MaxPool2d(kernel_size=2, stride=2)
avgpool = nn.AdaptiveAvgPool2d(output_size=(1, 1))

print(f"MaxPool2d: {maxpool(x_2d).shape}")  # (8, 3, 16, 16)
print(f"AdaptiveAvgPool2d: {avgpool(x_2d).shape}")  # (8, 3, 1, 1)

# ===== 归一化层 =====
bn = nn.BatchNorm1d(num_features=10)
ln = nn.LayerNorm(normalized_shape=10)

x_norm = torch.randn(32, 10)
print(f"BatchNorm1d: {bn(x_norm).shape}")  # (32, 10)
print(f"LayerNorm: {ln(x_norm).shape}")    # (32, 10)

# ===== 激活函数 =====
activations = {
    'ReLU': nn.ReLU(),
    'LeakyReLU': nn.LeakyReLU(0.1),
    'GELU': nn.GELU(),
    'Sigmoid': nn.Sigmoid(),
    'Tanh': nn.Tanh(),
    'Softmax': nn.Softmax(dim=1),
    'SiLU': nn.SiLU(),  # Swish
}

for name, act in activations.items():
    print(f"{name}: {act(x).shape}")

# ===== Dropout =====
dropout = nn.Dropout(p=0.5)
print(f"\nDropout (训练模式): mean={dropout(x).mean():.4f}")
dropout.eval()  # 评估模式下关闭
print(f"Dropout (评估模式): mean={x.mean():.4f} (不变)")

# ===== Embedding =====
embedding = nn.Embedding(num_embeddings=1000, embedding_dim=64)
indices = torch.randint(0, 1000, (32, 50))  # (batch, seq_len)
print(f"\nEmbedding: {embedding(indices).shape}")  # (32, 50, 64)
```

### 4.3 参数管理

```python
import torch
import torch.nn as nn

class MyModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.linear1 = nn.Linear(10, 20)
        self.linear2 = nn.Linear(20, 5)
        self.register_buffer('running_mean', torch.zeros(10))  # 非参数缓冲区

    def forward(self, x):
        return self.linear2(F.relu(self.linear1(x)))

model = MyModel()

# 打印所有参数
print("模型参数:")
for name, param in model.named_parameters():
    print(f"  {name}: {param.shape}")

# 打印所有缓冲区
print("\n模型缓冲区:")
for name, buf in model.named_buffers():
    print(f"  {name}: {buf.shape}")

# 参数初始化
def init_weights(m):
    if isinstance(m, nn.Linear):
        nn.init.xavier_uniform_(m.weight)
        if m.bias is not None:
            nn.init.zeros_(m.bias)

model.apply(init_weights)

# 冻结/解冻参数
for param in model.linear1.parameters():
    param.requires_grad = False

trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
total_params = sum(p.numel() for p in model.parameters())
print(f"\n可训练参数: {trainable_params}, 总参数: {total_params}")

# 参数分组（不同学习率）
param_groups = [
    {'params': model.linear1.parameters(), 'lr': 0.001, 'name': 'linear1'},
    {'params': model.linear2.parameters(), 'lr': 0.01, 'name': 'linear2'},
]

optimizer = torch.optim.SGD(param_groups, lr=0.01)
for group in optimizer.param_groups:
    print(f"\n参数组 '{group['name']}': lr={group['lr']}")

# 保存和加载
torch.save(model.state_dict(), 'model_weights.pth')
model.load_state_dict(torch.load('model_weights.pth'))
print("\n模型权重已保存/加载")
```

---

## 5. Dataset 与 DataLoader

### 5.1 自定义 Dataset

```python
import torch
from torch.utils.data import Dataset, DataLoader
import numpy as np

class MyDataset(Dataset):
    """自定义数据集"""

    def __init__(self, n_samples=1000, n_features=20, transform=None):
        self.n_samples = n_samples
        self.transform = transform

        # 生成模拟数据
        np.random.seed(42)
        self.X = np.random.randn(n_samples, n_features).astype(np.float32)
        true_w = np.random.randn(n_features).astype(np.float32)
        self.y = (self.X @ true_w > 0).astype(np.int64)  # 二分类

    def __len__(self):
        return self.n_samples

    def __getitem__(self, idx):
        x = self.X[idx]
        y = self.y[idx]

        if self.transform:
            x = self.transform(x)

        return torch.from_numpy(x), torch.tensor(y)

# 使用
dataset = MyDataset(n_samples=2000, n_features=20)
print(f"数据集大小: {len(dataset)}")
print(f"第一个样本: x={dataset[0][0].shape}, y={dataset[0][1]}")

# DataLoader
dataloader = DataLoader(
    dataset,
    batch_size=32,
    shuffle=True,
    num_workers=0,   # Windows 上建议设为 0
    drop_last=False,  # 是否丢弃不足一个 batch 的数据
    pin_memory=True,  # GPU 训练时加速
)

# 迭代
for batch_idx, (x, y) in enumerate(dataloader):
    print(f"Batch {batch_idx}: x={x.shape}, y={y.shape}")
    if batch_idx >= 2:
        break
```

### 5.2 数据增强与变换

```python
import torch
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms

# 图像变换 pipeline
train_transform = transforms.Compose([
    transforms.ToPILImage(),
    transforms.RandomHorizontalFlip(p=0.5),
    transforms.RandomRotation(degrees=15),
    transforms.ColorJitter(brightness=0.2, contrast=0.2),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                         std=[0.229, 0.224, 0.225]),
])

test_transform = transforms.Compose([
    transforms.ToPILImage(),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                         std=[0.229, 0.224, 0.225]),
])

# 演示数据增强效果
import matplotlib.pyplot as plt
from PIL import Image

# 使用 torchvision 内置数据集
from torchvision.datasets import CIFAR10

try:
    train_dataset = CIFAR10(root='./data', train=True, download=True, transform=train_transform)
    print(f"CIFAR-10 训练集大小: {len(train_dataset)}")
    print(f"类别: {train_dataset.classes}")

    img, label = train_dataset[0]
    print(f"图片张量形状: {img.shape}, 标签: {train_dataset.classes[label]}")
except Exception as e:
    print(f"CIFAR-10 下载可能失败: {e}")
```

### 5.3 高级 DataLoader 技巧

```python
import torch
from torch.utils.data import DataLoader, random_split, ConcatDataset, Subset
import numpy as np

# 1. 数据集划分
dataset = MyDataset(n_samples=1000)
train_size = int(0.8 * len(dataset))
val_size = int(0.1 * len(dataset))
test_size = len(dataset) - train_size - val_size

train_set, val_set, test_set = random_split(
    dataset, [train_size, val_size, test_size],
    generator=torch.Generator().manual_seed(42)
)

print(f"训练集: {len(train_set)}, 验证集: {len(val_set)}, 测试集: {len(test_set)}")

# 2. collate_fn 自定义批处理
def custom_collate(batch):
    """自定义批处理函数"""
    xs = torch.stack([item[0] for item in batch])
    ys = torch.tensor([item[1] for item in batch])
    return {'features': xs, 'labels': ys}

loader = DataLoader(dataset, batch_size=16, collate_fn=custom_collate)
batch = next(iter(loader))
print(f"\n自定义 collate: keys={batch.keys()}, features={batch['features'].shape}")

# 3. 采样器
from torch.utils.data import WeightedRandomSampler

# 处理类别不平衡
labels = np.array([dataset[i][1].item() for i in range(len(dataset))])
class_counts = np.bincount(labels)
class_weights = 1.0 / class_counts
sample_weights = class_weights[labels]

sampler = WeightedRandomSampler(
    weights=sample_weights,
    num_samples=len(dataset),
    replacement=True,
)

balanced_loader = DataLoader(dataset, batch_size=32, sampler=sampler)

# 检查平衡效果
batch_labels = []
for x, y in balanced_loader:
    batch_labels.extend(y.tolist())
    if len(batch_labels) >= 1000:
        break
print(f"\n平衡采样后的标签分布: {np.bincount(batch_labels[:1000])}")

# 4. IterableDataset (流式数据)
class MyIterableDataset(torch.utils.data.IterableDataset):
    def __init__(self, n_samples=10000):
        self.n_samples = n_samples

    def __iter__(self):
        for i in range(self.n_samples):
            x = torch.randn(10)
            y = (x.sum() > 0).long()
            yield x, y

iterable_dataset = MyIterableDataset()
iterable_loader = DataLoader(iterable_dataset, batch_size=32)
print(f"\nIterableDataset batch: {next(iter(iterable_loader))[0].shape}")
```

---

## 6. 训练循环模板

### 6.1 标准训练模板

```python
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, random_split
from torch.optim.lr_scheduler import CosineAnnealingLR
import numpy as np
import time
from collections import defaultdict

class Trainer:
    """通用训练器"""

    def __init__(self, model, device, config=None):
        self.model = model.to(device)
        self.device = device
        self.config = config or {}

        # 默认配置
        self.epochs = self.config.get('epochs', 50)
        self.patience = self.config.get('patience', 10)

        # 优化器
        self.optimizer = optim.AdamW(
            model.parameters(),
            lr=self.config.get('lr', 1e-3),
            weight_decay=self.config.get('weight_decay', 1e-4),
        )

        # 学习率调度器
        self.scheduler = CosineAnnealingLR(
            self.optimizer,
            T_max=self.epochs,
            eta_min=self.config.get('min_lr', 1e-6),
        )

        # 损失函数
        self.criterion = nn.CrossEntropyLoss(
            label_smoothing=self.config.get('label_smoothing', 0.0)
        )

        # 记录
        self.history = defaultdict(list)
        self.best_val_loss = float('inf')
        self.best_val_acc = 0.0
        self.epochs_no_improve = 0

        # 混合精度训练
        self.use_amp = self.config.get('use_amp', False)
        self.scaler = torch.amp.GradScaler('cuda') if self.use_amp and device.type == 'cuda' else None

    def train_epoch(self, train_loader):
        self.model.train()
        total_loss = 0
        correct = 0
        total = 0

        for batch_idx, (x, y) in enumerate(train_loader):
            x, y = x.to(self.device), y.to(self.device)

            self.optimizer.zero_grad()

            if self.use_amp and self.scaler:
                with torch.amp.autocast('cuda'):
                    logits = self.model(x)
                    loss = self.criterion(logits, y)
                self.scaler.scale(loss).backward()
                self.scaler.unscale_(self.optimizer)
                torch.nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
                self.scaler.step(self.optimizer)
                self.scaler.update()
            else:
                logits = self.model(x)
                loss = self.criterion(logits, y)
                loss.backward()
                torch.nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
                self.optimizer.step()

            total_loss += loss.item() * x.size(0)
            pred = logits.argmax(dim=1)
            correct += (pred == y).sum().item()
            total += x.size(0)

        return total_loss / total, correct / total

    @torch.no_grad()
    def evaluate(self, data_loader):
        self.model.eval()
        total_loss = 0
        correct = 0
        total = 0

        for x, y in data_loader:
            x, y = x.to(self.device), y.to(self.device)
            logits = self.model(x)
            loss = self.criterion(logits, y)

            total_loss += loss.item() * x.size(0)
            pred = logits.argmax(dim=1)
            correct += (pred == y).sum().item()
            total += x.size(0)

        return total_loss / total, correct / total

    def fit(self, train_loader, val_loader):
        print(f"\n{'='*60}")
        print(f"开始训练 — {self.epochs} epochs, device={self.device}")
        print(f"{'='*60}")

        for epoch in range(self.epochs):
            start_time = time.time()

            train_loss, train_acc = self.train_epoch(train_loader)
            val_loss, val_acc = self.evaluate(val_loader)

            self.scheduler.step()
            current_lr = self.optimizer.param_groups[0]['lr']

            # 记录
            self.history['train_loss'].append(train_loss)
            self.history['train_acc'].append(train_acc)
            self.history['val_loss'].append(val_loss)
            self.history['val_acc'].append(val_acc)
            self.history['lr'].append(current_lr)

            # 打印
            elapsed = time.time() - start_time
            print(f"Epoch {epoch+1:3d}/{self.epochs} | "
                  f"Train Loss: {train_loss:.4f} Acc: {train_acc:.4f} | "
                  f"Val Loss: {val_loss:.4f} Acc: {val_acc:.4f} | "
                  f"LR: {current_lr:.2e} | Time: {elapsed:.1f}s")

            # 早停
            if val_loss < self.best_val_loss:
                self.best_val_loss = val_loss
                self.best_val_acc = val_acc
                self.epochs_no_improve = 0
                self.best_model_state = {
                    k: v.cpu().clone() for k, v in self.model.state_dict().items()
                }
            else:
                self.epochs_no_improve += 1

            if self.epochs_no_improve >= self.patience:
                print(f"\n早停! 验证损失在 {self.patience} 个 epoch 内未改善")
                break

        # 恢复最佳模型
        if hasattr(self, 'best_model_state'):
            self.model.load_state_dict(self.best_model_state)

        print(f"\n训练完成! 最佳验证 Loss: {self.best_val_loss:.4f}, Acc: {self.best_val_acc:.4f}")

    def predict(self, data_loader):
        """返回预测结果"""
        self.model.eval()
        all_preds = []
        all_probs = []

        with torch.no_grad():
            for x, _ in data_loader:
                x = x.to(self.device)
                logits = self.model(x)
                probs = torch.softmax(logits, dim=1)
                preds = logits.argmax(dim=1)
                all_preds.append(preds.cpu())
                all_probs.append(probs.cpu())

        return torch.cat(all_preds), torch.cat(all_probs)
```

### 6.2 训练循环的完整流程

```python
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, random_split
from torch.optim.lr_scheduler import ReduceLROnPlateau
import matplotlib.pyplot as plt

# 准备数据
dataset = MyDataset(n_samples=5000, n_features=50)

train_size = int(0.7 * len(dataset))
val_size = int(0.15 * len(dataset))
test_size = len(dataset) - train_size - val_size

train_set, val_set, test_set = random_split(dataset, [train_size, val_size, test_size])

train_loader = DataLoader(train_set, batch_size=64, shuffle=True)
val_loader = DataLoader(val_set, batch_size=128, shuffle=False)
test_loader = DataLoader(test_set, batch_size=128, shuffle=False)

# 模型
model = MLP(input_dim=50, hidden_dims=[128, 64], output_dim=2, dropout=0.3)
device = get_device()

# 训练
trainer = Trainer(model, device, config={
    'epochs': 30,
    'lr': 1e-3,
    'weight_decay': 1e-4,
    'patience': 8,
    'label_smoothing': 0.0,
    'use_amp': False,
})

trainer.fit(train_loader, val_loader)

# 测试
test_loss, test_acc = trainer.evaluate(test_loader)
print(f"\n测试集: Loss={test_loss:.4f}, Acc={test_acc:.4f}")

# 绘制训练曲线
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

axes[0].plot(trainer.history['train_loss'], label='Train')
axes[0].plot(trainer.history['val_loss'], label='Val')
axes[0].set_xlabel('Epoch')
axes[0].set_ylabel('Loss')
axes[0].set_title('损失曲线')
axes[0].legend()
axes[0].grid(True, alpha=0.3)

axes[1].plot(trainer.history['train_acc'], label='Train')
axes[1].plot(trainer.history['val_acc'], label='Val')
axes[1].set_xlabel('Epoch')
axes[1].set_ylabel('Accuracy')
axes[1].set_title('准确率曲线')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('training_curves.png', dpi=100)
plt.show()
```

---

## 7. MNIST 完整示例

```python
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
import matplotlib.pyplot as plt
import numpy as np
from sklearn.metrics import classification_report, confusion_matrix
import seaborn as sns

# ==================== 1. 数据准备 ====================

transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.1307,), (0.3081,)),
])

train_dataset = datasets.MNIST(
    root='./data', train=True, download=True, transform=transform
)
test_dataset = datasets.MNIST(
    root='./data', train=False, download=True, transform=transform
)

train_loader = DataLoader(train_dataset, batch_size=128, shuffle=True, pin_memory=True)
test_loader = DataLoader(test_dataset, batch_size=256, shuffle=False, pin_memory=True)

print(f"训练集: {len(train_dataset)} 张图片")
print(f"测试集: {len(test_dataset)} 张图片")
print(f"图像形状: {train_dataset[0][0].shape}")

# ==================== 2. 模型定义 ====================

class MNISTModel(nn.Module):
    """适用于 MNIST 的小型卷积网络"""

    def __init__(self, num_classes=10):
        super().__init__()

        self.conv_block = nn.Sequential(
            nn.Conv2d(1, 32, kernel_size=3, padding=1),
            nn.BatchNorm2d(32),
            nn.ReLU(inplace=True),
            nn.Conv2d(32, 32, kernel_size=3, padding=1),
            nn.BatchNorm2d(32),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2),
            nn.Dropout2d(0.25),

            nn.Conv2d(32, 64, kernel_size=3, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(inplace=True),
            nn.Conv2d(64, 64, kernel_size=3, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2),
            nn.Dropout2d(0.25),
        )

        self.fc_block = nn.Sequential(
            nn.Flatten(),
            nn.Linear(64 * 7 * 7, 256),
            nn.BatchNorm1d(256),
            nn.ReLU(inplace=True),
            nn.Dropout(0.5),
            nn.Linear(256, 128),
            nn.BatchNorm1d(128),
            nn.ReLU(inplace=True),
            nn.Dropout(0.5),
            nn.Linear(128, num_classes),
        )

        self._init_weights()

    def _init_weights(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode='fan_out', nonlinearity='relu')
            elif isinstance(m, nn.Linear):
                nn.init.kaiming_normal_(m.weight, mode='fan_out', nonlinearity='relu')
                if m.bias is not None:
                    nn.init.constant_(m.bias, 0)
            elif isinstance(m, nn.BatchNorm2d) or isinstance(m, nn.BatchNorm1d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        x = self.conv_block(x)
        x = self.fc_block(x)
        return x


# ==================== 3. 训练配置 ====================

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = MNISTModel(num_classes=10).to(device)

criterion = nn.CrossEntropyLoss()
optimizer = optim.AdamW(model.parameters(), lr=1e-3, weight_decay=1e-4)
scheduler = optim.lr_scheduler.ReduceLROnPlateau(
    optimizer, mode='min', factor=0.5, patience=3, min_lr=1e-6
)

print(f"\n模型参数量: {sum(p.numel() for p in model.parameters()):,}")
print(f"设备: {device}")

# ==================== 4. 训练 ====================

def train_epoch(model, loader, criterion, optimizer, device):
    model.train()
    total_loss = 0
    correct = 0

    for x, y in loader:
        x, y = x.to(device), y.to(device)

        optimizer.zero_grad()
        logits = model(x)
        loss = criterion(logits, y)
        loss.backward()
        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
        optimizer.step()

        total_loss += loss.item() * x.size(0)
        correct += (logits.argmax(dim=1) == y).sum().item()

    return total_loss / len(loader.dataset), correct / len(loader.dataset)

@torch.no_grad()
def evaluate(model, loader, criterion, device):
    model.eval()
    total_loss = 0
    correct = 0
    all_preds = []
    all_labels = []

    for x, y in loader:
        x, y = x.to(device), y.to(device)
        logits = model(x)
        loss = criterion(logits, y)

        total_loss += loss.item() * x.size(0)
        preds = logits.argmax(dim=1)
        correct += (preds == y).sum().item()

        all_preds.extend(preds.cpu().tolist())
        all_labels.extend(y.cpu().tolist())

    return total_loss / len(loader.dataset), correct / len(loader.dataset), all_preds, all_labels

# 训练循环
n_epochs = 15
history = {'train_loss': [], 'train_acc': [], 'val_loss': [], 'val_acc': []}

for epoch in range(n_epochs):
    train_loss, train_acc = train_epoch(model, train_loader, criterion, optimizer, device)
    val_loss, val_acc, val_preds, val_labels = evaluate(
        model, test_loader, criterion, device
    )

    scheduler.step(val_loss)

    history['train_loss'].append(train_loss)
    history['train_acc'].append(train_acc)
    history['val_loss'].append(val_loss)
    history['val_acc'].append(val_acc)

    print(f"Epoch {epoch+1:2d}/{n_epochs} | "
          f"Train Loss: {train_loss:.4f} Acc: {train_acc:.4f} | "
          f"Test Loss: {val_loss:.4f} Acc: {val_acc:.4f} | "
          f"LR: {optimizer.param_groups[0]['lr']:.2e}")

# ==================== 5. 评估与可视化 ====================

_, final_acc, final_preds, final_labels = evaluate(
    model, test_loader, criterion, device
)

print(f"\n{'='*50}")
print(f"最终测试准确率: {final_acc:.4f}")
print(f"{'='*50}")

# 分类报告
print("\n分类报告:")
print(classification_report(final_labels, final_preds, digits=4))

# 混淆矩阵
cm = confusion_matrix(final_labels, final_preds)

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# 混淆矩阵
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=axes[0, 0])
axes[0, 0].set_xlabel('预测标签')
axes[0, 0].set_ylabel('真实标签')
axes[0, 0].set_title('混淆矩阵')

# 训练曲线
axes[0, 1].plot(history['train_loss'], label='Train')
axes[0, 1].plot(history['val_loss'], label='Test')
axes[0, 1].set_xlabel('Epoch')
axes[0, 1].set_ylabel('Loss')
axes[0, 1].set_title('损失曲线')
axes[0, 1].legend()
axes[0, 1].grid(True, alpha=0.3)

axes[1, 0].plot(history['train_acc'], label='Train')
axes[1, 0].plot(history['val_acc'], label='Test')
axes[1, 0].set_xlabel('Epoch')
axes[1, 0].set_ylabel('Accuracy')
axes[1, 0].set_title('准确率曲线')
axes[1, 0].legend()
axes[1, 0].grid(True, alpha=0.3)

# 预测样本可视化
model.eval()
sample_images = []
sample_preds = []
sample_trues = []

test_iter = iter(test_loader)
x_batch, y_batch = next(test_iter)

with torch.no_grad():
    x_batch = x_batch.to(device)
    logits = model(x_batch)
    preds = logits.argmax(dim=1).cpu()

for i in range(8):
    sample_images.append(x_batch[i].cpu().squeeze())
    sample_preds.append(preds[i].item())
    sample_trues.append(y_batch[i].item())

for i in range(8):
    ax = axes[1, 1].inset_axes([(i % 4) * 0.25, 0.5 - (i // 4) * 0.5, 0.22, 0.4])
    ax.imshow(sample_images[i], cmap='gray')
    color = 'green' if sample_preds[i] == sample_trues[i] else 'red'
    ax.set_title(f'Pred: {sample_preds[i]}\nTrue: {sample_trues[i]}', color=color, fontsize=9)
    ax.axis('off')

axes[1, 1].set_title('预测样本 (绿色=正确, 红色=错误)')
axes[1, 1].axis('off')

plt.tight_layout()
plt.savefig('mnist_results.png', dpi=100)
plt.show()

# ==================== 6. 错误分析 ====================

errors_idx = np.where(np.array(final_preds) != np.array(final_labels))[0]
print(f"\n错误预测样本数: {len(errors_idx)} / {len(final_labels)}")

# 找出每个类别最常见的误分类
error_pairs = {}
for idx in errors_idx:
    true_label = final_labels[idx]
    pred_label = final_preds[idx]
    pair = (true_label, pred_label)
    error_pairs[pair] = error_pairs.get(pair, 0) + 1

top_errors = sorted(error_pairs.items(), key=lambda x: x[1], reverse=True)[:10]
print("\n最常见的误分类:")
for (true, pred), count in top_errors:
    print(f"  {true} → {pred}: {count} 次")
```

---

## 8. 常用技巧汇集

### 8.1 Fine-tuning 预训练模型

```python
import torch
import torch.nn as nn
from torchvision import models

def create_finetune_model(num_classes, backbone='resnet18', freeze_backbone=True):
    """创建微调模型"""

    if backbone == 'resnet18':
        model = models.resnet18(weights=models.ResNet18_Weights.DEFAULT)
        in_features = model.fc.in_features

        if freeze_backbone:
            for param in model.parameters():
                param.requires_grad = False

        model.fc = nn.Sequential(
            nn.Dropout(0.3),
            nn.Linear(in_features, 256),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(256, num_classes),
        )
    else:
        raise ValueError(f"不支持的 backbone: {backbone}")

    return model

# 使用
model_ft = create_finetune_model(num_classes=10, backbone='resnet18', freeze_backbone=True)

trainable = sum(p.numel() for p in model_ft.parameters() if p.requires_grad)
total = sum(p.numel() for p in model_ft.parameters())
print(f"可训练参数: {trainable:,} / {total:,}")
```

### 8.2 模型部署 — 导出与推理

```python
import torch

# 1. 保存完整模型
torch.save(model.state_dict(), 'mnist_model.pth')

# 2. TorchScript 导出
model.eval()
example_input = torch.randn(1, 1, 28, 28).to(device)

# 方式 A: Trace
traced_model = torch.jit.trace(model, example_input)
traced_model.save('mnist_traced.pt')

# 方式 B: Script (更通用)
scripted_model = torch.jit.script(model)
scripted_model.save('mnist_scripted.pt')

# 3. ONNX 导出
torch.onnx.export(
    model.cpu(),
    example_input.cpu(),
    'mnist.onnx',
    input_names=['input'],
    output_names=['output'],
    dynamic_axes={'input': {0: 'batch'}, 'output': {0: 'batch'}},
    opset_version=14,
)
print("模型已导出为 ONNX 格式: mnist.onnx")

# 4. 推理优化 (量化)
quantized_model = torch.quantization.quantize_dynamic(
    model.cpu(),
    {nn.Linear, nn.Conv2d},
    dtype=torch.qint8,
)
print(f"量化模型已创建")

# 5. 推理
def inference_demo(model, image_tensor):
    model.eval()
    with torch.no_grad():
        logits = model(image_tensor.unsqueeze(0))
        probs = torch.softmax(logits, dim=1)
        pred = probs.argmax(dim=1).item()
        confidence = probs[0, pred].item()
    return pred, confidence

sample_img, sample_label = test_dataset[0]
pred, conf = inference_demo(model.cpu(), sample_img)
print(f"\n推理示例: 真实标签={sample_label}, 预测={pred}, 置信度={conf:.4f}")
```

### 8.3 多 GPU 训练

```python
import torch
import torch.nn as nn

# DataParallel (简单但不推荐)
if torch.cuda.device_count() > 1:
    model = nn.DataParallel(model)
    print(f"使用 {torch.cuda.device_count()} 个 GPU (DataParallel)")

# DistributedDataParallel (推荐)
"""
使用方式 (命令行):
python -m torch.distributed.launch --nproc_per_node=4 train.py

代码示例:
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel as DDP

def setup(rank, world_size):
    dist.init_process_group("nccl", rank=rank, world_size=world_size)

def cleanup():
    dist.destroy_process_group()

# 在 main 中:
model = DDP(model, device_ids=[local_rank])
"""
```

---

## 相关笔记

- [[../../数理基础/代数/Linear algebra|线性代数]]
- [[../../数理基础/数学分析|数学分析]]
- [[../../数理基础/向量微积分|向量微积分]]
- [[../机器学习与深度学习/0.绪论|深度学习绪论]]
- [[../RL-PPO理论|PPO理论]]
- [[LaTeX/main.tex|LaTeX 完整教程]]
