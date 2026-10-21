#!/bin/bash
# Regression test for the SDDM greeter virtual keyboard.
# Run: bash tests/sddm_config_test.sh
#
# Bug: on Plasma 6.8 the SDDM greeter showed a mobile-styled Qt virtual
# keyboard scaled over the whole login page, popping up every time the
# password field took focus. Cause: EndeavourOS ships
# /etc/sddm.conf.d/10-endeavouros.conf with InputMethod=qtvirtualkeyboard,
# which makes SDDM export QT_IM_MODULE=qtvirtualkeyboard to the greeter so
# the Qt virtual keyboard plugin loads as the platform input context.
#
# Fix: sddm/sddm.conf.d/99-no-virtual-keyboard.conf overrides it with an
# empty InputMethod= (SDDM's default = no input method). Because SDDM's
# built-in default for that key is "qtvirtualkeyboard", the drop-in is
# load-bearing: if it goes missing, or if some other file in
# /etc/sddm.conf.d/ sorts after it and sets InputMethod, the keyboard comes
# back. These tests check both the repo and the live system.

set -u
PASS=0 FAIL=0

pass() { PASS=$((PASS+1)); echo "  PASS"; }
fail() { FAIL=$((FAIL+1)); echo "  FAIL: $1"; }

STOW_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=/dev/null
. "$STOW_DIR/lib/sddm-config.sh"

echo "=== SDDM Greeter Virtual Keyboard Tests ==="
echo

# --- The drop-in is in the repo ---
echo "--- DROP-IN PRESENT ---"
DROPIN="$STOW_DIR/sddm/sddm.conf.d/99-no-virtual-keyboard.conf"
if [ -f "$DROPIN" ]; then
    pass
else
    fail "missing $DROPIN"
fi

# --- It sets an empty InputMethod in the General section ---
echo "--- DROP-IN SETS EMPTY InputMethod ---"
val="$(grep -E '^[[:space:]]*InputMethod[[:space:]]*=' "$DROPIN" 2>/dev/null | tail -1 | cut -d= -f2- | tr -d '[:space:]')"
if [ -z "$val" ]; then
    pass
else
    fail "drop-in sets InputMethod=$val (must be empty)"
fi

# --- It must sort after the EOS drop-in it overrides ---
echo "--- DROP-IN SORTS AFTER 10-endeavouros.conf ---"
# SDDM reads /etc/sddm.conf.d/ in QDir::LocaleAware order; later wins.
if [[ "99-no-virtual-keyboard.conf" > "10-endeavouros.conf" ]]; then
    pass
else
    fail "drop-in name does not sort after 10-endeavouros.conf"
fi

# --- The repo drop-in wins over the repo's other SDDM drop-ins ---
echo "--- REPO CONFIG RESOLVES TO EMPTY InputMethod ---"
# Resolve using the repo's own drop-in directory in place of /etc/sddm.conf.d
# so the test still means something on a machine that has not stowed yet.
repo_resolve="$(SDDM_LOCAL_CONF_DIR="$STOW_DIR/sddm/sddm.conf.d" \
                SDDM_CONF_FILE=/dev/null \
                sddm_effective_value General InputMethod)"
if [ -z "$repo_resolve" ]; then
    pass
else
    fail "repo SDDM config resolves to InputMethod='$repo_resolve' (must be empty)"
fi

# --- No repo drop-in may set InputMethod after the 99- file ---
echo "--- NO LATER DROP-IN RE-ENABLES THE KEYBOARD ---"
later=0
for f in "$STOW_DIR"/sddm/sddm.conf.d/*.conf; do
    [ -e "$f" ] || continue
    name="$(basename "$f")"
    [[ "$name" > "99-no-virtual-keyboard.conf" ]] || continue
    if grep -qE '^[[:space:]]*InputMethod[[:space:]]*=' "$f"; then
        fail "$name sorts after the drop-in and sets InputMethod"
        later=1
    fi
done
[ "$later" -eq 0 ] && pass

# --- Live system: the effective config must have no input method ---
echo "--- LIVE SYSTEM: EFFECTIVE InputMethod IS EMPTY ---"
live="$(sddm_effective_value General InputMethod)"
if [ -z "$live" ]; then
    pass
else
    fail "live SDDM resolves InputMethod='$live' — greeter will show the keyboard"
fi

# --- Live system: the drop-in is actually installed ---
echo "--- LIVE SYSTEM: DROP-IN INSTALLED ---"
if [ -e /etc/sddm.conf.d/99-no-virtual-keyboard.conf ]; then
    pass
else
    fail "/etc/sddm.conf.d/99-no-virtual-keyboard.conf is not installed (stow sddm -t /etc)"
fi

echo
echo "=== Result: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
