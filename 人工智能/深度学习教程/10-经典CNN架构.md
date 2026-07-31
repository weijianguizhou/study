# 经典CNN架构

## 1. CNN架构演进总览

```
LeNet-5 (1998) → AlexNet (2012) → VGG (2014) → GoogLeNet/Inception (2014)
    → ResNet (2015) → DenseNet (2017) → MobileNet (2017) → EfficientNet (2019)
```

每个里程碑都解决了一个核心问题：
- AlexNet：证明深度CNN在ImageNet上可行
- VGG：统一使用小卷积核(3×3)，通过深度提升性能
- GoogLeNet：多尺度特征融合，计算效率
- ResNet：残差学习解决深度退化问题
- DenseNet：极致特征复用
- MobileNet：移动端部署的高效架构

## 2. LeNet-5 (1998)

### 2.1 架构

LeNet-5由Yann LeCun设计，用于手写数字识别(MNIST)：

```
Input(32×32) → Conv(5×5, 6) → AvgPool(2×2) → Conv(5×5, 16) → AvgPool(2×2)
    → FC(120) → FC(84) → FC(10)
```

### 2.2 关键设计

- **卷积-池化交替**：逐步提取特征并减小空间维度
- **子采样（Subsampling）**：LeNet使用平均池化，并对结果做缩放和偏置
- **Sigmoid/Tanh激活**：当时的主流（现在被ReLU替代）
- **Gaussian Connection**：输出层使用RBF而非Softmax

### 2.3 历史意义

LeNet-5首次将反向传播用于卷积网络的端到端训练，证明CNN可以自动学习层次化的视觉特征。

```python
# LeNet-5 PyTorch实现
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
import matplotlib.pyplot as plt
import numpy as np

class LeNet5(nn.Module):
    """经典LeNet-5架构 (适配现代MNIST: 28×28输入)"""

    def __init__(self, num_classes=10):
        super(LeNet5, self).__init__()

        # C1: 卷积层 1×28×28 → 6×28×28 (padding=2保持尺寸)
        self.conv1 = nn.Conv2d(1, 6, kernel_size=5, padding=2)
        # S2: 池化层 6×28×28 → 6×14×14
        self.pool1 = nn.AvgPool2d(kernel_size=2, stride=2)

        # C3: 卷积层 6×14×14 → 16×10×10
        self.conv2 = nn.Conv2d(6, 16, kernel_size=5)
        # S4: 池化层 16×10×10 → 16×5×5
        self.pool2 = nn.AvgPool2d(kernel_size=2, stride=2)

        # C5: 卷积层 (等价于全连接) 16×5×5 → 120
        self.conv3 = nn.Conv2d(16, 120, kernel_size=5)

        # F6: 全连接层
        self.fc1 = nn.Linear(120, 84)

        # 输出层
        self.fc2 = nn.Linear(84, num_classes)

    def forward(self, x):
        x = self.pool1(torch.tanh(self.conv1(x)))
        x = self.pool2(torch.tanh(self.conv2(x)))
        x = torch.tanh(self.conv3(x))
        x = x.view(x.size(0), -1)
        x = torch.tanh(self.fc1(x))
        x = self.fc2(x)
        return x


# 训练LeNet-5
def train_lenet():
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

    # 数据预处理
    transform = transforms.Compose([
        transforms.Resize(32),  # LeNet需要32×32输入
        transforms.ToTensor(),
        transforms.Normalize((0.1307,), (0.3081,))
    ])

    train_dataset = datasets.MNIST('./data', train=True, download=True,
                                    transform=transform)
    test_dataset = datasets.MNIST('./data', train=False, transform=transform)

    train_loader = DataLoader(train_dataset, batch_size=128, shuffle=True)
    test_loader = DataLoader(test_dataset, batch_size=128, shuffle=False)

    model = LeNet5().to(device)
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    criterion = nn.CrossEntropyLoss()

    train_accs, test_accs = [], []

    for epoch in range(10):
        model.train()
        correct, total = 0, 0
        for data, target in train_loader:
            data, target = data.to(device), target.to(device)
            optimizer.zero_grad()
            output = model(data)
            loss = criterion(output, target)
            loss.backward()
            optimizer.step()
            pred = output.argmax(dim=1)
            correct += pred.eq(target).sum().item()
            total += target.size(0)
        train_accs.append(100. * correct / total)

        model.eval()
        correct, total = 0, 0
        with torch.no_grad():
            for data, target in test_loader:
                data, target = data.to(device), target.to(device)
                output = model(data)
                pred = output.argmax(dim=1)
                correct += pred.eq(target).sum().item()
                total += target.size(0)
        test_accs.append(100. * correct / total)
        print(f'Epoch {epoch+1:2d}: Train Acc {train_accs[-1]:.2f}%, '
              f'Test Acc {test_accs[-1]:.2f}%')

    # 可视化
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(train_accs, 'b-o', label='训练')
    ax.plot(test_accs, 'r-s', label='测试')
    ax.set_xlabel('Epoch')
    ax.set_ylabel('Accuracy (%)')
    ax.set_title('LeNet-5 on MNIST')
    ax.legend()
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.show()

    print(f'\n参数量: {sum(p.numel() for p in model.parameters()):,}')

train_lenet()
```

