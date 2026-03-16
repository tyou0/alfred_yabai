import json

# Define the hotkeys and their configuration
# (arg, title, note, keycode, modifiers, uid, colorindex, ypos_offset)
hotkeys = [
    # Basic Position (Green)
    ("left", "Left Half", "Horizontal: Left Half", 123, 1835008, "HK_LEFT", 4, 0),
    ("right", "Right Half", "Horizontal: Right Half", 124, 1835008, "HK_RIGHT", 4, 1),
    ("top_half", "Top Half", "Vertical: Top Half", 126, 1835008, "HK_TOP_HALF", 4, 2),
    ("bottom_half", "Bottom Half", "Vertical: Bottom Half", 125, 1835008, "HK_BOTTOM_HALF", 4, 3),
    
    # Thirds (Green)
    ("left_third", "Left Third", "Horizontal: Left Third", 18, 1835008, "HK_LEFT_3RD", 4, 4),
    ("center_third", "Center Third", "Horizontal: Center Third", 19, 1835008, "HK_CENTER_3RD", 4, 5),
    ("right_third", "Right Third", "Horizontal: Right Third", 20, 1835008, "HK_RIGHT_3RD", 4, 6),
    ("center_two_thirds", "Center 2/3rds", "Horizontal: Center 2/3rds", 21, 1835008, "HK_CENTER_2_3RDS", 4, 7),
    
    # Screen & Quarters (Blue)
    ("next_screen", "Next Display", "Screen: Next Display", 124, 1966080, "HK_NEXT", 6, 8),
    ("prev_screen", "Prev Display", "Screen: Previous Display", 123, 1966080, "HK_PREV", 6, 9),
    ("top_left", "Top Left Quarter", "Quarter: Top Left", 32, 1835008, "HK_TOP_LEFT", 6, 10),
    ("top_right", "Top Right Quarter", "Quarter: Top Right", 34, 1835008, "HK_TOP_RIGHT", 6, 11),
    ("bottom_left", "Bottom Left Quarter", "Quarter: Bottom Left", 38, 1835008, "HK_BOTTOM_LEFT", 6, 12),
    ("bottom_right", "Bottom Right Quarter", "Quarter: Bottom Right", 40, 1835008, "HK_BOTTOM_RIGHT", 6, 13),
    
    # Window State (Yellow)
    ("maximize", "Maximize", "Window: Maximize", 126, 1310720, "HK_MAXIMIZE", 3, 14), # Option + Up
    ("center_window", "Center Window", "Window: Center", 8, 1835008, "HK_CENTER_WIN", 3, 15), # C key
    ("float", "Toggle Float", "Window: Toggle Float", 3, 1835008, "HK_FLOAT", 3, 16), # F key
    ("sticky", "Toggle Sticky", "Window: Toggle Sticky", 1, 1835008, "HK_STICKY", 3, 17), # S key
    
    # Control Actions (Orange)
    ("reset_window", "Reset Balance", "Window: Reset/Balance", 23, 1835008, "HK_RESET", 2, 18),
    ("balance", "Balance Space", "Space: Balance", 11, 1835008, "HK_BALANCE", 2, 19), # B key
    ("rotate", "Rotate 90", "Space: Rotate", 15, 1835008, "HK_ROTATE", 2, 20), # R key
    ("layout_bsp", "Layout: BSP", "Layout: BSP", 18, 1048576, "HK_LAYOUT_BSP", 2, 21), # Cmd+1 (wait, using hyper for these is better)
]

# (Simplified hotkeys for demonstration - I'll actually just write the final content using tools)
