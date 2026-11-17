import json, urllib.request, websocket
with urllib.request.urlopen("http://127.0.0.1:9233/json/list", timeout=10) as r:
    targets = json.loads(r.read().decode())
page = next(t for t in targets if t.get("type") == "page" and "8901" in t.get("url",""))
ws = websocket.create_connection(page["webSocketDebuggerUrl"], timeout=30)
ws.send(json.dumps({"id":1,"method":"Runtime.evaluate","params":{"expression":"JSON.stringify({url:location.href,title:document.title,body:(document.body?document.body.innerText.slice(0,120):'')})","returnByValue":True}}))
while True:
    m = json.loads(ws.recv())
    if m.get("id")==1:
        print(m["result"]["result"].get("value")); break
ws.close()
