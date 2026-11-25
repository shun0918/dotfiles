# ~/.bashrc の先頭から読み込まれる。シェルが始まるたびに、常駐ランナーが止まっていれば起動する。
# ワークスペースが再起動した後、最初の接続（coder ssh、ターミナル、Claude からの操作）で復帰させるためのもの。
# 何度呼ばれても安全（ensure-runner が排他を取る）。ランナーが動いていれば、すぐ終わる。
_dev_orch_autostart() {
    [ -n "${HERDR_ENV:-}" ] && return 0          # herdr のペインの中では起動しない（ランナー自身のペインで繰り返してしまうため）
    [ -f "$HOME/.config/dev-orchestrator/local.json" ] || return 0   # 設定済みの環境だけ
    [ -x "$HOME/.dev-orchestrator/bin/ensure-runner" ] || return 0
    command -v flock >/dev/null 2>&1 || return 0
    # シェルから切り離して実行する（接続が終わっても続き、ジョブの表示も出ない）。同時に呼ばれたら1つだけが走る。
    setsid -f bash -c 'exec 8>"$HOME/.dev-orchestrator/autostart.lock"; flock -n 8 || exit 0; "$HOME/.dev-orchestrator/bin/ensure-runner"' >/dev/null 2>&1 </dev/null
}
_dev_orch_autostart
unset -f _dev_orch_autostart
