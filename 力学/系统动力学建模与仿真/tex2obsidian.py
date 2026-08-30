# -*- coding: utf-8 -*-
"""
将《系统动力学建模与仿真》各章 tex 转换为 Obsidian 风格读书笔记 md。
约定（参考第十章读书笔记）：
  - 章节：# 章标题 / ## 节 / ### 小节 / #### 段标题
  - 数学：$...$ 行内，$$...$$ 独立公式
  - 定理/定义/例题等：Obsidian callout（> [!type] 标题）
  - 图片：![[basename.png]]
  - 表格：Markdown 表格
  - 交叉引用：尽量解析为 章.编号
"""
import re, os, sys

SRC_DIR = r"D:\studynotes\力学\系统动力学建模与仿真"
OUT_DIR = r"D:\studynotes\教材\SystemDynamicsModelingAndSimulation"

ZH = {1:"一",2:"二",3:"三",4:"四",5:"五",6:"六",7:"七",8:"八",9:"九",10:"十"}

# (源tex文件名, 章标题)
CHAPTERS = {
 1: ("绪论", "绪论"),
 2: ("数学基础", "数学基础"),
 3: ("运动学基础", "运动学基础"),
 4: ("拉格朗日力学基础", "拉格朗日力学基础"),
 5: ("有限维广义变分原理", "有限维广义变分原理"),
 6: ("多体系统的拉格朗日方程", "多体系统的拉格朗日方程"),
 7: ("系统运动微分方程及其数值求解", "系统运动微分方程"),
 8: ("空间运动刚体的动能与势能", "空间运动刚体的动能与势能"),
 9: ("体元件广义坐标与系统总体动力学方程", "体元件广义坐标与系统总体动力学方程"),
}

THM_FAMILY = {
 'theorem':   ('theorem', '定理'),
 'lemma':     ('info',    '引理'),
 'corollary': ('info',    '推论'),
 'definition':('definition','定义'),
 'axiom':     ('definition','公理'),
 'proposition':('note',   '命题'),
 'property':  ('note',    '性质'),
 'example':   ('example', '例题'),
 'exercise':  ('example', '练习'),
 'longexample':('example','例题'),
 'conclusion':('abstract','结论'),
}
CALLBOX = {
 'keybox': ('important','重点'),
 'tipbox': ('tip',     '技巧'),
 'warnbox':('warning', '注意'),
}
BRACE_ENVS = {
 'mydefinition': ('definition', None),
 'myTheorem':    ('theorem',    None),
 'myhypothesis': ('tip',        None),
}
SIMPLE = {
 'proof':    ('quote',   '推导'),
 'remark':   ('note',    '注'),
 'note':     ('note',    '注'),
 'solution': ('success', '解'),
}
LIST_ENVS = {'itemize':'-', 'enumerate':'1.'}

def strip_comments(text):
    out = []
    for line in text.split('\n'):
        m = re.search(r'(?<!\\)%', line)
        if m:
            line = line[:m.start()]
        out.append(line)
    return '\n'.join(out)

def build_global_labels():
    """跨章标签表：登记各章的节标题与图表题，供跨章 \\ref 解析（如第九章引用第三章的节）。"""
    g = {}
    for ch in CHAPTERS:
        src_name = CHAPTERS[ch][0]
        p = os.path.join(SRC_DIR, src_name + '.tex')
        if not os.path.exists(p):
            continue
        t = strip_comments(open(p, 'r', encoding='utf-8').read())
        t = inline_inputs(t)
        # 节标题后面紧跟的 \label
        for m in re.finditer(r'\\(?:section|subsection|subsubsection|paragraph)\*?\{([^}]*)\}\s*\\label\{([^}]*)\}', t):
            g[m.group(2)] = m.group(1)
        # 图表：\label 附近有 \caption 则以图/表题指代
        for m in re.finditer(r'\\label\{([^}]*)\}', t):
            key = m.group(1)
            around = t[max(0, m.start() - 400): m.end() + 400]
            cm = re.search(r'\\caption\{([^}]*)\}', around)
            if cm:
                g.setdefault(key, cm.group(1).strip())
    return g

GLOBAL_LABELS = None

def inline_inputs(text):
    """把 \\input{xxx} 替换成被引用文件的实际内容（支持递归一层）。"""
    def repl(m):
        rel = m.group(1)
        if not rel.endswith('.tex'):
            rel += '.tex'
        p = os.path.join(SRC_DIR, rel)
        if not os.path.exists(p):
            return ''
        sub = open(p, 'r', encoding='utf-8').read()
        return strip_comments(sub)
    prev = None
    while prev != text:
        prev = text
        text = re.sub(r'\\input\{([^}]*)\}', repl, text)
    return text

