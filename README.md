# Local Fivetran ELT Lab

## Purpose
This repository builds a realistic local ELT lab in phases.

## Current status
Phase 01 and Phase 02 foundations are now in place:

- Repository standards, contracts, and validation tooling
- Local Docker runtime with three PostgreSQL databases:
  - `postgres-crm`
  - `postgres-erp`
  - `postgres-warehouse`

Business schemas, seed data, and transformation logic are intentionally deferred to later phases.

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

4. Stop services:

```bash
make docker-down
```

For full operations guidance, see [`docs/operations/local-setup.md`](docs/operations/local-setup.md).

## Local database ports

Default host ports (overridable in `.env`):

- CRM: `localhost:5433`
- ERP: `localhost:5434`
- Warehouse: `localhost:5435`

## Validation

Run all repository checks:

```bash
make validate
```

This includes file policy checks, docs checks, and Docker infrastructure checks for required paths plus Compose config validation.

## Repository structure

```text
.
├── docs/
├── infra/docker/
├── tools/validate/
├── .env.example
├── Makefile
└── README.md
```
