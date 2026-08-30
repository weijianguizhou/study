# -*- coding: utf-8 -*-
"""逐个编译 模板/课程笔记/ 下的所有封面，生成预览 PDF 并报告错误。"""
import subprocess, shutil, pathlib, re, sys, os

TPL = pathlib.Path(r"D:\studynotes\模板\课程笔记")
TEST = pathlib.Path(r"D:\studynotes\.workbuddy\_covertest")
PREV = TPL / "封面预览"
BIN = pathlib.Path(r"D:\Latex\R\bin\windows")

MAIN = r"""\documentclass[12pt,a4paper]{book}
\input{preamble}
\newcommand{\notename}{课\ 程\ 名\ 称}
\newcommand{\noteauthor}{作\ 者\ 姓\ 名}
\newcommand{\notecourseen}{Course Notes}
\begin{document}
\input{%s}
\end{document}
"""

TEST.mkdir(parents=True, exist_ok=True)
PREV.mkdir(parents=True, exist_ok=True)
shutil.copy(TPL / "preamble.tex", TEST / "preamble.tex")

covers = sorted(TPL.glob("cover*.tex"))
env = os.environ.copy()
env["PATH"] = str(BIN) + os.pathsep + env.get("PATH", "")

ok, bad = [], []
for c in covers:
    shutil.copy(c, TEST / c.name)
    (TEST / "cover_test.tex").write_text(MAIN % c.stem, encoding="utf-8")
    for _ in range(2):
        subprocess.run(["latexmk", "-xelatex", "-interaction=nonstopmode",
                        "cover_test.tex"], cwd=TEST, env=env,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    pdf = TEST / "cover_test.pdf"
    log = (TEST / "cover_test.log").read_text(encoding="utf-8", errors="ignore")
    errs = [l for l in log.splitlines() if l.startswith("! ")]
    if pdf.exists() and not errs:
        shutil.copy(pdf, PREV / f"预览_{c.stem}.pdf")
        ok.append(c.stem)
    else:
        bad.append((c.stem, errs[:3]))

print("OK:", len(ok))
for n in ok:
    print("  +", n)
print("FAIL:", len(bad))
for n, e in bad:
    print("  -", n, "|", " / ".join(e))