## 3. AlexNet (2012)

### 3.1 历史地位

AlexNet在2012年ImageNet竞赛中以15.3%的Top-5错误率夺冠（第二名26.2%），标志着深度学习的复兴。关键创新：

| 创新 | 描述 |
|------|------|
| ReLU激活 | 替代Sigmoid，加速训练6倍 |
| GPU并行 | 双GPU训练，突破显存限制 |
| 局部响应归一化(LRN) | 侧抑制机制（后已被BN取代） |
| 重叠池化 | stride < kernel_size，提升精度 |
| Dropout | 首次大规模使用，对抗过拟合 |
| 数据增强 | 随机裁剪、水平翻转、PCA颜色增强 |

### 3.2 架构

输入224×224×3，5个卷积层 + 3个全连接层：

```
Conv1(11×11, s=4, 96) → MaxPool(3×3, s=2) → LRN
Conv2(5×5, 256) → MaxPool(3×3, s=2) → LRN
Conv3(3×3, 384) → Conv4(3×3, 384) → Conv5(3×3, 256)
MaxPool(3×3, s=2)
FC(4096) → Dropout → FC(4096) → Dropout → FC(1000)
```

```python
# AlexNet PyTorch实现
import torch
import torch.nn as nn

class AlexNet(nn.Module):
    """AlexNet for ImageNet (1000类)"""

    def __init__(self, num_classes=1000):
        super(AlexNet, self).__init__()

        self.features = nn.Sequential(
            # Conv1: 227×227×3 → 55×55×96
            nn.Conv2d(3, 96, kernel_size=11, stride=4, padding=2),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(kernel_size=3, stride=2),
            nn.LocalResponseNorm(5, alpha=0.0001, beta=0.75, k=2),

            # Conv2: 27×27×96 → 27×27×256
            nn.Conv2d(96, 256, kernel_size=5, padding=2),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(kernel_size=3, stride=2),
            nn.LocalResponseNorm(5, alpha=0.0001, beta=0.75, k=2),

            # Conv3
            nn.Conv2d(256, 384, kernel_size=3, padding=1),
            nn.ReLU(inplace=True),

            # Conv4
            nn.Conv2d(384, 384, kernel_size=3, padding=1),
            nn.ReLU(inplace=True),

            # Conv5
            nn.Conv2d(384, 256, kernel_size=3, padding=1),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(kernel_size=3, stride=2),
        )

        self.classifier = nn.Sequential(
            nn.Dropout(p=0.5),
            nn.Linear(256 * 6 * 6, 4096),
            nn.ReLU(inplace=True),
            nn.Dropout(p=0.5),
            nn.Linear(4096, 4096),
            nn.ReLU(inplace=True),
            nn.Linear(4096, num_classes),
        )

        self._init_weights()

    def _init_weights(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.normal_(m.weight, mean=0, std=0.01)
                if m.bias is not None:
                    nn.init.constant_(m.bias, 0)
            elif isinstance(m, nn.Linear):
                nn.init.normal_(m.weight, mean=0, std=0.01)
                nn.init.constant_(m.bias, 1)

    def forward(self, x):
        x = self.features(x)
        x = x.view(x.size(0), -1)
        x = self.classifier(x)
        return x


# 测试前向传播
model = AlexNet(num_classes=1000)
x = torch.randn(2, 3, 227, 227)
y = model(x)
print(f"输入: {x.shape} → 输出: {y.shape}")
print(f"参数量: {sum(p.numel() for p in model.parameters()):,}")

# 各组件参数量分布
for name, param in model.named_parameters():
    print(f"  {name}: {param.shape} ({param.numel():,})")
```

## 4. VGG (2014)

### 4.1 核心思想

VGG的哲学：**更深的网络 + 全用3×3小卷积核 + 2×2最大池化**。

两个3×3卷积堆叠的感受野等于5×5，三个等于7×7，但参数更少且非线性更强：

- 1个5×5卷积：$5 \times 5 \times C \times C = 25C^2$ 参数
- 2个3×3卷积：$2 \times (3 \times 3 \times C \times C) = 18C^2$ 参数 ($-28\%$)

### 4.2 VGG16 / VGG19

```
VGG16: 2×[Conv64] → Pool → 2×[Conv128] → Pool → 3×[Conv256] → Pool
       → 3×[Conv512] → Pool → 3×[Conv512] → Pool → FC4096 → FC4096 → FC1000
```

VGG19与VGG16结构相同，但最后三个stage有4个卷积层而非3个。

