#!/usr/bin/env bash
# .devcontainer/install-toolings.sh
# Executes tooling-specific devcontainer installation scripts in sorted order
#
# IMPORTANT: This script runs during Docker image build (see devc.Dockerfile)
# - Toolings are installed at build time, not runtime
# - Works with both VS Code devcontainer and manual `make devc.up`
# - To reinstall toolings, rebuild the image with `make devc.rebuild`

set -euo pipefail

# Allow TOOLING_DIR to be overridden via environment variable
# During Docker build: TOOLING_DIR=/tmp/tooling (set in Dockerfile)
# At runtime: defaults to /workspace/tooling
TOOLING_DIR="${TOOLING_DIR:-/workspace/tooling}"

echo "======================================================================"
echo "Installing tooling extensions..."
echo "======================================================================"
echo ""
echo "Looking for toolings in: $TOOLING_DIR"
echo ""

# Find all tooling install scripts (sorted by directory name)
if [ ! -d "$TOOLING_DIR" ]; then
    echo "No tooling directory found at $TOOLING_DIR"
    echo "Skipping tooling installation."
    exit 0
fi

INSTALL_SCRIPTS=$(find "$TOOLING_DIR" -mindepth 1 -maxdepth 1 -type d | sort | while read -r tooling_path; do
    tooling_name=$(basename "$tooling_path")
    install_script="$tooling_path/devcontainer/install.sh"
    if [ -f "$install_script" ]; then
        echo "$install_script"
    fi
done)

if [ -z "$INSTALL_SCRIPTS" ]; then
    echo "No tooling installation scripts found."
    echo "Toolings can provide devcontainer/install.sh for custom setup."
    echo ""
    exit 0
fi

# Execute each install script in order
while IFS= read -r script; do
    tooling_name=$(basename $(dirname $(dirname "$script")))
    echo "→ Installing tooling: $tooling_name"
    echo "  Script: $script"
    
    # Make script executable if not already
    chmod +x "$script"
    
    # Execute the install script
    if bash "$script"; then
        echo "  ✓ $tooling_name installed successfully"
    else
        exit_code=$?
        echo "  ✗ $tooling_name installation failed (exit code: $exit_code)"
        echo ""
        echo "Build aborted due to tooling installation failure."
        exit 1
    fi
    echo ""
done <<< "$INSTALL_SCRIPTS"

echo "======================================================================"
echo "✓ All tooling extensions installed successfully"
echo "======================================================================"
echo "✓ All tooling extensions installed"
echo "======================================================================"
