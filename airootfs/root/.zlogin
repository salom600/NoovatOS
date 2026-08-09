#!/usr/bin/env bash
# Live ISO auto-login script (run as root via .zlogin for the novatos user)
# This is the legacy archiso bootstrap; modern archiso uses systemd units.

# SPDX-License-Identifier: GPL-3.0-or-later

if [ -n "${DISPLAY}" ]; then return 0; 2>/dev/null || exit 0; fi
if [ "$XDG_VTNR" != 1 ]; then return 0; 2>/dev/null || exit 0; fi

# Auto-login the novatos user into Hyprland
exec Hyprland
