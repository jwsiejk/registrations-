#!/usr/bin/env python3
"""Check whether required Fivetran raw schemas/tables exist in postgres-warehouse."""

from __future__ import annotations

from pathlib import Path
import subprocess
import sys

REQUIRED_TABLES: dict[str, list[str]] = {
    "fivetran_crm": [
        "accounts",
        "contacts",
        "opportunities",
        "opportunity_history",
    ],
    "fivetran_erp": [
        "customers",
        "products",
        "orders",
        "order_items",
        "invoices",
    ],
}


def run_psql(root: Path, sql: str) -> subprocess.CompletedProcess[str]:
    compose_file = root / "infra/docker/compose.yaml"
    env_file = root / ".env"

    command = [
        "docker",
        "compose",
        "--env-file",
        str(env_file),
        "-f",
        str(compose_file),
        "exec",
        "-T",
        "postgres-warehouse",
        "bash",
        "-lc",
        (
            "psql -v ON_ERROR_STOP=1 --username \"$POSTGRES_USER\" "
            "--dbname \"$POSTGRES_DB\" -At -F '|' -c \""
            + sql.replace('"', r'\"')
            + '\"'
        ),
    ]

    try:
        return subprocess.run(command, capture_output=True, text=True, check=False)
    except FileNotFoundError as exc:
        raise RuntimeError("Docker CLI was not found. Install Docker and Docker Compose plugin.") from exc


def main() -> int:
    root = Path.cwd()
    env_file = root / ".env"

    if not env_file.is_file():
        print(f"FAIL: Missing required environment file: {env_file}")
        print("      Create it from the template first: cp .env.example .env")
        return 1

    required_pairs = [
        (schema_name, table_name)
        for schema_name, table_names in REQUIRED_TABLES.items()
        for table_name in table_names
    ]

    table_filter = " OR ".join(
        f"(table_schema = '{schema_name}' AND table_name = '{table_name}')"
        for schema_name, table_name in required_pairs
    )

    sql = (
        "SELECT table_schema, table_name "
        "FROM information_schema.tables "
        "WHERE table_type = 'BASE TABLE' "
        f"AND ({table_filter}) "
        "ORDER BY table_schema, table_name;"
    )

    try:
        result = run_psql(root, sql)
    except RuntimeError as error:
        print(f"FAIL: {error}")
        return 1
    if result.returncode != 0:
        print("FAIL: Could not query warehouse raw-table readiness.")
        if result.stderr.strip():
            print(result.stderr.strip())
        elif result.stdout.strip():
            print(result.stdout.strip())
        return 1

    found_pairs = set()
    for line in result.stdout.splitlines():
        if not line.strip() or "|" not in line:
            continue
        schema_name, table_name = [part.strip() for part in line.split("|", maxsplit=1)]
        found_pairs.add((schema_name, table_name))

    missing_pairs = [pair for pair in required_pairs if pair not in found_pairs]

    if missing_pairs:
        print("FAIL: dbt raw-source readiness check failed.")
        print("Expected Fivetran raw tables are missing in postgres-warehouse.")
        print("This is expected until manual Fivetran sync lands raw tables into:")
        print("  - fivetran_crm")
        print("  - fivetran_erp")
        print("Missing tables:")
        for schema_name, table_name in missing_pairs:
            print(f"  - {schema_name}.{table_name}")
        print("Run manual Fivetran sync, then re-run this check.")
        return 1

    print("PASS: dbt raw-source readiness check passed.")
    print("All required Fivetran raw tables are present in postgres-warehouse.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
