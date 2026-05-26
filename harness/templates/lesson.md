# Lesson: {{TITLE}}

| | |
|---|---|
| **Date** | {{YYYY-MM-DD}} |
| **Captured by** | {{AGENT_OR_HUMAN}} |
| **Severity** | cosmetic / annoying / data-corrupting / reasoning-error |
| **Cost first time** | {{MINUTES}} minutes |
| **Tool / file / quirk** | {{e.g. run-kql.sh, AppRequests schema, Mermaid syntax}} |
| **Triggers re-find** | {{search phrases someone would type when hitting this again}} |

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
