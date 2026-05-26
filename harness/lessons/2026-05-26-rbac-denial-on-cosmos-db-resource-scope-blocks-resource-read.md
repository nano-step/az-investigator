# Lesson: RBAC denial on Cosmos DB resource scope blocks resource read but app-side dependencies still queryable

| | |
|---|---|
| **Date** | 2026-05-26 |
| **Captured by** | agent |
| **Severity** | cosmetic / annoying / data-corrupting / reasoning-error |
| **Cost first time** | 15 minutes |
| **Tool / file / quirk** | dependencies table fallback when RBAC denied |
| **Triggers re-find** | Cosmos AuthorizationFailed Microsoft.DocumentDB databaseAccounts/read pivot to dependencies |

## What I expected

{{One paragraph: the assumption I was operating under.}}

## What actually happened

{{One paragraph: the surprise. Include raw tool output if useful.}}

## Why it surprised me

{{One paragraph: the gap between my mental model and reality. This is the lesson.}}

## How I diagnosed it

{{The chain of tool calls that resolved the surprise. Cite exact commands.}}

## Generalizable rule

{{One sentence that future-me can scan in 5 seconds.}}

## Where this belongs (when promoted)

- [ ] `references/known-quirks.md` — Q{{NN}}
- [ ] `references/<other>.md`
- [ ] New / modified query template: `queries/{{path}}.kql`
- [ ] New / modified script: `scripts/{{name}}.sh`
- [ ] SKILL.md Phase {{N}} update
- [ ] New regression test: `harness/tests/regression.yaml R{{NN}}`

## Open follow-ups

{{Things I noticed but didn't chase down. Leave breadcrumbs for the next investigation.}}
