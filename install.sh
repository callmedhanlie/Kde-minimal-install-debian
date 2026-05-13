#!/bin/bash

# 1. Update Repositories (Debian 13 Trixie)
# This adds the necessary 'non-free-firmware' for your AMD Vega graphics
sudo sed -i 's/main/main contrib non-free non-free-firmware/g' /etc/apt/sources.list
sudo apt update && sudo apt upgrade -y

# 2. Install Hardware Drivers & GTK Bridges
# 'slick-greeter' is the correct package name for Debian
sudo apt install -y xserver-xorg-core xserver-xorg-video-all xinit build-essential \
git network-manager pipewire-audio-client-libraries curl wget \
firmware-amd-graphics libgl1-mesa-dri mesa-vulkan-drivers \
plasma-desktop systemsettings konsole dolphin kwin-x11 plasma-nm \
breeze-gtk-theme kde-config-gtk-style slick-greeter lightdm

# 3. Configure the "Not Ugly" Login Screen
sudo systemctl enable lightdm
sudo mkdir -p /etc/lightdm/lightdm.conf.d/
sudo bash -c 'cat <<EOF > /etc/lightdm/lightdm.conf.d/90-slick-greeter.conf
[Seat:*]
greeter-session=slick-greeter
EOF'

# 4. Install Firefox (Mozilla Repo)
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
sudo apt update && sudo apt install -y firefox

# 5. Global Dark Mode Force (KDE + GTK Apps)
plasma-apply-lookandfeel org.kde.breezedark.desktop
plasma-apply-colorscheme BreezeDark

# Ensure Firefox/GTK apps know they are in Dark Mode
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/gtk-4.0
cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Breeze-Dark
gtk-icon-theme-name=breeze-dark
gtk-application-prefer-dark-theme=1
EOF
cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

# Environment variable for Firefox
if ! grep -q "GTK_THEME=Breeze-Dark" ~/.profile; then
    echo "export GTK_THEME=Breeze-Dark" >> ~/.profile
    echo "export MOZ_ENABLE_WAYLAND=0" >> ~/.profile
fi

# 6. Final Cleanup
sudo apt autoremove -y
echo "----------------------------------------------------"
echo "SETUP COMPLETE! Your login should now look premium."
echo "Please reboot now."
echo "----------------------------------------------------"
