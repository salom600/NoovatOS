#!/usr/bin/env bash
# ============================================================
#  NovatOS — ISO build script (runs INSIDE the archlinux Docker container)
#  This file is mounted into the container and executed by the GitHub
#  Actions workflow. Keeping it as a separate file avoids ALL the
#  shell-quoting nightmares that come from nesting bash inside YAML
#  inside a single-quoted `bash -c '...'` argument.
# ============================================================
set -eu  # exit on error, undefined var; NO -x (cleaner logs)

echo "=== NovatOS ISO build starting ==="
echo "Build date: ${BUILD_DATE:-unknown}"
echo "Build tag:  ${BUILD_TAG:-unknown}"
echo "Working dir: $(pwd)"
echo "User: $(whoami)"
df -h / /work /out 2>/dev/null || true

# ---------------------------------------------------------------
# 1) Update the container
# ---------------------------------------------------------------
echo "=== Step 1: Update container ==="
pacman -Syu --noconfirm

# ---------------------------------------------------------------
# 2) Install archiso + build deps
# ---------------------------------------------------------------
echo "=== Step 2: Install build dependencies ==="
pacman -S --noconfirm --needed \
  archiso mkinitcpio squashfs-tools mtools dosfstools \
  grub efibootmgr edk2-ovmf edk2-shell \
  xorriso parted curl wget rsync git bash python jq \
  pacman-contrib reflector imagemagick \
  ttf-dejavu fontconfig

# ---------------------------------------------------------------
# 3) Init pacman keyring
# ---------------------------------------------------------------
echo "=== Step 3: Init pacman keyring ==="
pacman-key --init
pacman-key --populate archlinux

# ---------------------------------------------------------------
# 4) Add chaotic-aur key (non-fatal)
# ---------------------------------------------------------------
echo "=== Step 4: Add chaotic-aur key (non-fatal) ==="
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com 2>/dev/null \
  || pacman-key --recv-key 3056513887B78AEB --keyserver hkp://pool.sks-keyservers.net 2>/dev/null \
  || echo "WARN: Could not import chaotic-aur key — continuing without it"
pacman-key --lsign-key 3056513887B78AEB 2>/dev/null || true

# ---------------------------------------------------------------
# 5) Generate a RELIABLE mirrorlist
#    Using printf with NO inner single quotes (avoids shell-quoting bugs)
# ---------------------------------------------------------------
echo "=== Step 5: Generate mirrorlist ==="
mkdir -p /etc/pacman.d 2>/dev/null || true
chmod 755 /etc/pacman.d 2>/dev/null || true

# Write known-good mirrors using echo (no single quotes needed)
echo "Server = https://geo.mirror.pkgbuild.com/\$repo/os/\$arch"     >  /etc/pacman.d/mirrorlist 2>/dev/null || true
echo "Server = https://mirror.rackspace.com/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist 2>/dev/null || true
echo "Server = https://mirrors.kernel.org/archlinux/\$repo/os/\$arch"    >> /etc/pacman.d/mirrorlist 2>/dev/null || true
echo "Server = https://archive.archlinux.org/repos/last/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist 2>/dev/null || true

# Augment with reflector (non-fatal)
reflector --latest 20 --protocol https --sort rate \
  --download-timeout 30 --connection-timeout 30 \
  --save /tmp/reflector-mirrorlist 2>/dev/null \
  && cat /tmp/reflector-mirrorlist >> /etc/pacman.d/mirrorlist 2>/dev/null \
  || echo "WARN: reflector failed, using hardcoded mirrors only"

echo "--- Mirrorlist ---"
head -10 /etc/pacman.d/mirrorlist 2>/dev/null || echo "(mirrorlist not readable)"

# ---------------------------------------------------------------
# 6) Sync databases (MUST succeed)
# ---------------------------------------------------------------
echo "=== Step 6: Sync pacman databases ==="
pacman -Sy --noconfirm
echo "pacman -Sy completed successfully"

# Verify repos
echo "--- Repo database check ---"
for repo in core extra multilib chaotic-aur; do
  if pacman -Sl "$repo" >/dev/null 2>&1; then
    count=$(pacman -Sl "$repo" 2>/dev/null | wc -l)
    echo "  OK: $repo ($count packages)"
  else
    echo "  WARN: $repo not accessible"
  fi
done

# ---------------------------------------------------------------
# 7) Generate NovatOS wallpaper + Plymouth assets
#    (Non-fatal — fall back to solid colors if font/image fails)
# ---------------------------------------------------------------
echo "=== Step 7: Generate wallpaper + Plymouth assets ==="
mkdir -p airootfs/usr/share/wallpapers/novatos
mkdir -p airootfs/usr/share/plymouth/themes/novatos
mkdir -p airootfs/usr/share/calamares/branding/novatos
mkdir -p airootfs/usr/share/sddm/themes/novatos

# Refresh font cache
fc-cache -f >/dev/null 2>&1 || true

