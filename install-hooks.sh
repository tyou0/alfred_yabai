#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR/.git/hooks"
PRE_COMMIT_HOOK="$SCRIPT_DIR/hooks/pre-commit"

echo "Installing pre-commit hook..."

# Create .git/hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Copy the pre-commit hook
cp "$PRE_COMMIT_HOOK" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"

echo "✅ Pre-commit hook installed successfully!"
echo ""
echo "The hook will now run on every commit to check:"
echo "  • ShellCheck for linting bash scripts"
echo "  • Bash syntax validation"
echo "  • Code formatting (tabs, trailing whitespace)"
echo "  • Required directives (shebang, set -euo pipefail)"
