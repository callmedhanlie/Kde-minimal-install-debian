#!/bin/bash

# 1. Update and Base Dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install -y xserver-xorg-core xserver-xorg-video-all xinit build-essential \
git network-manager pipewire-audio-client-libraries curl wget

# 2. Install Minimal KDE Plasma + Dark Mode Assets
# We add breeze-gtk-theme so non-KDE apps (like Firefox) turn dark too
sudo apt install -y --no-install-recommends \
    plasma-desktop \
    systemsettings \
    konsole \
    dolphin \
    kwin-x11 \
    plasma-nm \
    breeze-gtk-theme \
    kde-config-gtk-style

# 3. Install Ly (Ugly SDDM Alternative)
if [ ! -d "ly" ]; then
    git clone --recurse-submodules https://github.com/fairyglade/ly
    cd ly && make && sudo make install
    sudo systemctl enable ly.service
    cd ..
fi

# 4. Install Latest Firefox (Mozilla Repo)
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

sudo apt update && sudo apt install -y firefox

# 5. Apply Dark Mode (System-wide)
# These commands apply the theme to the current user profile
plasma-apply-lookandfeel org.kde.breezedark.desktop
plasma-apply-colorscheme BreezeDark

# 6. Set GTK apps (Firefox/GIMP/etc) to Dark Mode
mkdir -p ~/.config/gtk-3.0
cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Breeze-Dark
gtk-application-prefer-dark-theme=1
EOF

# 7. Final Cleanup
sudo apt autoremove -y

echo "----------------------------------------------------"
echo "SETUP COMPLETE!"
echo "1. Reboot your system."
echo "2. Log in through the Ly interface."
echo "3. Everything should be in Dark Mode."
echo "----------------------------------------------------"
