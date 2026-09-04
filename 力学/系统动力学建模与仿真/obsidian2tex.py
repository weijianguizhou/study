# -*- coding: utf-8 -*-
"""
将《系统动力学建模与仿真》各章 Obsidian 读书笔记 md 转换回 tex 章节正文。
与 tex2obsidian.py 互逆：
  - 章节：# 章标题(丢弃,主文件负责 \chapter) / ## \section / ### \subsection / #### \parahead
  - 数学：$...$ 行内保留，$$...$$ 独立公式 → \[...\]
  - callout：> [!type] → 对应 tcolorbox / amsthm 环境（支持一层嵌套）
  - 图片：![[name.png]] → center + includegraphics（含图注 *...* 行）
  - 表格：| a | b | → tabular（callout 内不带浮动包装）
  - 列表：- / 1. → itemize / enumerate
"""
import re
import os
import sys

SRC_DIR = r"D:\studynotes\教材\SystemDynamicsModelingAndSimulation"
OUT_DIR = r"D:\studynotes\力学\系统动力学建模与仿真"
FIG_DIR = os.path.join(OUT_DIR, "Figure")

# (md 文件名, 输出 tex 文件名)
CHAPTERS = [
    ("1读书笔记——第一章 有限维广义变分原理.md", "有限维广义变分原理.tex"),
    ("2读书笔记——第二章 多体系统拉格朗日方程.md", "多体系统的拉格朗日方程.tex"),
    ("3读书笔记——第三章 系统运动微分方程及其数值求解.md", "系统运动微分方程及其数值求解.tex"),
    ("4读书笔记——第四章 笛卡尔张量.md", "笛卡尔张量.tex"),
    ("5读书笔记——第五章 坐标系的相对方位.md", "坐标系的相对方位.tex"),
    ("6读书笔记——第六章 相对转动角速度.md", "相对转动角速度.tex"),
    ("7读书笔记——第七章 坐标系的姿态广义坐标.md", "坐标系的姿态广义坐标.tex"),
    ("8读书笔记——第八章 空间运动刚体的动能与势能.md", "空间运动刚体的动能与势能.tex"),
    ("9读书笔记——第九章 体元件广义坐标与系统总体动力学方程.md", "体元件广义坐标与系统总体动力学方程.tex"),
    ("10读书笔记——第十章 多刚体系统运动学方程递推形式.md", "多刚体系统运动学方程递推形式.tex"),
    ("11读书笔记——多刚体系统拉格朗日方程递推形式.md", "多刚体系统拉格朗日方程递推形式.tex"),
]

# callout 类型 → (tex 环境, 是否带可选标题)
CALLOUT_MAP = {
    'theorem':    ('theorem',    True),
    'definition': ('definition', True),
    'example':    ('example',    True),
    'abstract':   ('conclusion', True),
    'info':       ('note',       False),
    'success':    ('solution',   False),
    'note':       ('note',       False),
    'important':  ('keybox',     True),
    'tip':        ('tipbox',     True),
    'warning':    ('warnbox',    True),
    'quote':      ('proof',      True),
}


def strip_math(text, maths):
    """把 $...$ 与 $$...$$ 暂时藏起，返回带占位符的文本。"""
    def stash(m):
        maths.append(m.group(0))
        return '\x00M%d\x00' % (len(maths) - 1)
    text = re.sub(r'\$\$.*?\$\$', stash, text, flags=re.S)
    text = re.sub(r'\$(?!\$)((?:\\\$|[^$])*?)\$(?!\$)', stash, text)
    return text


def restore_math(text, maths):
    return re.sub(r'\x00M(\d+)\x00', lambda m: maths[int(m.group(1))], text)


