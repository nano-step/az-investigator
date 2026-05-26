#!/usr/bin/env bash
#
# run-tests.sh — Execute the harness test matrix.
#
# Usage:
#   bash harness/scripts/run-tests.sh smoke      # S01-S10 (must all pass before any other lane)
#   bash harness/scripts/run-tests.sh regression # R01-R20
#   bash harness/scripts/run-tests.sh edge       # E01-E10
#   bash harness/scripts/run-tests.sh all        # smoke then regression then edge
#
# Each lane is defined declaratively in harness/tests/<lane>.yaml.
# This runner parses the YAML, runs each case's `cmd`, and checks `expect`.

set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
HARNESS="$SKILL_ROOT/harness"
EVIDENCE="$HARNESS/evidence/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$EVIDENCE"

LANE="${1:-smoke}"
case "$LANE" in
  smoke|regression|edge) LANES=("$LANE") ;;
  all) LANES=(smoke regression edge) ;;
  *) echo "Usage: $0 <smoke|regression|edge|all>" >&2; exit 2 ;;
esac

PASS=0; FAIL=0; SKIP=0
RESULTS_FILE="$EVIDENCE/results.tsv"
printf "lane\tid\tstatus\tnote\n" > "$RESULTS_FILE"

run_lane() {
  local lane="$1"
  local file="$HARNESS/tests/${lane}.yaml"
  [[ -f "$file" ]] || { echo "ℹ️  no test file at $file — skipping lane $lane" >&2; return; }

  echo ""
  echo "=== Lane: $lane (file: $file) ==="

  python3 - "$file" "$lane" "$RESULTS_FILE" "$EVIDENCE" <<'PY'
import sys, subprocess, os, re

path, lane, results_path, evidence_dir = sys.argv[1:5]

try:
    with open(path) as f:
        text = f.read()
except FileNotFoundError:
    sys.exit(0)

try:
    import yaml
    cases = yaml.safe_load(text) or []
except ImportError:
    cases = []
    cur = {}
    for line in text.splitlines():
        if line.startswith("- id:"):
            if cur: cases.append(cur)
            cur = {"id": line.split(":", 1)[1].strip().strip('"').strip("'")}
        elif line.startswith("  ") and ":" in line and cur:
            k, _, v = line.strip().partition(":")
            v = v.strip()
            if (v.startswith('"') and v.endswith('"')) or (v.startswith("'") and v.endswith("'")):
                v = v[1:-1]
            cur[k.strip()] = v
    if cur: cases.append(cur)

passed = failed = skipped = 0
for c in cases:
    cid = c.get("id", "?")
    desc = c.get("desc", "")
    cmd = c.get("cmd", "")
    expect = c.get("expect", "")
    skip_if = c.get("skip_if", "")

    if skip_if and os.system(skip_if + " >/dev/null 2>&1") == 0:
        print(f"  ⊘ {cid}  SKIP  ({skip_if})")
        with open(results_path, "a") as r: r.write(f"{lane}\t{cid}\tskip\t{skip_if}\n")
        skipped += 1
        continue

    if not cmd:
        print(f"  ⊘ {cid}  SKIP  (no cmd)")
        with open(results_path, "a") as r: r.write(f"{lane}\t{cid}\tskip\tno cmd\n")
        skipped += 1
        continue

    out_path = os.path.join(evidence_dir, f"{lane}-{cid}.out")
    try:
        res = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=120)
        out = (res.stdout or "") + (res.stderr or "")
        with open(out_path, "w") as f: f.write(out)
        ok = (res.returncode == 0) and (not expect or re.search(expect, out, re.M))
        if ok:
            print(f"  ✅ {cid}  PASS  {desc[:60]}")
            with open(results_path, "a") as r: r.write(f"{lane}\t{cid}\tpass\t{desc}\n")
            passed += 1
        else:
            print(f"  ❌ {cid}  FAIL  rc={res.returncode}  {desc[:60]}")
            print(f"       evidence: {out_path}")
            with open(results_path, "a") as r: r.write(f"{lane}\t{cid}\tfail\trc={res.returncode}\n")
            failed += 1
    except subprocess.TimeoutExpired:
        print(f"  ⏱ {cid}  TIMEOUT")
        with open(results_path, "a") as r: r.write(f"{lane}\t{cid}\ttimeout\t\n")
        failed += 1

print(f"\n  Summary: {passed} pass / {failed} fail / {skipped} skip")
sys.exit(1 if failed else 0)
PY
  local rc=$?
  return $rc
}

OVERALL_RC=0
for lane in "${LANES[@]}"; do
  run_lane "$lane" || OVERALL_RC=$?
done

echo ""
echo "=== All lanes complete ==="
echo "Evidence: $EVIDENCE"
echo "Results:  $RESULTS_FILE"
exit "$OVERALL_RC"
