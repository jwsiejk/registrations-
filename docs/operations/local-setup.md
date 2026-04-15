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

`docker-up` now waits until all three services report `healthy`:
- `postgres-crm`
- `postgres-erp`
- `postgres-warehouse`

If services do not become healthy before the timeout, the script exits non-zero and prints compose status.

## Check status and health

```bash
make docker-status
```

Equivalent direct command:

```bash
docker compose --env-file .env -f infra/docker/compose.yaml ps
```

Expected health state for each service: `healthy`.

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

## Port reference

Default host-to-container mappings:

- `localhost:5433 -> postgres-crm:5432`
- `localhost:5434 -> postgres-erp:5432`
- `localhost:5435 -> postgres-warehouse:5432`

## Init SQL mount points for later phases

- `infra/docker/init/crm`
- `infra/docker/init/erp`
- `infra/docker/init/warehouse`

Any `.sql` files placed in these directories will run at first database initialization (new volume).
