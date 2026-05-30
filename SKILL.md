---
name: az-investigator
description: "Install Azure CLI + Azure MCP into an ephemeral ai-sandbox container in a way that survives rebuilds, then run KQL investigations against your Azure Log Analytics workspaces (stg/qa/trunk/prod) without re-installing or re-authenticating each time. Use whenever the user asks to query App Insights / Log Analytics, debug a production 401 / 5xx / latency spike, trace BI events, or diagnose any backend incident in <your-app-insights-resources>. Also use for one-time sandbox bootstrap of az tooling. Triggers on phrases like 'query App Insights', 'run KQL', 'check <YOUR_BACKEND_ROLE> logs', 'why is /api/X returning 401', 'find user activity in Azure', 'investigate prod spike', 'show me game spin events'."
compatibility: "OpenCode running in a Docker ai-sandbox (Debian) on macOS host, with /home/<user> bind-mounted from host, npm + python3 + curl available, and an Azure AD account that has previously logged in via `az login` (MSAL cache at ~/.azure persists across sandbox rebuilds)."
metadata:
  author: Sisyphus
  version: "1.0.0"
  triggers:
    - "query App Insights"
    - "run KQL"
    - "check <YOUR_BACKEND_ROLE> logs"
    - "investigate prod 401"
    - "Azure Log Analytics"
    - "<your-app-insights>"
    - "azmcp"
    - "BI event"
    - "game spin events"
  workspace_targets:
    - stg
    - qa
    - trunk
    - prod
---

# Azure Log Analytics Investigator

End-to-end workflow for installing Azure tooling once into an ephemeral sandbox and using it to investigate Azure Monitor / App Insights / Log Analytics from inside an opencode session.

This skill encodes lessons from a real production 401-storm investigation. It is opinionated about three things: **persistence first**, **discovery before filtering**, and **proof before claim**.

---

## Phase 0 — Decide whether this skill applies

Use this skill if EITHER:

1. The user asks any question whose answer requires KQL against `<your-app-insights-resources>` or `*-LOG-AI-SWEEPS`, OR
2. The user reports a production/staging symptom (401 spike, error rate, latency, missing events) and the diagnosis requires Azure data.

Do NOT use this skill for:
- Code-only investigations (no Azure data needed) — use direct grep / explore agents.
- Datadog investigations — use `datadog-pup-investigator` instead.
- Backend deployment / infra questions — use `azure_arm` / Bicep tooling instead.

---

## Phase 1 — Sandbox persistence audit (always run first)

Sandbox containers are ephemeral. Before installing anything, verify which paths persist:

```bash
bash ~/.config/opencode/skills/az-investigator/scripts/audit-persistence.sh
```

The script tests with **device number** (`stat -c '%D'`), not `findmnt`. `findmnt` only shows mount roots — child directories of a bind-mount inherit persistence but appear absent from `findmnt`. **Trust device numbers, not mount listings.**

Expected output for a working sandbox:

```
PERSIST ✅  /home/<user>  (and all its children)
PERSIST ✅  $HOME/.local/share/az-investigator  (skill state path)
PERSIST ✅  /home/<user>/.azure  (MSAL token cache)
PERSIST ✅  /home/<user>/.npm-global  (global npm bins)
OVERLAY ❌  /tmp/*  (wiped on rebuild — never install here)
```

If `/home/<user>/.azure/msal_token_cache.json` is missing → user has not logged in to Azure on this host. Stop and tell them to run `az login` after install.

---

## Phase 2 — Install tooling (idempotent)

Run:

```bash
bash ~/.config/opencode/skills/az-investigator/scripts/install.sh
```

This installs (all to persistent paths):

| Tool | Where | Why |
|---|---|---|
| Azure CLI 2.86+ (`az`) | `$HOME/.local/share/az-investigator/az-venv` (override with `$PROJECT_DIR`) | KQL queries via `az monitor log-analytics query` + fallback `az monitor app-insights query` |
| `log-analytics` extension | `~/.azure/cliextensions/` | Required for the KQL subcommand |
| `azure-monitor-query` Python SDK | same venv | Programmatic access if scripting Python |
| `azure-identity` | same venv | SDK auth |
| `@azure/mcp` (`azmcp`) | `~/.npm-global/bin/azmcp` | Native opencode MCP tools (requires session restart to activate) |
| `run-kql` helper | `~/.local/bin/run-kql` → `.opencode/run-kql.sh` | Wraps `az` with env shortcuts (stg/qa/trunk/prod) and auto-fallback from workspace-mode → component-mode if RBAC differs |
| Bashrc additions | `~/.bashrc` (`AZURE_SANDBOX_BLOCK`) | PATH + `$AZURE_VENV` + `az-activate` alias |

**Skip-if-installed semantics**: Every install step checks for existing binary and skips if present. Safe to run repeatedly. The whole install takes ~3 minutes on a fresh sandbox, ~10 seconds on a warm one.

### After install, two paths to query Azure

**Path A — Bash + `run-kql`** (works immediately, no restart needed):

