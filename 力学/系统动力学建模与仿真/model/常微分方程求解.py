import matplotlib.pyplot as plt
import numpy as np
plt.rcParams["font.family"] = ["Microsoft YaHei"]  # 微软雅黑，Windows 自带
plt.rcParams["axes.unicode_minus"] = False         # 负号正常显示

def ode_func(t,y,a):
    return -a*y

def analytical_solution(t,a,y0):
    return np.exp(-a*t)*y0

def euler_solve(a,dt,t_max,y0):
    t=0.0
    y=y0
    t_list=[t]
    y_list=[y]
    while t<t_max:
        t+=dt
        y+=dt*ode_func(t,y,a)
        t_list.append(t)
        y_list.append(y)
    return t_list,y_list

a=1
y0=8
t_max=10*a
dt_list=[0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40,0.45,0.50]
colors = ['#0000ff', '#3366ff', '#6699ff', '#66cccc', '#66ff99', '#99cc66', '#cc9966', '#ff3333','#ff9933','#ffcc33']

plt.figure(figsize=(10, 6))

# 解析解
t_analy = np.linspace(0, t_max, 200)
y_analy = analytical_solution(t_analy, a, y0)
plt.plot(t_analy, y_analy, 'k-', linewidth=3, label='解析解')

# 多个步长的数值解
for dt, c in zip(dt_list, colors):
    t_num, y_num = euler_solve(a, dt, t_max, y0)
    plt.plot(t_num, y_num, color=c, linewidth=2, label=f'Δt={dt}')

plt.xlabel('时间 t', fontsize=14)
plt.ylabel('y(t)', fontsize=14)
plt.title('显式欧拉法求解 dy/dt = -a y (不同步长对比)', fontsize=16)
plt.legend(loc='center left', bbox_to_anchor=(1, 0.5))
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()

   
