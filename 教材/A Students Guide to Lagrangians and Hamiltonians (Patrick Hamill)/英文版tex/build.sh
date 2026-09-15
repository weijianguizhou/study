#!/bin/bash
# Build script for A Student's Guide to Lagrangians and Hamiltonians
# Usage: bash build.sh

set -e

echo "=== First xelatex pass ==="
xelatex -interaction=nonstopmode main.tex

echo ""
echo "=== Second xelatex pass (for TOC) ==="
xelatex -interaction=nonstopmode main.tex

echo ""
echo "=== Build complete ==="
ls -lh main.pdf 2>/dev/null || echo "main.pdf not found — check main.log for errors."

# Clean up auxiliary files (optional)
# rm -f main.aux main.log main.out main.toc chapters/*.aux
