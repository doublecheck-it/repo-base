## Debug tooling discovery

.PHONY: tooling.debug

tooling.debug: ## Debug tooling discovery variables
	@echo "Tooling Discovery Debug"
	@echo "TOOLING_DIR: $(_TOOLING_DIR)"
	@echo ""
	@echo "Wildcard result: $(wildcard $(_TOOLING_DIR)/*/)"
	@echo ""
	@echo "Notdir result: $(notdir $(wildcard $(_TOOLING_DIR)/*/))"
	@echo ""
	@echo "TOOLING_MODULES: $(_TOOLING_MODULES)"
	@echo ""
	@echo "TOOLING_MAKEFILES: $(_TOOLING_MAKEFILES)"
	@echo ""
	@echo "TOOLING_COMPOSE_FILES: $(_TOOLING_COMPOSE_FILES)"
	@echo ""
	@echo "TOOLING_ENV_FILES: $(_TOOLING_ENV_FILES)"
	@echo ""
	@echo "TOOLING_DEVC_SCRIPTS: $(_TOOLING_DEVC_SCRIPTS)"
