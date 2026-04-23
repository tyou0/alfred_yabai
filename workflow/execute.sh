#!/bin/bash
set -euo pipefail

# Ensure we have a proper PATH for Alfred
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

notify_error() {
    local message="$1"

    echo "$message" >&2
    osascript \
        -e 'on run argv' \
        -e 'display notification (item 1 of argv) with title "Yabai Workflow"' \
        -e 'end run' \
        "$message" >/dev/null 2>&1 || true
}

fail() {
    notify_error "$1"
    exit 1
}

move_window_to_display() {
    local target_display="$1"
    local fallback_display="$2"
    local display_count
    local target_display_index

    display_count=$("$YABAI" -m query --displays | awk '/"index":/ { count++ } END { print count + 0 }')
    if [ "$display_count" -lt 2 ]; then
        fail "Only one display found. Connect another monitor before using next/previous display."
    fi

    if ! target_display_index=$("$YABAI" -m query --displays --display "$target_display" 2>/dev/null | sed -n 's/.*"index":[[:space:]]*\([0-9][0-9]*\).*/\1/p'); then
        target_display_index=""
    fi

    if [ -z "$target_display_index" ]; then
        target_display_index=$("$YABAI" -m query --displays --display "$fallback_display" 2>/dev/null | sed -n 's/.*"index":[[:space:]]*\([0-9][0-9]*\).*/\1/p')
    fi

    if [ -z "$target_display_index" ]; then
        fail "No target display found."
    fi

    "$YABAI" -m window --display "$target_display_index" --focus
}

# Find yabai
YABAI=$(command -v yabai || true)
if [ -z "$YABAI" ]; then
    # Fallback to common locations
    if [ -x "/opt/homebrew/bin/yabai" ]; then
        YABAI="/opt/homebrew/bin/yabai"
    elif [ -x "/usr/local/bin/yabai" ]; then
        YABAI="/usr/local/bin/yabai"
    else
        fail "yabai not found. Install it with Homebrew, then run: yabai --start-service"
    fi
fi

ACTION="${1:-}"

if ! YABAI_STATUS=$("$YABAI" -m query --spaces 2>&1 >/dev/null); then
    fail "yabai is installed but not accepting commands. Grant Accessibility permission to yabai and Alfred, run: yabai --restart-service, then verify: yabai -m query --spaces. Error: $YABAI_STATUS"
fi

case "$ACTION" in
    "left")
        "$YABAI" -m window --grid 1:2:0:0:1:1
        ;;
    "right")
        "$YABAI" -m window --grid 1:2:1:0:1:1
        ;;
    "maximize")
        # Toggle zoom-fullscreen (fill the workspace)
        "$YABAI" -m window --grid 1:1:0:0:1:1 || "$YABAI" -m window --toggle zoom-fullscreen
        ;;
    "center")
        "$YABAI" -m window --grid 4:4:1:1:2:2
        ;;
    "top_half")
        "$YABAI" -m window --grid 2:1:0:0:1:1
        ;;
    "bottom_half")
        "$YABAI" -m window --grid 2:1:0:1:1:1
        ;;
    "left_third")
        "$YABAI" -m window --grid 1:3:0:0:1:1
        ;;
    "center_third")
        "$YABAI" -m window --grid 1:3:1:0:1:1
        ;;
    "right_third")
        "$YABAI" -m window --grid 1:3:2:0:1:1
        ;;
    "left_two_thirds")
        "$YABAI" -m window --grid 1:3:0:0:2:1
        ;;
    "right_two_thirds")
        "$YABAI" -m window --grid 1:3:1:0:2:1
        ;;
    "center_two_thirds")
        "$YABAI" -m window --grid 6:6:1:0:4:6
        ;;
    "top_left")
        "$YABAI" -m window --grid 2:2:0:0:1:1
        ;;
    "top_right")
        "$YABAI" -m window --grid 2:2:1:0:1:1
        ;;
    "bottom_left")
        "$YABAI" -m window --grid 2:2:0:1:1:1
        ;;
    "bottom_right")
        "$YABAI" -m window --grid 2:2:1:1:1:1
        ;;
    "center_window")
        "$YABAI" -m window --grid 10:10:1:1:8:8
        ;;
    "reset_window")
        # Comprehensive reset: un-zoom, un-float, then balance
        "$YABAI" -m query --windows --window | grep -q '"is-zoom-fullscreen": true' && "$YABAI" -m window --toggle zoom-fullscreen
        "$YABAI" -m query --windows --window | grep -q '"is-floating": true' && "$YABAI" -m window --toggle float
        "$YABAI" -m space --balance
        ;;
    "next_screen")
        move_window_to_display "next" "first"
        ;;
    "prev_screen")
        move_window_to_display "prev" "last"
        ;;
    "float")
        "$YABAI" -m window --toggle float
        ;;
    "sticky")
        "$YABAI" -m window --toggle sticky
        ;;
    "balance")
        "$YABAI" -m space --balance
        ;;
    "layout_bsp")
        "$YABAI" -m space --layout bsp
        ;;
    "layout_stack")
        "$YABAI" -m space --layout stack
        ;;
    "layout_float")
        "$YABAI" -m space --layout float
        ;;
    "mirror_x")
        "$YABAI" -m space --mirror x-axis
        ;;
    "mirror_y")
        "$YABAI" -m space --mirror y-axis
        ;;
    "rotate")
        "$YABAI" -m space --rotate 90
        ;;
    "focus_left")
        "$YABAI" -m window --focus west
        ;;
    "focus_right")
        "$YABAI" -m window --focus east
        ;;
    "focus_up")
        "$YABAI" -m window --focus north
        ;;
    "focus_down")
        "$YABAI" -m window --focus south
        ;;
    "swap_left")
        "$YABAI" -m window --swap west
        ;;
    "swap_right")
        "$YABAI" -m window --swap east
        ;;
    "swap_up")
        "$YABAI" -m window --swap north
        ;;
    "swap_down")
        "$YABAI" -m window --swap south
        ;;
    *) echo "Unknown action: $ACTION" >&2; exit 1 ;;
esac
