# === DEVGRU GreenBoot .bashrc ===
# Author: DEVGRU
# Description: Configuration file for customizing shell behavior and aliases.
# Last Updated: 2025-03-29

# History and prompt
HISTFILE=~/.bash_history
HISTSIZE=1000
HISTCONTROL=ignoredups:erasedups
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
PS1='\u@\h:\w\$ '

# Paths
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# === ALIASES ===

# System and terminal
alias ll='ls -la --color=auto'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'

# DevOps and CLI
alias tf='terraform'
alias ans='ansible-playbook'
alias pass='gopass'
alias g='git'
alias k='kubectl'

# Editors
alias e='micro'
alias v='nvim'

# File Manager
alias fm='nnn'
alias cheat='cd ~/cheatsheets && micro'

# Networking
alias ping6='ping -6'
alias trace='mtr --report'
alias ports='nmap -sS -T4'
alias ipinfo='curl ifconfig.me'
alias digdev='dig @1.1.1.1 +short'

# Tailscale
alias ts='tailscale'
alias tailscale-status='tailscale status'

# greenboot CLI
alias gb='~/bin/gb'