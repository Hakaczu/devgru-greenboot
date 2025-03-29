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
    info)
        echo "🧾 Informacje o środowisku FROGa"
        echo "Hostname: $(hostname)"
        echo "Data:     $(date)"
        echo "Uptime:   $(uptime -p)"
        echo "User:     $(whoami)"
        echo "Shell:    $SHELL"
        echo "Kernel:   $(uname -srmo)"
        echo "IPv4:     $(hostname -I | awk '{print $1}')"
        echo "IPv6:     $(ip -6 addr show | grep inet6 | awk '{print $2}' | head -n 1)"
        echo "Tailscale: $(tailscale ip -4 2>/dev/null | head -n 1)"
        echo "greenboot CLI: v$VERSION"
        ;;
    ports)
        echo "🌐 Dostępne zewnętrzne porty FROGa:"
        HOSTNAME=$(hostname)
        SUFFIX=$(echo "$HOSTNAME" | grep -o '[0-9]*$')

        echo "Domena: $HOSTNAME"
        echo "Identyfikator: $SUFFIX"
        echo
        echo "➡️  Porty dostępne (TCP/UDP):"
        echo " - $HOSTNAME:20678 → 192.168.6.178:20678 (slot 2)"
        echo " - $HOSTNAME:30678 → 192.168.6.178:30678 (slot 3)"
        echo " - $HOSTNAME:40678 → 192.168.6.178:40678 (slot 4)"
        echo
        echo "🧪 Status nasłuchu lokalnie:"
        for PORT in 20678 30678 40678; do
            if ss -tuln | grep -q ":$PORT"; then
                echo "✅ Port $PORT aktywny (nasłuchuje)"
            else
                echo "❌ Port $PORT nieaktywny"
            fi
        done
        echo
        echo "🧬 Adres IPv6:"
        ip -6 addr show | grep inet6 | awk '{print $2}' | grep -v '::1' | head -n 1
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
        echo "  gb info            – wyświetl informacje o systemie"
        echo "  gb help             – to co widzisz teraz"
        ;;
esac