# Validation Tools

This document defines the purpose and usage of scripts in `tools/validate/`.

## `check_file_length.py`
- **Purpose:** Enforce the 500-line file size policy.
- **Inputs/Arguments:** Optional paths to scan; defaults to repository root.
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
- **Purpose:** Validate required Docker infrastructure files exist for local startup.
- **Inputs/Arguments:** None.
- **Exit behavior:**
  - `0` when compose file, service env files, and docker scripts all exist
  - `1` when one or more required Docker infrastructure files are missing
- **Example:**
  - `python3 tools/validate/check_docker_infra.py`

## `run_all.sh`
- **Purpose:** Run all validation checks in a single command.
- **Inputs/Arguments:** None.
- **Exit behavior:**
  - `0` when all checks pass
  - non-zero if any check fails
- **Example:**
  - `bash tools/validate/run_all.sh`

Related standards:
- [`../standards/testing-standard.md`](../standards/testing-standard.md)
- [`../standards/file-size-policy.md`](../standards/file-size-policy.md)
