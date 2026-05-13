#!/bin/bash

# 1. Enable Non-Free Repositories (Required for AMD Graphics Firmware)
sudo apt install -y software-properties-common
sudo apt-add-repository non-free-firmware -y
sudo apt-add-repository contrib -y
sudo apt update

# 2. Install Essential Tools & Drivers
# Includes firmware-amd-graphics for Athlon 200GE/Vega graphics
sudo apt install -y xserver-xorg-core xserver-xorg-video-all xinit build-essential \
git network-manager pipewire-audio-client-libraries curl wget \
libpam0g-dev libxcb-util0-dev firmware-amd-graphics libgl1-mesa-dri

# 3. Install Minimal KDE Plasma + Dark Mode Assets
sudo apt install -y --no-install-recommends \
    plasma-desktop systemsettings konsole dolphin kwin-x11 \
    plasma-nm breeze-gtk-theme kde-config-gtk-style

# 4. Install/Build Ly (The Console Display Manager)
echo "Building Ly from source..."
sudo rm -rf ly
git clone --recurse-submodules https://github.com/fairyglade/ly
cd ly
make
sudo make install

# Manual fix for "service not found"
if [ -f "res/ly.service" ]; then
    sudo cp res/ly.service /lib/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable ly.service
    echo "Ly service enabled."
else
    echo "Ly build failed. Falling back to LightDM..."
    sudo apt install -y lightdm
    sudo systemctl enable lightdm
fi
cd ..

# 5. Install Latest Firefox (Mozilla Repo)
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
sudo apt update && sudo apt install -y firefox

# 6. Apply Dark Mode Configuration
plasma-apply-lookandfeel org.kde.breezedark.desktop
plasma-apply-colorscheme BreezeDark

mkdir -p ~/.config/gtk-3.0
cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Breeze-Dark
gtk-application-prefer-dark-theme=1
EOF

# 7. Final Cleanup
sudo apt autoremove -y
echo "----------------------------------------------------"
echo "INSTALLATION COMPLETE! Please reboot your system."
echo "----------------------------------------------------"