```python
# VGG PyTorch实现
import torch
import torch.nn as nn

class VGG(nn.Module):
    """VGG网络 (支持VGG11/13/16/19)"""

    cfgs = {
        'VGG11': [64, 'M', 128, 'M', 256, 256, 'M', 512, 512, 'M', 512, 512, 'M'],
        'VGG13': [64, 64, 'M', 128, 128, 'M', 256, 256, 'M', 512, 512, 'M', 512, 512, 'M'],
        'VGG16': [64, 64, 'M', 128, 128, 'M', 256, 256, 256, 'M', 512, 512, 512, 'M', 512, 512, 512, 'M'],
        'VGG19': [64, 64, 'M', 128, 128, 'M', 256, 256, 256, 256, 'M', 512, 512, 512, 512, 'M', 512, 512, 512, 512, 'M'],
    }

    def __init__(self, vgg_name, num_classes=1000, use_bn=False):
        super(VGG, self).__init__()
        self.features = self._make_layers(self.cfgs[vgg_name], use_bn)
        self.avgpool = nn.AdaptiveAvgPool2d((7, 7))
        self.classifier = nn.Sequential(
            nn.Linear(512 * 7 * 7, 4096),
            nn.ReLU(inplace=True),
            nn.Dropout(0.5),
            nn.Linear(4096, 4096),
            nn.ReLU(inplace=True),
            nn.Dropout(0.5),
            nn.Linear(4096, num_classes),
        )
        self._init_weights()

    def _make_layers(self, cfg, use_bn):
        layers = []
        in_channels = 3
        for v in cfg:
            if v == 'M':
                layers.append(nn.MaxPool2d(kernel_size=2, stride=2))
            else:
                layers.append(nn.Conv2d(in_channels, v, kernel_size=3, padding=1))
                if use_bn:
                    layers.append(nn.BatchNorm2d(v))
                layers.append(nn.ReLU(inplace=True))
                in_channels = v
        return nn.Sequential(*layers)

    def _init_weights(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode='fan_out')
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)
            elif isinstance(m, nn.Linear):
                nn.init.normal_(m.weight, 0, 0.01)
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        x = self.features(x)
        x = self.avgpool(x)
        x = x.view(x.size(0), -1)
        x = self.classifier(x)
        return x


# 测试不同VGG变体
for name in ['VGG11', 'VGG13', 'VGG16', 'VGG19']:
    model = VGG(name, num_classes=10, use_bn=True)
    params = sum(p.numel() for p in model.parameters())
    print(f"{name}: {params:,} 参数")

# VGG特点总结
print("\nVGG设计哲学:")
print("1. 统一使用3×3卷积核（感受野等价于更大的核，但参数更少）")
print("2. 卷积核数量逐Stage翻倍 (64→128→256→512→512)")
print("3. 通过Pooling逐步降低空间分辨率（每次减半）")
print("4. 极深的网络深度 (16/19层)")
print("5. 缺点：三个FC层的参数占总量约90% (>100M)")
```

## 5. GoogLeNet / Inception (2014)

### 5.1 核心思想

Inception模块并行使用不同尺度的卷积核(1×1, 3×3, 5×5)和池化，捕获多尺度特征。配合1×1卷积做**降维（Bottleneck）**以控制计算量。

### 5.2 Inception v1 模块

```
                  ┌──→ 1×1 Conv ──→ 输出
输入 ──┬──→ 1×1 Conv ──→ 3×3 Conv ──→ 输出
       ├──→ 1×1 Conv ──→ 5×5 Conv ──→ 输出
       ├──→ 3×3 MaxPool ──→ 1×1 Conv ──→ 输出
       拼接 (Concatenation)
```

### 5.3 Inception v2/v3 改进

- **卷积核分解**：5×5 → 两个3×3；3×3 → 1×3 + 3×1
- **Batch Normalization**：引入BN
- **Label Smoothing**：标签平滑正则化
- **辅助分类器**：中间层输出辅助损失

