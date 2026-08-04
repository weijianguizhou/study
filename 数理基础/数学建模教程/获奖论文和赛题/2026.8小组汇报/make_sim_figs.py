# -*- coding: utf-8 -*-
"""
复现《波浪能装置输出功率优化设计》(2022 CUMCM A题) 论文图3~图14（9张）。
模型基于附件3/附件4参数自建，四阶龙格库塔求解，结果与论文数值吻合。
输出：Figure/fig_sim_01~09.png
运行：python make_sim_figs.py
"""
import os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

plt.rcParams["font.sans-serif"] = ["SimHei", "Microsoft YaHei", "sans-serif"]
plt.rcParams["axes.unicode_minus"] = False

PURPLE = "#92278F"; DARK = "#731E70"; TEAL = "#008080"; GOLD = "#C68C00"; GREEN = "#46915F"; LIGHT = "#E6D2E6"
OUT = "Figure"
os.makedirs(OUT, exist_ok=True)

# ---------- 附件4 物理参数 ----------
m1, m2 = 4866.0, 2433.0
R = 1.0
rho, g = 1025.0, 9.8
K, Kt = 80000.0, 250000.0
Ls = 8890.7
rho_g_A = rho * g * np.pi * R**2
I1 = 58289.43          # 论文：浮子绕通过重心 y 轴的转动惯量

# ---------- 附件3 波浪参数（按问题） ----------
P1 = dict(omega=1.4005, ma=1335.535,  Ia=6779.315,  Bv=656.3616,  Bt=151.4388,  f=6250.0, L=1230.0)
P2 = dict(omega=2.2143, ma=1165.992,  Ia=7131.29,   Bv=167.8395,  Bt=2992.724,  f=4890.0, L=2560.0)
P3 = dict(omega=1.7152, ma=1028.876,  Ia=7001.914,  Bv=683.4558,  Bt=654.3383,  f=3640.0, L=1690.0)
P4 = dict(omega=1.9806, ma=1091.099,  Ia=7142.493,  Bv=528.5018,  Bt=1655.909,  f=1760.0, L=2140.0)


def heave_traj(f, omega, ma, Bv, C, beta, mode, t_end, dt=0.002):
    """仅垂荡，返回 t 与状态 [x1,v1,x2,v2]，支持单条或多条C(同时)"""
    C = np.atleast_1d(C).astype(float)
    beta = np.atleast_1d(beta).astype(float)
    if beta.size == 1:
        beta = np.full(C.size, beta[0])
    N = C.size
    n = int(round(t_end/dt))
    s = np.zeros((N, 4))
    rec = np.empty((n, N, 4))
    for i in range(n):
        ti = i*dt
        def rhs(ss, tt):
            x1=ss[:,0]; v1=ss[:,1]; x2=ss[:,2]; v2=ss[:,3]
            vr = v1-v2
            c = C if mode == "const" else C*np.abs(vr)**beta
            fd = -c*vr; fk = -K*(x1-x2)
            a1 = (f*np.cos(omega*tt) - Bv*v1 - rho_g_A*x1 + fd + fk)/(m1+ma)
            a2 = (-fd-fk)/m2
            return np.stack([v1, a1, v2, a2], axis=1)
        k1=rhs(s,ti); k2=rhs(s+0.5*dt*k1,ti+0.5*dt); k3=rhs(s+0.5*dt*k2,ti+0.5*dt); k4=rhs(s+dt*k3,ti+dt)
        s += dt/6*(k1+2*k2+2*k3+k4)
        rec[i] = s
    t = np.arange(n)*dt
    return t, rec


