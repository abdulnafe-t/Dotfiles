#
# ~/.bashrc
#

# If not running interactively, exit right away (and don't execute rest of script)
case $- in
    *i*) ;;
    *) return ;;
esac

case ":${PATH}:" in
    *":${HOME}/.local/bin:"*) ;;
    *) export PATH="${PATH}:${HOME}/.local/bin" ;;
esac

export EDITOR="emacsclient --alternate-editor= -c -nw"
export VISUAL=$EDITOR

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Reclaim C-s for I-search in bash (as opposed to the default XON, consumed by the tty)
stty -ixon

if [ -t 0 ]; then
    GREEN="\[$(tput setaf 2)\]"
    MAGENTA="\[$(tput setaf 5)\]"
    CYAN="\[$(tput setaf 4)\]"
    RESET="\[$(tput sgr0)\]"
    BOLD="\[$(tput bold)\]"

    PS1="${BOLD}${MAGENTA}\u${RESET}@${GREEN}\h${RESET}:${CYAN}\w${RESET}\$ "
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

    GPG_TTY=$(tty)
    export GPG_TTY
fi

export GROFF_NO_SGR=1
export MANPAGER='less'

eval "$(zoxide init bash)"
eval "$(thefuck --alias)"

osc7_cwd() {
    local strlen=${#PWD}
    local encoded=""
    local pos c o
    for (( pos=0; pos<strlen; pos++ )); do
        c=${PWD:$pos:1}
        case "$c" in
            [-/:_.!\'\(\)~[:alnum:]] ) o="${c}" ;;
            * ) printf -v o '%%%02X' "'${c}" ;;
        esac
        encoded+="${o}"
    done
    printf '\e]7;file://%s%s\e\\' "${HOSTNAME}" "${encoded}"
}
PROMPT_COMMAND=${PROMPT_COMMAND:+${PROMPT_COMMAND%;}; }osc7_cwd
