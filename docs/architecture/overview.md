# Local ELT Architecture Overview

This project implements a realistic local ELT lab using Docker Compose, PostgreSQL, and dbt Core.

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

`source Postgres -> manual Fivetran trial sync -> warehouse Postgres raw schemas -> dbt transformations -> validation`

No alternate source-to-warehouse copy path is implemented in this repository.

## Bootstrap and modeling layers

- **Source bootstrap (CRM/ERP):**
  - Thin init scripts in `infra/docker/init/crm/` and `infra/docker/init/erp/`
  - Business SQL in `db/crm/` and `db/erp/`
- **Warehouse bootstrap:**
  - Thin init script in `infra/docker/init/warehouse/010-bootstrap.sh`
  - Business SQL in `db/warehouse/bootstrap/`
  - Creates analytics-side schemas only (`analytics_staging`, `analytics_intermediate`, `analytics_marts`)
- **dbt transformation layer:**
  - Project at `analytics/dbt/`
  - Source definitions target expected Fivetran destination schemas:
    - `fivetran_crm`
    - `fivetran_erp`
  - Layered models:
    - Staging (`stg_*`)
    - Intermediate (`int_*`)
    - Marts (`dim_customers`, `fct_orders`, `fct_pipeline`, `customer_360`, `revenue_summary`)

## Operational constraints

- Manual Fivetran actions (connector setup, sync trigger, account interaction) are out of scope for automation in this repo.
- dbt `run`/`test` depend on manual Fivetran sync having landed required raw tables in warehouse.
- Raw-source readiness is checked explicitly with `make dbt-raw-source-readiness`.
