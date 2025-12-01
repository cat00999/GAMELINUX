# GAMELINUX
an arch linux shell script for gamers that installs gaming things for begginners in gaming :)

ATTENTION:
yes, this script CAN overheat and damage your GPU be warned about that  recommend you going with the moderate though






you have 2 installation methods:
1. console mode: automatically launches the steam big picture mode in boot
2. desktop mode: a normal desktop experience + a menu to choose WMs and DEs
 (note: the console mode comes with KDE plasma but feel free to customize it :) )
STEP 1: set up installation method
STEP 2: GPU driver install (required to overclock later)
STEP 3: multi user setup: in case you have a little brother who is going to game in your pc you can now add multi user accounts: FEEL FREE THIS IS YOUR CHOICE!
STEP 4: install kernel, personally id recommend using linux-zen, because of its low latency and high performance and stability in games
STEP 5: update. the script will run:

         bash: sudo pacman --noconfirm -Syu
STEP 6: flatpak is going to be insalled using the command:


         bash: sudo pacman -S --noconfirm flatpak
STEP 7: optional! if you play roblox (like i do) then i tell you, there IS a way to play roblox in linux so i decided to choose Sober as it makes the roblox launcher run like a native program and boosts performance
you will also be prompted to install Heroic Games Launcher

the both uses their flathub repositorys


        bash: flatpak install -y org.vinegarhq.Sober
        bash: flatpak install -y com.heroicgameslauncher.hgl
STEP 8: installing steam:
the script will use the flathub repository for steam which is

         bash: flatpak install -y com.valvesoftware.Steam

STEP 9: installing and configuring gamemode
if you dont know, gamemode is a software that sets CPU priority to MAXIMUM and i put some configs so that it will launch in every game you open (if its supported)
STEP 10: post install and other stuff




# INSTALLATION





git clone https://github.com/cat00999/GAMELINUX.git
cd GAMELINUX
chmod +x install.sh
./install.sh




the script is open-source and if you do a betterversion show me :)
