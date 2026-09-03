#!/bin/sh

set -e

THEMES="Papyrus"
DESTDIR="/usr/share/icons"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Usage: $0 [install|uninstall|update]"
    exit 1
}

_sudo() {
    if command -v sudo >/dev/null; then
        sudo "$@"
    elif command -v doas >/dev/null; then
        doas "$@"
    else
        echo "Failed to execute '$*'. Please run the script with root permissions." >&2
        exit 1
    fi
}

_sudo_rm() {
    if [ -w "$1" ]; then
        rm -rf "$1"
    else
        _sudo rm -rf "$1"
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

install_theme() {
    echo "=> Installing Papyrus icon themes to $DESTDIR ..."

    if [ -w "$DESTDIR" ] || [ -w "$(dirname "$DESTDIR")" ]; then
        mkdir -p "$DESTDIR"
    else
        _sudo mkdir -p "$DESTDIR"
    fi

    for theme in $THEMES; do
        src="$SCRIPT_DIR/$theme"
        if [ ! -d "$src" ]; then
            echo "  Skipping '$theme' (not found in $SCRIPT_DIR)"
            continue
        fi

        echo "  Copying '$theme' ..."
        if [ -w "$DESTDIR" ]; then
            cp -R "$src" "$DESTDIR"
        else
            _sudo cp -R "$src" "$DESTDIR"
        fi

        echo "  Updating icon cache for '$theme' ..."
        if [ -w "$DESTDIR" ]; then
            gtk-update-icon-cache -q "$DESTDIR/$theme" || true
        else
            _sudo gtk-update-icon-cache -q "$DESTDIR/$theme" || true
        fi
    done
    echo "=> Install complete!"
}

uninstall_theme() {
    echo "=> Removing Papyrus icon themes ..."

    for d in "$HOME/.icons" "$HOME/.local/share/icons" "/usr/local/share/icons" "/usr/share/icons"; do
        for theme in $THEMES; do
            [ -d "$d/$theme" ] || continue
            if _yes_no "Remove '$theme' from '$d'?"; then
                echo "  Removing '$d/$theme' ..."
                _sudo_rm "$d/$theme"
            fi
        done
    done
    echo "=> Uninstall complete!"
}

update_theme() {
    echo "=> Updating Papyrus icon themes ..."
    uninstall_theme
    install_theme
    echo "=> Update complete! You may need to restart your desktop environment to see all changes."
}

ACTION="${1:-install}"

case "$ACTION" in
    install)
        install_theme
        ;;
    uninstall)
        uninstall_theme
        ;;
    update)
        update_theme
        ;;
    *)
        usage
        ;;
esac
