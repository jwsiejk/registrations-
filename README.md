# Local Fivetran ELT Lab

## Purpose
This repository provides a realistic local ELT lab with PostgreSQL sources, PostgreSQL warehouse destination, dbt transformations, and deterministic mutation scenarios.

Design goal:

`source Postgres -> manual Fivetran sync -> warehouse Postgres raw schemas -> dbt -> validation -> mutate -> manual re-sync -> validation`

## Current status
Phase 01 through Phase 07 are in place:

- Repository standards, contracts, and validation tooling
- Local Docker runtime with three PostgreSQL databases:
  - `postgres-crm`
  - `postgres-erp`
  - `postgres-warehouse`
- Realistic CRM and ERP source schemas with deterministic seed data
- Source-only reseed flow for CRM/ERP without resetting warehouse state
- Warehouse bootstrap for analytics schemas (`db/warehouse/bootstrap`)
- dbt Core transformation project under `analytics/dbt`
- Explicit dbt schema routing to exact layer schemas (`analytics_staging`, `analytics_intermediate`, `analytics_marts`)
- Explicit raw-source readiness check for expected Fivetran destination schemas:
  - `fivetran_crm`
  - `fivetran_erp`
- Controlled source-side mutation scenarios for CRM/ERP under `db/*/mutate`
- Operator documentation for manual Fivetran and Proxy Agent setup
- Phase 07 CI/validation hardening for repo structure and dbt project structure gates

Manual Fivetran actions remain manual by design. This repo does not automate Fivetran account/connector/destination/agent actions and does not include a fake ingestion fallback.

## Where to start

- Local runtime setup: [`docs/operations/local-setup.md`](docs/operations/local-setup.md)
- Manual Fivetran setup runbook: [`docs/operations/fivetran-setup.md`](docs/operations/fivetran-setup.md)
- Proxy Agent guidance: [`docs/operations/proxy-agent.md`](docs/operations/proxy-agent.md)
- Validation workflow: [`docs/operations/validation.md`](docs/operations/validation.md)
- Mutation troubleshooting: [`docs/operations/troubleshooting.md`](docs/operations/troubleshooting.md)

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

5. Configure Fivetran and Proxy Agent manually using:

- [`docs/operations/fivetran-setup.md`](docs/operations/fivetran-setup.md)
- [`docs/operations/proxy-agent.md`](docs/operations/proxy-agent.md)

6. Run readiness and dbt commands:

```bash
make dbt-raw-source-readiness
# when readiness passes after manual sync:
make dbt-parse
make dbt-compile  # local gate when dbt is installed
make dbt-run
make dbt-test
```

## Local database ports

Default host ports (overridable in `.env`):

- CRM: `localhost:5433`
- ERP: `localhost:5434`
- Warehouse: `localhost:5435`

## Validation

Before running validation locally, create root `.env`:

```bash
cp .env.example .env
```

Run repository checks:

```bash
make validate
```

Useful targeted checks:

```bash
make validate-dbt-project
make dbt-parse
make dbt-compile  # local gate when dbt is installed
make mutate-list
```

## CI enforcement summary

CI enforces:

- root `.env` creation from `.env.example`
- repository validation scripts (`bash tools/validate/run_all.sh`)
- Docker/bootstrap structure validation
- dbt project structure validation
- dbt dependency installation from pinned requirements
- dbt profile setup
- dbt parse
- mutation target listing (`make mutate-list`)

CI intentionally does **not** enforce unless environment state truly exists:

- dbt compile (kept as a local gate in this phase due environment-dependent dbt install constraints observed during validation)
- manual Fivetran sync success
- raw-source readiness success (`make dbt-raw-source-readiness`)
- `dbt run` / `dbt test` against real landed raw tables

For full operator flow, see:
- Phase 07 hardening record: [`docs/phases/phase-07-hardening.md`](docs/phases/phase-07-hardening.md)
- Validation workflow: [`docs/operations/validation.md`](docs/operations/validation.md)

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
