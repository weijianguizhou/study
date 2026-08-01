# 生成对抗网络 (GAN)

> 如果说 VAE 用"概率 + 变分推断"逼近数据分布，那么 GAN（Goodfellow et al., 2014）则换了一条更"暴力"的路线：让两个神经网络互相博弈，在对抗中逼出真实的生成器。GAN 生成的图像曾经一度是 AI 圈的顶流（人脸生成、风格迁移），但也以"训练难、易崩溃"著称。本章讲透博弈思想、理论证明、训练技巧，以及它的继承者扩散模型为何更胜一筹。

---

## 1. 核心思想：伪造者与鉴定者的博弈

### 1.1 直觉类比

想象一个**伪造者**（生成器 G）和一个**鉴定专家**（判别器 D）：

- 伪造者制造假画，试图骗过专家；
- 专家鉴定画作，努力分辨真假；
- 训练过程中，专家越来越强，逼着伪造者画得越来越好；
- 最终：伪造者的画足以以假乱真。

关键：**两个角色在对抗中共同进步**，最终达到一个均衡——专家再也分不出真假。

### 1.2 角色定义

- **生成器**（Generator）$G: \mathbb{R}^{d_z} \to \mathbb{R}^{d_x}$：把随机噪声 $z \sim p_z(z)$（通常是标准高斯）映射为"伪造样本" $G(z)$，希望它服从真实数据分布 $p_{\text{data}}$；
- **判别器**（Discriminator）$D: \mathbb{R}^{d_x} \to [0,1]$：输入一个样本，输出它是**真实样本**的概率。目标是：真实样本给高分 $D(x)\to 1$，伪造样本给低分 $D(G(z))\to 0$。

```
z (噪声) ──▶ 生成器 G ──▶ G(z) ──┐
                                 ├──▶ 判别器 D ──▶ P(真实)
x (真实数据) ───────────────────┘
```

---

## 2. 目标函数与理论基础

### 2.1 极小极大目标函数

GAN 的完整目标是下面的**极小极大博弈**：

$$
\boxed{\;\min_G \max_D V(D, G)
= \mathbb{E}_{x \sim p_{\text{data}}(x)}\left[ \log D(x) \right]
+ \mathbb{E}_{z \sim p_z(z)}\left[ \log\left(1 - D(G(z))\right) \right]\;}
$$

理解每一项：

- $D$ 想**最大化** $V$：让 $D(x)$ 大（第一项大）、$D(G(z))$ 小（第二项大）；
- $G$ 想**最小化** $V$：让 $D(G(z))$ 大（第二项小，即 $\log(1-D(G(z)))$ 小），从而骗过判别器。

由于 $D$ 输出在 $[0,1]$，$\log D(x)$ 是标准二值交叉熵——**判别器 D 本质上是一个二分类器**。

### 2.2 最优判别器

对于固定的生成器 $G$，最优判别器 $D^*$ 应最大化 $V$。把两项合起来写成对 $x$ 的积分（$G$ 诱导的分布记作 $p_g$，即 $p_g = p_z \circ G^{-1}$）：

$$
V = \int_x \Big[ p_{\text{data}}(x) \log D(x) + p_g(x) \log\big(1 - D(x)\big) \Big] dx
$$

对每个固定的 $x$，被积函数 $f(d) = p_{\text{data}} \log d + p_g \log(1-d)$ 关于 $d$ 是凹函数。求导令其为 0：

$$
\frac{\partial f}{\partial d} = \frac{p_{\text{data}}}{d} - \frac{p_g}{1-d} = 0
\;\Longrightarrow\;
\boxed{\;D^*(x) = \frac{p_{\text{data}}(x)}{p_{\text{data}}(x) + p_g(x)}\;}
$$

**直觉**：当真实分布占优处判别器输出接近 1，伪造占优处接近 0，五五开处输出 0.5（即"彻底分不清"）。

### 2.3 全局最优：$p_g = p_{\text{data}}$

把 $D^*$ 代回目标函数，得到关于 $G$ 的目标：

