# Known Quirks — read before investigating

Every entry below burned at least one turn in a real session. Read them before re-discovering them the hard way.

## Sandbox / environment

### Q1. `findmnt` does NOT show child directories of a bind-mount

`findmnt /home/<user>/.npm-global` returns nothing → looks ephemeral. But it inherits persistence from the parent bind-mount. Use `stat -c '%D' <path>` and compare to `/home/<user>`'s device number. Identical = persistent.

### Q2. `/tmp` is on the container overlay, always wiped

Never install anything to `/tmp/opencode/*`. The `/tmp/opencode/` path mentioned in earlier opencode docs is a working directory, not persistent storage. Use `$HOME/.local/share/az-investigator/` (the skill's default `$PROJECT_DIR`) or any other path under `/home/<user>/.local/` for anything that must survive a rebuild.

### Q3. Sudo / root is unavailable

Sandbox runs as user `agent` (uid 1001). System apt fails with "Permission denied". Use pip venvs and `npm config set prefix ~/.npm-global`.

### Q4. Newly installed MCPs require opencode restart

`@azure/mcp` is registered in `opencode.json`, but MCP servers load only at opencode startup. Same session = use `az` CLI directly. Next session = `azmcp_*` tools available.

## Azure / RBAC

### Q5. Workspace read vs component read are different RBAC

A user may be denied `Microsoft.OperationalInsights/workspaces/read` on prod but still have `Microsoft.Insights/components/read`. Use `az monitor app-insights query` as fallback (see `run-kql.sh` auto-fallback logic). Table names change: `AppRequests` → `requests`, `AppTraces` → `traces`, `TimeGenerated` → `timestamp`.

### Q6. `az resource list --query` silently fails on nested properties

`az resource list --resource-type Microsoft.Insights/components --query "[?properties.InstrumentationKey=='...']"` returns `[]` even when the resource exists. Don't trust nested filters. Instead: list all, then loop with `az monitor app-insights component show -g <rg> --app <name> --query instrumentationKey`.

### Q7. The portal `eventId` is NOT the same as `itemId`

Links like `https://portal.azure.com/.../DetailsV2Blade/.../eventId":"467704a5-..."` look like an `itemId`. They're not. Fetching by `itemId == "<eventId>"` usually returns empty. Use the timestamp ± a few seconds instead.

## App Insights schema

### Q8. UserId lives in multiple places, none consistent

- `Properties["request-X-PSA-ID"]` — set by the FE axios wrapper, sent on every authenticated request. Absent on pre-auth calls.
- `Properties["ctx_UserId"]` — set by backend middleware after JWT validation. Present only when auth succeeded.
- Buried inside `Message` string in NLog traces — must `extract()` via regex.

Query by BOTH `request-X-PSA-ID` and `ctx_UserId` to catch all activity.

### Q9. `appsettings.Local.json` lies about prod values

Local dev config had `ApplicationIdentifier = "<YOUR_LOCAL_ROLE_NAME>"`. Real prod / staging value is `"<YOUR_BACKEND_ROLE>"`. Always discover real values via `summarize by AppRoleName` before filtering.

### Q10. BI events (`win_amount`, `bet_amount`, etc.) are NOT in `AppRequests`

They go to Azure EventHub and are shipped to App Insights ONLY as serialized JSON strings inside `AppTraces.Message` under `cloud_RoleName == "<your-bi-event-role>"`. Parse with `parse_json(extract(@"----serializedEvent\s+(\{.+\})\s*$", 1, Message))`.

### Q11. Sampling can hide volume

If adaptive sampling is on, `count()` understates real counts. Use `summarize sum(ItemCount)` for true counts.

### Q12. `customDimensions` is case-sensitive

`Properties["UserId"]` ≠ `Properties["psaid"]`. The web FE uses `UserId` (PascalCase). NLog targets sometimes use `LoggerName` instead of `CategoryName`. Try multiple variants with `has_any`.

## HTTP / client repro

### Q13. `fetch()` defaults to disk cache

`fetch('/api/...')` from DevTools can return a 200 from disk cache and never hit the network. Always pass `cache: 'no-store'`. For paranoia, also append `?_=${Date.now()}` and a `cache-control: no-cache` header.

### Q14. `<YOUR_FRONTEND_HOST>/api/*` is NOT the API — it's the SPA fallback

CDN serves `index.html` for unknown routes. The real backend is `https://<YOUR_BACKEND_HOST>/api`. Always `curl -I` first and confirm `Content-Type: application/json` before assuming a path is the API.

### Q15. The `AccessToken` cookie is `HttpOnly`

JavaScript cannot read it, cannot delete it with `document.cookie = ...`. To force an invalid cookie, use DevTools → Application → Cookies → right-click → Edit value.

## Redux / saga code patterns

### Q16. `takeLatest` + side-effect in `catch` = silent cancellation

`takeLatest` cancels the prior worker task when a new action arrives. If the catch block has multiple `yield` points before its critical `put`, a new dispatch can cancel the modal/redirect mid-recovery. Use `takeEvery`, `putResolve`, or `spawn(detached saga)` for recovery side-effects.

### Q17. your team web is cookie auth, NOT Bearer token

`defaultHeaders(token)` accepts a `token` parameter and **silently ignores it** — the `Authorization` line is commented out. Auth flows via `withCredentials: true` and HttpOnly cookies. There is no `Bearer` header anywhere in normal requests. Don't recommend "refresh the token" — there is no client-side token to refresh; a 401 means cookie-expired.

### Q18. `isSessionOverTracking(baseURL)` whitelist excludes `SERVER_API_HOST`

The main backend host is NOT in the whitelist that triggers the sign-in modal. Only `REWARD_API_HOST`, `LOYALTY_*`, `REWARD_PLUS_*` are listed. Any 401 from `/api/player/balances` skips the modal silently. Real bug, not WAI.

## Investigation discipline

### Q19. "Hypothesis" and "confirmed" must be visible in the report

Mixing them produces reports that look authoritative but contain speculation. Use the ✅/🔍/❌ tag convention from `SKILL.md` Phase 5.

### Q20. Never claim a cause from code-read alone for a runtime behavior

`takeLatest`-cancellation is a perfect example. The code looks like it should fire a modal; only runtime evidence proves whether it actually does. If you can't run the test, label it 🔍 hypothesis.
