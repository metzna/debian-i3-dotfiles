#!/usr/bin/env bash
set -euo pipefail

# Run this script AFTER logging into Firefox at least once.
# It symlinks userChrome.css into the active Firefox profile.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILES_INI="$HOME/.mozilla/firefox/profiles.ini"

if [[ ! -f "$PROFILES_INI" ]]; then
    echo "Fehler: $PROFILES_INI nicht gefunden."
    echo "Firefox mindestens einmal starten, dann dieses Skript erneut ausführen."
    exit 1
fi

# Read the default profile path from the [Install...] section
PROFILE_PATH=$(awk '/^\[Install/ { in_install=1 } in_install && /^Default=/ { sub(/^Default=/, ""); print; exit }' "$PROFILES_INI")

if [[ -z "$PROFILE_PATH" ]]; then
    echo "Fehler: Kein Standard-Profil in $PROFILES_INI gefunden."
    exit 1
fi

PROFILE_DIR="$HOME/.mozilla/firefox/$PROFILE_PATH"

if [[ ! -d "$PROFILE_DIR" ]]; then
    echo "Fehler: Profilordner $PROFILE_DIR existiert nicht."
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
