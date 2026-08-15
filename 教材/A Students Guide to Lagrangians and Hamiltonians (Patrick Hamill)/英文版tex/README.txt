A Student's Guide to Lagrangians and Hamiltonians — LaTeX Source
=================================================================

Author:  Patrick Hamill
Source:  Cambridge University Press (2014)

This archive contains the LaTeX source files for the book,
organized by chapter, with all figures extracted into the
Figures/ folder.

Directory Structure
--------------------
main.tex                 — Main document (XeLaTeX)
chapters/
  Ch_intro.tex           — Introduction & Acknowledgements
  Ch1.tex                 — Chapter 1: Fundamental Concepts
  Ch2.tex                 — Chapter 2: The Calculus of Variations
  Ch3.tex                 — Chapter 3: Lagrangian Dynamics
  Ch4.tex                 — Chapter 4: Hamilton's Equations
  Ch5.tex                 — Chapter 5: Canonical Transformations; Poisson Brackets
  Ch6.tex                 — Chapter 6: Hamilton-Jacobi Theory
  Ch7.tex                 — Chapter 7: Continuous Systems
Figures/                 — All extracted figures (PNG format)

Compilation
-----------
Requires XeLaTeX (TeX Live 2020 or later recommended).

  cd latex_project_final
  xelatex main.tex
  xelatex main.tex

Run twice to resolve cross-references and TOC.

Dependencies
------------
  fontspec, graphicx, amsmath, amssymb, amsthm,
  fancyhdr, titlesec, caption, subcaption, hyperref, enumitem

Fonts: TeX Gyre Termes (serif), TeX Gyre Cursor (mono)
  — Both are free and included in TeX Live.

Notes
-----
- Cover, copyright page, and reference/answer sections
  have been omitted per the user's request.
- All figures are referenced by \includegraphics{fig_X_Y}
  and resolved via \graphicspath{{./Figures/}}.
- If you prefer a different font, change the \setmainfont
  and \setmonofont lines in main.tex.

Enjoy!
