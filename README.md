# repo-base

Generic, extensible project foundation with pluggable tooling architecture.

## Quick Start

Add the tooling base foundation to your project:

```bash
curl -fsSL https://raw.githubusercontent.com/doublecheck-it/repo-base/main/install.sh | bash
```

Then:

```bash
make setup
```

### What it does

- Downloads `make/` directory (all Make task definitions)
- Downloads `tooling/` directory (tooling framework)
- Skips `README.md` if your repository already has one
- For `Makefile`:
  - If exists: adds `-include make/*.mk` and `help` task (if not present)
  - If missing: downloads the full Makefile
- Merges `.gitignore` and `.dockerignore` entries (non-destructive)
- Installs `.tooling.env.template` configuration

## Managing Toolings

repo-base provides pluggable toolings that extend your project with specific capabilities (Python, Node.js, devcontainer, etc.).

**Available toolings:** See [`tooling/AVAILABLE-TOOLINGS.md`](tooling/AVAILABLE-TOOLINGS.md)

List all available toolings:

```bash
make tooling.list-available
```

Show currently active toolings:

```bash
make tooling.list
```

Add a tooling to your project:

```bash
make tooling.add NAME=python
```

```bash
make tooling.add NAME=devcontainer
```

Remove a tooling:

```bash
make tooling.remove NAME=python
```

## What is repo-base?

repo-base provides a **host-first**, **filesystem-driven** project foundation where:

- Everything runs via `make` on the host
- Toolings are discovered automatically from `tooling/` directory
- Load order is controlled via numeric prefixes (00-, 10-, 20-, etc.)
- Single unified devcontainer for all toolings
- Project isolation via unique Docker Compose names
- Add your own Make tasks and toolings as needed
