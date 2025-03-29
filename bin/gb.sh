#!/bin/sh
VERSION="1.0.0"

# greenboot CLI – alias: gb
# Ułatwia zarządzanie FROGiem z terminala
# Autor: DEVGRU
# Repozytorium: https://github.com/hakaczu/devgru-greenboot

case "$1" in
    init)
        echo "Inicjalizacja środowiska FROGa..."
        sh ./bootstrap.sh frog
        ;;
    backup)
        echo "📦 Tworzę backup katalogu domowego..."
        tar -czf ~/backups/frog_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C ~ .
        ;;
    update)
        echo "🔄 Aktualizacja pakietów systemowych..."
        sudo apk update && sudo apk upgrade
        ;;
    update-self)
        echo "⬇️  Aktualizuję greenboot CLI (gb)..."
        curl -sSL https://raw.githubusercontent.com/hakaczu/devgru-greenboot/main/bin/gb.sh -o ~/bin/gb
        chmod +x ~/bin/gb
        echo "✅ gb zaktualizowany do najnowszej wersji."

        if [ "$2" = "--override-config" ]; then
            echo "♻️  Nadpisuję pliki konfiguracyjne użytkownika..."
            cp -r ./config/.bashrc ~/.bashrc
            cp -r ./config/.vimrc ~/.vimrc
            cp -r ./config/.tmux.conf ~/.tmux.conf
            mkdir -p ~/.config/micro ~/.config/nvim
            cp ./config/micro/settings.json ~/.config/micro/
            cp ./config/nvim/init.vim ~/.config/nvim/
            echo "✅ Konfiguracja zaktualizowana."
        fi
        ;;
    logs)
        echo "📋 Ostatnie logi systemowe:"
        tail -n 50 /var/log/syslog
        ;;
    cheats)
        echo "📚 Dostępne ściągi:"
        ls ~/cheatsheets/
        ;;
    version)
        echo "greenboot CLI version $VERSION"
        ;;
    help|*)
        echo "🐸 greenboot CLI – zarządzanie FROGiem"
        echo "Użycie:"
        echo "  gb init             – uruchom bootstrap"
        echo "  gb backup           – zrób backup systemu"
        echo "  gb update           – aktualizuj system"
        echo "  gb update-self [--override-config] – zaktualizuj CLI i opcjonalnie konfigurację"
        echo "  gb logs             – pokaż logi"
        echo "  gb cheats           – pokaż dostępne ściągi"
        echo "  gb help             – to co widzisz teraz"
        ;;
esac