$$
\begin{aligned}
C(G) &= \mathbb{E}_{x \sim p_{\text{data}}}\left[\log \frac{p_{\text{data}}}{p_{\text{data}}+p_g}\right]
+ \mathbb{E}_{x \sim p_g}\left[\log \frac{p_g}{p_{\text{data}}+p_g}\right] \\
&= -\log 4 + \underbrace{2 \cdot JSD\left(p_{\text{data}} \,\|\, p_g\right)}_{\text{JS 散度}}
\end{aligned}
$$

其中 JS 散度（Jensen-Shannon Divergence）定义（见 [[03-数学基础-概率与统计|概率与统计]]）：

$$
JSD(p \| q) = \frac{1}{2}KL\!\left(p \,\Big\|\, \frac{p+q}{2}\right) + \frac{1}{2}KL\!\left(q \,\Big\|\, \frac{p+q}{2}\right)
$$

**关键结论**：

1. JS 散度 $\geq 0$，当且仅当 $p_g = p_{\text{data}}$ 时取 0；
2. 因此 $C(G)$ 的最小值为 $-\log 4$，在 $p_g = p_{\text{data}}$ 处取得；
3. 此时 $D^*(x) \equiv 0.5$——判别器对真假完全束手无策。

**理论说了什么**：GAN 的极小极大博弈存在唯一全局最优，且最优时生成分布等于真实分布。

---

## 3. 训练流程：交替更新

理论说"同时优化两个网络"，但实践中用**交替更新**：一个 batch 里先固定 $G$ 更新 $D$，再固定 $D$ 更新 $G$。

```
for epoch in range(n_epochs):
    for (real_images, _) in dataloader:
        # ===== 1. 更新判别器 D（固定 G）=====
        z = sample_noise(batch_size)          # 采样噪声
        fake_images = G(z)                    # 生成伪造样本
        d_real = D(real_images)               # 判别真实样本
        d_fake = D(fake_images.detach())      # 判别伪造样本（detach 阻断 G 的梯度）
        d_loss = -[ log(d_real) + log(1 - d_fake) ]
        d_loss.backward(); update(D)

        # ===== 2. 更新生成器 G（固定 D）=====
        fake_images = G(z)                    # 重新前向（或用上一次的）
        d_fake = D(fake_images)               # 判别器对伪造样本的打分
        g_loss = -log(d_fake)                 # 想让 D 判它为真
        g_loss.backward(); update(G)
```

**三个工程细节**：

| 细节 | 原因 |
|------|------|
| `fake.detach()` | 更新 D 时不让梯度流入 G |
| G 用 $-\log D(G(z))$ 而非 $\log(1-D(G(z)))$ | 后者早期梯度饱和（D 太强时梯度≈0），前者梯度更陡，训练更稳 |
| 生成器更新次数常少于判别器 | 防止判别器被"打爆" |

---

## 4. 训练困难与常见问题

### 4.1 模式坍缩（Mode Collapse）

**现象**：生成器只学会生成少数几种样本（如只生成数字 1），丢弃了其他模式。因为只要骗过当前判别器就能得分，生成器倾向于"躺平"到最容易骗的少数模式上。

$$
p_g \neq p_{\text{data}}，但 \min_G \text{仍能骗过弱判别器}
$$

**缓解**：
- **Mini-batch Discrimination**：判别器看整个 batch 的统计量，识别"全是同一类"的 batch；
- **Unrolled GAN**：更新 G 时展开几步 D 的优化，避免"只顾当前骗局"；
- **WGAN**（见下）：Wasserstein 距离对坍缩更敏感；
- 历史平均、谱归一化等正则技巧。

### 4.2 不收敛：纳什均衡 vs 梯度下降

GAN 的目标是找**纳什均衡**（两人都不愿单方面改变），但梯度下降只保证找到**局部极小**，两者并不等价。实践中常出现：

- **震荡**：D 和 G 的损失交替上升下降，永不收敛；
- **判别器太强**：$D$ 迅速收敛到 $D^*$，梯度消失，$G$ 学不到东西；
- **判别器太弱**：$G$ 得不到有效反馈，胡乱生成。

**经验法则**：判别器不能比生成器强太多（常见做法：每更新 1 次 D 更新 1~5 次 G，或用学习率控制）。

### 4.3 梯度消失 / 梯度爆炸

