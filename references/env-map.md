# your Azure Environment Map

Last verified: 2026-05-26 by Sisyphus investigation session.

Source: `az account list` + `az resource list --resource-type Microsoft.Insights/components` across all subscriptions, cross-referenced with `playsweeps-web/.env.jarvis*` files.

**Always re-verify before relying on these values.** Run `queries/01-discover-roles.kql` against the target env.

## Subscription / RG / App Insights map

| Env | Subscription | RG | App Insights | Workspace (LA) | Region |
|---|---|---|---|---|---|
| stg | `<YOUR_SUBSCRIPTION_STG>` | `<YOUR_RG_STG>` | `<YOUR_APP_INSIGHTS_STG>` | `<YOUR_LA_WORKSPACE_STG>` | South Central US |
| qa | `<YOUR_SUBSCRIPTION_QA>` | `<YOUR_RG_QA>` | `<YOUR_APP_INSIGHTS_QA>` | `<YOUR_LA_WORKSPACE_QA>` | East US (EA) |
| trunk | `<YOUR_SUBSCRIPTION_TNK>` | `<YOUR_RG_TNK>` | `<YOUR_APP_INSIGHTS_TNK>` | `<YOUR_LA_WORKSPACE_TNK>` | East US |
| prod | `<YOUR_SUBSCRIPTION_PRD>` | `<YOUR_RG_PRD>` | `<YOUR_APP_INSIGHTS_PRD>` | `<YOUR_LA_WORKSPACE_PRD>` | South Central US |

## Instrumentation keys (from playsweeps-web/.env files)

These are the **frontend** keys. The backend uses the same App Insights resource per env.

| Env | Key |
|---|---|
| dev | `<YOUR_INSTRUMENTATION_KEY_DEV>` |
| qa1–4 / review | `<YOUR_INSTRUMENTATION_KEY_QA>` (shared) |
| stg | `<YOUR_INSTRUMENTATION_KEY_STG>` |
| trunk | `<YOUR_INSTRUMENTATION_KEY_TNK>` |
| prod | `<YOUR_INSTRUMENTATION_KEY_PRD>` |

Note: the prod **backend** App Insights `<YOUR_APP_INSIGHTS_PRD>` has its own instrumentation key (different from the FE key above). Verify with `az monitor app-insights component show -g <rg> --app <name> --query instrumentationKey`.

## Backend hosts

| Env | API host |
|---|---|
| prod | `<YOUR_BACKEND_HOST>` |
| stg | `<YOUR_BACKEND_HOST_STG>` |
| trunk | `<YOUR_BACKEND_HOST_TNK>` |
| qa1 | `backend.sweeps.qa1.<your-qa-domain>` |
| qa2 | `backend.sweeps.qa2.<your-qa-domain>` |
| qa3 | `backend.sweeps.qa3.<your-qa-domain>` |
| qa4 | `backend.sweeps.qa4.<your-qa-domain>` |
| review | `<YOUR_BACKEND_HOST_REVIEW>` |
| unlocked | `<YOUR_BACKEND_HOST_UNLOCKED>` |

## Observed `cloud_RoleName` values per env (24h window, 2026-05-26)

Staging top roles by trace volume:

| AppRoleName | Notes |
|---|---|
| (empty) | Some health probes / sidecar telemetry without role attribution |
| `<your-bi-event-role>` | The BI event publisher — `win_amount`, `bet_amount`, etc. live here |
| `<your-function-app-stg>` | Azure Function — EventHub consumer |
| `<YOUR_BACKEND_ROLE>` | **The main backend API service** — most user-facing requests |
| `<your-payment-webhook>` | Paysafe payment webhook receiver |
| `<your-aux-service>` | Auxiliary service |
| `<your-game-service-role>` | game-vendor game service (low traffic on staging) |

Re-discover via `queries/01-discover-roles.kql` if values look off.

## Tenant

All four subs are in the same tenant: `<YOUR_TENANT_ID>` (<YOUR_TENANT_NAME>).
