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
    doctor)
        echo "🧪 Diagnostyka środowiska FROGa:"
        echo "➡️  Sprawdzam dostępność narzędzi..."

        for bin in terraform gopass ansible-playbook ssh nvim micro tmux nnn gb; do
            if command -v $bin >/dev/null 2>&1; then
                echo "✅ $bin OK"
            else
                echo "❌ $bin NIE ZNALEZIONY"
            fi
        done

        echo "➡️  Sprawdzam status Tailscale..."
        tailscale status 2>/dev/null || echo "⚠️  tailscale nie działa"

        echo "➡️  Sprawdzam konfigurację gopass..."
        gopass status 2>/dev/null || echo "⚠️  brak stanu gopass"

        echo "🧠 Diagnostyka zakończona."
        ;;
    restore)
        echo "♻️  Przywracanie backupu FROGa..."
        LATEST_BACKUP=$(ls -t ~/backups/frog_backup_*.tar.gz 2>/dev/null | head -n 1)

        if [ -z \"$LATEST_BACKUP\" ]; then
            echo \"❌ Brak pliku backupu w ~/backups/\"
        else
            echo \"📦 Przywracam z $LATEST_BACKUP...\"
            tar -xzf \"$LATEST_BACKUP\" -C ~
            echo \"✅ Przywrócono dane z backupu.\"
        fi
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
        echo "  gb doctor           – sprawdź stan środowiska"
        echo "  gb restore          – przywróć ostatni backup"
        echo "  gb help             – to co widzisz teraz"
        ;;
esac