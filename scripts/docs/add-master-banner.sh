#!/usr/bin/env bash
# Puts a one-line pointer to the MeoArch master doc at the top of every (non-generated) Markdown file in every repo.
# Idempotent (marker comment), skips files that start with YAML front matter. Commits nothing; review with git diff.
set -euo pipefail
. "$(dirname "$0")/lib.sh"
LINE="> 📚 [MeoArch 主文档 / Master Doc]($MEO_MASTER_URL)：全部仓库地图、操作手册、Cloudflare 清单、全部文档链接。<!-- $MEO_MARK -->"
n=0
for r in $MEO_REPOS; do
  d="$MEO_PROJECTS/$r"; [ -d "$d/.git" ] || continue
  while IFS= read -r f; do
    [ -n "$f" ] || continue; p="$d/$f"
    grep -q "$MEO_MARK" "$p" && continue
    head -c3 "$p" | grep -q '^---' && continue
    cr=""; head -1 "$p" | grep -q $'\r' && cr=$'\r'
    { printf '%s%s\n%s\n' "$LINE" "$cr" "$cr"; cat "$p"; } > "$p.tmp" && mv "$p.tmp" "$p"
    n=$((n+1))
  done < <(meo_md_files "$d" banner)
done
echo "bannered $n files"