理论上当 $p_g$ 与 $p_{\text{data}}$ 几乎不重叠时，JS 散度**恒为 $\log 2$**（一个常数！），梯度完全消失——这正是原始 GAN 训练困难的理论根源，也是 WGAN 的动机。

### 4.4 训练技巧清单

| 技巧 | 说明 |
|------|------|
| **标签平滑**（Label Smoothing） | 把真实标签 1 改成 0.9，防止 D 过度自信 |
| **噪声** | 给 D 的输入加高斯噪声，或对标签加噪声 |
| **谱归一化**（Spectral Norm） | 约束 D 的 Lipschitz 常数，稳定训练 |
| **BatchNorm 技巧** | D 用层归一化而非 BatchNorm（避免 batch 统计泄露真假信息） |
| **Adam 参数** | 常用 lr=2e-4，$\beta_1=0.5$（降低动量，防震荡） |
| **He 初始化** | 卷积层用 $\mathcal{N}(0, 0.02)$ 初始化 |

---

## 5. WGAN 与 WGAN-GP

### 5.1 从 JS 到 Wasserstein 距离

原始 GAN 用 JS 散度，问题在于：两个分布**不相交时 JS 恒为常数**，梯度为零，无法学习。WGAN（Arjovsky et al., 2017）改用 **Wasserstein 距离**（推土机距离，Earth-Mover Distance）——度量把 $p_g$ 的"土"搬成 $p_{\text{data}}$ 的最小代价：

$$
W(p_r, p_g) = \inf_{\gamma \in \Pi(p_r, p_g)} \mathbb{E}_{(x,y)\sim\gamma}\left[ \| x - y \| \right]
$$

即使两个分布不重叠，Wasserstein 距离仍然**平滑、连续、处处有梯度**（JS 散度不连续且梯度消失）。通过 Kantorovich-Rubinstein 对偶，可写成：

$$
W(p_r, p_g) = \sup_{\|f\|_L \leq 1} \left\{ \mathbb{E}_{x \sim p_r}[f(x)] - \mathbb{E}_{x \sim p_g}[f(x)] \right\}
$$

其中 $f$ 是满足 **Lipschitz 约束**（$\|f\|_L \le 1$，斜率有界）的判别器（WGAN 中称为 critic）。

### 5.2 WGAN 目标函数

$$
\boxed{\;\min_G \max_{\|f\|_L \le 1} \; \mathbb{E}_{x \sim p_r}[f(x)] - \mathbb{E}_{z \sim p_z}[f(G(z))]\;}
$$

注意：critic 的最后一层**去掉 Sigmoid**，输出是一个实数值（不再解释为概率）。$D$ 的输出越大表示越像真实数据。

**WGAN 的优势**：损失函数数值反映生成质量（训练时可当作监控指标）、训练明显更稳定、模式坍缩大幅减少。

### 5.3 WGAN-GP：梯度惩罚

Wasserstein 距离要求 Lipschitz 约束，WGAN 用权重裁剪实现（效果差、易导致参数两极分化）。**WGAN-GP**（Gulrajani et al., 2017）改用**梯度惩罚**：

$$
\mathcal{L}_D = \mathbb{E}[f(G(z))] - \mathbb{E}[f(x)]
+ \lambda \, \mathbb{E}_{\hat{x}}\left[\left( \|\nabla_{\hat{x}} f(\hat{x})\|_2 - 1 \right)^2\right]
$$

其中 $\hat{x}$ 在真实样本与伪造样本的连线上采样：$\hat{x} = \epsilon x + (1-\epsilon) G(z)$，$\epsilon \sim U[0,1]$。梯度惩罚项直接惩罚判别器梯度偏离 1，从而隐式满足 Lipschitz 条件。

$$
\hat{x} = \epsilon x + (1-\epsilon)\tilde{x}, \quad \epsilon \sim \text{Uniform}(0,1)
$$

**总结：WGAN-GP 是目前 GAN 训练稳定性的标杆方案。**

---

## 6. GAN 变体

### 6.1 DCGAN（深度卷积 GAN）

DCGAN（Radford et al., 2015）把 GAN 从全连接网络升级为卷积网络，奠定了图像 GAN 的标准范式：

