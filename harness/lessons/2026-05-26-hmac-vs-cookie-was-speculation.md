# Lesson: claimed spin webhooks use HMAC, not cookies — was speculation, not evidence

| | |
|---|---|
| **Date** | 2026-05-26 |
| **Captured by** | Sisyphus |
| **Severity** | reasoning-error |
| **Cost first time** | 25 minutes |
| **Tool / file / quirk** | auth model investigation |
| **Triggers re-find** | spin webhook HMAC cookie auth Pragmatic Evolution speculation |

## What I expected
Spin webhooks would use HMAC because that's the standard pattern for game vendor → casino backend integrations.

## What actually happened
When user asked for proof, I had none. The spin requests we observed were actually from the user's browser with the same cookie auth, after a fresh login at 10:58Z.

## Why it surprised me
I imported an architectural pattern from prior knowledge without verifying it applied to this codebase.

## How I diagnosed it
User asked 'where's the proof?' and I had to rerun the queries. The 200-spins came from the SAME browser session that was 401-storming earlier.

## Generalizable rule
Never state a cause as confirmed when it's prior-knowledge speculation. Tag every claim with ✅/🔍/❌ before saying it.

## Where this belongs (when promoted)
- [x] BP-3 + SKILL.md Phase 5 (proof discipline)

## Open follow-ups
Document the actual auth model for game vendor webhooks somewhere — what IS the pattern in this codebase?
