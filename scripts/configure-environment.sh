#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Bitte als root ausführen (sudo)."
    exit 1
fi

TARGET_USER="${SUDO_USER:-}"
if [[ -z "$TARGET_USER" ]]; then
    echo "Fehler: SUDO_USER nicht gesetzt. Skript mit sudo ausführen."
    exit 1
fi

echo "Konfiguriere Systemumgebung..."

# -------------------------------------------------
# Locale und Zeitzone
# -------------------------------------------------
echo "Setze Locale und Zeitzone..."
sed -i 's/^# *\(de_DE.UTF-8\)/\1/' /etc/locale.gen
locale-gen
update-locale LANG=de_DE.UTF-8
timedatectl set-timezone Europe/Berlin

# -------------------------------------------------
# Benutzergruppen
# -------------------------------------------------
echo "Füge $TARGET_USER zu Gruppen hinzu..."
for group in cdrom floppy sudo audio dip video plugdev users netdev input; do
    if getent group "$group" > /dev/null 2>&1; then
        usermod -aG "$group" "$TARGET_USER"
    else
        echo "  Gruppe '$group' nicht vorhanden, übersprungen."
    fi
done

# -------------------------------------------------
# Login-Manager: lightdm aktivieren
# -------------------------------------------------
echo "Aktiviere lightdm..."
systemctl enable lightdm
systemctl set-default graphical.target

# -------------------------------------------------
# i3 als Standard-Session in lightdm setzen
# -------------------------------------------------
echo "Setze i3 als Standard-Session..."
mkdir -p /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/50-i3-session.conf <<EOF
[Seat:*]
user-session=i3
EOF

# -------------------------------------------------
# Standard-Editor: Sublime Text
# -------------------------------------------------
echo "Setze Sublime Text als Standard-Editor..."
update-alternatives --install /usr/bin/editor editor /usr/bin/subl 60
update-alternatives --set editor /usr/bin/subl

# -------------------------------------------------
# Standard-Terminal: alacritty
# -------------------------------------------------
echo "Setze alacritty als Standard-Terminal..."
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/alacritty 50
update-alternatives --set x-terminal-emulator /usr/bin/alacritty

# -------------------------------------------------
# Standard-Browser: Firefox (system-weit + xdg für den User)
# -------------------------------------------------
echo "Setze Firefox als Standard-Browser..."
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 200
update-alternatives --set x-www-browser /usr/bin/firefox
update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/firefox 200
update-alternatives --set gnome-www-browser /usr/bin/firefox

# xdg-settings speichert den Browser pro User in ~/.config/mimeapps.list
runuser -u "$TARGET_USER" -- xdg-settings set default-web-browser firefox.desktop

echo "Systemumgebung konfiguriert."
