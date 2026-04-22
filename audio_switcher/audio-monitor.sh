#!/bin/bash

# Switch to the right audio device when switching between speaker and headphones on Linux.
#
# Requires: pactl, grep, awk, head, sed, wpctl, playerctl

# 1. Identify Card and Profiles
CARD=$(pactl list cards short | awk '{print $2}' | grep -E "pci|sof" | head -n 1)
HP_PROF=$(pactl list cards | grep "HiFi" | grep "Headphones" | head -n 1 | sed 's/:.*//' | xargs)
SP_PROF=$(pactl list cards | grep "HiFi" | grep "Speaker" | head -n 1 | sed 's/:.*//' | xargs)

LAST_STATE="unknown"

# Function to check hardware and apply profile
check_and_apply() {
    HP_PORT_LINE=$(pactl list cards | grep -A 1 "\[Out\] Headphones" | head -n 1)
    
    if echo "$HP_PORT_LINE" | grep -q "available" && ! echo "$HP_PORT_LINE" | grep -q "not available"; then
        CURRENT_STATE="plugged"
    else
        CURRENT_STATE="unplugged"
    fi

    if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
        if [ "$CURRENT_STATE" == "plugged" ]; then
            echo "--- Headphones IN ---"
            pactl set-card-profile "$CARD" "$HP_PROF"
            sleep 0.5
            ID=$(wpctl status | grep -i "headphone" | grep -oE "[0-9]+" | head -n 1)
            [ -n "$ID" ] && wpctl set-default "$ID"
        else
            echo "--- Headphones OUT ---"
            # Pause media only if we aren't at script startup (to avoid pausing background music when you just start your PC)
            if [ "$LAST_STATE" != "unknown" ]; then
                playerctl pause 2>/dev/null
            fi
            
            pactl set-card-profile "$CARD" "$SP_PROF"
            sleep 0.5
            ID=$(wpctl status | grep -i "speaker" | grep -oE "[0-9]+" | head -n 1)
            [ -z "$ID" ] && ID=$(wpctl status | grep "Sinks:" -A 15 | grep "Alder Lake" | grep -v "HDMI" | grep -oE "[0-9]+" | head -n 1)
            [ -n "$ID" ] && wpctl set-default "$ID"
        fi
        LAST_STATE=$CURRENT_STATE
    fi
}

echo "Starting audio monitor for $CARD..."

# --- RUN ONCE AT STARTUP ---
check_and_apply

# --- THEN LISTEN FOR EVENTS ---
pactl subscribe | while read line; do
    if echo "$line" | grep -q "card"; then
        check_and_apply
    fi
done
