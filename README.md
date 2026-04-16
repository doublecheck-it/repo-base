# repo-base

Generic, extensible project foundation with pluggable tooling architecture.

## Adding to Existing Repository

Want to add repo-base tooling to your existing project? Use the install scripts to add specific toolings without affecting your git configuration or existing files.

### Python Tooling

Install Python development tools (ruff, pytest, mypy, ipython):

```bash
# Quick install (default Python 3.12)
curl -fsSL https://raw.githubusercontent.com/doublecheck-it/repo-base/main/python-tooling/devcontainer/install.sh | bash

# Custom Python version
PYTHON_VERSION=3.11 curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash

# Or download and run
wget https://raw.githubusercontent.com/doublecheck-it/repo-base/main/python-tooling/devcontainer/install.sh
chmod +x install.sh
./install.sh
```

**What it installs:**
- Python (default: 3.12) and development tools
- Essential packages: ruff, pytest, pytest-cov, pytest-asyncio, mypy, ipython, ipdb
- Does NOT install frameworks (fastapi, django, flask) - add those separately
- Does NOT modify your existing repository files or git configuration

**Requirements:**
- Debian/Ubuntu-based container with apt-get
- Root privileges (or run with sudo)

---

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
