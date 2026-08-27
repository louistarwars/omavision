#!/bin/bash
set -euo pipefail

PLUGIN_ID="louistarwars.omavision"
DEST="${HOME}/.config/omarchy/plugins/${PLUGIN_ID}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -a "$SRC" "$DEST"

echo "Installed $PLUGIN_ID to $DEST"
if command -v omarchy >/dev/null 2>&1; then
  omarchy plugin validate "$DEST"
  omarchy plugin enable "$PLUGIN_ID"
  omarchy-shell shell rescanPlugins || true
  echo
  echo "Open with:"
  echo "  omarchy-shell shell summon $PLUGIN_ID '{}'"
fi
