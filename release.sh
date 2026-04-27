#!/bin/bash
set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
WORKFLOW_INFO="$PROJECT_DIR/workflow/info.plist"
README_FILE="$PROJECT_DIR/README.md"
EXPORT_NAME="Yabai_Window_Manager_Pro.alfredworkflow"
EXPORT_PATH="$PROJECT_DIR/$EXPORT_NAME"
MAIN_BRANCH="${MAIN_BRANCH:-main}"
REMOTE="${RELEASE_REMOTE:-origin}"
BUMP_TYPE="patch"
REQUESTED_CLI=""

usage() {
    cat <<EOF
Usage: ./release.sh [--major|--minor|--patch] [gh|gmt]

Version bump:
  --patch    Bump 0.0.1 (default)
  --minor    Bump 0.1.0 and reset patch to 0
  --major    Bump 1.0.0 and reset minor/patch to 0

Release tool:
  gh|gmt     Force a release CLI

Environment:
  RELEASE_CLI=gh|gmt       Choose the release tool without an argument
  MAIN_BRANCH=main         Branch to merge into before tagging
  RELEASE_REMOTE=origin    Remote to push main and the tag to
EOF
}

parse_args() {
    local seen_bump=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --major|--minor|--patch)
                if [ -n "$seen_bump" ]; then
                    echo "❌ Error: Choose only one version bump flag." >&2
                    usage >&2
                    exit 1
                fi
                BUMP_TYPE="${1#--}"
                seen_bump="yes"
                ;;
            gh|gmt)
                if [ -n "$REQUESTED_CLI" ]; then
                    echo "❌ Error: Choose only one release CLI." >&2
                    usage >&2
                    exit 1
                fi
                REQUESTED_CLI="$1"
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                usage >&2
                exit 1
                ;;
        esac
        shift
    done
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

ensure_clean_worktree() {
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "❌ Error: Commit or stash tracked changes before releasing." >&2
        git status --short >&2
        exit 1
    fi
}

current_branch() {
    if ! git symbolic-ref --quiet --short HEAD; then
        echo "❌ Error: Releases must be run from a branch, not detached HEAD." >&2
        exit 1
    fi
}

sync_main_from_remote() {
    if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
        echo "⚠️  Remote '$REMOTE' not found; skipping remote sync."
        return
    fi

    echo "🔄 Syncing $MAIN_BRANCH from $REMOTE..."
    git fetch "$REMOTE" "$MAIN_BRANCH"

    if git rev-parse --verify "$REMOTE/$MAIN_BRANCH" >/dev/null 2>&1; then
        git merge --ff-only "$REMOTE/$MAIN_BRANCH"
    fi
}

read_version() {
    awk '
        /<key>version<\/key>/ {
            getline
            if ($0 ~ /<string>[0-9]+\.[0-9]+\.[0-9]+<\/string>/) {
                gsub(/.*<string>|<\/string>.*/, "")
                print
                exit
            }
        }
    ' "$WORKFLOW_INFO"
}

