# === DEVGRU GreenBoot .bashrc ===
# Author: DEVGRU
# Description: Configuration file for customizing shell behavior and aliases.
# Last Updated: 2025-03-29

# Historia
HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoredups:erasedups
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Kolorowanie ls i grep
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# === Git branch w promptcie ===
parse_git_branch() {
  git branch 2>/dev/null | grep '\*' | sed 's/* //'
}

# === Kolory ===
RESET='\[\033[0m\]'
RED='\[\033[0;31m\]'
GREEN='\[\033[0;32m\]'
BLUE='\[\033[0;34m\]'
CYAN='\[\033[0;36m\]'
YELLOW='\[\033[1;33m\]'
GRAY='\[\033[1;30m\]'

# === Prompt ===
# Format: [HH:MM] user@host:~/path (branch) $
PS1="${GRAY}[\A]${RESET} ${CYAN}\u${RESET}:${BLUE}\w${RESET} \$(parse_git_branch && echo \"(${YELLOW}\$(parse_git_branch)${RESET})\")\$ "

# PATH
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# === Aliasy ===
alias ll='ls -la'
alias la='ls -A'
alias cls='clear'
alias reload='source ~/.bashrc'

# Edytory
alias e='micro'
alias v='nvim'

# DevOps tools
alias tf='tofu'
alias ans='ansible-playbook'
alias pass='gopass'
alias g='git'
alias ts='tailscale'

# greenboot
alias gb='~/bin/gb'
alias cheat='cd ~/cheatsheets && micro'

# Sieciowe
alias ipinfo='curl ifconfig.me'
alias ping6='ping -6'
alias digdev='dig @1.1.1.1 +short'
alias trace='mtr --report'
