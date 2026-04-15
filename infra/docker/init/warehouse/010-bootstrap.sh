#!/usr/bin/env bash
set -euo pipefail

for sql_file in /opt/bootstrap/warehouse/bootstrap/*.sql; do
  echo "[warehouse init] applying bootstrap: ${sql_file}"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$sql_file"
done
