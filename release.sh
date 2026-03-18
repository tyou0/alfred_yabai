#!/bin/bash
set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
WORKFLOW_INFO="$PROJECT_DIR/workflow/info.plist"
EXPORT_NAME="Yabai_Window_Manager_Pro.alfredworkflow"
EXPORT_PATH="$PROJECT_DIR/$EXPORT_NAME"

# Check for gh (GitHub CLI)
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) is not installed."
    echo "Please install it via 'brew install gh' and authenticate with 'gh auth login'."
    exit 1
fi

# Extract version from info.plist
VERSION=$(grep -A 1 "<key>version</key>" "$WORKFLOW_INFO" | grep "<string>" | sed -E 's/.*<string>(.*)<\/string>.*/\1/')

if [ -z "$VERSION" ]; then
    echo "❌ Error: Could not find version in $WORKFLOW_INFO"
    exit 1
fi

TAG="v$VERSION"
echo "🔖 Preparing release for $TAG..."

# Run deployment to get current artifact
if ! ./deploy.sh; then
    echo "❌ Deployment failed. Aborting release."
    exit 1
fi

# Check if tag already exists locally or remotely
if git rev-parse "$TAG" &>/dev/null; then
    echo "⚠️ Warning: Tag $TAG already exists locally."
    # We continue, gh might handle it, or user might be re-releasing
fi

# Generate changelog from last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)
if [ -n "$LAST_TAG" ]; then
    echo "📝 Generating changelog since $LAST_TAG..."
    CHANGELOG=$(git log "$LAST_TAG..HEAD" --oneline --pretty=format:"* %s")
else
    echo "📝 Generating initial changelog..."
    CHANGELOG=$(git log --oneline --pretty=format:"* %s")
fi

if [ -z "$CHANGELOG" ]; then
    CHANGELOG="Maintenance release."
fi

RELEASE_NOTES="## Release $TAG\n\n### Changes\n$CHANGELOG"

echo -e "\n--- Release Notes ---\n$RELEASE_NOTES\n----------------------\n"

# Create release
echo "🚀 Creating GitHub release $TAG..."
if gh release create "$TAG" "$EXPORT_PATH" \
    --title "Release $TAG" \
    --notes "$(echo -e "$RELEASE_NOTES")" \
    --latest; then
    echo "✅ Success! Release $TAG is live."
    echo "🔗 View it at: $(gh release view "$TAG" --web 2>/dev/null || echo "GitHub")"
else
    echo "❌ Error: Failed to create GitHub release."
    exit 1
fi
