# harness/evidence/

Each test-runner invocation writes a timestamped directory here containing:

- `results.tsv` — per-test verdict (lane, id, status, note)
- `<lane>-<id>.out` — stdout+stderr for every executed case

This directory is **gitignored**. Purpose: local debugging.

To record an external review for the approval gate, write the reviewer name and verdict into `last-review.txt`:

```
Oracle agent, 2026-05-26 — approved with note: tighten R20 expectation regex
```
