#!/usr/bin/env bash

set -e

echo "Uninstalling existing Papyrus icon theme..."
./uninstall.sh

echo "Installing new Papyrus icon theme..."
./install.sh

echo "Update complete! You may need to reset your icon cache or restart your desktop environment to see all changes."
