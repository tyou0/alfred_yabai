# 🪟 Yabai Window Manager Pro

[![Version](https://img.shields.io/badge/version-1.1.3-blue.svg)](https://github.com/tyou0/alfred_yabai/releases/latest)
[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A premium, high-performance Alfred workflow for advanced window management on macOS, powered by the `yabai` tiling window manager.

---

## 📦 Download Latest
**[Download Yabai_Window_Manager_Pro.alfredworkflow](https://github.com/tyou0/alfred_yabai/releases/latest/download/Yabai_Window_Manager_Pro.alfredworkflow)**

---

## 🚀 Requirements & Setup

On a new Mac, the fastest path is:

```bash
./install.sh
```

That script installs or reuses `yabai`, starts or restarts the service, builds `Yabai_Window_Manager_Pro.alfredworkflow`, and opens it for Alfred import. It also opens the macOS Accessibility pane when `yabai` still needs permission.

Importing the Alfred workflow by itself is not enough. The workflow only sends commands to a running `yabai` service; macOS permissions still need a manual approval step.

1.  **Install yabai**:
    ```bash
    brew install yabai
    ```
2.  **Start the yabai service**:
    ```bash
    yabai --start-service
    ```
3.  **Grant Accessibility permissions**:
    Open *System Settings > Privacy & Security > Accessibility* and enable:
    - **yabai** (`/opt/homebrew/bin/yabai` or `/usr/local/bin/yabai`)
    - **Alfred**
    - Your terminal app, if you want to test `yabai` commands from Terminal/iTerm
4.  **Restart and verify yabai**:
    ```bash
    yabai --restart-service
    yabai -m query --spaces
    ```

The final command must print JSON. If it prints `failed to connect to socket` or `could not access accessibility features`, the Alfred workflow will not be able to move windows yet.

### Troubleshooting New Macs

If `yabai -m query --spaces` fails:

- Re-open *System Settings > Privacy & Security > Accessibility*, remove `yabai` if it is already listed, add it again, and enable it.
- Restart the service:
  ```bash
  yabai --restart-service
  ```
- Check the service log:
  ```bash
  tail -80 /tmp/yabai_$USER.err.log
  ```
- Confirm Alfred also has Accessibility permission. Hotkeys launched by Alfred need Alfred permission as well as yabai permission.

The `wm` command palette now shows a setup warning when `yabai` is missing or not accepting commands. Hotkey actions also show a macOS notification with the underlying `yabai` error.

### Scripting Addition

The yabai scripting addition is optional for this workflow. Some advanced yabai features need it, but the basic grid, focus, layout, and display commands should work once the service and Accessibility permissions are correct.

---

## ⌨️ Pro Shortcuts (Hyper Key)
All shortcuts use the **Hyper Key** (`Cmd + Alt + Ctrl`).

### 🧱 Standard Layouts
| Action | Shortcut |
| :--- | :--- |
| **Left Half** | `Hyper + ←` |
| **Right Half** | `Hyper + →` |
| **Prev Display** | `Hyper + ↑` |
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
For contributor setup in a local clone:

```bash
./install-hooks.sh
```

Or combine end-user and contributor setup in one pass:

```bash
./install.sh --dev
```

`install-hooks.sh` is developer-only. It installs the repo's `hooks/pre-commit` file into `.git/hooks/pre-commit` as a symlink, so local commits run the shell checks from the tracked hook and pick up future hook updates automatically.

To create a new release:
1. Commit your feature or fix changes on a branch.
2. Run `./release.sh` for a patch release, `./release.sh --minor`, or `./release.sh --major`.
3. The script bumps the version, commits it, merges the release branch into `main`, tags it, pushes `main` and the tag, builds the workflow, and creates the GitHub release.

`release.sh` uses `gh` when available, then falls back to `gmt`. You can force either tool with `./release.sh gh`, `./release.sh gmt`, or `RELEASE_CLI=gmt ./release.sh`. The `gh` path uploads the `.alfredworkflow` asset automatically; the `gmt` path creates release notes only because current `gmt release create` does not expose asset upload. Release notes include the commit subjects since the previous `v*` version tag.

---
*Created with ❤️ for macOS power users.*