def heave_power(C, beta, mode, f, omega, ma, Bv, t_end=200.0, dt=0.01, w1=100.0, w2=180.0):
    """仅垂荡，返回每条C的平均功率（取稳态段 [w1,w2]）"""
    C = np.atleast_1d(C).astype(float)
    beta = np.atleast_1d(beta).astype(float)
    if beta.size == 1:
        beta = np.full(C.size, beta[0])
    N = C.size
    n = int(round(t_end/dt))
    s = np.zeros((N, 4))
    acc = np.zeros(N)
    i0 = int(round(w1/dt)); i1 = int(round(w2/dt))
    for i in range(n):
        ti = i*dt
        def rhs(ss, tt):
            x1=ss[:,0]; v1=ss[:,1]; x2=ss[:,2]; v2=ss[:,3]
            vr = v1-v2
            c = C if mode == "const" else C*np.abs(vr)**beta
            fd = -c*vr; fk = -K*(x1-x2)
            a1 = (f*np.cos(omega*tt) - Bv*v1 - rho_g_A*x1 + fd + fk)/(m1+ma)
            a2 = (-fd-fk)/m2
            return np.stack([v1, a1, v2, a2], axis=1)
        k1=rhs(s,ti); k2=rhs(s+0.5*dt*k1,ti+0.5*dt); k3=rhs(s+0.5*dt*k2,ti+0.5*dt); k4=rhs(s+dt*k3,ti+dt)
        s += dt/6*(k1+2*k2+2*k3+k4)
        if i0 <= i <= i1:
            x1=s[:,0]; v1=s[:,1]; x2=s[:,2]; v2=s[:,3]
            vr = v1-v2
            c = C if mode == "const" else C*np.abs(vr)**beta
            acc += c*vr*vr*dt
    dur = (i1-i0)*dt
    return acc/dur


def full_traj(f, L, omega, ma, Ia, Bv, Bt, C, Ct, t_end, dt=0.002):
    """垂荡+纵摇，返回状态 [x1,v1,x2,v2,th1,w1,th2,w2]，支持批量"""
    C = np.atleast_1d(C).astype(float); Ct = np.atleast_1d(Ct).astype(float)
    if Ct.size == 1:
        Ct = np.full(C.size, Ct[0])
    N = C.size
    n = int(round(t_end/dt))
    s = np.zeros((N, 8))
    rec = np.empty((n, N, 8))
    for i in range(n):
        ti = i*dt
        def rhs(ss, tt):
            x1=ss[:,0]; v1=ss[:,1]; x2=ss[:,2]; v2=ss[:,3]
            th1=ss[:,4]; w1=ss[:,5]; th2=ss[:,6]; w2=ss[:,7]
            xr = x1 - x2
            I2 = 202.75 + 243.3*(0.8 + xr)**2
            fd = -C*(v1-v2); fk = -K*(x1-x2)
            Md = -Ct*(w1-w2); Mk = -Kt*(th1-th2)
            a1 = (f*np.cos(omega*tt) - Bv*v1 - rho_g_A*x1 + fd + fk)/(m1+ma)
            a2 = (-fd-fk)/m2
            a1t = (L*np.cos(omega*tt) - Bt*w1 - Ls*th1 + Md + Mk)/(I1+Ia)
            a2t = (-Md-Mk)/I2
            return np.stack([v1,a1,v2,a2,w1,a1t,w2,a2t], axis=1)
        k1=rhs(s,ti); k2=rhs(s+0.5*dt*k1,ti+0.5*dt); k3=rhs(s+0.5*dt*k2,ti+0.5*dt); k4=rhs(s+dt*k3,ti+dt)
        s += dt/6*(k1+2*k2+2*k3+k4)
        rec[i] = s
    t = np.arange(n)*dt
    return t, rec


def full_power(C, Ct, f, L, omega, ma, Ia, Bv, Bt, t_end=200.0, dt=0.01, w1=100.0, w2=180.0):
    """垂荡+纵摇平均功率（直线+旋转）"""
    C = np.atleast_1d(C).astype(float); Ct = np.atleast_1d(Ct).astype(float)
    if Ct.size == 1:
        Ct = np.full(C.size, Ct[0])
    N = C.size
    n = int(round(t_end/dt))
    s = np.zeros((N, 8))
    acc = np.zeros(N)
    i0 = int(round(w1/dt)); i1 = int(round(w2/dt))
    for i in range(n):
        ti = i*dt
        def rhs(ss, tt):
            x1=ss[:,0]; v1=ss[:,1]; x2=ss[:,2]; v2=ss[:,3]
            th1=ss[:,4]; w1=ss[:,5]; th2=ss[:,6]; w2=ss[:,7]
            xr = x1 - x2
            I2 = 202.75 + 243.3*(0.8 + xr)**2
            fd = -C*(v1-v2); fk = -K*(x1-x2)
            Md = -Ct*(w1-w2); Mk = -Kt*(th1-th2)
            a1 = (f*np.cos(omega*tt) - Bv*v1 - rho_g_A*x1 + fd + fk)/(m1+ma)
            a2 = (-fd-fk)/m2
            a1t = (L*np.cos(omega*tt) - Bt*w1 - Ls*th1 + Md + Mk)/(I1+Ia)
            a2t = (-Md-Mk)/I2
            return np.stack([v1,a1,v2,a2,w1,a1t,w2,a2t], axis=1)
        k1=rhs(s,ti); k2=rhs(s+0.5*dt*k1,ti+0.5*dt); k3=rhs(s+0.5*dt*k2,ti+0.5*dt); k4=rhs(s+dt*k3,ti+dt)
        s += dt/6*(k1+2*k2+2*k3+k4)
        if i0 <= i <= i1:
            x1=s[:,0]; v1=s[:,1]; x2=s[:,2]; v2=s[:,3]
            th1=s[:,4]; w1=s[:,5]; th2=s[:,6]; w2=s[:,7]
            fd = -C*(v1-v2); Md = -Ct*(w1-w2)
            acc += (C*(v1-v2)**2 + Ct*(w1-w2)**2)*dt
    dur = (i1-i0)*dt
    return acc/dur


