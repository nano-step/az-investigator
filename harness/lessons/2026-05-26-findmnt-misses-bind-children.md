# Lesson: findmnt misses bind-mount children

| | |
|---|---|
| **Date** | 2026-05-26 |
| **Captured by** | Sisyphus |
| **Severity** | annoying |
| **Cost first time** | 15 minutes |
| **Tool / file / quirk** | scripts/audit-persistence.sh |
| **Triggers re-find** | findmnt overlay bind mount persistent sandbox |

## What I expected
findmnt would list every persistent mount, including children of a bind mount.

## What actually happened
findmnt only shows mount roots. ~/.npm-global appeared to be ephemeral overlay even though it inherited persistence from /home/<user>.

## Why it surprised me
I trusted a tool's output without checking its semantics — findmnt is for mount points, not arbitrary paths.

## How I diagnosed it
Cross-checked with stat -c '%D' against /home/<user>'s device number; identical = persistent. Wrote a test file and confirmed it survived.

## Generalizable rule
Use stat -c '%D' compared to a known-persistent path; never findmnt alone for inheriting bind mounts.

## Where this belongs (when promoted)
- [x] references/known-quirks.md Q1 + scripts/audit-persistence.sh

## Open follow-ups
Worth checking other workspace skills that audit persistence — are they making the same mistake?
