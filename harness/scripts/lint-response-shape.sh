#!/usr/bin/env bash
#
# lint-response-shape.sh — Ensure every worked example + every SKILL.md output
# template carries the 6 mandatory sections (Finding, Evidence, Reason,
# Why it matters, Solution, Open questions) AND uses proof tags
# (✅ confirmed | 🔍 hypothesis | ❌ refuted).

set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"

REQUIRED_SECTIONS=(
  "## Finding"
  "## Evidence"
  "## Reason"
  "## Why it matters"
  "## Solution"
  "## Open questions"
)

PASS=0; FAIL=0

check_file() {
  local f="$1"; local rel="${f#$SKILL_ROOT/}"
  local missing=()
  for s in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -qF "$s" "$f"; then missing+=("$s"); fi
  done
  if (( ${#missing[@]} == 0 )); then
    echo "  ✅ $rel  (all 6 sections present)"
    PASS=$((PASS + 1))
  else
    echo "  ❌ $rel  (missing: ${missing[*]})"
    FAIL=$((FAIL + 1))
  fi
}

for f in "$SKILL_ROOT/PLAN-v2.md"; do
  if grep -qE 'Worked Example [AB]' "$f"; then
    check_file "$f"
  fi
done

CONFIRMED=$(grep -rEc '✅ confirmed' "$SKILL_ROOT/PLAN-v2.md" 2>/dev/null || echo 0)
HYPO=$(grep -rEc '🔍 hypothesis' "$SKILL_ROOT/PLAN-v2.md" 2>/dev/null || echo 0)
REFUTED=$(grep -rEc '❌ refuted' "$SKILL_ROOT/PLAN-v2.md" 2>/dev/null || echo 0)
echo ""
echo "Proof tags found in PLAN-v2.md:  ✅=$CONFIRMED  🔍=$HYPO  ❌=$REFUTED"

if (( CONFIRMED < 3 || HYPO < 1 )); then
  echo "  ⚠️  Proof-tag coverage looks low — worked examples should demonstrate all 3 tag types"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "Response-shape lint: $PASS pass, $FAIL fail"
exit "$FAIL"
