# az-investigator

> An [opencode](https://opencode.ai) skill that turns Azure Log Analytics + Application Insights into a self-improving investigation tool. Battle-tested on real production incidents.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skill version](https://img.shields.io/badge/skill-v1.0.0-blue.svg)](skill.json)

When your prod 401s spike at 3 AM, when a slow Cosmos query is melting RU, when "the failures blade looks bad and I don't know where to start" — `az-investigator` is the opencode skill you load. It bootstraps `az` CLI + Microsoft's `@azure/mcp` into an ephemeral container, runs discovery-first KQL templates, and forces every claim in its report to be tagged `✅ confirmed` / `🔍 hypothesis` / `❌ refuted` so you can trust the diagnosis.

## Why this exists

Every Azure investigation produces lessons — quirks in App Insights schema, RBAC gotchas, KQL footguns, hypotheses you thought were true and weren't. Without a process those lessons evaporate. This skill ships with a **harness** ([`harness/HARNESS.md`](harness/HARNESS.md)) that:

1. Captures every real lesson as a structured markdown file (`harness/scripts/capture-lesson.sh`)
2. Catalogs them in an index (`harness/LESSONS_INDEX.md`)
3. Promotes ripe lessons into actionable stories (`harness/scripts/promote-to-story.sh`)
4. Validates skill changes against a 40-case test matrix (`harness/scripts/run-tests.sh`)
5. Gates publish on a 15-item approval checklist (`harness/scripts/gate-check.sh`)

The skill gets smarter with every investigation, on purpose.

## What you get out of the box

- **One install script** (`scripts/install.sh`) — idempotent install of `azure-cli` + `azure-monitor-query` Python SDK + `@azure/mcp` (Node) into a persistent path that survives container rebuilds. ~3 min cold, ~10 sec warm.
- **`run-kql` wrapper** (`scripts/run-kql.sh`) — multi-env KQL runner with **automatic workspace-mode → component-mode RBAC fallback** (so a `Microsoft.OperationalInsights/workspaces/read` deny doesn't stop you — it falls back to `Microsoft.Insights/components` queries).
- **7 battle-tested KQL templates** for the most common Azure investigation patterns:
  - `01-discover-roles.kql` — **always run this first**; lists real `AppRoleName` values to filter on
  - `02-failed-requests.kql` — failing endpoint triage
  - `03-401-spike.kql` — auth-failure attribution (user, IP, endpoint)
  - `04-user-timeline.kql` — per-user request timeline
  - `05-slot-studio-spins.kql` — sample game-vendor webhook traffic
  - `06-bi-event-spin.kql` — parse serialized BI events embedded in NLog traces
  - `07-exception-by-type.kql` — exception triage grouped by `problemId`
- **Response-shape contract** — every output uses the 6 mandatory sections (`Finding / Evidence / Reason / Why it matters / Solution / Open questions`) with proof tags. No "I think it's probably the cookie" hand-waving.
- **16 published lessons** in `harness/lessons/` — real things we learned the hard way so you don't have to (sandbox persistence, App Insights sampling, redux-saga cancellation, etc.)

## Quick start

### Prerequisites

- OpenCode (the editor / agent — [opencode.ai](https://opencode.ai))
- A Docker dev container or ai-sandbox, ideally with `/home/<user>` bind-mounted from your host so installs persist
- `npm`, `python3`, `curl` on PATH
- An Azure AD account with **at least one** of:
  - `Microsoft.OperationalInsights/workspaces/read` on the target Log Analytics workspace, **or**
  - `Microsoft.Insights/components/read` on the target App Insights resource (the skill auto-falls-back to this path)

### Install

```bash
git clone https://github.com/nano-step/az-investigator.git
cd az-investigator

bash scripts/install.sh
source ~/.bashrc

az login  # one-time; MSAL cache persists across container rebuilds
```

`install.sh` is idempotent — safe to re-run after a sandbox rebuild. See [`harness/lessons/2026-05-26-tmp-is-overlay-wiped-on-rebuild.md`](harness/lessons/2026-05-26-tmp-is-overlay-wiped-on-rebuild.md) for why this matters.

### Use it from opencode

Drop the skill into your opencode skills directory:

```bash
ln -s "$(pwd)" ~/.config/opencode/skills/az-investigator
```

Then from any opencode session:

```
load the az-investigator skill and tell me what's spiking 5xx on staging right now
```

OpenCode will load [`SKILL.md`](SKILL.md), which walks the agent through discovery → query → proof-tagged report.

### Use it from a plain shell

```bash
run-kql stg 'AppRequests | where TimeGenerated >= ago(15m) | where Success == false | summarize Count=count() by Name | top 10 by Count desc'
```

The `stg|qa|trunk|prod` shortcuts resolve to your configured workspaces. See [`references/env-map.md`](references/env-map.md) to wire them up to **your** Azure resources (the file ships with placeholders — `<YOUR_SUBSCRIPTION_PRD>`, `<YOUR_RG_PRD>`, etc.).

## What's in this repo

```
az-investigator/
├── SKILL.md                   # The opencode-loaded workflow (9 phases)
├── skill.json                 # OpenCode skill manifest
├── PLAN-v2.md                 # Roadmap to v2 (Resource Graph, Activity Log, Metrics, etc.)
├── scripts/
│   ├── install.sh             # Idempotent bootstrap
│   ├── audit-persistence.sh   # Test which container paths survive rebuild
│   ├── run-kql.sh             # KQL wrapper w/ RBAC fallback
│   └── repair.sh              # After-rebuild recovery
├── queries/                   # 7 battle-tested KQL templates
├── references/
│   ├── env-map.md             # Per-env Azure resource map (fill in your IDs)
│   ├── known-quirks.md        # 20 footguns we hit so you don't have to
│   └── devtools-probe.md      # Browser-side reproduction snippets
└── harness/                   # The lesson-loop machinery
    ├── HARNESS.md             # The harness spec
    ├── LESSONS_INDEX.md       # Catalog of captured lessons
    ├── BACKLOG.md             # Open + in-progress improvements
    ├── lessons/               # 16 published postmortems
    ├── stories/               # Lesson-to-implementation work units
    ├── templates/             # lesson.md, story.md, postmortem.md
    ├── scripts/
    │   ├── capture-lesson.sh
    │   ├── promote-to-story.sh
    │   ├── run-tests.sh
    │   ├── lint-kql.sh
    │   ├── lint-response-shape.sh
    │   └── gate-check.sh      # The 15-item approval gate
    └── tests/
        ├── smoke.yaml         # S01-S10 (must all pass before publish)
        ├── regression.yaml    # R01-R20
        └── edge.yaml          # E01-E10
```

## Three principles the skill enforces

1. **Discovery first, never hardcode.** Real `AppRoleName` / resource names get *discovered* via a `summarize by` query before any filtered investigation. Local config files lie. (See lesson [`hardcoded-rolename-was-wrong`](harness/lessons/2026-05-26-hardcoded-rolename-was-wrong.md).)
2. **Proof tags on every claim.** Each finding is `✅ confirmed` (came from a tool call in this session), `🔍 hypothesis` (plausible from code-read, not runtime-tested), or `❌ refuted` (was a hypothesis, disproven). No mixing in narrative prose.
3. **One PR per lesson.** Every captured lesson that wants to become a code change goes through the harness lifecycle: capture → backlog → story → spec → implement → test → fix → regression → approve → publish.

## Compatibility

- **opencode** running in any Docker-based dev container or [ai-sandbox](https://github.com/nano-step/ai-sandbox-wrapper) on macOS/Linux host.
- `/home/<user>` should be bind-mounted from the host so the MSAL token cache (`~/.azure`) and the install (`~/.npm-global`, the Python venv) survive container rebuilds.
- Azure CLI **2.86+**, Node **20+**, Python **3.11+**.

## Roadmap (v2)

See [`PLAN-v2.md`](PLAN-v2.md) for the full v2 plan — adds Resource Graph (cross-subscription resource inventory), Activity Log auditing, Metrics (`az monitor metrics`), Service Health checks, Cost Management spike attribution, Key Vault access denial diagnosis, AKS pod restart triage, and Cosmos DB throttling investigation. v2 will cover **28 distinct Azure investigation use cases**.

## Contributing

Pull requests welcome. Every PR is reviewed by [Gemini Code Assist](https://developers.google.com/gemini-code-assist) and a human reviewer. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the workflow.

If you hit a quirk while using this skill, please capture it as a lesson:

```bash
bash harness/scripts/capture-lesson.sh
```

…then promote it to a story and send a PR. The whole point of the harness is to make those lessons reusable for everyone.

## License

[MIT](LICENSE) — use it, fork it, ship it.

## Acknowledgments

- Built on Microsoft's [`@azure/mcp`](https://www.npmjs.com/package/@azure/mcp) and `azure-cli`.
- Workflow patterns inspired by [`nano-step/lograft`](https://github.com/nano-step/lograft), [`nano-step/nano-brain`](https://github.com/nano-step/nano-brain), and [`obra/superpowers`](https://github.com/obra/superpowers).
- This skill exists because production incidents kept producing the same lessons. Now they only have to be learned once.
