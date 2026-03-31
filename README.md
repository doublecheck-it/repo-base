# repo-base

Generic, extensible project foundation with pluggable tooling architecture.

## Philosophy

**repo-base** is a minimal, stack-agnostic base repository that provides:

- **Host-first orchestration**: All `make` tasks run on the host, delegating to containers when needed
- **Filesystem-driven discovery**: Everything under `tooling/` is automatically active
- **Deterministic ordering**: Load order controlled via numeric prefixes (e.g., `10-python`, `20-kind`)
- **Single devcontainer**: Exactly one `.devcontainer/` entrypoint, no tooling-specific containers
- **Project isolation**: Unique Docker Compose project names prevent conflicts between multiple local checkouts

This repo is designed to be forked and extended with your stack-specific toolings (Python, Node.js, Kubernetes, etc.).

---

## Quick Start

### 1. First-Time Setup

Clone this repository and run the interactive setup:

```bash
git clone git@github.com:doublecheck-it/repo-base.git
cd repo-base
make setup
```

This will:
- Ask for your project name
- Remove the `.git` directory (fresh start)
- Generate `.tooling.env` with a unique `PROJECT_ID`
- Optionally rename the directory

### 2. Start the Development Environment

**Option A: Command Line**
```bash
make devc.up     # Start devcontainer
make devc.shell  # Open shell in devcontainer
```

**Option B: VS Code**
```bash
# Open in VS Code and use "Reopen in Container"
code .
# Then: Ctrl+Shift+P → "Dev Containers: Reopen in Container"
```

**Important:** Both methods use the same container! The `PROJECT_ID` from `.tooling.env` ensures VS Code and `make devc.up` attach to the same container instance.

### 3. Add Tooling Module

Add toolings from separate repositories:

```bash
# Add Python tooling with auto-assigned prefix
make tooling.add NAME=python

# Add with specific prefix for ordering
make tooling.add NAME=kind PREFIX=20

# Import specific branch or tag
make tooling.add NAME=python REF=v1.2.3

# List active toolings
make tooling.list
```

Available toolings: `python`, `kind`, `terraform`, `node`

### 4. Explore Available Commands

```bash
make help         # Show all available commands
make tooling.list # Show active tooling modules
```

---

## Architecture

### Directory Structure

```
.
├── .devcontainer/           # Central devcontainer configuration (DO NOT duplicate)
│   ├── devcontainer.json    # VS Code devcontainer config
│   ├── devc.docker-compose.yaml  # Base compose file
│   ├── devc.Dockerfile      # Generic base image
│   └── install-toolings.sh  # Executes tooling install scripts
├── .tooling.env             # Global project configuration (NOT committed)
├── .tooling.env.template    # Template for .tooling.env
├── make/                    # Base makefiles
│   ├── commons.mk           # Shared variables & tooling discovery logic
│   ├── devc.mk              # Devcontainer tasks (devc.*)
│   ├── qa.mk                # Quality assurance tasks (qa.*)
│   ├── sec.mk               # Security scanning tasks (sec.*)
│   ├── hooks.mk             # Git hooks management (hooks.*)
│   ├── setup.mk             # Project setup (setup, setup.project)
│   └── tooling.mk           # Tooling management (tooling.list)
├── tooling/                 # Active tooling modules (sorted by prefix)
├── Makefile                 # Aggregates all makefiles
└── README.md                # This file
```

---

## Common Tasks

### Development Environment

```bash
make devc.up        # Start devcontainer
make devc.down      # Stop devcontainer
make devc.restart   # Restart devcontainer (quick, uses cached image)
make devc.rebuild   # Rebuild and restart (slow, forces full rebuild without cache)
make devc.shell     # Open shell in devcontainer
make devc.logs      # Show devcontainer logs
make devc.ps        # Show container status
make devc.clean     # Clean up containers, networks, volumes
```

**When to use `devc.restart` vs `devc.rebuild`:**
- Use `devc.restart` for quick restarts (e.g., after config changes)
- Use `devc.rebuild` after adding/removing toolings or modifying Dockerfile/install scripts

### Tooling Management

```bash
make tooling.list   # List active toolings in load order
make tooling.info   # Alias for tooling.list
```

### Quality Assurance (placeholders—override in toolings)

```bash
make qa.fmt         # Format code
make qa.lint        # Lint code
make qa.test        # Run tests
make qa.check       # Lint + test (no formatting)
make qa.all         # Format + lint + test
```

### Security

```bash
make sec.scan-image IMAGE_NAME=myimage:tag  # Scan Docker image with Trivy
make sec.scan-deps                          # Scan dependencies (override in toolings)
```

### Git Hooks

```bash
make hooks.install   # Install git hooks (override in toolings)
make hooks.uninstall # Uninstall git hooks
make hooks.status    # Show hook status
```

---

### Adding Environment Variables

- **Global variables**: Add to `.tooling.env` (not committed)
- **Tooling-specific variables**: Add to `tooling/<name>/tooling.env`

The loading order ensures later toolings can override earlier ones.

---

## Best Practices

1. **Use numeric prefixes** for deterministic ordering: `10-python`, `20-kind`, `30-terraform`
2. **Keep toolings independent**: Avoid tight coupling between toolings
3. **Document tooling-specific commands**: Add comments in `make.mk` files
4. **Test in isolation**: Each tooling should be testable independently
5. **Don't commit `.tooling.env`**: It's generated per local checkout
6. **Use `$(call DEVC_EXEC,...)` for container commands**: Makes it explicit where code runs

---

## Troubleshooting

### `.tooling.env` not found

Run `make setup.project` to generate it.

### Tooling not loading

1. Check the directory is under `tooling/`
2. Run `make tooling.list` to see what's discovered
3. Ensure file names are correct: `make.mk`, `compose.yaml`, `tooling.env`, `devcontainer/install.sh`

### Devcontainer build fails

- Check `tooling/*/devcontainer/install.sh` scripts for errors
- Scripts must be executable (`chmod +x`)
- Scripts must exit cleanly (exit code 0)