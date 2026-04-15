# Validation Workflow

This runbook explains the honest validation flow for local runtime, manual Fivetran sync boundary, and dbt execution.

Primary operator references:
- Manual setup + sync flow: [`fivetran-setup.md`](./fivetran-setup.md)
- Proxy Agent connectivity guidance: [`proxy-agent.md`](./proxy-agent.md)
- Mutation troubleshooting and manual re-sync workflow: [`troubleshooting.md`](./troubleshooting.md)

## 1) Bootstrap prerequisites

```bash
cp .env.example .env
make docker-up
make warehouse-bootstrap
```

Notes:
- `make warehouse-bootstrap` is safe and repeatable on running `postgres-warehouse`.
- Fresh warehouse volumes also run bootstrap automatically through `infra/docker/init/warehouse/010-bootstrap.sh`.
- Bootstrap creates dbt analytics schemas (`analytics`, `analytics_staging`, `analytics_intermediate`, `analytics_marts`); it does **not** create raw Fivetran tables.

## 2) dbt dependency and profile setup

```bash
make dbt-install-deps
make dbt-profile-setup
make dbt-deps
```

- `make dbt-install-deps` installs pinned dbt packages from `analytics/dbt/requirements.txt`.
- `make dbt-profile-setup` copies `analytics/dbt/profiles/profiles.template.yml` to `analytics/dbt/profiles/profiles.yml`.

## 3) Parse and compile checks

```bash
make dbt-parse
make dbt-compile
```

- These validate project structure, references, and SQL compilation.
- Parse/compile can pass before raw Fivetran tables exist.

## 4) Raw-source readiness check

```bash
make dbt-raw-source-readiness
```

This check verifies required base tables exist in warehouse schemas:

- `fivetran_crm`: `accounts`, `contacts`, `opportunities`, `opportunity_history`
- `fivetran_erp`: `customers`, `products`, `orders`, `order_items`, `invoices`

Expected behavior:
- **PASS:** required raw tables exist (manual sync already landed data)
- **FAIL:** one or more required tables are missing

A fail here is correct until manual Fivetran setup + manual sync is completed.

## 5) When dbt run/test are expected to work

Only run these after readiness passes:

```bash
make dbt-run
make dbt-test
```

Interpretation guidance:
- If readiness fails, `dbt run`/`dbt test` are correctly blocked by missing upstream raw tables.
- Do not fabricate raw data and do not claim dbt success without successful command output.

## 6) Mutation validation boundary

Mutation scenarios are source-side only (`postgres-crm`, `postgres-erp`).

- Apply and verify source-side mutations using `make mutate-*` and direct SQL checks.
- Then run manual sync for affected connector(s).
- Only then expect downstream raw/dbt changes.

For detailed mutation operations and recovery guidance, see [`troubleshooting.md`](./troubleshooting.md) and [`reset-reseed.md`](./reset-reseed.md).
