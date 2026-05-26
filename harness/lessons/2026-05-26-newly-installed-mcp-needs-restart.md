# Lesson: newly installed MCPs need opencode restart to load

| | |
|---|---|
| **Date** | 2026-05-26 |
| **Captured by** | Sisyphus |
| **Severity** | annoying |
| **Cost first time** | 10 minutes |
| **Tool / file / quirk** | @azure/mcp install |
| **Triggers re-find** | MCP server restart opencode azmcp not available same session |

## What I expected
Installing @azure/mcp via npm and adding it to opencode.json would make azmcp_* tools available in the same session.

## What actually happened
MCPs load only at opencode startup. The newly-registered Azure MCP did nothing until I restarted opencode.

## Why it surprised me
I conflated 'binary installed' with 'tool registered in current session'.

## How I diagnosed it
Read the opencode source / docs; confirmed MCP servers are spawned at process start, not on config reload.

## Generalizable rule
Tell the user explicitly: restart opencode to load newly registered MCPs. Provide a Bash CLI fallback for current session.

## Where this belongs (when promoted)
- [x] scripts/install.sh end-of-run message + SKILL.md Phase 9 + references/known-quirks.md Q4

## Open follow-ups
Could a future opencode version reload MCPs on config change? Worth filing an upstream issue.
