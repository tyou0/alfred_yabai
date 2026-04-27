#!/bin/bash
set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
WORKFLOW_INFO="$PROJECT_DIR/workflow/info.plist"
EXPORT_NAME="Yabai_Window_Manager_Pro.alfredworkflow"
EXPORT_PATH="$PROJECT_DIR/$EXPORT_NAME"

usage() {
    echo "Usage: ./release.sh [gh|gmt]"
    echo "Set RELEASE_CLI=gh or RELEASE_CLI=gmt to choose the release tool without an argument."
}

select_release_cli() {
    local requested_cli="${1:-${RELEASE_CLI:-}}"

    if [ -n "$requested_cli" ]; then
        case "$requested_cli" in
            gh|gmt)
                if command -v "$requested_cli" &> /dev/null; then
                    echo "$requested_cli"
                    return
                fi

                echo "❌ Error: Requested release CLI '$requested_cli' is not installed." >&2
                exit 1
                ;;
            *)
                usage >&2
                exit 1
                ;;
        esac
    fi

    if command -v gh &> /dev/null; then
        echo "gh"
        return
    fi

    if command -v gmt &> /dev/null; then
        echo "gmt"
        return
    fi

    echo "❌ Error: Neither GitHub CLI (gh) nor gmt is installed." >&2
    echo "Install gh with 'brew install gh' and authenticate with 'gh auth login'," >&2
    echo "or install/authenticate gmt and run './release.sh gmt'." >&2
    exit 1
}

create_release_with_gh() {
    echo "🚀 Creating GitHub release $TAG with gh..."
    if gh release create "$TAG" "$EXPORT_PATH" \
        --title "Release $TAG" \
        --notes "$RELEASE_NOTES" \
        --latest; then
        echo "✅ Success! Release $TAG is live."
        echo "🔗 View it at: $(gh release view "$TAG" --json url --template '{{.url}}' 2>/dev/null || echo "GitHub")"
    else
        echo "❌ Error: Failed to create GitHub release with gh."
        exit 1
    fi
}

create_release_with_gmt() {
    if ! git rev-parse "$TAG" &> /dev/null; then
        echo "❌ Error: gmt requires tag $TAG to already exist."
        echo "Create and push the tag first:"
        echo "   git tag $TAG"
        echo "   git push origin $TAG"
        exit 1
    fi

    echo "⚠️  gmt release create does not currently expose asset upload."
    echo "   Creating the release notes only; attach $EXPORT_NAME manually if needed."
    echo "🚀 Creating GitHub release $TAG with gmt..."
    if gmt release create "$TAG" \
        --title "Release $TAG" \
        --notes "$RELEASE_NOTES"; then
        echo "✅ Success! Release $TAG is live."
        echo "🔗 View it with: gmt release view $TAG"
    else
        echo "❌ Error: Failed to create GitHub release with gmt."
        exit 1
    fi
}

if [ "$#" -gt 1 ]; then
    usage >&2
    exit 1
fi

RELEASE_CLI=$(select_release_cli "${1:-}")

# Extract version from info.plist
VERSION=$(grep -A 1 "<key>version</key>" "$WORKFLOW_INFO" | grep "<string>" | sed -E 's/.*<string>(.*)<\/string>.*/\1/')

if [ -z "$VERSION" ]; then
    echo "❌ Error: Could not find version in $WORKFLOW_INFO"
    exit 1
fi

TAG="v$VERSION"
echo "🔖 Preparing release for $TAG with $RELEASE_CLI..."

# Run deployment to get current artifact
if ! ./deploy.sh; then
    echo "❌ Deployment failed. Aborting release."
    exit 1
fi

# Check if tag already exists locally
if git rev-parse "$TAG" &>/dev/null; then
    echo "⚠️ Warning: Tag $TAG already exists locally."
    # We continue, gh might handle it, or user might be re-releasing
fi

# Generate changelog from last tag
LAST_TAG=""
if LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null); then
    true
fi

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

RELEASE_NOTES=$(printf "## Release %s\n\n### Changes\n%s" "$TAG" "$CHANGELOG")

printf "\n--- Release Notes ---\n%s\n----------------------\n\n" "$RELEASE_NOTES"

# Create release
case "$RELEASE_CLI" in
    gh)
        create_release_with_gh
        ;;
    gmt)
        create_release_with_gmt
        ;;
    *)
        echo "Unknown release CLI: $RELEASE_CLI" >&2
        exit 1
        ;;
esac
