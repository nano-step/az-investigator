# Lesson: fetch() defaults to disk cache — DevTools snippets need cache:'no-store'

| | |
|---|---|
| **Date** | 2026-05-26 |
| **Captured by** | Sisyphus |
| **Severity** | annoying |
| **Cost first time** | 10 minutes |
| **Tool / file / quirk** | DevTools probe snippet |
| **Triggers re-find** | fetch disk cache no-store cannot reproduce 401 |

## What I expected
fetch() in DevTools always hits the network.

## What actually happened
User reported the probe returned 200 from disk cache. The /api/player/balances response was cached with a short max-age.

## Why it surprised me
I forgot fetch's default cache mode is 'default' (uses HTTP cache).

## How I diagnosed it
User showed cached 200 response. Added cache:'no-store' and the request went to network and returned 401 as expected.

## Generalizable rule
All DevTools probe snippets must set cache:'no-store'. For paranoia, also append ?_=Date.now() and Cache-Control: no-cache.

## Where this belongs (when promoted)
- [x] references/devtools-probe.md (all snippets updated)

## Open follow-ups

