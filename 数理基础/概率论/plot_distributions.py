# -*- coding: utf-8 -*-
"""
概率论 - 常见概率分布图绘制
生成 PNG 图片供 LaTeX 文档引用，均配置中文字体和中文标签。
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rcParams
from scipy import stats

# ==================== 中文配置 ====================
rcParams['font.sans-serif'] = ['SimHei', 'Microsoft YaHei', 'DejaVu Sans']
rcParams['axes.unicode_minus'] = False
plt.rcParams['figure.dpi'] = 150
plt.rcParams['savefig.dpi'] = 150
plt.rcParams['savefig.bbox'] = 'tight'

# 输出目录（与 .tex 文件同级的 Figure/ 目录）
import os
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(SCRIPT_DIR, 'Figure')
os.makedirs(OUT_DIR, exist_ok=True)

COLORS = ['#8B0000', '#732D02', '#005050', '#1A5276', '#7D3C98']


def stem_plot(ax, x, y, color, label, **kwargs):
    """兼容旧版 matplotlib 的 stem 绘图辅助函数"""
    markerline, stemlines, baseline = ax.stem(x, y, label=label, **kwargs)
    plt.setp(stemlines, color=color, linewidth=1.5)
    plt.setp(markerline, color=color, markersize=5, marker='o')
    plt.setp(baseline, color='gray', linewidth=0.5)
    return markerline, stemlines, baseline


# ==================== 1. 二项分布 ====================
def plot_binomial():
    n = 20
    k = np.arange(0, n + 1)
    params = [(0.3, 'p=0.3'), (0.5, 'p=0.5'), (0.7, 'p=0.7')]

    fig, ax = plt.subplots(figsize=(10, 5))
    for (p, label), c in zip(params, COLORS[:3]):
        pmf = stats.binom.pmf(k, n, p)
        stem_plot(ax, k, pmf, c, label)
    ax.set_xlabel(r'$k$', fontsize=13)
    ax.set_ylabel(r'$P\{X=k\}$', fontsize=13)
    ax.set_title(f'二项分布 $B(n={n}, p)$ 的分布律', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(-0.5, n + 0.5)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(os.path.join(OUT_DIR, 'binomial_dist.png'))
    plt.close(fig)


# ==================== 2. Poisson 分布 ====================
def plot_poisson():
    lambdas = [3, 6, 10]
    k_max = 25
    k = np.arange(0, k_max + 1)

    fig, ax = plt.subplots(figsize=(10, 5))
    for lam, c in zip(lambdas, COLORS[:3]):
        pmf = stats.poisson.pmf(k, lam)
        stem_plot(ax, k, pmf, c, rf'$\lambda={lam}$')
    ax.set_xlabel(r'$k$', fontsize=13)
    ax.set_ylabel(r'$P\{X=k\}$', fontsize=13)
    ax.set_title(r'Poisson 分布 $P(\lambda)$ 的分布律', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(-0.5, k_max)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(os.path.join(OUT_DIR, 'poisson_dist.png'))
    plt.close(fig)


# ==================== 3. 均匀分布 ====================
def plot_uniform():
    params = [(0, 1), (-1, 2), (2, 4)]
    x = np.linspace(-2, 5, 500)

    fig, ax = plt.subplots(figsize=(10, 5))
    for (a, b), c in zip(params, COLORS[:3]):
        y = stats.uniform.pdf(x, loc=a, scale=b - a)
        ax.plot(x, y, c, linewidth=2, label=rf'$U({a},{b})$')
        mask = (x >= a) & (x <= b)
        ax.fill_between(x[mask], 0, y[mask], color=c, alpha=0.15)
    ax.set_xlabel(r'$x$', fontsize=13)
    ax.set_ylabel(r'$f(x)$', fontsize=13)
    ax.set_title(r'均匀分布 $U(a,b)$ 的概率密度函数', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(-2, 5)
    ax.set_ylim(bottom=0)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(os.path.join(OUT_DIR, 'uniform_dist.png'))
    plt.close(fig)


# ==================== 4. 指数分布 ====================
def plot_exponential():
    lambdas = [0.5, 1.0, 2.0]
    x = np.linspace(0, 8, 500)

    fig, ax = plt.subplots(figsize=(10, 5))
    for lam, c in zip(lambdas, COLORS[:3]):
        y = stats.expon.pdf(x, scale=1 / lam)
        ax.plot(x, y, c, linewidth=2, label=rf'$\lambda={lam}$')
    ax.set_xlabel(r'$x$', fontsize=13)
    ax.set_ylabel(r'$f(x)$', fontsize=13)
    ax.set_title(r'指数分布 $E(\lambda)$ 的概率密度函数', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 8)
    ax.set_ylim(bottom=0)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(os.path.join(OUT_DIR, 'exponential_dist.png'))
    plt.close(fig)


# ==================== 5. 正态分布 —— 不同均值 ====================
def plot_normal_mu():
    mus = [-2, 0, 3]
    sigma = 1.0
    x = np.linspace(-6, 7, 500)

    fig, ax = plt.subplots(figsize=(10, 5))
    for mu, c in zip(mus, COLORS[:3]):
        y = stats.norm.pdf(x, loc=mu, scale=sigma)
        ax.plot(x, y, c, linewidth=2, label=rf'$\mu={mu},\ \sigma={sigma}$')
    ax.set_xlabel(r'$x$', fontsize=13)
    ax.set_ylabel(r'$f(x)$', fontsize=13)
    ax.set_title(r'正态分布：不同均值 $\mu$（方差固定 $\sigma=1$）', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(os.path.join(OUT_DIR, 'normal_mu.png'))
    plt.close(fig)


# ==================== 6. 正态分布 —— 不同方差 ====================
def plot_normal_sigma():
    sigmas = [0.5, 1.0, 2.0]
    mu = 0.0
    x = np.linspace(-6, 6, 500)

    fig, ax = plt.subplots(figsize=(10, 5))
    for sig, c in zip(sigmas, COLORS[:3]):
        y = stats.norm.pdf(x, loc=mu, scale=sig)
        ax.plot(x, y, c, linewidth=2, label=rf'$\mu={mu},\ \sigma={sig}$')
    ax.set_xlabel(r'$x$', fontsize=13)
    ax.set_ylabel(r'$f(x)$', fontsize=13)
    ax.set_title(r'正态分布：不同标准差 $\sigma$（均值固定 $\mu=0$）', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(os.path.join(OUT_DIR, 'normal_sigma.png'))
    plt.close(fig)


# ==================== 7. 二维正态分布等高线 ====================
def plot_bivariate_normal():
    from scipy.stats import multivariate_normal

    mu = np.array([0.0, 0.0])
    covs = [
        (np.array([[1.0, 0.0], [0.0, 1.0]]), r'$\rho=0$（独立）'),
        (np.array([[1.0, 0.7], [0.7, 1.0]]), r'$\rho=0.7$（正相关）'),
        (np.array([[1.0, -0.7], [-0.7, 1.0]]), r'$\rho=-0.7$（负相关）'),
    ]

    x = np.linspace(-3, 3, 100)
    y = np.linspace(-3, 3, 100)
    X, Y = np.meshgrid(x, y)
    pos = np.dstack((X, Y))

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    for ax, (cov, title), c in zip(axes, covs, COLORS[:3]):
        rv = multivariate_normal(mean=mu, cov=cov)
        Z = rv.pdf(pos)
        cf = ax.contourf(X, Y, Z, levels=15, cmap='YlOrRd', alpha=0.8)
        ax.contour(X, Y, Z, levels=8, colors='white', linewidths=0.5, alpha=0.5)
        ax.set_title(title, fontsize=13)
        ax.set_xlabel(r'$x_1$', fontsize=11)
        ax.set_ylabel(r'$x_2$', fontsize=11)
        ax.set_aspect('equal')
        plt.colorbar(cf, ax=ax, shrink=0.8)

    fig.suptitle(
        r'二维正态分布 $N(\mathbf{0}, \Sigma)$ 的等高线图',
        fontsize=15, y=1.02
    )
    fig.tight_layout()
    fig.savefig(os.path.join(OUT_DIR, 'bivariate_normal.png'))
    plt.close(fig)


# ==================== 主函数 ====================
if __name__ == '__main__':
    plot_binomial()
    plot_poisson()
    plot_uniform()
    plot_exponential()
    plot_normal_mu()
    plot_normal_sigma()
    plot_bivariate_normal()
    print(f"所有图片已生成至: {OUT_DIR}")
