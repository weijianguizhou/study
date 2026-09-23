# -*- coding: utf-8 -*-
"""合成钱学森学院横向组合标识 logo/QXC.png（彩色、透明底）。

素材：
  figure/njust-emblem.png  南京理工大学校徽（自 NJUST.png 裁切）
  figure/院徽.png          学院院徽（院徽条形图 + 钱学森学院 + QIAN XUESEN COLLEGE）

比例参照官方横向组合图 figure/透明logo.png（白色版）：
  校徽高 : 条形图最高柱 : 字标块高 = 71 : 71 : 66
  间隙 = 0.634 * 校徽高（校徽—条形图）、0.155 * 校徽高（条形图—字标）

用法：在本模板根目录执行  python tools/build_logo.py
"""
import os
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FIG = os.path.join(ROOT, 'figure')
OUT = os.path.join(ROOT, 'logo')

E = 240   # 校徽高度（像素）
PAD = 8   # 画布内边距

emblem = Image.open(os.path.join(FIG, 'njust-emblem.png')).convert('RGBA')
emblem = emblem.resize((round(emblem.width * E / emblem.height), E), Image.LANCZOS)

yh = Image.open(os.path.join(FIG, '院徽.png')).convert('RGBA')

barcode = yh.crop((435, 0, 817, 531))                       # 条形图
barcode = barcode.resize((round(barcode.width * E / barcode.height), E), Image.LANCZOS)

wordmark = yh.crop((0, 598, 1159, 986))                     # 字标块
wh_h = round(0.93 * E)
wordmark = wordmark.resize((round(wordmark.width * wh_h / wordmark.height), wh_h), Image.LANCZOS)

gap1 = round(0.634 * E)
gap2 = round(0.155 * E)

W = PAD + emblem.width + gap1 + barcode.width + gap2 + wordmark.width + PAD
H = E + 2 * PAD
canvas = Image.new('RGBA', (W, H), (0, 0, 0, 0))
bottom = PAD + E

x = PAD
canvas.alpha_composite(emblem, (x, bottom - E)); x += emblem.width + gap1
canvas.alpha_composite(barcode, (x, bottom - barcode.height)); x += barcode.width + gap2
canvas.alpha_composite(wordmark, (x, bottom - wh_h))

os.makedirs(OUT, exist_ok=True)
path = os.path.join(OUT, 'QXC.png')
canvas.save(path)
print('saved', path, canvas.size)