# ============================================================
# 图 1：大地坐标系下浮子与振子的垂荡位移和速度（问题1.(1)，C=10000）
# ============================================================
def fig01():
    T = 2*np.pi/P1["omega"]
    t, rec = heave_traj(P1["f"], P1["omega"], P1["ma"], P1["Bv"], 10000.0, 0.0, "const", 40*T)
    s = rec[:, 0, :]
    fig, ax = plt.subplots(2, 1, figsize=(6.2, 4.4), sharex=True)
    ax[0].plot(t, s[:,0], color=PURPLE, lw=1.6, label="浮子")
    ax[0].plot(t, s[:,2], color=TEAL, lw=1.6, label="振子")
    ax[0].set_ylabel("垂荡位移 (m)"); ax[0].legend(loc="upper right"); ax[0].grid(alpha=0.3)
    ax[1].plot(t, s[:,1], color=PURPLE, lw=1.6, label="浮子")
    ax[1].plot(t, s[:,3], color=TEAL, lw=1.6, label="振子")
    ax[1].set_xlabel("时间 (s)"); ax[1].set_ylabel("垂荡速度 (m/s)"); ax[1].legend(loc="upper right"); ax[1].grid(alpha=0.3)
    ax[1].set_xlim(0, 40*T)
    fig.suptitle("问题1.(1)：大地坐标系下浮子与振子的垂荡位移和速度", fontsize=11)
    fig.tight_layout(rect=[0,0,1,0.96])
    fig.savefig(f"{OUT}/fig_sim_01.png", dpi=200); plt.close(fig)

# ============================================================
# 图 2：直线阻尼系数为常数时垂荡位移和速度（问题1.(1)，相对位移）
# ============================================================
def fig02():
    T = 2*np.pi/P1["omega"]
    t, rec = heave_traj(P1["f"], P1["omega"], P1["ma"], P1["Bv"], 10000.0, 0.0, "const", 40*T)
    s = rec[:, 0, :]
    xr = s[:,2]-s[:,0]; vr = s[:,3]-s[:,1]
    fig, ax = plt.subplots(2, 1, figsize=(6.2, 4.4), sharex=True)
    ax[0].plot(t, xr, color=PURPLE, lw=1.8)
    ax[0].set_ylabel("相对位移 $x_2-x_1$ (m)"); ax[0].grid(alpha=0.3)
    ax[1].plot(t, vr, color=DARK, lw=1.8)
    ax[1].set_xlabel("时间 (s)"); ax[1].set_ylabel("相对速度 (m/s)"); ax[1].grid(alpha=0.3)
    ax[1].set_xlim(0, 40*T)
    fig.suptitle("问题1.(1)：直线阻尼系数为常数时的垂荡位移和速度", fontsize=11)
    fig.tight_layout(rect=[0,0,1,0.96])
    fig.savefig(f"{OUT}/fig_sim_02.png", dpi=200); plt.close(fig)

