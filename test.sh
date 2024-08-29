#!/bin/bash

# Funkce pro instalaci závislostí
install_dependencies() {
    echo "Aktualizace balíčků a instalace závislostí..."
    sudo apt update
    sudo apt install -y openjdk-17-jre-headless wget unzip tar git curl screen lib32gcc-s1
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
            # Instalace Vanilla serveru
            wget https://launcher.mojang.com/v1/objects/1c5c77d5b8ffb2cabc690c20b11f7b5462d5b74c/server.jar -O minecraft_server.jar
            ;;
        2)
            # Instalace Spigot serveru
            wget https://download.getbukkit.org/spigot/spigot-$mc_version_number.jar -O spigot.jar
            ;;
        3)
            # Instalace Forge serveru
            wget https://maven.minecraftforge.net/net/minecraftforge/forge/$mc_version_number/forge-$mc_version_number-installer.jar -O forge-installer.jar
            java -jar forge-installer.jar --installServer
            ;;
        4)
            # Instalace Paper serveru
            wget https://papermc.io/api/v2/projects/paper/versions/$mc_version_number/builds/latest/downloads/paper-$mc_version_number-latest.jar -O paper.jar
            ;;
        *)
            echo "Neplatná volba!"
            cd ..
            return
            ;;
    esac

    # Automatické spuštění serveru
    echo "eula=true" > eula.txt
    echo "Spouštění Minecraft serveru..."
    if [ "$mc_version" == "1" ]; then
        java -Xmx1024M -Xms1024M -jar minecraft_server.jar nogui
    elif [ "$mc_version" == "2" ]; then
        java -Xmx1024M -Xms1024M -jar spigot.jar nogui
    elif [ "$mc_version" == "3" ]; then
        java -Xmx1024M -Xms1024M -jar forge-$mc_version_number-universal.jar nogui
    elif [ "$mc_version" == "4" ]; then
        java -Xmx1024M -Xms1024M -jar paper.jar nogui
    fi

    cd ..
    echo "Minecraft server byl nainstalován a spuštěn!"
}

# Funkce pro instalaci 7 Days to Die serveru pomocí SteamCMD
install_7d2d() {
    echo "Instalace 7 Days to Die serveru pomocí SteamCMD..."
    
    # Stažení a instalace SteamCMD
    mkdir -p steamcmd
    cd steamcmd
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar -xvzf steamcmd_linux.tar.gz

    # Stažení a instalace 7 Days to Die serveru
    ./steamcmd.sh +login anonymous +force_install_dir ../7d2d-server +app_update 294420 validate +quit

    cd ../7d2d-server

    # Automatické spuštění serveru
    echo "Spouštění 7 Days to Die serveru..."
    screen -S 7d2d-server ./startserver.sh -configfile=serverconfig.xml

    cd ..
    echo "7 Days to Die server byl nainstalován a spuštěn!"
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

echo "Instalace dokončena!"
