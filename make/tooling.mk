## Tooling management and discovery
## Shows information about active tooling modules

.PHONY: tooling.list tooling.info tooling.list-available tooling.add tooling.remove

tooling.list: ## List all active tooling modules in load order
	@echo "Active Tooling Modules (load order)"
	@echo ""
	@if [ -z "$(_TOOLING_MODULES)" ]; then \
		echo "No tooling modules found in $(_TOOLING_DIR)/"; \
		echo ""; \
		echo "To add a tooling module, create a directory like:"; \
		echo "  $(_TOOLING_DIR)/10-python/"; \
		echo "  $(_TOOLING_DIR)/20-kind/"; \
		echo ""; \
		echo "Optional files per tooling:"; \
		echo "  - make.mk              (included in main Makefile)"; \
		echo "  - compose.yaml         (merged into docker compose stack)"; \
		echo "  - tooling.env          (environment variables)"; \
		echo "  - devcontainer/install.sh (executed during devcontainer build)"; \
		echo "  - .tooling-source.env  (source metadata)"; \
	else \
		for tooling in $(_TOOLING_MODULES); do \
			echo "$$tooling"; \
			if [ -f "$(_TOOLING_DIR)/$$tooling/make.mk" ]; then \
				echo "  make.mk"; \
			fi; \
			if [ -f "$(_TOOLING_DIR)/$$tooling/compose.yaml" ]; then \
				echo "  compose.yaml"; \
			fi; \
			if [ -f "$(_TOOLING_DIR)/$$tooling/tooling.env" ]; then \
				echo "  tooling.env"; \
			fi; \
			if [ -f "$(_TOOLING_DIR)/$$tooling/devcontainer/install.sh" ]; then \
				echo "  devcontainer/install.sh"; \
			fi; \
			if [ -f "$(_TOOLING_DIR)/$$tooling/.tooling-source.env" ]; then \
				echo "  .tooling-source.env"; \
				source "$(_TOOLING_DIR)/$$tooling/.tooling-source.env" 2>/dev/null && \
				if [ -n "$$TOOLING_SOURCE" ]; then \
					echo "    Source: $$TOOLING_SOURCE"; \
					if [ -n "$$TOOLING_COMMIT" ]; then \
						echo "    Commit: $${TOOLING_COMMIT:0:8}"; \
					fi; \
				fi; \
			fi; \
			echo ""; \
		done; \
	fi


tooling.info: tooling.list ## Alias for tooling.list

tooling.list-available: ## List all available toolings that can be added
	@if [ -f "$(_TOOLING_DIR)/AVAILABLE-TOOLINGS.md" ]; then \
		cat "$(_TOOLING_DIR)/AVAILABLE-TOOLINGS.md"; \
	else \
		echo "Error: $(_TOOLING_DIR)/AVAILABLE-TOOLINGS.md not found"; \
		exit 1; \
	fi

_TOOLING_REPO_BASE := https://github.com/doublecheck-it