def escape_text(text):
    """转义公式外的 LaTeX 特殊字符。"""
    maths = []
    text = strip_math(text, maths)
    # markdown 强调
    text = re.sub(r'\*\*(.+?)\*\*', r'\\textbf{\1}', text)
    text = re.sub(r'(?<!\*)\*(?!\*)([^*]+?)\*(?!\*)', r'\\emph{\1}', text)
    text = re.sub(r'==(.+?)==', r'\\uline{\1}', text)
    text = re.sub(r'`([^`]+?)`', r'\\texttt{\1}', text)
    # 特殊字符（不破坏已存在的 LaTeX 命令——反斜杠后跟字母的序列）
    text = re.sub(r'(?<!\\)&', r'\\&', text)
    text = re.sub(r'(?<!\\)%', r'\\%', text)
    text = re.sub(r'(?<!\\)#', r'\\#', text)
    text = re.sub(r'(?<!\\)_', r'\\_', text)
    text = re.sub(r'(?<!\\)\$', r'\\$', text)
    text = restore_math(text, maths)
    return text


def fig_width(path):
    try:
        from PIL import Image
        im = Image.open(path)
        w, h = im.size
        return 0.8 if w >= h else 0.55
    except Exception:
        return 0.8


def img_basename(name):
    """![[path/to/x.png||3000]] → x.png"""
    name = name.strip()
    if '||' in name:
        name = name.split('||')[0]
    base = os.path.basename(name.replace('\\', '/'))
    return base


def convert_figure_line(line, caption=None):
    """![[x.png]] → center + includegraphics"""
    m = re.search(r'!\[\[([^\]]+)\]\]', line)
    if not m:
        return None
    base = img_basename(m.group(1))
    path = os.path.join(FIG_DIR, base)
    w = fig_width(path)
    out = ['\\begin{center}', '\\includegraphics[width=%.2f\\textwidth]{Figure/%s}' % (w, base)]
    if caption:
        out.append('\\par\\vspace{0.2em}{\\small\\kaishu %s}' % caption)
    out.append('\\end{center}')
    return '\n'.join(out)


def convert_table(rows, indent=''):
    """md 表格行列表 → tabular"""
    if not rows:
        return ''
    header = rows[0]
    body = rows[1:]
    # 跳过分隔行 |---|
    body = [r for r in body if not re.match(r'^\s*\|[\s:|-]+\|\s*$', r)]
    ncols = max(len(r.split('|')) - 2 for r in [header] + body)
    colfmt = 'l' * ncols
    def cells(row):
        parts = row.split('|')
        cells_ = [p.strip() for p in parts[1:-1]]
        while len(cells_) < ncols:
            cells_.append('')
        return cells_
    lines = ['\\begin{tabular}{%s}' % colfmt, '\\toprule']
    lines.append(' & '.join(escape_text(c) for c in cells(header)) + ' \\\\')
    lines.append('\\midrule')
    for r in body:
        lines.append(' & '.join(escape_text(c) for c in cells(r)) + ' \\\\')
    lines.append('\\bottomrule')
    lines.append('\\end{tabular}')
    return '\n'.join(indent + l for l in lines)


# ---------------- callout 解析 ----------------

