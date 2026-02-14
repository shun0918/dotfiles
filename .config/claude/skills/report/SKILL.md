---
name: report
description: 本日の作業報告を生成する（マージ済み PR → 完了、未マージ PR → 仕掛かり）
disable-model-invocation: true
allowed-tools: Bash(gh *), Bash(mkdir *), Write, Read
---

# 日次作業報告の生成

本日マージした PR と本日作成した未マージの PR を GitHub から取得し、作業報告を生成する。

## 手順

### 1. リポジトリ情報の取得

以下を並列で実行:

- `gh repo view --json nameWithOwner -q .nameWithOwner` で リポジトリ名を取得
- `gh pr list --search "merged:$(date +%Y-%m-%d)" --state merged --json number,title,url` で本日マージされた PR を取得
- `gh pr list --search "created:$(date +%Y-%m-%d)" --state open --json number,title,url` で本日作成されて未マージの PR を取得

### 2. レポートファイルの作成

出力先: リポジトリルートからの相対パスで `tmp/reports/YYYYMMDD/report.md`（YYYYMMDD は本日の日付）

`mkdir -p` でディレクトリを作成してから Write ツールでファイルを書き出す。

### 3. レポートのフォーマット

Slack に貼り付けて使うため、Slack の mrkdwn 記法に準拠する。

```
*日次作業報告 YYYY/MM/DD*
リポジトリ: `owner/repo`

*完了した作業*
- <PR_URL|#番号 PRタイトル>
- <PR_URL|#番号 PRタイトル>

*仕掛かり中の作業*
- <PR_URL|#番号 PRタイトル>
- <PR_URL|#番号 PRタイトル>
```

#### フォーマットルール

- 太字は `*テキスト*`（Slack 記法）
- リンクは `<URL|表示テキスト>`（Slack 記法）
- PR は番号の昇順でソート
- 該当する PR がないセクションは「なし」と記載
- 余計な装飾や絵文字は使わない

### 4. 出力

- ファイルに書き出した後、レポートの内容をそのままユーザーに表示する
- ファイルパスも併せて伝える
