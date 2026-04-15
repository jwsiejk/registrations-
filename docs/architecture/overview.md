# Local ELT Architecture Overview

This project now includes local runtime infrastructure for a realistic ELT lab using Docker Compose and PostgreSQL.

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

## Design choices for Phase 02

- **Service isolation:** each database runs in its own container to mirror independent systems.
- **Persistent storage:** each service uses a dedicated named volume.
- **Health checks:** each service uses `pg_isready` for readiness/health reporting.
- **Init mount points:** each service mounts a dedicated init folder under `/docker-entrypoint-initdb.d` so later phases can add SQL bootstrap files without changing container wiring.

## Not included yet

- No business schema model.
- No seed/business datasets.
- No transformation layer.

Those are intentionally deferred to later phases.
