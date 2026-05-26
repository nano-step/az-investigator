#!/usr/bin/env bash
#
# run-kql.sh — Azure Log Analytics + App Insights KQL runner for your team envs.
#
# Usage:
#   run-kql <env> '<kql>'         # inline KQL
#   run-kql <env> -f <file.kql>   # from file
#   echo '<kql>' | run-kql <env> -
#
# Envs: stg | qa | trunk | prod
#
# Auto-falls-back from workspace-mode (table names: AppRequests, AppTraces,
# AppExceptions, AppDependencies, AppEvents) to component-mode (lowercase
# table names: requests, traces, exceptions, dependencies, customEvents)
# when the workspace read is RBAC-denied. The script prints which path it
# used on stderr — write your KQL using the correct table names.

set -euo pipefail

VENV="${AZURE_VENV:-/Users/nhonh/Documents/geargames/.opencode/az-venv}"
if [[ ! -x "$VENV/bin/az" ]]; then
  echo "ERR: az not found at $VENV/bin/az — run skill install.sh first" >&2
  exit 2
fi
. "$VENV/bin/activate"

ENV_NAME="${1:-}"; shift || true
[[ -n "$ENV_NAME" ]] || { echo "Usage: $0 <stg|qa|trunk|prod> '<kql>' | -f <file> | -" >&2; exit 2; }

case "$ENV_NAME" in
  stg|staging) SUB="<YOUR_SUBSCRIPTION_STG>"; RG="<YOUR_RG_STG>"; WS="<YOUR_LA_WORKSPACE_STG>"; AI="<YOUR_APP_INSIGHTS_STG>" ;;
  qa)          SUB="<YOUR_SUBSCRIPTION_QA>"; RG="<YOUR_RG_QA>";   WS="<YOUR_LA_WORKSPACE_QA>";  AI="<YOUR_APP_INSIGHTS_QA>"  ;;
  trunk|tnk)   SUB="<YOUR_SUBSCRIPTION_TNK>"; RG="<YOUR_RG_TNK>";  WS="<YOUR_LA_WORKSPACE_TNK>"; AI="<YOUR_APP_INSIGHTS_TNK>" ;;
  prod)        SUB="<YOUR_SUBSCRIPTION_PRD>"; RG="<YOUR_RG_PRD>"; WS="<YOUR_LA_WORKSPACE_PRD>"; AI="<YOUR_APP_INSIGHTS_PRD>" ;;
  *) echo "ERR: unknown env '$ENV_NAME'. Use: stg|qa|trunk|prod" >&2; exit 2 ;;
esac

case "${1:-}" in
  -f) KQL="$(cat "$2")" ;;
  -)  KQL="$(cat)" ;;
  "") echo "ERR: missing KQL. Pass inline string, -f <file>, or - for stdin" >&2; exit 2 ;;
  *)  KQL="$1" ;;
esac

WORKSPACE_GUID=$(az monitor log-analytics workspace show \
  --subscription "$SUB" -g "$RG" -n "$WS" \
  --query customerId -o tsv 2>/dev/null || true)

if [[ -n "$WORKSPACE_GUID" ]]; then
  echo "[run-kql] env=$ENV_NAME  via=workspace  ws=$WS  customerId=$WORKSPACE_GUID" >&2
  echo "[run-kql] tables: AppRequests, AppTraces, AppExceptions, AppDependencies, AppEvents" >&2
  az monitor log-analytics query \
    --subscription "$SUB" \
    --workspace "$WORKSPACE_GUID" \
    --analytics-query "$KQL" \
    --output json
  exit $?
fi

echo "[run-kql] env=$ENV_NAME  via=component  app=$AI  (workspace read denied; classic schema)" >&2
echo "[run-kql] tables: requests, traces, exceptions, dependencies, customEvents, pageViews, browserTimings" >&2
echo "[run-kql] time column is 'timestamp' (not 'TimeGenerated')" >&2
az monitor app-insights query \
  --subscription "$SUB" \
  --app "$AI" \
  --resource-group "$RG" \
  --analytics-query "$KQL" \
  --output json
