#!/bin/bash

# 1. Enable Non-Free Repos & Update
# This ensures your Athlon 200GE graphics work perfectly
sudo sed -i 's/main/main contrib non-free non-free-firmware/g' /etc/apt/sources.list
sudo apt update && sudo apt upgrade -y

# 2. Install Drivers & Base Desktop
# breeze-gtk-theme and kde-config-gtk-style are the "secret sauce" for Firefox dark mode
sudo apt install -y xserver-xorg-core xserver-xorg-video-all xinit build-essential \
git network-manager pipewire-audio-client-libraries curl wget \
firmware-amd-graphics libgl1-mesa-dri mesa-vulkan-drivers \
plasma-desktop systemsettings konsole dolphin kwin-x11 plasma-nm \
breeze-gtk-theme kde-config-gtk-style

# 3. Install the "Not Ugly" Login (LightDM + Slick Greeter)
sudo apt install -y lightdm lightdm-slick-greeter
sudo systemctl enable lightdm
sudo bash -c 'cat <<EOF > /etc/lightdm/lightdm.conf
[Seat:*]
greeter-session=lightdm-slick-greeter
EOF'

# 4. Install Firefox (Latest Stable)
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
sudo apt update && sudo apt install -y firefox

# 5. FORCE GLOBAL DARK MODE
# Apply Dark Mode to KDE (Qt apps)
plasma-apply-lookandfeel org.kde.breezedark.desktop
plasma-apply-colorscheme BreezeDark

# Apply Dark Mode to GTK (Firefox/Chrome/GIMP)
mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/gtk-4.0

cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Breeze-Dark
gtk-icon-theme-name=breeze-dark
gtk-application-prefer-dark-theme=1
EOF

cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

# Tell Firefox and others to use the system theme via environment variable
if ! grep -q "GTK_THEME=Breeze-Dark" ~/.profile; then
    echo "export GTK_THEME=Breeze-Dark" >> ~/.profile
    echo "export QT_QPA_PLATFORMTHEME=kde" >> ~/.profile
fi

# 6. Final Cleanup
sudo apt autoremove -y
echo "----------------------------------------------------"
echo "SYSTEM READY! Dark mode is forced for all apps."
echo "Please reboot now."
echo "----------------------------------------------------"
