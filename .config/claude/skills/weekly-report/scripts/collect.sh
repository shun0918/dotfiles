#!/usr/bin/env bash
# weekly-report のデータ収集。
# 期間内にマージされた PR (author 不問)・open PR (draft 含む)・open issue を gh CLI で集計し、
# 区切り付きで stdout に出す。解釈・深掘り・markdown 化は呼び出し側 (Claude) が行う。
#
# 使い方: collect.sh [SINCE]   (SINCE は YYYY-MM-DD。省略時は 7 日前)
set -euo pipefail

# 省略時は 7 日前 (YYYY-MM-DD) をローカル TZ で算出する。ユーザーの「直近 1 週間」はローカル感覚なので
# UTC ではなくローカル基準にする (GitHub の date qualifier は日付のみ渡すと UTC 00:00 扱いになり
# 下端で最大 TZ ぶんずれ得るが、日次粒度の週次レポートでは許容)。
# date の引数形式が macOS(BSD) と Linux(GNU) で違うため両対応 (BSD を先に試し、失敗したら GNU)。
if [ $# -ge 1 ]; then
  SINCE="$1"
elif SINCE=$(date -v-7d +%Y-%m-%d 2>/dev/null); then
  :
else
  SINCE=$(date -d "7 days ago" +%Y-%m-%d)
fi
UNTIL=$(date +%Y-%m-%d)

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

# gh search prs ではなく gh pr list/issue list を使う理由:
#  - current repo を自動解決できる (gh api user / --repo の明示が要らない)
#  - --search に GitHub の qualifier をそのまま渡せる。gh search prs だと
#    マージ日フィルタが --merged フラグ扱いで誤作動し、raw query をクォートで囲むと
#    () でラップされ "Invalid search query" になる罠がある。
#  - 返る JSON に mergedAt が含まれる (gh search prs の JSON には mergedAt が無い)。

echo "REPO=$REPO"
echo "SINCE=$SINCE"
echo "UNTIL=$UNTIL"

# 期間内にマージされた PR。author を絞らない (bot 等の PR も「その他」として 1 行圧縮で報告するため)。
echo "===MERGED_PRS==="
gh pr list --state merged --search "merged:>=$SINCE" \
  --json number,title,author,mergedAt,baseRefName,url --limit 100

# open PR (draft 含む)。作成中の仕事と対応待ち (bot) の検出用。
echo "===OPEN_PRS==="
gh pr list --state open \
  --json number,title,author,isDraft,createdAt,baseRefName,url --limit 100

# open issue。「今後やること」の材料 + 実質完了なのに open のままの issue の検出用。
echo "===OPEN_ISSUES==="
gh issue list --state open --json number,title,createdAt,labels,url --limit 100
