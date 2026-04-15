#!/usr/bin/env python3
"""Check that required documentation files are present."""

from __future__ import annotations

from pathlib import Path
import sys

REQUIRED_DOCS = [
    "README.md",
    "docs/standards/repo-contract.md",
    "docs/standards/documentation-standard.md",
    "docs/standards/file-size-policy.md",
    "docs/standards/testing-standard.md",
    "docs/operations/validation-tools.md",
    "docs/phases/phase-01-foundation.md",
    "docs/phases/phase-02-docker-postgres.md",
    "docs/phases/phase-03-seed-data.md",
    "docs/phases/phase-04-dbt.md",
    "docs/phases/phase-05-simulation.md",
    "docs/phases/phase-06-operator-runbook.md",
]


def main() -> int:
    root = Path.cwd()
    missing = [path for path in REQUIRED_DOCS if not (root / path).exists()]

    if missing:
        print("FAIL: Missing required documentation files:")
        for path in missing:
            print(f"  - {path}")
        return 1

    print("PASS: All required documentation files are present.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
