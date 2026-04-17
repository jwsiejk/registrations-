# Validation Workflow

This runbook defines the honest validation flow for repository gates, dbt structural gates, dbt parse/compile gates, and raw-source readiness boundaries.

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

## 2) Repository validation gates

```bash
make validate
```

`make validate` runs repository validation scripts (via `tools/validate/run_all.sh`), including:

- Repository/documentation/index/top-level validation
- Docker/bootstrap structure validation and compose config validation
- dbt project structure validation (`tools/validate/check_dbt_project.py`)

## 2b) PostgreSQL TLS runtime checks

Run these checks after `make docker-up` to verify TLS is active on each service.

```bash
docker exec postgres-crm psql -U crm_user -d crm -t -A -c "show ssl;"
docker exec postgres-erp psql -U erp_user -d erp -t -A -c "show ssl;"
docker exec postgres-warehouse psql -U warehouse_user -d warehouse -t -A -c "show ssl;"
```

Client SSL negotiation checks:

```bash
PGPASSWORD=crm_password psql "host=localhost port=5433 dbname=crm user=crm_user sslmode=require" -c "\conninfo"
PGPASSWORD=erp_password psql "host=localhost port=5434 dbname=erp user=erp_user sslmode=require" -c "\conninfo"
PGPASSWORD=warehouse_password psql "host=localhost port=5435 dbname=warehouse user=warehouse_user sslmode=require" -c "\conninfo"
```

These checks prove the server is TLS-enabled and the client negotiated SSL successfully.

## 3) dbt dependency and profile setup

```bash
make dbt-install-deps
make dbt-profile-setup
make dbt-deps
```

- `make dbt-install-deps` installs pinned dbt packages from `analytics/dbt/requirements.txt`.
- `make dbt-profile-setup` copies `analytics/dbt/profiles/profiles.template.yml` to `analytics/dbt/profiles/profiles.yml`.

## 4) dbt parse and compile gates

```bash
make dbt-parse
make dbt-compile  # local gate when dbt is installed
```

- These validate dbt project structure, refs/sources, and SQL compilation.
- Parse/compile can pass before raw Fivetran tables exist.
- Parse/compile are not a substitute for real landed raw data validation.

## 5) Raw-source readiness gate (separate, explicit)

```bash
make dbt-raw-source-readiness
```

This check verifies required base tables exist in warehouse schemas:

- `fivetran_crm_public`: `accounts`, `contacts`, `opportunities`, `opportunity_history`
- `fivetran_erp_public`: `customers`, `products`, `orders`, `order_items`, `invoices`

Expected behavior:
- **PASS:** required raw tables exist (manual sync already landed data)
- **FAIL:** one or more required tables are missing

A fail here is correct until manual Fivetran setup + manual sync is completed.

## 6) When dbt run/test are expected to work

Only run these after readiness passes:

```bash
make dbt-run
make dbt-test
```

Interpretation guidance:
- If readiness fails, `dbt run`/`dbt test` are correctly blocked by missing upstream raw tables.
- Do not fabricate raw data and do not claim dbt run/test success without successful command output.

## 7) Mutation usability signal

```bash
make mutate-list
```

`make mutate-list` confirms mutation targets are discoverable and operator-usable.

## 8) CI enforcement summary

CI currently enforces:

- Root `.env` creation from `.env.example`
- Full validation scripts (`bash tools/validate/run_all.sh`)
- dbt dependency installation from pinned requirements
- dbt profile setup from template
- dbt parse
- mutation target listing

CI intentionally does **not** enforce (unless the CI environment truly has that state):

- dbt compile (retained as a local gate in this phase due environment-dependent dbt install constraints observed during validation)
- Manual Fivetran sync success
- Raw-source readiness success
- `dbt run`/`dbt test` against real landed raw tables
