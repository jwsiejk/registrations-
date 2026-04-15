# Validation Workflow (Phase 04)

This runbook explains the honest Phase 04 validation flow for warehouse bootstrap and dbt.

## 1) Bootstrap prerequisites

```bash
cp .env.example .env
make docker-up
make warehouse-bootstrap
```

Notes:
- `make warehouse-bootstrap` is safe and repeatable on running `postgres-warehouse`.
- Fresh warehouse volumes also run bootstrap automatically through `infra/docker/init/warehouse/010-bootstrap.sh`.
- Bootstrap creates dbt analytics schemas (`analytics`, `analytics_staging`, `analytics_intermediate`, `analytics_marts`); it does **not** create fake Fivetran raw tables.
- dbt schema resolution is explicit via `analytics/dbt/macros/generate_schema_name.sql`: models with configured `+schema` land exactly in that schema (no implicit concatenation).

## 2) dbt dependency and profile setup

```bash
make dbt-install-deps
make dbt-profile-setup
make dbt-deps
```

- `make dbt-install-deps` installs pinned and aligned dbt packages from `analytics/dbt/requirements.txt` (`dbt-core==1.10.13`, `dbt-postgres==1.10.13`).
- `make dbt-profile-setup` copies `analytics/dbt/profiles/profiles.template.yml` to `analytics/dbt/profiles/profiles.yml`.
- Profile values use environment variables for host/port/user/password/dbname.

## 3) Parse and compile checks

```bash
make dbt-parse
make dbt-compile
```

- These checks validate project structure, references, and SQL compilation.
- Parse/compile can pass even before raw Fivetran tables exist.

## 4) Raw-source readiness check

```bash
make dbt-raw-source-readiness
```

This check verifies required base tables exist in warehouse schemas:

- `fivetran_crm`: `accounts`, `contacts`, `opportunities`, `opportunity_history`
- `fivetran_erp`: `customers`, `products`, `orders`, `order_items`, `invoices`

Expected behavior:
- **PASS:** all required tables exist (manual Fivetran sync already landed data)
- **FAIL:** one or more required tables are missing

A fail here is the correct and honest result until manual Fivetran setup/sync is complete.

## 5) When dbt run/test are expected to work

Only run these after readiness passes:

```bash
make dbt-run
make dbt-test
```

Interpretation guidance:
- If readiness fails, `dbt run`/`dbt test` are correctly blocked by missing upstream raw tables.
- Do not fabricate raw data and do not claim `dbt run`/`dbt test` passed without actual successful command output.


## 6) Phase 05 source-mutation validation boundary

Phase 05 mutation scenarios are applied only to source systems (`postgres-crm`, `postgres-erp`).

- Apply and verify source-side mutations using `make mutate-*` targets and direct SQL checks.
- Then run manual Fivetran sync in your own account before expecting downstream warehouse/dbt changes.
- Do not claim downstream dbt mutation effects unless manual sync has completed and command output proves it.

Mutation runbook: [`troubleshooting.md`](./troubleshooting.md).
