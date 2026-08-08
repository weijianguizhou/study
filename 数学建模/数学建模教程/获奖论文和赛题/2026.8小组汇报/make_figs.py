# -*- coding: utf-8 -*-
"""
为《波浪能装置输出功率优化设计》赏析 PPT 生成示意图（matplotlib）。
说明：图均为"原理示意/定性演示"，非论文原始数据，仅用于汇报讲解。
运行：python make_figs.py   （输出到 Figure/ 目录）
"""
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

plt.rcParams["font.sans-serif"] = ["SimHei", "Microsoft YaHei", "sans-serif"]
plt.rcParams["axes.unicode_minus"] = False

PURPLE = "#92278F"
DARK   = "#731E70"
LIGHT  = "#E6D2E6"
TEAL   = "#008080"
GOLD   = "#C68C00"
OUT    = "Figure"

# ---------------------------------------------------------------
# 图 1：四阶龙格库塔（RK4）一步斜率示意
# ---------------------------------------------------------------
def fig_rk4():
    # 用一条解析曲线 y(t) = 1 - exp(-t) 演示"沿曲线取四个斜率"
    tt = np.linspace(0, 1.8, 200)
    y  = 1 - np.exp(-tt)

    h  = 0.62
    t0 = 0.28
    y0 = 1 - np.exp(-t0)
    k1 = np.exp(-t0)                      # 起点斜率
    k2 = np.exp(-(t0 + h/2))              # 中点斜率(欧拉预测)
    k4 = np.exp(-(t0 + h))                # 终点斜率

    fig, ax = plt.subplots(figsize=(5.6, 3.4))
    ax.plot(tt, y, color=PURPLE, lw=2.5, label=r"精确解 $y(t)$")
    ax.axvline(t0, ls="--", color="gray", lw=1)
    ax.axvline(t0 + h, ls="--", color="gray", lw=1)

    ax.annotate("", xy=(t0 + h, y0 + k1*h), xytext=(t0, y0),
                arrowprops=dict(arrowstyle="-|>", color=TEAL, lw=2))
    ax.annotate("", xy=(t0 + h, y0 + k2*h), xytext=(t0, y0),
                arrowprops=dict(arrowstyle="-|>", color=GOLD, lw=2))
    ax.annotate("", xy=(t0 + h, y0 + k4*h), xytext=(t0, y0),
                arrowprops=dict(arrowstyle="-|>", color=DARK, lw=2))

    ax.text(t0 + h*0.13, y0 + k1*h + 0.035, "$k_1$", color=TEAL, fontsize=11)
    ax.text(t0 + h*0.13, y0 + k2*h + 0.035, "$k_2$", color=GOLD, fontsize=11)
    ax.text(t0 + h*0.13, y0 + k4*h + 0.035, "$k_4$", color=DARK, fontsize=11)

    ax.scatter([t0], [y0], color=DARK, zorder=5, s=28)
    ax.text(t0, y0 - 0.10, "当前点 $y_n$", fontsize=10)
    ax.set_xlabel("时间 $t$")
    ax.set_ylabel("$y$")
    ax.set_title("四阶龙格库塔：一个步长内取多个斜率加权平均", fontsize=11)
    ax.legend(loc="lower right", fontsize=9)
    ax.set_xlim(0, 1.8); ax.set_ylim(0, 1.15)
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig(f"{OUT}/fig_rk4.png", dpi=200)
    plt.close(fig)

