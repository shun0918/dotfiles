---
name: setup-orchestrator
description: 秘書・司令塔（今日やること、司令塔ステータス、feature による実装委任）を、この環境で使えるようにセットアップする。「秘書をセットアップして」と頼まれたときに使う
disable-model-invocation: true
---

# 秘書・司令塔のセットアップ

dotfiles の `dev-orchestrator/` にあるコードは汎用で、会社名・個人の ID・Docs の URL は入っていない。
この skill は、この環境だけの設定を聞いて生成し、動作を確かめるところまでを行う。生成物は手元だけに置き、dotfiles には入れない。

## 守ること

- 会社名・個人の ID・Docs の URL・メールアドレスを、dotfiles のリポジトリ側のファイルに書かない。書くのは `~/.config/dev-orchestrator/` と `~/.pr-reviews/config.json` だけ。
- AI が GitHub に投稿する設定にしない（`post_ai_reviews` は false のまま）。投稿するかどうかは人間が決める。
- 人間の承認なしに、実装を始める設定や、常駐の起動をしない。ログインや認証は人間に頼む（代わりにやらない）。
- Slack・Notion・GitHub・カレンダーへ書き込む設定にしない。読み取りだけ。

## 手順

1. **前提の確認**
   - `command -v claude gh herdr codex python3 git` を実行し、足りないものを一覧にして人間に伝える（codex は無くてもよい。無ければ `use_codex` を false にする）。
   - `gh auth status` を実行する。claude のログインは `claude -p "ok" --max-turns 1` が通るかで確かめる。どちらもログインが必要なら、人間に頼んで止まる。
   - `ls -l ~/.dev-orchestrator/bin` がリンクでなければ、`bash ~/.config/coderv2/dotfiles/install.sh --links-only` を案内する（実行前に人間に確認する）。

2. **ヒアリング**（1回にまとめて聞く。不要なものは飛ばせると伝える）
   - 名前と、所属・役割を1文で（自己紹介に使う）
   - Slack: 自分の user ID、ワークスペースのサブドメイン（使わなければ飛ばす）
   - カレンダー: どのツールで、どの calendarId を対象にするか
   - メモページ・タスクDB（あれば）: ページ ID、DB の名前・条件
   - レビュー: 対象の GitHub org、リポジトリを置いている場所、除外する作者（bot など。既定の dependabot / renovate に追加する分）、稼働する曜日・時間
   - 2つの Docs（今日やること・司令塔ステータス）を新しく作ってよいか

3. **設定の生成**（雛形は `~/.config/coderv2/dotfiles/dev-orchestrator/templates/`）
   - `~/.config/dev-orchestrator/today-context.md` を `today-context.template.md` から作る。答えを埋め、聞いていない項目の行は消す。
   - `~/.config/dev-orchestrator/local.json` を `local.template.json` から作る（docs は次の手順で埋める）。権限は 600 にする。`vars` のうち聞いていない項目（Slack を飛ばしたときの `SLACK_USER_ID` など）は、`<...>` を残さず空文字にする。
   - `~/.pr-reviews/config.json` を `pr-reviews-config.example.json` から作る。`post_ai_reviews` は false のまま。聞いた除外する作者は `skip_authors` に追記する（既定の dependabot / renovate は残す）。
   - `~/.dev-orchestrator/runner-config.json` が無ければ `runner-config.json` を写し、稼働する曜日・時間を答えに合わせる（`window.days` は 0=月曜 … 6=日曜。月〜金なら `[0,1,2,3,4]`。時刻は JST の `"HH:MM"`）。
   - 禁止語リスト `~/.config/dev-orchestrator/denylist.txt` に、会社名・org 名・自分の名前などを1行1語で書く（dotfiles へのコミット前検査に使う。部分一致で調べるので、短すぎる語は避ける。リポジトリには入れない）。
   - 置き換え漏れの確認: `grep -n '<[^>]*>' ~/.config/dev-orchestrator/local.json ~/.config/dev-orchestrator/today-context.md ~/.pr-reviews/config.json` を実行する。docs の `<DOC_ID>` と `<DOC_URL>` は次の手順で埋めるので、それ以外が残っていたら埋めるか消す（日本語の穴 `<レビュー対象の GitHub org>` などもこれで見つかる）。

4. **Docs の作成**
   - Claude Docs のツールで、空の doc を2つ作る（タイトルは「今日やること」「司令塔ステータス」）。
   - それぞれの id と URL を `local.json` の `docs` に書く。書いたあとに、手順3の置き換え漏れの確認をもう一度実行し、0 件にする。
   - Docs のツールが使えない（コネクタ未接続・権限なし・ヘッドレスなど）ときは、作らずに人間に頼んで止まる。ダミーの id を入れて進めない。

5. **動作確認**（書き込みをしない、dry の確認）
   - `~/.dev-orchestrator/bin/push-today --dry`（平日はプロンプトが表示される。土日は何も出さずに終わる。それが正常）
   - `~/.dev-orchestrator/bin/push-status --dry`
   - `~/.local/bin/pr-review-watch --brief`
   - `~/.dev-orchestrator/bin/feature list`
   - どれかが失敗したら、原因を人間に伝えて止まる。

6. **常駐の起動**（人間に確認してから）
   - `~/.dev-orchestrator/bin/ensure-runner` を実行する。
   - 初回の push が成功したか、`~/.dev-orchestrator/state/runner-state.json` で確かめる。

7. **最後に人間へ伝えること**
   - 作ったもの（設定ファイルの場所と、2つの Docs の URL）。
   - 人間が行うこと（claude のログイン期限、gh の認証、Slack・Notion 等のコネクタ接続）。
   - 実装の委任は `feature start <名前> --repo <パス> --task "..."` で始まり、計画の承認は人間が `feature approve <名前>` で行うこと。