def register_sec_labels(text, state):
    """把 \\section{标题}\\label{sec:xxx} 登记进 labels，使 \\ref{sec:xxx} 解析为节标题。"""
    for m in re.finditer(r'\\(?:section|subsection|subsubsection|paragraph)\*?\{([^}]*)\}\s*\\label\{([^}]*)\}', text):
        state['labels'][m.group(2)] = m.group(1)
    return text

def match_brace(text, open_idx):
    """给定 '{' 的下标，返回匹配 '}' 的下标（考虑嵌套与 \\{ 转义）。"""
    depth = 0
    i = open_idx
    n = len(text)
    while i < n:
        c = text[i]
        if c == '\\':
            i += 2
            continue
        if c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1

def convert_footnotes(text):
    """\\footnote{...} → Obsidian 脚注 callout（用括号配对，避免被嵌套花括号截断）。"""
    out = []
    i = 0
    while True:
        j = text.find('\\footnote', i)
        if j < 0:
            out.append(text[i:])
            break
        out.append(text[i:j])
        k = text.find('{', j)
        if k < 0:
            out.append(text[j:])
            break
        e = match_brace(text, k)
        if e < 0:
            out.append(text[j:])
            break
        content = text[k+1:e].strip()
        # 用行内括注而不是 callout：脚注常出现在 callout 内部，
        # 再套一层 callout 会得到错误的嵌套（需要 >> 前缀）。
        content = re.sub(r'\s*\n\s*', ' ', content)
        out.append('（脚注：%s）' % content)
        i = e + 1
    return ''.join(out)

def clean_text_only(seg):
    """仅清理文本段：保护行内数学 $...$ 与独立公式 $$...$$，清理字体/强调/间距命令。"""
    maths = []
    def stash(m):
        maths.append(m.group(0))
        return '\x00%d\x00' % (len(maths)-1)
    seg = re.sub(r'\$\$.*?\$\$', stash, seg, flags=re.S)  # 先保护独立公式
    seg = re.sub(r'\$(?!\$)((?:\\\$|[^$])*?)\$(?!\$)', stash, seg)  # 再保护行内公式
    seg = re.sub(r'\\textcolor\{[^}]*\}\{(.*?)\}', r'\1', seg, flags=re.S)
    seg = re.sub(r'\\color\{[^}]*\}', '', seg)
    seg = re.sub(r'\\emph\{(.*?)\}', r'**\1**', seg, flags=re.S)
    seg = re.sub(r'\\textbf\{(.*?)\}', r'**\1**', seg, flags=re.S)
    seg = re.sub(r'\\textit\{(.*?)\}', r'*\1*', seg, flags=re.S)
    seg = re.sub(r'\\texttt\{(.*?)\}', r'`\1`', seg, flags=re.S)
    seg = re.sub(r'\\underline\{(.*?)\}', r'<u>\1</u>', seg, flags=re.S)
    # 去掉 {\heiti ...} 等字体开关的花括号包裹（含内容）
    seg = re.sub(r'\{\s*\\(?:heiti|kaishu|songti|fangsong|lishu|bfseries|itshape|upshape|normalsize|large|Large|footnotesize|small|centering|noindent)\b\s*(.*?)\}', r'\1', seg, flags=re.S)
    # 去掉 **..** / *..* 外层的花括号包裹
    # 注意 [^*}] 而非 [^*]：否则会跨过 } 把两个 \multirow{2}{*}{...} 拼在一起破坏掉
    seg = re.sub(r'\{\s*(\*\*[^*}]+\*\*)\s*\}', r'\1', seg)
    seg = re.sub(r'\{\s*(\*[^*}]+\*)\s*\}', r'\1', seg)
    seg = re.sub(r'\\(?:heiti|kaishu|songti|fangsong|lishu|bfseries|itshape|upshape|normalsize|large|Large|footnotesize|small|centering|noindent|par)\b', ' ', seg)
    seg = seg.replace('\\qquad','   ').replace('\\quad','  ')
    seg = seg.replace('\\;',' ').replace('\\:', ' ').replace('\\,',' ').replace('\\!','')
    seg = seg.replace('\\ ',' ').replace('~',' ')
    # 罗马数字：源中写法为 \uppercase\expandafter{\romannumeral1}（花括号未转义）
    seg = re.sub(r'\\uppercase\\expandafter\{\\romannumeral\s*(\d+)\}',
                 lambda m: 'ⅠⅡⅢⅣⅤⅥⅦⅧⅨ'[int(m.group(1))-1], seg)
    seg = seg.replace('\\{','{').replace('\\}','}')
    seg = re.sub(r'\\intro\{(.*?)\}', r'> *\1*', seg, flags=re.S)
    seg = re.sub(r'\\blocksep','\n', seg)
    seg = re.sub(r'\\vspace\{[^}]*\}',' ', seg)
    seg = re.sub(r'\\hspace\{[^}]*\}',' ', seg)
    seg = re.sub(r'\\protect','', seg)
    seg = re.sub(r' {2,}', ' ', seg)
    # 递归展开占位符，防止内层公式占位符被外层行内数学捕获后无法还原（如 $x$$y$$z$）
    guard = 0
    while '\x00' in seg and guard < 20:
        seg = re.sub(r'\x00(\d+)\x00', lambda m: maths[int(m.group(1))], seg)
        guard += 1
    seg = fix_adj_inline(seg)
    return seg

