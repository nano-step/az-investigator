#!/usr/bin/env bash
#
# install.sh — Idempotent install of Azure tooling for the ai-sandbox.
#
# Every step checks if the artifact already exists and skips if so.
# Safe to run repeatedly. Total runtime: ~3 min cold, ~10 sec warm.

set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-$HOME/.local/share/az-investigator}"
AZ_VENV="$PROJECT_DIR/az-venv"
NPM_BIN="$HOME/.npm-global/bin"
LOCAL_BIN="$HOME/.local/bin"
OPENCODE_CFG="$HOME/.config/opencode/opencode.json"

log() { printf "\033[1;36m[install]\033[0m %s\n" "$*"; }
ok()  { printf "\033[1;32m[ok]\033[0m %s\n" "$*"; }
skip(){ printf "\033[1;33m[skip]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[err]\033[0m %s\n" "$*" >&2; }

mkdir -p "$PROJECT_DIR" "$LOCAL_BIN"

if [[ -x "$AZ_VENV/bin/az" ]]; then
  skip "az venv already at $AZ_VENV"
else
  log "Creating Python venv at $AZ_VENV (persistent path)…"
  python3 -m venv "$AZ_VENV"
  log "Installing azure-cli + azure-monitor-query + azure-identity into venv…"
  "$AZ_VENV/bin/pip" install --quiet --upgrade pip wheel setuptools
  "$AZ_VENV/bin/pip" install --quiet azure-cli azure-monitor-query azure-identity
  ok "az installed: $("$AZ_VENV/bin/az" --version | head -1)"
fi

if "$AZ_VENV/bin/az" extension list 2>/dev/null | grep -q '"log-analytics"'; then
  skip "log-analytics extension already present"
else
  log "Installing log-analytics az extension…"
  "$AZ_VENV/bin/az" extension add --name log-analytics --yes --allow-preview true 2>&1 | tail -2
fi

mkdir -p "$NPM_BIN"
export PATH="$NPM_BIN:$PATH"
npm config set prefix "$HOME/.npm-global" >/dev/null 2>&1 || true

if [[ -x "$NPM_BIN/azmcp" ]]; then
  skip "@azure/mcp already at $NPM_BIN/azmcp ($("$NPM_BIN/azmcp" --version 2>/dev/null | head -1))"
else
  log "Installing @azure/mcp (Microsoft Azure MCP server)…"
  npm install -g @azure/mcp --silent 2>&1 | tail -3
  ok "azmcp installed at $NPM_BIN/azmcp"
fi

SCRIPT_SRC="$(dirname "$(readlink -f "$0")")/run-kql.sh"
SCRIPT_DEST="$PROJECT_DIR/run-kql.sh"
if [[ -x "$SCRIPT_DEST" ]] && diff -q "$SCRIPT_SRC" "$SCRIPT_DEST" >/dev/null 2>&1; then
  skip "run-kql.sh already in place + up-to-date"
else
  log "Installing run-kql.sh helper to $SCRIPT_DEST"
  cp "$SCRIPT_SRC" "$SCRIPT_DEST"
  chmod +x "$SCRIPT_DEST"
fi

if [[ -L "$LOCAL_BIN/run-kql" ]] && [[ "$(readlink "$LOCAL_BIN/run-kql")" == "$SCRIPT_DEST" ]]; then
  skip "run-kql symlink already at $LOCAL_BIN/run-kql"
else
  log "Symlinking $LOCAL_BIN/run-kql → $SCRIPT_DEST"
  ln -sf "$SCRIPT_DEST" "$LOCAL_BIN/run-kql"
fi

BLOCK_START="# === AZURE_SANDBOX_BLOCK ==="
BLOCK_END="# === /AZURE_SANDBOX_BLOCK ==="
BLOCK="$BLOCK_START
export PATH=\"\$PATH:$NPM_BIN\"
export AZURE_VENV=\"$AZ_VENV\"
[ -d \"\$AZURE_VENV/bin\" ] && export PATH=\"\$AZURE_VENV/bin:\$PATH\"
alias az-activate='source \"\$AZURE_VENV/bin/activate\"'
$BLOCK_END"

if grep -qF "$BLOCK_START" "$HOME/.bashrc" 2>/dev/null; then
  skip "bashrc already has AZURE_SANDBOX_BLOCK"
else
  log "Appending AZURE_SANDBOX_BLOCK to ~/.bashrc"
  printf "\n%s\n" "$BLOCK" >> "$HOME/.bashrc"
fi

if [[ -f "$OPENCODE_CFG" ]]; then
  if python3 -c "import json; c=json.load(open('$OPENCODE_CFG')); exit(0 if 'azure' in c.get('mcp',{}) else 1)" 2>/dev/null; then
    skip "opencode.json already registers 'azure' MCP"
  else
    log "Registering 'azure' MCP in opencode.json (with timestamped backup)"
    cp "$OPENCODE_CFG" "${OPENCODE_CFG}.bak.pre-azmcp.$(date -u +%Y%m%dT%H%M%SZ)"
    python3 <<PY
import json, sys
p = "$OPENCODE_CFG"
c = json.load(open(p))
c.setdefault("mcp", {})["azure"] = {
    "type": "local",
    "command": ["$NPM_BIN/azmcp", "server", "start"],
    "enabled": True,
}
json.dump(c, open(p, "w"), indent=2)
PY
    ok "opencode.json updated. Restart opencode to load azmcp_* tools."
  fi
else
  err "opencode.json not found at $OPENCODE_CFG — skipping MCP wiring"
fi

echo ""
ok "Install complete."
echo ""
echo "Verify with:"
echo "  source ~/.bashrc && az --version && azmcp --version && run-kql stg 'AppRequests | take 1'"
echo ""
echo "If 'az account show' fails, run 'az login' once. The MSAL token cache will persist."
echo "The 'azure' MCP requires an opencode restart to become available as azmcp_* tools."
