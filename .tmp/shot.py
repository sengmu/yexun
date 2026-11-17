import json, time, base64, sys
import urllib.request
import websocket

PORT = 9233
URL = sys.argv[1]
OUT = sys.argv[2]

def http(path):
    with urllib.request.urlopen(f"http://127.0.0.1:{PORT}{path}", timeout=10) as r:
        return json.loads(r.read().decode())

for _ in range(30):
    try:
        http("/json/version"); break
    except Exception:
        time.sleep(1)

targets = http("/json/list")
page = next((t for t in targets if t.get("type") == "page"), None)
ws = websocket.create_connection(page["webSocketDebuggerUrl"], timeout=60)
_id = 0
def cmd(method, **params):
    global _id
    _id += 1
    ws.send(json.dumps({"id": _id, "method": method, "params": params}))
    while True:
        msg = json.loads(ws.recv())
        if msg.get("id") == _id:
            return msg

cmd("Page.enable")
cmd("Runtime.enable")
cmd("Page.navigate", url=URL)
# wait for engine: poll for canvas with non-zero size, then settle
title = None
for i in range(60):
    time.sleep(2)
    r = cmd("Runtime.evaluate", expression="(()=>{const c=document.querySelector('canvas');return JSON.stringify({t:document.title,canvas:!!c,w:c?c.width:0,h:c?c.height:0})})()", returnByValue=True)
    try:
        val = json.loads(r["result"]["result"]["value"])
        title = val["t"]
        if val["canvas"] and val["w"] > 100:
            print("canvas ready:", val); break
    except Exception as e:
        print("poll err", e)
time.sleep(12)
r = cmd("Page.captureScreenshot", format="png")
data = r["result"]["data"]
open(OUT, "wb").write(base64.b64decode(data))
print("saved", OUT, "title:", title)
ws.close()
