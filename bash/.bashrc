#
# ~/.bashrc
#

# If not running interactively, exit right away (and don't execute rest of script)
case $- in
    *i*) ;;
    *) return ;;
esac

export PATH=${PATH}:${HOME}/.local/bin
export EDITOR='emacsclient -c -a emacs'
export VISUAL='emacsclient -c -a emacs'

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

# Colorful man pages (from https://gist.github.com/bahamas10/542875bb47990933638d2b7dfaa501bf)
LESS_TERMCAP_mb=$(tput blink)
LESS_TERMCAP_md=$(tput bold; tput setaf 2)
LESS_TERMCAP_me=$(tput sgr0)
LESS_TERMCAP_se=$(tput sgr0)
LESS_TERMCAP_so=$(tput bold; tput setaf 0; tput setab 7)
LESS_TERMCAP_ue=$(tput sgr0)
LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 4)
LESS_TERMCAP_mr=$(tput rev)
LESS_TERMCAP_mh=$(tput dim)
LESS_TERMCAP_ZN=$(tput ssubm)
LESS_TERMCAP_ZV=$(tput rsubm)
LESS_TERMCAP_ZO=$(tput ssupm)
LESS_TERMCAP_ZW=$(tput rsupm)

export LESS_TERMCAP_mb \
       LESS_TERMCAP_md \
       LESS_TERMCAP_me \
       LESS_TERMCAP_se \
       LESS_TERMCAP_so \
       LESS_TERMCAP_ue \
       LESS_TERMCAP_us \
       LESS_TERMCAP_mr \
       LESS_TERMCAP_mh \
       LESS_TERMCAP_ZN \
       LESS_TERMCAP_ZV \
       LESS_TERMCAP_ZO \
       LESS_TERMCAP_ZW
export GROFF_NO_SGR=1
export MANPAGER='less'

eval "$(zoxide init bash)"
