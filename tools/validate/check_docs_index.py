#!/usr/bin/env python3
"""Check that key files referenced by docs/README.md exist."""

from __future__ import annotations

from pathlib import Path
import sys

REQUIRED_DOC_INDEX_TARGETS = [
    "docs/README.md",
    "docs/architecture/README.md",
    "docs/operations/validation-tools.md",
    "docs/standards/repo-contract.md",
    "docs/standards/documentation-standard.md",
    "docs/phases/phase-01-foundation.md",
]


def main() -> int:
    root = Path.cwd()
    missing = [path for path in REQUIRED_DOC_INDEX_TARGETS if not (root / path).exists()]

    if missing:
        print("FAIL: Missing docs index targets:")
        for path in missing:
            print(f"  - {path}")
        return 1

    print("PASS: All required docs index targets are present.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
