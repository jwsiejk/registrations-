# Local Fivetran ELT Lab

## Purpose
This repository builds a realistic local ELT lab in phases.

## Current status
Phase 01 through Phase 04 are in place:

- Repository standards, contracts, and validation tooling
- Local Docker runtime with three PostgreSQL databases:
  - `postgres-crm`
  - `postgres-erp`
  - `postgres-warehouse`
- Realistic CRM and ERP source schemas with deterministic seed data
- Source-only reseed flow for CRM/ERP without resetting warehouse state
- Warehouse bootstrap for analytics schemas (`db/warehouse/bootstrap`)
- dbt Core transformation project under `analytics/dbt`
- Explicit raw-source readiness check for expected Fivetran destination schemas:
  - `fivetran_crm`
  - `fivetran_erp`

Manual Fivetran setup/sync is still required for raw warehouse tables. This repo does not provide a fake ingestion fallback.

## Quick start

1. Copy local environment defaults:

```bash
cp .env.example .env
```

2. Start local databases:

```bash
make docker-up
```

3. Apply warehouse bootstrap to a running warehouse container (safe to rerun):

```bash
make warehouse-bootstrap
```

4. Prepare dbt profile and dependencies:

```bash
make dbt-install-deps
make dbt-profile-setup
make dbt-deps
```

5. Validate parse/compile and raw readiness:

```bash
make dbt-parse
make dbt-compile
make dbt-raw-source-readiness
```

6. If readiness passes after manual Fivetran sync, run dbt transforms/tests:

```bash
make dbt-run
make dbt-test
```

## Local database ports

Default host ports (overridable in `.env`):

- CRM: `localhost:5433`
- ERP: `localhost:5434`
- Warehouse: `localhost:5435`

## Source and warehouse model locations

Business SQL is committed and ordered by filename prefix:

- CRM schema: `db/crm/schema/`
- CRM seed: `db/crm/seed/`
- ERP schema: `db/erp/schema/`
- ERP seed: `db/erp/seed/`
- Warehouse bootstrap: `db/warehouse/bootstrap/`

Docker init entrypoints under `infra/docker/init/crm/`, `infra/docker/init/erp/`, and `infra/docker/init/warehouse/` remain thin wrappers that execute committed SQL.

## Validation

Before running validation locally, create a root `.env` file from the example:

```bash
cp .env.example .env
```

Run all repository checks:

```bash
make validate
```

This includes file policy checks, docs checks, and Docker infrastructure checks.

For dbt and raw-readiness validation flow, see [`docs/operations/validation.md`](docs/operations/validation.md).

## Repository structure

```text
.
├── analytics/dbt/
├── db/
│   ├── crm/
│   ├── erp/
│   └── warehouse/
├── docs/
├── infra/docker/
├── tools/validate/
├── .env.example
├── Makefile
└── README.md
```
