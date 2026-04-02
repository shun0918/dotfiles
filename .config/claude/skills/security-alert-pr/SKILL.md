---
name: security-alert-pr
description: DependabotなどのSecurity Alertに対応するPRを自動作成する。Transitive dependencyなど、Dependabotが自動でPRを作成できない場合に使用。
disable-model-invocation: true
argument-hint: <security_alert_url_or_package_name[@version]>
allowed-tools: Bash(git *), Bash(gh *), Bash(docker compose exec frontend yarn *)
---

# Security Alert PR 作成

脆弱性が検出されたパッケージを安全なバージョンに更新し、Pull Request を作成する。

## 引数

- `$ARGUMENTS`: 必須。以下のいずれかを指定する
  - GitHub Security Alert の URL（例: `https://github.com/org/repo/security/dependabot/123`）
  - パッケージ名とバージョン（例: `basic-ftp@5.2.0`）
  - パッケージ名のみ（例: `basic-ftp`）

## 手順

### 1. 対象パッケージとバージョンの特定

引数の形式に応じて処理を分岐する:

- **Security Alert URL の場合**: `gh api` で脆弱性情報を取得し、対象パッケージ名と推奨バージョンを確認する
- **`パッケージ名@バージョン` の場合**: そのまま使用する
- **パッケージ名のみの場合**: `docker compose exec frontend yarn npm info <パッケージ名>` で最新の安定バージョン（`dist-tags.latest`）を確認してユーザーに提示し、使用バージョンを確定する

### 2. 依存チェーンの調査

以下を並列で実行する:

- `docker compose exec frontend yarn why <パッケージ名>` で依存チェーンを確認
- `package.json` の `resolutions` フィールドに既に同パッケージの記載がないか確認

依存チェーンを遡り、`package.json` の `dependencies` / `devDependencies` のどのライブラリが起点になっているかを特定する。

起点ライブラリに応じて影響範囲を判断する:
- `devDependencies` 起点 → 本番バンドルに含まれない（CI環境のみで使用）
- `dependencies` 起点 → 本番バンドルへの影響を確認する

### 3. 対応方法の判断

- **直接依存の場合**: `package.json` の `dependencies` / `devDependencies` の該当バージョンを更新する
- **間接依存（transitive dependency）の場合**: `package.json` の `resolutions` フィールドに追加する

Dependabot が自動 PR を作成できないのは基本的に間接依存のケースであるため、`resolutions` での固定が主な対応手段となる。

### 4. 修正の実施

#### 間接依存の場合（`resolutions` を追加）

`frontend/package.json` の `resolutions` フィールドに追記する:

```json
"resolutions": {
  ...（既存エントリ）,
  "<パッケージ名>": "<バージョン>"
}
```

#### 直接依存の場合

`frontend/package.json` の `dependencies` または `devDependencies` の該当バージョンを更新する。

#### yarn.lock の更新

```bash
docker compose exec frontend yarn install
```

実行後、`yarn.lock` で対象パッケージが指定バージョンに更新されていることを確認する。

### 5. ブランチの作成とコミット

- `master` ブランチにいる場合は新しいブランチを作成する（例: `fix/upgrade-<パッケージ名>-<バージョン>`）
- 変更をコミットし、リモートにプッシュする

### 6. PR の作成

以下の構成で PR 本文を組み立てる。**日本語**で記述すること。

```
## ユーザーから見た変更

### 非機能
- <パッケージ名> パッケージの脆弱性が修正されたバージョンに更新された

## 実装詳細

### 依存チェーン

（yarn why の結果をもとに依存ツリーを ASCII で記述）

### 影響範囲

以下の観点で分析して記述:
- package.json のどのライブラリが起点か（直接依存 / devDependencies など）
- 本番ビルドのバンドルに含まれるか
- 脆弱性が実際に悪用されるシナリオがあるか（get-uri が basic-ftp を使うのは ftp:// スキームの場合のみ、など）
- 動作確認が必要な場合はどこを確認するか

### 対応方法

（直接依存の更新 / resolutions による固定のどちらを選んだか、理由とともに記述）

## テストケース
- [ ] 動作確認が必要な箇所（影響範囲が CI のみなら該当ステップ、本番バンドルに含まれるなら関連する画面など）
```

- `gh pr create --draft` で Draft PR として作成する。HEREDOC で body を渡すこと
- PR タイトルは70文字以内で簡潔に（例: `fix: <パッケージ名> を <バージョン> にアップグレード（脆弱性対応）`）
- 作成後、PR の URL をユーザーに返す
