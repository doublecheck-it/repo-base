#!/usr/bin/env bash
# Bootstrap script to initialize repo-base in an existing repository
# Usage: curl -fsSL https://raw.githubusercontent.com/doublecheck-it/repo-base/main/install.sh | bash

set -euo pipefail

REPO_BASE_URL="${REPO_BASE_URL:-https://github.com/doublecheck-it/repo-base.git}"
REPO_BASE_REF="${REPO_BASE_REF:-main}"
TEMP_DIR=$(mktemp -d)

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

# Function to merge gitignore
merge_gitignore() {
  local src="$1"
  local dest="$2"

  if [ -f "$dest" ]; then
    echo -e "${BLUE}→ Merging .gitignore entries...${NC}"
    # Add a marker
    if ! grep -q "# repo-base tooling framework" "$dest"; then
      echo "" >>"$dest"
      echo "# repo-base tooling framework" >>"$dest"
      # Extract only the tooling-specific entries
      grep -E "^\.tooling\.env$|^\.devcontainer/$" "$src" >>"$dest" || true
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
      echo "" >>"$dest"
      echo "# repo-base tooling framework" >>"$dest"
      # Extract only the tooling-specific entries
      grep -E "^\.git$|^\.tooling\.env$|^\.devcontainer/$" "$src" >>"$dest" || true
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
    echo -e "${BLUE}→ Updating existing Makefile...${NC}"

    # Check and add wildcard include for make directory
    if ! grep -q "include make/.*\.mk" "$dest" && ! grep -q "include.*make/" "$dest"; then
      echo "" >>"$dest"
      echo "# repo-base tooling framework" >>"$dest"
      echo "include make/includes.mk" >>"$dest"
      echo -e "${GREEN}✓ Added make/includes.mk include to Makefile${NC}"
    else
      echo -e "${BLUE}  make/ includes already present in Makefile${NC}"
    fi

    # Check and add help task if not present
    if ! grep -q "^help:" "$dest" && ! grep -q "^help " "$dest"; then
      echo "" >>"$dest"
      cat >>"$dest" <<'EOF'
.PHONY: help
help: ## Show this help message
	@echo "Available tasks:"
	@echo ""
	@for file in $(MAKEFILE_LIST); do \
		if [ -f "$$file" ]; then \
			targets=$$(grep -E '^[a-zA-Z_.-]+:.*##' "$$file" 2>/dev/null); \
			if [ -n "$$targets" ]; then \
				name=$$(basename "$$file" .mk); \
				if [ "$$name" = "Makefile" ]; then name="main"; fi; \
				echo "-- $$name"; \
				echo "$$targets" | awk -F':.*##' '{printf "   \033[36m%-28s\033[0m %s\n", $$1, $$2}'; \
				echo ""; \
			fi; \
		fi; \
	done
EOF
      echo -e "${GREEN}✓ Added help task to Makefile${NC}"
    else
      echo -e "${BLUE}  help task already present in Makefile${NC}"
    fi
  else
    cp "$src" "$dest"
    echo -e "${GREEN}✓ Makefile installed${NC}"
  fi
}

echo -e "${BLUE}Installing core files...${NC}"
echo ""

# 1. Always download make/ directory (core functionality)
echo -e "${BLUE}→ Installing make/ directory...${NC}"
mkdir -p make
cp -r "$TEMP_DIR/make/"* make/
echo -e "${GREEN}✓ make/ directory installed${NC}"

# 2. Always download tooling/ directory
echo -e "${BLUE}→ Installing tooling/ directory...${NC}"
mkdir -p tooling
if [ -d "$TEMP_DIR/tooling" ]; then
  # Copy all tooling directory contents
  cp -r "$TEMP_DIR/tooling/"* tooling/ 2>/dev/null || true
fi
echo -e "${GREEN}✓ tooling/ directory installed${NC}"

# 3. Handle README.md - skip if exists
if [ -f "README.md" ]; then
  echo -e "${BLUE}  README.md already exists - skipping${NC}"
else
  if [ -f "$TEMP_DIR/README.md" ]; then
    cp "$TEMP_DIR/README.md" README.md
    echo -e "${GREEN}✓ README.md installed${NC}"
  fi
fi

# 4. Handle Makefile intelligently
setup_makefile "$TEMP_DIR/Makefile"

# 5. Install config files (always)
if [ -f "$TEMP_DIR/.tooling.env.template" ]; then
  cp "$TEMP_DIR/.tooling.env.template" .tooling.env.template
  echo -e "${GREEN}✓ .tooling.env.template installed${NC}"
fi

# 6. Merge .gitignore
merge_gitignore "$TEMP_DIR/.gitignore" ".gitignore"

# 7. Merge .dockerignore
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
echo -e "     ${GREEN}make setup${NC}"
echo "  3. Add your first tooling (e.g., devcontainer):"
echo -e "     ${GREEN}make tooling.add NAME=devcontainer${NC}"
echo ""
echo -e "${BLUE}Available commands:${NC}"
echo -e "  ${GREEN}make help${NC}                    - Show all available commands"
echo -e "  ${GREEN}make tooling.list-installed${NC}  - Show available toolings"
echo ""
