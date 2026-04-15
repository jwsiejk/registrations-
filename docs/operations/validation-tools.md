# Validation Tools

This document defines the purpose and usage of scripts in `tools/validate/`.

## `check_file_length.py`
- **Purpose:** Enforce the 500-line file size policy.
- **Inputs/Arguments:** None.
- **Exit behavior:**
  - `0` when all scanned files are within policy
  - `1` when one or more files exceed policy
- **Example:** `python3 tools/validate/check_file_length.py`

## `check_required_docs.py`
- **Purpose:** Ensure required documentation files exist.
- **Inputs/Arguments:** None.
- **Exit behavior:**
  - `0` when all required docs are present
  - `1` when required docs are missing
- **Example:** `python3 tools/validate/check_required_docs.py`

## `check_required_top_level.py`
- **Purpose:** Ensure required top-level repository files exist.
- **Inputs/Arguments:** None.
- **Exit behavior:**
  - `0` when all required files are present
  - `1` when required files are missing
- **Example:** `python3 tools/validate/check_required_top_level.py`

## `check_docs_index.py`
- **Purpose:** Validate all local markdown link targets defined in `docs/README.md`.
- **Inputs/Arguments:** None.
- **Exit behavior:**
  - `0` when every local link target exists
  - `1` when one or more local link targets are missing
- **Example:** `python3 tools/validate/check_docs_index.py`

## `check_docker_infra.py`
- **Purpose:** Validate Docker runtime prerequisites, bootstrap paths, and Compose config.
- **Inputs/Arguments:** None.
- **Prerequisite:** Root `.env` must exist.
- **What it validates:**
  - Required Docker files (compose, env files, helper scripts, bootstrap scripts)
  - Required init and SQL directories (`db/crm`, `db/erp`, `db/warehouse/bootstrap`)
  - Each required SQL directory contains at least one `.sql` file
  - Root `.env` exists
  - `docker compose ... config` succeeds
- **Exit behavior:**
  - `0` when checks pass
  - `1` when required paths are missing, `.env` is missing, Docker/Compose is unavailable, or compose config is invalid
- **Example:** `python3 tools/validate/check_docker_infra.py`

## `check_dbt_raw_sources.py`
- **Purpose:** Verify Phase 04 raw-source readiness by checking required Fivetran-landed tables in `postgres-warehouse`.
- **Inputs/Arguments:** None.
- **Prerequisites:** Root `.env` exists and `postgres-warehouse` is running.
- **Checks:**
  - `fivetran_crm`: `accounts`, `contacts`, `opportunities`, `opportunity_history`
  - `fivetran_erp`: `customers`, `products`, `orders`, `order_items`, `invoices`
- **Exit behavior:**
  - `0` when all required raw tables exist
  - `1` when one or more tables are missing or warehouse cannot be queried
- **Example:** `python3 tools/validate/check_dbt_raw_sources.py`

## `run_all.sh`
- **Purpose:** Run repository policy/infrastructure validation checks in one command.
- **Inputs/Arguments:** None.
- **Prerequisite:** Root `.env` must exist first.
- **Exit behavior:**
  - `0` when all checks pass
  - non-zero if any check fails
- **Example:** `bash tools/validate/run_all.sh`

Related standards:
- [`../standards/testing-standard.md`](../standards/testing-standard.md)
- [`../standards/file-size-policy.md`](../standards/file-size-policy.md)
