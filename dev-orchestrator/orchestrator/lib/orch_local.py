"""手元（この環境だけ）の設定を読む。リポジトリには入れない値（Docs の ID、Slack の ID、会社名など）は、
すべて ~/.config/dev-orchestrator/ に置く。最初の生成は setup-orchestrator skill が行う。"""
import json, sys
from pathlib import Path

LOCAL_DIR = Path.home() / ".config" / "dev-orchestrator"
LOCAL_JSON = LOCAL_DIR / "local.json"


def local():
    try:
        return json.loads(LOCAL_JSON.read_text())
    except Exception:
        sys.exit(f"手元の設定 {LOCAL_JSON} がありません。Claude に「秘書をセットアップして」と頼んで、setup-orchestrator skill で作ってください。")


def doc(name):
    """name は today / status。戻り値は (doc_id, doc_url)。"""
    d = local().get("docs", {}).get(name)
    if not d or not d.get("id") or not d.get("url"):
        sys.exit(f"{LOCAL_JSON} の docs.{name} (id, url) がありません。setup-orchestrator skill で作ってください。")
    return d["id"], d["url"]


def fill(text, extra=None):
    """{{KEY}} を local.json の vars と、context ファイルで埋める。"""
    cfg = local()
    vals = dict(cfg.get("vars", {}))
    vals.update(extra or {})
    for k in ("today", "status"):
        d = cfg.get("docs", {}).get(k, {})
        vals.setdefault(f"{k.upper()}_URL", d.get("url", ""))
    ctx = LOCAL_DIR / "today-context.md"
    vals.setdefault("LOCAL_CONTEXT", ctx.read_text().strip() if ctx.exists() else "（手元の前提情報はありません）")
    for k, v in vals.items():
        text = text.replace("{{" + k + "}}", str(v))
    return text
