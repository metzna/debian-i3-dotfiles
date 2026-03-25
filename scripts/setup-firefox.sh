#!/usr/bin/env bash
set -euo pipefail

# Run this script AFTER starting Firefox at least once.
# It symlinks userChrome.css into the active Firefox profile.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Find the Firefox profile directory — check XDG path first, then legacy
PROFILE_DIR=$(find "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox" \
    -maxdepth 1 -type d \( -name "*.default-release" -o -name "*.default" \) \
    2>/dev/null | head -1)

if [[ -z "$PROFILE_DIR" ]]; then
    echo "Fehler: Kein Firefox-Profilordner gefunden."
    echo "Firefox mindestens einmal starten, dann dieses Skript erneut ausführen."
    exit 1
fi

echo "Firefox-Profil gefunden: $PROFILE_DIR"

# Enable userChrome.css in Firefox (required since Firefox 69)
USER_JS="$PROFILE_DIR/user.js"
if ! grep -q "toolkit.legacyUserProfileCustomizations.stylesheets" "$USER_JS" 2>/dev/null; then
    echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$USER_JS"
    echo "user.js: Stylesheet-Support aktiviert."
fi

mkdir -p "$PROFILE_DIR/chrome"
ln -sfn "$REPO_DIR/config/firefox/userChrome.css" "$PROFILE_DIR/chrome/userChrome.css"

echo "userChrome.css verlinkt. Firefox neu starten."