```python
# Inception模块实现
import torch
import torch.nn as nn
import torch.nn.functional as F

class InceptionModule(nn.Module):
    """Inception v1模块"""

    def __init__(self, in_channels, out_1x1, reduce_3x3, out_3x3,
                 reduce_5x5, out_5x5, out_pool):
        super(InceptionModule, self).__init__()

        # Branch 1: 1×1 Conv
        self.branch1 = nn.Sequential(
            nn.Conv2d(in_channels, out_1x1, kernel_size=1),
            nn.BatchNorm2d(out_1x1),
            nn.ReLU(inplace=True)
        )

        # Branch 2: 1×1 reduce → 3×3 Conv
        self.branch2 = nn.Sequential(
            nn.Conv2d(in_channels, reduce_3x3, kernel_size=1),
            nn.BatchNorm2d(reduce_3x3),
            nn.ReLU(inplace=True),
            nn.Conv2d(reduce_3x3, out_3x3, kernel_size=3, padding=1),
            nn.BatchNorm2d(out_3x3),
            nn.ReLU(inplace=True)
        )

        # Branch 3: 1×1 reduce → 5×5 Conv
        self.branch3 = nn.Sequential(
            nn.Conv2d(in_channels, reduce_5x5, kernel_size=1),
            nn.BatchNorm2d(reduce_5x5),
            nn.ReLU(inplace=True),
            nn.Conv2d(reduce_5x5, out_5x5, kernel_size=5, padding=2),
            nn.BatchNorm2d(out_5x5),
            nn.ReLU(inplace=True)
        )

        # Branch 4: 3×3 MaxPool → 1×1 Conv
        self.branch4 = nn.Sequential(
            nn.MaxPool2d(kernel_size=3, stride=1, padding=1),
            nn.Conv2d(in_channels, out_pool, kernel_size=1),
            nn.BatchNorm2d(out_pool),
            nn.ReLU(inplace=True)
        )

    def forward(self, x):
        b1 = self.branch1(x)
        b2 = self.branch2(x)
        b3 = self.branch3(x)
        b4 = self.branch4(x)
        return torch.cat([b1, b2, b3, b4], dim=1)


# 简化版GoogLeNet
class MiniGoogLeNet(nn.Module):
    """用于CIFAR-10的简化GoogLeNet"""

    def __init__(self, num_classes=10):
        super(MiniGoogLeNet, self).__init__()

        self.pre_conv = nn.Sequential(
            nn.Conv2d(3, 64, kernel_size=3, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(inplace=True)
        )

        # Inception模块序列
        self.inception1 = InceptionModule(64, 32, 48, 64, 8, 16, 16)  # out: 128
        self.inception2 = InceptionModule(128, 64, 64, 128, 16, 32, 32)  # out: 256

        self.maxpool = nn.MaxPool2d(2, 2)

        self.inception3 = InceptionModule(256, 128, 96, 192, 16, 48, 48)  # out: 416
        self.inception4 = InceptionModule(416, 128, 128, 256, 24, 64, 64)  # out: 512

        self.avgpool = nn.AdaptiveAvgPool2d(1)
        self.fc = nn.Linear(512, num_classes)

    def forward(self, x):
        x = self.pre_conv(x)
        x = self.inception1(x)
        x = self.inception2(x)
        x = self.maxpool(x)
        x = self.inception3(x)
        x = self.inception4(x)
        x = self.avgpool(x)
        x = x.view(x.size(0), -1)
        x = self.fc(x)
        return x


# 测试
googlenet = MiniGoogLeNet()
x = torch.randn(2, 3, 32, 32)
y = googlenet(x)
print(f"MiniGoogLeNet: {x.shape} → {y.shape}")
print(f"参数量: {sum(p.numel() for p in googlenet.parameters()):,}")
```

## 6. ResNet — 残差学习 (2015)

### 6.1 核心问题：深度退化

随着网络加深，理论上拟合能力应增强，但实际上：
- **训练误差不降反升**（不是过拟合！）
- 梯度消失/爆炸使得非常深的网络难以优化

### 6.2 残差连接 (Skip Connection)

$$
\mathbf{y} = \mathcal{F}(\mathbf{x}, \{W_i\}) + \mathbf{x}
$$

其中 $\mathcal{F}(\mathbf{x}, \{W_i\})$ 是残差函数（通常2-3层卷积）。

**关键洞察**：学习残差映射 $\mathcal{F}(\mathbf{x}) = \mathcal{H}(\mathbf{x}) - \mathbf{x}$ 比直接学习目标映射 $\mathcal{H}(\mathbf{x})$ 更容易。如果恒等映射是最优的，残差映射只需将权重推向零。

### 6.3 梯度分析

通过残差连接，反向传播的梯度为：

$$
\frac{\partial L}{\partial \mathbf{x}} = \frac{\partial L}{\partial \mathbf{y}} \cdot \left(\frac{\partial \mathcal{F}}{\partial \mathbf{x}} + 1\right)
$$

梯度中的 "+1" 项防止梯度消失，提供了稳定的梯度传播路径。这允许训练极深网络（如ResNet-152）。

### 6.4 Bottleneck设计

为减少深层ResNet的计算量，使用1×1卷积先降维后升维：

```
256-d → 1×1, 64 → 3×3, 64 → 1×1, 256 → + input(256-d)
```

计算量：$(256 \times 64 \times 1 \times 1 + 64 \times 64 \times 3 \times 3 + 64 \times 256 \times 1 \times 1) \times H \times W$
对比直接3×3卷积：$256 \times 256 \times 3 \times 3 \times H \times W$，节省约16倍。

