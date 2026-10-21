#!/bin/bash
# sddm-config.sh — resolve SDDM's effective configuration.
#
# SDDM does not use QSettings for sddm.conf; it ships its own INI parser
# (sddm 0.21, src/common/ConfigReader.cpp). The rules that matter:
#
#   1. Files are read in this order, and the LAST value of a key wins:
#        /usr/lib/sddm/sddm.conf.d/*   (system defaults)
#        /etc/sddm.conf.d/*            (local drop-ins)
#        /etc/sddm.conf                (legacy single file)
#   2. Within a directory, files are read in QDir::LocaleAware order.
#      For the names we ship that is the same as byte order: digits sort
#      before letters, so "10-" < "50-" < "99-" < "kde_settings.conf".
#   3. Every regular file in the directory is read — SDDM does not filter
#      on the .conf extension. Symlinks to regular files count as regular
#      files (Qt's QDir::Files follows symlinks); stow installs the
#      drop-ins as symlinks, so this matters.
#   4. A key is only applied inside the section that owns it. Keys before
#      any [Section] header belong to the implicit "General" section.
#   5. Values are trimmed, so "InputMethod=" is the empty string.
#
# Sourced by setup.sh (post-install verification) and
# tests/sddm_config_test.sh (regression test).

SDDM_SYS_CONF_DIR="${SDDM_SYS_CONF_DIR:-/usr/lib/sddm/sddm.conf.d}"
SDDM_LOCAL_CONF_DIR="${SDDM_LOCAL_CONF_DIR:-/etc/sddm.conf.d}"
SDDM_CONF_FILE="${SDDM_CONF_FILE:-/etc/sddm.conf}"

# sddm_config_files — the ordered list of config files SDDM will read.
sddm_config_files() {
    local dir file
    for dir in "$SDDM_SYS_CONF_DIR" "$SDDM_LOCAL_CONF_DIR"; do
        [ -d "$dir" ] || continue
        while IFS= read -r file; do
            printf '%s\n' "$file"
        done < <(find -L "$dir" -maxdepth 1 -type f -printf '%p\n' 2>/dev/null | LC_ALL=C sort || true)
    done
    printf '%s\n' "$SDDM_CONF_FILE"
}

# sddm_effective_value SECTION KEY — print the value SDDM would end up
# with for that key, or the empty string if it is not set anywhere.
sddm_effective_value() {
    local want_section="$1" want_key="$2"
    local file section key value line result=""

    while IFS= read -r file; do
        [ -r "$file" ] || continue
        section="General"   # SDDM's IMPLICIT_SECTION
        while IFS= read -r line; do
            line="${line%%#*}"          # strip comments
            line="${line#"${line%%[![:space:]]*}"}"   # ltrim
            line="${line%"${line##*[![:space:]]}"}"   # rtrim
            [ -n "$line" ] || continue

            if [[ "$line" == *=* ]]; then
                key="${line%%=*}"
                value="${line#*=}"
                key="${key%"${key##*[![:space:]]}"}"
                value="${value#"${value%%[![:space:]]*}"}"
                value="${value%"${value##*[![:space:]]}"}"
                if [ "$section" = "$want_section" ] && [ "$key" = "$want_key" ]; then
                    result="$value"
                fi
            elif [[ "$line" == \[*\] ]]; then
                section="${line:1:${#line}-2}"
            fi
        done < "$file"
    done < <(sddm_config_files)

    printf '%s\n' "$result"
}
