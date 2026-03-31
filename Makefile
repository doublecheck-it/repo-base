SHELL := /bin/bash
.DEFAULT_GOAL := help

# Load project-specific environment if it exists
-include .tooling.env

# Core makefiles (commons must be first for shared variables)
include make/commons.mk
include make/setup.mk
include make/devc.mk
include make/qa.mk
include make/sec.mk
include make/hooks.mk
include make/tooling.mk
include make/debug.mk

# Optional: include stack-specific or project-specific makefiles if they exist
-include make/stack.mk
-include make/project.mk

# Dynamically include all tooling makefiles (discovered via commons.mk)
# Toolings are loaded in sorted order based on their directory names
-include $(_TOOLING_MAKEFILES)

.PHONY: help
help: ## Show this help message
	@echo "repo-base - Generic Project Foundation"
	@echo ""
	@echo "Available tasks (grouped by category):"
	@echo ""
	@for file in $(MAKEFILE_LIST); do \
		if [ -f "$$file" ]; then \
			section=$$(grep -E '^##[^#]' "$$file" 2>/dev/null | head -1 | sed 's/^##\s*//'); \
			targets=$$(grep -E '^[a-zA-Z_.-]+:.*##' "$$file" 2>/dev/null); \
			if [ -n "$$targets" ]; then \
				name=$$(basename "$$file" .mk); \
				if [ "$$name" = "Makefile" ]; then name="main"; fi; \
				echo "-- $$name"; \
				if [ -n "$$section" ]; then echo "   $$section"; fi; \
				echo "$$targets" | awk -F':.*##' '{printf "   \033[36m%-28s\033[0m %s\n", $$1, $$2}'; \
				echo ""; \
			fi; \
		fi; \
	done
	@echo "First time setup: make setup"