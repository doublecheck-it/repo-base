## Common variables and configuration

REPO_ROOT := $(shell pwd)
REPO_DIRNAME := $(shell basename $(REPO_ROOT))

# Discover devcontainer tooling directory dynamically
# Look for any tooling that has the devcontainer files
_DEVC_TOOLING_DIR := $(shell find tooling -maxdepth 2 -type d -name devcontainer 2>/dev/null | grep -E 'tooling/[^/]+/devcontainer$$' | head -1 | xargs dirname 2>/dev/null)
_DEVC_COMPOSE_FILE := $(_DEVC_TOOLING_DIR)/devcontainer/devc.docker-compose.yaml
_DEVC_DOCKERFILE := $(_DEVC_TOOLING_DIR)/devcontainer/devc.Dockerfile
DEVC_SERVICE := dev

# Export dockerfile path for docker compose to use
export DEVC_DOCKERFILE_PATH := $(_DEVC_DOCKERFILE)

_TOOLING_ENV_FILE := .tooling.env
_TOOLING_ENV_TEMPLATE := .tooling.env.template
_TOOLING_DIR := tooling

# Tooling discovery
_TOOLING_MODULES := $(sort $(filter-out . ..,$(patsubst $(_TOOLING_DIR)/%/,%,$(wildcard $(_TOOLING_DIR)/*/))))
_TOOLING_MAKEFILES := $(sort $(wildcard $(_TOOLING_DIR)/*/make.mk))
_TOOLING_COMPOSE_FILES := $(sort $(wildcard $(_TOOLING_DIR)/*/compose.yaml))
_TOOLING_ENV_FILES := $(sort $(wildcard $(_TOOLING_DIR)/*/tooling.env))
_TOOLING_DEVC_SCRIPTS := $(sort $(wildcard $(_TOOLING_DIR)/*/devcontainer/install.sh))

# Docker Compose with env and compose files
_COMPOSE_FILES := -f $(_DEVC_COMPOSE_FILE)
_COMPOSE_FILES += $(foreach file,$(_TOOLING_COMPOSE_FILES),-f $(file))
_ENV_FILES := --env-file $(_TOOLING_ENV_FILE)
_ENV_FILES += $(foreach file,$(_TOOLING_ENV_FILES),--env-file $(file))

DOCKER_COMPOSE := docker compose $(_ENV_FILES) $(_COMPOSE_FILES)

# Helper functions
define DEVC_EXEC
	$(DOCKER_COMPOSE) exec $(DEVC_SERVICE) bash -c "$(1)"
endef

define DEVC_RUN
	$(DOCKER_COMPOSE) run --rm $(DEVC_SERVICE) bash -c "$(1)"
endef

# Ensure .tooling.env exists (do not use in setup.* tasks)
.PHONY: _ensure-tooling-env
_ensure-tooling-env:
	@if [ ! -f $(_TOOLING_ENV_FILE) ]; then \
		echo "$(_TOOLING_ENV_FILE) not found. Running setup..."; \
		$(MAKE) -s setup.project; \
	fi
