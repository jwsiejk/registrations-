#!/usr/bin/env bash
set -euo pipefail

for sql_file in /opt/bootstrap/erp/schema/*.sql; do
  echo "[erp init] applying schema: ${sql_file}"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$sql_file"
done

for sql_file in /opt/bootstrap/erp/seed/*.sql; do
  echo "[erp init] applying seed: ${sql_file}"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$sql_file"
done
