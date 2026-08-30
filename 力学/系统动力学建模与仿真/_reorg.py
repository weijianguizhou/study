# -*- coding: utf-8 -*-
"""按 SystemDynamicsModelingAndSimulation.pdf 的章节结构，重组现有读书笔记。
拆分/合并策略（忠实于 PDF 的 11 章，跳第十一章）：
  绪论       <- 第一章 绪论.md
  一 有限维广义变分原理  <- 第五章 有限维广义变分原理 + 数学基础(代数基础,并矢)
  二 多体系统拉格朗日方程 <- 第六章 多体系统的拉格朗日方程 + 第四章 拉格朗日力学基础
  三 系统运动微分方程及其数值求解 <- 第七章 系统运动微分方程 + 数学基础(系统动力学方程数值求解)
  四 笛卡尔张量          <- 数学基础(笛卡尔张量)
  五 坐标系的相对方位     <- 运动学基础(方向余弦)
  六 相对转动角速度       <- 运动学基础(角速度*)
  七 坐标系的姿态广义坐标  <- 运动学基础(转轴和转角/欧拉参数/欧拉角/其余)
  八/九/十               <- 同名不变（仅修正 H1）
"""
import re, os, glob

D = r"D:\studynotes\教材\SystemDynamicsModelingAndSimulation"

ZH = {1:"一",2:"二",3:"三",4:"四",5:"五",6:"六",7:"七",8:"八",9:"九",10:"十"}

# 目标章: (编号中文, 标题, 输出文件名)
TARGETS = {
    'xu': ('',   '绪论',                                   '读书笔记——绪论.md'),
    'c1': ('一','有限维广义变分原理',                       '读书笔记——第一章 有限维广义变分原理.md'),
    'c2': ('二','多体系统拉格朗日方程',                     '读书笔记——第二章 多体系统拉格朗日方程.md'),
    'c3': ('三','系统运动微分方程及其数值求解',             '读书笔记——第三章 系统运动微分方程及其数值求解.md'),
    'c4': ('四','笛卡尔张量',                               '读书笔记——第四章 笛卡尔张量.md'),
    'c5': ('五','坐标系的相对方位',                         '读书笔记——第五章 坐标系的相对方位.md'),
    'c6': ('六','相对转动角速度',                           '读书笔记——第六章 相对转动角速度.md'),
    'c7': ('七','坐标系的姿态广义坐标',                     '读书笔记——第七章 坐标系的姿态广义坐标.md'),
    'c8': ('八','空间运动刚体的动能与势能',                 '读书笔记——第八章 空间运动刚体的动能与势能.md'),
    'c9': ('九','体元件广义坐标与系统总体动力学方程',       '读书笔记——第九章 体元件广义坐标与系统总体动力学方程.md'),
    'c10':('十','多刚体系统运动学方程递推形式',             '读书笔记——第十章 多刚体系统运动学方程递推形式.md'),
}

def load(fn):
    return open(os.path.join(D, fn), encoding='utf-8').read()

def split_note(text):
    m = re.search(r'^#\s+.*$', text, re.M)
    h1 = m.group(0).strip() if m else ''
    rest = text[m.end():] if m else text
    parts = re.split(r'(?m)^##\s+', rest)
    preamble = parts[0].strip('\n')
    secs = []
    for p in parts[1:]:
        nl = p.find('\n')
        title = p[:nl].strip()
        body = p[nl+1:].strip('\n')
        secs.append((title, body))
    return h1, preamble, secs

def secs_dict(secs):
    return {t: b for t, b in secs}

def join_sections(blocks):
    """blocks: list of (title, body) or ('', body) for preamble."""
    out = []
    for title, body in blocks:
        if title:
            out.append('## ' + title)
        if body:
            out.append(body)
    txt = '\n\n'.join(out).strip('\n') + '\n'
    txt = re.sub(r'\n{3,}', '\n\n', txt)
    return txt

# ---- 载入源 ----
math_h1, math_pre, math_secs = split_note(load('读书笔记——第二章 数学基础.md'))
kin_h1,  kin_pre,  kin_secs  = split_note(load('读书笔记——第三章 运动学基础.md'))
var_h1,  var_pre,  var_secs  = split_note(load('读书笔记——第五章 有限维广义变分原理.md'))
lag_h1,  lag_pre,  lag_secs  = split_note(load('读书笔记——第四章 拉格朗日力学基础.md'))
mbl_h1,  mbl_pre,  mbl_secs  = split_note(load('读书笔记——第六章 多体系统的拉格朗日方程.md'))
sde_h1,  sde_pre,  sde_secs  = split_note(load('读书笔记——第七章 系统运动微分方程.md'))

