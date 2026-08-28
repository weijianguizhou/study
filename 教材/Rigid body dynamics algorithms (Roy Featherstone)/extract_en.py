import re, os
import fitz

SRC = 'Rigid body dynamics algorithms (Roy Featherstone).pdf'
OUT = 'english'
os.makedirs(OUT, exist_ok=True)

doc = fitz.open(SRC)

# 书页N -> pdf索引 N+7 （已验证）
UNITS = [
    ('frontmatter', 3, 5),
    ('ch01', 8, 14), ('ch02', 14, 46), ('ch03', 46, 72), ('ch04', 72, 96),
    ('ch05', 96, 108), ('ch06', 108, 126), ('ch07', 126, 148), ('ch08', 148, 178),
    ('ch09', 178, 202), ('ch10', 202, 220), ('ch11', 220, 248),
    ('appA', 248, 264), ('bib', 264, 272), ('symbols', 272, 274),
]
CHAPTER_TITLES = {
    'ch01': 'Introduction',
    'ch02': 'Spatial Vector Algebra',
    'ch03': 'Dynamics of Rigid Body Systems',
    'ch04': 'Modelling Rigid Body Systems',
    'ch05': 'Inverse Dynamics',
    'ch06': 'Forward Dynamics --- Inertia Matrix Methods',
    'ch07': 'Forward Dynamics --- Propagation Methods',
    'ch08': 'Closed Loop Systems',
    'ch09': 'Hybrid Dynamics and Other Topics',
    'ch10': 'Accuracy and Efficiency',
    'ch11': 'Contact and Impact',
}

SEC = re.compile(r'^\s*(\d+)\.(\d+)\s+[A-Z]')                        # 节标题
EXER = re.compile(r'^\s*Exercise\s+(\d+)~?(\d+)')

CHARMAP = {
    '\ufb01': 'fi', '\ufb02': 'fl', '\ufb00': 'ff', '\ufb03': 'ffi', '\ufb04': 'ffl',
}
# 去除私有区大括号拼接件
PUA = re.compile(r'[\ue000-\uf8ff]')

def get_lines(pno):
    page = doc[pno]
    h = page.rect.height
    out = []
    d = page.get_text('dict')
    for blk in d['blocks']:
        if blk.get('type') != 0:
            continue
        for ln in blk['lines']:
            y0 = ln['bbox'][1]
            if y0 < 52:                     # 页眉带
                continue
            s = ''.join(sp['text'] for sp in ln['spans']).rstrip()
            if not s.strip():
                continue
            for k, v in CHARMAP.items():
                s = s.replace(k, v)
            s = PUA.sub('', s)
            out.append(s)
    out.append('')
    return out

def clean_join(lines):
    """合并断词、拼段落；返回块列表 [(kind, text)]"""
    blocks = []
    buf = []
    def flush():
        if not buf:
            return
        t = ' '.join(buf)
        t = re.sub(r'(\w)- (\w)', r'\1\2', t)      # 断词连字符
        t = re.sub(r'\s+', ' ', t).strip()
        blocks.append(('p', t))
        buf.clear()
    for ln in lines:
        if ln == '':
            flush()
            continue
        buf.append(ln.strip())
    flush()
    return blocks

def render(start, end):
    lines = []
    for p in range(start, end):
        lines.extend(get_lines(p))
        lines.append('')
    return clean_join(lines)

def esc(t):
    t = t.replace('\\', r'\textbackslash{}')
    for c, r in [('&', r'\&'), ('%', r'\%'), ('#', r'\#'), ('_', r'\_'),
                 ('$', r'\$'), ('{', r'\{'), ('}', r'\}'), ('^', r'\^{}'), ('~', r'\textasciitilde{}')]:
        t = t.replace(c, r)
    return t

for name, start, end in UNITS:
    blocks = render(start, end)
    parts = []
    if name == 'frontmatter':
        parts.append(r'\chapter*{Preface}')
        parts.append(r'\addcontentsline{toc}{chapter}{Preface}')
    elif name.startswith('ch'):
        n = int(name[2:])
        parts.append(r'\chapter{%s}' % esc(CHAPTER_TITLES[name]))
        parts.append(r'\label{chap:%d}' % n)
    elif name == 'appA':
        parts.append(r'\appendix')
        parts.append(r'\chapter{Spatial Vector Arithmetic}')
    elif name == 'bib':
        parts.append(r'\chapter*{Bibliography}')
        parts.append(r'\addcontentsline{toc}{chapter}{Bibliography}')
    elif name == 'symbols':
        parts.append(r'\chapter*{Symbols}')

    i = 0
    while i < len(blocks):
        kind, t = blocks[i]
        m_sec = SEC.match(t) if kind == 'p' else None
        if m_sec:
            num, title = '%s.%s' % (m_sec.group(1), m_sec.group(2)), t[m_sec.end():].strip()
            depth = r'\section'
            if num.count('.') >= 2:
                depth = r'\subsection'
                num = t.split()[0]
                title = t[len(num):].strip()
            parts.append('%s{%s}' % (depth, esc(title)))
            parts.append(r'\label{sec:%s}' % num)
            i += 1
            continue
        me = EXER.match(t)
        if me:
            parts.append(r'\medskip\noindent\textbf{Exercise %s.%s} ' % (me.group(1), me.group(2)) + esc(t[me.end():]).strip())
            parts.append('')
            i += 1
            continue
        # 图表标题
        mf = re.match(r'^(Figure|Table)\s+(\d+(?:\.\d+)?)[:.]?\s*', t)
        if mf:
            label = mf.group(1).lower()
            cap = esc(t[mf.end():])
            env = 'figure' if label == 'figure' else 'table'
            parts.append(r'\begin{%s}[ht]\centering' % env)
            parts.append((r'\caption{%s}' % cap))
            parts.append(r'\label{%s:%s}' % (label, mf.group(2)))
            parts.append(r'\end{%s}' % env)
            i += 1
            continue
        parts.append(esc(t))
        parts.append('')
        i += 1
    fn = os.path.join(OUT, name + '.tex')
    with open(fn, 'w', encoding='utf-8') as f:
        f.write('\n'.join(parts).rstrip() + '\n')
    print(fn, len(blocks), 'blocks')
print('done')
