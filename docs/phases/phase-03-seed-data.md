# Phase 03 - Seed Data

## Status
Completed.

## Intent
Add repeatable, deterministic source schemas and seed data for local ELT experiments.

## What changed in this phase

1. Added committed business SQL with explicit execution ordering:
   - CRM schema: `db/crm/schema/*.sql`
   - CRM seed: `db/crm/seed/*.sql`
   - ERP schema: `db/erp/schema/*.sql`
   - ERP seed: `db/erp/seed/*.sql`
2. Added realistic CRM source model tables:
   - `accounts`
   - `contacts`
   - `opportunities`
   - `opportunity_history`
3. Added realistic ERP source model tables:
   - `customers`
   - `products`
   - `orders`
   - `order_items`
   - `invoices`
4. Added relational constraints (PK/FK/check constraints) and mutable timestamps (`created_at`, `updated_at`) on operational tables.
5. Added deterministic, enterprise-style seed data with mixed business states:
   - Active/inactive customers/accounts
   - Open and closed opportunities
   - Booked/shipped/completed/cancelled orders
   - Open and paid invoices
6. Added stable cross-system bridge key:
   - `customer_external_id` shared across CRM `accounts` and ERP `customers`
7. Kept Docker init directories as thin entrypoints and wired them to execute SQL from `db/...`.
8. Added source-only reseed scripts for running environments:
   - `infra/docker/scripts/reseed-crm`
   - `infra/docker/scripts/reseed-erp`
   - `infra/docker/scripts/reseed-sources`
9. Added Make targets for reseed operations:
   - `docker-reseed-crm`
   - `docker-reseed-erp`
   - `docker-reseed-sources`
10. Added/updated docs for data model and operations:
    - Added `docs/architecture/data-model.md`
    - Added `docs/operations/reset-reseed.md`
    - Updated README and operations/architecture indexes
    - Updated `tools/validate/check_required_docs.py` required docs list
11. Final Phase 03 cleanup aligned repository contract wording, validation script documentation, and operations runbooks with committed Docker runtime/reset/reseed script behavior.
12. Final Phase 03 follow-up explicitly aligned documentation coverage for Docker init/bootstrap scripts (`infra/docker/init/crm/010-bootstrap.sh`, `infra/docker/init/erp/010-bootstrap.sh`) in the repo contract and local setup runbook.

## Validation performed

- Repository validation via `make validate`, including checks that thin bootstrap scripts and committed `db/...` source SQL directories/files required by Phase 03 are present
- Fresh bootstrap validation via `make docker-reset` then `make docker-up`
- Source-only reseed validation via `make docker-reseed-sources`
- Direct SQL verification for table existence and representative row counts on CRM and ERP

## Explicitly out of scope

- Warehouse bootstrap schema/data
- dbt modeling
- mutation/re-sync automation
- any Fivetran account automation
