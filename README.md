# 🐸 greenboot

**greenboot** to bootstrapper systemu FROG – lekkiego i zautomatyzowanego terminalowego noda operacyjnego.

Zaprojektowany z myślą o szybkości, czystości i pełnej gotowości DevOpsowej, greenboot instaluje wszystkie niezbędne narzędzia, konfiguruje środowisko i uruchamia agenta CLI `gb`.

---

## ✅ Co robi greenboot?

- Tworzy użytkownika z uprawnieniami sudo
- Kopiuje klucz SSH z aktualnego użytkownika
- Generuje klucze GPG i SSH
- Instaluje:
  - `neovim`, `micro`, `tmux`, `nnn`
  - `ansible`, `opentofu`, `gopass`, `tailscale`
  - narzędzia sieciowe (`nmap`, `tcpdump`, `drill`, `mtr`, itd.)
- Konfiguruje:
  - `.bashrc`, `.tmux.conf`, `nvim`, `micro`
  - aliasy, plugins, MOTD
- Tworzy lokalny vault gopass
- Ustawia cron, firewall, i przygotowuje katalogi

---

## 🚀 Szybki start

```bash
git clone https://github.com/hakaczu/devgru-greenboot
cd greenboot
sudo sh bootstrap.sh frog
```

---

## 📁 Struktura katalogów FROGa

```
/home/frog/
├── bin/           # Skrypty CLI, m.in. gb
├── projects/      # Twoje repozytoria i kod
├── config/        # Konfiguracje terminala
├── .config/       # Konfiguracje edytorów
├── logs/          # Logi skryptów i crona
├── tmp/           # Pliki tymczasowe
├── secrets/       # Tokeny, klucze GPG
├── backups/       # Lokalne backupy
├── cron/          # Skrypty do crona
├── infra/         # Ansible, OpenTofu, DNS
├── cheatsheets/   # Skróty do narzędzi
└── README_DEVGRU.txt
```

---

## 🛠️ greenboot CLI (`gb`)

Po instalacji masz dostępne:

- `gb init` – uruchom bootstrap ponownie
- `gb update` – aktualizuj pakiety
- `gb update-self [--override-config]` – aktualizuj CLI i konfig
- `gb backup` – backup katalogu domowego
- `gb restore` – przywróć z ostatniego backupu
- `gb doctor` – sprawdź środowisko
- `gb info` – informacje systemowe
- `gb ports` – pokaż porty FROGa
- `gb cheats` – ściągi terminalowe
- `gb help` – pomoc
