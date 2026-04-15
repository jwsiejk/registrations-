#!/usr/bin/env bash
set -euo pipefail

for sql_file in /opt/bootstrap/crm/schema/*.sql; do
  echo "[crm init] applying schema: ${sql_file}"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$sql_file"
done

for sql_file in /opt/bootstrap/crm/seed/*.sql; do
  echo "[crm init] applying seed: ${sql_file}"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$sql_file"
done