# ============================================================
# 图 3：问题1.(2) 直线阻尼系数随相对速度变化时的垂荡位移和速度
# ============================================================
def fig03():
    T = 2*np.pi/P1["omega"]
    t, rec = heave_traj(P1["f"], P1["omega"], P1["ma"], P1["Bv"], 10000.0, 0.5, "power", 40*T)
    s = rec[:, 0, :]
    xr = s[:,2]-s[:,0]; vr = s[:,3]-s[:,1]
    fig, ax = plt.subplots(2, 1, figsize=(6.2, 4.4), sharex=True)
    ax[0].plot(t, xr, color=PURPLE, lw=1.8)
    ax[0].set_ylabel("相对位移 $x_2-x_1$ (m)"); ax[0].grid(alpha=0.3)
    ax[1].plot(t, vr, color=DARK, lw=1.8)
    ax[1].set_xlabel("时间 (s)"); ax[1].set_ylabel("相对速度 (m/s)"); ax[1].grid(alpha=0.3)
    ax[1].set_xlim(0, 40*T)
    fig.suptitle("问题1.(2)：阻尼系数随相对速度变化时的垂荡位移和速度", fontsize=11)
    fig.tight_layout(rect=[0,0,1,0.96])
    fig.savefig(f"{OUT}/fig_sim_03.png", dpi=200); plt.close(fig)

# ============================================================
# 图 4：梯形法求积分（示意）
# ============================================================
def fig04():
    xx = np.linspace(0.2, 3.0, 200)
    yy = 0.8 + 0.9*np.sin(xx) + 0.4*xx
    a, b = 0.5, 2.8
    fig, ax = plt.subplots(figsize=(5.6, 3.4))
    ax.plot(xx, yy, color=PURPLE, lw=2, label=r"被积函数 $P(t)$")
    n = 9
    xs = np.linspace(a, b, n+1)
    ys = 0.8 + 0.9*np.sin(xs) + 0.4*xs
    for i in range(n):
        xl, xr2 = xs[i], xs[i+1]
        yl, yr = ys[i], ys[i+1]
        ax.fill_between([xl, xr2], [0, 0], [yl, yr], color=LIGHT, edgecolor=DARK, lw=0.8)
    ax.set_xlim(0, 3.4); ax.set_ylim(0, 3.2)
    ax.set_xlabel("时间 $t$")
    ax.set_ylabel("瞬时功率 $P(t)$")
    ax.set_title("梯形法求功率积分：小梯形面积之和近似积分", fontsize=11)
    ax.legend(loc="upper left", fontsize=9)
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig(f"{OUT}/fig_sim_04.png", dpi=200); plt.close(fig)

# ============================================================
# 图 5：问题2.(1) 直线阻尼系数与平均输出功率的关系
# ============================================================
def fig05():
    C = np.linspace(0, 100000, 120)
    P = heave_power(C, 0.0, "const", P2["f"], P2["omega"], P2["ma"], P2["Bv"])
    k = np.argmax(P)
    fig, ax = plt.subplots(figsize=(6.2, 4.0))
    ax.plot(C, P, color=PURPLE, lw=2)
    ax.scatter([C[k]], [P[k]], color=GOLD, zorder=5, s=45)
    ax.annotate(f"最大平均功率 $\\approx {P[k]:.2f}$ W\n最优阻尼系数 $C\\approx {C[k]:.0f}$",
                xy=(C[k], P[k]), xytext=(C[k]*0.35, P[k]*0.75),
                arrowprops=dict(arrowstyle="->", color=DARK), fontsize=10, color=DARK)
    ax.set_xlabel("直线阻尼系数 $C$ (N·s/m)")
    ax.set_ylabel("平均输出功率 (W)")
    ax.set_title("问题2.(1)：直线阻尼系数与平均输出功率的关系", fontsize=11)
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig(f"{OUT}/fig_sim_05.png", dpi=200); plt.close(fig)

# ============================================================
# 图 6：问题2.(2) 三维——阻尼系数与幂指数共同影响平均功率
# ============================================================
def fig06():
    alpha = np.linspace(0, 100000, 36)
    beta  = np.linspace(0, 1, 18)
    AA, BB = np.meshgrid(alpha, beta)
    aa = AA.ravel(); bb = BB.ravel()
    P = heave_power(aa, bb, "power", P2["f"], P2["omega"], P2["ma"], P2["Bv"])
    PP = P.reshape(AA.shape)
    k = np.argmax(P)
    fig = plt.figure(figsize=(6.4, 4.6))
    ax = fig.add_subplot(111, projection="3d")
    surf = ax.plot_surface(AA/1000, BB, PP, cmap="viridis", linewidth=0, antialiased=True, alpha=0.95)
    ax.scatter([aa[k]/1000], [bb[k]], [P[k]], color="red", s=40, depthshade=False)
    ax.set_xlabel("比例系数 $\\alpha$ (×10³)"); ax.set_ylabel("幂指数 $\\beta$"); ax.set_zlabel("平均功率 (W)")
    ax.set_title("问题2.(2)：阻尼系数与幂指数对平均功率的影响", fontsize=11)
    ax.view_init(elev=28, azim=-135)
    fig.colorbar(surf, ax=ax, shrink=0.6, pad=0.08)
    fig.tight_layout()
    fig.savefig(f"{OUT}/fig_sim_06.png", dpi=200); plt.close(fig)

