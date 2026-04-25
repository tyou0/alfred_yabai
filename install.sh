#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
EXPORT_NAME="Yabai_Window_Manager_Pro.alfredworkflow"
EXPORT_PATH="$PROJECT_DIR/$EXPORT_NAME"
ACCESSIBILITY_URL="x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

log() {
    echo "==> $1"
}

warn() {
    echo "Warning: $1" >&2
}

fail() {
    echo "Error: $1" >&2
    exit 1
}

ensure_macos() {
    if [ "$(uname -s)" != "Darwin" ]; then
        fail "This installer only supports macOS."
    fi
}

ensure_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        fail "Homebrew is required. Install it first from https://brew.sh/"
    fi
}

install_yabai_if_needed() {
    if brew list --versions yabai >/dev/null 2>&1; then
        log "yabai is already installed."
        return
    fi

    log "Installing yabai with Homebrew..."
    brew install yabai
}

start_yabai_service() {
    local yabai_bin

    yabai_bin=$(command -v yabai || true)
    if [ -z "$yabai_bin" ]; then
        fail "yabai was not found after installation."
    fi

    if "$yabai_bin" --start-service >/dev/null 2>&1; then
        log "Started the yabai service."
        return
    fi

    if "$yabai_bin" --restart-service >/dev/null 2>&1; then
        log "Restarted the yabai service."
        return
    fi

    warn "Could not start the yabai service automatically."
}

check_yabai_readiness() {
    local yabai_bin
    local yabai_status

    yabai_bin=$(command -v yabai || true)
    if [ -z "$yabai_bin" ]; then
        return
    fi

    if yabai_status=$("$yabai_bin" -m query --spaces 2>&1 >/dev/null); then
        log "yabai is accepting commands."
        return
    fi

    warn "yabai is installed but not ready yet."
    warn "$yabai_status"

    if command -v open >/dev/null 2>&1; then
        open "$ACCESSIBILITY_URL" >/dev/null 2>&1 || true
    fi

    cat <<EOF

Grant Accessibility access to:
- yabai
- Alfred
- your terminal app if you plan to test commands manually

Then run:
    yabai --restart-service
    yabai -m query --spaces
EOF
}

build_workflow() {
    log "Packaging the Alfred workflow..."
    "$PROJECT_DIR/deploy.sh"
}

import_workflow() {
    if [ ! -f "$EXPORT_PATH" ]; then
        fail "Expected workflow artifact at $EXPORT_PATH"
    fi

    if ! command -v open >/dev/null 2>&1; then
        warn "Could not find the macOS 'open' command to import the workflow automatically."
        return
    fi

    log "Opening the Alfred workflow for import..."
    if ! open "$EXPORT_PATH"; then
        warn "Could not open the workflow automatically. Import $EXPORT_PATH in Alfred manually."
    fi
}

install_dev_hooks() {
    log "Installing git hooks for this clone..."
    "$PROJECT_DIR/install-hooks.sh"
}

main() {
    local install_dev_hooks_flag=0

    while [ $# -gt 0 ]; do
        case "$1" in
            --dev)
                install_dev_hooks_flag=1
                ;;
            *)
                fail "Unknown option: $1"
                ;;
        esac
        shift
    done

    ensure_macos
    ensure_homebrew
    install_yabai_if_needed
    start_yabai_service
    check_yabai_readiness
    build_workflow
    import_workflow

    if [ "$install_dev_hooks_flag" -eq 1 ]; then
        install_dev_hooks
    fi

    cat <<EOF

Installation flow complete.

What happened:
- yabai was installed or reused
- the yabai service was started or restarted when possible
- the Alfred workflow was packaged and opened for import

If macOS blocked yabai, finish the Accessibility step above and then run:
    yabai --restart-service
    yabai -m query --spaces
EOF
}

main "$@"
