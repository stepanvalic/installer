#!/bin/bash

install_minecraft_dependencies() {
    echo "Aktualizace balíčků a instalace závislostí pro Minecraft server..."
    sudo apt update
    sudo apt install -y openjdk-17-jre-headless wget unzip tar curl
}

install_7d2d_dependencies() {
    echo "Aktualizace balíčků a instalace závislostí pro 7 Days to Die server..."
    sudo apt update
    sudo apt install -y wget tar git curl screen lib32gcc-s1
}

install_fivem_dependencies() {
    echo "Aktualizace balíčků a instalace závislostí pro FiveM server..."
    sudo apt update
    sudo apt install -y wget tar curl screen
}

install_phpmyadmin_dependencies() {
    echo "Aktualizace balíčků a instalace závislostí pro PHPMyAdmin..."
    sudo apt update
    sudo apt install -y apache2 php libapache2-mod-php php-mysql mariadb-server mariadb-client
}

install_minecraft() {
    install_minecraft_dependencies

    echo "Vyberte verzi Minecraft serveru:"
    echo "1) Vanilla asi nefunguje  "
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

    java -Xmx1024M -Xms1024M -jar $(ls *.jar) nogui

    cd ..
    echo "Minecraft server byl nainstalován a spuštěn!"
}

install_7d2d() {
    install_7d2d_dependencies

    echo "Instalace 7 Days to Die serveru pomocí SteamCMD..."

    mkdir -p steamcmd
    cd steamcmd
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar -xvzf steamcmd_linux.tar.gz

    ./steamcmd.sh +login anonymous +force_install_dir ../7d2d-server +app_update 294420 validate +quit

    cd ../7d2d-server

    ./startserver.sh -configfile=serverconfig.xml

    cd ..
    echo "7 Days to Die server byl nainstalován a spuštěn!"
}

install_FiveM(){
    install_fivem_dependencies

    mkdir -p FiveM
    cd FiveM
    echo "https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/" 
    echo "Vložte odkaz na FiveM Linux stažení:"
    read build_link
    wget $build_link
    echo "Rozbalují se soubory"
    tar xf fx.tar.xz
    echo "Soubory byly úspěšně rozbaleny"
    rm -r fx.tar.xz
    echo "Instaluji screen pro běh na pozadí"
    screen ./run.sh
    ip_address=$(hostname -I | awk '{print $1}')
    if [[ -z "$ip_address" ]]; then
        ip_address=$(hostname -I | awk '{print $2}')
    fi
    echo "Váš server běží na: $ip_address:40120" 
}

install_phpmyadmin() {

    echo -e "\033[33mUpozornění: Instalace PHPMyAdmin nemusí být plně funkční.\033[0m"
    read -p "Pokud si toho jste vědomi a chcete pokračovat, zadejte 'ano': " confirmation
    if [ "$confirmation" != "ano" ]; then
        echo -e "\033[31mInstalace PHPMyAdmin byla zrušena.\033[0m"
        return
    fi

    install_phpmyadmin_dependencies

    echo "Instalace PHPMyAdmin..."

    sudo mysql_secure_installation

    echo "Vytvořit speciálního uživatele kromě roota? (y/n)"
    read create_user
    if [ "$create_user" == "y" ]; then
        read -p "Zadejte jméno nového uživatele: " new_user
        read -sp "Zadejte heslo nového uživatele: " new_password
        echo
        sudo mysql -e "CREATE USER '$new_user'@'localhost' IDENTIFIED BY '$new_password';"
        sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$new_user'@'localhost';"
        sudo mysql -e "FLUSH PRIVILEGES;"
        echo "Nový uživatel $new_user byl vytvořen."
    fi

    echo "Chcete nastavit heslo pro roota? (y/n)"
    read root_password_choice
    if [ "$root_password_choice" == "y" ]; then
        read -sp "Zadejte heslo pro roota: " root_password
        echo
        sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$root_password';"
        echo "Heslo pro roota bylo nastaveno."
    else
        root_password=$(openssl rand -base64 12)
        sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$root_password';"
        echo "Generované heslo pro roota: $root_password"
    fi

    sudo apt install -y phpmyadmin

    sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

    echo "Instalace PHPMyAdmin dokončena."
    echo "Přístupové údaje:"
    if [ "$create_user" == "y" ]; then
        echo "Nový uživatel: $new_user"
        echo "Heslo: $new_password"
    fi
    echo "Root uživatel: root"
    echo "Heslo: $root_password"
}

install_CasaOS() {
    curl -fsSL https://get.casaos.io | sudo bash
}

echo "Vyberte, co chcete nainstalovat:"
echo "1) Minecraft server"
echo "2) 7 Days to Die server"
echo "3) FiveM server"
echo "4) PHPMyAdmin"
echo "5) CasaOS"
read -p "Vaše volba: " choice

case $choice in
    1)
        install_minecraft
        ;;
    2)
        install_7d2d
        ;;
    3)
        install_FiveM
        ;;
    4)
        install_phpmyadmin
        ;;
    5)
        install_CasaOS
        ;;
    *)
        echo -e "\033[31mNeplatná volba!\033[0m"
        ;;
esac

echo -e "\033[32mInstalace dokončena!\033[0m"
