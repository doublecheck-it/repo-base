## Quality Assurance tasks

.PHONY: qa.fmt qa.lint qa.test qa.check qa.all

qa.fmt: ## Format code (placeholder - implement in stack-specific repos)
	@echo "qa.fmt: No formatter configured (generic base)."
	@echo "Override this target in your stack-specific Makefile."

qa.lint: ## Lint code (placeholder - implement in stack-specific repos)
	@echo "qa.lint: No linter configured (generic base)."
	@echo "Override this target in your stack-specific Makefile."

qa.test: ## Run tests (placeholder - implement in stack-specific repos)
	@echo "qa.test: No test suite configured (generic base)."
	@echo "Override this target in your stack-specific Makefile."

qa.check: qa.lint qa.test ## Run all checks (lint + test, no formatting)

qa.all: qa.fmt qa.lint qa.test ## Run all QA tasks (format + lint + test)