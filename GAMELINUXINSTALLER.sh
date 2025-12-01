#!/bin/bash

clear

echo "
                 .--.
                |o_o |
                |:_/ |
               //   \ \
              (|     | )
             /'\_   _/`\
             \___)=(___/

        ████████╗██╗   ██╗██╗  ██╗
        ╚══██╔══╝██║   ██║██║ ██╔╝
           ██║   ██║   ██║█████╔╝
           ██║   ██║   ██║██╔═██╗
           ██║   ╚██████╔╝██║  ██╗
           ╚═╝    ╚═════╝ ╚═╝  ╚═╝

              GameLinux Installer
"

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

    # Install KDE Plasma and necessary applications
    sudo pacman -S --noconfirm plasma kde-applications

    # Install Steam via Flatpak for Big Picture mode
    flatpak install -y flathub com.valvesoftware.Steam

    mkdir -p ~/.config/autostart
    echo "[Desktop Entry]" > ~/.config/autostart/steam.desktop
    echo "Name=Steam Big Picture" >> ~/.config/autostart/steam.desktop
    echo "Exec=flatpak run com.valvesoftware.Steam steam://open/bigpicture" >> ~/.config/autostart/steam.desktop
    echo "Type=Application" >> ~/.config/autostart/steam.desktop
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
    read -rp "Enter the desktop environment (GNOME, XFCE, etc.) or window manager (e.g., i3): " de
    sudo pacman -S --noconfirm "$de"
    echo "$de installed successfully!"

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

    # Detect GPU
    gpu=$(lspci | grep -i vga)

    # Check for NVIDIA
    if [[ "$gpu" =~ "NVIDIA" ]]; then
        echo "Detected NVIDIA GPU. Installing NVIDIA drivers..."
        sudo pacman -S --noconfirm nvidia nvidia-utils
    # Check for AMD
    elif [[ "$gpu" =~ "AMD" || "$gpu" =~ "ATI" ]]; then
        echo "Detected AMD GPU. Installing AMD drivers..."
        sudo pacman -S --noconfirm xf86-video-amdgpu
    # Check for Intel
    elif [[ "$gpu" =~ "Intel" ]]; then
        echo "Detected Intel GPU. Installing Intel drivers..."
        sudo pacman -S --noconfirm xf86-video-intel
    else
        echo "GPU not recognized. Skipping driver installation."
    fi

    # Inform user of next step
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
    read -rp "Do you want to create a new user for this system? (y/n): " create_user

    if [[ $create_user =~ ^[Yy]$ ]]; then
        read -rp "Enter the username for the new user: " username
        sudo useradd -m -G wheel -s /bin/bash "$username"
        sudo passwd "$username"
        echo "User '$username' has been created and granted sudo access."
    else
        echo "Skipping user creation."
    fi

    # Proceed to the next step
    read -rp "Press Enter to continue..."
}

#####################################################
# Step: Kernel Selection
#####################################################

step_kernel() {
    clear
    echo "==============================="
    echo " STEP 4: KERNEL INSTALLATION"
    echo "==============================="
    echo "Choose a kernel to install:"
    echo "1) Linux-Zen (recommended)"
    echo "2) Stock Linux Kernel"
    echo "3) Hardened Kernel"
    echo "4) Skip"
    read -rp "Choose an option: " ksel

    case $ksel in
        1) sudo pacman -S linux-zen linux-zen-headers ;;
        2) sudo pacman -S linux linux-headers ;;
        3) sudo pacman -S linux-hardened linux-hardened-headers ;;
        4) echo "Skipping kernel install..." ;;
    esac
}

#####################################################
# Step: System Update
#####################################################

step_update_system() {
    clear
    echo "==============================="
    echo " STEP 5: SYSTEM UPDATE"
    echo "==============================="
    echo "Updating your system..."
    sudo pacman -Syu --noconfirm
    echo "System updated successfully!"
}

#####################################################
# Step: Flatpak Installation (for Steam, Lutris, etc.)
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
# Step: Additional Software Setup (Roblox, Heroic, etc.)
#####################################################

step_roblox() {
    clear
    echo "==============================="
    echo " STEP 7: INSTALLING ROBLOX"
    echo "==============================="
    read -rp "Do you want to install Roblox? (y/n): " rb

    if [[ $rb =~ ^[Yy]$ ]]; then
        flatpak install -y org.vinegarhq.Sober
        sudo pacman -S --noconfirm wine
        echo "Roblox installed!"
    else
        echo "Skipping Roblox installation."
    fi

    read -rp "Press ENTER to continue..."
}