bump_version() {
    local version="$1"
    local major=""
    local minor=""
    local patch=""

    if [[ ! "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        echo "❌ Error: Unsupported version format '$version'. Expected MAJOR.MINOR.PATCH." >&2
        exit 1
    fi

    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    patch="${BASH_REMATCH[3]}"

    case "$BUMP_TYPE" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            echo "❌ Error: Unknown bump type '$BUMP_TYPE'." >&2
            exit 1
            ;;
    esac

    echo "$major.$minor.$patch"
}

update_version_files() {
    local old_version="$1"
    local new_version="$2"

    echo "📝 Bumping version $old_version -> $new_version..."
    OLD_VERSION="$old_version" NEW_VERSION="$new_version" perl -0pi -e '
        s{(<key>version</key>\s*<string>)\Q$ENV{OLD_VERSION}\E(</string>)}{$1$ENV{NEW_VERSION}$2};
        s{Yabai Window Manager Pro \(v\Q$ENV{OLD_VERSION}\E\)}{Yabai Window Manager Pro (v$ENV{NEW_VERSION})}g;
    ' "$WORKFLOW_INFO"

    if [ -f "$README_FILE" ]; then
        OLD_VERSION="$old_version" NEW_VERSION="$new_version" perl -0pi -e '
            s{version-\Q$ENV{OLD_VERSION}\E-blue}{version-$ENV{NEW_VERSION}-blue}g;
            s{Yabai Window Manager Pro \(v\Q$ENV{OLD_VERSION}\E\)}{Yabai Window Manager Pro (v$ENV{NEW_VERSION})}g;
        ' "$README_FILE"
    fi
}

commit_version_bump() {
    git add "$WORKFLOW_INFO"

    if [ -f "$README_FILE" ]; then
        git add "$README_FILE"
    fi

    if git diff --cached --quiet; then
        echo "❌ Error: Version bump did not change any tracked files." >&2
        exit 1
    fi

    git commit -m "chore: release $TAG"
}

ensure_tag_available() {
    if git rev-parse "$TAG" >/dev/null 2>&1; then
        echo "❌ Error: Tag $TAG already exists locally." >&2
        exit 1
    fi

    if git remote get-url "$REMOTE" >/dev/null 2>&1 && git ls-remote --exit-code --tags "$REMOTE" "refs/tags/$TAG" >/dev/null 2>&1; then
        echo "❌ Error: Tag $TAG already exists on $REMOTE." >&2
        exit 1
    fi
}

merge_release_branch_to_main() {
    local release_branch="$1"

    if [ "$release_branch" = "$MAIN_BRANCH" ]; then
        echo "✅ Already on $MAIN_BRANCH; release commit is on the target branch."
        return
    fi

    echo "🔀 Merging $release_branch into $MAIN_BRANCH..."
    git checkout "$MAIN_BRANCH"
    sync_main_from_remote
    git merge --no-edit "$release_branch"
}

push_main_and_tag() {
    if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
        echo "❌ Error: Remote '$REMOTE' not found. Cannot push $MAIN_BRANCH or $TAG." >&2
        exit 1
    fi

    echo "⬆️  Pushing $MAIN_BRANCH and $TAG to $REMOTE..."
    git push "$REMOTE" "$MAIN_BRANCH"
    git push "$REMOTE" "$TAG"
}

generate_release_notes() {
    local last_tag="$1"
    local changelog=""

    if [ -n "$last_tag" ]; then
        echo "📝 Generating changelog since $last_tag..."
        changelog=$(git log "$last_tag..$TAG" --pretty=format:"* %s")
        RELEASE_NOTES=$(printf "## Release %s\n\n### Changes since %s\n%s" "$TAG" "$last_tag" "$changelog")
    else
        echo "📝 Generating initial changelog..."
        changelog=$(git log "$TAG" --pretty=format:"* %s")
        RELEASE_NOTES=$(printf "## Release %s\n\n### Changes\n%s" "$TAG" "$changelog")
    fi

    if [ -z "$changelog" ]; then
        RELEASE_NOTES=$(printf "## Release %s\n\n### Changes\nMaintenance release." "$TAG")
    fi
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

parse_args "$@"

RELEASE_CLI=$(select_release_cli "$REQUESTED_CLI")
ensure_clean_worktree
RELEASE_BRANCH=$(current_branch)

if [ "$RELEASE_BRANCH" = "$MAIN_BRANCH" ]; then
    sync_main_from_remote
fi

VERSION=$(read_version)

if [ -z "$VERSION" ]; then
    echo "❌ Error: Could not find version in $WORKFLOW_INFO"
    exit 1
fi

NEXT_VERSION=$(bump_version "$VERSION")
TAG="v$NEXT_VERSION"
LAST_TAG=""
if LAST_TAG=$(git describe --tags --abbrev=0 --match "v[0-9]*" 2>/dev/null); then
    true
fi

ensure_tag_available

echo "🔖 Preparing release for $TAG with $RELEASE_CLI..."
update_version_files "$VERSION" "$NEXT_VERSION"
commit_version_bump
merge_release_branch_to_main "$RELEASE_BRANCH"

# Run deployment to get current artifact
if ! ./deploy.sh; then
    echo "❌ Deployment failed. Aborting release."
    exit 1
fi

echo "🏷️  Tagging $TAG..."
git tag "$TAG"
push_main_and_tag
generate_release_notes "$LAST_TAG"

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
