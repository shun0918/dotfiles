---
name: review-dependabot
description: Dependabot PR の changelog を精査し、リポジトリへの影響を分析する
argument-hint: <pr_url_or_number>
allowed-tools: Bash(gh *), Bash(git *), WebFetch, WebSearch, Read, Grep, Glob, Task
---

# Dependabot PR 影響分析

Dependabot が作成した PR の changelog を精査し、対象リポジトリへの影響を分析してコメントする。

## 引数

- `$ARGUMENTS`: 必須。PR の URL または番号（例: `https://github.com/org/repo/pull/135` または `135`）

## 手順

### 1. PR 情報の取得

`gh pr view $ARGUMENTS --json title,body,files` で PR の情報を取得する。

以下を抽出する:

- 更新対象のパッケージ名
- 更新前後のバージョン（例: 7.3.0 → 7.4.0）
- 更新の種類（major / minor / patch）

### 2. Changelog の取得

以下の方法で各パッケージのリリースノート・changelog を取得する:

- PR body に含まれるリリースノートを読む
- 必要に応じて GitHub Releases ページを WebFetch で取得する

以下の観点で情報を整理する:

- 新機能
- バグ修正
- 破壊的変更（Breaking Changes）
- 非推奨化（Deprecations）
- マイグレーション手順

### 3. リポジトリへの影響分析

対象パッケージがリポジトリ内でどう使われているかを調査する:

- `Grep` / `Glob` / `Read` でパッケージの import 箇所・使用パターンを特定
- 必要に応じて `Task`（Explore エージェント）で詳細調査
- 設定ファイル（schema、config 等）も確認

Changelog の各項目について、リポジトリへの影響を以下の3段階で判定する:

- **恩恵あり**: プロジェクトに良い影響がある変更
- **影響なし**: プロジェクトが使っていない機能・DB 等に関する変更
- **要対応**: 破壊的変更などで対応が必要な変更

### 4. PR にコメント

`gh pr comment` で分析結果を PR にコメントする。

#### コメントフォーマット

```
## 影響分析: <パッケージ名> <旧バージョン> → <新バージョン>

### 恩恵

- **<変更名>**: <リポジトリへの具体的な恩恵の説明>

### 影響なし

- **<変更名>**: <対象外である理由>

### 要対応

- **<変更名>**: <必要な対応の説明>

（要対応がない場合はこのセクションを省略）

### 破壊的変更

なし / あり（詳細を記載）

### 結論

リスク（高/中/低）・恩恵（高/中/低）の評価と、マージ可否の判断。
```

#### フォーマットルール

- 日本語で記述する
- 各項目はリポジトリの具体的な使用状況に基づいて記述する（汎用的な説明ではなく）
- 要対応がない場合、そのセクションは省略する
- 過剰な装飾や絵文字は使わない
