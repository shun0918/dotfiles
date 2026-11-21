#!/usr/bin/env bash
# 会話を共有しない別の Claude Code セッション (claude -p) に <base>...HEAD の差分をレビューさせる。
#
# usage: claude-review.sh <base-ref>    例: claude-review.sh origin/develop
# exit 0: レビュー完了 (0 件を含む)。exit 1: レビューできなかった。0 件と取り違えないこと
# env: CLAUDE_REVIEW_MODEL (既定 opus)、CLAUDE_REVIEW_EFFORT (既定 xhigh)
set -euo pipefail

base="${1:?usage: claude-review.sh <base-ref>}"
model="${CLAUDE_REVIEW_MODEL:-opus}"
effort="${CLAUDE_REVIEW_EFFORT:-xhigh}"

fail() {
  echo "claude-review: $*" >&2
  exit 1
}

for cmd in claude jq; do
  command -v "$cmd" >/dev/null || fail "$cmd が見つからない"
done

root="$(git rev-parse --show-toplevel)"
cd "$root"

git rev-parse --verify --quiet "${base}^{commit}" >/dev/null || fail "base '$base' が見つからない"
[ -n "$(git diff --name-only "$base"...HEAD)" ] || fail "$base...HEAD に差分が無い"
[ -z "$(git status --porcelain --untracked-files=no)" ] ||
  echo "claude-review: 未コミットの変更あり。レビュアーが読むファイルは作業ツリーの内容になる" >&2

out_dir="${TMPDIR:-/tmp}"
out_dir="${out_dir%/}/claude-review"
mkdir -p "$out_dir"
out="$out_dir/$(basename "$root")-$(date +%Y%m%d-%H%M%S).json"

schema='{
  "type": "object",
  "properties": {
    "findings": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "severity": { "type": "string", "enum": ["CRITICAL", "IMPORTANT", "LOW"] },
          "file": { "type": "string", "description": "リポジトリルートからの相対パス" },
          "line": { "type": "integer", "description": "変更後のファイルの行番号。行に紐づかない指摘は 0" },
          "title": { "type": "string", "description": "問題を 1 行で" },
          "scenario": { "type": "string", "description": "どの入力・状態で何が起きるか" },
          "suggestion": { "type": "string", "description": "推奨する修正" }
        },
        "required": ["severity", "file", "line", "title", "scenario", "suggestion"],
        "additionalProperties": false
      }
    }
  },
  "required": ["findings"],
  "additionalProperties": false
}'

# Bash は渡さない。settings の allow (Bash(git:*) など) が効いて書き込み系のコマンドまで通るため。
# skill・MCP・hook も切る。skill 一覧と MCP で文脈が約 5 倍に膨らみ、SessionStart hook は skill の起動を促す。
{
  cat <<EOF
あなたはこのブランチの変更を書いていないレビュアー。<diff> の差分 ($base...HEAD) をレビューする。<commits> は各コミットのメッセージ。

## 進め方
- 差分だけで判断しない。Read / Grep / Glob で呼び出し元・型・テスト・関連ファイルを読んで裏を取る
- 指摘するのは、変更した行と、その変更が壊す既存コードだけ。変更前からある問題は出さない
- プロジェクトのルール (CLAUDE.md・AGENTS.md・.review-guidelines.md のうちあるもの) と、そこから参照されるガイドラインのうち変更に関係するものに反していないかも見る
- ファイルは変更しない

## 観点
- バグ・ロジックエラー
- セキュリティ (XSS、インジェクション、秘密情報の露出など)
- 型・null 安全性
- 明らかなパフォーマンスの問題
- 可読性・保守性
- テストの欠如・不足

## 重大度
- CRITICAL: バグ・セキュリティ・データ破壊など、マージ前に必ず直すもの
- IMPORTANT: 可読性・保守性・テストの欠如など、直すべきだがすぐには壊れないもの
- LOW: スタイル・命名・細かなリファクタリングなど、任意のもの

## 出力
- scenario には、どの入力・状態で何が起きるかを書く。裏が取れない推測は出さない
- 日本語で書く
- 指摘が無ければ findings は空配列
EOF
  echo
  echo "<commits>"
  git log --format='- %h %s%n%w(0,2,2)%b' "$base"..HEAD
  echo "</commits>"
  echo
  echo "<diff>"
  git diff "$base"...HEAD
  echo "</diff>"
} | claude -p \
  --model "$model" --effort "$effort" \
  --tools "Read,Grep,Glob" --permission-mode dontAsk \
  --disable-slash-commands --strict-mcp-config --no-chrome \
  --settings '{"disableAllHooks":true}' \
  --json-schema "$schema" --output-format json \
  --name "review: $(git rev-parse --abbrev-ref HEAD)" \
  >"$out" || true

if ! jq -e '.is_error == false and (.structured_output.findings | type == "array")' "$out" >/dev/null 2>&1; then
  echo "claude-review: レビューできなかった (出力: $out)" >&2
  jq -r '.result // empty' "$out" >&2 2>/dev/null || head -c 2000 "$out" >&2
  exit 1
fi

jq -r --arg root "$root" '
  "Claude 別セッションのレビュー: \(.structured_output.findings | length) 件 (\(.modelUsage | keys | join(", ")), \(.duration_ms / 1000 | floor) 秒)",
  "セッションを開く: cd \($root) && claude --resume \(.session_id)",
  "",
  (.structured_output.findings[] |
    "[\(.severity)] \(.file):\(.line)  (ソース: Claude 別セッション)",
    .title,
    "起きること: \(.scenario)",
    "推奨: \(.suggestion)",
    "")
' "$out"
