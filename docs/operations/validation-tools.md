# Validation Tools

This document defines the purpose and usage of scripts in `tools/validate/`.

## `check_file_length.py`
- **Purpose:** Enforce the 500-line file size policy.
- **Inputs/Arguments:** None. The script scans all files under the current working directory (repository root when run via `make validate`).
- **Exit behavior:**
  - `0` when all scanned files are within policy
  - `1` when one or more files exceed policy
- **Example:**
  - `python3 tools/validate/check_file_length.py`

## `check_required_docs.py`
- **Purpose:** Ensure required documentation files exist.
- **Inputs/Arguments:** None.
- **Exit behavior:**
  - `0` when all required docs are present
  - `1` when required docs are missing
- **Example:**
  - `python3 tools/validate/check_required_docs.py`

## `check_required_top_level.py`
- **Purpose:** Ensure required top-level repository files exist.
- **Inputs/Arguments:** None.
- **Exit behavior:**
  - `0` when all required files are present
  - `1` when required files are missing
- **Example:**
  - `python3 tools/validate/check_required_top_level.py`

## `check_docs_index.py`
- **Purpose:** Validate all local markdown link targets defined in `docs/README.md`.
- **Inputs/Arguments:** None.
- **Exit behavior:**
  - `0` when every local link target in `docs/README.md` exists
  - `1` when one or more local link targets are missing
- **Notes:**
  - Parses markdown links directly from `docs/README.md`.
  - Resolves relative paths from the directory containing `docs/README.md`.
  - Ignores external URLs, `mailto:` links, and anchor-only links.
  - For links with fragments (for example `./file.md#section`), validates only the file path portion.
- **Example:**
  - `python3 tools/validate/check_docs_index.py`

## `check_docker_infra.py`
- **Purpose:** Validate Docker runtime prerequisites and Phase 03 source-bootstrap assets for local startup.
- **Inputs/Arguments:** None.
- **Prerequisite:** Root `.env` must exist (for local runs, create it with `cp .env.example .env`).
- **What it validates:**
  - Required Docker files exist (`compose.yaml`, service env files, helper scripts, reseed scripts, thin bootstrap scripts)
  - Required init and source SQL directories exist (`infra/docker/init/crm`, `infra/docker/init/erp`, `infra/docker/init/warehouse`, `db/crm/schema`, `db/crm/seed`, `db/erp/schema`, `db/erp/seed`)
  - Each required source SQL directory contains at least one `.sql` file
  - Root `.env` exists
  - Docker Compose config parses successfully via `docker compose --env-file .env -f infra/docker/compose.yaml config`
- **Exit behavior:**
  - `0` when required files/directories are present, required source SQL directories contain `.sql` files, and compose config validation succeeds
  - `1` when required paths are missing, `.env` is missing, Docker/Compose is unavailable, or compose config is invalid
- **Example:**
  - `python3 tools/validate/check_docker_infra.py`

## `run_all.sh`
- **Purpose:** Run all validation checks in a single command.
- **Inputs/Arguments:** None.
- **Prerequisite:** Because this script invokes `check_docker_infra.py`, root `.env` must exist first (`cp .env.example .env`).
- **Exit behavior:**
  - `0` when all checks pass
  - non-zero if any check fails
- **Example:**
  - `bash tools/validate/run_all.sh`

## CI behavior

The GitHub Actions validation workflow creates root `.env` from `.env.example` before running `bash tools/validate/run_all.sh`, so CI and local validation follow the same prerequisite.

Related standards:
- [`../standards/testing-standard.md`](../standards/testing-standard.md)
- [`../standards/file-size-policy.md`](../standards/file-size-policy.md)
