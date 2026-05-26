# Lesson: /tmp is on overlay and is wiped on container rebuild

| | |
|---|---|
| **Date** | 2026-05-26 |
| **Captured by** | Sisyphus |
| **Severity** | data-corrupting |
| **Cost first time** | 30 minutes |
| **Tool / file / quirk** | install path policy |
| **Triggers re-find** | tmp persist sandbox rebuild ephemeral overlay |

## What I expected
Installing to /tmp/opencode would survive across opencode sessions in the same container.

## What actually happened
On container rebuild, /tmp was wiped. The az-venv (741 MB) had to be reinstalled from scratch.

## Why it surprised me
I knew /tmp was tmpfs on Linux, but didn't realize it was also on the container overlay in this Docker setup — same observable effect either way.

## How I diagnosed it
Used stat -c '%D' on /tmp vs /home/<user>. Different device numbers proved /tmp is overlay-backed.

## Generalizable rule
Install to a path under /home/<user> or a workspace bind mount. Never /tmp for anything that must survive.

## Where this belongs (when promoted)
- [x] scripts/install.sh (writes to persistent project path) + references/known-quirks.md Q2

## Open follow-ups
Are there other skills installing to /tmp? Worth a sweep.
