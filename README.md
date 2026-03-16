# Yabai Window Manager Pro (Alfred Workflow)

![Yabai Logo](./workflow/icon.png)

A high-performance, color-coded Alfred workflow for advanced window management on macOS using `yabai`.

## 🚀 Installation & Requirement

1.  **yabai**: Must be installed and running (`brew install koekeishiya/formulae/yabai`).
2.  **Permissions**: Ensure `yabai` and `Alfred` have **Accessibility** permissions in *System Settings > Privacy & Security > Accessibility*.
3.  **Import**: Double-click [Yabai_Window_Manager_Pro.alfredworkflow](./Yabai_Window_Manager_Pro.alfredworkflow) to install.

## ⌨️ Hotkey Overview

All shortcuts use the **Hyper Key** combination (`Cmd + Alt + Ctrl` and optionally `Shift`).

### Quarters (4 Corners)
- ↖️ `Hyper + U`: Top-Left Quarter
- ↗️ `Hyper + I`: Top-Right Quarter
- ↙️ `Hyper + J`: Bottom-Left Quarter
- ↘️ `Hyper + K`: Bottom-Right Quarter

### Standard Layouts
- ⬅️ `Hyper + Left`: Left Half
- ➡️ `Hyper + Right`: Right Half
- ⬆️ `Hyper + Up`: Maximize Window (Smart Toggle)
- ⬇️ `Hyper + Down`: Move to Next Display

### Advanced Splits (Hyper + Shift)
- `1`: Left Third
- `2`: Center Third
- `3`: Right Third
- `4`: Center 2/3rds
- `5`: **Smart Reset** (Un-maximize, Un-float, and Balance)

## 🔍 Search & Command Palette
Type `wm` in Alfred to access the full command palette with fuzzy search. This includes advanced space transformations:
- **Space Layouts**: 🧱 BSP, 📚 Stack, 🎈 Float.
- **Transform**: 🪞 Mirror (X/Y), 🔄 Rotate 90°.
- **Navigation**: Focus & Swap windows in any direction.

## 🎨 Visual Guide (Alfred Editor)
The workflow blocks are color-coded for easy maintenance:
- 🟢 **Green**: Horizontal/Vertical Splits (Halves, Thirds).
- 🔵 **Blue**: Display Navigation & Quarters.
- 🟡 **Yellow**: Window State (Floating, Sticky, Centering).
- 🟠 **Orange**: Control Actions (Maximize, Reset, Layouts).

---
*Powered by Yabai. Rebranded with the official logo.*