```python
# ResNet PyTorch完整实现
import torch
import torch.nn as nn
import torch.nn.functional as F

class BasicBlock(nn.Module):
    """ResNet基本残差块 (用于ResNet-18/34)"""
    expansion = 1

    def __init__(self, in_planes, planes, stride=1):
        super(BasicBlock, self).__init__()
        self.conv1 = nn.Conv2d(in_planes, planes, kernel_size=3,
                               stride=stride, padding=1, bias=False)
        self.bn1 = nn.BatchNorm2d(planes)
        self.conv2 = nn.Conv2d(planes, planes, kernel_size=3,
                               stride=1, padding=1, bias=False)
        self.bn2 = nn.BatchNorm2d(planes)

        # Shortcut连接：当维度或空间尺寸不匹配时使用1×1卷积变换
        self.shortcut = nn.Sequential()
        if stride != 1 or in_planes != self.expansion * planes:
            self.shortcut = nn.Sequential(
                nn.Conv2d(in_planes, self.expansion * planes,
                          kernel_size=1, stride=stride, bias=False),
                nn.BatchNorm2d(self.expansion * planes)
            )

    def forward(self, x):
        out = F.relu(self.bn1(self.conv1(x)))
        out = self.bn2(self.conv2(out))
        out += self.shortcut(x)  # 残差连接！
        out = F.relu(out)
        return out


class Bottleneck(nn.Module):
    """ResNet瓶颈块 (用于ResNet-50/101/152)"""
    expansion = 4

    def __init__(self, in_planes, planes, stride=1):
        super(Bottleneck, self).__init__()
        # 1×1 降维
        self.conv1 = nn.Conv2d(in_planes, planes, kernel_size=1, bias=False)
        self.bn1 = nn.BatchNorm2d(planes)
        # 3×3 卷积
        self.conv2 = nn.Conv2d(planes, planes, kernel_size=3, stride=stride,
                               padding=1, bias=False)
        self.bn2 = nn.BatchNorm2d(planes)
        # 1×1 升维
        self.conv3 = nn.Conv2d(planes, self.expansion * planes, kernel_size=1,
                               bias=False)
        self.bn3 = nn.BatchNorm2d(self.expansion * planes)

        self.shortcut = nn.Sequential()
        if stride != 1 or in_planes != self.expansion * planes:
            self.shortcut = nn.Sequential(
                nn.Conv2d(in_planes, self.expansion * planes,
                          kernel_size=1, stride=stride, bias=False),
                nn.BatchNorm2d(self.expansion * planes)
            )

    def forward(self, x):
        out = F.relu(self.bn1(self.conv1(x)))
        out = F.relu(self.bn2(self.conv2(out)))
        out = self.bn3(self.conv3(out))
        out += self.shortcut(x)
        out = F.relu(out)
        return out


class ResNet(nn.Module):
    """完整ResNet实现"""

    def __init__(self, block, num_blocks, num_classes=1000):
        super(ResNet, self).__init__()
        self.in_planes = 64

        # Stem层
        self.conv1 = nn.Conv2d(3, 64, kernel_size=7, stride=2, padding=3,
                               bias=False)
        self.bn1 = nn.BatchNorm2d(64)
        self.maxpool = nn.MaxPool2d(kernel_size=3, stride=2, padding=1)

        # 四个Stage
        self.layer1 = self._make_layer(block, 64, num_blocks[0], stride=1)
        self.layer2 = self._make_layer(block, 128, num_blocks[1], stride=2)
        self.layer3 = self._make_layer(block, 256, num_blocks[2], stride=2)
        self.layer4 = self._make_layer(block, 512, num_blocks[3], stride=2)

        # 分类器
        self.avgpool = nn.AdaptiveAvgPool2d((1, 1))
        self.fc = nn.Linear(512 * block.expansion, num_classes)

        self._init_weights()

    def _make_layer(self, block, planes, num_blocks, stride):
        strides = [stride] + [1] * (num_blocks - 1)
        layers = []
        for stride in strides:
            layers.append(block(self.in_planes, planes, stride))
            self.in_planes = planes * block.expansion
        return nn.Sequential(*layers)

    def _init_weights(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode='fan_out',
                                        nonlinearity='relu')
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)
            elif isinstance(m, nn.Linear):
                nn.init.normal_(m.weight, 0, 0.01)

    def forward(self, x):
        x = F.relu(self.bn1(self.conv1(x)))
        x = self.maxpool(x)

        x = self.layer1(x)
        x = self.layer2(x)
        x = self.layer3(x)
        x = self.layer4(x)

        x = self.avgpool(x)
        x = x.view(x.size(0), -1)
        x = self.fc(x)
        return x


def ResNet18(num_classes=1000):
    return ResNet(BasicBlock, [2, 2, 2, 2], num_classes)

def ResNet34(num_classes=1000):
    return ResNet(BasicBlock, [3, 4, 6, 3], num_classes)

def ResNet50(num_classes=1000):
    return ResNet(Bottleneck, [3, 4, 6, 3], num_classes)

def ResNet101(num_classes=1000):
    return ResNet(Bottleneck, [3, 4, 23, 3], num_classes)

def ResNet152(num_classes=1000):
    return ResNet(Bottleneck, [3, 8, 36, 3], num_classes)


# 对比不同ResNet
for name, model_fn in [('ResNet18', ResNet18), ('ResNet34', ResNet34),
                        ('ResNet50', ResNet50), ('ResNet101', ResNet101),
                        ('ResNet152', ResNet152)]:
    model = model_fn(num_classes=1000)
    params = sum(p.numel() for p in model.parameters())
    print(f"{name}: {params:,} 参数")


# 残差学习的可视化验证
def visualize_residual_learning():
    """通过玩具示例展示残差学习"""
    import numpy as np
    import matplotlib.pyplot as plt

    # 目标函数：恒等映射（最优为恒等）
    np.random.seed(42)
    X = np.random.randn(300, 1)
    y = X.copy()  # 恒等映射

    # 将数据转换为PyTorch张量
    X_t = torch.FloatTensor(X)
    y_t = torch.FloatTensor(y)

    # 普通网络 vs 残差网络
    class PlainNet(nn.Module):
        def __init__(self):
            super().__init__()
            self.net = nn.Sequential(
                nn.Linear(1, 32), nn.ReLU(),
                nn.Linear(32, 32), nn.ReLU(),
                nn.Linear(32, 1)
            )

        def forward(self, x):
            return self.net(x)

    class ResNet_1D(nn.Module):
        def __init__(self):
            super().__init__()
            self.net = nn.Sequential(
                nn.Linear(1, 32), nn.ReLU(),
                nn.Linear(32, 32), nn.ReLU(),
                nn.Linear(32, 1)
            )

        def forward(self, x):
            return self.net(x) + x  # 残差连接！

    def train_model(model, epochs=2000):
        opt = optim.Adam(model.parameters(), lr=0.01)
        losses = []
        for _ in range(epochs):
            opt.zero_grad()
            out = model(X_t)
            loss = F.mse_loss(out, y_t)
            loss.backward()
            opt.step()
            losses.append(loss.item())
        return losses, model

    plain_model = PlainNet()
    res_model = ResNet_1D()
    plain_losses, plain_model = train_model(plain_model)
    res_losses, res_model = train_model(res_model)

    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    # 损失曲线
    axes[0].plot(plain_losses, 'r-', label='Plain Net', linewidth=2)
    axes[0].plot(res_losses, 'b-', label='ResNet (Skip)', linewidth=2)
    axes[0].set_xlabel('Epoch')
    axes[0].set_ylabel('MSE Loss')
    axes[0].set_title('训练损失 (恒等映射问题)')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    axes[0].set_yscale('log')

    # 拟合结果
    x_test = np.linspace(-3, 3, 100).reshape(-1, 1)
    x_test_t = torch.FloatTensor(x_test)

    with torch.no_grad():
        y_plain = plain_model(x_test_t).numpy()
        y_res = res_model(x_test_t).numpy()

    axes[1].scatter(X, y, c='gray', s=10, alpha=0.5, label='数据')
    axes[1].plot(x_test, y_plain, 'r-', linewidth=2, label='Plain')
    axes[1].plot(x_test, x_test, 'k--', alpha=0.5, label='Target')
    axes[1].set_title('Plain Net拟合')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    axes[2].scatter(X, y, c='gray', s=10, alpha=0.5, label='数据')
    axes[2].plot(x_test, y_res, 'b-', linewidth=2, label='ResNet')
    axes[2].plot(x_test, x_test, 'k--', alpha=0.5, label='Target')
    axes[2].set_title('ResNet拟合')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    plt.suptitle('残差学习的优势', fontsize=14)
    plt.tight_layout()
    plt.show()

    print(f"Plain Net最终损失: {plain_losses[-1]:.6f}")
    print(f"ResNet最终损失: {res_losses[-1]:.6f}")

visualize_residual_learning()
```

