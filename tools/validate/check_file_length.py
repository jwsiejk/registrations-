#!/usr/bin/env python3
"""Validate that repository files do not exceed the configured line limit."""

from __future__ import annotations

from pathlib import Path
import sys

MAX_LINES = 500
EXCLUDED_DIRS = {
    ".git",
    "__pycache__",
    ".venv",
    "venv",
    "env",
    "dbt_packages",
    "target",
}


def should_skip(path: Path) -> bool:
    return any(part in EXCLUDED_DIRS for part in path.parts)


def count_lines(path: Path) -> int:
    with path.open("r", encoding="utf-8", errors="ignore") as handle:
        return sum(1 for _ in handle)


def collect_files(root: Path) -> list[Path]:
    files: list[Path] = []
    for path in root.rglob("*"):
        if path.is_file() and not should_skip(path):
            files.append(path)
    return sorted(files)


def main() -> int:
    root = Path.cwd()
    violations: list[tuple[Path, int]] = []

    for file_path in collect_files(root):
        line_count = count_lines(file_path)
        if line_count > MAX_LINES:
            violations.append((file_path.relative_to(root), line_count))

    if violations:
        print(f"FAIL: Found files exceeding {MAX_LINES} lines:")
        for file_path, line_count in violations:
            print(f"  - {file_path}: {line_count} lines")
        return 1

    print(f"PASS: All scanned files are <= {MAX_LINES} lines.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
