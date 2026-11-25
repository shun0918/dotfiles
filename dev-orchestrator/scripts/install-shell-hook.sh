#!/bin/bash
# ~/.bashrc の先頭に、ランナー自動起動の読み込みを1行足す（既にあれば何もしない）。
set -eu
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RC="$HOME/.bashrc"
[ "$(uname -s)" = Linux ] || exit 0
[ -f "$RC" ] || exit 0
grep -q "dev-orchestrator/scripts/shell-autostart.sh" "$RC" && exit 0
tmp="$(mktemp)"
{ printf '[ -f "%s/shell-autostart.sh" ] && . "%s/shell-autostart.sh"  # dev-orchestrator: ランナーの自動起動\n' "$DIR" "$DIR"; cat "$RC"; } > "$tmp"
cat "$tmp" > "$RC"      # 権限と所有者を保つため、置き換えずに中身だけ書き換える
rm -f "$tmp"
echo "~/.bashrc の先頭にランナーの自動起動を足しました。"
