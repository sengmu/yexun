import os, socket, threading, urllib.parse, base64, sys
u = urllib.parse.urlparse(os.environ.get("HTTPS_PROXY",""))
UP = (u.hostname, u.port or 3128)
auth = ""
if u.username:
    auth = "Proxy-Authorization: Basic " + base64.b64encode(f"{u.username}:{urllib.parse.unquote(u.password or '')}".encode()).decode() + "\r\n"
def handle(c):
    try:
        buf = b""
        while b"\r\n\r\n" not in buf:
            d = c.recv(4096)
            if not d: c.close(); return
            buf += d
        line = buf.split(b"\r\n")[0].decode(errors="replace")
        parts = line.split(" ")
        if parts[0].upper() == "CONNECT":
            target = parts[1]
            s = socket.create_connection(UP, timeout=20)
            s.sendall(f"CONNECT {target} HTTP/1.1\r\nHost: {target}\r\n{auth}\r\n".encode())
            resp = b""
            while b"\r\n\r\n" not in resp:
                d = s.recv(4096)
                if not d: break
                resp += d
            head, _, rest = resp.partition(b"\r\n\r\n")
            if b" 200" not in head.split(b"\r\n")[0]:
                c.sendall(b"HTTP/1.1 502 Bad Gateway\r\n\r\n"); c.close(); s.close(); return
            c.sendall(b"HTTP/1.1 200 Connection Established\r\n\r\n")
            if rest: c.sendall(rest)
            def pump(a,b):
                try:
                    while True:
                        d = a.recv(65536)
                        if not d: break
                        b.sendall(d)
                except Exception: pass
                try: b.shutdown(socket.SHUT_WR)
                except Exception: pass
            threading.Thread(target=pump,args=(c,s),daemon=True).start()
            pump(s,c)
        else:
            # plain HTTP: forward request to upstream proxy as-is with auth injected
            s = socket.create_connection(UP, timeout=20)
            head, _, rest = buf.partition(b"\r\n\r\n")
            lines = head.decode(errors="replace").split("\r\n")
            lines.insert(1, auth.strip())
            s.sendall(("\r\n".join(lines)+"\r\n\r\n").encode() + rest)
            while True:
                d = s.recv(65536)
                if not d: break
                c.sendall(d)
            s.close(); c.close()
    except Exception as e:
        try: c.close()
        except Exception: pass
srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
srv.bind(("127.0.0.1", 18080)); srv.listen(50)
print("fwdproxy listening 18080 ->", UP, flush=True)
while True:
    c, _ = srv.accept()
    threading.Thread(target=handle, args=(c,), daemon=True).start()
