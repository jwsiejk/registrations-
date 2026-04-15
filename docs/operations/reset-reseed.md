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
- Removes all named volumes (`crm`, `erp`, and `warehouse`)
- Next `make docker-up` triggers first-time bootstrap again

Use `make docker-reseed-sources` when you need only source refresh:
- Faster iteration for source schema/data changes
- Keeps warehouse volume and data intact

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
