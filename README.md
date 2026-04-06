# repo-base

Generic, extensible project foundation with pluggable tooling architecture.

## Quick Start

```bash
# First-time setup
make setup

# Add toolings
make tooling.list-available  # See what's available
make tooling.add NAME=devcontainer
make tooling.add NAME=python

# Start development environment
make devc.up
make devc.shell
```

## Documentation

**Main Documentation:** See [`tooling/README.md`](tooling/README.md) for complete documentation.

**Available Toolings:** See [`tooling/AVAILABLE-TOOLINGS.md`](tooling/AVAILABLE-TOOLINGS.md) for a list of all available tooling modules.

## Common Tasks

```bash
make help                    # Show all available tasks
make tooling.list-available  # List toolings you can add
make tooling.list           # Show currently active toolings
make devc.up                # Start development container
make devc.shell             # Open shell in container
```

## What is repo-base?

repo-base provides a **host-first**, **filesystem-driven** project foundation where:

- ✅ Everything runs via `make` on the host
- ✅ Toolings are discovered automatically from `tooling/` directory
- ✅ Load order is controlled via numeric prefixes (00-, 10-, 20-, etc.)
- ✅ Single unified devcontainer for all toolings
- ✅ Project isolation via unique Docker Compose names

Perfect for teams that want a consistent development environment without the complexity of managing multiple Docker configurations.

---

**Note:** This root README is kept minimal to avoid conflicts when integrating repo-base into existing projects. The main documentation lives in the `tooling/` directory.
