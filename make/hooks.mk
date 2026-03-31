## Git hooks management

_HOOKS_DIR := .git/hooks

.PHONY: hooks.install hooks.uninstall hooks.status

hooks.install: ## Install git hooks (placeholder)
	@echo "hooks.install: No hooks configured in generic base."
	@echo "Implement hook installation in stack-specific repos."
	@echo ""
	@echo "Typical hooks to consider:"
	@echo "  - pre-commit: run qa.fmt, qa.lint"
	@echo "  - pre-push: run qa.test"
	@echo ""

hooks.uninstall: ## Uninstall git hooks
	@rm -f $(_HOOKS_DIR)/pre-commit $(_HOOKS_DIR)/pre-push
	@echo "Git hooks removed"

hooks.status: ## Show installed hooks status
	@echo "Git hooks directory: $(_HOOKS_DIR)"
	@if [ -f "$(_HOOKS_DIR)/pre-commit" ]; then \
		echo "  pre-commit hook installed"; \
	else \
		echo "  pre-commit hook not installed"; \
	fi
	@if [ -f "$(_HOOKS_DIR)/pre-push" ]; then \
		echo "  pre-push hook installed"; \
	else \
		echo "  pre-push hook not installed"; \
	fi
