#!/bin/bash
# Sandbox/CI Build script for godot_empty template
# This script uses sandbox configuration with /app/ templates

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

echo "Building godot_empty for Web (Sandbox)..."

# Use sandbox export configuration
if [ -f "export_presets_sandbox.cfg" ]; then
    echo "Using sandbox export configuration..."
    cp export_presets_sandbox.cfg export_presets.cfg
else
    echo "Error: export_presets_sandbox.cfg not found"
    exit 1
fi

# Check if Godot is available
if ! command -v godot &> /dev/null
then
    echo "Error: Godot command not found"
    echo "Please install Godot 4.5+ or add it to your PATH"
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

# Export the project
echo "Exporting to dist/index.html..."
godot --headless --export-release "Web" dist/index.html

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "Output: dist/index.html"

    # Copy static assets for HTML loading screen
    echo "Copying static assets..."
    cp -f icon.svg dist/ 2>/dev/null || true

    # Clean up temporary export_presets.cfg
    if [ -f "export_presets.cfg" ]; then
        rm -f export_presets.cfg
        echo "Cleaned up temporary export_presets.cfg"
    fi
else
    echo "Build failed!"
    # Clean up temporary export_presets.cfg even on failure
    if [ -f "export_presets.cfg" ]; then
        rm -f export_presets.cfg
    fi
    exit 1
fi
