#!/usr/bin/env bash
set -euo pipefail

echo "Überprüfe das System..."

MISSING=0

# Exemplarische Liste wichtiger Pakete zur Überprüfung
NICHT_GEFUNDEN=()
for pkg in i3-wm lightdm firefox sublime-text alacritty git dropbox; do
    if ! dpkg -l | grep -q "^ii  $pkg"; then
        NICHT_GEFUNDEN+=("$pkg")
        MISSING=$((MISSING + 1))
    fi
done

if [ $MISSING -eq 0 ]; then
    echo "OK: Alle geprüften essentiellen Pakete sind installiert."
else
    echo "FEHLER: Folgende Pakete fehlen:"
    for pkg in "${NICHT_GEFUNDEN[@]}"; do
        echo " - $pkg"
    done
fi

if [[ -f "$HOME/.config/i3" || -L "$HOME/.config/i3" ]]; then
    echo "OK: i3 config Symlink existiert."
else
    echo "WARNUNG: i3 config Symlink fehlt."
    MISSING=$((MISSING + 1))
fi

if [ $MISSING -eq 0 ]; then
    echo "Das System scheint in Ordnung zu sein! Setup erfolgreich durchgeführt."
else
    echo "Es gab Probleme bei der Überprüfung."
    exit 1
fi
