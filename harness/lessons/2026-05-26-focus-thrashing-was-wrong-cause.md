# Lesson: focus-thrashing hypothesis was wrong — lodash throttle made it impossible at the observed rate

| | |
|---|---|
| **Date** | 2026-05-26 |
| **Captured by** | Sisyphus |
| **Severity** | reasoning-error |
| **Cost first time** | 45 minutes |
| **Tool / file / quirk** | useRefetchBalanceOnWindowFocus diagnosis |
| **Triggers re-find** | focus throttle lodash 500ms cannot explain 270 calls per hour |

## What I expected
Browser focus/visibility events could naturally fire 270 times per hour during gameplay.

## What actually happened
User correctly pointed out: a human can't generate 270 focus events/hour. The hook is throttled to 500ms so events would be capped, but more importantly, the events themselves can't happen that often from normal interaction.

## Why it surprised me
I read the hook code and saw 'focus event listener' and immediately built a story without verifying physics.

## How I diagnosed it
User pushback forced me to re-examine. I checked lodash throttle semantics, confirmed it caps dispatches not events, then realized the rate was unexplainable by manual interaction.

## Generalizable rule
Before stating a runtime cause, verify it's physically possible. Code-read alone is insufficient.

## Where this belongs (when promoted)
- [x] BP-3 (proof tags) + harness/scripts/lint-response-shape.sh

## Open follow-ups
Investigate the actual cause — likely takeLatest cancellation killing the modal action, not the polling driver itself.