# Pick best available bold font
NOVATOS_FONT=$(fc-match -f "%{family}\n" :bold 2>/dev/null | head -1 || true)
if [ -z "$NOVATOS_FONT" ]; then
  NOVATOS_FONT="DejaVu-Sans-Bold"
fi
echo "Using font: $NOVATOS_FONT"

# Wallpaper (gradient with NovatOS wordmark, fallback to solid color)
if [ ! -f airootfs/usr/share/wallpapers/novatos/default.jpg ]; then
  convert -size 1920x1080 gradient:"#0067c0"-"#0a1f3c" \
    -font "$NOVATOS_FONT" -pointsize 96 -fill white -gravity north \
    -annotate +0+80 "NovatOS" \
    -pointsize 32 -fill "#4cc2ff" \
    -annotate +0+200 "The lightest, newest, most powerful Linux" \
    airootfs/usr/share/wallpapers/novatos/default.jpg 2>/dev/null \
    || convert -size 1920x1080 gradient:"#0067c0"-"#0a1f3c" \
         airootfs/usr/share/wallpapers/novatos/default.jpg 2>/dev/null \
    || echo "WARN: wallpaper generation failed"
fi

# Solid blue fallback wallpaper
if [ ! -f airootfs/usr/share/wallpapers/novatos/solid-blue.png ]; then
  convert -size 1920x1080 xc:"#0a1f3c" \
    airootfs/usr/share/wallpapers/novatos/solid-blue.png 2>/dev/null || true
fi

# Plymouth background
if [ ! -f airootfs/usr/share/plymouth/themes/novatos/background.png ]; then
  convert -size 1920x1080 xc:"#0a1f3c" \
    airootfs/usr/share/plymouth/themes/novatos/background.png 2>/dev/null || true
fi

# Plymouth logo (transparent with wordmark)
if [ ! -f airootfs/usr/share/plymouth/themes/novatos/logo.png ]; then
  convert -size 800x200 xc:none -font "$NOVATOS_FONT" -pointsize 96 \
    -fill white -gravity center -annotate +0+0 "NovatOS" \
    airootfs/usr/share/plymouth/themes/novatos/logo.png 2>/dev/null \
    || convert -size 800x200 xc:none \
         airootfs/usr/share/plymouth/themes/novatos/logo.png 2>/dev/null \
    || true
fi

# Plymouth spinner
if [ ! -f airootfs/usr/share/plymouth/themes/novatos/spinner.png ]; then
  convert -size 128x128 xc:none -stroke "#4cc2ff" -fill none -strokewidth 8 \
    -draw "arc 8,8 120,120 0,300" \
    airootfs/usr/share/plymouth/themes/novatos/spinner.png 2>/dev/null || true
fi

# Calamares branding logo
if [ ! -f airootfs/usr/share/calamares/branding/novatos/logo.png ]; then
  convert -size 256x256 xc:none -font "$NOVATOS_FONT" -pointsize 56 \
    -fill "#4cc2ff" -gravity center -annotate +0+0 "NovatOS" \
    airootfs/usr/share/calamares/branding/novatos/logo.png 2>/dev/null \
    || convert -size 256x256 xc:"#4cc2ff" \
         airootfs/usr/share/calamares/branding/novatos/logo.png 2>/dev/null \
    || true
fi

# SDDM background
if [ ! -f airootfs/usr/share/sddm/themes/novatos/background.jpg ]; then
  cp airootfs/usr/share/wallpapers/novatos/default.jpg \
     airootfs/usr/share/sddm/themes/novatos/background.jpg 2>/dev/null \
    || convert -size 1920x1080 xc:"#0a1f3c" \
         airootfs/usr/share/sddm/themes/novatos/background.jpg 2>/dev/null \
    || true
fi

# ---------------------------------------------------------------
# 8) Make scripts executable
# ---------------------------------------------------------------
echo "=== Step 8: Make scripts executable ==="
chmod 0755 airootfs/usr/local/bin/novatos-* 2>/dev/null || true
chmod 0755 airootfs/etc/novatos/scripts/* 2>/dev/null || true
chmod 0755 airootfs/root/customize_airootfs.sh 2>/dev/null || true
chmod 0755 profiledef.sh 2>/dev/null || true

# ---------------------------------------------------------------
# 9) Run mkarchiso — the actual ISO build
# ---------------------------------------------------------------
echo "=== Step 9: Build ISO with mkarchiso ==="
mkdir -p /work /out
mkarchiso -v -w /work -o /out .

# ---------------------------------------------------------------
# 10) Generate checksums + list output
# ---------------------------------------------------------------
echo "=== Step 10: Generate checksums ==="
cd /out
sha256sum *.iso > SHA256SUMS.txt 2>/dev/null || true
echo "--- Build output ---"
ls -la /out/
echo "--- SHA256SUMS ---"
cat SHA256SUMS.txt 2>/dev/null || true

echo "=== NovatOS ISO build COMPLETE ==="
