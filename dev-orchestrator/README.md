# dev-orchestrator

AI 秘書・司令塔・PR レビュー・実装委任（`feature`）の仕組み。Coder 上で常駐ランナーが動かす。
このディレクトリには**汎用のコードと雛形だけ**を置く。会社名・個人の ID・Docs の URL は入れない。

## 置き場所とリンク

`install.sh` が、次をリンクする（状態・ログ・固有の設定は、リンク先のディレクトリに残り、ここには入らない）。

| ここ | リンク先 |
|---|---|
| `orchestrator/{bin,lib,prompts,roles}` | `~/.dev-orchestrator/` |
| `pr-reviews/{bin,prompts,schemas}` | `~/.pr-reviews/` |

固有の設定は手元だけ: `~/.config/dev-orchestrator/`（`local.json`、`today-context.md`、`denylist.txt`）と `~/.pr-reviews/config.json`。

## 新しい環境で使い始める

1. dotfiles を入れる（Coder の dotfiles 機能、または `install.sh`）。
2. Claude に「秘書をセットアップして」と頼む（`setup-orchestrator` skill）。聞かれたことに答えると、設定と 2 つの Docs が作られる。

## 固有の値を誤ってコミットしない

`scripts/check-private.sh` が、コミット前（pre-commit）に固定のパターンと、手元の禁止語リストを検査する。`--all` で全ファイルを検査できる。

## 守っていること

- AI は GitHub に投稿しない・push しない（`post_ai_reviews` の既定は false）。
- 自動で起動するのは読み取りだけ。実装は人間が `feature approve` したあとに始まる。
