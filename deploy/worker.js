export default {
  async fetch(request, env) {
    try {
      return await handle(request, env);
    } catch (e) {
      return new Response("WORKER_ERROR: " + (e && e.message ? e.message : String(e)), { status: 500 });
    }
  },
};

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".wasm": "application/wasm",
  ".pck": "application/octet-stream",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".svg": "image/svg+xml",
  ".json": "application/json",
  ".css": "text/css; charset=utf-8",
  ".ico": "image/x-icon",
  ".apk": "application/vnd.android.package-archive",
};

function mimeFor(path) {
  const dot = path.lastIndexOf(".");
  if (dot < 0) return null;
  return MIME[path.slice(dot).toLowerCase()] || null;
}

async function handle(request, env) {
  const url = new URL(request.url);
  let path = url.pathname;
  if (path === "/") path = "/index.html";
  const assetRequest = new Request(new URL(path, url), request);
  let response = await env.ASSETS.fetch(assetRequest);

  // The assets platform answers /index.html with a 307 to "/" (html
  // handling). With run_worker_first that would loop ("/" is rewritten to
  // /index.html here), so follow asset redirects internally, up to 3 hops.
  for (let hop = 0; hop < 3 && response.status >= 300 && response.status < 400; hop++) {
    const loc = response.headers.get("location");
    if (!loc) break;
    const nextPath = new URL(loc, url).pathname;
    response = await env.ASSETS.fetch(new Request(new URL(nextPath, url)));
    if (response.status === 200) path = nextPath === "/" ? "/index.html" : nextPath;
  }

  // Large files are stored split into <path>.partN chunks (per-file asset
  // size limit). Stitch them back together transparently.
  if (response.status === 404 && !path.endsWith(".html")) {
    const parts = [];
    for (let i = 0; i < 8; i++) {
      const partUrl = new URL(path + ".part" + i, url);
      const part = await env.ASSETS.fetch(new Request(partUrl));
      if (part.status !== 200) break;
      parts.push(part);
    }
    if (parts.length > 0) {
      let total = 0;
      for (const p of parts) total += Number(p.headers.get("content-length") || 0);
      const stream = new ReadableStream({
        async start(controller) {
          for (const p of parts) {
            const reader = p.body.getReader();
            for (;;) {
              const { done, value } = await reader.read();
              if (done) break;
              controller.enqueue(value);
            }
          }
          controller.close();
        },
      });
      const headers = new Headers();
      if (path.endsWith(".wasm")) headers.set("content-type", "application/wasm");
      if (path.endsWith(".apk")) headers.set("content-type", "application/vnd.android.package-archive");
      if (total > 0) headers.set("content-length", String(total));
      headers.set("Cross-Origin-Opener-Policy", "same-origin");
      headers.set("Cross-Origin-Embedder-Policy", "require-corp");
      return new Response(stream, { status: 200, headers });
    }
  }

  const headers = new Headers(response.headers);
  // Workers Assets serves these files as application/octet-stream, which
  // makes browsers download the HTML instead of rendering it. Force the
  // correct Content-Type per extension.
  const mime = mimeFor(path);
  if (mime) headers.set("Content-Type", mime);
  headers.set("Cross-Origin-Opener-Policy", "same-origin");
  headers.set("Cross-Origin-Embedder-Policy", "require-corp");
  return new Response(response.body, { status: response.status, headers });
}