- 生成器用**转置卷积**（ConvTranspose，见 [[09-卷积神经网络CNN|CNN]]）上采样；
- 判别器用**带步长卷积**下采样，替代池化；
- 除输出层外**去掉全连接层**，用 BatchNorm + ReLU（G）/ LeakyReLU（D）；
- 生成器输出用 **Tanh**，判别器输出用 Sigmoid。

### 6.2 cGAN（条件 GAN）

无条件 GAN 无法控制生成内容。cGAN 把条件信息 $y$（类别标签、文本）同时喂给 G 和 D：

$$
\min_G \max_D \; \mathbb{E}_{x,y}\left[\log D(x, y)\right] + \mathbb{E}_{z,y}\left[\log\left(1 - D(G(z, y), y)\right)\right]
$$

应用：**生成指定数字**、人脸属性编辑、文本生成图像（如 StackGAN）。

### 6.3 CycleGAN：无配对风格迁移

CycleGAN（Zhu et al., 2017）解决**无配对**的风格迁移（如马↔斑马、照片↔油画）。核心是**循环一致性损失**：

$$
\mathcal{L}_{\text{cyc}} = \mathbb{E}_x\left[\| G_{BA}(G_{AB}(x)) - x \|_1\right]
+ \mathbb{E}_y\left[\| G_{AB}(G_{BA}(y)) - y \|_1\right]
$$

直觉：把照片变成油画，再变回照片，应该回到原图。这约束了映射 $G_{AB}$ 与 $G_{BA}$ 的"可逆性"，防止风格迁移时内容被篡改。

**完整损失**：对抗损失（两对 G/D） + 循环一致性损失（$\lambda=10$）。

---

## 7. 评估指标：IS 与 FID

GAN 没有显式的损失值可看，需要专门的指标评估生成质量。

### 7.1 Inception Score（IS）

用预训练的 Inception-v3 网络计算生成图像的条件标签分布：

$$
IS(G) = \exp\left( \mathbb{E}_{x \sim p_g}\left[ KL\left( p(y\mid x) \,\|\, p(y) \right) \right] \right)
$$

- $p(y\mid x)$ 尖锐（熵小）⟹ 每张图类别明确；
- $p(y)$ 均匀（熵大）⟹ 生成的类别多样。

**IS 越高越好**，同时惩罚"模糊的中间态"和"模式坍缩"。缺陷：对分布内样本偏差不敏感，且完全脱离真实数据。

### 7.2 Fréchet Inception Distance（FID）

把真实与生成图像都送入 Inception-v3 取特征（2048 维），假设特征服从高斯，计算两个高斯之间的 **Fréchet 距离**：

$$
FID = \|\mu_r - \mu_g\|_2^2 + \text{Tr}\left( \Sigma_r + \Sigma_g - 2(\Sigma_r \Sigma_g)^{1/2} \right)
$$

- $\mu, \Sigma$：真实/生成特征分布的均值与协方差矩阵；
- **FID 越低越好**，对模式坍缩比 IS 更敏感，是当前主流标准。

| 指标 | 度量 | 越高/越低好 | 依赖真实数据 |
|------|------|------------|:---:|
| IS | 图像质量 + 类别多样性 | 越高越好 | 否 |
| FID | 生成分布与真实分布的特征距离 | 越低越好 | 是 |

---

## 8. PyTorch 实现：DCGAN 生成 MNIST

