"""
PPT转Obsidian Markdown - 按知识点组织版本
- 不按页分节，按PPT中的节标题组织
- 公式用$$包裹
- 图片用![[...]]引用
"""
import olefile
import struct
import os
import re
import aspose.slides as slides


# ==================== 文本提取（olefile）====================

def parse_records(data, offset=0, end=None, depth=0):
    if end is None:
        end = len(data)
    records = []
    while offset < end - 8:
        rec_ver_inst = struct.unpack_from('<H', data, offset)[0]
        rec_ver = rec_ver_inst & 0x000F
        rec_type = struct.unpack_from('<H', data, offset + 2)[0]
        rec_len = struct.unpack_from('<I', data, offset + 4)[0]
        if rec_len > end - offset - 8 or rec_len < 0:
            break
        rec = {'offset': offset, 'ver': rec_ver, 'type': rec_type,
               'len': rec_len, 'depth': depth,
               'data': data[offset+8:offset+8+rec_len] if rec_len > 0 else b''}
        records.append(rec)
        if rec_ver == 0xF and rec_len > 0:
            records.extend(parse_records(data, offset + 8, offset + 8 + rec_len, depth + 1))
        offset += 8 + rec_len
    return records


def extract_text_from_records(records):
    texts = []
    i = 0
    while i < len(records):
        rec = records[i]
        if rec['type'] == 0x0F9F and i + 1 < len(records):
            next_rec = records[i + 1]
            if next_rec['type'] in (0x0FA0, 0x0FA8) and next_rec['len'] > 0:
                try:
                    if next_rec['type'] == 0x0FA0:
                        text = next_rec['data'].decode('utf-16-le')
                    else:
                        text = next_rec['data'].decode('gbk')
                    text = text.replace('\r', '\n').replace('\x0b', '\n').replace('\x07', '')
                    text = text.strip()
                    if text and text != '*':
                        texts.append(text)
                except:
                    pass
                i += 2
                continue
        i += 1
    return texts


def group_by_slide(records):
    slides = []
    current = []
    for rec in records:
        if rec['type'] == 0x03EE and rec['ver'] == 0xF:
            if current:
                slides.append(current)
            current = [rec]
        elif current:
            current.append(rec)
    if current:
        slides.append(current)
    return slides


def is_master_text(text):
    patterns = ['单击此处编辑母版', '第二级', '第三级', '第四级', '第五级']
    return any(p in text for p in patterns)


def is_header_text(text):
    return text.strip() == '控制工程基础'


def is_section_title(text):
    """判断是否是节标题"""
    t = text.strip()
    # 1.1, 1.2, 2.3.1 等数字编号
    if re.match(r'^\d+\.\d+(\.\d+)?\s*\S', t):
        return True
    # 一、二、三、四、五 等中文编号
    if re.match(r'^[一二三四五六七八九十]+、', t):
        return True
    # （一）（二）等
    if re.match(r'^[（(][一二三四五六七八九十]+[）)]', t):
        return True
    return False


def is_formula_line(text):
    t = text.strip()
    if not t or len(t) < 2:
        return False
    if re.match(r'^\d+[-－]\d+$', t):
        return False
    if re.match(r'^[\d\s\.\,\;\:\(\)\[\]\-]+$', t):
        return False
    if len(re.findall(r'[\u4e00-\u9fff]', t)) > 0:
        return False
    chinese_punct = ['，', '。', '：', '；', '！', '？', '、']
    if any(p in t for p in chinese_punct):
        return False

    strong_indicators = [
        '∫', '∑', '∏', '√', '∞', '≈', '≠', '≤', '≥',
        '∂', '∇', '∈', '∉', '⊂', '⊃', '∪', '∩', '∀', '∃',
        'α', 'β', 'γ', 'δ', 'ε', 'ζ', 'η', 'θ', 'ι', 'κ', 'λ',
        'μ', 'ν', 'ξ', 'ο', 'π', 'ρ', 'σ', 'τ', 'υ', 'φ', 'χ',
        'ψ', 'ω', 'Γ', 'Δ', 'Θ', 'Λ', 'Ξ', 'Π', 'Σ', 'Φ', 'Ψ', 'Ω',
    ]
    for ind in strong_indicators:
        if ind in t:
            return True

    has_equals = '=' in t or '＝' in t
    math_ops = ['+', '-', '*', '/', '^', '(', ')', '[', ']', '{', '}', '−', '×', '÷']
    has_math_op = any(op in t for op in math_ops)

    if has_equals and has_math_op:
        return True
    if re.search(r'[A-Za-z]\([sjω]\)\s*[=＝]', t):
        return True
    if re.search(r'd[²²]?[xyztuvw]/d[t²²]?', t):
        return True
    if re.search(r'\\frac|\\int|\\sum|\\sqrt|\\alpha|\\beta|\\gamma|\\omega', t):
        return True
    if has_math_op and len(t) > 3:
        if not re.match(r'^[\d\s\.\,\;\:\-]+$', t):
            return True
    return False


