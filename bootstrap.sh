#!/bin/sh

# -----------------------------------------------------------------------------
# DEVGRU Greenboot Bootstrap Script
# Author: DEVGRU
# Description: This script sets up a development environment on an Alpine Linux node.
# Last Updated: 2025-03-29
# -----------------------------------------------------------------------------

set -e

if [ -z "$1" ]; then
    echo "Użycie: ./bootstrap.sh <nazwa_użytkownika>"
    exit 1
fi

USERNAME="$1"
USER_HOME="/home/$USERNAME"

echo "==> Sprawdzanie, czy użytkownik $USERNAME istnieje..."
if id "$USERNAME" >/dev/null 2>&1; then
    echo "Użytkownik $USERNAME już istnieje, pomijanie dodawania."
else
    echo "==> Dodawanie użytkownika $USERNAME..."
    adduser -D "$USERNAME"
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

echo "==> Konfigurowanie SSH dla użytkownika $USERNAME..."
mkdir -p $USER_HOME/.ssh
cp ~/.ssh/authorized_keys $USER_HOME/.ssh/authorized_keys
chmod 700 $USER_HOME/.ssh
chmod 600 $USER_HOME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME $USER_HOME/.ssh

echo "==> Aktualizacja i instalacja pakietów..."
apk update && apk upgrade
apk add bash vim neovim micro tmux curl git openssh coreutils iptables sudo make gnupg gopass unzip py3-pip tailscale \
        rsync rclone wget drill bind-tools htop mtr nmap nmap-ncat tcpdump socat iperf3 fzf jq yq cronie

echo "==> Instalacja narzędzi CLI..."
pip install --break-system-packages ansible

echo "==> Instalacja OpenTofu..."
# Instalacja zależności wymaganych przez OpenTofu
apk add --no-cache curl unzip libc6-compat

# Pobieranie najnowszej wersji OpenTofu
TF_VERSION=$(curl -s https://opentofu.org/releases/ | grep -Eo 'opentofu/[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 | cut -d/ -f2)
DOWNLOAD_URL="https://opentofu.org/releases/${TF_VERSION}/opentofu_${TF_VERSION}_linux_amd64.zip"

# Sprawdzanie poprawności URL
if ! curl -Is "$DOWNLOAD_URL" | head -n 1 | grep -q "200"; then
    echo "\u274c Nie można pobrać OpenTofu. Sprawdź URL: $DOWNLOAD_URL"
    exit 1
fi

curl -Ls "$DOWNLOAD_URL" -o /tmp/opentofu.zip

# Sprawdzanie, czy plik ZIP został poprawnie pobrany
if [ ! -s /tmp/opentofu.zip ]; then
    echo "\u274c Pobieranie OpenTofu nie powiodło się. Plik ZIP jest pusty lub nie istnieje."
    exit 1
fi

# Rozpakowanie i instalacja binarki OpenTofu
unzip /tmp/opentofu.zip -d /usr/local/bin/ || {
    echo "\u274c Rozpakowanie OpenTofu nie powiodło się. Sprawdź plik ZIP."
    exit 1
}
chmod +x /usr/local/bin/opentofu

# Weryfikacja instalacji
if ! command -v opentofu >/dev/null 2>&1; then
    echo "\u274c Instalacja OpenTofu nie powiodła się."
    exit 1
else
    echo "\u2705 OpenTofu zainstalowane pomyślnie."
fi

echo "==> Tworzenie struktury katalogów w $USER_HOME..."
mkdir -p $USER_HOME/{bin,projects,config,logs,tmp,secrets,backups,cron,infra,cheatsheets}
mkdir -p $USER_HOME/.config/{micro,nvim,nnn,rclone}
mkdir -p $USER_HOME/.local/bin

echo "==> Tworzenie pliku README_DEVGRU.txt..."
cat <<EOF > $USER_HOME/README_DEVGRU.txt
🐸 FROG – DEVGRU Alpine Node – Struktura folderów:

~/bin/         – Twoje własne skrypty CLI
~/projects/    – Repozytoria kodu
~/config/      – Konfiguracje terminala (bashrc, tmux, edytory)
~/logs/        – Logi z crona i skryptów
~/tmp/         – Dane tymczasowe
~/secrets/     – Klucze, tokeny
~/backups/     – Backupy lokalne Froga
~/cron/        – Automatyczne zadania
~/infra/       – OpenTofu / Ansible / DNS
~/cheatsheets/ – Ściągi do narzędzi terminalowych
EOF

chown -R $USERNAME:$USERNAME $USER_HOME

echo "==> Kopiowanie cheatsheets (jeśli istnieją)..."
if [ -d ./cheatsheets ]; then
    cp -r ./cheatsheets/* $USER_HOME/cheatsheets/
    chown -R $USERNAME:$USERNAME $USER_HOME/cheatsheets
fi

echo "==> Kopiowanie konfiguracji..."
cp -r ./config/.bashrc $USER_HOME/
cp -r ./config/.vimrc $USER_HOME/
cp -r ./config/.tmux.conf $USER_HOME/
cp ./config/micro/settings.json $USER_HOME/.config/micro/
cp ./config/nvim/init.vim $USER_HOME/.config/nvim/

echo "==> Kopiowanie Greenboot CLI..."
cp ./bin/gb $USER_HOME/bin/gb
chmod +x $USER_HOME/bin/gb
chown $USERNAME:$USERNAME $USER_HOME/bin/gb

echo "==> Start usług Cron..."
rc-update add crond
rc-service crond start

echo "==> Konfigurowanie Tailscale..."
rc-update add tailscaled
rc-service tailscaled start

echo "==> Generowanie klucza SSH dla $USERNAME..."
sudo -u $USERNAME ssh-keygen -t ed25519 -C "$USERNAME@frog.devgru.local" -N "" -f $USER_HOME/.ssh/id_ed25519

echo "==> Generowanie klucza GPG dla $USERNAME..."
GPG_BATCH_FILE="/tmp/gpg_batch"
cat <<EOF > $GPG_BATCH_FILE
%no-protection
Key-Type: default
Key-Length: 2048
Subkey-Type: default
Name-Real: $USERNAME
Name-Email: $USERNAME@frog.devgru.local
Expire-Date: 0
%commit
EOF

sudo -u $USERNAME gpg --batch --generate-key $GPG_BATCH_FILE
rm $GPG_BATCH_FILE

GPG_FPR=$(sudo -u $USERNAME gpg --list-keys --with-colons | grep '^fpr' | head -n 1 | cut -d: -f10)
sudo -u $USERNAME gpg --armor --export $GPG_FPR > $USER_HOME/publickey.asc

echo "==> Konfigurowanie Gopass..."
sudo -u $USERNAME gopass init --storage=fs "$GPG_FPR"
sudo -u $USERNAME gopass insert -m cloudflare/api <<< "CLOUDFLARE_API_KEY=your-api-key-here"
sudo -u $USERNAME gopass insert -m mikrus1/ssh <<< "root@mikrus1\\npassword123"
sudo -u $USERNAME gopass insert -m devgru/gpg/public <<< "$(cat $USER_HOME/publickey.asc)"

echo "==> Ustawianie MOTD..."
if [ -f /etc/motd ]; then
    mv /etc/motd /etc/motd.bak
fi
if [ -f /etc/motd.tail ]; then
    mv /etc/motd.tail /etc/motd.tail.bak
fi
cat <<EOF > /etc/motd
🐸 Alpine Node DEVGRU
Hostname: $(hostname)
Data: $(date)
Uptime: $(uptime -p)
EOF

echo "==> Bootstrap zakończony pomyślnie!"