## 7. DenseNet (2017)

### 7.1 核心思想

DenseNet将每一层的输出连接到所有后续层，实现**最大化信息流**：

$$
\mathbf{x}_l = H_l([\mathbf{x}_0, \mathbf{x}_1, ..., \mathbf{x}_{l-1}])
$$

$[\mathbf{x}_0, \mathbf{x}_1, ..., \mathbf{x}_{l-1}]$ 表示前面所有层的输出在通道维度上的拼接。

### 7.2 与ResNet对比

- ResNet：$\mathbf{x}_l = H_l(\mathbf{x}_{l-1}) + \mathbf{x}_{l-1}$（加法）
- DenseNet：$\mathbf{x}_l = H_l([\mathbf{x}_0, \mathbf{x}_1, ..., \mathbf{x}_{l-1}])$（拼接）

DenseNet的优势：特征重用、梯度流动更好、参数量更少（通过Growth Rate控制）。

```python
# DenseNet核心组件实现
import torch
import torch.nn as nn

class DenseLayer(nn.Module):
    """DenseNet的基本构建块"""

    def __init__(self, in_channels, growth_rate, bn_size=4):
        super(DenseLayer, self).__init__()
        # Bottleneck: BN-ReLU-1×1Conv-BN-ReLU-3×3Conv
        self.bn1 = nn.BatchNorm2d(in_channels)
        self.conv1 = nn.Conv2d(in_channels, bn_size * growth_rate,
                                kernel_size=1, bias=False)
        self.bn2 = nn.BatchNorm2d(bn_size * growth_rate)
        self.conv2 = nn.Conv2d(bn_size * growth_rate, growth_rate,
                                kernel_size=3, padding=1, bias=False)

    def forward(self, x):
        out = self.conv1(F.relu(self.bn1(x)))
        out = self.conv2(F.relu(self.bn2(out)))
        return torch.cat([x, out], 1)  # 拼接！


class DenseBlock(nn.Module):
    """多个DenseLayer组成的稠密块"""

    def __init__(self, num_layers, in_channels, growth_rate, bn_size=4):
        super(DenseBlock, self).__init__()
        self.layers = nn.ModuleList()
        for i in range(num_layers):
            self.layers.append(DenseLayer(in_channels + i * growth_rate,
                                          growth_rate, bn_size))

    def forward(self, x):
        for layer in self.layers:
            x = layer(x)
        return x


class TransitionLayer(nn.Module):
    """过渡层: 1×1卷积压缩通道 + 2×2平均池化"""

    def __init__(self, in_channels, out_channels):
        super(TransitionLayer, self).__init__()
        self.bn = nn.BatchNorm2d(in_channels)
        self.conv = nn.Conv2d(in_channels, out_channels, kernel_size=1,
                              bias=False)
        self.pool = nn.AvgPool2d(kernel_size=2, stride=2)

    def forward(self, x):
        return self.pool(self.conv(F.relu(self.bn(x))))


class DenseNet(nn.Module):
    """DenseNet-121 (简化版，适配32×32输入)"""

    def __init__(self, growth_rate=32, num_classes=10):
        super(DenseNet, self).__init__()

        # Stem
        self.conv1 = nn.Conv2d(3, 2 * growth_rate, kernel_size=3,
                               stride=1, padding=1, bias=False)
        self.bn1 = nn.BatchNorm2d(2 * growth_rate)

        num_channels = 2 * growth_rate

        # Dense Block 1
        self.block1 = DenseBlock(6, num_channels, growth_rate)
        num_channels = num_channels + 6 * growth_rate
        self.trans1 = TransitionLayer(num_channels, num_channels // 2)
        num_channels = num_channels // 2

        # Dense Block 2
        self.block2 = DenseBlock(12, num_channels, growth_rate)
        num_channels = num_channels + 12 * growth_rate
        self.trans2 = TransitionLayer(num_channels, num_channels // 2)
        num_channels = num_channels // 2

        # Dense Block 3
        self.block3 = DenseBlock(24, num_channels, growth_rate)
        num_channels = num_channels + 24 * growth_rate

        # 分类器
        self.bn_final = nn.BatchNorm2d(num_channels)
        self.fc = nn.Linear(num_channels, num_classes)

    def forward(self, x):
        x = F.relu(self.bn1(self.conv1(x)))
        x = self.block1(x)
        x = self.trans1(x)
        x = self.block2(x)
        x = self.trans2(x)
        x = self.block3(x)
        x = F.relu(self.bn_final(x))
        x = F.adaptive_avg_pool2d(x, 1)
        x = x.view(x.size(0), -1)
        x = self.fc(x)
        return x


densenet = DenseNet(growth_rate=12, num_classes=10)
print(f"DenseNet 参数量: {sum(p.numel() for p in densenet.parameters()):,}")

x = torch.randn(2, 3, 32, 32)
print(f"输入: {x.shape} → 输出: {densenet(x).shape}")
```

