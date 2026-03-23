#!/bin/bash
# Build script for godot_empty template (Windows local development)
# This script exports the Godot project to web format
#
# Usage:
#   ./tools/build_windows.sh          - Build using project.godot main_scene -> dist/index.html
#   ./tools/build_windows.sh <scene>  - Build scene (tests/<scene>.tscn) -> dist/<scene>.html
#
# For sandbox/CI builds, use the root build.sh instead.

# Get the project root directory (parent of tools/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Parse arguments
if [ -z "$1" ]; then
    SCENE_PATH=""
    OUTPUT_NAME="index"
else
    SCENE_NAME="$1"
    OUTPUT_NAME="${SCENE_NAME}"
    FOUND_FILE=$(find tests -name "${SCENE_NAME}.tscn" -type f 2>/dev/null | head -1)
    if [ -z "$FOUND_FILE" ] && [ -d "../tests" ]; then
        REPO_FOUND=$(find ../tests -name "${SCENE_NAME}.tscn" -type f 2>/dev/null | head -1)
        if [ -n "$REPO_FOUND" ]; then
            REPO_TEST_DIR=$(dirname "$REPO_FOUND")
            LOCAL_TEST_DIR="tests/$(basename "$REPO_TEST_DIR")"
            echo "Copying test scene from repo root: $REPO_TEST_DIR -> $LOCAL_TEST_DIR"
            mkdir -p "$LOCAL_TEST_DIR"
            cp -r "$REPO_TEST_DIR"/* "$LOCAL_TEST_DIR"/
            FOUND_FILE=$(find "$LOCAL_TEST_DIR" -name "${SCENE_NAME}.tscn" -type f 2>/dev/null | head -1)
        fi
    fi
    if [ -n "$FOUND_FILE" ]; then
        SCENE_PATH="res://${FOUND_FILE}"
    else
        echo "Error: ${SCENE_NAME}.tscn not found under tests/ or ../tests/"
        exit 1
    fi
fi

echo "========================================"
echo "godot_empty Web Build"
echo "========================================"
if [ -n "$SCENE_PATH" ]; then
    echo "Scene: ${SCENE_PATH} (override)"
else
    echo "Scene: (using project.godot main_scene)"
fi

# Check if Godot is available
if ! command -v godot &> /dev/null
then
    echo "Error: Godot command not found"
    echo "Please install Godot 4.5+ or add it to your PATH"
    echo "On Windows, you might need to use: godot.exe"
    exit 1
fi

# Pre-warm: let Godot scan project and build class_name cache
echo "Pre-warming Godot cache..."
godot --headless --import 2>/dev/null || true

# Create dist directory if it doesn't exist
if [ ! -d "dist" ]; then
    echo "Creating dist directory..."
    mkdir -p dist
fi

# Use Windows export configuration
if [ -f "export_presets_windows.cfg" ]; then
    echo "Using Windows export configuration..."
    cp export_presets_windows.cfg export_presets.cfg
else
    echo "Error: export_presets_windows.cfg not found"
    exit 1
fi

# Backup original project.godot
cp project.godot project.godot.bak

# Modify main_scene only if building a test scene (SCENE_PATH is set)
if [ -n "$SCENE_PATH" ]; then
    echo "Setting main scene to: ${SCENE_PATH}"
    sed -i.tmp "s|run/main_scene=.*|run/main_scene=\"${SCENE_PATH}\"|" project.godot
    rm -f project.godot.tmp
fi

# Export the project
OUTPUT_FILE="dist/${OUTPUT_NAME}.html"
echo "Exporting to ${OUTPUT_FILE}..."
godot --headless --export-release "Web" "${OUTPUT_FILE}"

BUILD_RESULT=$?

# Restore original project.godot
mv project.godot.bak project.godot

# Clean up temporary export_presets.cfg
if [ -f "export_presets.cfg" ]; then
    rm -f export_presets.cfg
    echo "Cleaned up temporary export_presets.cfg"
fi

if [ $BUILD_RESULT -eq 0 ]; then
    echo "========================================"
    echo "Build successful!"
    echo "Output: ${OUTPUT_FILE}"
    echo "========================================"

    # Copy static assets for HTML loading screen
    echo "Copying static assets..."
    cp -f icon.svg dist/ 2>/dev/null || true

    # List generated files
    echo ""
    echo "Generated files:"
    ls -lh dist/${OUTPUT_NAME}.* 2>/dev/null
else
    echo "========================================"
    echo "Build failed!"
    echo "========================================"
    exit 1
fi
