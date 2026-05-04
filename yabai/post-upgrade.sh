#!/usr/bin/env bash
# Re-establish the yabai scripting addition after `brew upgrade yabai`.
#
# An upgrade does three things that break your SA setup:
#   1. Replaces /opt/homebrew/bin/yabai — the SHA in /etc/sudoers.d/yabai no
#      longer matches, so passwordless `--load-sa` stops working.
#   2. Reinstalls /Library/ScriptingAdditions/yabai.osax/Contents/MacOS/loader
#      — the PAC ABI byte-patch (0x81 → 0x80) gets clobbered, so injection
#      fails with "could not spawn remote thread: protection failure".
#   3. Replaces the running yabai binary — service needs a restart to pick up
#      the new build.
#
# This script fixes all three, in order. Prompts for sudo once.

set -euo pipefail

YABAI=$(command -v yabai) || { echo "error: yabai not in PATH"; exit 1; }
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PATCH="$SCRIPT_DIR/patch-sa-pac-abi.sh"
[ -x "$PATCH" ] || { echo "error: $PATCH not found / not executable"; exit 1; }

echo "yabai post-upgrade — 3-step recovery"

# ── 1. Regenerate sudoers entry with the new binary's hash ───────────────────
echo
echo "[1/3] refreshing sudoers entry…"
HASH=$(shasum -a 256 "$YABAI" | cut -d ' ' -f 1)
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$HASH $YABAI --load-sa" \
    | sudo tee /private/etc/sudoers.d/yabai > /dev/null
sudo chmod 0440 /private/etc/sudoers.d/yabai
echo "      hash: ${HASH:0:16}…"

# ── 2. Install the new (unpatched) SA loader ─────────────────────────────────
# This will fail to inject — that's expected. We just need the loader file
# on disk so step 3 has something to patch.
echo "[2/3] installing SA loader (initial inject will fail — expected)…"
sudo "$YABAI" --load-sa 2>&1 | sed 's/^/      /' || true

# ── 3. Patch loader's PAC ABI byte, then re-inject ───────────────────────────
echo "[3/3] patching loader and re-injecting…"
sudo "$PATCH" 2>&1 | sed 's/^/      /'
sudo "$YABAI" --load-sa
echo "      SA injected."

# ── restart service so the new binary takes over ─────────────────────────────
echo
echo "restarting yabai service…"
"$YABAI" --restart-service
echo "done."