## 8. MobileNet (2017)

### 8.1 设计目标

在移动设备和嵌入式设备上高效运行，通过**深度可分离卷积**大幅减少计算量。

### 8.2 核心：深度可分离卷积

MobileNet引入了两个关键超参数：
- **宽度乘子 $\alpha$** (Width Multiplier)：统一缩放通道数，默认1.0
- **分辨率乘子 $\rho$** (Resolution Multiplier)：缩放输入分辨率

```python
# MobileNet v1 核心实现
class DepthwiseSeparableConv(nn.Module):
    """深度可分离卷积"""

    def __init__(self, in_channels, out_channels, stride=1):
        super(DepthwiseSeparableConv, self).__init__()
        # Depthwise: 每个通道单独卷积
        self.depthwise = nn.Conv2d(in_channels, in_channels, kernel_size=3,
                                    stride=stride, padding=1,
                                    groups=in_channels, bias=False)
        self.bn1 = nn.BatchNorm2d(in_channels)
        # Pointwise: 1×1卷积混合通道
        self.pointwise = nn.Conv2d(in_channels, out_channels, kernel_size=1,
                                    stride=1, bias=False)
        self.bn2 = nn.BatchNorm2d(out_channels)

    def forward(self, x):
        x = F.relu(self.bn1(self.depthwise(x)))
        x = F.relu(self.bn2(self.pointwise(x)))
        return x


class MobileNetV1(nn.Module):
    """MobileNet V1"""

    def __init__(self, num_classes=1000, width_mult=1.0):
        super(MobileNetV1, self).__init__()

        def conv_dw(in_c, out_c, stride):
            return DepthwiseSeparableConv(
                int(in_c * width_mult), int(out_c * width_mult), stride)

        def conv(in_c, out_c, stride):
            return nn.Sequential(
                nn.Conv2d(int(in_c * width_mult), int(out_c * width_mult),
                          kernel_size=3, stride=stride, padding=1, bias=False),
                nn.BatchNorm2d(int(out_c * width_mult)),
                nn.ReLU(inplace=True)
            )

        self.model = nn.Sequential(
            conv(3, 32, 2),       # 224→112
            conv_dw(32, 64, 1),   # 112→112
            conv_dw(64, 128, 2),  # 112→56
            conv_dw(128, 128, 1), # 56→56
            conv_dw(128, 256, 2), # 56→28
            conv_dw(256, 256, 1), # 28→28
            conv_dw(256, 512, 2), # 28→14
            *[conv_dw(512, 512, 1) for _ in range(5)],  # 14→14
            conv_dw(512, 1024, 2), # 14→7
            conv_dw(1024, 1024, 1), # 7→7
            nn.AdaptiveAvgPool2d(1),
        )
        self.fc = nn.Linear(int(1024 * width_mult), num_classes)

    def forward(self, x):
        x = self.model(x)
        x = x.view(x.size(0), -1)
        x = self.fc(x)
        return x


mobilenet = MobileNetV1(num_classes=1000, width_mult=1.0)
print(f"MobileNetV1 参数量: {sum(p.numel() for p in mobilenet.parameters()):,}")
print(f"vs VGG16: ~138M → MobileNet: ~4.2M (约33x更小)")
```

