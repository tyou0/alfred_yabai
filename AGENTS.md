# AGENTS.md — Yabai Window Manager Pro

## Project Overview

Yabai Window Manager Pro is a bash-based Alfred workflow for macOS window management via the `yabai` tiling window manager. It provides a fuzzy-search UI in Alfred (via `wm.sh`) that dispatches window actions (resize, move, focus, layout) through `execute.sh`, which translates action names into `yabai -m` commands.

The project has no runtime dependencies beyond `bash`, `yabai`, and Alfred. JSON output for Alfred's Script Filter is built via string concatenation — no `jq` dependency.

## Build / Deploy / Release Commands

| Command | Purpose |
|---|---|
| `./deploy.sh` | Package `workflow/` into `Yabai_Window_Manager_Pro.alfredworkflow` zip |
| `./release.sh` | Deploy + create GitHub release with auto-generated changelog (requires `gh` CLI) |
| `./install-hooks.sh` | Install the pre-commit hook for linting and formatting checks |
| `bash -n workflow/execute.sh` | Syntax-check a script |
| `bash -n workflow/wm.sh` | Syntax-check the Alfred Script Filter |
| `shellcheck workflow/execute.sh` | Lint a shell script (install via `brew install shellcheck`) |
| `bash workflow/execute.sh left` | Manual test — invoke an action directly |

## Pre-Commit Hooks

The project includes a pre-commit hook that automatically runs linting and formatting checks before allowing commits. This helps maintain code quality and consistency.

### Installation

Run the installation script once per clone:
```bash
./install-hooks.sh
```

The hook will be installed to `.git/hooks/pre-commit` and will run automatically on every commit.

### Checks Performed

The pre-commit hook verifies the following for all staged `.sh` files:

1. **ShellCheck**: Runs `shellcheck` if available (install via `brew install shellcheck`)
2. **Bash Syntax**: Validates syntax with `bash -n`
3. **Shebang**: Ensures `#!/bin/bash` shebang is present
4. **Safety Mode**: Verifies `set -euo pipefail` is present
5. **Tabs**: Checks for tabs (requires 4-space indentation)
6. **Trailing Whitespace**: Detects trailing whitespace on lines

If any check fails, the commit will be blocked until the issues are resolved.

### Skipping the Hook

If you need to bypass the pre-commit checks temporarily:
```bash
git commit --no-verify -m "your message"
```

Use sparingly and only when absolutely necessary.

## Code Style Guidelines

### General

- `#!/bin/bash` shebang on every script.
- All scripts use `set -euo pipefail` for safety — do not remove or weaken this.
- Use `SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"` for dynamic path resolution. Never hardcode absolute paths like `/Users/tyou/...`.
- Prefer direct command testing (`if ./deploy.sh; then`) over `$?` checks.

### Naming

- `snake_case` for action names and variables (e.g., `left_third`, `top_half`, `SCRIPT_DIR`).
- `UPPER_SNAKE_CASE` for constants (e.g., `YABAI`, `PROJECT_DIR`, `EXPORT_NAME`).

### Formatting

- 4-space indentation inside `case` statement arms.
- Fallback commands use the pipe pattern: `$YABAI -m window --display next || $YABAI -m window --display first`.
- JSON output built with string concatenation via `echo` — no jq. In `wm.sh`, use `printf '%q'` for safe escaping.

### Error Handling

- Every `case` statement must include a default arm that errors on unknown actions:
  ```bash
  *) echo "Unknown action: $ACTION" >&2; exit 1 ;;
  ```
- Use `set -euo pipefail` so failures in pipelines and unset variables are caught.

### Commits & Versioning

- Commit messages: conventional style with `feat:`, `fix:`, `chore:`, `docs:` prefix.
- Git tags: `v` prefix semantic versioning (e.g., `v1.1.0`, `v1.1.1`).

## File Map

| File | Role |
|---|---|
| `workflow/execute.sh` | Core dispatcher — maps action names to `yabai -m` commands (case statement with 28+ actions) |
| `workflow/wm.sh` | Alfred Script Filter — outputs JSON array of commands for Alfred's fuzzy search UI |
| `workflow/info.plist` | Alfred workflow definition (XML) — hotkeys, connections, bundle ID |
| `workflow/icon.png` | Workflow icon (raster) |
| `workflow/icon.svg` | Workflow icon (vector) |
| `deploy.sh` | Build packaging — zips `workflow/` into `.alfredworkflow` |
| `release.sh` | GitHub release automation — requires `gh` CLI |
| `install-hooks.sh` | Pre-commit hook installation script |
| `hooks/pre-commit` | Pre-commit hook definition for linting and formatting |
| `AGENTS.md` | This file — guidance for agentic coding tools |

## Naming Conventions

### Action Strings

All action strings are `lowercase_snake_case`. Examples: `left_third`, `top_half`, `layout_bsp`, `mirror_x`, `focus_next`.

Action strings must match exactly between:
- `execute.sh` case arms (the pattern in each `action_name)` line)
- `wm.sh` options array (the strings passed as action identifiers)

If you add a new action, update both files. Mismatched strings will cause Alfred to display commands that silently fail or error.

### Constants

Use `UPPER_SNAKE_CASE` for constants defined at the top of scripts:
```bash
YABAI="/usr/local/bin/yabai"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXPORT_NAME="Yabai_Window_Manager_Pro.alfredworkflow"
```

### Hotkey UIDs (info.plist)

Hotkey UIDs in `info.plist` use the `HK_` prefix + `UPPER_SNAKE_CASE`: `HK_LEFT`, `HK_TOP_LEFT`, `HK_MAXIMIZE`, etc.

### Script Files

All script files use lowercase names with `.sh` extension.

## Constraints & Gotchas

### macOS Only

This project requires macOS, the yabai tiling window manager, and Accessibility permissions. There is no cross-platform support.

### Dynamic Paths

Always resolve paths dynamically. Use `SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"` — do NOT hardcode `/Users/tyou/src/alfred_yabai` or any user-specific path.

### No jq Dependency

JSON for Alfred's Script Filter is built via string concatenation in `wm.sh`. Do not introduce `jq` as a dependency. Use `printf '%q'` for safe shell escaping of strings embedded in JSON.

### Action String Contract

Every action defined in `execute.sh` must have a corresponding entry in `wm.sh`'s options array, and vice versa. When adding or renaming actions, verify both files stay in sync.

### Default Error Case

The default arm in `execute.sh`'s case statement (`*) echo "Unknown action: $ACTION" >&2; exit 1 ;;`) must be preserved. This ensures unknown actions produce a clear error instead of silent failure.

### Shell Style

All conditionals use direct command testing rather than `$?`:
```bash
# Correct
if ./deploy.sh; then
    echo "Deployed"
fi

# Avoid
./deploy.sh
if [ $? -eq 0 ]; then
    echo "Deployed"
fi
```

## Testing

There is no automated test framework. Testing is manual:

1. **Syntax checking**: `bash -n workflow/execute.sh` and `bash -n workflow/wm.sh`
2. **Linting**: `shellcheck workflow/execute.sh` (install via `brew install shellcheck`)
3. **Manual invocation**: `bash workflow/execute.sh <action>` — e.g., `bash workflow/execute.sh left`
4. **Alfred integration**: Install the `.alfredworkflow` and test via Alfred's UI

When adding new actions, test at minimum:
- Syntax check passes (`bash -n`)
- Shellcheck passes
- Manual invocation produces expected yabai behavior or a clear error message
