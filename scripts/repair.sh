#!/usr/bin/env bash
#
# repair.sh — Diagnose + restore working state after sandbox rebuild.
#
# Idempotent. Only reinstalls what's missing. Reuses install.sh internally.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

echo "=== Diagnose ==="
bash "$SCRIPT_DIR/audit-persistence.sh"

echo ""
echo "=== Run install.sh (idempotent — skips installed components) ==="
bash "$SCRIPT_DIR/install.sh"

echo ""
echo "=== Verify ==="
. "$HOME/.bashrc" 2>/dev/null || true

if command -v az >/dev/null 2>&1; then
  echo "✅ az ready: $(az --version | head -1)"
else
  echo "❌ az not on PATH after bashrc reload — manual fix needed"
  exit 3
fi

if command -v azmcp >/dev/null 2>&1 || [ -x "$HOME/.npm-global/bin/azmcp" ]; then
  echo "✅ azmcp ready"
else
  echo "❌ azmcp missing — npm install -g @azure/mcp failed?"
fi

if command -v run-kql >/dev/null 2>&1; then
  echo "✅ run-kql on PATH"
else
  echo "❌ run-kql symlink missing — re-run install.sh"
fi

if az account show >/dev/null 2>&1; then
  echo "✅ Azure login cached: $(az account show --query name -o tsv)"
else
  echo "⚠️  Azure login expired — run: az login"
fi
