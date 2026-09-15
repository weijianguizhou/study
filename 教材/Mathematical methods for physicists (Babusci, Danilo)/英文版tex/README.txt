Mathematical Methods for Physicists — XeLaTeX Project
==================================================

AUTHORS (original book): Danilo Babusci, Giuseppe Dattoli,
                              Silvia Licciardi, Elio Sabia
LATEX TRANSCRIPTION: AI-assisted, hand-typeset key equations

STRUCTURE:
  main.tex      XeLaTeX master file (compile this)
  ch1.tex       Ch.1 Matrices, Exponential Operators and Physical Applications
  ch2.tex       Ch.2 Ordinary/PDE, Evolution Operator Method
  ch3.tex       Ch.3 Hermite Polynomials and Applications
  ch4.tex       Ch.4 Laguerre Polynomials, Integral Operators
  ch5.tex       Ch.5 Exercises and Complements I
  ch6.tex       Ch.6 Exercises and Complements II
  ch7.tex       Ch.7 Exercises and Complements III
  ch8.tex       Ch.8 Exercises and Complements IV
  ch9.tex       Ch.9 Special Functions, Umbral Methods
  ch10.tex      Ch.10 A Glimpse into Feynman Diagrams

HOW TO COMPILE (Windows / VS Code):
  1. Install TeX Live (https://tug.org/texlive/) or MiKTeX
  2. Open main.tex in VS Code with LaTeX Workshop extension
  3. Ensure first line:  % !TEX program = xelatex
  4. Click "Build LaTeX project" → select XeLaTeX
  5. Build TWICE (first pass writes .aux, second resolves \ref)

ALTERNATIVE (command line):
  cd <this folder>
  xelatex main.tex
  xelatex main.tex

CUSTOM MACROS (defined in main.tex):
  \mat{...}      → pmatrix shorthand
  \spp, \smm    → σ₊, σ₋ ladder operators
  \sigx, \sigy, \sigz → σ_x, σ_y, σ_z
  \vect{v}        → bold vector
  \tr, \sinc, \sincf, \diag  → standard operators

CONTENT NOTES:
  - Key equations in every chapter are hand-typeset in proper
    LaTeX math environments (equation, align, etc.)
  - A "Transcribed Notes (raw OCR, verbatim)" section at the end
    of ch3–ch10 contains the raw extracted text from the source PDF,
    wrapped in a verbatim environment so it cannot break compilation.
    This is supplementary reading material.
  - Original book figures (Figures 1.1–10.x) are NOT embedded.
    To add them, screenshot / extract from the PDF and use:
      \includegraphics[width=0.8\linewidth]{figX_Y.png}

VALIDATION STATUS:
  ✅ All \mat{} inside math mode
  ✅ Brace balance: depth 0 in every file
  ✅ All \ref keys resolve to a \label
  ✅ All \include targets exist
  ✅ All custom macros defined in main.tex

LICENSE NOTE:
  This LaTeX transcription is for personal study use only.
  The original book copyright © 2020 World Scientific Publishing.
  Do not redistribute the compiled PDF commercially.
