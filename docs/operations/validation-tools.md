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
- **Purpose:** Ensure key files linked from `docs/README.md` exist.
- **Inputs/Arguments:** None.
- **Exit behavior:**
  - `0` when all required docs index targets are present
  - `1` when one or more docs index targets are missing
- **Example:**
  - `python3 tools/validate/check_docs_index.py`

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