#####################################################
# Step: Heroic Games Launcher
#####################################################

step_heroic() {
    clear
    echo "==============================="
    echo " STEP 8: INSTALLING HEROIC GAMES LAUNCHER"
    echo "==============================="
    read -rp "Install Heroic Games Launcher? (y/n): " hc

    if [[ $hc =~ ^[Yy]$ ]]; then
        flatpak install -y com.heroicgameslauncher.hgl
        echo "Heroic Games Launcher installed!"
    else
        echo "Skipping Heroic Games Launcher installation."
    fi

    read -rp "Press ENTER to continue..."
}

#####################################################
# Step: Steam Installation (via Flatpak)
#####################################################

step_steam() {
    clear
    echo "==============================="
    echo " STEP 9: INSTALLING STEAM"
    echo "==============================="
    flatpak install -y flathub com.valvesoftware.Steam
    echo "Steam installed via Flatpak!"
}

#####################################################
# Step: Game Mode (For performance)
#####################################################

step_gamemode() {
    clear
    echo "==============================="
    echo " STEP 10: INSTALLING GAMEMODE"
    echo "==============================="
    sudo pacman -S --noconfirm gamemode
    echo "Gamemode installed!"

    # Enable Gamemode for all games
    echo "Enabling GameMode for games..."
    echo "[GameMode]" > ~/.config/systemd/user/gamemoded.service
    echo "ExecStart=/usr/bin/gamemoded" >> ~/.config/systemd/user/gamemoded.service
    systemctl --user enable gamemoded.service
    systemctl --user start gamemoded.service
    echo "Gamemode enabled and configured to launch with games."

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
    echo "Verifying that everything is installed correctly..."

    # Verify Steam installation
    if flatpak list | grep -q "com.valvesoftware.Steam"; then
        echo "Steam is installed correctly."
    else
        echo "Steam installation failed."
    fi

    # Verify GPU drivers installation
    if lspci | grep -i "NVIDIA" &> /dev/null; then
        echo "NVIDIA drivers are installed correctly."
    elif lspci | grep -i "AMD" &> /dev/null; then
        echo "AMD drivers are installed correctly."
    elif lspci | grep -i "Intel" &> /dev/null; then
        echo "Intel drivers are installed correctly."
    else
        echo "GPU drivers installation failed."
    fi

    # Verify Gamemode
    if pacman -Qs gamemode &> /dev/null; then
        echo "Gamemode is installed correctly."
    else
        echo "Gamemode installation failed."
    fi

    read -rp "Press Enter to continue..."
}

#####################################################
# Troubleshooting Section (Moved to the end)
#####################################################

step_troubleshoot() {
    clear
    echo "==============================="
    echo " STEP 12: TROUBLESHOOTING"
    echo "==============================="
    echo "Here are some common troubleshooting tips:"

    echo -e "\n1. Steam not launching? Try running: 'flatpak run com.valvesoftware.Steam'."
    echo "2. If you're experiencing poor game performance, make sure you have the correct GPU drivers installed."
    echo "3. If you can't use your Xbox controller, ensure 'xone-dkms' and 'xone-dongle-firmware' are installed."
    echo "4. For issues with flatpak apps, try 'flatpak repair'."
    echo "5. If you're having graphics issues with AMD, try installing 'mesa' alongside the drivers."

    read -rp "Press Enter to continue..."
}

#####################################################
# FINAL STEP: Installation Finished
#####################################################

step_done() {
    clear
    echo "==============================="
    echo " INSTALLATION COMPLETE!"
    echo "==============================="
    echo ""
    echo "All the selected steps have been completed successfully!"
    echo "You can now reboot your system or continue configuring your system as needed."
    echo ""

    read -rp "Would you like to reboot now? (y/n): " reboot_choice

    if [[ $reboot_choice =~ ^[Yy]$ ]]; then
        echo "Rebooting your system now..."
        sudo reboot
    else
        echo "Reboot later by running 'sudo reboot'."
    fi

    echo ""
    echo "Press ENTER to exit the wizard."
    read -rp ""
}

# RUN ALL STEPS
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
