# -*- coding: utf-8 -*-
# 快速验证：垂荡模型 + 问题2(1) 扫阻尼系数求平均功率，与论文 229.6819W/37639 对比
import numpy as np

# 附件4 物理参数
m1 = 4866; m2 = 2433; R = 1.0
rho = 1025; g = 9.8; K = 80000.0
rho_g_A = rho * g * np.pi * R**2

# 问题2 波浪参数 (附件3)
omega = 2.2143; ma = 1165.992; Bv = 167.8395; f = 4890.0


def avg_power_batch(Cvec, t_end=200.0, dt=0.01, w1=100.0, w2=180.0):
    Cvec = np.atleast_1d(Cvec).astype(float)
    N = len(Cvec)
    n = int(round(t_end / dt))
    s = np.zeros((N, 4))
    sum_vr2 = np.zeros(N); cnt = 0
    i0 = int(round(w1/dt)); i1 = int(round(w2/dt))
    for i in range(n):
        ti = i * dt
        x1 = s[:,0]; v1 = s[:,1]; x2 = s[:,2]; v2 = s[:,3]
        vr = v1 - v2
        def rhs(ss, tt):
            xx1=ss[:,0]; vv1=ss[:,1]; xx2=ss[:,2]; vv2=ss[:,3]
            vvr = vv1 - vv2
            c = Cvec
            fd = -c*vvr; fk = -K*(xx1-xx2)
            a1 = (f*np.cos(omega*tt) - Bv*vv1 - rho_g_A*xx1 + fd + fk)/(m1+ma)
            a2 = (-fd-fk)/m2
            return np.stack([vv1,a1,vv2,a2], axis=1)
        k1=rhs(s,ti); k2=rhs(s+0.5*dt*k1,ti+0.5*dt); k3=rhs(s+0.5*dt*k2,ti+0.5*dt); k4=rhs(s+dt*k3,ti+dt)
        s += dt/6*(k1+2*k2+2*k3+k4)
        if i0 <= i <= i1:
            sum_vr2 += vr*vr*dt
            cnt += 1
    dur = (i1-i0)*dt
    P = Cvec * (sum_vr2/dur)
    return P, s


Cvals = np.linspace(5000, 90000, 60)
P, _ = avg_power_batch(Cvals)
k = np.argmax(P)
print("C scan range:", Cvals[0], Cvals[-1])
print("Pmax=", P[k], " C=", Cvals[k])
