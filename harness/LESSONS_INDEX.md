# Lessons Index

Searchable catalog of every lesson captured from real `az-investigator` use. Append to bottom on each new lesson via `harness/scripts/capture-lesson.sh`.

| # | Date | Slug | Severity | Cost-1st-time | Status | Story |
|---|---|---|---|---|---|---|
| L01 | 2026-05-26 | [findmnt-misses-bind-children](lessons/2026-05-26-findmnt-misses-bind-children.md) | annoying | 15min | ✅ folded into [`audit-persistence.sh`](../scripts/audit-persistence.sh) | — |
| L02 | 2026-05-26 | [tmp-is-overlay-wiped-on-rebuild](lessons/2026-05-26-tmp-is-overlay-wiped-on-rebuild.md) | data-corrupting | 30min | ✅ folded into [`install.sh`](../scripts/install.sh) (writes to persistent path) | — |
| L03 | 2026-05-26 | [hardcoded-rolename-was-wrong](lessons/2026-05-26-hardcoded-rolename-was-wrong.md) | data-corrupting | 20min | ✅ folded into discovery-first rule (`queries/01-discover-roles.kql`) | — |
| L04 | 2026-05-26 | [newly-installed-mcp-needs-restart](lessons/2026-05-26-newly-installed-mcp-needs-restart.md) | annoying | 10min | ✅ folded into `install.sh` end-of-run message + SKILL.md Phase 9 | — |
| L05 | 2026-05-26 | [focus-thrashing-was-wrong-cause](lessons/2026-05-26-focus-thrashing-was-wrong-cause.md) | reasoning-error | 45min | ✅ folded into BP-3 (proof tags) + `lint-response-shape.sh` | — |
| L06 | 2026-05-26 | [hmac-vs-cookie-was-speculation](lessons/2026-05-26-hmac-vs-cookie-was-speculation.md) | reasoning-error | 25min | ✅ folded into proof-tag system | — |
| L07 | 2026-05-26 | [www-thewinzone-is-spa-fallback](lessons/2026-05-26-www-thewinzone-is-spa-fallback.md) | annoying | 15min | ✅ folded into `references/devtools-probe.md` + Q14 | — |
| L08 | 2026-05-26 | [takelatest-cancels-modal-mid-catch](lessons/2026-05-26-takelatest-cancels-modal-mid-catch.md) | data-corrupting | 60min | ✅ folded into BP-8 + Q16 + worked example | — |
| L09 | 2026-05-26 | [fetch-defaults-to-disk-cache](lessons/2026-05-26-fetch-defaults-to-disk-cache.md) | annoying | 10min | ✅ folded into `references/devtools-probe.md` | — |
| L10 | 2026-05-26 | [az-resource-list-query-fails-silently](lessons/2026-05-26-az-resource-list-query-fails-silently.md) | annoying | 15min | ✅ folded into Q6 + `run-kql.sh` fallback | — |

## Severity legend

| Severity | Meaning | Triggers backlog? |
|---|---|---|
| `cosmetic` | Style / wording issue, no functional impact | no |
| `annoying` | Slows me down but I recover | yes |
| `data-corrupting` | Gave the wrong answer or no answer when there was one | yes + high-priority |
| `reasoning-error` | I drew an incorrect conclusion that survived multiple turns | yes + Momus review |

## Status legend

| Status | Meaning |
|---|---|
| `📥 captured` | In `lessons/`, not yet promoted |
| `🛠️ promoted` | Story exists, not yet implemented |
| `🚧 in-progress` | Implementation underway |
| `🧪 testing` | Validation ladder running |
| `✅ folded` | Shipped — embedded in skill content / scripts / tests |
| `❌ rejected` | Considered, not actionable (rare; document why) |
| L11 | 2026-05-26 | [cosmos-dependency-type-is-azure-documentdb-not-cosmos](lessons/2026-05-26-cosmos-dependency-type-is-azure-documentdb-not-cosmos.md) | annoying | 10min | 📥 captured | — |
| L12 | 2026-05-26 | [capture-lesson-sh-failed-under-set-u-when-user-env-var-unset](lessons/2026-05-26-capture-lesson-sh-failed-under-set-u-when-user-env-var-unset.md) | annoying | 5min | 📥 captured | — |
| L13 | 2026-05-26 | [rbac-denial-on-cosmos-db-resource-scope-blocks-resource-read](lessons/2026-05-26-rbac-denial-on-cosmos-db-resource-scope-blocks-resource-read.md) | annoying | 15min | 📥 captured | — |
| L14 | 2026-05-26 | [patchasync-80-percent-failure-rate-is-normal-try-patch-then-](lessons/2026-05-26-patchasync-80-percent-failure-rate-is-normal-try-patch-then-.md) | reasoning-error | 20min | 📥 captured | — |
| L15 | 2026-05-26 | [user-id-in-app-insights-is-empty-on-backend-traces-use-custo](lessons/2026-05-26-user-id-in-app-insights-is-empty-on-backend-traces-use-custo.md) | annoying | 10min | 📥 captured | — |
| L16 | 2026-05-26 | [open-ended-portal-resource-link-does-not-specify-the-blade-i](lessons/2026-05-26-open-ended-portal-resource-link-does-not-specify-the-blade-i.md) | annoying | 5min | 📥 captured | — |
