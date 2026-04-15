#!/usr/bin/env python3
"""Validate required local Docker infrastructure files exist."""

from __future__ import annotations

from pathlib import Path
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
]


def main() -> int:
    root = Path.cwd()
    missing = [path for path in REQUIRED_FILES if not (root / path).exists()]

    if missing:
        print("FAIL: Missing required Docker infrastructure files:")
        for path in missing:
            print(f"  - {path}")
        return 1

    print("PASS: All required Docker infrastructure files are present.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
