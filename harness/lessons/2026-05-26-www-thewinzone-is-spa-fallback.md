# Lesson: <YOUR_FRONTEND_HOST>/api/* is the SPA fallback, not the API

| | |
|---|---|
| **Date** | 2026-05-26 |
| **Captured by** | Sisyphus |
| **Severity** | annoying |
| **Cost first time** | 15 minutes |
| **Tool / file / quirk** | host routing |
| **Triggers re-find** | SPA fallback HTML 200 api proxy backend host |

## What I expected
<YOUR_FRONTEND_HOST>/api/player/balances would proxy to the backend.

## What actually happened
Hit returned HTTP 200 with content-type text/html — the homepage. CDN serves index.html for any unmatched route.

## Why it surprised me
I assumed /api/* on a frontend host was always proxied. It isn't — depends on CDN config.

## How I diagnosed it
curl -I returned text/html. Tried <YOUR_BACKEND_HOST>/api/ directly and got real JSON 401.

## Generalizable rule
Always curl -I a host before writing client snippets. Confirm content-type is application/json.

## Where this belongs (when promoted)
- [x] references/devtools-probe.md + references/known-quirks.md Q14

## Open follow-ups