def parse_callouts(lines):
    """把行列表解析为块树。

    返回 (blocks, rest_lines)。block = dict(type, ctype, title, lines, children)
    解析规则：以 '> ' 开头的行为 callout 区；'[!type]' 行开启 callout。
    前缀深度：'> ' =1, '> > ' =2（仅支持两层嵌套）。
    """
    blocks = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        m = re.match(r'^>\s*\[!(\w+)\]\s*(.*)$', line)
        if not m:
            blocks.append({'type': 'text', 'lines': [line]})
            i += 1
            continue
        # 开启 callout
        ctype = m.group(1).lower()
        title = m.group(2).strip()
        depth = len(re.match(r'^(>\s*)*', line).group(0).split('>')) - 1
        block = {'type': 'callout', 'ctype': ctype, 'title': title,
                 'depth': depth, 'lines': [], 'children': []}
        i += 1
        # 收集内容直到 callout 区结束（非 '>' 行 或 同级/更浅的 '[!type]'）
        while i < n:
            cur = lines[i]
            # 判断当前行前缀深度
            lead = re.match(r'^(>\s*)+', cur)
            if not lead:
                break  # 非 callout 行，结束
            cur_depth = len(re.findall(r'>\s*', lead.group(0)))
            inner = re.sub(r'^(>\s*)+', '', cur)
            im = re.match(r'^\[!(\w+)\]\s*(.*)$', inner)
            if im and cur_depth <= block['depth']:
                break  # 同级或更浅的 callout，结束
            if im and cur_depth > block['depth']:
                # 嵌套 callout
                sub = {'type': 'callout', 'ctype': im.group(1).lower(),
                       'title': im.group(2).strip(), 'depth': cur_depth,
                       'lines': [], 'children': []}
                i += 1
                while i < n:
                    c2 = lines[i]
                    lead2 = re.match(r'^(>\s*)+', c2)
                    if not lead2:
                        break
                    d2 = len(re.findall(r'>\s*', lead2.group(0)))
                    if d2 <= block['depth']:
                        break
                    inner2 = re.sub(r'^(>\s*)+', '', c2)
                    im2 = re.match(r'^\[!(\w+)\]\s*(.*)$', inner2)
                    if im2 and d2 <= sub['depth']:
                        break
                    if im2 and d2 > sub['depth']:
                        sub3 = {'type': 'callout', 'ctype': im2.group(1).lower(),
                                'title': im2.group(2).strip(), 'depth': d2,
                                'lines': [], 'children': []}
                        i += 1
                        while i < n:
                            c3 = lines[i]
                            lead3 = re.match(r'^(>\s*)+', c3)
                            if not lead3 or len(re.findall(r'>\s*', lead3.group(0))) <= sub['depth']:
                                break
                            sub3['lines'].append(re.sub(r'^(>\s*)+', '', c3))
                            i += 1
                        sub['children'].append(sub3)
                        continue
                    sub['lines'].append(inner2)
                    i += 1
                block['children'].append(sub)
                continue
            block['lines'].append(inner)
            i += 1
        blocks.append(block)
    return blocks


def convert_callout(block, math_wrapper=None):
    """callout 块 → tex 环境字符串。"""
    env_name, has_title = CALLOUT_MAP.get(block['ctype'], (None, False))
    if env_name is None:
        env_name = 'note'
    begin_parts = []
    if has_title and block['title']:
        begin_parts.append('\\begin{%s}[%s]' % (env_name, block['title']))
    else:
        begin_parts.append('\\begin{%s}' % env_name)
    body = convert_lines(block['lines'])
    for sub in block['children']:
        body += '\n' + convert_callout(sub)
    return begin_parts[0] + '\n' + body.strip('\n') + '\n\\end{%s}' % env_name


# ---------------- 内容转换 ----------------

ENVS_WITH_AMP = r'\\begin\{(aligned|align|align\*|alignat|array|matrix|pmatrix|bmatrix|Bmatrix|vmatrix|Vmatrix|cases|dcases|smallmatrix|split|gathered)'
TOP_ENVS = r'\\begin\{(align|align\*|gather|gather\*|equation|equation\*|alignat|alignat\*|multline|multline\*|flalign|flalign\*)\}'


def has_bare_amp(expr):
    """判断公式块顶层（环境外）是否存在裸 &。"""
    seg = ''
    depth = 0
    for tok in re.split(r'(\\begin\{[^}]*\}|\\end\{[^}]*\})', expr):
        if re.match(r'\\begin\{', tok):
            if depth == 0:
                seg += ' '
            depth += 1
        elif re.match(r'\\end\{', tok):
            depth -= 1
        else:
            if depth == 0:
                seg += tok
    return '&' in seg


def wrap_formula(expr):
    """公式块处理：顶层显示环境原样；含 \\tag 用 equation*；裸 & 补 aligned。"""
    if re.match(r'^\s*' + TOP_ENVS, expr):
        return expr
    if re.search(r'\\tag\{', expr):
        return '\\begin{equation*}\n' + expr.strip() + '\n\\end{equation*}'
    if has_bare_amp(expr):
        return '\\begin{aligned}\n' + expr.strip() + '\n\\end{aligned}'
    return expr


def emit_formula(expr):
    """顶层显示环境（align*/gather*/equation* 等）原样输出，其余包 \[ \]。"""
    if re.match(r'^\s*\\begin\{(align|align\*|gather|gather\*|equation|equation\*|multline|multline\*|flalign|flalign\*)\}', expr):
        return expr
    return '\\[\n' + expr.strip() + '\n\\]'


