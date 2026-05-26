# Postmortem: {{INCIDENT_TITLE}}

> Use this template when a `high-risk` story ships and turns out to have a bug in production, OR when a lesson reveals a reasoning error that affected multiple turns in an investigation. Tiny / annoying lessons use `lesson.md` instead.

| | |
|---|---|
| **Date** | {{YYYY-MM-DD}} |
| **Skill version when found** | v{{semver}} |
| **Reporter** | {{who noticed}} |
| **Severity** | data-corrupting / reasoning-error |
| **Duration (impact window)** | {{e.g. wrong answer present for 2h before correction}} |
| **Detected by** | self / Oracle / Momus / user / regression test |

## Summary

{{Two-sentence executive summary.}}

## Timeline (UTC)

| Time | Event |
|---|---|
| {{HH:MM}} | {{first action / signal}} |
| {{HH:MM}} | {{escalation}} |
| {{HH:MM}} | {{correction shipped}} |

## What went wrong

{{The failure mode. Be specific. Quote tool output / SKILL.md / queries.}}

## Why it wasn't caught earlier

{{The gap in tests / gates / proof discipline that let this slip.}}

## Five whys

1. Why did the skill produce the wrong answer?
2. Why did the failing path exist?
3. Why didn't the test catch it?
4. Why didn't the gate catch it?
5. Why didn't review catch it?

## Corrective actions

| Action | Owner | Lane | Due |
|---|---|---|---|
| {{Specific fix}} | {{name}} | tiny/normal/high-risk | {{date}} |
| {{Test added to prevent recurrence}} | | | |
| {{Gate or lint rule added}} | | | |
| {{Lesson captured + folded}} | | | |

## Lessons learned

- {{Generalizable insight 1}} → folded into BP-{{NN}}
- {{Generalizable insight 2}} → folded into Q{{NN}}

## What worked

{{Don't just list failures. Credit the parts of the harness that DID catch / contain the issue.}}
