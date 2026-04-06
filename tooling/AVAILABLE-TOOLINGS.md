# Available Toolings

This is a curated list of available tooling modules for the repo-base framework.

## How to Add a Tooling

Use the `tooling.add` task with the name from the list below:

```bash
make tooling.add NAME=<tooling-name>
```

To see this list from the command line:
```bash
make tooling.list-available
```

---

## Core Toolings

### devcontainer
**Name for tooling.add:** `devcontainer`  
**Repository:** https://github.com/doublecheck-it/devcontainer-tooling  
**Description:** Development container setup with Docker Compose orchestration. Provides the base development environment.  
**Prefix:** `00` (enforced - this is the absolute basis)  
**Status:** Available

---

## Language & Runtime Toolings

### python
**Name for tooling.add:** `python`  
**Repository:** https://github.com/doublecheck-it/python-tooling  
**Description:** Python development stack with uv, pytest, ruff, and mypy.  
**Suggested Prefix:** `10` (auto-assigned)  
**Status:** Available

### node
**Name for tooling.add:** `node`  
**Repository:** https://github.com/doublecheck-it/node-tooling  
**Description:** Node.js development stack with npm/yarn/pnpm support.  
**Suggested Prefix:** `10` (auto-assigned)  
**Status:** Planned

### go
**Name for tooling.add:** `go`  
**Repository:** https://github.com/doublecheck-it/go-tooling  
**Description:** Go development environment with go modules and common tools.  
**Suggested Prefix:** `10` (auto-assigned)  
**Status:** Planned

### rust
**Name for tooling.add:** `rust`  
**Repository:** https://github.com/doublecheck-it/rust-tooling  
**Description:** Rust development environment with cargo and clippy.  
**Suggested Prefix:** `10` (auto-assigned)  
**Status:** Planned

---

## Infrastructure Toolings

### kind
**Name for tooling.add:** `kind`  
**Repository:** https://github.com/doublecheck-it/kind-tooling  
**Description:** Kubernetes in Docker for local Kubernetes development.  
**Suggested Prefix:** `20` (auto-assigned)  
**Status:** Planned

### terraform
**Name for tooling.add:** `terraform`  
**Repository:** https://github.com/doublecheck-it/terraform-tooling  
**Description:** Infrastructure as Code with Terraform and common providers.  
**Suggested Prefix:** `30` (auto-assigned)  
**Status:** Planned

### aws
**Name for tooling.add:** `aws`  
**Repository:** https://github.com/doublecheck-it/aws-tooling  
**Description:** AWS CLI and tools for AWS development.  
**Suggested Prefix:** `30` (auto-assigned)  
**Status:** Planned

---

## Database Toolings

### postgres
**Name for tooling.add:** `postgres`  
**Repository:** https://github.com/doublecheck-it/postgres-tooling  
**Description:** PostgreSQL database with local Docker instance and psql client.  
**Suggested Prefix:** `40` (auto-assigned)  
**Status:** Planned

### mysql
**Name for tooling.add:** `mysql`  
**Repository:** https://github.com/doublecheck-it/mysql-tooling  
**Description:** MySQL database with local Docker instance and mysql client.  
**Suggested Prefix:** `40` (auto-assigned)  
**Status:** Planned

### redis
**Name for tooling.add:** `redis`  
**Repository:** https://github.com/doublecheck-it/redis-tooling  
**Description:** Redis cache/database with local Docker instance and redis-cli.  
**Suggested Prefix:** `40` (auto-assigned)  
**Status:** Planned

---

## Contributing

To add a new tooling to this list:
1. Create the tooling repository following the tooling module structure
2. Add it to this file with the appropriate details
3. Update the list in `repo-base/make/tooling.mk` help text

---

**Legend:**
- Available - Tooling is ready to use
- Planned - Tooling is planned but not yet available
- In Development - Tooling is being actively developed

**Last Updated:** 2026-04-06
