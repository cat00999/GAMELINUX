

echo              "GameLinux Installer"


read -rp "Press ENTER to continue..."

#####################################################
# STEP 0 — Choose Installation Mode
#####################################################

choose_mode() {
    clear
    echo "==============================="
    echo " CHOOSE INSTALLATION MODE"
    echo "==============================="
    echo "1) Console Mode (KDE Plasma + Steam Big Picture)"
    echo "2) Desktop Mode (Select your DE/WM)"
    read -rp "Choose an option: " mode

    case $mode in
        1) console_mode_setup ;;
        2) desktop_mode_setup ;;
        *) echo "Invalid option, exiting..."; exit 1 ;;
    esac
}

#####################################################
# Console Mode Setup (KDE Plasma + Steam Big Picture)
#####################################################

console_mode_setup() {
    clear
    echo "==============================="
    echo " SETTING UP CONSOLE MODE"
    echo "==============================="
    echo "Installing KDE Plasma and setting up Steam Big Picture mode..."

    # Install KDE Plasma and required components
    sudo pacman -S --noconfirm plasma kde-applications flatpak

    # Steam via Flatpak
    flatpak install -y flathub com.valvesoftware.Steam

    mkdir -p ~/.config/autostart
    cat <<EOF > ~/.config/autostart/steam.desktop
[Desktop Entry]
Name=Steam Big Picture
Exec=flatpak run com.valvesoftware.Steam steam://open/bigpicture
Type=Application
EOF

    echo "Steam Big Picture will launch on boot."

    read -rp "Press ENTER to continue..."
}

#####################################################
# Desktop Mode Setup (User's choice of DE/WM)
#####################################################

desktop_mode_setup() {
    clear
    echo "==============================="
    echo " SETTING UP DESKTOP MODE"
    echo "==============================="
    echo "Choose your Desktop Environment / Window Manager:"
    echo "1) KDE Plasma"
    echo "2) GNOME"
    echo "3) XFCE"
    echo "4) Cinnamon"
    echo "5) MATE"
    echo "6) i3 Window Manager"
    echo "7) Hyprland"
    echo "8) Qtile"
    echo "9) AwesomeWM"
    read -rp "Choose an option: " de

    case $de in
        1)
            sudo pacman -S --noconfirm plasma kde-applications
            ;;
        2)
            sudo pacman -S --noconfirm gnome
            ;;
        3)
            sudo pacman -S --noconfirm xfce4 xfce4-goodies
            ;;
        4)
            sudo pacman -S --noconfirm cinnamon
            ;;
        5)
            sudo pacman -S --noconfirm mate mate-extra
            ;;
        6)
            sudo pacman -S --noconfirm i3-wm i3status i3lock dmenu
            ;;
        7)
            sudo pacman -S --noconfirm hyprland xdg-desktop-portal-hyprland waybar wofi
            ;;
        8)
            sudo pacman -S --noconfirm qtile
            ;;
        9)
            sudo pacman -S --noconfirm awesome xterm
            ;;
        *)
            echo "Invalid option"; exit 1 ;;
    esac

    echo "Desktop Environment installed successfully!"
    read -rp "Press ENTER to continue..."
}

#####################################################
# GPU Detection and Driver Installation
#####################################################

step_gpu() {
    clear
    echo "==============================="
    echo " STEP 2: GPU DRIVER INSTALLATION"
    echo "==============================="
    echo "Detecting your GPU..."

    gpu=$(lspci | grep -i 'vga\|3d\|display')
    echo "Detected: $gpu"

    if echo "$gpu" | grep -qi "NVIDIA"; then
        echo "Detected NVIDIA GPU. Installing drivers..."
        sudo pacman -S --noconfirm nvidia nvidia-utils
    elif echo "$gpu" | grep -qi "AMD\|ATI"; then
        echo "Detected AMD GPU. Installing drivers..."
        sudo pacman -S --noconfirm xf86-video-amdgpu mesa
    elif echo "$gpu" | grep -qi "Intel"; then
        echo "Detected Intel GPU. Installing drivers..."
        sudo pacman -S --noconfirm xf86-video-intel mesa
    else
        echo "GPU not recognized, skipping."
    fi

    read -rp "Press Enter to continue..."
}

#####################################################
# Multi-User Setup (Option to create a new user)
#####################################################

step_create_user() {
    clear
    echo "==============================="
    echo " STEP 3: MULTI-USER SETUP"
    echo "==============================="
    read -rp "Do you want to create a new user? (y/n): " create_user

    if [[ $create_user =~ ^[Yy]$ ]]; then
        read -rp "Enter the username: " username
        sudo useradd -m -G wheel -s /bin/bash "$username"
        sudo passwd "$username"
        echo "User created: $username"
    else
        echo "Skipping user creation."
    fi

    read -rp "Press Enter to continue..."
}

