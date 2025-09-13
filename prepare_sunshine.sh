#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.config/hypr/hyprland.conf"
BACKUP="$HOME/.config/hypr/hyprland.conf.sunshine.bak"
TMP="$(mktemp --tmpdir hypr_config.XXXXXX)"

OLD_LINE='monitor=,preferred,auto,auto'
NEW_LINE='monitor=DP-3, 1920x1080@60, auto, auto'

if [[ ! -f "$CONFIG" ]]; then
  echo "Error: config file not found at $CONFIG" >&2
  exit 2
fi

# Create a backup if one doesn't already exist (so undo is safe)
if [[ ! -f "$BACKUP" ]]; then
  cp --preserve=mode,timestamps "$CONFIG" "$BACKUP"
  echo "Backup created at: $BACKUP"
else
  echo "Backup already exists at: $BACKUP"
fi

# Replace only exact matching line (whole-line match). Preserve file mode/timestamps by copying tmp -> file.
awk -v old="$OLD_LINE" -v new="$NEW_LINE" '
  $0 == old { print new; next }
  { print }
' "$CONFIG" > "$TMP"

# If the change resulted in same content, notify; otherwise move tmp into place
if cmp -s "$TMP" "$CONFIG"; then
  rm -f "$TMP"
  echo "No change needed: exact line '$OLD_LINE' not found or already replaced."
else
  mv "$TMP" "$CONFIG"
  echo "Replaced line:"
  echo "  '$OLD_LINE' -> '$NEW_LINE'"
fi
