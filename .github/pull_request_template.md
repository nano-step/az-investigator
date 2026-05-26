<!-- Thanks for contributing! Please fill in this template — Gemini Code Assist reads it. -->

## Driving lesson

<!-- Link the lesson file in harness/lessons/ that motivates this change. Required for all non-trivial PRs. -->
<!-- Example: harness/lessons/2026-05-26-cosmos-dependency-type-is-azure-documentdb-not-cosmos.md -->

Closes #<issue-number>

## Risk lane

- [ ] **tiny** — single file, no behavior change for existing consumers
- [ ] **normal** — new query / script / SKILL.md section, additive only
- [ ] **high-risk** — breaks v1 contract, removes a file, or touches publish path

## Hard gates (the harness will fail without these)

- [ ] v1 consumer regression test still passes (`bash harness/scripts/run-tests.sh regression` returns 0)
- [ ] If this changes an output template: it still uses the 6 mandatory sections (Finding / Evidence / Reason / Why / Solution / Open-questions)
- [ ] Every new claim in examples / docs is tagged ✅ / 🔍 / ❌
- [ ] No destructive `az` commands (`delete`, `purge`, `revoke`) in execute paths
- [ ] No hardcoded resource names in user-facing query templates — discovery-first

## What this PR does

<!-- 2-3 sentences. Match the lesson's "Where this belongs" checklist. -->

## What this PR does NOT do (scope guard)

<!-- Bullet list of related-but-out-of-scope items. Helps prevent reviewer asking "why didn't you also…" -->

## Test plan

```
bash harness/scripts/run-tests.sh smoke         # S01-S10 (must be 10/10)
bash harness/scripts/run-tests.sh regression    # R01-R20
bash harness/scripts/gate-check.sh              # must exit 0
```

- [ ] Smoke 10/10 pass
- [ ] Regression 20/20 pass
- [ ] gate-check.sh exits 0

## Reviewers

- [ ] Gemini Code Assist (auto)
- [ ] At least one human maintainer

<!-- After Gemini posts, address each comment with a fixup commit. Don't rebase mid-review; we squash on merge. -->
