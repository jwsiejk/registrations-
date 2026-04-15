# Local ELT Architecture Overview

This project includes local runtime infrastructure for a realistic ELT lab using Docker Compose and PostgreSQL.

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

## Phase 02 + Phase 03 design choices

- **Service isolation:** each database runs in its own container to mirror independent systems.
- **Persistent storage:** each service uses a dedicated named volume.
- **Health checks:** each service uses `pg_isready` for readiness/health reporting.
- **Thin init entrypoints for sources:**
  - `infra/docker/init/crm/` and `infra/docker/init/erp/` contain thin scripts only.
  - Business SQL lives under `db/crm/` and `db/erp/` and is executed in explicit numeric order.
- **Deterministic source seeds:** realistic CRM and ERP datasets are committed to the repo; no runtime randomness.
- **Source-only reseed path:** CRM/ERP can be rebuilt in running environments without resetting warehouse volume state.

## Not included yet

- Warehouse bootstrap schema and transformations are not implemented.
- dbt modeling is not implemented.
- Mutation/re-sync automation is not implemented.

Those remain intentionally deferred to later phases.
