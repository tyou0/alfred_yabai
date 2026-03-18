#!/bin/bash
set -euo pipefail

# Ensure we have a proper PATH for Alfred
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Find yabai
YABAI=$(command -v yabai)
if [ -z "$YABAI" ]; then
  # Fallback to common locations
  if [ -x "/opt/homebrew/bin/yabai" ]; then
    YABAI="/opt/homebrew/bin/yabai"
  elif [ -x "/usr/local/bin/yabai" ]; then
    YABAI="/usr/local/bin/yabai"
  else
    echo "yabai not found. Please ensure it is installed via Homebrew."
    exit 1
  fi
fi

ACTION="$1"

case "$ACTION" in
  "left")
    $YABAI -m window --grid 1:2:0:0:1:1
    ;;
  "right")
    $YABAI -m window --grid 1:2:1:0:1:1
    ;;
  "maximize")
    # Toggle zoom-fullscreen (fill the workspace)
    $YABAI -m window --grid 1:1:0:0:1:1 || $YABAI -m window --toggle zoom-fullscreen
    ;;
  "center")
    $YABAI -m window --grid 4:4:1:1:2:2
    ;;
  "top_half")
    $YABAI -m window --grid 2:1:0:0:1:1
    ;;
  "bottom_half")
    $YABAI -m window --grid 2:1:0:1:1:1
    ;;
  "left_third")
    $YABAI -m window --grid 1:3:0:0:1:1
    ;;
  "center_third")
    $YABAI -m window --grid 1:3:1:0:1:1
    ;;
  "right_third")
    $YABAI -m window --grid 1:3:2:0:1:1
    ;;
  "left_two_thirds")
    $YABAI -m window --grid 1:3:0:0:2:1
    ;;
  "right_two_thirds")
    $YABAI -m window --grid 1:3:1:0:2:1
    ;;
  "center_two_thirds")
    $YABAI -m window --grid 6:6:1:0:4:6
    ;;
  "top_left")
    $YABAI -m window --grid 2:2:0:0:1:1
    ;;
  "top_right")
    $YABAI -m window --grid 2:2:1:0:1:1
    ;;
  "bottom_left")
    $YABAI -m window --grid 2:2:0:1:1:1
    ;;
  "bottom_right")
    $YABAI -m window --grid 2:2:1:1:1:1
    ;;
  "center_window")
    $YABAI -m window --grid 10:10:1:1:8:8
    ;;
  "reset_window")
    # Comprehensive reset: un-zoom, un-float, then balance
    $YABAI -m query --windows --window | grep -q '"is-zoom-fullscreen": true' && $YABAI -m window --toggle zoom-fullscreen
    $YABAI -m query --windows --window | grep -q '"is-floating": true' && $YABAI -m window --toggle float
    $YABAI -m space --balance
    ;;
  "next_screen")
    $YABAI -m window --display next || $YABAI -m window --display first
    $YABAI -m display --focus next || $YABAI -m display --focus first
    ;;
  "prev_screen")
    $YABAI -m window --display prev || $YABAI -m window --display last
    $YABAI -m display --focus prev || $YABAI -m display --focus last
    ;;
  "float")
    $YABAI -m window --toggle float
    ;;
  "sticky")
    $YABAI -m window --toggle sticky
    ;;
  "balance")
    $YABAI -m space --balance
    ;;
  "layout_bsp")
    $YABAI -m space --layout bsp
    ;;
  "layout_stack")
    $YABAI -m space --layout stack
    ;;
  "layout_float")
    $YABAI -m space --layout float
    ;;
  "mirror_x")
    $YABAI -m space --mirror x-axis
    ;;
  "mirror_y")
    $YABAI -m space --mirror y-axis
    ;;
  "rotate")
    $YABAI -m space --rotate 90
    ;;
  "focus_left")
    $YABAI -m window --focus west
    ;;
  "focus_right")
    $YABAI -m window --focus east
    ;;
  "focus_up")
    $YABAI -m window --focus north
    ;;
  "focus_down")
    $YABAI -m window --focus south
    ;;
  "swap_left")
    $YABAI -m window --swap west
    ;;
  "swap_right")
    $YABAI -m window --swap east
    ;;
  "swap_up")
    $YABAI -m window --swap north
    ;;
  "swap_down")
    $YABAI -m window --swap south
    ;;
  *) echo "Unknown action: $ACTION" >&2; exit 1 ;;
esac