```python
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
import matplotlib.pyplot as plt

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
torch.manual_seed(42)

# ========== 数据加载（归一化到 [-1, 1] 匹配 Tanh 输出） ==========
transform = transforms.Compose([
    transforms.Resize(32),                 # 转为 32x32
    transforms.ToTensor(),
    transforms.Normalize((0.5,), (0.5,)),
])
train_data = datasets.MNIST(root='./data', train=True, download=True,
                            transform=transform)
train_loader = DataLoader(train_data, batch_size=128, shuffle=True)

# ========== 参数初始化（DCGAN 约定） ==========
def weights_init(m):
    classname = m.__class__.__name__
    if classname.find('Conv') != -1:
        nn.init.normal_(m.weight.data, 0.0, 0.02)
    elif classname.find('BatchNorm') != -1:
        nn.init.normal_(m.weight.data, 1.0, 0.02)
        nn.init.constant_(m.bias.data, 0)

# ========== 生成器：噪声 z -> 32x32 图像 ==========
class Generator(nn.Module):
    def __init__(self, latent_dim=100, ngf=64):
        super().__init__()
        self.main = nn.Sequential(
            nn.ConvTranspose2d(latent_dim, ngf*8, 4, 1, 0, bias=False),  # -> 4x4
            nn.BatchNorm2d(ngf*8), nn.ReLU(True),
            nn.ConvTranspose2d(ngf*8, ngf*4, 4, 2, 1, bias=False),       # -> 8x8
            nn.BatchNorm2d(ngf*4), nn.ReLU(True),
            nn.ConvTranspose2d(ngf*4, ngf*2, 4, 2, 1, bias=False),       # -> 16x16
            nn.BatchNorm2d(ngf*2), nn.ReLU(True),
            nn.ConvTranspose2d(ngf*2, 1, 4, 2, 1, bias=False),           # -> 32x32
            nn.Tanh(),
        )

    def forward(self, z):
        return self.main(z.view(z.size(0), z.size(1), 1, 1))

# ========== 判别器：32x32 图像 -> 真/假 ==========
class Discriminator(nn.Module):
    def __init__(self, ndf=64):
        super().__init__()
        self.main = nn.Sequential(
            nn.Conv2d(1, ndf, 4, 2, 1, bias=False),      # -> 16x16
            nn.LeakyReLU(0.2, True),
            nn.Conv2d(ndf, ndf*2, 4, 2, 1, bias=False),  # -> 8x8
            nn.BatchNorm2d(ndf*2), nn.LeakyReLU(0.2, True),
            nn.Conv2d(ndf*2, ndf*4, 4, 2, 1, bias=False),# -> 4x4
            nn.BatchNorm2d(ndf*4), nn.LeakyReLU(0.2, True),
            nn.Conv2d(ndf*4, ndf*8, 4, 2, 1, bias=False),# -> 2x2
            nn.BatchNorm2d(ndf*8), nn.LeakyReLU(0.2, True),
            nn.Conv2d(ndf*8, 1, 2, 1, 0, bias=False),    # -> 1x1
            nn.Sigmoid(),
        )

    def forward(self, x):
        return self.main(x).view(-1)

# ========== 初始化模型与优化器 ==========
latent_dim = 100
G = Generator(latent_dim).to(device)
D = Discriminator().to(device)
G.apply(weights_init); D.apply(weights_init)

criterion = nn.BCELoss()                    # 二值交叉熵
opt_G = optim.Adam(G.parameters(), lr=2e-4, betas=(0.5, 0.999))
opt_D = optim.Adam(D.parameters(), lr=2e-4, betas=(0.5, 0.999))

# 固定噪声用于可视化训练过程
fixed_noise = torch.randn(16, latent_dim, 1, 1, device=device)

# ========== 训练循环 ==========
EPOCHS = 15
real_label, fake_label = 0.9, 0.0          # 标签平滑：真实=0.9
g_losses, d_losses = [], []

for epoch in range(EPOCHS):
    for i, (real, _) in enumerate(train_loader):
        batch = real.size(0)
        real = real.to(device)
        noise = torch.randn(batch, latent_dim, 1, 1, device=device)

        # ---- 1. 更新判别器 ----
        D.zero_grad()
        output_real = D(real)
        loss_D_real = criterion(output_real, torch.full((batch,), real_label, device=device))
        loss_D_real.backward()

        fake = G(noise)
        output_fake = D(fake.detach())
        loss_D_fake = criterion(output_fake, torch.full((batch,), fake_label, device=device))
        loss_D_fake.backward()
        opt_D.step()

        # ---- 2. 更新生成器 ----
        G.zero_grad()
        output_fake = D(fake)
        loss_G = criterion(output_fake, torch.full((batch,), real_label, device=device))
        loss_G.backward()
        opt_G.step()

        if i % 100 == 0:
            print(f'Epoch {epoch+1} Batch {i:4d} | '
                  f'D_loss: {(loss_D_real+loss_D_fake).item():.4f} | '
                  f'G_loss: {loss_G.item():.4f}')

    g_losses.append(loss_G.item()); d_losses.append((loss_D_real+loss_D_fake).item())

    # ---- 每轮可视化固定噪声的生成结果 ----
    G.eval()
    with torch.no_grad():
        gen = G(fixed_noise).cpu()
    G.train()
    fig, axes = plt.subplots(4, 4, figsize=(8, 8))
    for idx, ax in enumerate(axes.flatten()):
        ax.imshow(gen[idx, 0].numpy() * 0.5 + 0.5, cmap='gray')
        ax.axis('off')
    plt.suptitle(f'Epoch {epoch+1}: 生成器输出', fontsize=13)
    plt.tight_layout(); plt.show()

# ========== 最终采样与损失曲线 ==========
G.eval()
with torch.no_grad():
    samples = G(torch.randn(64, latent_dim, 1, 1, device=device)).cpu()
fig, axes = plt.subplots(8, 8, figsize=(8, 8))
for idx, ax in enumerate(axes.flatten()):
    ax.imshow(samples[idx, 0].numpy() * 0.5 + 0.5, cmap='gray')
    ax.axis('off')
plt.suptitle('DCGAN 最终生成结果', fontsize=13)
plt.tight_layout(); plt.show()

plt.figure(figsize=(8, 4))
plt.plot(d_losses, label='判别器损失', linewidth=2)
plt.plot(g_losses, label='生成器损失', linewidth=2)
plt.xlabel('Epoch'); plt.ylabel('Loss'); plt.legend(); plt.grid(alpha=0.3)
plt.title('GAN 训练损失（理想: D≈0.69 即对数几率五五开）')
plt.show()
```

