# Backlog — open lessons + in-progress stories

Lessons promoted to stories live in `stories/`; this is the queue.

## In-progress

_(none yet — v1.0.0 just shipped)_

## Queued (lesson exists, story not yet written)

| Priority | Lesson | Lane est. | Notes |
|---|---|---|---|
| _(empty)_ | | | The 10 seed lessons are all already folded into v1 + PLAN-v2. New entries land here as real-world use surfaces them. |

## Ideas (for future v2.x / v3.0 — not yet a lesson)

| Idea | Source | Status |
|---|---|---|
| Add Resource Graph wrapper `scripts/run-arg.sh` | PLAN-v2.md §1 UC#9-10, 16, 26-27 | tracked in PLAN-v2.md |
| Add typed `az` CLI helper `scripts/run-az.sh` | PLAN-v2.md §1 UC#8, 11-14, 18, 22-23, 26 | tracked in PLAN-v2.md |
| Cost Management query template (cost spike attribution) | PLAN-v2.md UC#11 | tracked in PLAN-v2.md |
| AKS container-events triage template | PLAN-v2.md UC#21-22 | tracked in PLAN-v2.md |
| Cosmos DB throttling diagnostic | PLAN-v2.md UC#24-25 | tracked in PLAN-v2.md |
| Token-cost ceiling check (response must be ≤8K output tokens) | PLAN-v2.md Deliverable 6 #10 | needs gate-check.sh enhancement |
| Automatic lesson capture from session distiller | Stretch — would close the loop fully | bigger lift |

## Done (current release window)

| Story | Shipped in | Date |
|---|---|---|
| Initial harness + 10 seed lessons | v1.0.0 + harness init | 2026-05-26 |
| v2 plan document `PLAN-v2.md` | (plan only, not yet implemented) | 2026-05-26 |

| L11 | [cosmos-dependency-type-is-azure-documentdb-not-cosmos](lessons/2026-05-26-cosmos-dependency-type-is-azure-documentdb-not-cosmos.md) | tbd | annoying — captured 2026-05-26 |

| L12 | [capture-lesson-sh-failed-under-set-u-when-user-env-var-unset](lessons/2026-05-26-capture-lesson-sh-failed-under-set-u-when-user-env-var-unset.md) | tbd | annoying — captured 2026-05-26 |

| L13 | [rbac-denial-on-cosmos-db-resource-scope-blocks-resource-read](lessons/2026-05-26-rbac-denial-on-cosmos-db-resource-scope-blocks-resource-read.md) | tbd | annoying — captured 2026-05-26 |

| L14 | [patchasync-80-percent-failure-rate-is-normal-try-patch-then-](lessons/2026-05-26-patchasync-80-percent-failure-rate-is-normal-try-patch-then-.md) | tbd | reasoning-error — captured 2026-05-26 |

| L15 | [user-id-in-app-insights-is-empty-on-backend-traces-use-custo](lessons/2026-05-26-user-id-in-app-insights-is-empty-on-backend-traces-use-custo.md) | tbd | annoying — captured 2026-05-26 |

| L16 | [open-ended-portal-resource-link-does-not-specify-the-blade-i](lessons/2026-05-26-open-ended-portal-resource-link-does-not-specify-the-blade-i.md) | tbd | annoying — captured 2026-05-26 |
