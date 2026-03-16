#!/bin/bash

# Define variables
PROJECT_DIR="/Users/tyou/src/alfred_yabai"
WORKFLOW_DIR="$PROJECT_DIR/workflow"
EXPORT_NAME="Yabai_Window_Manager_Pro.alfredworkflow"
EXPORT_PATH="$PROJECT_DIR/$EXPORT_NAME"

echo "🚀 Starting deployment of Alfred Yabai Workflow..."

# Navigate to workflow directory
cd "$WORKFLOW_DIR" || exit

# Remove previous build if exists
if [ -f "$EXPORT_PATH" ]; then
    rm "$EXPORT_PATH"
    echo "🧹 Cleaned up old build."
fi

# Clean up macOS metadata files
find . -name ".DS_Store" -delete

# Zip the contents
# -r: recursive
# -q: quiet
echo "📦 Packaging workflow..."
zip -rq "$EXPORT_PATH" . -x "*.DS_Store" "task.md" "implementation_plan.md" "walkthrough.md"

if [ $? -eq 0 ]; then
    echo "✅ Success! Workflow created at:"
    echo "   $EXPORT_PATH"
    echo "👉 Double-click that file to import into Alfred."
else
    echo "❌ Error: Failed to create workflow file."
    exit 1
fi
