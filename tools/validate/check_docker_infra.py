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
]

REQUIRED_DIRECTORIES = [
    "infra/docker/init/crm",
    "infra/docker/init/erp",
    "infra/docker/init/warehouse",
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

    if not check_compose_config(root):
        return 1

    print("PASS: Docker infrastructure files/directories are present and compose config is valid.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
