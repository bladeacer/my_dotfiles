#!/bin/bash
# plasma-shutdown-fix.sh — toggle the KDE Plasma 6.8 / Qt 6.12 shutdown-hang workaround.
#
# KDE bug 525727 (duplicate: 527208): on Qt 6.12.0, plasmashell deadlocks in
# QQuickPixmapReader::~QQuickPixmapReader when the Pager (virtual desktops)
# widget is on the panel. It then ignores SIGTERM at logout/shutdown and
# systemd SIGKILLs it only after the 40s TimeoutStopSec — adding ~40s to
# every shutdown/reboot. The fix is merged upstream in Qt 6.12.1.
#
# This workaround shortens TimeoutStopSec for plasma-plasmashell.service so
# a hang costs ~8s instead of 40s. It is inert once Qt >= 6.12.1 ships
# (plasmashell exits in <1s, the timeout never fires), so it is safe to
# keep — but once you have updated, disable it with: plasma-shutdown-fix.sh disable
#
# The override lives OUTSIDE the dotfiles repo (it is toggle state, not a
# stowed file): ~/.config/systemd/user/plasma-plasmashell.service.d/timeout.conf

set -euo pipefail

UNIT="plasma-plasmashell.service"
DROPIN_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/$UNIT.d"
DROPIN="$DROPIN_DIR/timeout.conf"

qt_version() {
    pacman -Q qt6-base 2>/dev/null | awk '{print $2}' || echo "unknown"
}

usage() {
    cat <<EOF
Usage: plasma-shutdown-fix.sh <command>

Commands:
  enable    Shorten TimeoutStopSec to 8s for $UNIT (workaround ON)
  disable   Remove the override; restore the 40s default (workaround OFF)
  status    Show workaround state and installed qt6-base version

Background: KDE bug 525727, fixed upstream in Qt 6.12.1. Once qt6-base
>= 6.12.1 is installed, run: plasma-shutdown-fix.sh disable
EOF
}

case "${1:-}" in
    enable)
        mkdir -p "$DROPIN_DIR"
        cat > "$DROPIN" <<'EOF'
# Created by plasma-shutdown-fix.sh — KDE bug 525727 (fixed in Qt 6.12.1).
# Cut the shutdown hang from 40s to 8s while plasmashell ignores SIGTERM.
[Service]
TimeoutStopSec=8s
EOF
        systemctl --user daemon-reload
        echo "Workaround ENABLED: TimeoutStopSec=8s for $UNIT."
        echo "Disable it once Qt >= 6.12.1 is installed: plasma-shutdown-fix.sh disable"
        ;;
    disable)
        rm -f "$DROPIN"
        rmdir --ignore-fail-on-non-empty "$DROPIN_DIR" 2>/dev/null || true
        systemctl --user daemon-reload
        echo "Workaround DISABLED: $UNIT back to the 40s systemd default."
        ;;
    status)
        if [ -f "$DROPIN" ]; then
            echo "workaround: enabled ($DROPIN)"
        else
            echo "workaround: disabled"
        fi
        echo "qt6-base:   $(qt_version)  (fix ships in >= 6.12.1)"
        echo "active TimeoutStopSec: $(systemctl --user show "$UNIT" -p TimeoutStopUSec 2>/dev/null | cut -d= -f2 || echo 'unit not loaded')"
        ;;
    *)
        usage
        [ -z "${1:-}" ] && exit 1 || exit 1
        ;;
esac
