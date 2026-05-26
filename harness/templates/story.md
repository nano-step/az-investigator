# STORY-{{NN}}: {{TITLE}}

| | |
|---|---|
| **Date opened** | {{YYYY-MM-DD}} |
| **Lane** | tiny / normal / high-risk |
| **Change type** | skill-content / script / query / response-shape / test / publish |
| **Driving lesson** | [L{{NN}}](../lessons/{{file}}.md) |
| **Linked PLAN-v2 section** | §{{N}} {{Deliverable name}} (or "none") |
| **Tracking issue** | nano-step/skill-manager#{{N}} (created on promotion) |
| **Status** | 🛠️ promoted / 🚧 in-progress / 🧪 testing / ✅ shipped / ❌ abandoned |

## Goal

{{One paragraph: what changes when this is shipped.}}

## Non-goals

{{Bullet list of things this story explicitly does NOT do, to scope-limit the change.}}

## Acceptance criteria

- [ ] Hard gate 1 (v1 v1 regression) passes
- [ ] Hard gate 2 (response-shape contract) preserved
- [ ] Hard gate 3 (proof-tag discipline) preserved
- [ ] Hard gate 4 (no destructive `az` commands) preserved
- [ ] Hard gate 5 (discovery-first) preserved
- [ ] {{Story-specific criterion 1}}
- [ ] {{Story-specific criterion 2}}
- [ ] At least 1 new test in `harness/tests/{{level}}.yaml`
- [ ] Lesson L{{NN}} status updated to ✅ folded in `LESSONS_INDEX.md`

## Implementation outline

{{For tiny lane: 2-4 lines.
  For normal lane: file-by-file diff plan.
  For high-risk lane: full spec section + Oracle review notes + Momus review pending.}}

## Test plan

{{List of test IDs from harness/tests/ that exercise this change. New tests defined in this story go here too.}}

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| {{e.g. breaks consumer parsing v1 output}} | low/med/high | {{e.g. keep v1 path via symlink for one minor version}} |

## Deferred decisions

{{Things that came up during scoping but are out of this story's lane. Drop them in `BACKLOG.md` as new ideas.}}

## Sign-off

- [ ] Self-review: validation ladder green (`bash harness/scripts/run-tests.sh all`)
- [ ] Self-review: `bash harness/scripts/gate-check.sh` exits 0
- [ ] Reviewer (lane-dependent): Self / Oracle / Momus
- [ ] Reviewer signed off on: {{date}}
- [ ] Shipped in: v{{semver}}
