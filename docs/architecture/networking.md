# Networking Reference (Phase 06)

This document is the durable, repo-specific networking reference for the local ELT lab.

## Purpose

It defines how traffic flows between local PostgreSQL services, local dbt execution, and manual Fivetran trial sync via Proxy Agent.

It also clarifies the schema boundary between raw Fivetran-landed tables and dbt analytics schemas.

## Component and flow diagram

```text
                        +------------------+
                        |  Fivetran Cloud  |
                        +---------+--------+
                                  |
                                  | outbound/registered agent traffic
                                  v
                        +---------+--------+
                        |   Proxy Agent    |
                        | (operator-managed|
                        |  local bridge)   |
                        +----+--------+----+
                             |        |
       source read traffic   |        | destination write traffic
                             |        |
        +--------------------+        +--------------------+
        |                                             |
+-------v--------+                           +--------v---------+
| postgres-crm   |                           | postgres-warehouse|
| host:5433      |                           | host:5435         |
| container:5432 |                           | container:5432    |
+----------------+                           +-------------------+

+----------------+
| postgres-erp   |
| host:5434      |
| container:5432 |
+----------------+

Local dbt traffic (operator machine) -> postgres-warehouse host:5435
```

## Host-to-container port mappings

From `infra/docker/compose.yaml` and root `.env` defaults:

| Service | Host port default | Container port | `.env` override |
|---|---:|---:|---|
| `postgres-crm` | `5433` | `5432` | `CRM_DB_PORT` |
| `postgres-erp` | `5434` | `5432` | `ERP_DB_PORT` |
| `postgres-warehouse` | `5435` | `5432` | `WAREHOUSE_DB_PORT` |

If root `.env` changes these values, operators must use the overridden host ports consistently in manual connector/destination configuration.

## Traffic classes

### 1) Source DB traffic (manual Fivetran source connectors)

- Path: Fivetran Cloud -> Proxy Agent -> source Postgres (`postgres-crm`, `postgres-erp`)
- Purpose: read source tables from CRM/ERP
- Expected source schemas/tables:
  - CRM `public`: `accounts`, `contacts`, `opportunities`, `opportunity_history`
  - ERP `public`: `customers`, `products`, `orders`, `order_items`, `invoices`

### 2) Destination DB traffic (manual Fivetran destination)

- Path: Fivetran Cloud -> Proxy Agent -> warehouse Postgres (`postgres-warehouse`)
- Purpose: write raw replicated tables
- Expected raw schemas in warehouse:
  - `fivetran_crm`
  - `fivetran_erp`

### 3) Local dbt traffic

- Path: local operator machine -> warehouse host port (`localhost:5435` by default)
- Purpose: run dbt parse/compile/run/test against the warehouse
- dbt profile defaults are defined in `analytics/dbt/profiles/profiles.template.yml`

## Schema boundary: raw vs analytics

Raw ingest schemas (created/populated by manual Fivetran sync):
- `fivetran_crm`
- `fivetran_erp`

Analytics schemas (created by warehouse bootstrap SQL and used by dbt models):
- `analytics`
- `analytics_staging`
- `analytics_intermediate`
- `analytics_marts`

The repository does **not** implement any direct source-to-warehouse copy path and does not create fake raw stand-ins.

## Related docs

- Overview: [`overview.md`](./overview.md)
- Fivetran setup runbook: [`../operations/fivetran-setup.md`](../operations/fivetran-setup.md)
- Proxy Agent guidance: [`../operations/proxy-agent.md`](../operations/proxy-agent.md)
- Local runtime setup: [`../operations/local-setup.md`](../operations/local-setup.md)
