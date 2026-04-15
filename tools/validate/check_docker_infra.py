#!/usr/bin/env python3
"""Validate required local Docker infrastructure files, directories, and compose config."""

from __future__ import annotations

from pathlib import Path
import subprocess
import sys

REQUIRED_FILES = [
    "infra/docker/compose.yaml",
    "infra/docker/compose/postgres-crm.env",
    "infra/docker/compose/postgres-erp.env",
    "infra/docker/compose/postgres-warehouse.env",
    "infra/docker/scripts/up",
    "infra/docker/scripts/down",
    "infra/docker/scripts/status",
    "infra/docker/scripts/reset",
    "infra/docker/scripts/reseed-crm",
    "infra/docker/scripts/reseed-erp",
    "infra/docker/scripts/reseed-sources",
    "infra/docker/scripts/bootstrap-warehouse",
    "infra/docker/init/crm/010-bootstrap.sh",
    "infra/docker/init/erp/010-bootstrap.sh",
]

REQUIRED_DIRECTORIES = [
    "infra/docker/init/crm",
    "infra/docker/init/erp",
    "infra/docker/init/warehouse",
    "db/warehouse/bootstrap",
    "db/crm/schema",
    "db/crm/seed",
    "db/erp/schema",
    "db/erp/seed",
    "db/warehouse/bootstrap",
]

REQUIRED_SQL_DIRECTORIES = [
    "db/crm/schema",
    "db/crm/seed",
    "db/erp/schema",
    "db/erp/seed",
    "db/warehouse/bootstrap",
]


def check_required_paths(root: Path) -> bool:
    missing_files = [path for path in REQUIRED_FILES if not (root / path).is_file()]
    missing_directories = [path for path in REQUIRED_DIRECTORIES if not (root / path).is_dir()]

    if missing_files or missing_directories:
        print("FAIL: Missing required Docker infrastructure paths:")
        for path in missing_files:
            print(f"  - file: {path}")
        for path in missing_directories:
            print(f"  - directory: {path}")
        return False

    return True


def check_required_sql_files(root: Path) -> bool:
    missing_sql = []

    for directory in REQUIRED_SQL_DIRECTORIES:
        sql_files = sorted((root / directory).glob("*.sql"))
        if not sql_files:
            missing_sql.append(directory)

    if missing_sql:
        print("FAIL: Required source SQL directories must each contain at least one .sql file:")
        for directory in missing_sql:
            print(f"  - {directory}")
        return False

    return True


def check_compose_config(root: Path) -> bool:
    compose_file = root / "infra/docker/compose.yaml"
    env_file = root / ".env"

    if not env_file.is_file():
        print(f"FAIL: Missing required environment file: {env_file}")
        print("      Create it from the template first: cp .env.example .env")
        return False

    command = [
        "docker",
        "compose",
        "--env-file",
        str(env_file),
        "-f",
        str(compose_file),
        "config",
    ]

    try:
        result = subprocess.run(command, capture_output=True, text=True, check=False)
    except FileNotFoundError:
        print("FAIL: Docker CLI was not found. Install Docker and Docker Compose plugin.")
        return False

    if result.returncode != 0:
        print("FAIL: Docker Compose config validation failed.")
        if result.stderr.strip():
            print(result.stderr.strip())
        elif result.stdout.strip():
            print(result.stdout.strip())
        return False

    return True


def main() -> int:
    root = Path.cwd()

    if not check_required_paths(root):
        return 1

    if not check_required_sql_files(root):
        return 1

    if not check_compose_config(root):
        return 1

    print("PASS: Docker infrastructure files/directories are present, source SQL directories are populated, and compose config is valid.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
