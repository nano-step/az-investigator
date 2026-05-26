# Contributing to az-investigator

Thanks for considering a contribution. This document explains the workflow so your PR has the highest chance of being merged quickly.

## The 30-second version

1. **Capture a lesson first**: `bash harness/scripts/capture-lesson.sh`. The lesson explains *why* this change is needed.
2. **Open an issue** describing the proposed change (link the lesson file).
3. **Open a PR** that addresses one lesson at a time. Conventional Commit title (`feat:`, `fix:`, `docs:`, `chore:`).
4. **Gemini Code Assist will auto-review** — push fixups until Gemini has no remaining concerns.
5. **A human maintainer signs off** and merges.

That's it. The rest of this doc is detail.

## How the harness changes the contribution model

This isn't a typical OSS repo where you "just fix the bug." It's a self-improving skill. Every code change traces to a captured lesson — a structured markdown file in [`harness/lessons/`](harness/lessons/) that explains:

- What you expected
- What actually happened
- Why it surprised you
- How you diagnosed it
- The generalizable rule

**No lesson, no PR.** This sounds strict; it's actually liberating. The lesson is the story. The code change is the punchline.

### Workflow

```
1. You hit something annoying / wrong / surprising while using the skill.
2. bash harness/scripts/capture-lesson.sh           # produces harness/lessons/YYYY-MM-DD-<slug>.md
3. Fill in the body of that lesson file.
4. bash harness/scripts/promote-to-story.sh harness/lessons/<file>.md
                                                    # produces harness/stories/STORY-NN-<slug>.md
5. Implement the change per the story's "Where this belongs" checklist.
6. bash harness/scripts/run-tests.sh all            # must pass smoke + regression
7. bash harness/scripts/gate-check.sh               # must exit 0
8. Open a PR. Title: feat(skill): <one-line summary> (closes STORY-NN)
```

## Risk lanes

Every story lives in one of three lanes. Match the lane to the change.

| Lane | When | Required artifacts | Reviewer |
|---|---|---|---|
| **tiny** | Single-file edit, no behavior change for existing consumers, no new dependency | Story + ≥1 test | Self + Gemini |
| **normal** | New query / new script / SKILL.md section, **additive only** | Story + spec section + ≥2 tests | Gemini + 1 human |
| **high-risk** | Breaks v1 contract, removes a file, changes the response-shape contract, touches publish path | Story + deep-design + spec + ≥5 tests | Gemini + 2 humans |

When in doubt, **default to the higher lane**.

## Hard gates (every change crosses these)

Enforced by `harness/scripts/gate-check.sh`:

1. v1 consumer regression: the existing `run-kql stg 'AppRequests | take 1'` invocation still returns rows.
2. Response-shape contract: every new output template has Finding / Evidence / Reason / Why / Solution / Open-questions.
3. Proof-tag discipline: every claim labeled ✅ / 🔍 / ❌.
4. No destructive `az` commands in execute paths (`az * delete`, `purge`, `revoke`).
5. Discovery-first: no hardcoded resource names in user-facing query templates.

## What we don't accept

- PRs that introduce hardcoded subscription IDs, instrumentation keys, or tenant IDs in the published files. Use the `<YOUR_…>` placeholder pattern. See [`harness/lessons/2026-05-26-findmnt-misses-bind-children.md`](harness/lessons/2026-05-26-findmnt-misses-bind-children.md) and friends for the format.
- PRs that disable existing tests to make a change pass. Fix the test or fix the change.
- "Mega PRs" that fold 5 lessons into one. One lesson per PR; reviews stay tractable.
- PRs whose response examples mix confirmed claims with hypotheses in narrative prose. The Evidence table is mandatory.

## Style

- **Bash scripts**: pass `bash -n` AND `shellcheck -S warning`. Header comment block explaining the script's CLI contract.
- **KQL templates**: first comment line MUST be `// Discovery: run queries/01-discover-roles.kql first`. Time filter MUST be the first `where` clause (Log Analytics partition pruning depends on it).
- **Markdown**: Mermaid diagrams must pass the [mermaid-validator](https://github.com/mermaid-js/mermaid-cli) — no parens in node labels, no unescaped colons.
- **Lessons**: use the `harness/templates/lesson.md` template; fill every field.

## Local test run

```bash
bash harness/scripts/run-tests.sh smoke         # S01-S10
bash harness/scripts/run-tests.sh regression    # R01-R20
bash harness/scripts/run-tests.sh edge          # E01-E10
bash harness/scripts/gate-check.sh              # the 15-item gate
```

Smoke + regression should be 100% green before you open a PR. Edge can be ≥8/10; document the 2 that fail in `harness/BACKLOG.md`.

## Gemini Code Assist

We use [Gemini Code Assist](https://developers.google.com/gemini-code-assist) as the first-line reviewer on every PR. Gemini will:

- Read your diff
- Cross-reference SKILL.md + linked lesson
- Flag inconsistencies, missing tests, broken examples, and code-smell

**Your job after Gemini posts**: address every comment. Push fixups (don't rebase mid-review; we squash on merge). When Gemini has no remaining concerns, a human will sign off.

If Gemini doesn't post within 10 minutes of PR open, ping a maintainer — the bot may be down or uninstalled.

## Reporting security issues

See [`SECURITY.md`](SECURITY.md). Don't open a public issue for security bugs.

## Code of Conduct

See [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md). Short version: be kind, assume good faith, focus on the code.

## Questions?

Open an issue tagged `question`. We're a small project; we answer.
