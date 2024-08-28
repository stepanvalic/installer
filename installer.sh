#!/bin/bash

# Funkce pro instalaci prvotních balíčků
install_packages() {
    echo "Instalace prvotních balíčků..."
    # Sem můžete vložit příkazy pro instalaci balíčků
    sudo apt update
    sudo apt install -y curl wget git tmux htop
    clear
    echo "Prvotní balíčky byly úspěšně nainstalovány."
}

# Funkce pro instalaci hry 7 Days to Die
install_7d2d() {
    echo "Instalace 7 Days to Die..."
    # Sem můžete vložit příkazy pro instalaci hry 7d2d
    echo "7 Days to Die bylo úspěšně nainstalováno."
}

# Funkce pro instalaci Minecraftu
install_minecraft() {
    echo "Instalace Minecraftu..."
    # Sem můžete vložit příkazy pro instalaci Minecraftu
    echo "Minecraft byl úspěšně nainstalován."
}

# Hlavní menu
while true; do
    echo "Vyberte možnost:"
    echo "1) Instalovat prvotní balíčky"
    echo "2) Instalátor her"
    echo "3) Ukončit"

    read -p "Zadejte číslo možnosti: " choice

    case $choice in
        1)
            install_packages
            ;;
        2)
            echo "Vyberte hru k instalaci:"
            echo "1) 7 Days to Die"
            echo "2) Minecraft"
            read -p "Zadejte číslo hry: " game_choice
            case $game_choice in
                1)
                    install_7d2d
                    ;;
                2)
                    install_minecraft
                    ;;
                *)
                    echo "Neplatná volba. Zkuste to znovu."
                    ;;
            esac
            ;;
        3)
            echo "Ukončuji skript."
            exit 0
            ;;
        *)
            echo "Neplatná volba. Zkuste to znovu."
            ;;
    esac
done
