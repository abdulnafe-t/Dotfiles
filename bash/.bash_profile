#
# ~/.bash_profile
#

if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    fastfetch
    echo

    GREEN=$(tput setaf 2)
    MAGENTA=$(tput setaf 5)
    CYAN=$(tput setaf 6)
    RESET=$(tput sgr0)
    BOLD=$(tput bold)

    echo "${RESET}Greetings, ${MAGENTA}${BOLD}$(whoami)${RESET}. Welcome to ${BOLD}${GREEN}${HOSTNAME}${RESET}.
Would you like to start ${CYAN}Hyprland${RESET}? [Y/n] "

    if [ -f "$HOME/.bashrc" ]; then
        source "$HOME/.bashrc"
    fi

    read -r ans
    case "$ans" in
        "" | [Yy]) "$HOME/.local/bin/set-season-theme"
                   exec start-hyprland;;
        *) ;;
    esac
fi

