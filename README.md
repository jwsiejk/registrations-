# Local Fivetran ELT Lab

## Purpose
This repository builds a realistic local ELT lab in phases.

## Current status
Phase 01, Phase 02, and Phase 03 are in place:

- Repository standards, contracts, and validation tooling
- Local Docker runtime with three PostgreSQL databases:
  - `postgres-crm`
  - `postgres-erp`
  - `postgres-warehouse`
- Realistic CRM and ERP source schemas with deterministic seed data
- Source-only reseed flow for CRM/ERP without resetting warehouse state

Phase 04+ work (warehouse modeling, dbt, mutation/re-sync) is intentionally out of scope in current state.

## Quick start

1. Copy local environment defaults:

```bash
cp .env.example .env
```

The root `.env` file is required by Docker helper scripts and is passed explicitly to Compose via `--env-file`.

2. Start local databases:

```bash
make docker-up
```

`make docker-up` returns success only after all three Postgres services report healthy.

3. Check service state:

```bash
make docker-status
```

4. (Optional) Reseed CRM + ERP source systems on running containers:

```bash
make docker-reseed-sources
```

5. Stop services:

```bash
make docker-down
```

For full operations guidance, see [`docs/operations/local-setup.md`](docs/operations/local-setup.md) and [`docs/operations/reset-reseed.md`](docs/operations/reset-reseed.md).

## Local database ports

Default host ports (overridable in `.env`):

- CRM: `localhost:5433`
- ERP: `localhost:5434`
- Warehouse: `localhost:5435`

## Source model locations

Business SQL for source systems is committed and ordered by filename prefix:

- CRM schema: `db/crm/schema/`
- CRM seed: `db/crm/seed/`
- ERP schema: `db/erp/schema/`
- ERP seed: `db/erp/seed/`

Docker init entrypoints under `infra/docker/init/crm/` and `infra/docker/init/erp/` remain thin wrappers that execute these SQL files.

## Validation

Before running validation locally, create a root `.env` file from the example:

```bash
cp .env.example .env
```

`make validate` runs Docker infrastructure validation, and `check_docker_infra.py` requires this root `.env`.
CI follows the same prerequisite by creating `.env` from `.env.example` before running validation.

Run all repository checks:

```bash
make validate
```

This includes file policy checks, docs checks, and Docker infrastructure checks for required paths plus Compose config validation.

## Repository structure

```text
.
├── db/
│   ├── crm/
│   └── erp/
├── docs/
├── infra/docker/
├── tools/validate/
├── .env.example
├── Makefile
└── README.md
```
