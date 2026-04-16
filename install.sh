#!/usr/bin/env bash
# Bootstrap script to initialize repo-base in an existing repository
# Usage: curl -fsSL https://raw.githubusercontent.com/doublecheck-it/repo-base/main/install.sh | bash

set -euo pipefail

REPO_BASE_URL="${REPO_BASE_URL:-https://github.com/doublecheck-it/repo-base.git}"
REPO_BASE_REF="${REPO_BASE_REF:-main}"
TEMP_DIR=$(mktemp -d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not in a git repository root${NC}"
    echo "Please run this script from the root of your git repository"
    exit 1
fi

echo -e "${BLUE}======================================================================"
echo "Initializing repo-base tooling framework"
echo -e "======================================================================${NC}"
echo ""

# Clone repo-base to temp directory
echo -e "${BLUE}→ Fetching repo-base from ${REPO_BASE_URL}...${NC}"
git clone --depth 1 --branch "$REPO_BASE_REF" "$REPO_BASE_URL" "$TEMP_DIR" 2>&1 | grep -v "Cloning into" || true

# Function to check if file exists and ask user
check_and_copy() {
    local src="$1"
    local dest="$2"
    local description="$3"
    
    if [ -e "$dest" ]; then
        echo -e "${YELLOW}⚠ ${description} already exists: ${dest}${NC}"
        read -p "  Overwrite? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "  ${BLUE}Skipped${NC}"
            return 0
        fi
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"
    
    if [ -d "$src" ]; then
        cp -r "$src" "$dest"
    else
        cp "$src" "$dest"
    fi
    echo -e "${GREEN}✓ ${description} installed${NC}"
}

# Function to merge gitignore
merge_gitignore() {
    local src="$1"
    local dest="$2"
    
    if [ -f "$dest" ]; then
        echo -e "${BLUE}→ Merging .gitignore entries...${NC}"
        # Add a marker
        if ! grep -q "# repo-base tooling framework" "$dest"; then
            echo "" >> "$dest"
            echo "# repo-base tooling framework" >> "$dest"
            # Extract only the tooling-specific entries
            grep -E "^\.tooling\.env$|^\.devcontainer/$" "$src" >> "$dest" || true
            echo -e "${GREEN}✓ Merged tooling entries into existing .gitignore${NC}"
        else
            echo -e "${BLUE}  repo-base entries already in .gitignore${NC}"
        fi
    else
        cp "$src" "$dest"
        echo -e "${GREEN}✓ .gitignore installed${NC}"
    fi
}

# Function to merge dockerignore
merge_dockerignore() {
    local src="$1"
    local dest="$2"
    
    if [ -f "$dest" ]; then
        echo -e "${BLUE}→ Merging .dockerignore entries...${NC}"
        if ! grep -q "# repo-base tooling framework" "$dest"; then
            echo "" >> "$dest"
            echo "# repo-base tooling framework" >> "$dest"
            # Extract only the tooling-specific entries
            grep -E "^\.git$|^\.tooling\.env$|^\.devcontainer/$" "$src" >> "$dest" || true
            echo -e "${GREEN}✓ Merged tooling entries into existing .dockerignore${NC}"
        else
            echo -e "${BLUE}  repo-base entries already in .dockerignore${NC}"
        fi
    else
        cp "$src" "$dest"
        echo -e "${GREEN}✓ .dockerignore installed${NC}"
    fi
}

# Function to setup Makefile
setup_makefile() {
    local src="$1"
    local dest="Makefile"
    
    if [ -f "$dest" ]; then
        echo -e "${YELLOW}⚠ Makefile already exists${NC}"
        echo "  You'll need to manually add these includes to your Makefile:"
        echo -e "  ${BLUE}include make/commons.mk${NC}"
        echo -e "  ${BLUE}include make/tooling.mk${NC}"
        echo -e "  ${BLUE}include make/setup.mk${NC}"
        echo -e "  ${BLUE}-include tooling/*/make.mk${NC}"
        echo ""
        read -p "  Open example Makefile to see full structure? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
            cat "$src"
            echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
            echo ""
        fi
    else
        cp "$src" "$dest"
        echo -e "${GREEN}✓ Makefile installed${NC}"
    fi
}

echo -e "${BLUE}Installing core files...${NC}"
echo ""

# Install make directory (always needed)
if [ -d "make" ]; then
    echo -e "${YELLOW}⚠ make/ directory already exists${NC}"
    read -p "  Update make files? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp -r "$TEMP_DIR/make/"*.mk make/
        echo -e "${GREEN}✓ make/ directory updated${NC}"
    else
        echo -e "${BLUE}  Skipped${NC}"
    fi
else
    mkdir -p make
    cp -r "$TEMP_DIR/make/"*.mk make/
    echo -e "${GREEN}✓ make/ directory installed${NC}"
fi

# Install tooling directory (if not exists, create with README)
if [ ! -d "tooling" ]; then
    mkdir -p tooling
    if [ -d "$TEMP_DIR/tooling" ]; then
        # Copy README and available toolings list if they exist
        [ -f "$TEMP_DIR/tooling/README.md" ] && cp "$TEMP_DIR/tooling/README.md" tooling/
        [ -f "$TEMP_DIR/tooling/AVAILABLE-TOOLINGS.md" ] && cp "$TEMP_DIR/tooling/AVAILABLE-TOOLINGS.md" tooling/
    fi
    echo -e "${GREEN}✓ tooling/ directory created${NC}"
else
    echo -e "${BLUE}  tooling/ directory already exists${NC}"
    # Update documentation if available
    if [ -f "$TEMP_DIR/tooling/README.md" ]; then
        check_and_copy "$TEMP_DIR/tooling/README.md" "tooling/README.md" "tooling documentation"
    fi
    if [ -f "$TEMP_DIR/tooling/AVAILABLE-TOOLINGS.md" ]; then
        check_and_copy "$TEMP_DIR/tooling/AVAILABLE-TOOLINGS.md" "tooling/AVAILABLE-TOOLINGS.md" "available toolings list"
    fi
fi

# Install Makefile
setup_makefile "$TEMP_DIR/Makefile"

# Install config files
check_and_copy "$TEMP_DIR/.tooling.env.template" ".tooling.env.template" "tooling environment template"

# Merge .gitignore
merge_gitignore "$TEMP_DIR/.gitignore" ".gitignore"

# Merge .dockerignore
merge_dockerignore "$TEMP_DIR/.dockerignore" ".dockerignore"

# Clean up
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}======================================================================"
echo "✓ repo-base initialization complete!"
echo -e "======================================================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review the installed files (especially Makefile if it existed)"
echo "  2. Initialize your project:"
echo -e "     ${GREEN}make setup.project${NC}"
echo "  3. Add your first tooling (e.g., devcontainer):"
echo -e "     ${GREEN}make tooling.add NAME=devcontainer${NC}"
echo "  4. Set up devcontainer:"
echo -e "     ${GREEN}make devcontainer.setup${NC}"
echo "  5. Start development:"
echo -e "     ${GREEN}make devc.up${NC}"
echo ""
echo -e "${BLUE}Available commands:${NC}"
echo -e "  ${GREEN}make help${NC}                    - Show all available commands"
echo -e "  ${GREEN}make tooling.list-available${NC}  - Show available toolings"
echo ""
echo -e "${YELLOW}Note: If you had an existing Makefile, you'll need to manually"
echo "add the required includes (see output above).${NC}"
echo ""
