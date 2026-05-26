# Lesson: hardcoded AppRoleName '<YOUR_LOCAL_ROLE_NAME>' was wrong — real value is '<YOUR_BACKEND_ROLE>'

| | |
|---|---|
| **Date** | 2026-05-26 |
| **Captured by** | Sisyphus |
| **Severity** | data-corrupting |
| **Cost first time** | 20 minutes |
| **Tool / file / quirk** | queries/log-analytics filters |
| **Triggers re-find** | AppRoleName cloud_RoleName hardcode appsettings staging differs |

## What I expected
appsettings.Local.json reflected the real backend role name in staging.

## What actually happened
Local file said <YOUR_LOCAL_ROLE_NAME>. Staging deployment overrode it to <YOUR_BACKEND_ROLE>. KQL filter returned zero rows — looked like 'no data' but was actually 'wrong filter'.

## Why it surprised me
I trusted a config file as source of truth without verifying against the live environment.

## How I diagnosed it
Ran 'AppTraces | summarize count() by AppRoleName | top 20' to see the real values.

## Generalizable rule
Always discover real role/resource names from the environment before filtering. Never copy from local config.

## Where this belongs (when promoted)
- [x] queries/01-discover-roles.kql + SKILL.md Phase 3 'Discover, never hardcode'

## Open follow-ups
Add a hard gate that flags any query template containing a literal AppRoleName == '...'.
