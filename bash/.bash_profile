#
# ~/.bash_profile
#

if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    fastfetch
    echo

    export PATH=${PATH}:${HOME}/.local/bin
    export EDITOR='emacsclient -c -a emacs'
    export VISUAL='emacsclient -c -a emacs'
    GPG_TTY=$(tty)
    export GPG_TTY

    GREEN=$(tput setaf 2)
    MAGENTA=$(tput setaf 5)
    YELLOW=$(tput setaf 11)
    RESET=$(tput sgr0)
    BOLD=$(tput bold)

    echo "${RESET}Greetings, ${MAGENTA}${BOLD}$(whoami)${RESET}. Welcome to ${BOLD}${GREEN}${HOSTNAME}${RESET}.
Would you like to start ${YELLOW}Hyprland${RESET}? [Y/n] "
    read -r ans
    case "$ans" in
        "" | ^[Yy]$) "$HOME/.local/bin/set-season-theme"
                     exec start-hyprland;;
        *) ;;
    esac
fi
