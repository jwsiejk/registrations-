# Local ELT Architecture Overview

This project implements a realistic local ELT lab using Docker Compose, PostgreSQL, manual Fivetran trial sync, Proxy Agent connectivity, and dbt Core.

## Runtime components

The Compose stack defines three isolated PostgreSQL services:

1. **`postgres-crm`**
   - Represents the CRM source system.
   - Host port: `5433` (default) -> container port `5432`.
2. **`postgres-erp`**
   - Represents the ERP source system.
   - Host port: `5434` (default) -> container port `5432`.
3. **`postgres-warehouse`**
   - Represents the analytics warehouse destination.
   - Host port: `5435` (default) -> container port `5432`.

## End-to-end design goal

The intended flow remains:

`source Postgres -> manual Fivetran sync -> warehouse Postgres raw schemas -> dbt transformations -> validation -> mutate -> manual re-sync -> validation`

No alternate source-to-warehouse copy path is implemented in this repository.

## Networking and access model

- Fivetran cloud access to local/private databases is handled through a manually managed Proxy Agent.
- Source connector traffic reads from CRM/ERP Postgres endpoints.
- Destination traffic writes raw tables into warehouse Postgres.
- Local dbt traffic connects directly from the operator machine to warehouse host port.

See durable reference: [`networking.md`](./networking.md).

## Bootstrap and modeling layers

- **Source bootstrap (CRM/ERP):**
  - Thin init scripts in `infra/docker/init/crm/` and `infra/docker/init/erp/`
  - Business SQL in `db/crm/` and `db/erp/`
- **Warehouse bootstrap:**
  - Thin init script in `infra/docker/init/warehouse/010-bootstrap.sh`
  - Business SQL in `db/warehouse/bootstrap/`
  - Creates analytics-side schemas (`analytics`, `analytics_staging`, `analytics_intermediate`, `analytics_marts`)
- **dbt transformation layer:**
  - Project at `analytics/dbt/`
  - Source definitions target expected Fivetran raw schemas:
    - `fivetran_crm_public`
    - `fivetran_erp_public`
  - Layered models:
    - Staging (`stg_*`)
    - Intermediate (`int_*`)
    - Marts (`dim_customers`, `fct_orders`, `fct_pipeline`, `customer_360`, `revenue_summary`)

## Operational constraints

- Manual Fivetran actions remain out of scope for automation.
- dbt `run`/`test` depend on manual Fivetran sync having landed required raw tables.
- Raw-source readiness is checked explicitly with `make dbt-raw-source-readiness`.

## Controlled mutation layer (Phase 05)

Phase 05 adds deterministic source-side mutation assets under `db/crm/mutate/` and `db/erp/mutate/`, executed by `infra/docker/scripts/apply-mutation` and explicit `make mutate-*` targets.

These scenarios intentionally preserve the design flow and require manual re-sync for downstream effects.

## Related docs

- Fivetran setup runbook: [`../operations/fivetran-setup.md`](../operations/fivetran-setup.md)
- Proxy Agent guidance: [`../operations/proxy-agent.md`](../operations/proxy-agent.md)
- Validation workflow: [`../operations/validation.md`](../operations/validation.md)
