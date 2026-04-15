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

2. Start local databases:

```bash
make docker-up
```

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

This includes file policy checks, docs checks, and Docker infrastructure existence checks.

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
