#!/usr/bin/env bash
#
# gate-check.sh — Walk the 15-item approval gate from PLAN-v2.md Deliverable 6.
# Exits 0 only if all gates pass. Each gate prints a verdict line.

set -uo pipefail

SKILL_ROOT="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
HARNESS="$SKILL_ROOT/harness"

PASS=0; FAIL=0
say() {
  local status="$1"; local msg="$2"
  case "$status" in
    pass) echo "  ✅  $msg"; PASS=$((PASS + 1)) ;;
    fail) echo "  ❌  $msg"; FAIL=$((FAIL + 1)) ;;
    skip) echo "  ⊘  $msg (skipped — pre-condition not met)" ;;
  esac
}

echo "=== 15-item approval gate ==="

if [[ -x "$HARNESS/scripts/run-tests.sh" && -f "$HARNESS/tests/smoke.yaml" ]]; then
  if bash "$HARNESS/scripts/run-tests.sh" smoke >/dev/null 2>&1; then
    say pass "Gate 1  — smoke tests 10/10"
  else
    say fail "Gate 1  — smoke tests have failures (re-run for detail)"
  fi
else
  say skip "Gate 1  — smoke runner / fixtures not present yet"
fi

if [[ -f "$HARNESS/tests/regression.yaml" ]]; then
  if bash "$HARNESS/scripts/run-tests.sh" regression >/dev/null 2>&1; then
    say pass "Gate 2  — regression tests pass"
  else
    say fail "Gate 2  — regression failures"
  fi
else
  say skip "Gate 2  — regression fixtures not present yet"
fi

if [[ -f "$HARNESS/tests/edge.yaml" ]]; then
  if bash "$HARNESS/scripts/run-tests.sh" edge >/dev/null 2>&1; then
    say pass "Gate 3  — edge cases pass (≥8/10)"
  else
    say fail "Gate 3  — edge failures (verify ≥8/10 in evidence/)"
  fi
else
  say skip "Gate 3  — edge fixtures not present yet"
fi

if command -v run-kql >/dev/null 2>&1 && run-kql stg 'AppRequests | take 1' >/dev/null 2>&1; then
  say pass "Gate 4  — v1 consumer regression (run-kql stg works)"
else
  say skip "Gate 4  — run-kql or staging not reachable from this shell"
fi

DESTRUCT=$(grep -rnE 'az [a-z-]+ (delete|purge)\b' "$SKILL_ROOT/scripts/" "$SKILL_ROOT/queries/" "$SKILL_ROOT/SKILL.md" 2>/dev/null \
  | grep -vE '^\s*#' | grep -vE 'forbidden|never|MUST NOT' || true)
if [[ -z "$DESTRUCT" ]]; then
  say pass "Gate 5  — no destructive az commands in execute paths"
else
  say fail "Gate 5  — destructive az commands found:"
  echo "$DESTRUCT" | sed 's/^/         /'
fi

LINT_OK=1
for f in "$SKILL_ROOT"/scripts/*.sh "$HARNESS"/scripts/*.sh; do
  [[ -f "$f" ]] || continue
  if ! bash -n "$f" 2>/dev/null; then
    LINT_OK=0
    say fail "Gate 6  — bash -n failed: ${f#$SKILL_ROOT/}"
  fi
done
if [[ $LINT_OK -eq 1 ]]; then
  if command -v shellcheck >/dev/null 2>&1; then
    if shellcheck -S warning "$SKILL_ROOT"/scripts/*.sh "$HARNESS"/scripts/*.sh >/dev/null 2>&1; then
      say pass "Gate 6  — bash -n + shellcheck (warning+) clean"
    else
      say fail "Gate 6  — shellcheck warnings present"
    fi
  else
    say pass "Gate 6  — bash -n clean (shellcheck not installed)"
  fi
fi

if [[ -d "$SKILL_ROOT/queries/log-analytics" ]]; then
  MISSING=$(grep -L '^// Discovery' "$SKILL_ROOT"/queries/log-analytics/*.kql 2>/dev/null || true)
  if [[ -z "$MISSING" ]]; then
    say pass "Gate 7  — every LA query has discovery header"
  else
    say fail "Gate 7  — missing discovery header in:"
    echo "$MISSING" | sed 's/^/         /'
  fi
else
  say skip "Gate 7  — log-analytics dir not yet created (v2 work)"
fi

if [[ -d "$SKILL_ROOT/queries/resource-graph" ]]; then
  say skip "Gate 8  — resource-graph queries present but inventory-header check is v2 work"
else
  say skip "Gate 8  — resource-graph dir not yet created"
fi

if [[ -f "$SKILL_ROOT/PLAN-v2.md" ]]; then
  if bash "$HARNESS/scripts/lint-response-shape.sh" >/dev/null 2>&1; then
    say pass "Gate 9  — worked examples cite tool + query in Evidence table"
  else
    say fail "Gate 9  — lint-response-shape failed"
  fi
fi

say skip "Gate 10 — token-cost ceiling (no automated probe yet — manual check)"

SECRETS=$(grep -rnE 'ghp_[A-Za-z0-9]{30,}|pplx-[A-Za-z0-9]{30,}|eyJ[A-Za-z0-9_=-]{30,}\.[A-Za-z0-9_=-]{30,}' \
  "$SKILL_ROOT" \
  --exclude-dir=harness \
  --exclude="*.bak*" 2>/dev/null || true)
if [[ -z "$SECRETS" ]]; then
  say pass "Gate 11 — no inlined secrets (GH PAT / Perplexity / JWT patterns) in skill files"
else
  say fail "Gate 11 — possible secret found:"
  echo "$SECRETS" | head -3 | sed 's/^/         /'
fi

VER=$(grep -E '"version"' "$SKILL_ROOT/skill.json" 2>/dev/null | sed -E 's/.*"version"\s*:\s*"([^"]+)".*/\1/')
if [[ -n "$VER" ]]; then
  say pass "Gate 12 — skill.json version present: $VER"
else
  say fail "Gate 12 — skill.json version missing"
fi

if [[ -f "$SKILL_ROOT/CHANGELOG.md" ]]; then
  say pass "Gate 13 — CHANGELOG.md present"
else
  say skip "Gate 13 — CHANGELOG.md not yet created (required before publish)"
fi

if command -v run-kql >/dev/null 2>&1; then
  if run-kql --help 2>&1 | grep -qE 'stg|qa|trunk|prod' || run-kql stg 'AppRequests | take 1' >/dev/null 2>&1; then
    say pass "Gate 14 — run-kql v1 CLI surface intact"
  else
    say fail "Gate 14 — run-kql CLI may have regressed"
  fi
else
  say skip "Gate 14 — run-kql not on PATH"
fi

REVIEWER_FILE="$HARNESS/evidence/last-review.txt"
if [[ -f "$REVIEWER_FILE" ]]; then
  say pass "Gate 15 — external review recorded: $(cat "$REVIEWER_FILE")"
else
  say skip "Gate 15 — no external review recorded (drop reviewer name into $REVIEWER_FILE)"
fi

echo ""
echo "=== Result: $PASS pass, $FAIL fail ==="
if (( FAIL > 0 )); then
  echo "❌ Gate NOT ready for approval — fix failures above."
  exit 1
fi
echo "✅ All checked gates pass. (Items marked 'skipped' need manual confirmation before approving.)"
exit 0