math = secs_dict(math_secs)
kin  = secs_dict(kin_secs)

# 运动学基础 按 PDF 归类
kin_ch5 = ['方向余弦']
kin_ch6 = ['角速度矩阵','角速度矢量','角速度分量','角速度与欧拉参数','辅助参考系',
           '角速度与方向角','缓慢小转动','瞬时轴','角加速度','偏角速度与偏速度']
kin_ch7 = ['转轴和转角','欧拉参数','欧拉角','坐标系姿态广义坐标的其他形式',
           '相继转动','间接定向法','小角度旋转','螺旋运动']

def blk(d, keys):
    return [(k, d[k]) for k in keys if k in d]

# ---- 组装各目标章 ----
content = {}

# 绪论
xu_text = load('读书笔记——第一章 绪论.md')
xu_text = re.sub(r'^#\s+.*$', '# 绪论', xu_text, count=1, flags=re.M)
content['xu'] = xu_text.strip('\n') + '\n'

# 一：有限维广义变分原理 + 数学基础(代数基础,并矢)
blocks_c1 = []
if math_pre: blocks_c1.append(('', math_pre))
blocks_c1 += blk(math, ['代数基础','并矢'])
blocks_c1 += var_secs
content['c1'] = '# 第一章 有限维广义变分原理\n\n' + join_sections(blocks_c1)

# 二：多体系统的拉格朗日方程 + 拉格朗日力学基础
blocks_c2 = mbl_secs + lag_secs
content['c2'] = '# 第二章 多体系统拉格朗日方程\n\n' + join_sections(blocks_c2)

# 三：系统运动微分方程 + 数学基础(系统动力学方程数值求解)
blocks_c3 = sde_secs + blk(math, ['系统动力学方程数值求解'])
content['c3'] = '# 第三章 系统运动微分方程及其数值求解\n\n' + join_sections(blocks_c3)

# 四：笛卡尔张量
content['c4'] = '# 第四章 笛卡尔张量\n\n' + join_sections(blk(math, ['笛卡尔张量']))

# 五：坐标系的相对方位
content['c5'] = '# 第五章 坐标系的相对方位\n\n' + join_sections(blk(kin, kin_ch5))

# 六：相对转动角速度
content['c6'] = '# 第六章 相对转动角速度\n\n' + join_sections(blk(kin, kin_ch6))

# 七：坐标系的姿态广义坐标
content['c7'] = '# 第七章 坐标系的姿态广义坐标\n\n' + join_sections(blk(kin, kin_ch7))

# 八/九：不变
content['c8'] = load('读书笔记——第八章 空间运动刚体的动能与势能.md').strip('\n') + '\n'
content['c9'] = load('读书笔记——第九章 体元件广义坐标与系统总体动力学方程.md').strip('\n') + '\n'

# 十：仅修正 H1
c10 = load('读书笔记——第十章 多刚体系统运动学方程递推形式.md')
c10 = re.sub(r'^#\s+.*$', '# 第十章 多刚体系统运动学方程递推形式', c10, count=1, flags=re.M)
content['c10'] = c10.strip('\n') + '\n'

# ---- 写出 ----
for key, (_, _, fn) in TARGETS.items():
    if key not in content: 
        continue
    path = os.path.join(D, fn)
    open(path, 'w', encoding='utf-8').write(content[key])
    print('写出 %-48s %6d 行' % (fn, content[key].count('\n')+1))

print('\n完成。待删除的旧文件：')
for old in ['读书笔记——第一章 绪论.md','读书笔记——第二章 数学基础.md',
            '读书笔记——第三章 运动学基础.md','读书笔记——第四章 拉格朗日力学基础.md',
            '读书笔记——第五章 有限维广义变分原理.md','读书笔记——第六章 多体系统的拉格朗日方程.md',
            '读书笔记——第七章 系统运动微分方程.md']:
    print('  ', old, '存在' if os.path.exists(os.path.join(D, old)) else 'MISSING')
