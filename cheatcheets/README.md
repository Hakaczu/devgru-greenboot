# 📚 greenboot cheatsheets

Terminalowe skróty i podpowiedzi do narzędzi.

---

## 🗂️ nnn – terminalowy menedżer plików
p         – podgląd pliku  
m         – edytuj w micro  
b         – backup (np. plugin backup-frog)  
^R        – odśwież  
q         – wyjście  
g         – idź do katalogu  
?         – pomoc  

---

## ✍️ micro – lekki edytor terminalowy
Ctrl-e     – otwórz linię poleceń  
Ctrl-s     – zapisz  
Ctrl-q     – zamknij  
Ctrl-k u   – podgląd unicode  
Ctrl-k e   – eksplorator plików  
Ctrl-k f   – wyszukiwarka plików  
Ctrl-k t   – nowa karta  
Ctrl-k n/p – następna/poprzednia karta  

---

## 🧠 neovim – potężny edytor tekstu
:split file       – podział poziomy  
:vsplit file      – podział pionowy  
Ctrl-w + strzałka – przełącz panel  
:ls               – lista buforów  
:buffer 2         – przełącz bufor  
:q                – zamknij plik  
:w                – zapisz  
:wq               – zapisz i wyjdź  

---

## 🖥️ tmux – terminal multiplexer
Ctrl-b c   – nowe okno  
Ctrl-b ,   – zmień nazwę okna  
Ctrl-b n/p – następne/poprzednie okno  
Ctrl-b %   – podział pionowy  
Ctrl-b "   – podział poziomy  
Ctrl-b o   – przełącz między panelami  
Ctrl-b d   – odłącz sesję  

---

## 🌐 Narzędzia sieciowe

**DNS**  
dig devgru.com.pl  
drill devgru.com.pl  
nslookup devgru.com.pl  
dig @1.1.1.1 +short devgru.com.pl  

**HTTP/HTTPS**  
curl -I https://devgru.com.pl  
wget https://devgru.com.pl -O -  

**IPv6**  
ping6 devgru.com.pl  
curl -6 https://devgru.com.pl  

**Porty i skanowanie**  
nmap -sS devgru.com.pl  
nmap -6 -Pn devgru.com.pl  

**Trasy i połączenia**  
mtr devgru.com.pl  
tracepath devgru.com.pl  

---

## 🌍 opentofu
tofu init  
tofu plan  
tofu apply  
tofu destroy  
tofu fmt  
tofu validate  

---

## ⚙️ ansible
ansible all -m ping -i inventory.yml  
ansible-playbook playbook.yml -i inventory.yml  
ansible-vault encrypt secrets.yml  
ansible-vault edit secrets.yml  
ansible-inventory --list -i inventory.yml  

---

## 🔐 gopass – menedżer haseł z GPG
gopass init  
gopass insert path/secret  
gopass show path/secret  
gopass rm path/secret  
gopass git push/pull  
gopass search nazwapliku
