#!/usr/bin/env python3
"""Check that required top-level repository files are present."""

from __future__ import annotations

from pathlib import Path
import sys

REQUIRED_TOP_LEVEL = [
    ".editorconfig",
    ".gitignore",
    "Makefile",
    "README.md",
    ".env.example",
    "docs/README.md",
    ".github/pull_request_template.md",
    ".github/workflows/ci-validate.yml",
]


def main() -> int:
    root = Path.cwd()
    missing = [path for path in REQUIRED_TOP_LEVEL if not (root / path).exists()]

    if missing:
        print("FAIL: Missing required top-level files:")
        for path in missing:
            print(f"  - {path}")
        return 1

    print("PASS: All required top-level files are present.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
