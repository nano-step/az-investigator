#!/usr/bin/env bash
#
# audit-persistence.sh — Determine which paths survive a sandbox rebuild.
#
# Uses device number (stat -c '%D') because findmnt only shows mount roots,
# not bind-mount children which inherit persistence.

set -u

HOST_DEV=$(stat -c '%D' /home/<user> 2>/dev/null)
[[ -z "$HOST_DEV" ]] && { echo "ERR: cannot stat /home/<user>" >&2; exit 2; }

check_path() {
  local p="$1"
  if [[ ! -e "$p" ]]; then
    printf "MISSING ?   %s\n" "$p"
    return
  fi
  local dev
  dev=$(stat -c '%D' "$p")
  if [[ "$dev" == "$HOST_DEV" ]]; then
    printf "PERSIST ✅  %s\n" "$p"
  else
    printf "OVERLAY ❌  %s (device %s ≠ host %s — wiped on rebuild)\n" "$p" "$dev" "$HOST_DEV"
  fi
}

echo "=== Sandbox persistence audit (host bind device = $HOST_DEV) ==="
for p in \
  /home/<user> \
  /home/<user>/.azure \
  /home/<user>/.config/opencode \
  /home/<user>/.npm \
  /home/<user>/.npm-global \
  /home/<user>/.cache/pip \
  /home/<user>/.local/bin \
  "$HOME/.local/share" \
  "$HOME/.local/share/az-investigator" \
  /tmp \
  /opt/chromium \
  /opt/playwright-browsers
do
  check_path "$p"
done

echo ""
echo "=== Azure auth cache ==="
if [[ -f /home/<user>/.azure/msal_token_cache.json ]]; then
  echo "✅ MSAL cache present — az should pick up cached login on first command"
else
  echo "⚠️  No MSAL cache. User must run 'az login' after install completes."
fi

echo ""
echo "=== Existing az binary (if any) ==="
if command -v az >/dev/null 2>&1; then
  echo "az found at $(command -v az)"
  az --version 2>/dev/null | head -1
elif [[ -x "$HOME/.local/share/az-investigator/az-venv/bin/az" ]]; then
  echo "az found at persistent venv (not on PATH — bashrc may need reload)"
else
  echo "az NOT installed. Run scripts/install.sh."
fi
