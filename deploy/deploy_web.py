#!/usr/bin/env python3
"""Deploy the Jiange 3D slice (Godot web export in build/web/) as a Cloudflare
Worker with Static Assets, via the custom.cloudflare connector credential
(same surrogate route as deploy_jiange.py). The short-lived asset-upload JWT
returned by the API is used in-process only and never printed or stored.

Flow (Workers Assets API):
  1. POST /accounts/<id>/workers/scripts/<name>/assets-upload-session {manifest}
  2. POST /accounts/<id>/workers/assets/upload?base64=true  (Bearer = session JWT)
  3. PUT  /accounts/<id>/workers/scripts/<name>             (metadata.assets.jwt)
  4. POST /accounts/<id>/workers/scripts/<name>/subdomain   {enabled: true}
  5. Verify public 200 + asset byte sizes.
"""
import base64
import hashlib
import json
import subprocess
import sys
import urllib.request
from pathlib import Path

sys.path.insert(0, "/opt/muse/skills/custom-connector-setup/bin")
from dynamic_credentials import add_surrogate_to_request, read_json_response

ROOT = Path(__file__).resolve().parent.parent
WEB = ROOT / "build-web"
NAME = "yexun-ch1"
BASE = "https://api.cloudflare.com/client/v4"


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args):
        raise RuntimeError("redirect refused, verify the endpoint")


def api(method, path, json_body=None, data=None, content_type=None, bearer=None, timeout=120):
    url = path if path.startswith("https://") else BASE + path
    headers = {}
    if json_body is not None:
        data = json.dumps(json_body).encode("utf-8")
        headers["Content-Type"] = "application/json"
    if content_type:
        headers["Content-Type"] = content_type
    request = urllib.request.Request(url, data=data, method=method.upper(), headers=headers)
    if bearer is not None:
        request.add_header("Authorization", "Bearer " + bearer)
    else:
        add_surrogate_to_request(request, "custom.cloudflare", allowed_hosts=["api.cloudflare.com"])
    opener = urllib.request.build_opener(NoRedirect())
    try:
        with opener.open(request, timeout=timeout) as response:
            return response.status, read_json_response(response)
    except urllib.error.HTTPError as e:
        raw = e.read().decode("utf-8", "replace")
        try:
            body = json.loads(raw)
        except Exception:
            body = raw[:1500]
        return e.code, body


def require_ok(status, body, what):
    if status not in (200, 201, 202) or (isinstance(body, dict) and body.get("success") is False):
        print(f"FAILED {what}: status={status} body={json.dumps(body, ensure_ascii=False)[:800]}")
        sys.exit(1)
    return body["result"]



SHELL_MARKER = "yx-overlay"
LOADING_QUOTES = ["老爷出宫，夜路莫回头", "香未烧完，话未讲完", "锣声未响，轿莫起行", "埕头风大，灯笼看牢", "三更夜巡，借路莫借名"]

SHELL_CSS = """
/* yx-loading: custom loading screen (SP key visual + title + thin bar + quotes) */
body { background-color: #060c17; }
#status { background-color: #060c17; transition: opacity 0.7s ease; }
#status-splash { width: 100%; height: 100%; max-width: none; max-height: none; object-fit: cover; filter: brightness(0.5) saturate(0.85); }
#status-progress { -webkit-appearance: none; appearance: none; height: 3px; width: 46%; background: rgba(255,255,255,0.18); border: none; z-index: 3; }
#status-progress::-webkit-progress-bar { background: rgba(255,255,255,0.18); }
#status-progress::-webkit-progress-value { background: #c9a86a; }
#status-progress::-moz-progress-bar { background: #c9a86a; }
#yx-overlay { position: absolute; left: 0; right: 0; top: 0; bottom: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; z-index: 2; pointer-events: none; font-family: "LXGW WenKai", "KaiTi", "STKaiti", "Noto Serif SC", serif; }
#yx-title { font-size: 64px; letter-spacing: 0.35em; margin-left: 0.35em; color: #a8eeeb; text-shadow: 0 2px 24px rgba(0,0,0,0.85); }
#yx-sub { margin-top: 16px; font-size: 19px; letter-spacing: 0.3em; margin-left: 0.3em; color: #d8b777; text-shadow: 0 1px 10px rgba(0,0,0,0.8); }
#yx-quote { position: absolute; left: 0; right: 0; bottom: 16.5%; text-align: center; font-size: 17px; letter-spacing: 0.22em; color: #c7d3e0; text-shadow: 0 1px 8px rgba(0,0,0,0.9); transition: opacity 0.4s ease; }
#yx-pct { position: absolute; left: 0; right: 0; bottom: 12.6%; text-align: center; font-size: 13px; letter-spacing: 0.2em; color: #93a7bd; }
"""