```bash
run-kql stg '<kql>'
run-kql prod -f /path/to/query.kql
echo '<kql>' | run-kql qa -
```

**Path B — Azure MCP tools** (requires opencode restart):

After `install.sh` adds the `"azure"` entry to `~/.config/opencode/opencode.json`, the user must **restart opencode** for `azmcp_*` tools to load. Tell them this explicitly — do not assume it works in the current session.

---

## Phase 3 — Discover, never hardcode

Before any KQL query that uses an `AppRoleName`, `cloud_RoleName`, `instrumentationKey`, or environment-specific constant: **discover the real value from the workspace**, do not copy from `appsettings.Local.json` or env files.

Why this matters (real bug from this skill's lineage): `appsettings.Local.json` had `ApplicationIdentifier = "<YOUR_LOCAL_ROLE_NAME>"`. Staging actually uses `"<YOUR_BACKEND_ROLE>"`. A query filtered on the local value returns zero rows, leading to a false "no data" conclusion.

### Discovery snippet (always run before filtering)

```bash
run-kql stg 'AppTraces | where TimeGenerated >= ago(24h) | summarize Count=count() by AppRoleName | order by Count desc | take 20'
```

Look at the **actual top role names** in the workspace. Use those exact strings.

### Reference: confirmed sample env mapping (2026-05)

These values were observed in real production data. Verify they still match before relying on them.

| Env | Subscription | Resource Group | App Insights | Log Analytics workspace | `AppRoleName` (backend) |
|---|---|---|---|---|---|
| stg | `<YOUR_SUBSCRIPTION_STG>` | `<YOUR_RG_STG>` | `<YOUR_APP_INSIGHTS_STG>` | `<YOUR_LA_WORKSPACE_STG>` (customerId `b976ada5-…`) | `<YOUR_BACKEND_ROLE>` |
| qa | `<YOUR_SUBSCRIPTION_QA>` | `<YOUR_RG_QA>` | `<YOUR_APP_INSIGHTS_QA>` | `<YOUR_LA_WORKSPACE_QA>` | `<YOUR_BACKEND_ROLE>` |
| trunk | `<YOUR_SUBSCRIPTION_TNK>` | `<YOUR_RG_TNK>` | `<YOUR_APP_INSIGHTS_TNK>` | `<YOUR_LA_WORKSPACE_TNK>` | `<YOUR_BACKEND_ROLE>` |
| prod | `<YOUR_SUBSCRIPTION_PRD>` | `<YOUR_RG_PRD>` | `<YOUR_APP_INSIGHTS_PRD>` | `<YOUR_LA_WORKSPACE_PRD>` | `<YOUR_BACKEND_ROLE>` |

**RBAC quirk**: On `prod`, workspace read may be denied for some accounts but App Insights component read may still work. `run-kql` auto-falls-back to component path — **table names switch from `AppRequests`/`AppTraces` to `requests`/`traces`** in that case. The script prints which path it used; honor that in your KQL.

---

## Phase 4 — Investigation patterns (use these as starting points)

The `queries/` directory has battle-tested KQL templates. Adapt to the question, do not blind-paste.

### Quick reference (full files in `queries/`)

| File | When to use |
|---|---|
| `queries/01-discover-roles.kql` | Always run this first — see real `AppRoleName` values |
| `queries/02-failed-requests.kql` | "Why is endpoint X failing?" — group 4xx/5xx by url + ResultCode |
| `queries/03-401-spike.kql` | "There's a 401 alert" — find user, IP, endpoint behind the spike |
| `queries/04-user-timeline.kql` | "What did UserId N do today?" — full request timeline by user |
| `queries/05-slot-studio-spins.kql` | "Find game-vendor plays" — `AppRequests` for `/api/slotstudio/*` |
| `queries/06-bi-event-spin.kql` | "Find win/loss/bet amounts" — parse `<your-bi-event-role>` BI payloads (the only place `win_amount` etc. live in Log Analytics) |
| `queries/07-exception-by-type.kql` | Standard exception triage |

### When App Insights data is empty but the user "definitely was using the app"

Two recurring traps:

1. **Wrong table**: workspace-mode uses `AppRequests`, classic component-mode uses `requests`. `run-kql` tells you which path it used.
2. **UserId filter on requests where `request-X-PSA-ID` is absent**: pre-auth calls (login, /maintenance, /signin) don't carry the header. Use `tostring(customDimensions["ctx_UserId"])` for post-auth correlation, fall back to `client_IP` for pre-auth.

### When the user reports "the alert says peak at time T" and you can't find T

The portal `eventId` in `https://portal.azure.com/.../DetailsV2Blade/...` is **not the same as `itemId`**. Fetching by `itemId == "<eventId>"` often returns zero rows. Instead:
- Use the timestamp ± 2s window with `union exceptions, requests, traces`
- The "peak" the user clicked may not be THE peak — query a wider window to find the real peak

---

## Phase 5 — Proof discipline (CRITICAL)

This is the most important phase. Every claim about the user, code, or system MUST be grounded in tool output. Mark claims explicitly:

| Tag | Meaning | Example |
|---|---|---|
| ✅ **Confirmed** | Came from a real tool call this session | "Body has `Code:1015` — confirmed via curl just now" |
| 🔍 **Hypothesis** | Plausible from code-read but not tested at runtime | "Modal might be cancelled by `takeLatest`" |
| ❌ **Refuted** | Tested and turned out false | "User on a different device — refuted by `ctx_UserId` matching across both 200s and 401s" |

Do **not** mix these in narrative prose. If you state a cause, label it.

### Anti-patterns this skill prevents

| Anti-pattern | How to avoid |
|---|---|
| "The 401 happens because the cookie expired" (asserted, never proved) | Run `curl <YOUR_BACKEND_HOST>/api/player/balances` without cookie → confirm `Code:1015` body shape |
| "Hardcoded `cloud_RoleName == '<YOUR_LOCAL_ROLE_NAME>'`" | Always run `queries/01-discover-roles.kql` FIRST and use the real value |
| "User is in iframe-focus loop" | Verify with at least one piece of independent evidence (browser headers? referer? BI event `flow`?) |
| "`<YOUR_FRONTEND_HOST>/api/*` is a proxy" | `curl -I` first to verify `content-type: application/json`, not `text/html` |
| "MCP just installed = available now" | Tell user to **restart opencode** for MCP servers to load |

---

## Phase 6 — Reproduce client behavior

When the user wants to repro a request from the browser console, use the snippet in `references/devtools-probe.md`. It defaults to `cache: 'no-store'` (we burned a turn on disk cache once) and explicitly notes that the cookie is HttpOnly so JS can't tamper with it — DevTools UI is required.

---

## Phase 7 — Wrap-up & report shape

Every Azure investigation should end with a report that has these sections:

```markdown
## What I confirmed (grounded in tool output)
- ...
## What I hypothesized but did not prove
- ...
## What's still unknown
- ...
## Recommended fix (with file:line references)
- ...
## Repro script (if applicable)
- ...
```

The "hypothesized but did not prove" section is mandatory. If it's empty, you probably mixed proof with speculation — re-read.

---

## Phase 8 — Repair recipe (if sandbox was rebuilt and something broke)

```bash
bash ~/.config/opencode/skills/az-investigator/scripts/repair.sh
```

Diagnoses + reinstalls only what's missing. Idempotent.

---

## Phase 10 — Lesson loop (harness)

Every real investigation that hits a quirk, a wrong answer, or a moment of "huh, I didn't know that" SHOULD end with a lesson capture. The harness under [`harness/`](harness/HARNESS.md) owns the lifecycle: capture → backlog → story → spec → implement → test → fix → regression → approve → publish.

Minimum after every non-trivial investigation:

```bash
bash harness/scripts/capture-lesson.sh
```

When ≥1 backlog lesson has accumulated and time permits:

```bash
bash harness/scripts/promote-to-story.sh harness/lessons/<file>.md
# Implement the change
bash harness/scripts/run-tests.sh smoke
bash harness/scripts/run-tests.sh regression
bash harness/scripts/gate-check.sh
# If gate exits 0 and Gate 15 reviewer signed off:
/sync-skill-to-manager az-investigator
```

See [`harness/HARNESS.md`](harness/HARNESS.md) for risk lanes, hard gates, change types, and the embedded best-practice list (BP-1 through BP-10).

## Phase 9 — Sandbox restart awareness

Every time opencode restarts, the **MCP servers reload from `opencode.json`**. If the user installs the Azure MCP via this skill during a session, that MCP will not be available until the next opencode launch. In the current session, fall back to `run-kql` (Bash CLI), which works immediately.

Never tell the user "the Azure MCP is ready" inside the same session it was just installed. Always: "Installed. Restart opencode to load `azmcp_*` tools, OR use `run-kql` in Bash right now."

---

## Files in this skill

| Path | Purpose |
|---|---|
| `SKILL.md` (this file) | Workflow orchestration + lessons |
| `scripts/audit-persistence.sh` | Phase 1 — sandbox persistence check |
| `scripts/install.sh` | Phase 2 — idempotent install of az + venv + helper + MCP + bashrc |
| `scripts/repair.sh` | Phase 8 — fix broken state after sandbox rebuild |
| `scripts/run-kql.sh` | The KQL wrapper (also installed to `.opencode/run-kql.sh`) |
| `queries/01-discover-roles.kql` | Discover real AppRoleName values |
| `queries/02-failed-requests.kql` | Find failing endpoints |
| `queries/03-401-spike.kql` | 401 spike attribution |
| `queries/04-user-timeline.kql` | Full timeline for a UserId |
| `queries/05-slot-studio-spins.kql` | game-vendor webhook activity |
| `queries/06-bi-event-spin.kql` | Parse <your-bi-event-role> BI payloads |
| `queries/07-exception-by-type.kql` | Exception triage |
| `references/devtools-probe.md` | Browser-console snippet (cache:no-store etc.) |
| `references/known-quirks.md` | All the gotchas we hit so the next agent doesn't repeat them |
| `references/env-map.md` | Per-env Azure resource map (refreshable via discover query) |
