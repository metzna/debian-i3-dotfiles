#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Bitte als root ausführen (z.B. mittels su -)."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$SCRIPT_DIR/apt-packages.txt"

if [[ ! -f "$PACKAGES_FILE" ]]; then
    echo "Fehler: Die Datei $PACKAGES_FILE wurde nicht gefunden."
    exit 1
fi

echo "Teil 1: APT-Pakete installieren"
echo "APT Paketlisten werden aktualisiert..."
apt-get update

echo "Lese Pakete aus $PACKAGES_FILE und installiere..."
# Lese die Datei zeilenweise, ignoriere Kommentare und leere Zeilen
PACKAGES=$(grep -vE "^\s*#" "$PACKAGES_FILE" | grep -vE "^\s*$" | tr '\n' ' ')
# shellcheck disable=SC2086
apt-get install -y $PACKAGES

echo "Installation der apt-Liste abgeschlossen."
echo ""

echo "Teil 2: Firefox, Sublime Text und Dropbox"
echo "Vorbereitung..."
apt-get install -y curl gnupg ca-certificates

# -------------------------------------------------
# Mozilla Repo (aktuelles Firefox, nicht ESR)
# -------------------------------------------------
echo "Mozilla Repository wird eingerichtet..."
install -d -m 0755 /etc/apt/keyrings

curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg \
    | gpg --dearmor --yes -o /etc/apt/keyrings/mozilla.gpg

echo "deb [signed-by=/etc/apt/keyrings/mozilla.gpg] https://packages.mozilla.org/apt mozilla main" \
    > /etc/apt/sources.list.d/mozilla.list

# Pinning (damit Mozilla-Version bevorzugt wird)
cat > /etc/apt/preferences.d/mozilla <<EOF
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF

# -------------------------------------------------
# Sublime Text Repo
# -------------------------------------------------
echo "Sublime Repository wird eingerichtet..."
curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg \
    | gpg --dearmor --yes -o /etc/apt/keyrings/sublimehq.gpg

echo "deb [signed-by=/etc/apt/keyrings/sublimehq.gpg] https://download.sublimetext.com/ apt/stable/" \
    > /etc/apt/sources.list.d/sublime-text.list

# -------------------------------------------------
# Dropbox Repo
# -------------------------------------------------
echo "Dropbox Repository wird eingerichtet..."
curl -fsSL https://linux.dropbox.com/fedora/rpm-public-key.asc \
    | gpg --dearmor --yes -o /etc/apt/keyrings/dropbox.gpg

# Dropbox's Debian repo uses 'sid' regardless of the actual Debian version
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/dropbox.gpg] https://linux.dropbox.com/debian sid main" \
    > /etc/apt/sources.list.d/dropbox.list

# -------------------------------------------------
# Installation
# -------------------------------------------------
echo "APT aktualisieren..."
apt-get update

echo "Installiere Firefox (latest), Sublime Text und Dropbox..."
apt-get install -y firefox sublime-text dropbox

echo "Installation von Firefox, Sublime Text und Dropbox beendet."

# -------------------------------------------------
# Teil 3: Obsidian AppImage
# -------------------------------------------------
echo "Teil 3: Obsidian AppImage installieren..."

OBSIDIAN_URL=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
    | grep "browser_download_url" \
    | grep "\.AppImage" \
    | grep -v "arm64" \
    | cut -d '"' -f 4)

if [[ -z "$OBSIDIAN_URL" ]]; then
    echo "Fehler: Obsidian AppImage URL konnte nicht ermittelt werden."
    exit 1
fi

echo "Lade Obsidian herunter: $OBSIDIAN_URL"
curl -fsSL "$OBSIDIAN_URL" -o /opt/obsidian.AppImage
chmod +x /opt/obsidian.AppImage

# Icon aus AppImage extrahieren
echo "Extrahiere Icon..."
cd /tmp
/opt/obsidian.AppImage --appimage-extract obsidian.png 2>/dev/null || true
if [[ -f /tmp/squashfs-root/obsidian.png ]]; then
    cp /tmp/squashfs-root/obsidian.png /opt/obsidian.png
fi
rm -rf /tmp/squashfs-root
cd /

# Desktop Entry erstellen
cat > /usr/share/applications/obsidian.desktop <<EOF
[Desktop Entry]
Name=Obsidian
Exec=/opt/obsidian.AppImage %u
Terminal=false
Type=Application
Icon=/opt/obsidian.png
StartupWMClass=obsidian
MimeType=x-scheme-handler/obsidian;
Categories=Office;
EOF

echo "Obsidian installiert."