SHELL_OVERLAY = """
			<div id="yx-overlay">
				<div id="yx-title">夜 巡</div>
				<div id="yx-sub">夜巡 · 潮汕民俗恐怖解谜</div>
				<div id="yx-quote"></div>
				<div id="yx-pct"></div>
			</div>"""

SHELL_SCRIPT = """
		<script>
(function () {
	var quotes = __QUOTES__;
	var qEl = document.getElementById('yx-quote');
	var pctEl = document.getElementById('yx-pct');
	var prog = document.getElementById('status-progress');
	var qi = 0;
	if (qEl) {
		qEl.textContent = quotes[0];
		setInterval(function () {
			qEl.style.opacity = '0';
			setTimeout(function () {
				qi = (qi + 1) % quotes.length;
				qEl.textContent = quotes[qi];
				qEl.style.opacity = '1';
			}, 420);
		}, 3000);
	}
	var timer = setInterval(function () {
		if (!document.getElementById('status')) { clearInterval(timer); return; }
		if (prog && pctEl && prog.max > 0) {
			pctEl.textContent = '加载中 ' + Math.round(prog.value / prog.max * 100) + '%';
		}
	}, 120);
}());
		</script>
	</body>"""


def patch_shell():
    """Inject the game's own loading screen into the Godot web shell.

    The default template only offers #status / #status-progress hooks, so the
    loading UI lives at shell level: SP key visual as the splash, a thin gold
    progress bar (the template's own <progress>, restyled), rotating
    self-coined Chaoshan-flavoured lines, and a fade-out on load completion.
    Runs before the asset manifest is built; idempotent across re-deploys.
    """
    bg = ROOT / "game" / "art" / "opening_kv.png"
    if bg.exists():
        (WEB / "loading_bg.png").write_bytes(bg.read_bytes())
    html_path = WEB / "index.html"
    html = html_path.read_text(encoding="utf-8")
    if SHELL_MARKER in html:
        print("shell already patched (custom loading screen present)")
        return

    def swap(old, new):
        nonlocal html
        if old not in html:
            print("FAILED shell patch, anchor not found:", old[:60])
            sys.exit(1)
        html = html.replace(old, new, 1)

    swap('<img id="status-splash" src="index.png" alt="">',
         '<img id="status-splash" src="loading_bg.png" alt="">')
    swap("</style>", SHELL_CSS + "		</style>")
    swap('<div id="status-notice"></div>',
         '<div id="status-notice"></div>' + SHELL_OVERLAY)
    swap("statusOverlay.remove();",
         "statusOverlay.style.opacity = '0';\n"
         "\t\t\tsetTimeout(function () { if (statusOverlay.parentNode) { statusOverlay.remove(); } }, 750);")
    swap("</body>", SHELL_SCRIPT.replace("__QUOTES__", json.dumps(LOADING_QUOTES, ensure_ascii=False)))
    html_path.write_text(html, encoding="utf-8")
    print("shell patched: custom loading screen injected")


