#!/bin/bash

# Switch to the right audio device when switching between speaker and headphones on Linux.
#
# Requires: pactl, grep, awk, head, sed, wpctl, playerctl

# 1. Identify Card and Profiles
CARD=$(pactl list cards short | awk '{print $2}' | grep -E "pci|sof" | head -n 1)
HP_PROF=$(pactl list cards | grep "HiFi" | grep "Headphones" | head -n 1 | sed 's/:.*//' | xargs)
SP_PROF=$(pactl list cards | grep "HiFi" | grep "Speaker" | head -n 1 | sed 's/:.*//' | xargs)

LAST_STATE="unknown"

check_and_apply() {
    HP_PORT_LINE=$(pactl list cards | grep -A 1 "\[Out\] Headphones" | head -n 1)
    
    if echo "$HP_PORT_LINE" | grep -q "available" && ! echo "$HP_PORT_LINE" | grep -q "not available"; then
        CURRENT_STATE="plugged"
    else
        CURRENT_STATE="unplugged"
    fi

    if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
        echo "[DEBUG] State Change: $LAST_STATE -> $CURRENT_STATE"
        
        # --- 1. PRE-EMPTIVE SNAPSHOT ---
        P_STATUS=$(playerctl status 2>/dev/null)
        echo "[DEBUG] Capture Status: '$P_STATUS'"
        
        WANT_PLAYING=false
        # Logic: If playing, OR if just unplugged and status is already 'Paused' (OS hijack)
        if [ "$P_STATUS" == "Playing" ] || ([ "$P_STATUS" == "Paused" ] && [ "$CURRENT_STATE" == "unplugged" ]); then
            WANT_PLAYING=true
            echo "[RECONCILE] Media intent: PLAYING. Pausing for switch..."
            playerctl pause 2>/dev/null
        else
            echo "[RECONCILE] Media intent: SILENT."
        fi

        # --- 2. HARDWARE SWITCH ---
        if [ "$CURRENT_STATE" == "plugged" ]; then
            echo "--- ACTION: Switching to Headphones ---"
            pactl set-card-profile "$CARD" "$HP_PROF"
            READY_SLEEP=0.4 
            ID=$(wpctl status | grep -i "headphone" | grep -oE "[0-9]+" | head -n 1)
            [ -n "$ID" ] && wpctl set-default "$ID"
        else
            echo "--- ACTION: Switching to Speakers ---"
            pactl set-card-profile "$CARD" "$SP_PROF"
            READY_SLEEP=0.8
            ID=$(wpctl status | grep -i "speaker" | grep -oE "[0-9]+" | head -n 1)
            [ -z "$ID" ] && ID=$(wpctl status | grep "Sinks:" -A 15 | grep "Alder Lake" | grep -v "HDMI" | grep -oE "[0-9]+" | head -n 1)
            [ -n "$ID" ] && wpctl set-default "$ID"
        fi

        # --- 3. RECONCILIATION LOOP ---
        if [ "$WANT_PLAYING" = true ]; then
            echo "[DEBUG] Waiting ${READY_SLEEP}s for hardware settle..."
            sleep "$READY_SLEEP"
            
            echo "[DEBUG] Starting polling loop..."
            for i in {1..8}; do
                playerctl play 2>/dev/null
                sleep 0.3
                CHECK=$(playerctl status 2>/dev/null)
                
                if [ "$CHECK" == "Playing" ]; then
                    echo "[SUCCESS] Playback resumed on attempt $i."
                    break
                fi
                
                echo "[DEBUG] Attempt $i: Status still '$CHECK'..."
                
                # Emergency kick for stubborn players
                if [ $i -eq 3 ]; then
                    echo "[DEBUG] Sending toggle jumpstart..."
                    playerctl play-pause 2>/dev/null
                fi
            done
        fi

        LAST_STATE=$CURRENT_STATE
        echo "[DEBUG] Final State: $LAST_STATE"
        echo "----------------------------------------"
    fi
}

echo "Audio monitor (Debug + Polling) active for $CARD"
check_and_apply

pactl subscribe | while read line; do
    if echo "$line" | grep -q "card"; then
        check_and_apply
    fi
done
