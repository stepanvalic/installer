#!/bin/bash

# Funkce pro instalaci závislostí
install_dependencies() {
    echo "Aktualizace balíčků a instalace závislostí..."
    sudo apt update
    sudo apt install -y openjdk-17-jre-headless wget unzip tar git curl screen lib32gcc-s1 tmux
}

# Funkce pro instalaci Minecraft serveru
install_minecraft() {
    echo "Vyberte verzi Minecraft serveru:"
    echo "1) Vanilla"
    echo "2) Spigot"
    echo "3) Forge"
    echo "4) Paper"
    read -p "Vaše volba: " mc_version

    read -p "Zadejte verzi Minecraftu (např. 1.19.4): " mc_version_number

    mkdir -p minecraft-server
    cd minecraft-server

    case $mc_version in
        1)
            wget https://launcher.mojang.com/v1/objects/1c5c77d5b8ffb2cabc690c20b11f7b5462d5b74c/server.jar -O minecraft_server.jar
            ;;
        2)
            wget https://download.getbukkit.org/spigot/spigot-$mc_version_number.jar -O spigot.jar
            ;;
        3)
            wget https://maven.minecraftforge.net/net/minecraftforge/forge/$mc_version_number/forge-$mc_version_number-installer.jar -O forge-installer.jar
            java -jar forge-installer.jar --installServer
            ;;
        4)
            wget https://papermc.io/api/v2/projects/paper/versions/$mc_version_number/builds/latest/downloads/paper-$mc_version_number-latest.jar -O paper.jar
            ;;
        *)
            echo "Neplatná volba!"
            cd ..
            return
            ;;
    esac

    echo "eula=true" > eula.txt

    # Spuštění serveru v tmux
    tmux new-session -d -s minecraft "java -Xmx1024M -Xms1024M -jar $(ls *.jar) nogui"
    cd ..
    echo "Minecraft server byl nainstalován a spuštěn v tmux relaci 'minecraft'!"
}

# Funkce pro instalaci 7 Days to Die serveru pomocí SteamCMD
install_7d2d() {
    echo "Instalace 7 Days to Die serveru pomocí SteamCMD..."

    mkdir -p steamcmd
    cd steamcmd
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar -xvzf steamcmd_linux.tar.gz

    ./steamcmd.sh +login anonymous +force_install_dir ../7d2d-server +app_update 294420 validate +quit

    cd ../7d2d-server

    # Spuštění serveru v tmux
    tmux new-session -d -s 7d2d "./startserver.sh -configfile=serverconfig.xml"

    cd ..
    echo "7 Days to Die server byl nainstalován a spuštěn v tmux relaci '7d2d'!"
}

# Nastavení rozložení v tmux
setup_tmux_layout() {
    tmux new-session -d -s servers
    tmux rename-window -t servers "Server Management"
    tmux split-window -v -p 50
    tmux select-pane -t 0
    tmux send-keys "tmux attach-session -t minecraft" C-m
    tmux select-pane -t 1
    tmux send-keys "tmux attach-session -t 7d2d" C-m
    tmux attach-session -t servers
}

# Menu pro výběr instalace
echo "Vyberte, co chcete nainstalovat:"
echo "1) Minecraft server"
echo "2) 7 Days to Die server"
read -p "Vaše volba: " choice

case $choice in
    1)
        install_dependencies
        install_minecraft
        ;;
    2)
        install_dependencies
        install_7d2d
        ;;
    *)
        echo "Neplatná volba!"
        ;;
esac

# Nastavení a spuštění tmux layoutu
setup_tmux_layout

echo "Instalace dokončena a servery běží v tmux relacích!"