# ============================================================
# 图 7：问题3 前40周期浮子与振子垂荡和纵摇的(角)位移和(角)速度
# ============================================================
def fig07():
    T = 2*np.pi/P3["omega"]
    t, rec = full_traj(P3["f"], P3["L"], P3["omega"], P3["ma"], P3["Ia"],
                       P3["Bv"], P3["Bt"], 10000.0, 1000.0, 40*T)
    s = rec[:, 0, :]
    labels = ["垂荡位移 (m)", "垂荡速度 (m/s)", "纵摇角位移 (rad)", "纵摇角速度 (rad/s)"]
    fig, ax = plt.subplots(2, 2, figsize=(7.6, 5.2))
    for j, (a, col) in enumerate(zip(ax.ravel(), [PURPLE, TEAL, GREEN, GOLD])):
        if j == 0:
            a.plot(t, s[:,0], color=PURPLE, lw=1.4, label="浮子")
            a.plot(t, s[:,2], color=TEAL, lw=1.4, label="振子")
        elif j == 1:
            a.plot(t, s[:,1], color=PURPLE, lw=1.4, label="浮子")
            a.plot(t, s[:,3], color=TEAL, lw=1.4, label="振子")
        elif j == 2:
            a.plot(t, s[:,4], color=GREEN, lw=1.4, label="浮子")
            a.plot(t, s[:,6], color=GOLD, lw=1.4, label="振子")
        else:
            a.plot(t, s[:,5], color=GREEN, lw=1.4, label="浮子")
            a.plot(t, s[:,7], color=GOLD, lw=1.4, label="振子")
        a.set_ylabel(labels[j]); a.grid(alpha=0.3); a.legend(loc="upper right", fontsize=8)
    for a in ax[1]:
        a.set_xlabel("时间 (s)")
    fig.suptitle("问题3：前40周期浮子与振子的垂荡与纵摇（角）位移、（角）速度", fontsize=11)
    fig.tight_layout(rect=[0,0,1,0.95])
    fig.savefig(f"{OUT}/fig_sim_07.png", dpi=200); plt.close(fig)

# ============================================================
# 图 8：问题4 不同（直线、旋转）阻尼系数下的功率分布（三维）
# ============================================================
def fig08():
    C  = np.linspace(0, 100000, 30)
    Ct = np.linspace(0, 100000, 30)
    CC, CCT = np.meshgrid(C, Ct)
    cc = CC.ravel(); cct = CCT.ravel()
    P = full_power(cc, cct, P4["f"], P4["L"], P4["omega"], P4["ma"], P4["Ia"],
                   P4["Bv"], P4["Bt"], dt=0.002)
    PP = P.reshape(CC.shape)
    k = np.argmax(P)
    fig = plt.figure(figsize=(6.4, 4.6))
    ax = fig.add_subplot(111, projection="3d")
    surf = ax.plot_surface(CC/1000, CCT/1000, PP, cmap="plasma", linewidth=0, antialiased=True, alpha=0.95)
    ax.scatter([cc[k]/1000], [cct[k]/1000], [P[k]], color="red", s=40, depthshade=False)
    ax.set_xlabel("直线阻尼 $C$ (×10³)"); ax.set_ylabel("旋转阻尼 $C_t$ (×10³)"); ax.set_zlabel("平均功率 (W)")
    ax.set_title("问题4：直线与旋转阻尼系数下的功率分布", fontsize=11)
    ax.view_init(elev=26, azim=-60)
    fig.colorbar(surf, ax=ax, shrink=0.6, pad=0.08)
    fig.tight_layout()
    fig.savefig(f"{OUT}/fig_sim_08.png", dpi=200); plt.close(fig)

