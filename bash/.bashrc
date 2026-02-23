#
# ~/.bashrc
#

# If not running interactively, exit right away (and don't execute rest of script)
case $- in
    *i*) ;;
    *) return ;;
esac


alias ls='ls --color=auto'
alias grep='grep --color=auto'

GREEN="\[$(tput setaf 2)\]"
MAGENTA="\[$(tput setaf 5)\]"
CYAN="\[$(tput setaf 4)\]"
WHITE="\[$(tput setaf 7)\]"
RESET="\[$(tput sgr0)\]"
BOLD="\[$(tput bold)\]"

PS1="${BOLD}${MAGENTA}\u${WHITE}@${GREEN}\h${WHITE}:${CYAN}\w${RESET}\$ "
PS2='$ '

eval "$(zoxide init bash)"
eval "$(fzf --bash)"
