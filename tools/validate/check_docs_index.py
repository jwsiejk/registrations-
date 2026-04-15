#!/usr/bin/env python3
"""Validate local markdown link targets referenced by docs/README.md."""

from __future__ import annotations

from pathlib import Path
import re
import sys

LINK_PATTERN = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")
SCHEME_PATTERN = re.compile(r"^[a-zA-Z][a-zA-Z0-9+.-]*:")


def _extract_link_destination(raw_destination: str) -> str:
    """Return the URL/path portion of a markdown link destination."""
    destination = raw_destination.strip()

    if destination.startswith("<"):
        closing = destination.find(">")
        if closing != -1:
            return destination[1:closing]

    return destination.split(maxsplit=1)[0]


def _is_local_target(target: str) -> bool:
    if not target or target.startswith("#"):
        return False

    lowered = target.lower()
    if lowered.startswith("mailto:"):
        return False

    return SCHEME_PATTERN.match(target) is None


def _iter_local_targets(index_file: Path) -> set[str]:
    markdown = index_file.read_text(encoding="utf-8")
    local_targets: set[str] = set()

    for match in LINK_PATTERN.finditer(markdown):
        destination = _extract_link_destination(match.group(1))
        if not _is_local_target(destination):
            continue

        path_part = destination.split("#", maxsplit=1)[0].strip()
        if not path_part:
            continue

        local_targets.add(path_part)

    return local_targets


def main() -> int:
    root = Path.cwd()
    docs_index = root / "docs" / "README.md"

    if not docs_index.exists():
        print("FAIL: docs/README.md not found.")
        return 1

    missing: list[tuple[str, str]] = []
    for relative_target in sorted(_iter_local_targets(docs_index)):
        target_path = (docs_index.parent / relative_target).resolve(strict=False)
        if not target_path.exists():
            try:
                display_target = str(target_path.relative_to(root))
            except ValueError:
                display_target = str(target_path)
            missing.append((relative_target, display_target))

    if missing:
        print("FAIL: Missing local targets referenced by docs/README.md:")
        for raw_target, resolved_target in missing:
            print(f"  - {raw_target} -> {resolved_target}")
        return 1

    print("PASS: All local markdown link targets in docs/README.md exist.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
