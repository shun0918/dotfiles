---
name: nippo
description: 日報を生成・更新する
disable-model-invocation: true
---

日報を生成・更新する。

以下のコマンドを実行して日報を生成してください。
スクリプトは `~/.config/nippo/config` から出力先やユーザー名を読み込む。

```bash
NIPPO_DIR="${NIPPO_DIR:-$(ghq root)/shun0918/nippo}" && "$NIPPO_DIR/scripts/generate-report.sh" $ARGUMENTS
```

- 引数なしの場合は当日の日報を生成
- 日付が指定された場合はその日付の日報を生成（例: `2026-02-14`）

実行後、生成されたレポートファイルの内容を表示してください。