tooling.add: ## Add a tooling: make tooling.add NAME=python [PREFIX=10] [REF=main]
	@if [ -z "$(NAME)" ]; then \
		echo "Usage: make tooling.add NAME=<tooling-name> [PREFIX=<number>] [REF=<branch>]"; \
		echo ""; \
		echo "Parameters:"; \
		echo "  NAME    - Tooling name (required)"; \
		echo "  PREFIX  - Numeric prefix for ordering (optional, auto-assigned if not set)"; \
		echo "  REF     - Git branch/tag to import (optional, default: main)"; \
		echo ""; \
		echo "Examples:"; \
		echo "  make tooling.add NAME=python          # Auto-assigns prefix (10-)"; \
		echo "  make tooling.add NAME=python PREFIX=15  # Uses prefix 15-"; \
		echo "  make tooling.add NAME=python REF=v1.2.3 # Import tag v1.2.3"; \
		echo "  make tooling.add NAME=kind PREFIX=20 REF=develop # Import develop branch"; \
		echo "  make tooling.add NAME=devcontainer     # Always uses prefix 00- (enforced)"; \
		echo ""; \
		echo "Available toolings:"; \
		echo "  - devcontainer (Dev container setup - MUST use prefix 00)"; \
		echo "  - python (Python development stack)"; \
		echo "  - kind (Kubernetes in Docker)"; \
		echo "  - terraform (Infrastructure as Code)"; \
		echo "  - node (Node.js development stack)"; \
		echo ""; \
		echo "Note: The tooling's .git directory is removed after import."; \
		echo "      Source metadata is stored in .tooling-source.env"; \
		exit 1; \
	fi; \
	if [ "$(NAME)" = "devcontainer" ]; then \
		if [ -n "$(PREFIX)" ] && [ "$(PREFIX)" != "00" ]; then \
			echo "ERROR: devcontainer-tooling must use prefix 00 (it's the absolute basis)"; \
			echo "       You specified PREFIX=$(PREFIX), but only 00 is allowed."; \
			exit 1; \
		fi; \
		prefix=00; \
		echo "devcontainer-tooling is the absolute basis - using prefix 00"; \
	elif [ -z "$(PREFIX)" ]; then \
		existing_prefixes=$$(find $(_TOOLING_DIR) -mindepth 1 -maxdepth 1 -type d -name '[0-9]*-*' -printf '%f\n' 2>/dev/null | sed 's/-.*//' | sort -n | tail -1); \
		if [ -z "$$existing_prefixes" ]; then \
			prefix=10; \
		else \
			prefix=$$(($$existing_prefixes + 10)); \
		fi; \
	else \
		prefix=$(PREFIX); \
	fi; \
	tooling_name="$${prefix}-$(NAME)"; \
	tooling_path="$(_TOOLING_DIR)/$$tooling_name"; \
	repo_url="$(_TOOLING_REPO_BASE)/$(NAME)-tooling.git"; \
	if [ -d "$$tooling_path" ]; then \
		echo "Tooling already exists at $$tooling_path"; \
		echo "Remove it first with: make tooling.remove NAME=$$tooling_name"; \
		exit 1; \
	fi; \
	echo "Adding tooling: $$tooling_name"; \
	echo "Repository: $$repo_url"; \
	echo ""; \
	if git ls-remote "$$repo_url" >/dev/null 2>&1; then \
		ref="$(REF)"; \
		if [ -z "$$ref" ]; then \
			ref="main"; \
		fi; \
		echo "Cloning from $$repo_url (ref: $$ref)..."; \
		git clone --branch "$$ref" "$$repo_url" "$$tooling_path" 2>&1; \
		clone_exit=$$?; \
		if [ $$clone_exit -ne 0 ]; then \
			echo "Failed to clone branch '$$ref', trying 'master'..."; \
			rm -rf "$$tooling_path"; \
			git clone --branch master "$$repo_url" "$$tooling_path" 2>&1 || { \
				echo "Clone failed"; \
				exit 1; \
			}; \
			ref="master"; \
		fi; \
		echo ""; \
		cd "$$tooling_path" && \
		commit_sha=$$(git rev-parse HEAD) && \
		current_ref=$$(git symbolic-ref --short HEAD 2>/dev/null || echo "$$ref") && \
		cd - > /dev/null; \
		echo "Removing .git directory (tooling becomes part of main repo)..."; \
		rm -rf "$$tooling_path/.git"; \
		echo "Writing source metadata to .tooling-source.env..."; \
		{ \
			echo "# Tooling Source Metadata"; \
			echo "# This file tracks where this tooling was imported from."; \
			echo "# The tooling files are versioned in the main repo, not as a submodule."; \
			echo ""; \
			echo "# Logical name of the tooling"; \
			echo "TOOLING_NAME=$(NAME)"; \
			echo ""; \
			echo "# Directory name (prefix-name)"; \
			echo "TOOLING_DIR=$$tooling_name"; \
			echo ""; \
			echo "# Source repository URL"; \
			echo "TOOLING_SOURCE=$$repo_url"; \
			echo ""; \
			echo "# Branch/tag/ref that was imported"; \
			echo "TOOLING_REF=$$current_ref"; \
			echo ""; \
			echo "# Commit SHA that was imported"; \
			echo "TOOLING_COMMIT=$$commit_sha"; \
			echo ""; \
			echo "# Import timestamp"; \
			echo "TOOLING_IMPORTED_AT=$$(date -u +%Y-%m-%dT%H:%M:%SZ)"; \
		} > "$$tooling_path/.tooling-source.env"; \
		echo ""; \
		echo "Tooling $$tooling_name added successfully"; \
		echo "  Source: $$repo_url"; \
		echo "  Ref: $$current_ref"; \
		echo "  Commit: $${commit_sha:0:8}"; \
	else \
		echo "Repository not found: $$repo_url"; \
		echo ""; \
		echo "The repository doesn't exist yet. You can:"; \
		echo "  1. Create the repository at: $$repo_url"; \
		echo "  2. Use a local directory instead"; \
		echo ""; \
		echo "Creating placeholder structure locally..."; \
		mkdir -p "$$tooling_path"; \
		echo "# $(NAME) Tooling" > "$$tooling_path/README.md"; \
		echo "" >> "$$tooling_path/README.md"; \
		echo "This tooling was initialized locally." >> "$$tooling_path/README.md"; \
		echo "Push to: $$repo_url" >> "$$tooling_path/README.md"; \
		echo ""; \
		echo "Writing source metadata to .tooling-source.env..."; \
		{ \
			echo "# Tooling Source Metadata"; \
			echo "# This file tracks where this tooling was imported from."; \
			echo "# The tooling files are versioned in the main repo, not as a submodule."; \
			echo ""; \
			echo "# Logical name of the tooling"; \
			echo "TOOLING_NAME=$(NAME)"; \
			echo ""; \
			echo "# Directory name (prefix-name)"; \
			echo "TOOLING_DIR=$$tooling_name"; \
			echo ""; \
			echo "# Source repository URL (intended)"; \
			echo "TOOLING_SOURCE=$$repo_url"; \
			echo ""; \
			echo "# Branch/tag/ref"; \
			echo "TOOLING_REF=main"; \
			echo ""; \
			echo "# Commit SHA (local initialization, no commit)"; \
			echo "TOOLING_COMMIT="; \
			echo ""; \
			echo "# Import timestamp"; \
			echo "TOOLING_IMPORTED_AT=$$(date -u +%Y-%m-%dT%H:%M:%SZ)"; \
			echo ""; \
			echo "# Note: This tooling was created locally as a placeholder."; \
		} > "$$tooling_path/.tooling-source.env"; \
		echo ""; \
		echo "Created placeholder at $$tooling_path"; \
	fi; \
	echo ""; \
	echo "Next steps:"; \
	echo "  1. Review the tooling files in $$tooling_path/"; \
	echo "  2. Rebuild devcontainer: make devc.rebuild"; \
	echo "  3. Verify: make tooling.list"

tooling.remove: ## Remove a tooling module: make tooling.remove NAME=10-python
	@if [ -z "$(NAME)" ]; then \
		echo "Usage: make tooling.remove NAME=<tooling-name>"; \
		echo "Example: make tooling.remove NAME=10-python"; \
		exit 1; \
	fi
	@if [ ! -d "$(_TOOLING_DIR)/$(NAME)" ]; then \
		echo "Tooling $(_TOOLING_DIR)/$(NAME) does not exist"; \
		exit 1; \
	fi
	@echo "Removing tooling: $(_TOOLING_DIR)/$(NAME)"
	@read -p "Are you sure? This will delete the directory. [y/N] " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		rm -rf "$(_TOOLING_DIR)/$(NAME)"; \
		echo "Tooling $(NAME) removed"; \
		echo "Run 'make devc.rebuild' to apply changes"; \
	else \
		echo "Cancelled"; \
	fi

