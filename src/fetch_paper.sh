#!/usr/bin/env bash
# fetch_paper.sh <arxiv_id> [cache_dir]
#
# Fetch an arXiv paper into a per-paper directory, in a form ready for
# verbatim, line-addressable reading (Layer-A "quote + location"):
#   - LaTeX source available (most papers): extract *.tex, read them directly.
#   - PDF-only (no source uploaded):        convert to paper.md via pymupdf4llm.
# Prints: substrate type, the directory, and a heading tree with file:line
# anchors so the reader can jump straight to a section and cite `file:line`.
#
# Idempotent: re-running on a cached id re-prints the manifest without re-downloading.

set -euo pipefail

ID="${1:?usage: fetch_paper.sh <arxiv_id> [cache_dir]}"
# 默认缓存目录 = 仓库根/papers（脚本在 src/ 下，上跳一级），已 gitignore
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
CACHE="${2:-$SCRIPT_DIR/../papers}"
PYREAD_VENV="/home/hexay/projects/agent-tools/paper-read/.venv"

DIR="$CACHE/$ID"
mkdir -p "$DIR"
cd "$DIR"

download() {
  [ -f src ] && return 0
  echo ">> downloading arxiv.org/e-print/$ID" >&2
  curl -sSL -m 90 "https://arxiv.org/e-print/$ID" -o src
}

extract() {
  # Decide substrate only once (marker file records it).
  [ -f .substrate ] && return 0
  local ft
  ft="$(file -b src)"
  if printf '%s' "$ft" | grep -qi 'PDF'; then
    cp src paper.pdf
    "$PYREAD_VENV/bin/python" -c "
import pymupdf4llm, pathlib
pathlib.Path('paper.md').write_text(pymupdf4llm.to_markdown('paper.pdf'))
" >/dev/null 2>&1
    echo "pdf" > .substrate
  elif printf '%s' "$ft" | grep -qiE 'gzip|tar'; then
    if tar xzf src 2>/dev/null || tar xf src 2>/dev/null; then
      :
    else
      # single gzipped file (usually one .tex)
      gunzip -c src > main.tex
    fi
    # some e-prints are a single bare .tex after gunzip, not tar: detect
    if ! ls ./*.tex >/dev/null 2>&1 && [ -f main.tex ]; then :; fi
    echo "latex" > .substrate
  else
    echo "unknown ($ft)" > .substrate
  fi
}

manifest() {
  local sub; sub="$(cat .substrate)"
  echo "=============================================================="
  echo "paper:     $ID"
  echo "substrate: $sub"
  echo "dir:       $DIR"
  echo "=============================================================="
  case "$sub" in
    latex)
      local main
      main="$(grep -l 'documentclass' ./*.tex 2>/dev/null | head -1 || true)"
      echo "main tex:  ${main:-<none found>}"
      echo "tex files:"; ls -1 ./*.tex 2>/dev/null | sed 's#^\./#  #'
      echo "--- heading tree (file:line  heading) ---"
      grep -rnE '\\(section|subsection|subsubsection)\*?\{' ./*.tex 2>/dev/null \
        | sed -E 's/\\(sub)*section\*?\{/  &/' \
        | sed -E 's/\{(.*)\}.*$/\1/; s/\\(sub)*section\*?//g' || true
      ;;
    pdf)
      echo "markdown:  $DIR/paper.md"
      echo "--- heading tree (line:  heading) ---"
      grep -nE '^#{1,4} ' paper.md | sed -E 's/^([0-9]+):#{1,4} /  L\1  /' || true
      ;;
    *)
      echo "unrecognized e-print format; inspect $DIR/src manually" ;;
  esac
}

download
extract
manifest