def convert_formula_to_latex(text):
    t = text.strip()
    replacements = {
        'α': r'\alpha', 'β': r'\beta', 'γ': r'\gamma', 'δ': r'\delta',
        'ε': r'\varepsilon', 'ζ': r'\zeta', 'η': r'\eta', 'θ': r'\theta',
        'ι': r'\iota', 'κ': r'\kappa', 'λ': r'\lambda', 'μ': r'\mu',
        'ν': r'\nu', 'ξ': r'\xi', 'π': r'\pi', 'ρ': r'\rho',
        'σ': r'\sigma', 'τ': r'\tau', 'υ': r'\upsilon', 'φ': r'\varphi',
        'χ': r'\chi', 'ψ': r'\psi', 'ω': r'\omega',
        'Γ': r'\Gamma', 'Δ': r'\Delta', 'Θ': r'\Theta', 'Λ': r'\Lambda',
        'Ξ': r'\Xi', 'Π': r'\Pi', 'Σ': r'\Sigma', 'Φ': r'\Phi',
        'Ψ': r'\Psi', 'Ω': r'\Omega',
        '∫': r'\int', '∑': r'\sum', '∏': r'\prod', '√': r'\sqrt',
        '∞': r'\infty', '≈': r'\approx', '≠': r'\neq', '≤': r'\leq',
        '≥': r'\geq', '±': r'\pm', '∓': r'\mp',
        '∂': r'\partial', '∇': r'\nabla', '∈': r'\in', '∉': r'\notin',
        '→': r'\rightarrow', '←': r'\leftarrow', '↔': r'\leftrightarrow',
        '×': r'\times', '÷': r'\div', '·': r'\cdot',
        '⁰': '^0', '¹': '^1', '²': '^2', '³': '^3', '⁴': '^4',
        '⁵': '^5', '⁶': '^6', '⁷': '^7', '⁸': '^8', '⁹': '^9',
        '₀': '_0', '₁': '_1', '₂': '_2', '₃': '_3', '₄': '_4',
        '₅': '_5', '₆': '_6', '₇': '_7', '₈': '_8', '₉': '_9',
        '－': '-', '＋': '+', '＝': '=', '（': '(', '）': ')',
        '−': '-',
    }
    for old, new in replacements.items():
        t = t.replace(old, new)

    greek_cmds = [r'\\alpha', r'\\beta', r'\\gamma', r'\\delta', r'\\varepsilon',
                  r'\\zeta', r'\\eta', r'\\theta', r'\\iota', r'\\kappa',
                  r'\\lambda', r'\\mu', r'\\nu', r'\\xi', r'\\pi', r'\\rho',
                  r'\\sigma', r'\\tau', r'\\upsilon', r'\\varphi', r'\\chi',
                  r'\\psi', r'\\omega', r'\\Gamma', r'\\Delta', r'\\Theta',
                  r'\\Lambda', r'\\Xi', r'\\Pi', r'\\Sigma', r'\\Phi',
                  r'\\Psi', r'\\Omega']
    for cmd in greek_cmds:
        t = re.sub(r'(' + cmd + r')([a-zA-Z])', r'\1 \2', t)

    t = re.sub(r'([a-zA-Z\)\]}])(\d+)(?![a-zA-Z\d])', r'\1_{\2}', t)
    t = re.sub(r'\b([a-zA-Z])(\d+)\b', r'\1_{\2}', t)
    t = re.sub(r'\^([a-zA-Z0-9])', r'^{\1}', t)
    t = re.sub(r'_([a-zA-Z0-9])', r'_{\1}', t)
    return t


