# Phase 02 - Docker and Postgres

## Status
Completed (local runtime foundation only).

## Intent
Add local Docker-based Postgres services that can be used by later ELT phases.

## What changed in this phase

1. Added Docker Compose runtime definition:
   - `infra/docker/compose.yaml`
2. Added three Postgres services:
   - `postgres-crm`
   - `postgres-erp`
   - `postgres-warehouse`
3. Added named volumes for persistence:
   - `postgres_crm_data`
   - `postgres_erp_data`
   - `postgres_warehouse_data`
4. Added service-level env files:
   - `infra/docker/compose/postgres-crm.env`
   - `infra/docker/compose/postgres-erp.env`
   - `infra/docker/compose/postgres-warehouse.env`
5. Added startup/teardown scripts:
   - `infra/docker/scripts/up`
   - `infra/docker/scripts/down`
   - `infra/docker/scripts/status`
   - `infra/docker/scripts/reset`
6. Added init mount directories for future SQL bootstrap:
   - `infra/docker/init/crm/`
   - `infra/docker/init/erp/`
   - `infra/docker/init/warehouse/`
7. Updated `Makefile` with Docker operation targets.
8. Added `.env.example` entries for host port mappings.
9. Added docs for architecture and local setup.
10. Added validation check `tools/validate/check_docker_infra.py` and wired it into local validation workflow.

## Explicitly out of scope

- No business schemas.
- No seed/business datasets.
- No dbt or transformation logic.

## Acceptance criteria mapping

- Docker compose config present and valid: met.
- Three Postgres services start cleanly: met via local validation commands.
- Health checks configured and passing: met.
- Makefile targets for runtime control: met.
- Documentation current: met.
- No business model/seed beyond startup proof: met.
