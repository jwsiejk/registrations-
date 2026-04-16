# Local Setup (Docker + Postgres)

This document explains exactly how to start and stop the local runtime environment.

## Prerequisites

- Docker Engine + Docker Compose plugin installed.
- Run commands from repository root.

## Configure environment

1. Copy the example environment file:

   ```bash
   cp .env.example .env
   ```

2. (Optional) Adjust host ports in `.env`:
   - `CRM_DB_PORT` (default `5433`)
   - `ERP_DB_PORT` (default `5434`)
   - `WAREHOUSE_DB_PORT` (default `5435`)

The root `.env` file is required by all Docker helper scripts.

## Local PostgreSQL TLS setup

TLS is enabled for all three Postgres services during startup.

- `make docker-up` runs `infra/docker/scripts/generate-tls-certs` before `docker compose up`.
- Generated assets are written to `infra/docker/tls/` (git-ignored).
- Service containers then start through `infra/docker/scripts/postgres-entrypoint-with-tls.sh`, which applies explicit runtime settings:
  - `ssl=on`
  - `ssl_cert_file=<service cert path>`
  - `ssl_key_file=<service key path>`
  - `ssl_ca_file=<service CA path>`

To generate/re-generate TLS assets manually:

```bash
make docker-tls-setup
```

Windows Git Bash note: `infra/docker/scripts/generate-tls-certs` now automatically sets `MSYS_NO_PATHCONV=1` and `MSYS2_ARG_CONV_EXCL="*"` when running under MSYS/Cygwin shells so OpenSSL arguments/paths are not rewritten.

Optional certificate validity override (days): `TLS_CERT_VALIDITY_DAYS` in root `.env`.

## Start environment

```bash
make docker-up
```

Equivalent direct command:

```bash
bash infra/docker/scripts/up
```

`docker-up` returns success only after all three services report healthy.

## Bootstrap behavior on fresh volumes

For fresh volumes, Postgres entrypoint runs mounted init scripts once per new volume.

- CRM: `infra/docker/init/crm/010-bootstrap.sh`
  - Applies `db/crm/schema/*.sql` then `db/crm/seed/*.sql`
- ERP: `infra/docker/init/erp/010-bootstrap.sh`
  - Applies `db/erp/schema/*.sql` then `db/erp/seed/*.sql`
- Warehouse: `infra/docker/init/warehouse/010-bootstrap.sh`
  - Applies `db/warehouse/bootstrap/*.sql`
  - Creates analytics schemas used by dbt (`analytics`, `analytics_staging`, `analytics_intermediate`, `analytics_marts`)

Warehouse bootstrap does not create Fivetran raw tables.

## Apply warehouse bootstrap on running containers

```bash
make warehouse-bootstrap
```

Equivalent direct command:

```bash
bash infra/docker/scripts/bootstrap-warehouse
```

This command is safe and repeatable for existing warehouse volumes.

## Check status and health

```bash
make docker-status
```

## Reseed source systems (non-destructive to warehouse)

```bash
make docker-reseed-sources
```

This rebuilds CRM and ERP schemas/data on running containers and does not reset warehouse data.

## Stop environment

```bash
make docker-down
```

## Reset environment (destructive)

```bash
make docker-reset
```

This removes containers and named volumes.

## Runtime script reference

### Docker init bootstrap scripts

### `infra/docker/init/crm/010-bootstrap.sh`
- **Purpose:** Initialize CRM database on fresh volume by applying committed CRM schema and seed SQL.
- **Inputs/Arguments:** No CLI arguments. Reads `/opt/bootstrap/crm/schema/*.sql` then `/opt/bootstrap/crm/seed/*.sql` inside the container.
- **Exit behavior:**
  - `0` when all CRM SQL files apply successfully
  - non-zero when any SQL file fails (`set -euo pipefail` + `ON_ERROR_STOP=1`)
- **Example:** Runs automatically via Postgres entrypoint on first container start with fresh CRM volume.

### `infra/docker/init/erp/010-bootstrap.sh`
- **Purpose:** Initialize ERP database on fresh volume by applying committed ERP schema and seed SQL.
- **Inputs/Arguments:** No CLI arguments. Reads `/opt/bootstrap/erp/schema/*.sql` then `/opt/bootstrap/erp/seed/*.sql` inside the container.
- **Exit behavior:**
  - `0` when all ERP SQL files apply successfully
  - non-zero when any SQL file fails (`set -euo pipefail` + `ON_ERROR_STOP=1`)
