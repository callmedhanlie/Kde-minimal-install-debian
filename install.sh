#!/bin/bash

# 1. CLEAN REPOSITORY RESET (The "Nuclear" Option)
# This replaces your current sources with the full Debian 13 Trixie set
sudo bash -c 'cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware

deb http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOF'

sudo apt update && sudo apt upgrade -y

# 2. INSTALL HARDWARE & DESKTOP
# We include the correct AMD firmware for your Athlon 200GE
sudo apt install -y xserver-xorg-core xserver-xorg-video-all xinit build-essential \
git network-manager pipewire-audio-client-libraries curl wget \
firmware-amd-graphics libgl1-mesa-dri mesa-vulkan-drivers \
plasma-desktop systemsettings konsole dolphin kwin-x11 plasma-nm \
breeze-gtk-theme kde-config-gtk-style

# 3. INSTALL SLICK LOGIN (Now it will be found)
sudo apt install -y lightdm slick-greeter
sudo systemctl enable lightdm
sudo mkdir -p /etc/lightdm/lightdm.conf.d/
sudo bash -c 'cat <<EOF > /etc/lightdm/lightdm.conf.d/90-slick-greeter.conf
[Seat:*]
greeter-session=slick-greeter
EOF'

# 4. INSTALL FIREFOX (Mozilla Repo for latest version)
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
sudo apt update && sudo apt install -y firefox

# 5. THE "FORCE DARK" FIX FOR FIREFOX
# Set KDE to Dark Mode
plasma-apply-lookandfeel org.kde.breezedark.desktop
plasma-apply-colorscheme BreezeDark

# Manually create GTK configs so Firefox stays dark
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Breeze-Dark
gtk-application-prefer-dark-theme=1
EOF
cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

# Environment variable for current user session
if ! grep -q "GTK_THEME=Breeze-Dark" ~/.profile; then
    echo "export GTK_THEME=Breeze-Dark" >> ~/.profile
fi

# 6. CLEANUP
sudo apt autoremove -y
echo "----------------------------------------------------"
echo "DONE! Your repositories are fixed and Dark Mode is set."
echo "Please reboot now."
echo "----------------------------------------------------"
