#!/usr/bin/env bash

# Path to your Home Manager .nix file
FILE="/home/paddy/nixos-config/users/paddy/home.nix"

# Toggle the boolean
if grep -q 'darkMode = false;' "$FILE"; then
    sed -i 's/darkMode = false;/darkMode = true;/' "$FILE"
elif grep -q 'darkMode = true;' "$FILE"; then
    sed -i 's/darkMode = true;/darkMode = false;/' "$FILE"
else
    echo "darkMode setting not found in $FILE"
    exit 1
fi

home-manager switch -b backup --flake ~/nixos-config#paddy@pj-laptop

# Reload Waybar
pkill -SIGUSR2 waybar

./set-random-wallpaper.sh
