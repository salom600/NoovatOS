#!/usr/bin/env bash
# Live ISO automated script — runs at boot to set up the live environment.

# Source common functions
script_path="$(cd -P -- "$(dirname -- "$0")" >/dev/null 2>&1 && pwd -P)"

# Set up hostname
echo "novatos-live" > /etc/hostname

# Set up locale (en_US.UTF-8 default)
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

# Set timezone to UTC (user changes via Calamares)
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Enable services
systemctl enable NetworkManager bluetooth cups lightdm sddm apparmor 2>/dev/null || true

# Initialize pacman keys
pacman-key --init 2>/dev/null || true
pacman-key --populate archlinux 2>/dev/null || true

exit 0