def main():
    patch_shell()
    files = sorted(p for p in WEB.rglob("*") if p.is_file())
    manifest = {}
    contents = {}
    chunk_limit = 20 * 1024 * 1024  # stay under the 25 MiB per-asset limit
    for p in files:
        rel = "/" + p.relative_to(WEB).as_posix()
        data = p.read_bytes()
        if len(data) <= chunk_limit:
            h = hashlib.sha256(data).hexdigest()[:32]
            manifest[rel] = {"hash": h, "size": len(data)}
            contents[h] = data
        else:
            n_parts = (len(data) + chunk_limit - 1) // chunk_limit
            for i in range(n_parts):
                part = data[i * chunk_limit:(i + 1) * chunk_limit]
                h = hashlib.sha256(part).hexdigest()[:32]
                manifest[f"{rel}.part{i}"] = {"hash": h, "size": len(part)}
                contents[h] = part
            print(f"split {rel} ({len(data)} bytes) into {n_parts} parts; worker stitches them back")
    print(f"manifest: {len(manifest)} files, {sum(len(v) for v in contents.values())} bytes")

    status, body = api("GET", "/accounts")
    acct = require_ok(status, body, "GET /accounts")[0]["id"]

    status, body = api("POST", f"/accounts/{acct}/workers/scripts/{NAME}/assets-upload-session",
                       json_body={"manifest": manifest})
    session = require_ok(status, body, "assets-upload-session")
    jwt = session["jwt"]
    buckets = session.get("buckets", [])
    print(f"upload session ok; buckets={len(buckets)}")

    # Per-file Content-Type for uploads. Assets stored as octet-stream are
    # served back as octet-stream, which makes browsers download index.html
    # instead of rendering it. Split .partN chunks keep octet-stream (the
    # worker stitches them and sets the real type itself).
    MIME_BY_EXT = {
        ".html": "text/html; charset=utf-8",
        ".js": "text/javascript; charset=utf-8",
        ".wasm": "application/wasm",
        ".png": "image/png",
        ".jpg": "image/jpeg",
        ".jpeg": "image/jpeg",
        ".svg": "image/svg+xml",
        ".json": "application/json",
        ".css": "text/css; charset=utf-8",
        ".ico": "image/x-icon",
        ".apk": "application/vnd.android.package-archive",
    }
    hash_to_path = {}
    for rel, info in manifest.items():
        hash_to_path[info["hash"]] = rel

    def mime_for_hash(h):
        rel = hash_to_path.get(h, "")
        if ".part" in rel:
            return "application/octet-stream"
        dot = rel.rfind(".")
        if dot >= 0:
            return MIME_BY_EXT.get(rel[dot:].lower(), "application/octet-stream")
        return "application/octet-stream"

    completion_jwt = jwt
    for bucket in buckets:
        boundary = "----sliceassets7d3f"
        parts = []
        for h in bucket:
            b64 = base64.b64encode(contents[h]).decode("ascii")
            parts.append(
                f"--{boundary}\r\nContent-Disposition: form-data; name=\"{h}\"; filename=\"{h}\"\r\n"
                f"Content-Type: {mime_for_hash(h)}\r\n\r\n{b64}\r\n"
            )
        payload = ("".join(parts) + f"--{boundary}--\r\n").encode("utf-8")
        status, body = api("POST", f"/accounts/{acct}/workers/assets/upload?base64=true",
                           data=payload, content_type=f"multipart/form-data; boundary={boundary}",
                           bearer=jwt, timeout=900)
        result = require_ok(status, body, "assets upload")
        if isinstance(result, dict) and result.get("jwt"):
            completion_jwt = result["jwt"]
        print(f"uploaded bucket of {len(bucket)} assets (status {status})")

    worker_js = (ROOT / "deploy" / "worker.js").read_text(encoding="utf-8")
    boundary = "----sliceworker9a1b"
    meta = json.dumps({
        "main_module": "worker.js",
        "compatibility_date": "2024-11-01",
        "assets": {"jwt": completion_jwt, "binding": "ASSETS",
                   "config": {"run_worker_first": True}},
        "bindings": [{"name": "ASSETS", "type": "assets"}],
    })
    body_bytes = (
        f"--{boundary}\r\nContent-Disposition: form-data; name=\"metadata\"; filename=\"metadata.json\"\r\nContent-Type: application/json\r\n\r\n{meta}\r\n"
        f"--{boundary}\r\nContent-Disposition: form-data; name=\"worker.js\"; filename=\"worker.js\"\r\nContent-Type: application/javascript+module\r\n\r\n{worker_js}\r\n"
        f"--{boundary}--\r\n"
    ).encode("utf-8")
    status, body = api("PUT", f"/accounts/{acct}/workers/scripts/{NAME}",
                       data=body_bytes, content_type=f"multipart/form-data; boundary={boundary}")
    require_ok(status, body, "PUT worker script")
    print("worker script uploaded")

    status, body = api("POST", f"/accounts/{acct}/workers/scripts/{NAME}/subdomain",
                       json_body={"enabled": True, "previews_enabled": False})
    require_ok(status, body, "enable subdomain")
    status, body = api("GET", f"/accounts/{acct}/workers/subdomain")
    sub = require_ok(status, body, "GET workers subdomain")["subdomain"]
    url = f"https://{NAME}.{sub}.workers.dev/"
    print("url:", url)

    def fetch(path):
        out = subprocess.run(["curl", "-s", "-o", "/tmp/slice_check.bin", "-w", "%{http_code} %{size_download}", url.rstrip("/") + path],
                             capture_output=True, text=True, timeout=300)
        return out.stdout.strip()

    print("GET /           ->", fetch("/"))
    print("GET /index.wasm ->", fetch("/index.wasm"), "local bytes:", (WEB / "index.wasm").stat().st_size)
    print("GET /index.pck  ->", fetch("/index.pck"), "local bytes:", (WEB / "index.pck").stat().st_size)
    print("GET /index.js   ->", fetch("/index.js"), "local bytes:", (WEB / "index.js").stat().st_size)


if __name__ == "__main__":
    main()