- **Example:** Runs automatically via Postgres entrypoint on first container start with fresh ERP volume.

### `infra/docker/init/warehouse/010-bootstrap.sh`
- **Purpose:** Initialize warehouse database on fresh volume by applying committed warehouse bootstrap SQL.
- **Inputs/Arguments:** No CLI arguments. Reads `/opt/bootstrap/warehouse/bootstrap/*.sql` inside the container.
- **Exit behavior:**
  - `0` when all warehouse bootstrap SQL files apply successfully
  - non-zero when any SQL file fails (`set -euo pipefail` + `ON_ERROR_STOP=1`)
- **Example:** Runs automatically via Postgres entrypoint on first container start with fresh warehouse volume.

### `infra/docker/scripts/generate-tls-certs`
- **Purpose:** Generate local CA and service certificates/keys for CRM, ERP, and warehouse Postgres services.
- **Inputs/Arguments:** No CLI arguments. Optionally reads `TLS_CERT_VALIDITY_DAYS` from root `.env`.
- **Exit behavior:**
  - `0` when TLS assets are generated successfully under `infra/docker/tls/`
  - non-zero when `openssl` is unavailable or certificate generation fails
- **Example:** `bash infra/docker/scripts/generate-tls-certs`

### `infra/docker/scripts/postgres-entrypoint-with-tls.sh`
- **Purpose:** Container entrypoint wrapper that copies TLS assets into container paths with Postgres-safe permissions and starts PostgreSQL with SSL enabled.
- **Inputs/Arguments:** Requires `TLS_SERVICE_NAME` environment variable (`crm`, `erp`, `warehouse`) and existing mounted TLS assets under `/opt/postgres-tls/<service>/`.
- **Exit behavior:**
  - `0` when PostgreSQL starts with configured TLS settings
  - non-zero when required TLS files are missing or container startup fails
- **Example:** Invoked by each Postgres service entrypoint in `infra/docker/compose.yaml`.

### `infra/docker/scripts/up`
- **Purpose:** Start local Postgres services and wait until all configured services report `healthy`.
- **Inputs/Arguments:** No CLI arguments. Uses root `.env`, `infra/docker/compose.yaml`, and optional `DOCKER_UP_TIMEOUT_SECONDS`.
- **Exit behavior:**
  - `0` when startup succeeds and all services become healthy before timeout
  - `1` when `.env` is missing or health checks do not reach `healthy` before timeout
- **Example:** `bash infra/docker/scripts/up`

### `infra/docker/scripts/down`
- **Purpose:** Stop and remove runtime containers/orphans without deleting named volumes.
- **Inputs/Arguments:** No CLI arguments. Uses root `.env` and `infra/docker/compose.yaml`.
- **Exit behavior:**
  - `0` when compose shutdown completes
  - `1` when `.env` is missing or compose returns an error
- **Example:** `bash infra/docker/scripts/down`

### `infra/docker/scripts/status`
- **Purpose:** Print Docker Compose runtime status for local services.
- **Inputs/Arguments:** No CLI arguments. Uses root `.env` and `infra/docker/compose.yaml`.
- **Exit behavior:**
  - `0` when compose status command succeeds
  - `1` when `.env` is missing or compose returns an error
- **Example:** `bash infra/docker/scripts/status`

### `infra/docker/scripts/bootstrap-warehouse`
- **Purpose:** Apply committed warehouse bootstrap SQL to a running `postgres-warehouse` container.
- **Inputs/Arguments:** No CLI arguments. Uses root `.env`; executes `db/warehouse/bootstrap/*.sql` through mounted `/opt/bootstrap/warehouse/bootstrap/`.
- **Exit behavior:**
  - `0` when all warehouse bootstrap SQL files are applied successfully
  - `1` when `.env` is missing, container is unavailable, or any SQL step fails
- **Example:** `bash infra/docker/scripts/bootstrap-warehouse`

## Validation prerequisite

Before running either `python3 tools/validate/check_docker_infra.py` or `make validate`, ensure root `.env` exists:

```bash
cp .env.example .env
```
