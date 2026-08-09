# NovatOS

> The lightest, newest, most powerful Linux distribution — built for Windows 11 migrants.

![NovatOS](airootfs/usr/share/wallpapers/novatos/default.jpg)

NovatOS is a 2026-era Arch-based Linux distribution designed to:

- **Run on anything** — supports hardware from 2009 to 2026 (minimum: 2 GB RAM, dual-core 64-bit CPU)
- **Be feather-light** — idle RAM usage under 350 MB on Hyprland (Wayland)
- **Welcome Windows users** — taskbar, start menu, app store, Windows-app compatibility
- **Just work** — drivers auto-detected at first boot; no commands needed
- **Play games** — Steam + Proton + Wine + Lutris, one-click install from the store

## Desktop environment

- **Compositor:** Hyprland (Wayland, primary), Sway (fallback for old GPUs)
- **Display manager:** SDDM with custom NovatOS theme
- **Panel:** Waybar configured like a Windows 11 taskbar
- **Launcher:** wofi styled as a Windows 11 start menu
- **Lock screen:** Hyprlock with NovatOS branding
- **Boot splash:** Plymouth with custom NovatOS theme
- **Wallpaper:** Auto-generated gradient with NovatOS wordmark

## App store

[`bauh`](https://github.com/vinifmor/bauh) provides a single GUI to install apps from:
- Arch official repos (pacman)
- AUR (Arch User Repository)
- Flathub (Flatpak)
- Snap Store
- AppImage
- Web Apps (PWA shortcuts)

## Gaming

The gaming stack is **not** installed on the ISO (to keep it light). One click in the
Welcome app installs: Steam, Proton-GE, Wine-Staging, Lutris, Heroic, gamemode,
gamescope, mangohud, plus the correct 32-bit Vulkan drivers for your GPU.

## Windows compatibility

- Right-click any `.exe` or `.msi` in Thunar → **Run with Wine**
- Pre-initialized Wine prefix with d3dx9, vcrun2019, dotnet48, corefonts
- `novatos-windows-compat make-launcher <exe> <name>` creates a Start-menu entry

## Driver support

`/etc/novatos/scripts/detect-gpu` runs at every login and picks the correct driver:

| GPU family | Driver |
|------------|--------|
| Intel GMA 950/X3100 (2006-2009) | `i915` + `swrast` |
| Intel HD/Iris/Arc (2010+) | `i915` + `iris` + `anv` |
| AMD r600 (HD 2000-7000) | `radeon` + `r600g` |
| AMD GCN/RDNA (HD 7000+) | `amdgpu` + `radeonsi` + `RADV` |
| NVIDIA GeForce 6-500 (2004-2012) | `nouveau` (OSS) |
| NVIDIA GeForce 600+ (Kepler, 2012+) | `nvidia-dkms` (proprietary) |
| VirtualBox / VMware / QEMU | `vboxvideo` / `vmwgfx` / `qxl` |

## Repository structure

```
.
├── .github/workflows/build.yml   # CI/CD: builds ISO on every push
├── profiledef.sh                 # archiso profile metadata
├── packages.x86_64               # package list installed on ISO
├── pacman.conf                   # pacman config used during build
├── syslinux/                     # BIOS bootloader config
├── efiboot/                      # UEFI bootloader config
└── airootfs/                     # chroot filesystem
    ├── etc/
    │   ├── novatos/scripts/      # detect-gpu, install-gaming, setup-flatpak-remotes
    │   ├── calamares/            # Calamares installer config
    │   ├── sddm.conf             # Display manager config
    │   ├── polkit-1/rules.d/     # Polkit rules (allow user to mount, install, etc.)
    │   ├── mkinitcpio.conf       # initramfs hooks
    │   ├── pacman.conf           # system-wide pacman config
    │   └── skel/.config/         # Hyprland, Waybar, wofi, kitty, foot, hyprlock, wlogout
    ├── root/
    │   ├── customize_airootfs.sh # archiso post-install hook (creates user, services)
    │   ├── .automated_script.sh  # live-ISO boot script
    │   └── .zlogin               # tty1 auto-login
    └── usr/
        ├── local/bin/            # novatos-* helper scripts
        └── share/
            ├── wayland-sessions/ # hyprland.desktop, sway.desktop
            ├── sddm/themes/novatos/  # custom SDDM theme
            ├── plymouth/themes/novatos/  # custom Plymouth theme
            ├── calamares/branding/novatos/
            └── wallpapers/novatos/
```

## Building locally

```bash
# On an Arch Linux host (or any host with archiso + docker):
git clone https://github.com/salom600/NoovatOS.git
cd NoovatOS
sudo mkarchiso -v -w work -o out .
```

Or use Docker (any Linux host):

```bash
docker run --rm --privileged \
  -v "$PWD":/novatos -v "$PWD/work":/work -v "$PWD/out":/out \
  -w /novatos archlinux:latest \
  bash -c 'pacman -Syu --noconfirm && pacman -S --noconfirm archiso mkinitcpio squashfs-tools grub efibootmgr xorriso && mkarchiso -v -w /work -o /out .'
```

## CI/CD

Every push to `main` triggers a GitHub Actions build that:
1. Spins up an `archlinux:latest` Docker container
2. Installs archiso + dependencies
3. Generates wallpaper, Plymouth assets, SDDM background
4. Runs `mkarchiso` to build the hybrid ISO
5. Uploads the ISO + SHA256SUMS as both an Actions artifact and a rolling GitHub Release

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).
