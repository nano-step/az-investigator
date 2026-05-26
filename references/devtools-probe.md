# DevTools Console Probes — Reproduce a Request from the Browser

All snippets default to `cache: 'no-store'`. Run on the actual product domain (e.g. `https://<YOUR_FRONTEND_HOST>`) so the cookie is sent.

## Single request

```js
const t0 = performance.now();
const res = await fetch('/api/player/balances', {
    method: 'GET',
    credentials: 'include',
    cache: 'no-store',
    headers: { 'accept': 'application/json' }
});
const body = await res.text().then(t => { try { return JSON.parse(t); } catch { return t; } });
console.log(`HTTP ${res.status} in ${(performance.now()-t0)|0}ms`, body);
if (res.status === 401) {
    console.warn('body.Code=', body?.Code, '(modal trigger requires === 1015)');
}
```

## Loop (mimic the 401-storm cadence ~10s)

```js
let n = 0;
const id = setInterval(async () => {
    if (++n > 20) { clearInterval(id); return; }
    const res = await fetch(`/api/player/balances?_=${Date.now()}`, {
        credentials: 'include',
        cache: 'no-store',
        headers: { 'accept': 'application/json' }
    });
    const body = await res.text().then(t => { try { return JSON.parse(t); } catch { return t; } });
    console.log(`#${n} HTTP ${res.status}`,
        res.status === 401 ? `body.Code=${body?.Code}` : '');
}, 10000);
```

## Force a 401 (auth cookie is `HttpOnly`)

JS cannot delete `HttpOnly` cookies. To force an invalid cookie:

1. DevTools → **Application** → **Cookies** → `https://<YOUR_FRONTEND_HOST>`
2. Right-click `AccessToken` → **Edit value** → change the last 5 chars to garbage (e.g. `aaaaa`)
3. Run the single-request snippet above
4. Confirm the body is `{"Code":1015,"Message":"Invalid Access Token","AdditionalData":null}`

## Test against the REAL backend (skip SPA proxy)

`<YOUR_FRONTEND_HOST>/api/*` is the SPA fallback. Some routes work via CDN proxy, but if you get HTML back, hit the actual backend host:

| Env | Backend host |
|---|---|
| prod | `https://<YOUR_BACKEND_HOST>/api` |
| staging | `https://<YOUR_BACKEND_HOST_STG>/api` |
| trunk | `https://<YOUR_BACKEND_HOST_TNK>/api` |

```js
const res = await fetch('https://<YOUR_BACKEND_HOST>/api/player/balances', {
    credentials: 'include',
    cache: 'no-store',
    headers: { 'accept': 'application/json' }
});
console.log(res.status, await res.text());
```

CORS may block cross-origin from `www.*` to `backend.*`. If so, use `curl` from your terminal instead:

```bash
curl -i https://<YOUR_BACKEND_HOST>/api/player/balances \
    -H 'accept: application/json' \
    -H "Cookie: $(read-cookie-from-devtools)"
```
