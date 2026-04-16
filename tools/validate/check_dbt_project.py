#!/usr/bin/env python3
"""Validate required dbt project files and directories."""

from __future__ import annotations

from pathlib import Path
import sys

REQUIRED_FILES = [
    "analytics/dbt/dbt_project.yml",
    "analytics/dbt/requirements.txt",
    "analytics/dbt/profiles/profiles.template.yml",
    "analytics/dbt/macros/generate_schema_name.sql",
    "analytics/dbt/models/staging/sources.yml",
    "analytics/dbt/models/staging/staging.yml",
    "analytics/dbt/models/intermediate/intermediate.yml",
    "analytics/dbt/models/marts/marts.yml",
]

REQUIRED_DIRECTORIES = [
    "analytics/dbt/models/staging",
    "analytics/dbt/models/intermediate",
    "analytics/dbt/models/marts",
    "analytics/dbt/profiles",
    "analytics/dbt/macros",
]


def main() -> int:
    root = Path.cwd()

    missing_files = [path for path in REQUIRED_FILES if not (root / path).is_file()]
    missing_directories = [path for path in REQUIRED_DIRECTORIES if not (root / path).is_dir()]

    if missing_files or missing_directories:
        print("FAIL: dbt project structure validation failed.")
        if missing_files:
            print("Missing required files:")
            for path in missing_files:
                print(f"  - {path}")
        if missing_directories:
            print("Missing required directories:")
            for path in missing_directories:
                print(f"  - {path}")
        return 1

    print("PASS: dbt project structure validation passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