def pdf_simplify(s):
    """标题数学的书签安全近似文本。"""
    s = re.sub(r'\\boldsymbol\{([^}]*)\}', r'\1', s)
    s = re.sub(r'\\mathrm\{([^}]*)\}', r'\1', s)
    s = re.sub(r'\\dot\{([^}]*)\}', r'\1', s)
    s = re.sub(r'\\tilde\{([^}]*)\}', r'\1', s)
    s = re.sub(r'\\bar\{([^}]*)\}', r'\1', s)
    s = re.sub(r'\\widehat\{([^}]*)\}', r'\1', s)
    s = re.sub(r'\\hat\{([^}]*)\}', r'\1', s)
    s = re.sub(r'\\vec\{([^}]*)\}', r'\1', s)
    s = re.sub(r'\^\{([^}]*)\}', r'\1', s)
    s = re.sub(r'_\{([^}]*)\}', r'\1', s)
    s = re.sub(r'\^([^ ^])\b', r'\1', s)
    s = s.replace('\\,', '')
    return s


def convert_title(title):
    """标题中的数学 $...$ 用 texorpdfstring 包装（书签安全）。"""
    if '$' not in title:
        return title
    def rep(m):
        pdf = pdf_simplify(m.group(1))
        return '\\texorpdfstring{$%s$}{%s}' % (m.group(1), pdf)
    return re.sub(r'\$([^$]+)\$', rep, title)


def convert_lines(lines):
    """把 callout 内容行（已剥离 > 前缀）或普通文本行转换为 tex。"""
    out = []
    para = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        stripped = line.strip()
        if stripped == '':
            if para:
                out.append(' '.join(para))
                para = []
            i += 1
            continue
        if stripped.startswith('$$'):
            if para:
                out.append(' '.join(para))
                para = []
            # 独立公式块
            content = [stripped[2:]]
            if stripped.endswith('$$') and len(stripped) > 4:
                content[0] = stripped[2:-2].strip()
                out.append(emit_formula(wrap_formula(content[0])))
                i += 1
                continue
            i += 1
            while i < n and not lines[i].strip().endswith('$$'):
                content.append(lines[i])
                i += 1
            if i < n:
                content.append(lines[i].strip()[:-2])
                i += 1
            expr = '\n'.join(c for c in content if c.strip())
            out.append(emit_formula(wrap_formula(expr).strip()))
            continue
        # 图片行
        if '![[' in stripped:
            if para:
                out.append(' '.join(para))
                para = []
            caption = None
            # 紧邻下一非空行若为 *图注* 则作为标题
            j = i + 1
            while j < n and lines[j].strip() == '':
                j += 1
            if j < n:
                cm = re.match(r'^\*(.+)\*$', lines[j].strip())
                if cm:
                    caption = cm.group(1).strip()
                    i = j
            fig = convert_figure_line(stripped, caption)
            if fig:
                out.append(fig)
            i += 1
            continue
        # 表格块
        if stripped.startswith('|') and stripped.count('|') >= 3:
            if para:
                out.append(' '.join(para))
                para = []
            rows = [stripped]
            i += 1
            while i < n and lines[i].strip().startswith('|'):
                rows.append(lines[i].strip())
                i += 1
            out.append(convert_table(rows))
            continue
        # 列表
        mlist = re.match(r'^[-*]\s+(.*)$', stripped)
        if mlist and not stripped.startswith('**'):
            if para:
                out.append(' '.join(para))
                para = []
            items = []
            while i < n:
                mi = re.match(r'^[-*]\s+(.*)$', lines[i].strip())
                if not mi:
                    break
                items.append(mi.group(1).strip())
                i += 1
            out.append('\\begin{itemize}')
            for it in items:
                out.append('\\item ' + escape_text(it))
            out.append('\\end{itemize}')
            continue
        menum = re.match(r'^(\d+)[.)]\s+(.*)$', stripped)
        if menum:
            if para:
                out.append(' '.join(para))
                para = []
            items = []
            while i < n:
                mi = re.match(r'^(\d+)[.)]\s+(.*)$', lines[i].strip())
                if not mi:
                    break
                items.append(mi.group(2).strip())
                i += 1
            out.append('\\begin{enumerate}')
            for it in items:
                out.append('\\item ' + escape_text(it))
            out.append('\\end{enumerate}')
            continue
        # 普通文本行
        para.append(escape_text(stripped))
        i += 1
    if para:
        out.append(' '.join(para))
    return '\n\n'.join(o for o in out if o.strip())


