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
Scripts call Docker Compose with `--env-file .env` explicitly; they do not rely on implicit env-file discovery.
The same root `.env` is also required by Docker infra validation (`tools/validate/check_docker_infra.py`), which is included in `make validate`.

Service credentials/databases are defined in:
- `infra/docker/compose/postgres-crm.env`
- `infra/docker/compose/postgres-erp.env`
- `infra/docker/compose/postgres-warehouse.env`

## Start environment

```bash
make docker-up
```

Equivalent direct command:

```bash
bash infra/docker/scripts/up
```

`docker-up` waits until all three services report `healthy`:
- `postgres-crm`
- `postgres-erp`
- `postgres-warehouse`

If services do not become healthy before the timeout, the script exits non-zero and prints compose status.

## Bootstrap behavior on fresh volumes

On first initialization of CRM and ERP volumes, Docker entrypoint init scripts execute ordered SQL from:

- `db/crm/schema/*.sql`
- `db/crm/seed/*.sql`
- `db/erp/schema/*.sql`
- `db/erp/seed/*.sql`

Warehouse remains runtime-only in this phase (no warehouse business bootstrap).

## Check status and health

```bash
make docker-status
```

Equivalent direct command:

```bash
bash infra/docker/scripts/status
```

Expected health state for each service: `healthy`.

## Reseed source systems (non-destructive to warehouse)

```bash
make docker-reseed-sources
```

This rebuilds CRM and ERP schemas/data on running containers and does not reset warehouse data.

See [`reset-reseed.md`](./reset-reseed.md) for full reset/reseed guidance.

## Stop environment

```bash
make docker-down
```

Equivalent direct command:

```bash
bash infra/docker/scripts/down
```

## Reset environment (destructive)

This removes containers and named volumes:

```bash
make docker-reset
```

Equivalent direct command:

```bash
bash infra/docker/scripts/reset
```

## Runtime script reference

### `infra/docker/scripts/up`
- **Purpose:** Start local Postgres services and wait until all configured services report `healthy`.
- **Inputs/Arguments:** No CLI arguments. Uses root `.env`, `infra/docker/compose.yaml`, and optional `DOCKER_UP_TIMEOUT_SECONDS` (default `120`).
- **Exit behavior:**
  - `0` when compose startup succeeds and all services become healthy before timeout
  - `1` when `.env` is missing or health checks do not reach `healthy` before timeout
- **Example:**
  - `bash infra/docker/scripts/up`

### `infra/docker/scripts/down`
- **Purpose:** Stop and remove runtime containers/orphans without deleting named volumes.
- **Inputs/Arguments:** No CLI arguments. Uses root `.env` and `infra/docker/compose.yaml`.
- **Exit behavior:**
  - `0` when compose shutdown completes
  - `1` when `.env` is missing or compose returns an error
- **Example:**
  - `bash infra/docker/scripts/down`

### `infra/docker/scripts/status`
- **Purpose:** Print Docker Compose runtime status for local services.
- **Inputs/Arguments:** No CLI arguments. Uses root `.env` and `infra/docker/compose.yaml`.
- **Exit behavior:**
  - `0` when compose status command succeeds
  - `1` when `.env` is missing or compose returns an error
- **Example:**
  - `bash infra/docker/scripts/status`

## Port reference

Default host-to-container mappings:

- `localhost:5433 -> postgres-crm:5432`
- `localhost:5434 -> postgres-erp:5432`
- `localhost:5435 -> postgres-warehouse:5432`

## Validation prerequisite (local and CI alignment)

Before running either `python3 tools/validate/check_docker_infra.py` or full `make validate`, ensure root `.env` exists:

```bash
cp .env.example .env
```

CI uses the same approach and creates `.env` from `.env.example` before running `bash tools/validate/run_all.sh`.
