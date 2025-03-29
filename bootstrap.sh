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

# Dodanie użytkownika z roota
if id "$USERNAME" >/dev/null 2>&1; then
    echo "Użytkownik $USERNAME już istnieje, pomijanie dodawania."
else
    adduser -D "$USERNAME"
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

# SSH
mkdir -p $USER_HOME/.ssh
cp ~/.ssh/authorized_keys $USER_HOME/.ssh/authorized_keys
chmod 700 $USER_HOME/.ssh
chmod 600 $USER_HOME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME $USER_HOME/.ssh

# Pakiety
apk update && apk upgrade
apk add bash vim neovim micro tmux curl git openssh coreutils iptables sudo make gnupg go unzip py3-pip tailscale \
        rsync rclone wget drill bind-tools htop dstat mtr nmap nmap-ncat tcpdump socat iperf3 fzf jq yq cronie

# CLI tools
pip install --break-system-packages ansible
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
su - $USERNAME -c "go install github.com/gopasspw/gopass@latest"

# Terraform
TF_VERSION=$(curl -s https://releases.hashicorp.com/terraform/ | grep -Eo 'terraform/[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 | cut -d/ -f2)
curl -Ls "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip
unzip /tmp/terraform.zip -d /usr/local/bin/
chmod +x /usr/local/bin/terraform

# Struktura katalogów
mkdir -p $USER_HOME/{bin,projects,config,logs,tmp,secrets,backups,cron,infra,cheatsheets}
mkdir -p $USER_HOME/.config/{micro,nvim,nnn,rclone}
mkdir -p $USER_HOME/.local/bin

# README
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
~/infra/       – Terraform / Ansible / DNS
~/cheatsheets/ – Ściągi do narzędzi terminalowych
EOF

chown -R $USERNAME:$USERNAME $USER_HOME

# Kopiowanie cheatsheets
if [ -d ./cheatsheets ]; then
    cp -r ./cheatsheets/* $USER_HOME/cheatsheets/
    chown -R $USERNAME:$USERNAME $USER_HOME/cheatsheets
fi

# Konfiguracje
cp -r ./config/.bashrc $USER_HOME/
cp -r ./config/.vimrc $USER_HOME/
cp -r ./config/.tmux.conf $USER_HOME/
cp ./config/micro/settings.json $USER_HOME/.config/micro/
cp ./config/nvim/init.vim $USER_HOME/.config/nvim/

# CLI
cp ./bin/gb $USER_HOME/bin/gb
chmod +x $USER_HOME/bin/gb
chown $USERNAME:$USERNAME $USER_HOME/bin/gb

# Cron
rc-update add crond
rc-service crond start

# SSH security
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
rc-service sshd restart

# Tailscale
rc-update add tailscaled
rc-service tailscaled start

# Klucze SSH
echo "==> Generowanie klucza SSH dla $USERNAME..."
sudo -u $USERNAME ssh-keygen -t ed25519 -C "$USERNAME@frog.devgru.local" -N "" -f $USER_HOME/.ssh/id_ed25519

# GPG
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

# Gopass
sudo -u $USERNAME gopass init --storage=fs "$GPG_FPR"
sudo -u $USERNAME gopass insert -m cloudflare/api <<< "CLOUDFLARE_API_KEY=your-api-key-here"
sudo -u $USERNAME gopass insert -m mikrus1/ssh <<< "root@mikrus1\\npassword123"
sudo -u $USERNAME gopass insert -m devgru/gpg/public <<< "$(cat $USER_HOME/publickey.asc)"

# Ustawienia MOTD
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