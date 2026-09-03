# -*- coding: utf-8 -*-
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from matplotlib.transforms import Affine2D

plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei', 'SimSun']
plt.rcParams['axes.unicode_minus'] = False

fig, ax = plt.subplots(figsize=(7.8, 6.4), dpi=150)
ax.set_aspect('equal')
ax.axis('off')
ax.set_xlim(-2.4, 3.4)
ax.set_ylim(-2.5, 2.7)

theta_deg = 42.0
th = np.radians(theta_deg)

# ---- 父刚体 p(i)（蓝色，固定）----
ax.add_patch(patches.Rectangle((0.35, -0.5), 1.7, 1.0,
             edgecolor='#1f77b4', facecolor='#cfe0f0', lw=2, zorder=2))
ax.text(1.2, -0.02, r'体 $p(i)$', ha='center', va='center',
        fontsize=13, color='#1f77b4')
ax.annotate('', xy=(2.45, 0), xytext=(0, 0),
            arrowprops=dict(arrowstyle='-|>', color='#1f77b4', lw=1.6))
ax.text(2.5, 0.10, '参考线', fontsize=11, color='#1f77b4')

# ---- 体 i（红色，绕 O 转 theta_deg）----
rect_i = patches.Rectangle((0.35, -0.5), 1.7, 1.0,
             edgecolor='#d62728', facecolor='#f5c6c6', lw=2)
t = Affine2D().rotate_deg_around(0, 0, theta_deg) + ax.transData
rect_i.set_transform(t)
ax.add_patch(rect_i)
ax.text(1.25*np.cos(th), 1.25*np.sin(th)+0.08, r'体 $i$',
        ha='center', va='center', fontsize=13, color='#d62728', rotation=theta_deg)
xi, yi = 2.45*np.cos(th), 2.45*np.sin(th)
ax.annotate('', xy=(xi, yi), xytext=(0, 0),
            arrowprops=dict(arrowstyle='-|>', color='#d62728', lw=1.6))
ax.text(xi*0.92+0.1, yi*0.92-0.18, '参考线', fontsize=11, color='#d62728')

# ---- 转轴（垂直纸面向外 ⊙）与铰链点 O ----
ax.add_patch(plt.Circle((0, 0), 0.16, fill=False, ec='k', lw=2.0, zorder=5))
ax.plot(0, 0, 'ko', markersize=6, zorder=6)
ax.text(0.22, -0.55, r'$O_i = R_i$（转轴与纸面交点）', fontsize=11, ha='left')
ax.text(0.28, 0.30, r'$\odot\ \boldsymbol{n}_{J_i}$  转轴指向纸外', fontsize=11, ha='left')

# ---- 转角 theta 弧形标注 ----
arc_t = np.linspace(0, th, 60)
r_t = 1.05
ax.plot(r_t*np.cos(arc_t), r_t*np.sin(arc_t), 'k-', lw=1.6)
ax.annotate('', xy=(r_t*np.cos(th*0.5), r_t*np.sin(th*0.5)),
            xytext=(r_t*np.cos(th*0.5-0.04), r_t*np.sin(th*0.5-0.04)),
            arrowprops=dict(arrowstyle='-|>', color='k', lw=1.4))
ax.text(r_t*np.cos(th/2)*1.22, r_t*np.sin(th/2)*1.22,
        r'$\theta_{J_i}$', fontsize=15, ha='center', va='center')

# ---- 角速度 omega 环形箭头（外侧）----
arc_w = np.linspace(0, 0.95*np.pi, 60)
r_w = 1.85
ax.plot(r_w*np.cos(arc_w), r_w*np.sin(arc_w), color='#2ca02c', lw=2.2)
ax.annotate('', xy=(r_w*np.cos(0.5*np.pi*0.95), r_w*np.sin(0.5*np.pi*0.95)),
            xytext=(r_w*np.cos(0.5*np.pi*0.95-0.06), r_w*np.sin(0.5*np.pi*0.95-0.06)),
            arrowprops=dict(arrowstyle='-|>', color='#2ca02c', lw=2.2))
ax.text(0.15, r_w+0.35, r'$\boldsymbol{\omega}_{p(i),i}$  沿转轴，大小 $=\dot\theta_{J_i}$',
        fontsize=11.5, color='#2ca02c', ha='center')

ax.set_title('转动铰元件示意（俯视图，转轴 ⊙ 垂直纸面向外）', fontsize=14)

plt.tight_layout()
plt.savefig(r'D:\studynotes\转动铰元件示意图.png', bbox_inches='tight')
print('saved OK')
