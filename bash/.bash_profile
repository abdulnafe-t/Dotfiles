#
# ~/.bash_profile
#

if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    fastfetch
    echo

    export PATH=${PATH}:${HOME}/.local/bin
    export EDITOR=${HOME}/.local/bin/a-t-editor
    export VISUAL=$EDITOR
    GPG_TTY=$(tty)
    export GPG_TTY

    GREEN=$(tput setaf 2)
    MAGENTA=$(tput setaf 5)
    CYAN=$(tput setaf 6)
    RESET=$(tput sgr0)
    BOLD=$(tput bold)

    echo "${RESET}Greetings, ${MAGENTA}${BOLD}$(whoami)${RESET}. Welcome to ${BOLD}${GREEN}${HOSTNAME}${RESET}.
Would you like to start ${CYAN}Hyprland${RESET}? [Y/n] "
    read -r ans
    case "$ans" in
        "" | ^[Yy]$) "$HOME/.local/bin/set-season-theme"
                     exec start-hyprland;;
        *) ;;
    esac
fi
