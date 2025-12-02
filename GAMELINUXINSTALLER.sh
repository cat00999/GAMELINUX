echo "            GameLinux Installer"
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
# Console Mode Setup
#####################################################

console_mode_setup() {
    clear
    echo "==============================="
    echo " SETTING UP CONSOLE MODE"
    echo "==============================="
    echo "Installing KDE Plasma and Steam Big Picture..."

    sudo pacman -S --noconfirm plasma kde-applications flatpak
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
# Desktop Mode Setup
#####################################################

desktop_mode_setup() {
    clear
    echo "==============================="
    echo " SETTING UP DESKTOP MODE"
    echo "==============================="
    echo "Choose your Desktop Environment:"
    echo "1) KDE Plasma"
    echo "2) GNOME"
    echo "3) XFCE"
    echo "4) Cinnamon"
    echo "5) MATE"
    echo "6) i3"
    echo "7) Hyprland"
    echo "8) Qtile"
    echo "9) AwesomeWM"
    read -rp "Choose an option: " de

    case $de in
        1) sudo pacman -S --noconfirm plasma kde-applications ;;
        2) sudo pacman -S --noconfirm gnome ;;
        3) sudo pacman -S --noconfirm xfce4 xfce4-goodies ;;
        4) sudo pacman -S --noconfirm cinnamon ;;
        5) sudo pacman -S --noconfirm mate mate-extra ;;
        6) sudo pacman -S --noconfirm i3-wm i3status i3lock dmenu ;;
        7) sudo pacman -S --noconfirm hyprland xdg-desktop-portal-hyprland waybar wofi ;;
        8) sudo pacman -S --noconfirm qtile ;;
        9) sudo pacman -S --noconfirm awesome xterm ;;
        *) echo "Invalid option"; exit 1 ;;
    esac

    echo "Desktop Environment installed successfully!"
    read -rp "Press ENTER to continue..."
}

#####################################################
# STEP 1 — GPU Drivers
#####################################################

step_gpu() {
    clear
    echo "==============================="
    echo " STEP 1: GPU DRIVER INSTALLATION"
    echo "==============================="
    echo "Detecting GPU…"

    gpu=$(lspci | grep -i 'vga\|3d\|display')
    echo "Detected GPU(s):"
    echo "$gpu"
    echo

    read -rp "Install GPU drivers? (y/n): " install_gpu
    if [[ ! $install_gpu =~ ^[Yy]$ ]]; then
        echo "Skipping GPU drivers."
        return
    fi

    if echo "$gpu" | grep -qi "NVIDIA"; then
        echo "Installing NVIDIA drivers..."
        sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
    elif echo "$gpu" | grep -qi "AMD\|ATI"; then
        echo "Installing AMD drivers..."
        sudo pacman -S --noconfirm xf86-video-amdgpu mesa corectrl
    elif echo "$gpu" | grep -qi "Intel"; then
        echo "Installing Intel drivers..."
        sudo pacman -S --noconfirm xf86-video-intel mesa
    else
        echo "Unknown GPU."
    fi

    read -rp "Press ENTER to continue..."
}

#####################################################
# STEP 2 — Multi-User Setup
#####################################################

step_create_user() {
    clear
    echo "==============================="
    echo " STEP 2: MULTI-USER SETUP"
    echo "==============================="
    read -rp "Create new user? (y/n): " create_user

    if [[ $create_user =~ ^[Yy]$ ]]; then
        read -rp "Username: " username
        sudo useradd -m -G wheel -s /bin/bash "$username"
        sudo passwd "$username"
        echo "User created!"
    fi

    read -rp "Press ENTER to continue..."
}

#####################################################
# STEP 3 — Kernel Selection
#####################################################

step_kernel() {
    clear
    echo "==============================="
    echo " STEP 3: KERNEL INSTALLATION"
    echo "==============================="
    echo "1) Linux-Zen (recommended)"
    echo "2) Stock Kernel"
    echo "3) Hardened"
    echo "4) Skip"
    read -rp "Choose: " k

    case $k in
        1) sudo pacman -S --noconfirm linux-zen linux-zen-headers ;;
        2) sudo pacman -S --noconfirm linux linux-headers ;;
        3) sudo pacman -S --noconfirm linux-hardened linux-hardened-headers ;;
        4) ;;
    esac
}

#####################################################
# STEP 4 — System Update
#####################################################

step_update_system() {
    clear
    echo "Updating system..."
    sudo pacman -Syu --noconfirm
}

##############################################################
# STEP 5 — AUTOMATIC GPU OVERCLOCKING
##############################################################

