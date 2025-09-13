#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.config/hypr/hyprland.conf"
BACKUP="$HOME/.config/hypr/hyprland.conf.sunshine.bak"
TMP="$(mktemp --tmpdir hypr_config_restore.XXXXXX)"

OLD_LINE='monitor=,preferred,auto,auto'
NEW_LINE='monitor=DP-3, 1920x1080@60, auto, auto'

if [[ ! -f "$CONFIG" ]]; then
  echo "Error: config file not found at $CONFIG" >&2
  exit 2
fi

# Prefer restoring the backup (safe)
if [[ -f "$BACKUP" ]]; then
  cp --preserve=mode,timestamps "$BACKUP" "$CONFIG"
  echo "Restored config from backup: $BACKUP -> $CONFIG"
  exit 0
fi

# No backup found — try to undo the replacement inline (best-effort)
awk -v old="$OLD_LINE" -v new="$NEW_LINE" '
  $0 == new { print old; next }
  { print }
' "$CONFIG" > "$TMP"

if cmp -s "$TMP" "$CONFIG"; then
  rm -f "$TMP"
  echo "No change made: replacement line '$NEW_LINE' not found."
else
  mv "$TMP" "$CONFIG"
  echo "Reverted line:"
  echo "  '$NEW_LINE' -> '$OLD_LINE'"
fi

