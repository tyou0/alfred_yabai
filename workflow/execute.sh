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

json_number() {
    local json="$1"
    local field="$2"

    printf '%s\n' "$json" \
        | sed -n "s/.*\"$field\":[[:space:]]*\([-+]\{0,1\}[0-9][0-9]*\(\.[0-9][0-9]*\)\{0,1\}\).*/\1/p" \
        | head -n 1
}

move_window_frame_to_display() {
    local window_json="$1"
    local target_display_index="$2"
    local display_json
    local window_id
    local window_width
    local window_height
    local display_x
    local display_y
    local display_width
    local display_height
    local target_position
    local target_x
    local target_y

    display_json=$("$YABAI" -m query --displays index,frame --display "$target_display_index")
    window_id=$(json_number "$window_json" "id")
    window_width=$(json_number "$window_json" "w")
    window_height=$(json_number "$window_json" "h")
    display_x=$(json_number "$display_json" "x")
    display_y=$(json_number "$display_json" "y")
    display_width=$(json_number "$display_json" "w")
    display_height=$(json_number "$display_json" "h")

    if [ -z "$window_id" ] || [ -z "$window_width" ] || [ -z "$window_height" ] \
        || [ -z "$display_x" ] || [ -z "$display_y" ] \
        || [ -z "$display_width" ] || [ -z "$display_height" ]; then
        fail "Could not determine window or display geometry for display move."
    fi

    target_position=$(awk \
        -v display_x="$display_x" \
        -v display_y="$display_y" \
        -v display_width="$display_width" \
        -v display_height="$display_height" \
        -v window_width="$window_width" \
        -v window_height="$window_height" \
        'BEGIN {
            target_x = display_x + ((display_width - window_width) / 2)
            target_y = display_y + ((display_height - window_height) / 2)

            if (target_x < display_x) {
                target_x = display_x
            }
            if (target_y < display_y) {
                target_y = display_y
            }

            printf "%.0f:%.0f\n", target_x, target_y
        }')

    IFS=':' read -r target_x target_y <<< "$target_position"
    "$YABAI" -m window "$window_id" --move "abs:$target_x:$target_y"
}

move_window_to_display() {
    local target_display="$1"
    local fallback_display="$2"
    local display_count
    local target_display_index
    local focused_window_json
    local focused_window_id
    local moved_window_json
    local moved_display_index

    display_count=$("$YABAI" -m query --displays | awk '{ count += gsub(/"index":/, "&") } END { print count + 0 }')
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

    focused_window_json=$("$YABAI" -m query --windows id,display,frame --window)
    focused_window_id=$(json_number "$focused_window_json" "id")

    if [ -z "$focused_window_id" ]; then
        fail "No focused window found to move."
    fi

    if "$YABAI" -m window --display "$target_display_index"; then
        moved_window_json=$("$YABAI" -m query --windows display --window "$focused_window_id")
        moved_display_index=$(json_number "$moved_window_json" "display")
        if [ "$moved_display_index" != "$target_display_index" ]; then
            move_window_frame_to_display "$focused_window_json" "$target_display_index"
        fi
    else
        move_window_frame_to_display "$focused_window_json" "$target_display_index"
    fi

    moved_window_json=$("$YABAI" -m query --windows display --window "$focused_window_id")
    moved_display_index=$(json_number "$moved_window_json" "display")
    if [ "$moved_display_index" != "$target_display_index" ]; then
        fail "Could not move focused window to display $target_display_index."
    fi

    "$YABAI" -m display --focus "$target_display_index"
    "$YABAI" -m window "$focused_window_id" --focus || true
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
        if ! "$YABAI" -m query --windows --window | grep -q '"has-fullscreen-zoom":[[:space:]]*true'; then
            "$YABAI" -m window --toggle windowed-fullscreen \
                || "$YABAI" -m window --toggle zoom-fullscreen \
                || "$YABAI" -m window --grid 1:1:0:0:1:1
        fi
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
        "$YABAI" -m query --windows --window | grep -q '"has-fullscreen-zoom":[[:space:]]*true' && "$YABAI" -m window --toggle zoom-fullscreen
        "$YABAI" -m query --windows --window | grep -q '"is-floating":[[:space:]]*true' && "$YABAI" -m window --toggle float
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
    "focus_next")
        "$YABAI" -m window --focus next || "$YABAI" -m window --focus first
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