step_gpu_overclock() {
    clear
    echo "==============================="
    echo " STEP 5: GPU OVERCLOCKING"
    echo "==============================="

    gpu=$(lspci | grep -i 'vga\|3d\|display')
    echo "Detected GPU(s): $gpu"

    # AMD GPU (CoreCtrl)
    if echo "$gpu" | grep -qi "AMD\|ATI"; then
        echo "AMD GPU detected — OC via CoreCtrl."
        echo "Choose OC level:"
        echo "1) Mild"
        echo "2) Medium"
        echo "3) High"
        read -rp "Level: " lv

        mkdir -p ~/.config/corectrl
        echo "[oc]" > ~/.config/corectrl/overclock.conf
        echo "level=$lv" >> ~/.config/corectrl/overclock.conf

        echo "AMD OC profile saved."
        read -rp "Press ENTER..."
        return
    fi

    # Intel GPU — skip
    if echo "$gpu" | grep -qi "Intel"; then
        echo "Intel GPU detected — no OC available."
        read -rp "Press ENTER..."
        return
    fi

    # NVIDIA GPU
    if echo "$gpu" | grep -qi "NVIDIA"; then
        echo "NVIDIA GPU detected."

        # Check if CoolBits enabled
        if grep -Rqi "Coolbits" /etc/X11/xorg.conf.d/20-nvidia.conf 2>/dev/null; then
            echo "CoolBits enabled. Applying OC…"

            echo "Choose OC level:"
            echo "1) Mild"
            echo "2) Medium"
            echo "3) High"
            read -rp "Level: " lvl

            case $lvl in
                1) core=50; mem=100 ;;
                2) core=100; mem=200 ;;
                3) core=150; mem=300 ;;
                *) echo "Invalid"; return ;;
            esac

            if ! nvidia-settings -q GPUGraphicsClockOffset >/dev/null 2>&1; then
                echo "⚠ Cannot access overclock settings. Must run X11 session."
                read -rp "Press ENTER..."
                return
            fi

            nvidia-settings -a "[gpu:0]/GPUGraphicsClockOffset[3]=$core"
            nvidia-settings -a "[gpu:0]/GPUMemoryTransferRateOffset[3]=$mem"

            echo "NVIDIA OC applied: Core +$core, Memory +$mem."
            read -rp "Press ENTER..."
            return
        fi

        # CoolBits NOT enabled — enable & reboot
        echo "CoolBits not enabled. Enabling now..."

        sudo mkdir -p /etc/X11/xorg.conf.d
        sudo tee /etc/X11/xorg.conf.d/20-nvidia.conf >/dev/null <<EOF
Section "Device"
    Identifier "Nvidia Card"
    Driver "nvidia"
    Option "Coolbits" "28"
EndSection
EOF

        echo
        echo "========================================"
        echo " CoolBits enabled."
        echo " A reboot is REQUIRED."
        echo " After reboot, rerun this installer."
        echo " Overclocking will be applied automatically."
        echo "========================================"
        read -rp "Press ENTER to reboot..."
        sudo reboot
    fi
}

#####################################################
# STEP 6 — Flatpak
#####################################################

step_flatpak() {
    sudo pacman -S --noconfirm flatpak
}

#####################################################
# STEP 7 — Roblox
#####################################################

step_roblox() {
    clear
    echo "Install Roblox? (y/n)"
    read -rp "> " rb

    if [[ $rb =~ ^[Yy]$ ]]; then
        flatpak install -y flathub org.vinegarhq.Sober
        sudo pacman -S --noconfirm wine
    fi
}

#####################################################
# STEP 8 — Heroic
#####################################################

step_heroic() {
    clear
    read -rp "Install Heroic? (y/n): " hc
    if [[ $hc =~ ^[Yy]$ ]]; then
        flatpak install -y flathub com.heroicgameslauncher.hgl
    fi
}

#####################################################
# STEP 9 — Steam
#####################################################

step_steam() {
    flatpak install -y flathub com.valvesoftware.Steam
}

#####################################################
# STEP 10 — Gamemode
#####################################################

step_gamemode() {
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
}

#####################################################
# STEP 11 — Verification
#####################################################

step_verification() {
    clear
    echo "Verifying…"

    if flatpak list | grep -q Steam; then
        echo "✔ Steam installed"
    fi
    if pacman -Qs gamemode >/dev/null; then
        echo "✔ Gamemode installed"
    fi

    read -rp "Press ENTER..."
}

#####################################################
# STEP 12 — Troubleshooting
#####################################################

step_troubleshoot() {
    clear
    echo "Common Issues:"
    echo "- If OC didn’t work: Must use X11!"
    echo "- Flatpak repair: flatpak repair"
    read -rp "Press ENTER..."
}

#####################################################
# DONE
#####################################################

step_done() {
    read -rp "Reboot now? (y/n): " rb
    if [[ $rb =~ ^[Yy]$ ]]; then sudo reboot; fi
}

#####################################################
# RUN SEQUENCE
#####################################################

choose_mode
step_gpu
step_create_user
step_kernel
step_update_system
step_gpu_overclock
step_flatpak
step_roblox
step_heroic
step_steam
step_gamemode
step_verification
step_troubleshoot
step_done