def finalize_refs(text):
    """兜底：把最后仍未解析的引用退化成可读文字（去掉 fig:/tab:/eq:/sec: 前缀）。"""
    def key2txt(key):
        return re.sub(r'^(?:fig|tab|eq|sec):', '', key)
    text = re.sub(r'\\eqref\{([^}]*)\}', lambda m: '（%s）' % key2txt(m.group(1)), text)
    text = re.sub(r'\\(?:cref|ref)\{([^}]*)\}', lambda m: key2txt(m.group(1)), text)
    return text

def fix_adj_inline(seg):
    """把源里相邻的行内数学 $x$$y$$z$ 拆成 $x$, $y$, $z$。

    只对「内容很短且不含反斜杠/等号/空格」的相邻行内公式生效；
    真正的显示公式 $$...$$ 内容必含命令或运算符，因此不会被误伤。
    """
    tok = r'[A-Za-z0-9_\^\{\}]{1,4}'
    pat = re.compile(r'(\$' + tok + r'\$)(?=\$' + tok + r'\$)')
    prev = None
    while prev != seg:
        prev = seg
        seg = pat.sub(lambda m: m.group(1) + ', ', seg)
    return seg

def resolve_refs(text, labels):
    """解析已登记的引用；尚未登记的（如盒子内嵌的图表）原样保留，留给最后一遍解析。"""
    def sub_eq(m):
        key = m.group(1)
        return '（%s）' % labels[key] if key in labels else m.group(0)
    def sub(m):
        key = m.group(1)
        return labels[key] if key in labels else m.group(0)
    text = re.sub(r'\\eqref\{([^}]*)\}', sub_eq, text)
    text = re.sub(r'\\cref\{([^}]*)\}', sub, text)
    text = re.sub(r'\\ref\{([^}]*)\}', sub, text)
    text = re.sub(r'\\pageref\{[^}]*\}', '', text)
    text = re.sub(r'\\label\{[^}]*\}', '', text)
    return text

def convert_table(inner, env, state=None):
    cap = re.search(r'\\caption\{(.*?)\}', inner, flags=re.S)
    caption = cap.group(1).strip() if cap else ''
    inner = re.sub(r'\\endfirsthead.*?\\endhead', '', inner, flags=re.S)
    inner = re.sub(r'\\endfoot', '', inner)
    inner = re.sub(r'\\endlastfoot', '', inner)
    inner = re.sub(r'\\endhead', '', inner)
    inner = re.sub(r'\\endfirsthead', '', inner)
    inner = re.sub(r'\\toprule|\\midrule|\\bottomrule|\\hline|\\cline\{[^}]*\}', '', inner)
    inner = re.sub(r'\\caption\{.*?\}', '', inner, flags=re.S)
    inner = re.sub(r'\\multicolumn\{(\d+)\}\{[^}]*\}\{(.*?)\}', r'\2', inner, flags=re.S)
    inner = re.sub(r'\\multirow\{[^}]*\}\{[^}]*\}\{(.*?)\}', r'\1', inner, flags=re.S)
    inner = re.sub(r'\\tablename~\\thetable\{\}（续表）', '', inner)
    inner = re.sub(r'\\label\{[^}]*\}', '', inner)
    inner = re.sub(r'^\s*\{[lc| ]*\}', '', inner)
    rows = re.split(r'\\\\\s*(?:\[[^\]]*\])?\s*', inner)
    md = []
    for r in rows:
        r = r.strip()
        if r == '':
            continue
        cells = [c.strip() for c in r.split('&')]
        if all(c == '' for c in cells):
            continue
        md.append('| ' + ' | '.join(cells) + ' |')
    if not md:
        return ''
    out = []
    if caption:
        out.append('*表：%s*' % caption)
    out.append(md[0])
    out.append('| ' + ' | '.join(['---']*len(md[0].split('|')[1:-1])) + ' |')
    out.extend(md[1:])
    return '\n'.join(out)

