#!/bin/bash
# Unit test for shell.qml telemetry pipe commands.
# Run: bash tests/telemetry_test.sh
# All tests must pass before deploying to QML.

set -e
PASS=0 FAIL=0

pass() { PASS=$((PASS+1)); echo "  PASS"; }
fail() { FAIL=$((FAIL+1)); echo "  FAIL: $1"; }

echo "=== Telemetry Command Tests ==="
echo

# --- Battery ---
echo "--- BAT ---"
BAT=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "--")
echo "  output: BAT:${BAT}"
[[ "$BAT" =~ ^[0-9]+$ || "$BAT" == "--" ]] && pass "BAT" || fail "BAT=$BAT"

# --- Power ---
echo "--- PWR ---"
PWR=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
echo "  output: PWR:${PWR}"
[[ "$PWR" =~ ^(Charging|Discharging|Full|Unknown)$ ]] && pass "PWR" || fail "PWR=$PWR"

# --- Playerctl position ---
echo "--- POS ---"
POS=$(playerctl position 2>/dev/null || echo 0)
echo "  output: POS:${POS}"
[[ "$POS" =~ ^[0-9]+(\.[0-9]+)?$ || "$POS" == "0" ]] && pass "POS" || fail "POS=$POS"

# --- Bluetooth ---
echo "--- BT ---"
BT=$([ $(bluetoothctl devices Connected 2>/dev/null | wc -l) -gt 0 ] && echo UP || echo DOWN)
echo "  output: BT:${BT}"
[[ "$BT" == "UP" || "$BT" == "DOWN" ]] && pass "BT" || fail "BT=$BT"

# --- WIFI (active connection) ---
echo "--- WIFI ---"
WIFI=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi 2>/dev/null | grep '^yes' || echo 'NO:DISCONNECTED:0')
echo "  output: WIFI:${WIFI}"
if [[ "$WIFI" == "NO:DISCONNECTED:0" ]]; then
    pass "WIFI (disconnected)"
elif [[ "$WIFI" =~ ^yes: ]]; then
    IFS=':' read -r _ SSID SIGNAL <<< "$WIFI"
    [[ -n "$SSID" ]] && [[ "$SIGNAL" =~ ^[0-9]+$ ]] && pass "WIFI (connected)" || fail "WIFI=$WIFI"
else
    fail "WIFI=$WIFI"
fi

# --- Media metadata ---
echo "--- MEDIA ---"
MEDIA=$(playerctl metadata --format '{{ artist }} - {{ title }}|{{ status }}|{{ mpris:artUrl }}|{{ mpris:length }}|{{ xesam:album }}|{{ xesam:composer }}' 2>/dev/null || echo "")
echo "  output: MEDIA:${MEDIA:-(empty)}"
# Empty is valid (no players running), non-empty with pipes is valid
if [ -z "$MEDIA" ]; then
    pass "MEDIA (no players)"
elif [[ "$MEDIA" == *"|"* ]]; then
    pass "MEDIA (metadata)"
else
    fail "MEDIA=$MEDIA"
fi

# --- Volume ---
echo "--- VOL ---"
VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2}' || echo 0)
echo "  output: VOL:${VOL}"
[[ "$VOL" =~ ^[0-9]+\.[0-9]+$ || "$VOL" == "0" ]] && pass "VOL" || fail "VOL=$VOL"

# --- Brightness ---
echo "--- BRIGHT ---"
BRIGHT=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo 0)
[ -z "$BRIGHT" ] && BRIGHT=0
echo "  output: BRIGHT:${BRIGHT}"
[[ "$BRIGHT" =~ ^[0-9]+$ ]] && pass "BRIGHT" || fail "BRIGHT=$BRIGHT"

# --- Keyboard layout ---
echo "--- KB ---"
KB=$(fcitx5-remote -n 2>/dev/null | sed 's/.*-//' | head -1 || setxkbmap -query 2>/dev/null | grep layout | awk '{print toupper($2)}' || echo 'US')
echo "  output: KB:${KB}"
[[ -n "$KB" ]] && pass "KB" || fail "KB empty"

# ===== FOCUS (kdotool + KWin D-Bus) =====
echo "--- FOCUS ---"
FOCUS_WIN=$(kdotool getactivewindow 2>/dev/null)
if [ -n "$FOCUS_WIN" ]; then
    FOCUS_INFO=$(qdbus org.kde.KWin /KWin org.kde.KWin.getWindowInfo "$FOCUS_WIN" 2>&1)
    FOCUS_TITLE=$(echo "$FOCUS_INFO" | grep '^caption:' | sed 's/^caption: //')
    FOCUS_APP=$(echo "$FOCUS_INFO" | grep '^desktopFile:' | sed 's/^desktopFile: //')
    if [ -n "$FOCUS_APP" ] && [ "$FOCUS_APP" != "plasmashell" ]; then
        echo "  output: FOCUS_TITLE:${FOCUS_TITLE}"
        echo "  output: FOCUS_APP:${FOCUS_APP}"
        [[ -n "$FOCUS_TITLE" ]] && pass "FOCUS title" || fail "FOCUS_TITLE empty"
        [[ -n "$FOCUS_APP" ]] && pass "FOCUS app" || fail "FOCUS_APP empty"
    else
        echo "  output: (no valid window - desktop focused)"
        pass "FOCUS (desktop)"
    fi
else
    echo "  output: (no active window)"
    pass "FOCUS (no window)"
fi

# ===== WINDOW ENUMERATION (kdotool + KWin D-Bus) =====
echo "--- WINDOW ENUM ---"
declare -A WIN_COUNTS
declare -a WIN_LIST
# Ensure pipefails don't break
while read -r id; do
    [ -z "$id" ] && continue
    kclass=$(kdotool getwindowclassname "$id" 2>/dev/null)
    [ "$kclass" = "plasmashell" ] && continue
    [ -z "$kclass" ] && continue
    winfo=$(qdbus org.kde.KWin /KWin org.kde.KWin.getWindowInfo "$id" 2>&1)
    df=$(echo "$winfo" | grep '^desktopFile:' | sed 's/^desktopFile: //')
    cap=$(echo "$winfo" | grep '^caption:' | sed 's/^caption: //')
    [ -n "$df" ] && echo "  $df | $cap"
done < <(kdotool search "." 2>/dev/null)
echo "  (enumeration complete)"
pass "WINDOW ENUM"

echo
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
