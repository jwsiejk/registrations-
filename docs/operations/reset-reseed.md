# Reset vs Reseed Operations

This runbook clarifies when to use first-time bootstrap, source-only reseed, or full docker reset.

## First-time bootstrap behavior (fresh volumes)

When CRM/ERP volumes are created for the first time (`make docker-up` after `make docker-reset`):

- `postgres-crm` runs `infra/docker/init/crm/010-bootstrap.sh`
- `postgres-erp` runs `infra/docker/init/erp/010-bootstrap.sh`
- Each init script executes ordered business SQL from `db/<system>/schema/` then `db/<system>/seed/`

This is automatic and runs once per new volume.

## Source-only reseed behavior (running environment)

Use source-only reseed when you want to rebuild CRM and ERP source data without touching warehouse state.

Primary command:

```bash
make docker-reseed-sources
```

Per-system commands:

```bash
make docker-reseed-crm
make docker-reseed-erp
```

Reseed implementation:
- Drops and recreates `public` schema in the target source database
- Replays ordered schema SQL then ordered seed SQL
- Leaves `postgres-warehouse` untouched

## When to use `docker-reset` vs `reseed`

Use `make docker-reset` when you need a complete lab reset:
- Removes containers
- Removes all Compose named volumes (`postgres_crm_data`, `postgres_erp_data`, `postgres_warehouse_data`)
- Next `make docker-up` triggers first-time bootstrap again

Use `make docker-reseed-sources` when you need only source refresh:
- Faster iteration for source schema/data changes
- Keeps warehouse volume and data intact

## Reset/reseed script reference

### `infra/docker/scripts/reset`
- **Purpose:** Destructively stop services and remove containers plus named volumes for a full local reset.
- **Inputs/Arguments:** No CLI arguments. Uses root `.env` and `infra/docker/compose.yaml`.
- **Exit behavior:**
  - `0` when `docker compose down -v --remove-orphans` succeeds
  - `1` when `.env` is missing or compose returns an error
- **Example:**
  - `bash infra/docker/scripts/reset`

### `infra/docker/scripts/reseed-crm`
- **Purpose:** Rebuild CRM source schema/data in the running `postgres-crm` container from committed SQL.
- **Inputs/Arguments:** No CLI arguments. Requires running compose services plus root `.env`; executes all `db/crm/schema/*.sql` then `db/crm/seed/*.sql` through mounted `/opt/bootstrap/crm/...` paths.
- **Exit behavior:**
  - `0` when schema reset and SQL replay complete
  - `1` when `.env` is missing, container is unavailable, or any SQL step fails (`ON_ERROR_STOP=1`)
- **Example:**
  - `bash infra/docker/scripts/reseed-crm`

### `infra/docker/scripts/reseed-erp`
- **Purpose:** Rebuild ERP source schema/data in the running `postgres-erp` container from committed SQL.
- **Inputs/Arguments:** No CLI arguments. Requires running compose services plus root `.env`; executes all `db/erp/schema/*.sql` then `db/erp/seed/*.sql` through mounted `/opt/bootstrap/erp/...` paths.
- **Exit behavior:**
  - `0` when schema reset and SQL replay complete
  - `1` when `.env` is missing, container is unavailable, or any SQL step fails (`ON_ERROR_STOP=1`)
- **Example:**
  - `bash infra/docker/scripts/reseed-erp`

### `infra/docker/scripts/reseed-sources`
- **Purpose:** Run both CRM and ERP reseed scripts in sequence.
- **Inputs/Arguments:** No CLI arguments.
- **Exit behavior:**
  - `0` when both `reseed-crm` and `reseed-erp` complete successfully
  - `1` when either delegated reseed script fails
- **Example:**
  - `bash infra/docker/scripts/reseed-sources`

## Exact command sequences

### Full-lab reset + fresh bootstrap

```bash
cp .env.example .env
make docker-reset
make docker-up
```

### Source-only reseed on running containers

```bash
cp .env.example .env
make docker-up
make docker-reseed-sources
```

### Verify source table counts

```bash
docker exec -i postgres-crm psql -U crm_user -d crm -c "SELECT 'accounts' AS table_name, COUNT(*) AS row_count FROM accounts UNION ALL SELECT 'contacts', COUNT(*) FROM contacts UNION ALL SELECT 'opportunities', COUNT(*) FROM opportunities UNION ALL SELECT 'opportunity_history', COUNT(*) FROM opportunity_history ORDER BY table_name;"

docker exec -i postgres-erp psql -U erp_user -d erp -c "SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers UNION ALL SELECT 'invoices', COUNT(*) FROM invoices UNION ALL SELECT 'order_items', COUNT(*) FROM order_items UNION ALL SELECT 'orders', COUNT(*) FROM orders UNION ALL SELECT 'products', COUNT(*) FROM products ORDER BY table_name;"
```
