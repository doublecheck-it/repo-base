## Tooling management and discovery
## Shows information about active tooling modules

.PHONY: tooling.list tooling.info tooling.list-available tooling.add tooling.remove

_TOOLING_REPO_BASE := https://github.com/doublecheck-it
_TOOLING_LIST_URL := https://raw.githubusercontent.com/doublecheck-it/repo-base/main/tooling/available-toolings.txt
_TOOLING_LIST_CACHE := /tmp/available-toolings.txt

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

_fetch_toolings_list:
	@curl -fsSL "$(_TOOLING_LIST_URL)" -o "$(_TOOLING_LIST_CACHE)" 2>/dev/null || { \
		if [ -f "$(_TOOLING_DIR)/available-toolings.txt" ]; then \
			cp "$(_TOOLING_DIR)/available-toolings.txt" "$(_TOOLING_LIST_CACHE)"; \
		else \
			echo "Error: No toolings list available"; \
			exit 1; \
		fi; \
	}

tooling.list-available: _fetch_toolings_list ## List all available toolings that can be added
	@echo "Available Toolings"
	@echo "=================="
	@echo ""
	@installed="|"; \
	if [ -d "$(_TOOLING_DIR)" ]; then \
		for dir in $(_TOOLING_DIR)/[0-9]*-*; do \
			[ -d "$$dir" ] || continue; \
			name=$$(basename "$$dir" | sed 's/^[0-9]*-//'); \
			installed="$$installed$$name|"; \
		done; \
	fi; \
	prev_cat=""; \
	grep -v '^#' "$(_TOOLING_LIST_CACHE)" | grep -v '^$$' | while IFS='|' read -r name repo desc prefix enforced cat; do \
		if [ "$$cat" != "$$prev_cat" ]; then \
			[ -n "$$prev_cat" ] && echo ""; \
			echo "$$(echo $$cat | awk '{print toupper(substr($$0,1,1)) substr($$0,2)}') Toolings:"; \
			prev_cat="$$cat"; \
		fi; \
		badge=" "; \
		echo "$$installed" | grep -q "|$$name|" && badge="✓"; \
		printf "  %s %-15s - %s\n" "$$badge" "$$name" "$$desc"; \
	done

tooling.add: ## Add a tooling: make tooling.add [NAME=python] [PREFIX=10] [REF=main]
	@if [ -z "$(NAME)" ]; then \
		$(MAKE) -s _tooling_add_interactive; \
	else \
		$(MAKE) -s _tooling_add_by_name NAME="$(NAME)" PREFIX="$(PREFIX)" REF="$(REF)"; \
	fi

_tooling_add_interactive: _fetch_toolings_list
	@installed="|"; \
	if [ -d "$(_TOOLING_DIR)" ]; then \
		for dir in $(_TOOLING_DIR)/[0-9]*-*; do \
			[ -d "$$dir" ] || continue; \
			name=$$(basename "$$dir" | sed 's/^[0-9]*-//'); \
			installed="$$installed$$name|"; \
		done; \
	fi; \
	installable=$$(grep -v '^#' "$(_TOOLING_LIST_CACHE)" | grep -v '^$$' | while IFS='|' read -r name repo desc prefix enforced cat; do \
		echo "$$installed" | grep -q "|$$name|" || echo "$$name"; \
	done); \
	if [ -z "$$installable" ]; then \
		echo "No toolings available to install (all already installed)"; \
		exit 0; \
	fi; \
	echo "Select a tooling to add:"; \
	echo ""; \
	PS3="Enter number (or 0 to cancel): "; \
	select tooling in $$installable; do \
		if [ "$$REPLY" = "0" ]; then \
			echo "Cancelled"; \
			exit 0; \
		fi; \
		if [ -n "$$tooling" ]; then \
			echo ""; \
			$(MAKE) -s _tooling_add_by_name NAME=$$tooling; \
			break; \
		else \
			echo "Invalid selection. Please try again."; \
		fi; \
	done

_tooling_add_by_name:
_tooling_add_by_name:
	@if [ "$(NAME)" = "devcontainer" ]; then \
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