def convert_md(text):
    """md 全文 → tex 正文（不含 \chapter）。"""
    lines = text.split('\n')
    out = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        stripped = line.strip()
        # 章标题：丢弃（主文件负责）
        mh1 = re.match(r'^#\s+(.+)$', stripped)
        if mh1:
            i += 1
            continue
        mh2 = re.match(r'^##\s+(.+)$', stripped)
        if mh2:
            raw_title = mh2.group(1).strip()
            has_num = bool(re.match(r'^\d+(\.\d+)*\s+', raw_title))
            title = re.sub(r'^\d+(\.\d+)*\s+', '', raw_title)
            if title == '习题' and not has_num:
                out.append('\\section*{习题}')
            else:
                out.append('\\section{%s}' % convert_title(title))
            i += 1
            continue
        mh3 = re.match(r'^###\s+(.+)$', stripped)
        if mh3:
            title = re.sub(r'^\d+(\.\d+)*\s+', '', mh3.group(1).strip())
            out.append('\\subsection{%s}' % convert_title(title))
            i += 1
            continue
        mh4 = re.match(r'^####\s+(.+)$', stripped)
        if mh4:
            title = mh4.group(1).strip()
            out.append('\\parahead{%s}' % title)
            i += 1
            continue
        # callout 区（含嵌套 callout 头 > > [!type]）
        if stripped.startswith('>'):
            # 收集连续 callout 行（含嵌套）
            block_lines = []
            while i < n and (lines[i].strip().startswith('>') or lines[i].strip() == ''):
                if lines[i].strip() == '':
                    # 空行：若是 callout 区内空行（下一个还是 > 开头）则保留
                    j = i + 1
                    while j < n and lines[j].strip() == '':
                        j += 1
                    if j < n and lines[j].strip().startswith('>'):
                        block_lines.append('>')
                        i += 1
                        continue
                    break
                block_lines.append(lines[i])
                i += 1
            blocks = parse_callouts(block_lines)
            for b in blocks:
                if b['type'] == 'callout':
                    out.append(convert_callout(b))
                else:
                    out.append(convert_lines(b['lines']))
            continue
        # 普通区域：累积到下一个标题 / callout / 空行（公式、图片、表格、列表留在段内由 convert_lines 处理）
        seg = [line]
        i += 1
        while i < n:
            s = lines[i].strip()
            if s == '':
                # 图片行后允许跨空行并入图注 *caption*
                if '![[' in seg[-1]:
                    j = i
                    while j < n and lines[j].strip() == '':
                        j += 1
                    if j < n and re.match(r'^\*(.+)\*$', lines[j].strip()):
                        i = j
                        continue
                break
            if re.match(r'^#{1,4}\s', s) or s.startswith('>'):
                break
            seg.append(lines[i])
            i += 1
        out.append(convert_lines(seg))
    return '\n'.join(o for o in out if o.strip())


def convert_one(md_name, tex_name):
    md_path = os.path.join(SRC_DIR, md_name)
    tex_path = os.path.join(OUT_DIR, tex_name)
    with open(md_path, 'r', encoding='utf-8') as f:
        text = f.read()
    body = convert_md(text)
    with open(tex_path, 'w', encoding='utf-8') as f:
        f.write(body + '\n')
    print('已生成 %s  (%d 字符)' % (tex_name, len(body)))


if __name__ == '__main__':
    if len(sys.argv) > 1:
        idx = [int(a) for a in sys.argv[1:]]
    else:
        idx = range(1, len(CHAPTERS) + 1)
    for k in idx:
        md_name, tex_name = CHAPTERS[k - 1]
        convert_one(md_name, tex_name)