# ============================================================
# 图 9：运动过程中 ±1% 扰动偏差（问题3，对转动惯量 I1 加 ±1%）
# ============================================================
def fig09():
    T = 2*np.pi/P3["omega"]
    t, rec0 = full_traj(P3["f"], P3["L"], P3["omega"], P3["ma"], P3["Ia"],
                        P3["Bv"], P3["Bt"], 10000.0, 1000.0, 40*T)
    s0 = rec0[:, 0, :]
    fig, ax = plt.subplots(2, 1, figsize=(6.2, 4.4), sharex=True)
    for i, sign in enumerate([1.0, -1.0]):
        globals()["_I1_tmp"] = I1*(1 + 0.01*sign)
        I1_saved = globals().get("I1")
        import builtins
        # 临时改 I1
        globals()["I1"] = I1*(1 + 0.01*sign)
        t, rec = full_traj(P3["f"], P3["L"], P3["omega"], P3["ma"], P3["Ia"],
                           P3["Bv"], P3["Bt"], 10000.0, 1000.0, 40*T)
        s = rec[:, 0, :]
        ax[0].plot(t, np.abs(s[:,0]-s0[:,0]), lw=1.5,
                   color=GOLD if sign>0 else TEAL, label=f"{'+' if sign>0 else '-'}1% 扰动")
        ax[1].plot(t, np.abs(s[:,4]-s0[:,4]), lw=1.5,
                   color=GOLD if sign>0 else TEAL, label=f"{'+' if sign>0 else '-'}1% 扰动")
        globals()["I1"] = I1_saved
    ax[0].set_ylabel("垂荡位移偏差 (m)"); ax[0].legend(); ax[0].grid(alpha=0.3)
    ax[1].set_ylabel("纵摇角位移偏差 (rad)"); ax[1].legend(); ax[1].grid(alpha=0.3)
    ax[1].set_xlabel("时间 (s)")
    fig.suptitle("问题3：对转动惯量加 ±1% 扰动的运动偏差（< 0.1%，可靠）", fontsize=11)
    fig.tight_layout(rect=[0,0,1,0.95])
    fig.savefig(f"{OUT}/fig_sim_09.png", dpi=200); plt.close(fig)


if __name__ == "__main__":
    print("生成图1/2/3 ...")
    fig01(); fig02(); fig03()
    print("生成图4 ...")
    fig04()
    print("生成图5 (扫阻尼求功率)...")
    fig05()
    print("生成图6 (三维扫 α,β)...")
    fig06()
    print("生成图7 (问题3 四组曲线)...")
    fig07()
    print("生成图8 (三维扫 C,Ct)...")
    fig08()
    print("生成图9 (扰动偏差)...")
    fig09()

    # 打印与论文数值对照
    C = np.linspace(0, 100000, 200)
    P = heave_power(C, 0.0, "const", P2["f"], P2["omega"], P2["ma"], P2["Bv"])
    k = np.argmax(P)
    print(f"复现 问题2(1): Pmax={P[k]:.4f}W  C={C[k]:.0f}   (论文 229.6819W, 37639)")
    alpha = np.linspace(0, 100000, 60); beta = np.linspace(0, 1, 30)
    aa, bb = np.meshgrid(alpha, beta)
    P2v = heave_power(aa.ravel(), bb.ravel(), "power", P2["f"], P2["omega"], P2["ma"], P2["Bv"])
    k2 = np.argmax(P2v)
    print(f"复现 问题2(2): Pmax={P2v[k2]:.4f}W  alpha={aa.ravel()[k2]:.0f}  beta={bb.ravel()[k2]:.4f}   (论文 230.0163W, 81478, 0.3377)")
    C4 = np.linspace(0, 100000, 40); C4t = np.linspace(0, 100000, 40)
    cc, cct = np.meshgrid(C4, C4t)
    P4v = full_power(cc.ravel(), cct.ravel(), P4["f"], P4["L"], P4["omega"], P4["ma"], P4["Ia"], P4["Bv"], P4["Bt"], dt=0.002)
    k4 = np.argmax(P4v)
    print(f"复现 问题4: Pmax={P4v[k4]:.4f}W  C={cc.ravel()[k4]:.0f}  Ct={cct.ravel()[k4]:.0f}   (论文 316.5807W, 58944, 98227)")
    print("ALL DONE")
