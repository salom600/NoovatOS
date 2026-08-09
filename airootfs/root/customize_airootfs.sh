#!/usr/bin/env bash
# ============================================================
#  NovatOS — customize_airootfs.sh
#  Called by archiso after packages are installed into airootfs.
#  Sets up: live user, groups, services, Plymouth theme, etc.
# ============================================================
set -e

echo "==> [NovatOS] Running customize_airootfs.sh"

# --- Locale ---
sed -i 's/^#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# --- Hostname ---
echo "novatos-live" > /etc/hostname
cat > /etc/hosts <<'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   novatos-live.localdomain novatos-live
EOF

# --- Live user 'novatos' ---
# (no password, autologin, in wheel + audio + video + etc.)
if ! id -u novatos >/dev/null 2>&1; then
    useradd -m -G wheel,audio,video,network,storage,optical,power,lp,scanner,games,input,render,kvm,libvirt,docker,wireshark,uucp -s /bin/zsh novatos
    # Lock password (can't login via password) but allow passwordless sudo via PAM override below
    passwd -d novatos
fi

# Allow passwordless sudo for the novatos user (live ISO convenience)
cat > /etc/sudoers.d/novatos <<'EOF'
novatos ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/novatos

# Also allow passwordless for wheel group
cat > /etc/sudoers.d/g_wheel <<'EOF'
%wheel ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/g_wheel

# --- Root password (disabled, no password) ---
passwd -d root

# --- Groups for the live user ---
for g in wheel audio video network storage optical power lp scanner games input render kvm libvirt docker wireshark uucp; do
    getent group "$g" >/dev/null 2>&1 || groupadd "$g" 2>/dev/null || true
    gpasswd -a novatos "$g" >/dev/null 2>&1 || true
done

# --- Set up skel for the user ---
if [ -d /etc/skel ]; then
    cp -aT /etc/skel /home/novatos
    chown -R novatos:novatos /home/novatos
fi

# --- Machine info ---
cat > /etc/machine-info <<'EOF'
PRETTY_HOSTNAME=NovatOS
ICON_NAME=computer
CHASSIS=laptop
DEPLOYMENT=live
EOF

# --- OS release info (so it shows up as "NovatOS" in neofetch, etc.) ---
cat > /etc/os-release <<'EOF'
NAME="NovatOS"
ID=novatos
ID_LIKE=arch
VERSION_ID=2026.08
PRETTY_NAME="NovatOS 2026.08 (Wayland Edition)"
ANSI_COLOR="0;34"
HOME_URL="https://github.com/salom600/NoovatOS"
DOCUMENTATION_URL="https://github.com/salom600/NoovatOS/wiki"
SUPPORT_URL="https://github.com/salom600/NoovatOS/issues"
BUG_REPORT_URL="https://github.com/salom600/NoovatOS/issues"
LOGO=novatos
EOF

# --- Plymouth theme ---
if command -v plymouth-set-default-theme >/dev/null 2>&1; then
    plymouth-set-default-theme -R spinner 2>/dev/null || true
fi

# Rebuild initramfs (in case mkinitcpio.conf was changed)
mkinitcpio -P 2>/dev/null || true

# --- Enable services for live environment ---
systemctl enable NetworkManager 2>/dev/null || true
systemctl enable bluetooth 2>/dev/null || true
systemctl enable cups 2>/dev/null || true
systemctl enable sddm 2>/dev/null || true
systemctl enable systemd-timesyncd 2>/dev/null || true
systemctl enable systemd-resolved 2>/dev/null || true
systemctl enable apparmor 2>/dev/null || true
systemctl enable reflector.timer 2>/dev/null || true
systemctl enable paccache.timer 2>/dev/null || true
systemctl enable haveged 2>/dev/null || true
systemctl enable acpid 2>/dev/null || true

# Disable services that aren't needed
systemctl disable systemd-networkd-wait-online.service 2>/dev/null || true

# --- Enable SDDM autologin for the novatos user ---
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/autologin.conf <<'EOF'
[Autologin]
User=novatos
Session=hyprland
EOF

# --- Permissions ---
chmod 4755 /usr/bin/pkexec 2>/dev/null || true

# Make NovatOS scripts executable
chmod 0755 /usr/local/bin/novatos-* 2>/dev/null || true
chmod 0755 /etc/novatos/scripts/* 2>/dev/null || true

# --- Generate a default wallpaper (gradient) if missing ---
mkdir -p /usr/share/wallpapers/novatos
if [ ! -f /usr/share/wallpapers/novatos/default.jpg ]; then
    # We'll create the wallpaper at build time via a helper script
    # If ImageMagick is installed, generate it; otherwise use a solid color PNG
    if command -v convert >/dev/null 2>&1; then
        convert -size 1920x1080 \
            gradient:'#0067c0'-'#0a1f3c' \
            -font DejaVu-Sans-Bold -pointsize 64 -fill white -gravity center \
            -annotate +0-40 "NovatOS" \
            -pointsize 28 -fill '#4cc2ff' \
            -annotate +0+40 "The lightest, newest, most powerful Linux" \
            /usr/share/wallpapers/novatos/default.jpg 2>/dev/null || true
    fi
fi

# --- Make a default solid-blue fallback (for very low-end GPUs) ---
if [ ! -f /usr/share/wallpapers/novatos/solid-blue.png ]; then
    if command -v convert >/dev/null 2>&1; then
        convert -size 1920x1080 xc:'#0a1f3c' /usr/share/wallpapers/novatos/solid-blue.png 2>/dev/null || true
    fi
fi

# --- Done ---
echo "==> [NovatOS] customize_airootfs.sh complete"
exit 0
