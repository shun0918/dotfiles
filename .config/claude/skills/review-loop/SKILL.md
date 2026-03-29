---
name: review-loop
description: コードレビューループ。CRITICAL/IMPORTANT な指摘がなくなるまで 自動レビュー→修正→コミット を繰り返す
argument-hint: [max_iterations]
allowed-tools: Bash(git *), Bash(codex *), Bash(gh *), Bash(command *), Bash(sleep *), Read, Grep, Glob, Edit, Write, Task
---

# コードレビューループ

現在のブランチの変更に対して、レビュー→修正→コミットのループを回す。
CRITICAL / IMPORTANT な指摘がなくなるか、最大イテレーション数に達するまで繰り返す。

利用可能であれば Codex CLI・GitHub Copilot（PR レビュアー）を追加レビュアーとして活用し、複数の視点を統合する。

## 設計思想

- **スコープ制限**: `git diff main...HEAD` の範囲のみを対象とし、変更前から存在するコードは指摘しない
- **重大度フィルタリング**: CRITICAL / IMPORTANT のみ修正する。LOW は最終レポートに記録するだけ
- **振動検出**: 前イテレーションで修正した箇所が再び指摘された場合、振動（A→B→A）と判定し、現在の状態でロックして次の指摘に進む
- **外部ガイドライン**: プロジェクトルートに `.review-guidelines.md` があればそれを参照する
- **マルチレビュアー**: Codex CLI や GitHub Copilot PR レビューが使える場合は指摘を統合する

## 引数

- `$ARGUMENTS`: 任意。最大イテレーション数（デフォルト: 3）

## 変数

- `MAX_ITER`: $ARGUMENTS が指定されていれば使用、なければ 3
- `ITER`: 現在のイテレーション番号（1 から開始）
- `LOCKED_PATHS`: 振動検出によりロックされたファイルパス一覧
- `PREV_FINDINGS`: 前イテレーションの CRITICAL/IMPORTANT 指摘一覧（振動検出用）
- `USE_CODEX`: Codex CLI が利用可能かどうか（true/false）
- `PR_NUMBER`: GitHub PR 番号（PR が存在する場合）
- `USE_COPILOT_PR`: GitHub Copilot が PR レビュアーとして利用可能かどうか（true/false）

## 手順

### 0. 初期化

以下を並列で実行:

- `git rev-parse --abbrev-ref HEAD` で現在のブランチ名を確認
- `git diff main...HEAD --name-only` で変更されたファイル一覧を取得
- `git diff main...HEAD` で差分全体を取得
- プロジェクトルートに `.review-guidelines.md` があれば Read で読み込む
- `command -v codex` で Codex CLI の有無を確認 → `USE_CODEX` に設定
- `gh pr view --json number 2>/dev/null` で既存の PR を確認 → `PR_NUMBER` に設定

**GitHub Copilot PR レビューの有効化確認**

`PR_NUMBER` が取得できた場合:

```bash
gh api repos/{owner}/{repo}/collaborators/Copilot/permission 2>/dev/null
```

でリポジトリに Copilot がインストールされているか確認する。
`owner/repo` は `gh repo view --json nameWithOwner -q .nameWithOwner` で取得する。
成功（200 応答）した場合は `USE_COPILOT_PR=true` に設定する。

利用可能なレビュアーをユーザーに通知する（例: 「レビュアー: Claude + Codex + GitHub Copilot PR」）。

変更ファイルが0件の場合は「レビュー対象の変更がありません」と伝えて終了する。

### 1. ループ開始（ITER = 1）

以下のサブステップを繰り返す。終了条件は「手順 4」に記載。

#### 1-A. プッシュと差分取得

以下を実行する:

- `git push -u origin HEAD` で現在のブランチをリモートにプッシュする（PR へのプッシュにより Copilot の再レビューが必要なため、毎イテレーションで実行する）
- `git diff main...HEAD` で最新の差分を取得する

`PR_NUMBER` が未設定の場合は PR を作成し、`PR_NUMBER` を取得する:

```bash
gh pr create --title "<ブランチ名>" --body "review-loop による自動レビュー中" --draft
```

#### 1-B. レビュー（Review フェーズ）

利用可能なレビュアーに応じて以下を実行する。Claude のレビューと外部ツールの起動は並列で行う。

**Claude によるレビュー（常に実行）**

差分を精読し、以下の観点で指摘を洗い出す:

- バグ・ロジックエラー
- セキュリティ問題（XSS, SQLi, 秘密情報の露出 など）
- 型・null 安全性
- パフォーマンスの明らかな問題
- コードの可読性・保守性
- テストの欠如または不十分なケース

