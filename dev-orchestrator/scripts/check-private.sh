#!/usr/bin/env bash
# リポジトリに入れてはいけない値（会社名・個人の ID・Docs の URL など）が混ざっていないか調べる。
#   check-private.sh          コミット予定（staged）の中身を調べる（pre-commit フックとして使う）
#   check-private.sh --all    追跡中のファイル全部を調べる
# 検査は2種類:
#   1. 固定のパターン（Docs/artifact の URL、Slack の ID、UUID、メールアドレス）
#   2. 手元だけの禁止語リスト ~/.config/dev-orchestrator/denylist.txt（1行1語。リポジトリには入れない）
set -u
cd "$(git rev-parse --show-toplevel)" || exit 2
SCOPE=(dev-orchestrator .config/claude/skills/setup-orchestrator)
DENYLIST="$HOME/.config/dev-orchestrator/denylist.txt"
PATTERNS='claude\.ai/artifact/[A-Za-z0-9]+|\bU[0-9A-Z]{9,}\b|[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}|[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}'
if [ "${1:-}" = "--all" ]; then
  files=$(git ls-files -- "${SCOPE[@]}"); show() { cat -- "$1"; }
else
  files=$(git diff --cached --name-only --diff-filter=ACM -- "${SCOPE[@]}"); show() { git show ":$1"; }
fi
bad=0
for f in $files; do
  out=$(show "$f" | grep -nE "$PATTERNS" | grep -vE 'example\.com|noreply@' )
  if [ -n "$out" ]; then echo "[固定パターン] $f"; echo "$out" | head -5 | sed 's/^/    /'; bad=1; fi
  if [ -s "$DENYLIST" ]; then
    out=$(show "$f" | grep -niFf "$DENYLIST")
    if [ -n "$out" ]; then echo "[禁止語] $f"; echo "$out" | head -5 | sed 's/^/    /'; bad=1; fi
  fi
done
[ "$bad" = 1 ] && { echo "固有の値が混ざっています。手元の設定（~/.config/dev-orchestrator/）に移してください。"; exit 1; }
exit 0
