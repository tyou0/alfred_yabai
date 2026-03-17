#!/bin/bash

# Define the options
declare -a options=(
  "HEADER|--- RATIOS ---|Horizontal and Vertical screen splits"
  "Maximize|maximize|Maximize focused window (fill screen)"
  "Center|center|Center focused window"
  "Left Half|left|Move to left half"
  "Right Half|right|Move to right half"
  "Top Half|top_half|Move to top half"
  "Bottom Half|bottom_half|Move to bottom half"
  "Left Third|left_third|Move to left third"
  "Center Third|center_third|Move to center third"
  "Right Third|right_third|Move to right third"
  "Left Two Thirds|left_two_thirds|Move window to left 2/3"
  "Right Two Thirds|right_two_thirds|Move window to right 2/3"
  "Center Two Thirds|center_two_thirds|Move to center two thirds"
  "HEADER|--- QUARTERS ---|Corner window positioning"
  "Top-Left Quarter|top_left|Move to top-left quarter"
  "Top-Right Quarter|top_right|Move to top-right quarter"
  "Bottom-Left Quarter|bottom_left|Move to bottom-left quarter"
  "Bottom-Right Quarter|bottom_right|Move to bottom-right quarter"
  "HEADER|--- NAVIGATION ---|Focus and Screen control"
  "Focus Left|focus_left|Change focus to the left"
  "Focus Right|focus_right|Change focus to the right"
  "Focus Up|focus_up|Change focus upwards"
  "Focus Down|focus_down|Change focus downwards"
  "Swap Left|swap_left|Swap window with the one on the left"
  "Swap Right|swap_right|Swap window with the one on the right"
  "Swap Up|swap_up|Swap window with the one above"
  "Swap Down|swap_down|Swap window with the one below"
  "Next Display|next_screen|Move to next display"
  "Prev Display|prev_screen|Move to previous display"
  "HEADER|--- WINDOW STATE ---|Toggles and adjustments"
  "Toggle Float|float|Toggle float for window"
  "Toggle Sticky|sticky|Toggle sticky (stays on all spaces)"
  "Balance Windows|balance|Balance windows in space"
  "HEADER|--- SPACES & LAYOUT ---|Global space management"
  "Layout: BSP|layout_bsp|Set space layout to BSP"
  "Layout: Stack|layout_stack|Set space layout to Stack"
  "Layout: Float|layout_float|Set space layout to Float"
  "Mirror: X-Axis|mirror_x|Mirror space horizontally"
  "Mirror: Y-Axis|mirror_y|Mirror space vertically"
  "Rotate 90|rotate|Rotate window tree 90 degrees"
)

echo '{"items": ['
first=true
for opt in "${options[@]}"; do
  IFS='|' read -r title arg subtitle <<< "$opt"
  if [ "$first" = false ]; then echo ','; fi
  echo '{'
  if [[ "$title" == "HEADER" ]]; then
    echo "  \"title\": \"$arg\","
    echo "  \"subtitle\": \"$subtitle\","
    echo "  \"valid\": false,"
    echo "  \"icon\": { \"path\": \"icon.png\" }"
  else
    echo "  \"title\": \"$title\","
    echo "  \"subtitle\": \"$subtitle\","
    echo "  \"arg\": \"$arg\","
    echo "  \"autocomplete\": \"$title\","
    echo "  \"icon\": { \"path\": \"icon.png\" }"
  fi
  echo '}'
  first=false
done
echo ']}'
