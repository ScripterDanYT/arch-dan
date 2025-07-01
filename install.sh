#!/bin/bash

echo "im gonna start, alr??"
for i in {3..1..-1}; do
  echo "$i".."..."
  sleep 1
done

if [[ $EUID -ne 0 ]]; then
  echo "not running as root. trying sudo..."
  exec sudo "$0" "$@"
fi
# get directory of the script
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/packages.txt"

# read packages
mapfile -t packages < "$PACKAGE_FILE"

to_install=()
for pkg in "${packages[@]}"; do
  pacman -Qi "$pkg" &>/dev/null || to_install+=("$pkg")
done

# install missing packages
if (( ${#to_install[@]} )); then
  sudo pacman -S --needed "${to_install[@]}"
else
  echo "all packages already installed."
fi

# check for sddm or lightdm
if pacman -Qi sddm &>/dev/null; then
  echo "enabling sddm..."
  sudo systemctl enable sddm
elif pacman -Qi lightdm &>/dev/null; then
  echo "enabling lightdm..."
  sudo systemctl enable lightdm
else
  echo "no display manager (sddm or lightdm) found."
fi

read -p "do you want to reboot now? [y/n]: " answer
case "$answer" in
  [Yy]* ) echo "rebooting..."; sudo reboot ;;
  * ) echo "reboot canceled." ;;
esac
