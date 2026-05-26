#!/usr/bin/env bash
#
# lint-kql.sh — Syntax-validate every .kql file in queries/.
#
# Sends each query to `az monitor log-analytics query` with --debug to surface
# parse errors, against staging (smallest blast radius). A successful parse =
# response containing "tables" key, even if zero rows.

set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"

if [[ -z "${AZURE_VENV:-}" ]]; then
  export AZURE_VENV="$SKILL_ROOT/az-venv"
fi
if [[ -x "$AZURE_VENV/bin/az" ]]; then
  PATH="$AZURE_VENV/bin:$PATH"
fi

if ! command -v az >/dev/null 2>&1; then
  echo "⊘ az not installed — skipping KQL syntax probe" >&2
  exit 0
fi

PASS=0; FAIL=0
for f in "$SKILL_ROOT"/queries/*.kql "$SKILL_ROOT"/queries/**/*.kql; do
  [[ -f "$f" ]] || continue
  rel="${f#$SKILL_ROOT/}"
  if grep -q '<.*>' "$f"; then
    echo "  ⊘ $rel  (template — has <PLACEHOLDER>, skipping live probe)"
    continue
  fi
  if "$SKILL_ROOT/scripts/run-kql.sh" stg "$(cat "$f")" >/dev/null 2>&1; then
    echo "  ✅ $rel"
    PASS=$((PASS + 1))
  else
    echo "  ❌ $rel  (KQL probe failed against staging)"
    FAIL=$((FAIL + 1))
  fi
done

echo ""
echo "KQL lint: $PASS pass, $FAIL fail"
exit "$FAIL"
