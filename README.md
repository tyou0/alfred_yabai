# 🪟 Yabai Window Manager Pro

[![Version](https://img.shields.io/badge/version-1.1.1-blue.svg)](https://github.com/tyou0/alfred_yabai/releases/latest)
[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A premium, high-performance Alfred workflow for advanced window management on macOS, powered by the `yabai` tiling window manager.

---

## 📦 Download Latest
**[Download Yabai_Window_Manager_Pro.alfredworkflow](https://github.com/tyou0/alfred_yabai/releases/latest/download/Yabai_Window_Manager_Pro.alfredworkflow)**

---

## 🚀 Requirements & Setup

Before installing, ensure you have the following requirements met:

1.  **yabai**: Must be installed and running.
    ```bash
    brew install koekeishiya/formulae/yabai
    yabai --start-service
    ```
2.  **Accessibility**: Grant permissions in *System Settings > Privacy & Security > Accessibility* for both **yabai** and **Alfred**.
3.  **Scripting Addition**: (Optional but recommended) For full functionality, enable the yabai scripting addition.

---

## ⌨️ Pro Shortcuts (Hyper Key)
All shortcuts use the **Hyper Key** (`Cmd + Alt + Ctrl`).

### 🧱 Standard Layouts
| Action | Shortcut |
| :--- | :--- |
| **Left Half** | `Hyper + ←` |
| **Right Half** | `Hyper + →` |
| **Maximize** (Tgl) | `Hyper + ↑` |
| **Next Display** | `Hyper + ↓` |
| **Center Window** | `Hyper + C` |

### 📐 Precision Splits (Shift)
| Action | Shortcut |
| :--- | :--- |
| **Left Third** | `Hyper + Shift + 1` |
| **Center Third** | `Hyper + Shift + 2` |
| **Right Third** | `Hyper + Shift + 3` |
| **Center 2/3rds** | `Hyper + Shift + 4` |
| **Reset & Balance**| `Hyper + Shift + 5` |

### 🧭 Quarter Positioning
| Action | Shortcut |
| :--- | :--- |
| **Top Left** | `Hyper + U` |
| **Top Right** | `Hyper + I` |
| **Bottom Left** | `Hyper + J` |
| **Bottom Right** | `Hyper + K` |

---

## 🔍 Command Palette
Type `wm` in Alfred to trigger the fuzzy search command palette. 

- **Layouts**: Switch between `BSP`, `Stack`, and `Float`.
- **Toggles**: Enable `Sticky` or `Floating` states.
- **Transform**: Mirror (X/Y) or Rotate 90°.
- **Balanced Navigation**: Balance your current space or focus specific windows.

---

## 🛠️ Developer Guide
To create a new release:
1. Update version in `workflow/info.plist`.
2. Commit changes: `git add . && git commit -m "feat: new features"`.
3. Run release script: `./release.sh`.

---
*Created with ❤️ for macOS power users.*
