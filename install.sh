#!/bin/sh

set -e

THEMES="Papyrus"
DESTDIR="/usr/share/icons"

# Resolve the directory this script lives in
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

_sudo() {
    if [ -w "$DESTDIR" ] || [ -w "$(dirname "$DESTDIR")" ]; then
        "$@"
    else
        sudo "$@"
    fi
}

echo "=> Installing Papyrus icon themes to $DESTDIR ..."

_sudo mkdir -p "$DESTDIR"

for theme in $THEMES; do
    src="$SCRIPT_DIR/$theme"
    if [ ! -d "$src" ]; then
        echo "  Skipping '$theme' (not found in $SCRIPT_DIR)"
        continue
    fi
    echo "  Installing '$theme' ..."
    _sudo cp -rL "$src" "$DESTDIR/"
    _sudo gtk-update-icon-cache -q "$DESTDIR/$theme" || true
done

echo "=> Done!"
