---
name: update-pr
description: 現在のブランチの PR 本文を最新の差分に基づいて更新する
disable-model-invocation: true
allowed-tools: Bash(git *), Bash(gh *)
---

# Pull Request 本文の更新

現在のブランチに紐づく PR の本文を、最新の差分をもとに再生成して更新する。

> **関連スキル**: `create-pr` と PR 本文のフォーマットを共有している。このファイルを修正する際は `create-pr/SKILL.md` も確認・修正すること。

## 手順

### 1. 情報収集

以下を並列で実行:

- `gh pr view --json number,title,body`（現在の PR 情報を取得）
- `git log main..HEAD --oneline`（ブランチ上の全コミット一覧）
- `git diff main...HEAD`（main からの全変更差分）

PR が見つからない場合はエラーメッセージを返して終了する。

### 2. PR 本文の再生成

現在の PR 本文と最新の差分を照らし合わせ、PR 本文を再生成する。

フォーマットは `create-pr` スキルの「3. PR 本文の作成」に従うこと。

以下の点に注意:

- 関連 Issue のリンクは現在の PR 本文から引き継ぐ
- スクリーンショットや画像リンクは現在の PR 本文から引き継ぐ
- テストケースのチェック状態（`[x]`）は現在の PR 本文から引き継ぐ
- 差分の変化に応じてテストケースの追加・削除は行ってよい

### 3. 含めないもの

`create-pr` スキルの「4. 含めないもの」に従う。

### 4. PR の更新

- `gh pr edit <number> --body` で PR 本文を更新する。HEREDOC で body を渡すこと
- 更新後、PR の URL をユーザーに返す
