#!/usr/bin/env bash
# shellcheck disable=SC2034
# NovatOS — archiso profile definition (modern archiso format)
# Matches the official releng profile format (archiso >= 67).

iso_name="NovatOS"
iso_label="NOVATOS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="NovatOS Project <https://github.com/salom600/NoovatOS>"
iso_application="NovatOS Linux — lightweight Wayland distribution for Windows migrants"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="novatos"
buildmodes=('iso')
# Hybrid ISO: BIOS (syslinux) + UEFI (systemd-boot)
# These are the modern archiso boot mode names (no .mbr/.eltorito suffix).
bootmodes=('bios.syslinux' 'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '-19')
declare -A file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/root"]="0:0:700"
  ["/etc/sudoers.d"]="0:0:750"
  ["/etc/sudoers.d/g_wheel"]="0:0:440"
  ["/etc/sudoers.d/novatos"]="0:0:440"
  ["/usr/local/bin/novatos-first-boot"]="0:0:755"
  ["/usr/local/bin/novatos-setup-drivers"]="0:0:755"
  ["/usr/local/bin/novatos-setup-desktop"]="0:0:755"
  ["/usr/local/bin/novatos-setup-store"]="0:0:755"
  ["/usr/local/bin/novatos-windows-compat"]="0:0:755"
  ["/usr/local/bin/novatos-welcome"]="0:0:755"
  ["/usr/local/bin/novatos-apply-theme"]="0:0:755"
  ["/usr/local/bin/novatos-migrate-from-windows"]="0:0:755"
  ["/usr/local/bin/novatos-launcher"]="0:0:755"
  ["/usr/local/bin/novatos-power-menu"]="0:0:755"
  ["/usr/local/bin/novatos-screenshot"]="0:0:755"
  ["/usr/local/bin/novatos-setup-gaming"]="0:0:755"
  ["/etc/novatos/"]="0:0:755"
  ["/etc/novatos/scripts/"]="0:0:755"
  ["/etc/novatos/scripts/detect-gpu"]="0:0:755"
  ["/etc/novatos/scripts/install-gaming"]="0:0:755"
  ["/etc/novatos/scripts/setup-flatpak-remotes"]="0:0:755"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.zlogin"]="0:0:755"
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/etc/polkit-1/rules.d"]="0:0:750"
  ["/etc/polkit-1/rules.d/49-novatos.rules"]="0:0:644"
)
