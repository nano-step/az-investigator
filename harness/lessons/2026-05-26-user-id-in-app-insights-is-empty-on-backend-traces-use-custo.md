# Lesson: user_Id in App Insights is empty on backend traces use customDimensions ctx_UserId or request-X-PSA-ID instead

| | |
|---|---|
| **Date** | 2026-05-26 |
| **Captured by** | agent |
| **Severity** | cosmetic / annoying / data-corrupting / reasoning-error |
| **Cost first time** | 10 minutes |
| **Tool / file / quirk** | requests table user identity |
| **Triggers re-find** | user_Id empty backend dcount distinct users UserId customDimensions |

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