**训练成功的标志**：生成器损失的震荡幅度逐渐减小、生成的数字越来越清晰；若损失剧烈震荡且图像始终模糊/单一，往往是模式坍缩或学习率过大的信号。

---

## 9. GAN vs 扩散模型对比表

| 对比维度 | GAN | 扩散模型 |
|---------|-----|---------|
| 训练方式 | 双网络对抗博弈 | 单网络回归（预测噪声） |
| 目标函数 | 极小极大（非凸） | MSE 回归（凸、稳定） |
| 训练稳定性 | 差，易模式坍缩 | 非常稳定 |
| 多样性 | 差（模式坍缩倾向） | 好 |
| 样本质量 | 高（清晰锐利） | 最高（当前 SOTA） |
| 采样速度 | 快（单次前向） | 慢（T 步迭代） |
| 密度估计 | 无 | 有（ELBO 下界） |
| 潜在空间 | 无结构 | 有（LDM） |

一句话：**GAN 追求"一步到位地骗过判别器"，扩散模型追求"一步步把噪声还原成数据"。** 后者更稳、更可解释，但更慢——这也是为什么工业界最终选择了扩散模型（详见 [[15-扩散模型|扩散模型]]）。

---

## 10. GAN 的应用

- **图像生成**：人脸生成（StyleGAN）、超分辨率（SRGAN）、图像修复；
- **风格迁移**：CycleGAN 马↔斑马、照片↔艺术画；
- **数据增强**：为小样本任务合成数据；
- **文本生成**：GAN 文本（SeqGAN 等，但已被自回归模型取代）；
- **语音与音乐**：语音合成、声音转换。

---

## 相关笔记

- [[00-深度学习索引|深度学习教程索引]] — 返回教程总览
- [[07-神经网络|神经网络]] — MLP 与激活函数基础
- [[09-卷积神经网络CNN|CNN]] — 转置卷积、卷积下采样（DCGAN 基础）
- [[03-数学基础-概率与统计|概率与统计]] — 分布、KL/JS 散度、交叉熵
- [[08-优化方法|优化方法]] — Adam 与训练不稳定问题
- [[13-自编码器与变分自编码器|自编码器与变分自编码器]] — 概率生成模型的另一路线
- [[15-扩散模型|扩散模型]] — GAN 的现代替代者
- [[12-Transformer与大模型|Transformer]] — 多模态生成中的文本编码
- [[../大模型与生成式AI/05-多模态模型|多模态模型]] — 文生图/文生视频的整体图景