def convert_figure(inner, state=None):
    m = re.search(r'\\includegraphics(?:\[[^\]]*\])?\{([^}]*)\}', inner)
    path = m.group(1) if m else None
    cap = re.search(r'\\caption\{(.*?)\}', inner, flags=re.S)
    caption = cap.group(1).strip() if cap else ''
    if not path:
        return ''
    base = os.path.basename(path)
    res = '![[%s]]' % base
    if caption:
        res += '\n\n*%s*' % caption
    return res

def wrap_callout(ctype, title, body):
    out = ['> [!%s] %s' % (ctype, title)]
    raw = []
    for ln in body.strip('\n').split('\n'):
        raw.append('> ' + ln if ln.strip() else '>')
    idxs = [i for i, ln in enumerate(raw) if ln.strip() == '> $$']
    first = idxs[0] if idxs else -1
    last = idxs[-1] if idxs else -1
    for i, ln in enumerate(raw):
        if ln.strip() == '> $$':
            if i == first and out and out[-1].strip() != '>':
                out.append('>')
            out.append(ln)
            if i == last and i+1 < len(raw) and raw[i+1].strip() != '>':
                out.append('>')
        else:
            out.append(ln)
    return '\n' + '\n'.join(out) + '\n'

def box_handler(env, opt, brace, inner, ch, state):
    # 先从未处理的原文登记图表标签：下面的 resolve_refs 会把 \label{} 剥掉，
    # 若等到 convert_figure/convert_table 再去读就永远读不到了。
    if env in ('figure', 'table', 'longtable', 'tabular'):
        cap = re.search(r'\\caption\{(.*?)\}', inner, flags=re.S)
        caption = cap.group(1).strip() if cap else ''
        lm = re.search(r'\\label\{([^}]*)\}', inner)
        if lm:
            state['labels'][lm.group(1)] = caption if caption else lm.group(1)
    inner2 = resolve_refs(inner, state['labels'])
    # 关键点：先把内嵌盒子（表格/图片/列表等）转换掉，再加 > 前缀。
    # 否则 callout 的 > 会先落到原始 LaTeX 上，表格转换后 > 会混进单元格里。
    inner_p = process_boxes(inner2, ch, state)
    if env in THM_FAMILY:
        ctype, zh = THM_FAMILY[env]
        state['cnt'] += 1
        num = '%d.%d' % (ch, state['cnt'])
        title = '%s %s' % (zh, num)
        if opt:
            title += '（%s）' % opt.strip()
        return wrap_callout(ctype, title, inner_p)
    if env in CALLBOX:
        ctype, default = CALLBOX[env]
        title = opt.strip() if opt else default
        return wrap_callout(ctype, title, inner_p)
    if env in BRACE_ENVS:
        ctype, _ = BRACE_ENVS[env]
        title = brace if brace else ''
        return wrap_callout(ctype, title, inner_p)
    if env in SIMPLE:
        ctype, label = SIMPLE[env]
        return wrap_callout(ctype, label, inner_p)
    if env in ('center','flushleft','flushright'):
        return '\n' + inner_p.strip('\n') + '\n'
    if env in LIST_ENVS:
        marker = LIST_ENVS[env]
        inner_proc = inner_p
        items = re.split(r'\\item\s*(?:\[[^\]]*\])?', inner_proc)
        out = ['%s %s' % (marker, it.strip()) for it in items[1:] if it.strip()]
        return '\n' + '\n'.join(out) + '\n'
    if env in ('table','longtable','tabular'):
        return '\n' + convert_table(inner2, env, state) + '\n'
    if env == 'figure':
        return '\n' + convert_figure(inner2, state) + '\n'
    if env == 'myformula':
        math = inner2.strip().strip('$').strip()
        return '\n$$\n' + math + '\n$$\n'
    return '\\begin{%s}%s%s\\end{%s}' % (env, ('['+opt+']' if opt else ''), inner, env)

