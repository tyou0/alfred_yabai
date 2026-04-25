#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PRE_COMMIT_SOURCE="$SCRIPT_DIR/hooks/pre-commit"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: install-hooks.sh must be run from inside this git repository." >&2
    exit 1
fi

HOOKS_DIR=$(git rev-parse --git-path hooks)
PRE_COMMIT_TARGET="$HOOKS_DIR/pre-commit"

echo "Installing developer pre-commit hook..."
mkdir -p "$HOOKS_DIR"
ln -sf "$PRE_COMMIT_SOURCE" "$PRE_COMMIT_TARGET"
chmod +x "$PRE_COMMIT_SOURCE"

echo "✅ Pre-commit hook installed successfully!"
echo ""
echo "This script is for contributors working in this clone."
echo "It symlinks .git/hooks/pre-commit to the tracked hook in hooks/pre-commit"
echo "so future hook updates in the repo apply automatically."
echo ""
echo "The hook runs on every commit and checks:"
echo "  • ShellCheck for linting bash scripts"
echo "  • Bash syntax validation"
echo "  • Code formatting (tabs, trailing whitespace)"
echo "  • Required directives (shebang, set -euo pipefail)"