def format_text_block(text):
    """格式化文本块，识别公式，返回处理后的文本列表"""
    lines = text.split('\n')
    result = []
    in_formula = False
    formula_buffer = []

    for line in lines:
        stripped = line.strip()
        if not stripped:
            if in_formula and formula_buffer:
                result.append('$$' + ' '.join(formula_buffer) + '$$')
                formula_buffer = []
                in_formula = False
            result.append('')
            continue

        if is_formula_line(stripped):
            if not in_formula:
                in_formula = True
                formula_buffer = [convert_formula_to_latex(stripped)]
            else:
                formula_buffer.append(convert_formula_to_latex(stripped))
        else:
            if in_formula and formula_buffer:
                result.append('$$' + ' '.join(formula_buffer) + '$$')
                formula_buffer = []
                in_formula = False
            result.append(stripped)

    if in_formula and formula_buffer:
        result.append('$$' + ' '.join(formula_buffer) + '$$')

    return result


# ==================== 图片提取（aspose-slides）====================

def extract_images_with_aspose(ppt_path, output_dir, prefix):
    os.makedirs(output_dir, exist_ok=True)
    pres = slides.Presentation(ppt_path)
    slide_images = []

    for slide_idx, slide in enumerate(pres.slides):
        images = []
        img_count = 0
        for shape in slide.shapes:
            if type(shape).__name__ == 'PictureFrame':
                try:
                    # 使用get_image()渲染为真正的PNG（支持WMF/EMF矢量图转换）
                    img = shape.get_image()
                    img_count += 1
                    fname = f"{prefix}_s{slide_idx+1:03d}_{img_count:02d}.png"
                    fpath = os.path.join(output_dir, fname)
                    img.save(fpath)
                    images.append(fname)
                except Exception as e:
                    # 回退到原始数据
                    try:
                        pic = shape.picture_format.picture.image
                        img_data = pic.binary_data
                        img_count += 1
                        fname = f"{prefix}_s{slide_idx+1:03d}_{img_count:02d}.png"
                        fpath = os.path.join(output_dir, fname)
                        with open(fpath, 'wb') as f:
                            f.write(img_data)
                        images.append(fname)
                    except:
                        pass
        slide_images.append(images)

    return slide_images


# ==================== 主转换函数 ====================