## 9. 迁移学习实战

```python
# 迁移学习：使用预训练ResNet进行细粒度分类
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, random_split
from torchvision import datasets, transforms, models
import matplotlib.pyplot as plt

def transfer_learning_demo():
    """迁移学习：在小型数据集上微调预训练ResNet"""
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

    # 数据准备（使用CIFAR-10的前5类作为"新任务"）
    transform_train = transforms.Compose([
        transforms.Resize(224),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    transform_test = transforms.Compose([
        transforms.Resize(224),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])

    # 加载少量训练数据模拟小样本场景
    try:
        train_data = datasets.CIFAR10('./data', train=True, download=True,
                                       transform=transform_train)
        train_data, _ = random_split(train_data, [5000, 45000],
                                      generator=torch.Generator().manual_seed(42))
        test_data = datasets.CIFAR10('./data', train=False,
                                      transform=transform_test)
        train_loader = DataLoader(train_data, batch_size=32, shuffle=True)
        test_loader = DataLoader(test_data, batch_size=32, shuffle=False)
        num_classes = 10
    except:
        print("无法加载CIFAR-10，跳过训练")
        return

    # 加载预训练ResNet18
    model = models.resnet18(pretrained=True)

    # 策略: 冻结早期层，只微调后面的层
    # Stage 1: 冻结全部，只训练新的分类头
    for param in model.parameters():
        param.requires_grad = False

    # 替换最后的全连接层
    model.fc = nn.Sequential(
        nn.Linear(model.fc.in_features, 256),
        nn.ReLU(),
        nn.Dropout(0.5),
        nn.Linear(256, num_classes)
    )
    model = model.to(device)

    # 阶段1：训练分类头（学习率较大）
    print("Stage 1: 训练分类头 (参数冻结)")
    optimizer = optim.Adam(model.fc.parameters(), lr=0.001)
    criterion = nn.CrossEntropyLoss()

    for epoch in range(5):
        model.train()
        correct, total = 0, 0
        for data, target in train_loader:
            data, target = data.to(device), target.to(device)
            optimizer.zero_grad()
            output = model(data)
            loss = criterion(output, target)
            loss.backward()
            optimizer.step()
            correct += output.argmax(1).eq(target).sum().item()
            total += target.size(0)

        model.eval()
        test_correct, test_total = 0, 0
        with torch.no_grad():
            for data, target in test_loader:
                data, target = data.to(device), target.to(device)
                output = model(data)
                test_correct += output.argmax(1).eq(target).sum().item()
                test_total += target.size(0)

        print(f'Epoch {epoch+1}: Train {100.*correct/total:.1f}%, '
              f'Test {100.*test_correct/test_total:.1f}%')

    # 阶段2：解冻layer4，使用更小的学习率微调整个网络
    print("\nStage 2: 微调layer4 (学习率降低)")
    for param in model.layer4.parameters():
        param.requires_grad = True

    optimizer = optim.Adam([
        {'params': model.layer4.parameters(), 'lr': 0.0001},
        {'params': model.fc.parameters(), 'lr': 0.001},
    ])

    for epoch in range(5):
        model.train()
        correct, total = 0, 0
        for data, target in train_loader:
            data, target = data.to(device), target.to(device)
            optimizer.zero_grad()
            output = model(data)
            loss = criterion(output, target)
            loss.backward()
            optimizer.step()
            correct += output.argmax(1).eq(target).sum().item()
            total += target.size(0)

        model.eval()
        test_correct, test_total = 0, 0
        with torch.no_grad():
            for data, target in test_loader:
                data, target = data.to(device), target.to(device)
                output = model(data)
                test_correct += output.argmax(1).eq(target).sum().item()
                test_total += target.size(0)

        print(f'Epoch {epoch+1}: Train {100.*correct/total:.1f}%, '
              f'Test {100.*test_correct/test_total:.1f}%')

transfer_learning_demo()

# 迁移学习策略总结
print("\n迁移学习策略总结:")
print("=" * 60)
print("策略1 — 特征提取器:")
print("  冻结全部预训练层, 仅训练新的分类头")
print("  适用: 目标数据量小(<1000), 与源任务相似")
print()
print("策略2 — 部分微调:")
print("  冻结早期层, 微调后面几层 + 分类头")
print("  适用: 目标数据量中等(1000-10000)")
print()
print("策略3 — 完全微调:")
print("  解冻所有层, 使用较小学习率训练")
print("  适用: 目标数据量大(>10000)")
```

## 相关笔记

- [[07-神经网络|神经网络]] — 神经网络基础
- [[08-优化方法|优化方法]] — 训练技巧与正则化
- [[09-卷积神经网络CNN|卷积神经网络CNN]] — CNN基础原理
- [[06-PyTorch入门|PyTorch]] — PyTorch框架使用
- [[LaTeX/main.tex|LaTeX完整教程]] — 论文排版
