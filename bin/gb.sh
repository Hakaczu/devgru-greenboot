#!/bin/sh
VERSION="1.0.2"

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
            curl -sSL https://raw.githubusercontent.com/hakaczu/devgru-greenboot/main/config/.bashrc -o ~/.bashrc
            curl -sSL https://raw.githubusercontent.com/hakaczu/devgru-greenboot/main/config/.vimrc -o ~/.vimrc
            curl -sSL https://raw.githubusercontent.com/hakaczu/devgru-greenboot/main/config/.tmux.conf -o ~/.tmux.conf
            curl -sSL https://raw.githubusercontent.com/hakaczu/devgru-greenboot/main/config/micro/settings.json -o ~/.config/micro/settings.json
            curl -sSL https://raw.githubusercontent.com/hakaczu/devgru-greenboot/main/config/nvim/init.vim -o ~/.config/nvim/init.vim
            echo "✅ Konfiguracja zaktualizowana."
        fi
        ;;
    logs)
        echo "📋 Ostatnie logi systemowe:"
        tail -n 50 /var/log/syslog
        ;;
    cheats)
        echo "📚 greenboot cheatsheets"
        echo "──────────────────────────"
        if [ -f ~/cheatsheets/README.md ]; then
            cat ~/cheatsheets/README.md | less
        else
            echo "Brak pliku ~/cheatsheets/README.md"
        fi
        ;;
    version)
        echo "greenboot CLI version $VERSION"
        ;;
    doctor)
        echo "🧪 Diagnostyka środowiska FROGa:"
        echo "➡️  Sprawdzam dostępność narzędzi..."

        for bin in tofu gopass ansible-playbook ssh nvim micro tmux nnn gb; do
            if command -v $bin >/dev/null 2>&1; then
                echo "✅ $bin OK"
            else
                echo "❌ $bin NIE ZNALEZIONY"
            fi
        done

        echo "➡️  Sprawdzam status Tailscale..."
        tailscale status 2>/dev/null || echo "⚠️  tailscale nie działa"

        echo "➡️  Sprawdzam strukturę katalogów..."
        for dir in ~/bin ~/projects ~/config ~/logs ~/tmp ~/secrets ~/backups ~/cron ~/infra ~/cheatsheets; do
            if [ -d "$dir" ]; then
                echo "✅ $dir istnieje"
            else
                echo "❌ Brakuje katalogu: $dir"
            fi
        done

        echo "➡️  Sprawdzam obecność backupów..."
        LATEST_BACKUP=$(ls -t ~/backups/frog_backup_*.tar.gz 2>/dev/null | head -n 1)
        if [ -z "$LATEST_BACKUP" ]; then
            echo "⚠️  Brak backupów w ~/backups/"
        else
            echo "✅ Ostatni backup: $(date -r "$LATEST_BACKUP" "+%Y-%m-%d %H:%M")"
        fi

        echo "➡️  Sprawdzam konfigurację gopass..."
        gopass status 2>/dev/null || echo "⚠️  brak stanu gopass"

        echo "🧠 Diagnostyka zakończona."
        ;;
    restore)
        echo "♻️  Przywracanie backupu FROGa..."
        LATEST_BACKUP=$(ls -t ~/backups/frog_backup_*.tar.gz 2>/dev/null | head -n 1)

        if [ -z "$LATEST_BACKUP" ]; then
            echo "❌ Brak pliku backupu w ~/backups/"
        else
            echo "📦 Przywracam z $LATEST_BACKUP..."
            tar -xzf "$LATEST_BACKUP" -C ~
            echo "✅ Przywrócono dane z backupu."
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
        echo "IPv4:     $(ip -4 addr show | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n 1)"
        echo "IPv6:     $(ip -6 addr show | grep inet6 | awk '{print $2}' | grep -v '::1' | head -n 1)"

        LAST_LOGIN=$(last -n 1 $(whoami) | awk '{print $4, $5, $6, $7}')
        LAST_BACKUP=$(ls -t ~/backups/frog_backup_*.tar.gz 2>/dev/null | head -n 1 | xargs -I{} date -r {} "+%Y-%m-%d %H:%M")

        echo "Last login: ${LAST_LOGIN:-Brak danych}"
        echo "Last backup: ${LAST_BACKUP:-Brak backupu}"

        echo "greenboot CLI: v$VERSION"
        ;;
    ports)
        echo "🌐 Dostępne zewnętrzne porty FROGa:"
        HOSTNAME=$(hostname)
        IP=$(getent hosts "$HOSTNAME" | awk '{ print $1 }')
        SUFFIX=$(echo "$HOSTNAME" | grep -o '[0-9]*$')

        echo "Domena: $HOSTNAME"
        echo "Identyfikator: $SUFFIX"
        echo
        echo "➡️  Porty dostępne (TCP/UDP):"
        for PREFIX in 20 30 40; do
            PORT="${PREFIX}${SUFFIX}"
            SLOT=$((PREFIX / 10))
            echo " - $HOSTNAME:$PORT → $IP:$PORT (slot $SLOT)"
        done
        echo
        echo "🧪 Status nasłuchu lokalnie:"
        for PREFIX in 20 30 40; do
            PORT="${PREFIX}${SUFFIX}"
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