# ---------------------------------------------------------------
# 图 2：受迫振动——稳定后振动周期≈波浪激励周期（周期检验依据）
# ---------------------------------------------------------------
def fig_forced():
    # m y'' + c y' + k y = F cos(w t)，用 RK4 定性演示
    def forced(m, c, k, F, w, t0, t1, dt):
        n  = int((t1 - t0)/dt)
        t  = np.linspace(t0, t1, n)
        y  = np.zeros(n); v = np.zeros(n)
        for i in range(n-1):
            def d(yy, vv, ti):
                a = (F*np.cos(w*ti) - c*vv - k*yy)/m
                return vv, a
            k1v, k1a = d(y[i], v[i], t[i])
            k2v, k2a = d(y[i]+dt/2*k1v, v[i]+dt/2*k1a, t[i]+dt/2)
            k3v, k3a = d(y[i]+dt/2*k2v, v[i]+dt/2*k2a, t[i]+dt/2)
            k4v, k4a = d(y[i]+dt*k3v,  v[i]+dt*k3a,  t[i]+dt)
            y[i+1] = y[i] + dt/6*(k1v + 2*k2v + 2*k3v + k4v)
            v[i+1] = v[i] + dt/6*(k1a + 2*k2a + 2*k3a + k4a)
        return t, y, v

    m, c, k, F, w = 1.0, 0.25, 4.0, 1.0, 2.0   # 激励周期 T=pi≈3.14
    t, y, v = forced(m, c, k, F, w, 0.0, 20.0, 0.001)

    # 稳态段拟合一个周期：取后半段峰值间隔近似
    steady = y[t > 10.0]
    ts     = t[t > 10.0]
    pk     = ts[1:-1][(steady[1:-1] > steady[:-2]) & (steady[1:-1] > steady[2:])]
    T_est  = float(np.mean(np.diff(pk))) if len(pk) > 1 else np.nan

    fig, ax = plt.subplots(figsize=(5.6, 3.4))
    ax.plot(t, y, color=PURPLE, lw=2, label="位移 $y(t)$")
    ax.axvspan(0, 10, color=LIGHT, alpha=0.5)
    ax.text(5, 1.28, "瞬态段", ha="center", fontsize=10)
    ax.text(15, 1.28, "稳态段", ha="center", fontsize=10)
    ax.plot([t[0], t[-1]], [1.25, 1.25], color=DARK, lw=1.4)
    ax.plot([0, 0], [0, 1.25], color=DARK, lw=1.4)
    if not np.isnan(T_est):
        ax.text(0.2, 1.42, f"稳态周期 $\\approx$ {T_est:.2f}s ≈ 激励周期 $2\\pi/\\omega={2*np.pi/w:.2f}$s",
                fontsize=10, color=DARK)
    ax.set_xlabel("时间 $t$ (s)")
    ax.set_ylabel("位移 (m)")
    ax.set_title("受迫振动：稳定后周期与波浪激励周期一致（检验依据，示意图）", fontsize=10.5)
    ax.legend(loc="lower right", fontsize=9)
    ax.set_ylim(-1.5, 1.6)
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig(f"{OUT}/fig_forced.png", dpi=200)
    plt.close(fig)

# ---------------------------------------------------------------
# 图 3：±1% 参数扰动下的结果相对偏差（可靠性检验，示意图）
# ---------------------------------------------------------------
def fig_perturb():
    items = ["浮子位移", "振子位移", "浮子角位移", "振子角位移", "最大输出功率"]
    dev   = [0.062, 0.084, 0.038, 0.051, 0.093]   # 示意值，均 < 0.1%
    colors = [PURPLE, PURPLE, PURPLE, PURPLE, TEAL]

    fig, ax = plt.subplots(figsize=(5.6, 3.2))
    bars = ax.bar(range(len(items)), dev, color=colors, width=0.55)
    ax.axhline(0.10, color="red", ls="--", lw=1.6)
    ax.text(4.35, 0.115, "0.10% 阈值", color="red", fontsize=10, ha="right")
    ax.axhline(0.0, color="black", lw=0.8)
    for b, v in zip(bars, dev):
        ax.text(b.get_x() + b.get_width()/2, v + 0.004, f"{v:.3f}%",
                ha="center", fontsize=9)
    ax.set_xticks(range(len(items)))
    ax.set_xticklabels(items, fontsize=9)
    ax.set_ylabel("相对偏差 (%)")
    ax.set_title("对问题三参数加 ±1% 扰动：结果偏差均 < 0.1%（示意图）", fontsize=10.5)
    ax.set_ylim(0, 0.14)
    ax.grid(axis="y", alpha=0.3)
    fig.tight_layout()
    fig.savefig(f"{OUT}/fig_perturb.png", dpi=200)
    plt.close(fig)

if __name__ == "__main__":
    import os
    os.makedirs(OUT, exist_ok=True)
    fig_rk4()
    fig_forced()
    fig_perturb()
    print("figures generated ->", OUT)
