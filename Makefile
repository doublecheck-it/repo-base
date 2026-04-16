SHELL := /bin/bash
.DEFAULT_GOAL := help

include make/includes.mk

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
	@echo "To add a Tooling: make tooling.list-available and make tooling.add"
