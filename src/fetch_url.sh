#!/usr/bin/env bash
# fetch_url.sh <safe_id> <pdf_url> [cache_dir]
#
# Same contract as fetch_paper.sh, but for non-arXiv full texts that have a
# direct PDF link (ACL Anthology, OpenReview PDF, publisher OA PDF, ...).
# Produces  <cache>/<safe_id>/paper.pdf  and  paper.md  (pymupdf4llm), and prints
# a heading tree with paper.md:Lnn anchors so the reader can cite verbatim.
#
# Idempotent: re-running on a cached id re-prints the manifest without re-downloading.
# Callers should still wrap concurrent use in `flock /tmp/fetch_<id>.lock`.

set -euo pipefail

ID="${1:?usage: fetch_url.sh <safe_id> <pdf_url> [cache_dir]}"
URL="${2:?usage: fetch_url.sh <safe_id> <pdf_url> [cache_dir]}"
# 默认缓存目录 = 仓库根/papers（脚本在 src/ 下，上跳一级），已 gitignore
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
CACHE="${3:-$SCRIPT_DIR/../papers}"
PYREAD_VENV="/home/hexay/projects/agent-tools/paper-read/.venv"

DIR="$CACHE/$ID"
mkdir -p "$DIR"
cd "$DIR"

if [ ! -f paper.pdf ]; then
  echo ">> downloading $URL" >&2
  curl -sSL -m 120 -A "Mozilla/5.0" "$URL" -o paper.pdf
  if ! file -b paper.pdf | grep -qi 'PDF'; then
    echo "ERROR: downloaded content is not a PDF; inspect $DIR/paper.pdf" >&2
    exit 1
  fi
fi

if [ ! -f paper.md ]; then
  "$PYREAD_VENV/bin/python" -c "
import pymupdf4llm, pathlib
pathlib.Path('paper.md').write_text(pymupdf4llm.to_markdown('paper.pdf'))
" >/dev/null
fi
echo "pdf" > .substrate

echo "=============================================================="
echo "paper:     $ID"
echo "substrate: pdf"
echo "dir:       $DIR"
echo "=============================================================="
echo "--- heading tree (line:  heading) ---"
grep -nE '^#{1,4} ' paper.md | sed -E 's/^([0-9]+):#{1,4} /  L\1  /' || true
