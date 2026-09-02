#!/bin/sh

set -e

THEMES="Papyrus Papyrus-Dark"

_sudo() {
    if [ -w "$1" ]; then
        rm -rf "$1"
    else
        if command -v sudo >/dev/null; then
            sudo rm -rf "$1"
        elif command -v doas >/dev/null; then
            doas rm -rf "$1"
        else
            echo "Failed to remove '$1'. Please run the script with root permission." >&2
        fi
    fi
}

_yes_no() {
    printf '%s [Y/n]: ' "$*"
    read -r yes_no </dev/tty

    case "$yes_no" in
        [Yy]|'') return 0 ;;
        [Nn]|*)  return 1 ;;
    esac
}

echo "=> Removing Papyrus icon themes ..."

for d in "$HOME/.icons" "$HOME/.local/share/icons" "/usr/local/share/icons" "/usr/share/icons"; do
    for theme in $THEMES; do
        [ -d "$d/$theme" ] || continue
        if _yes_no "Remove '$theme' from '$d'?"; then
            echo "  Removing '$d/$theme' ..."
            _sudo "$d/$theme"
        fi
    done
done

echo "=> Done!"
