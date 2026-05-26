# Changelog

All notable changes to `az-investigator` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Lessons L11–L16 from initial production use are queued in [`harness/BACKLOG.md`](harness/BACKLOG.md) for v1.1.0:

- L11 — Cosmos dependency type is `Azure DocumentDB`, not `Cosmos`
- L12 — `capture-lesson.sh` failed under `set -u` when `$USER` unset (fixed in-session)
- L13 — RBAC denial on resource scope ≠ "can't investigate" — pivot to `dependencies` table
- L14 — High dependency-level failure rate ≠ bug — recognize try-then-fallback patterns
- L15 — `user_Id` is empty on backend traces; use `customDimensions["ctx_UserId"]` instead
- L16 — Open-ended portal resource links need a default-probe-set strategy

## [1.0.0] — 2026-05-26

### Added

- Initial public release as an opencode skill.
- `scripts/install.sh` — idempotent install of `azure-cli`, `azure-monitor-query` Python SDK, and `@azure/mcp` (Node) into a container-rebuild-safe path.
- `scripts/run-kql.sh` — multi-environment KQL wrapper (`stg | qa | trunk | prod`) with automatic Log Analytics workspace-mode → App Insights component-mode RBAC fallback. Table names switch from `AppRequests` to `requests` (etc.) when fallback fires; the script logs which path it used.
- `scripts/audit-persistence.sh` — uses `stat -c '%D'` (not `findmnt`) to determine which container paths survive a rebuild. Encodes lesson L01.
- `scripts/repair.sh` — diagnose + restore working state after a sandbox rebuild.
- 7 battle-tested KQL templates in `queries/`:
  - `01-discover-roles.kql` (must run before any filtered query)
  - `02-failed-requests.kql`
  - `03-401-spike.kql`
  - `04-user-timeline.kql`
  - `05-slot-studio-spins.kql` (example for game-vendor webhook traffic)
  - `06-bi-event-spin.kql` (parses serialized BI events embedded in NLog traces)
  - `07-exception-by-type.kql`
- Response-shape contract documented in `SKILL.md` and enforced by `harness/scripts/lint-response-shape.sh`: every output uses 6 mandatory sections (Finding / Evidence / Reason / Why / Solution / Open-questions) with `✅` / `🔍` / `❌` proof tags.
- The full **harness** under `harness/`:
  - `HARNESS.md` — risk-lane model (tiny / normal / high-risk), hard gates, change types, BP-1 through BP-10
  - `LESSONS_INDEX.md` — searchable catalog seeded with 16 published lessons
  - `BACKLOG.md` — open lessons + in-progress stories + ideas
  - `lessons/` — 16 postmortems from real production investigations
  - `stories/` — empty (created on first lesson promotion)
  - `templates/` — `lesson.md`, `story.md`, `postmortem.md`
  - `scripts/capture-lesson.sh`, `promote-to-story.sh`, `run-tests.sh`, `lint-kql.sh`, `lint-response-shape.sh`, `gate-check.sh`
  - `tests/smoke.yaml`, `regression.yaml`, `edge.yaml` — 40-case validation matrix
- `references/`:
  - `env-map.md` — per-env Azure resource map (placeholder template — users fill in their own resource names)
  - `known-quirks.md` — 20 documented footguns (App Insights schema, KQL gotchas, RBAC quirks, etc.)
  - `devtools-probe.md` — browser-side reproduction snippets with `cache: 'no-store'` defaults

### Documentation

- `PLAN-v2.md` — full v2 roadmap covering 28 Azure investigation use cases (Resource Graph, Activity Log, Metrics, Service Health, Cost, Key Vault, Storage, SQL, AKS, App Service, Functions, Cosmos DB).
- `README.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md` — community front door.

### Sanitization

All real Azure subscription IDs, tenant IDs, resource group names, instrumentation keys, role names, hostnames, user IDs, and support codes from the source environment have been replaced with `<YOUR_…>` placeholders. The skill is configured by editing `references/env-map.md` for your own Azure resources.

### Compatibility

- Tested on Debian 12 / macOS 14 host with Docker Desktop ai-sandbox layout (`/home/<user>` bind-mounted)
- Azure CLI 2.86+, Node 20+, Python 3.11+
- Works with [opencode](https://opencode.ai) and (with minor adapter work) any MCP-aware agent

[Unreleased]: https://github.com/nano-step/az-investigator/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/nano-step/az-investigator/releases/tag/v1.0.0