def process_boxes(text, ch, state):
    brace_pat = re.compile(r'\\begin\{(mydefinition|myTheorem|myhypothesis)\}\{([^}]*)\}(.*?)\\end\{\1\}', re.S)
    def brace_repl(m):
        return box_handler(m.group(1), None, m.group(2), m.group(3), ch, state)
    text = brace_pat.sub(brace_repl, text)
    gen_pat = re.compile(r'\\begin\{([A-Za-z*]+)\}(?:\[([^\]]*)\])?(.*?)\\end\{\1\}', re.S)
    def gen_repl(m):
        return box_handler(m.group(1), m.group(2), None, m.group(3), ch, state)
    prev = None
    while prev != text:
        prev = text
        text = gen_pat.sub(gen_repl, text)
    return text

def stage_math(text, ch, state):
    text = re.sub(r'(?<!\\)\\\[(.*?)(?<!\\)\\\]', lambda m: '\n$$\n'+m.group(1).strip()+'\n$$\n', text, flags=re.S)
    pat = re.compile(r'\\begin\{(equation\*?|align\*?|gather\*?)\}(.*?)\\end\{\1\}', re.S)
    def repl(m):
        env = m.group(1); inner = m.group(2)
        lm = re.search(r'\\label\{([^}]*)\}', inner)
        if lm:
            key = lm.group(1)
            inner = inner.replace(lm.group(0), '')
            if env in ('equation','align','gather'):
                state['eq'] += 1
                state['labels'][key] = '%d.%d' % (ch, state['eq'])
        if env in ('align','gather'):
            disp = '\\begin{%s*}%s\\end{%s*}' % (env, inner.strip(), env)
        else:
            disp = inner.strip()
        return '\n$$\n' + disp + '\n$$\n'
    text = pat.sub(repl, text)
    return text

def headings(text, ch, title):
    out = ['# 第%s章 %s' % (ZH[ch], title), '']
    text = re.sub(r'\\newpage|\\clearpage', '', text)
    # 带星号形式（\section*{}）同样要转成标题
    text = re.sub(r'\\paragraph\*?\{([^}]*)\}', r'\n#### \1\n', text)
    text = re.sub(r'\\parahead\*?\{([^}]*)\}', r'\n#### \1\n', text)
    text = re.sub(r'\\subsection\*?\{([^}]*)\}', r'\n### \1\n', text)
    text = re.sub(r'\\subsubsection\*?\{([^}]*)\}', r'\n#### \1\n', text)
    text = re.sub(r'\\section\*?\{([^}]*)\}', r'\n## \1\n', text)
    text = re.sub(r'\\chapter\*?\{([^}]*)\}', r'\n# \1\n', text)
    text = re.sub(r'\\label\{[^}]*\}', '', text)
    return '\n'.join(out) + text

def convert_chapter(ch):
    src_name, title = CHAPTERS[ch]
    src_path = os.path.join(SRC_DIR, src_name + '.tex')
    with open(src_path, 'r', encoding='utf-8') as f:
        text = f.read()
    text = strip_comments(text)
    text = inline_inputs(text)          # 先展开 \input
    global GLOBAL_LABELS
    if GLOBAL_LABELS is None:
        GLOBAL_LABELS = build_global_labels()
    text = text.replace('\\bm', '\\boldsymbol')
    state = {'cnt':0, 'eq':0, 'labels':dict(GLOBAL_LABELS), 'ch':ch}
    register_sec_labels(text, state)    # 登记 \section{...}\label{sec:...}
    text = stage_math(text, ch, state)
    text = clean_text_only(text)          # 先清理文本（此时尚无 callout 的 > 前缀）
    # 脚注要在 process_boxes 之前处理：否则 callout 的 > 前缀会混进脚注正文
    text = convert_footnotes(text)
    text = process_boxes(text, ch, state)  # 再包裹盒子（添加 > 前缀）
    text = re.sub(r'\\S(?![A-Za-z])', '§', text)   # 节号符号
    text = headings(text, ch, title)
    text = re.sub(r'\\includegraphics(?:\[[^\]]*\])?\{([^}]*)\}', lambda m: '![[%s]]' % os.path.basename(m.group(1)), text)
    text = resolve_refs(text, state['labels'])
    text = finalize_refs(text)
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = text.strip() + '\n'
    out_name = '读书笔记——第%s章 %s.md' % (ZH[ch], title)
    out_path = os.path.join(OUT_DIR, out_name)
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(text)
    print('已生成: %s  (定理类盒子=%d, 公式=%d, 标签=%d)' % (out_name, state['cnt'], state['eq'], len(state['labels'])))
    return out_path

if __name__ == '__main__':
    if len(sys.argv) > 1:
        for a in sys.argv[1:]:
            convert_chapter(int(a))
    else:
        for ch in range(1, 10):
            convert_chapter(ch)