`.review-guidelines.md` がある場合はそのルールも追加で適用する。

**スコープ制限**: 変更されたファイルの変更箇所のみを対象にすること。差分に含まれない既存コードへの指摘は除外する。

**Codex CLI によるレビュー（`USE_CODEX=true` の場合）**

Claude のレビューと並列で実行する:

```bash
codex review --base main
```

出力結果を収集し、後述の統合フェーズで共通フォーマットに変換する。

**GitHub Copilot PR レビュー（`USE_COPILOT_PR=true` の場合）**

1. Copilot をレビュアーにアサインする:

   ```bash
   gh pr edit $PR_NUMBER --add-reviewer Copilot
   ```

2. Copilot のレビュー完了を待つ。30 秒おきに最大 10 分ポーリングする:

   ```bash
   gh pr view $PR_NUMBER --json reviews --jq '.reviews[] | select(.author.login == "Copilot") | .state'
   ```

   状態が `COMMENTED` または `CHANGES_REQUESTED` になったら完了とみなす。

3. レビューコメントを取得する:

   ```bash
   gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments \
     --jq '[.[] | select(.user.login | startswith("Copilot")) | {path, line, body}]'
   ```

   取得したコメントを共通フォーマットに変換する。

**指摘の統合**

各レビュアーの出力を照合し、重複する指摘はひとつにまとめる（同じファイル・同種の問題は統合し、ソースを付記する）。
統合後の各指摘を以下の構造で列挙する:

```
[SEVERITY] ファイルパス:行番号  (ソース: Claude / Codex / Copilot / 複数)
問題の説明
推奨する修正
```

SEVERITY は `CRITICAL` / `IMPORTANT` / `LOW` のいずれか:

- **CRITICAL**: バグ・セキュリティ・データ破壊リスクなど、マージ前に必ず修正すべきもの
- **IMPORTANT**: 可読性・保守性・テストの欠如など、修正すべきだが即座に壊れるわけではないもの
- **LOW**: スタイル・命名・細かなリファクタリングなど、任意対応でよいもの

複数のレビュアーが同じ問題を指摘した場合は SEVERITY を一段上げることを検討する（LOW → IMPORTANT など）。

#### 1-C. トリアージ（Triage フェーズ）

レビュー結果を確認し、以下を判定する:

1. **振動チェック**: `PREV_FINDINGS` に同じファイルパス＋同種の問題が含まれているか確認する。
   含まれている場合、そのファイルを `LOCKED_PATHS` に追加し、指摘から除外する。
   振動をロックした場合は理由をログに記録する。

2. **修正対象の決定**: CRITICAL と IMPORTANT のうち、`LOCKED_PATHS` に含まれないものを修正対象とする。

修正対象が0件になった場合は「手順 4」へ進む。

#### 1-D. 修正（Fix フェーズ）

修正対象の各指摘に対して:

1. 対象ファイルを Read で読み込む
2. 推奨修正を適用する（Edit を使用）
3. 修正した内容と理由を簡潔にメモする

修正は最小限にとどめる。指摘されていない箇所は変更しない。

#### 1-E. バリデーション（Validate フェーズ）

修正後、修正内容を再確認する:

- 修正が指摘の根本原因を解決しているか（対症療法になっていないか）
- 修正によって新たな問題が生じていないか
- `LOCKED_PATHS` のファイルを誤って変更していないか

問題があれば追加修正する。

#### 1-F. コミット（Commit フェーズ）

修正内容をコミットする:

- `git add` で修正ファイルをステージング（機密ファイルや無関係ファイルは除く）
- コミットメッセージは `review-loop: iter N - <修正内容の要約>` の形式で作成
- `git commit` を実行する

コミット後、`PREV_FINDINGS` を今回の CRITICAL/IMPORTANT 指摘で更新し、`ITER` をインクリメントする。

### 4. 終了判定

以下のいずれかを満たしたらループを終了する:

- 修正対象の CRITICAL/IMPORTANT 指摘が0件になった
- `ITER` が `MAX_ITER` を超えた

ループ終了後、最終レポートを出力する（「手順 5」）。

### 5. 最終レポート

以下の構成で結果をまとめて出力する:

```
## レビューループ完了

- 実施イテレーション数: N / MAX_ITER
- 修正したファイル数: N
- 振動検出によりロックしたファイル: （あれば列挙）

### 修正内容サマリー

各イテレーションで行った修正の概要

### 残存する指摘（LOW）

- ファイルパス:行番号: 指摘内容

### 未解決の指摘（MAX_ITER 到達のため残留）

（MAX_ITER に達して終了した場合のみ記載）
- ファイルパス:行番号: 指摘内容
```
