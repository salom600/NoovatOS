#!/usr/bin/env bash
# shellcheck disable=SC2034
# NovatOS — archiso profile definition

iso_name="NovatOS"
iso_label="NOVATOS_$(date +%Y%m)"
iso_publisher="NovatOS Project <https://github.com/salom600/NoovatOS>"
iso_application="NovatOS Linux — lightweight Wayland distribution for Windows migrants"
iso_version="$(date +%Y.%m.%d)"
iso_install_dir="novatos"
iso_bootloader="grub"
# Hybrid ISO: BIOS (syslinux+grub) + UEFI (grub) + bootable from USB via Ventoy/Rufus/dd
iso_bootmodes="bios.syslinux.mbr bios.syslinux.eltorito uefi-x64.grub.esp uefi-x64.grub.eltorito"
# Also export as 'bootmodes' (some mkarchiso versions read this directly)
bootmodes="$iso_bootmodes"
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '-19')

declare -A file_permissions=(
  ["/etc/shadow"]="0400"
  ["/etc/gshadow"]="0400"
  ["/root"]="0700"
  ["/etc/sudoers.d"]="0750"
  ["/etc/sudoers.d/g_wheel"]="0440"
  ["/usr/local/bin/novatos-first-boot"]="0755"
  ["/usr/local/bin/novatos-setup-drivers"]="0755"
  ["/usr/local/bin/novatos-setup-desktop"]="0755"
  ["/usr/local/bin/novatos-setup-store"]="0755"
  ["/usr/local/bin/novatos-windows-compat"]="0755"
  ["/usr/local/bin/novatos-welcome"]="0755"
  ["/usr/local/bin/novatos-apply-theme"]="0755"
  ["/usr/local/bin/novatos-migrate-from-windows"]="0755"
  ["/usr/local/bin/novatos-launcher"]="0755"
  ["/usr/local/bin/novatos-power-menu"]="0755"
  ["/usr/local/bin/novatos-screenshot"]="0755"
  ["/etc/novatos/"]="0755"
  ["/etc/novatos/scripts/"]="0755"
  ["/root/.automated_script.sh"]="0755"
  ["/root/.zlogin"]="0755"
  ["/etc/polkit-1/rules.d"]="0750"
  ["/etc/polkit-1/rules.d/49-novatos.rules"]="0644"
  ["/etc/novatos/scripts/detect-gpu"]="0755"
  ["/etc/novatos/scripts/install-gaming"]="0755"
  ["/etc/novatos/scripts/setup-flatpak-remotes"]="0755"
)
