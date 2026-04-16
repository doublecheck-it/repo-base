
# Load project-specific environment if it exists
-include .tooling.env

# Core makefiles (commons must be first for shared variables)
include make/commons.mk
include make/setup.mk
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
