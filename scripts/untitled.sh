#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------
# Debian i3 Setup – Paketinstallation
# Installiert exakt die angegebene Programmliste
# -------------------------------------------------

if [[ $EUID -ne 0 ]]; then
    echo "Bitte mit sudo oder als root ausführen."
    exit 1
fi
echo "Teil 2: Firefox und Sublime"
echo "APT Paketlisten werden aktualisiert..."
apt update

echo "Pakete werden installiert..."

apt install -y \
i3-wm \
i3status \
i3lock \
i3blocks \
lightdm \
lightdm-gtk-greeter \
policykit-1 \
lxappearance \
picom \
nitrogen \
xfce4-screenshooter \
xfce4-clipman-plugin \
xfce4-panel \
xclip \
gdebi \
aptitude \
pulseaudio \
pulseaudio-utils \
pavucontrol \
network-manager \
network-manager-gnome \
network-manager-openvpn \
wireless-tools \
wpasupplicant \
thunar \
thunar-archive-plugin \
file-roller \
gvfs \
udiskie \
git \
gitk \
alacritty \
xterm \
htop \
btop \
neofetch \
ncdu \
tree \
bash-completion \
rofi \
dunst \
feh \
vlc \
curl \
wget \
unzip \
zip \
tar \
fonts-font-awesome \
fonts-dejavu \
fonts-noto

echo "Installation der apt-Liste abgeschlossen."


echo "Teil 2: Firefox und Sublime"
echo "Vorbereitung..."
apt update
apt install -y curl gnupg ca-certificates

# -------------------------------------------------
# Mozilla Repo (aktuelles Firefox, nicht ESR)
# -------------------------------------------------

echo "Mozilla Repository wird eingerichtet..."

install -d -m 0755 /etc/apt/keyrings

curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg \
    | gpg --dearmor -o /etc/apt/keyrings/mozilla.gpg

echo "deb [signed-by=/etc/apt/keyrings/mozilla.gpg] \
https://packages.mozilla.org/apt mozilla main" \
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
    | gpg --dearmor -o /etc/apt/keyrings/sublimehq.gpg

echo "deb [signed-by=/etc/apt/keyrings/sublimehq.gpg] \
https://download.sublimetext.com/ apt/stable/" \
> /etc/apt/sources.list.d/sublime-text.list


# -------------------------------------------------
# Installation
# -------------------------------------------------

echo "APT aktualisieren..."
apt update

echo "Installiere Firefox (latest) und Sublime Text..."
apt install -y firefox sublime-text

echo "Fertig."