def convert_ppt(ppt_path, output_dir, images_dir):
    filename = os.path.basename(ppt_path)
    name_without_ext = os.path.splitext(filename)[0]
    prefix = name_without_ext.replace(' ', '_')

    print(f"处理: {filename}")

    # 1. 提取图片
    print("  提取图片...")
    slide_images = extract_images_with_aspose(ppt_path, images_dir, prefix)
    total_images = sum(len(imgs) for imgs in slide_images)
    print(f"  提取了 {total_images} 张图片")

    # 2. 提取文本
    print("  提取文本...")
    ole = olefile.OleFileIO(ppt_path)
    data = ole.openstream('PowerPoint Document').read()
    ole.close()

    all_records = parse_records(data)
    slides_records = group_by_slide(all_records)

    # 过滤母版
    content_slides = []
    for slide_recs in slides_records:
        texts = extract_text_from_records(slide_recs)
        master_count = sum(1 for t in texts if is_master_text(t))
        if master_count < len(texts) * 0.5 and len(texts) > 0:
            content_slides.append(texts)

    print(f"  总幻灯片: {len(slides_records)}, 内容幻灯片: {len(content_slides)}")

    # 3. 按知识点组织内容
    md_lines = []
    md_lines.append(f"# {name_without_ext}")
    md_lines.append('')

    num_slides = min(len(content_slides), len(slide_images))
    current_section = None
    current_paragraph = ''  # 当前段落缓冲区

    def flush_paragraph():
        nonlocal current_paragraph
        if current_paragraph.strip():
            md_lines.append(current_paragraph.strip())
            md_lines.append('')
        current_paragraph = ''

    for idx in range(num_slides):
        slide_texts = content_slides[idx]
        images = slide_images[idx]

        # 过滤母版和页眉
        slide_texts = [t for t in slide_texts if not is_master_text(t) and not is_header_text(t)]

        # 统计本页中的节标题数量，用于识别目录页
        page_section_titles = [t for t in slide_texts if is_section_title(t.strip())]

        for text in slide_texts:
            formatted = format_text_block(text)
            for line in formatted:
                stripped = line.strip()
                if not stripped:
                    continue

                # 检查是否是节标题
                if is_section_title(stripped):
                    # 目录页判断：如果本页有多个节标题（>=3），则不作为节标题
                    if len(page_section_titles) >= 3:
                        if current_paragraph:
                            current_paragraph += stripped
                        else:
                            current_paragraph = stripped
                        continue

                    # 新节开始，先刷新当前段落
                    flush_paragraph()
                    md_lines.append(f"## {stripped}")
                    md_lines.append('')
                    current_section = stripped
                elif stripped.startswith('$$'):
                    # 公式行，先刷新段落
                    flush_paragraph()
                    md_lines.append(stripped)
                    md_lines.append('')
                elif stripped.startswith('![['):
                    # 图片（不会走到这里，图片在后面处理）
                    flush_paragraph()
                    md_lines.append(stripped)
                    md_lines.append('')
                else:
                    # 普通文本行，判断是否需要合并到当前段落
                    # 如果当前段落是短术语标题（<15字符，不以标点结尾），则加粗并结束
                    if (current_paragraph and len(current_paragraph) < 15
                            and not current_paragraph.endswith(('。', '？', '！', '：', '；', '…', '—', '.', '?', '!', '：'))
                            and not re.match(r'^[（(]?\d+[）)\.、]', current_paragraph)):
                        # 可能是术语小标题，加粗后结束
                        md_lines.append(f"**{current_paragraph.strip()}**")
                        md_lines.append('')
                        current_paragraph = stripped
                        continue

                    can_merge = (
                        current_paragraph
                        and not current_paragraph.endswith(('。', '？', '！', '：', '；', '…', '—', '.', '?', '!'))
                        and not re.match(r'^[（(]?\d+[）)\.、]', stripped)  # 列表项
                        and not re.match(r'^[一二三四五六七八九十]+[、.]', stripped)  # 中文编号
                        and not re.match(r'^[A-Z][a-z]+', stripped)  # 英文开头（可能是新术语）
                        and len(stripped) > 1
                    )
                    if can_merge:
                        current_paragraph += stripped
                    else:
                        flush_paragraph()
                        current_paragraph = stripped

        # 页结束，刷新当前段落
        flush_paragraph()

        # 图片紧跟在该页文本后
        if images:
            for img_name in images:
                rel_path = f"images/{img_name}"
                md_lines.append(f"![[{rel_path}]]")
                md_lines.append('')

    # 最后刷新
    flush_paragraph()

    # 如果没有任何节标题，添加一个默认节
    if current_section is None:
        # 在第3行插入一个默认标题
        md_lines.insert(2, "## 内容")
        md_lines.insert(3, '')

    # 写入文件
    output_path = os.path.join(output_dir, f"{name_without_ext}.md")
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(md_lines))

    print(f"  输出: {output_path}")
    return output_path


def main():
    ppt_dir = r"D:\studynotes\控制理论\控制工程基础\课件"
    output_dir = r"D:\studynotes\控制理论\控制工程基础\课堂笔记"
    images_dir = os.path.join(output_dir, "images")

    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(images_dir, exist_ok=True)

    ppt_files = sorted([f for f in os.listdir(ppt_dir) if f.lower().endswith('.ppt')])

    for ppt_file in ppt_files:
        ppt_path = os.path.join(ppt_dir, ppt_file)
        try:
            convert_ppt(ppt_path, output_dir, images_dir)
        except Exception as e:
            print(f"  错误: {e}")
            import traceback
            traceback.print_exc()

    print("\n全部处理完成!")


if __name__ == '__main__':
    main()