#####################################################
# Kernel Selection
#####################################################

step_kernel() {
    clear
    echo "==============================="
    echo " STEP 4: KERNEL INSTALLATION"
    echo "==============================="
    echo "1) Linux-Zen (recommended)"
    echo "2) Stock Linux Kernel"
    echo "3) Hardened Kernel"
    echo "4) Skip"
    read -rp "Choose an option: " ksel

    case $ksel in
        1) sudo pacman -S --noconfirm linux-zen linux-zen-headers ;;
        2) sudo pacman -S --noconfirm linux linux-headers ;;
        3) sudo pacman -S --noconfirm linux-hardened linux-hardened-headers ;;
        4) echo "Skipping..." ;;
        *) echo "Invalid option." ;;
    esac
}

#####################################################
# System Update
#####################################################

step_update_system() {
    clear
    echo "Updating your system..."
    sudo pacman -Syu --noconfirm
    echo "System updated successfully!"
}

#####################################################
# Flatpak Installation
#####################################################

step_flatpak() {
    clear
    echo "==============================="
    echo " STEP 6: INSTALLING FLATPAK"
    echo "==============================="
    sudo pacman -S --noconfirm flatpak
    echo "Flatpak installed!"
}

#####################################################
# Roblox
#####################################################

step_roblox() {
    clear
    echo "==============================="
    echo " STEP 7: INSTALLING ROBLOX"
    echo "==============================="
    read -rp "Install Roblox? (y/n): " rb

    if [[ $rb =~ ^[Yy]$ ]]; then
        flatpak install -y flathub org.vinegarhq.Sober
        sudo pacman -S --noconfirm wine
    else
        echo "Skipping Roblox installation."
    fi

    read -rp "Press ENTER to continue..."
}

#####################################################
# Heroic Games Launcher
#####################################################

step_heroic() {
    clear
    echo "==============================="
    echo " STEP 8: INSTALLING HEROIC GAMES LAUNCHER"
    echo "==============================="
    read -rp "Install Heroic? (y/n): " hc

    if [[ $hc =~ ^[Yy]$ ]]; then
        flatpak install -y flathub com.heroicgameslauncher.hgl
    else
        echo "Skipping Heroic."
    fi

    read -rp "Press ENTER to continue..."
}

#####################################################
# Steam
#####################################################

step_steam() {
    clear
    echo "==============================="
    echo " STEP 9: INSTALLING STEAM"
    echo "==============================="
    flatpak install -y flathub com.valvesoftware.Steam
    echo "Steam installed."
}

#####################################################
# Gamemode
#####################################################

step_gamemode() {
    clear
    echo "==============================="
    echo " STEP 10: INSTALLING GAMEMODE"
    echo "==============================="

    sudo pacman -S --noconfirm gamemode

    mkdir -p ~/.config/systemd/user

    cat <<EOF > ~/.config/systemd/user/gamemoded.service
[Unit]
Description=Feral GameMode Daemon

[Service]
ExecStart=/usr/bin/gamemoded

[Install]
WantedBy=default.target
EOF

    systemctl --user enable --now gamemoded.service

    echo "Gamemode installed and enabled."
    read -rp "Press Enter to continue..."
}

#####################################################
# Post-Install Verification
#####################################################

step_verification() {
    clear
    echo "==============================="
    echo " STEP 11: POST-INSTALL VERIFICATION"
    echo "==============================="

    if flatpak list | grep -q "com.valvesoftware.Steam"; then
        echo "✔ Steam is installed"
    else
        echo "✘ Steam installation failed"
    fi

    if pacman -Qs gamemode &>/dev/null; then
        echo "✔ Gamemode installed"
    else
        echo "✘ Gamemode missing"
    fi

    read -rp "Press Enter to continue..."
}

#####################################################
# Troubleshooting
#####################################################

step_troubleshoot() {
    clear
    echo "==============================="
    echo " STEP 12: TROUBLESHOOTING"
    echo "==============================="
    echo "1. Steam issues? Run: flatpak run com.valvesoftware.Steam"
    echo "2. Slow performance? Check GPU drivers."
    echo "3. Flatpak issues? Run: flatpak repair"
    echo "4. Controller issues? Install xone drivers."
    echo "5. AMD problems? Ensure MESA is installed."

    read -rp "Press Enter to continue..."
}

#####################################################
# DONE
#####################################################

step_done() {
    clear
    echo "Installation complete!"
    read -rp "Reboot now? (y/n): " rb

    if [[ $rb =~ ^[Yy]$ ]]; then
        sudo reboot
    else
        echo "Reboot manually when ready."
    fi
}

#####################################################
# RUN ALL STEPS
#####################################################

choose_mode
step_gpu
step_create_user
step_kernel
step_update_system
step_flatpak
step_roblox
step_heroic
step_steam
step_gamemode
step_verification
step_troubleshoot
step_done
