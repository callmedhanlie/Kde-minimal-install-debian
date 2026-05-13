#!/bin/bash

# 1. Update and Install Essential Build Tools
sudo apt update && sudo apt upgrade -y
sudo apt install -y xserver-xorg-core xserver-xorg-video-all xinit build-essential \
git network-manager pipewire-audio-client-libraries curl wget \
libpam0g-dev libxcb-util0-dev  # Critical for Ly

# 2. Install Minimal KDE Plasma + Dark Mode Assets
sudo apt install -y --no-install-recommends \
    plasma-desktop systemsettings konsole dolphin kwin-x11 \
    plasma-nm breeze-gtk-theme kde-config-gtk-style

# 3. Install/Build Ly (The Console Display Manager)
echo "Attempting to build Ly..."
git clone --recurse-submodules https://github.com/fairyglade/ly || true
cd ly
make
if sudo make install; then
    sudo systemctl enable ly.service
    echo "Ly installed successfully."
else
    echo "Ly build failed. Installing LightDM as a backup..."
    sudo apt install -y lightdm
    sudo systemctl enable lightdm
fi
cd ..

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

# 5. Force Dark Mode Configuration
# Apply to KDE
plasma-apply-lookandfeel org.kde.breezedark.desktop
plasma-apply-colorscheme BreezeDark

# Apply to GTK Apps (Firefox)
mkdir -p ~/.config/gtk-3.0
cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Breeze-Dark
gtk-application-prefer-dark-theme=1
EOF

# 6. Final Cleanup
sudo apt autoremove -y
echo "----------------------------------------------------"
echo "DONE! Please reboot now."
echo "----------------------------------------------------"
