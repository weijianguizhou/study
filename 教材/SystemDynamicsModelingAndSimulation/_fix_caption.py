# -*- coding: utf-8 -*-
import io

p = r'D:\studynotes\教材\SystemDynamicsModelingAndSimulation\3读书笔记——第三章 系统运动微分方程及其数值求解.md'
t = io.open(p, encoding='utf-8').read()

old = '*$y(t) = y_0\\,\\mathrm{e*'
new = '*$y(t) = y_0\\,\\mathrm{e}^{-at}$*'
if old in t:
    t = t.replace(old, new, 1)
    io.open(p, 'w', encoding='utf-8').write(t)
    print('已修复残缺图注')
else:
    print('未找到，逐行检查：')
    for ln in t.split('\n'):
        if 'mathrm{e' in ln and ln.strip().startswith('*'):
            print(repr(ln))
