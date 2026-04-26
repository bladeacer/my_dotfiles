#!/bin/bash

# Switch to the right audio device when switching between speaker and headphones on Linux.
#
# Requires: pactl, grep, awk, head, sed, wpctl, playerctl, loginctl
#
# --- 1. INITIALIZATION ---
# Give PipeWire/PulseAudio a moment to settle after login
sleep 2

LAST_STATE="unknown"

detect_hardware() {
    # Find the PCI/SOF card name
    CARD=$(pactl list cards short | awk '{print $2}' | grep -E "pci|sof" | head -n 1)
    
    # Extract the exact profile names (usually 'HiFi' or 'pro-audio' based)
    HP_PROF=$(pactl list cards | grep "HiFi" | grep "Headphones" | head -n 1 | sed 's/:.*//' | xargs)
    SP_PROF=$(pactl list cards | grep "HiFi" | grep "Speaker" | head -n 1 | sed 's/:.*//' | xargs)
    
    if [ -n "$CARD" ] && [ -n "$HP_PROF" ]; then
        echo "[INIT] Hardware Detected: Card=$CARD"
        return 0
    else
        return 1
    fi
}

check_and_apply() {
    # --- 2. ROBUSTNESS CHECK ---
    # If variables are empty (failed boot detection), try again now
    if [ -z "$CARD" ] || [ -z "$HP_PROF" ]; then
        echo "[RETRY] Hardware info missing. Attempting re-detection..."
        if ! detect_hardware; then
            echo "[ERROR] Audio hardware not ready. Skipping check."
            return
        fi
    fi

    # Detect jack availability
    HP_PORT_LINE=$(pactl list cards | grep -A 1 "\[Out\] Headphones" | head -n 1)
    
    if echo "$HP_PORT_LINE" | grep -q "available" && ! echo "$HP_PORT_LINE" | grep -q "not available"; then
        CURRENT_STATE="plugged"
    else
        CURRENT_STATE="unplugged"
    fi

    # Only act if the state has changed
    if [ "$CURRENT_STATE" != "$LAST_STATE" ]; then
        echo "[DEBUG] State Change: $LAST_STATE -> $CURRENT_STATE"
        
        # --- 3. PRE-EMPTIVE SNAPSHOT ---
        P_STATUS=$(playerctl status 2>/dev/null)
        WANT_PLAYING=false
        
        if [ "$P_STATUS" == "Playing" ] || ([ "$P_STATUS" == "Paused" ] && [ "$CURRENT_STATE" == "unplugged" ]); then
            WANT_PLAYING=true
            echo "[RECONCILE] Media intent: PLAYING. Pausing for switch..."
            playerctl pause 2>/dev/null
        else
            echo "[RECONCILE] Media intent: SILENT."
        fi

        # --- 4. HARDWARE SWITCH ---
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
            # Look for Speaker or fallback to Alder Lake Sink
            ID=$(wpctl status | grep -i "speaker" | grep -oE "[0-9]+" | head -n 1)
            [ -z "$ID" ] && ID=$(wpctl status | grep "Sinks:" -A 15 | grep "Alder Lake" | grep -v "HDMI" | grep -oE "[0-9]+" | head -n 1)
            [ -n "$ID" ] && wpctl set-default "$ID"
        fi

        # --- 5. RECONCILIATION LOOP ---
        if [ "$WANT_PLAYING" = true ]; then
            sleep "$READY_SLEEP"
            for i in {1..8}; do
                playerctl play 2>/dev/null
                sleep 0.3
                if [ "$(playerctl status 2>/dev/null)" == "Playing" ]; then
                    echo "[SUCCESS] Playback resumed on attempt $i."
                    break
                fi
                [ $i -eq 3 ] && playerctl play-pause 2>/dev/null
            done
        fi

        LAST_STATE=$CURRENT_STATE
        echo "[DEBUG] Final State: $LAST_STATE"
        echo "----------------------------------------"
    fi
}

# --- 6. EXECUTION ---
detect_hardware
check_and_apply

# Subscribe to events and filter for card/sink changes
pactl subscribe | while read -r line; do
    if echo "$line" | grep -qE "card|sink"; then
        check_and_apply
    fi
done
