# Phase 04 - dbt

## Status
Completed.

## Intent
Implement warehouse bootstrap and a real dbt transformation layer for the local ELT lab.

## What changed in this phase

1. Added warehouse bootstrap business SQL:
   - `db/warehouse/bootstrap/010_create_analytics_schemas.sql`
2. Added thin warehouse init entrypoint:
   - `infra/docker/init/warehouse/010-bootstrap.sh`
3. Wired warehouse bootstrap SQL mount in compose:
   - `infra/docker/compose.yaml` mounts `db/warehouse` to `/opt/bootstrap/warehouse`
4. Added repeatable bootstrap command for running warehouse containers:
   - `infra/docker/scripts/bootstrap-warehouse`
   - `make warehouse-bootstrap`
5. Added dbt Core project:
   - `analytics/dbt/dbt_project.yml`
   - `analytics/dbt/profiles/profiles.template.yml`
   - `analytics/dbt/requirements.txt`
   - Layered staging/intermediate/marts models and YAML tests
6. Added dbt source definitions against required raw schemas:
   - `fivetran_crm` (`accounts`, `contacts`, `opportunities`, `opportunity_history`)
   - `fivetran_erp` (`customers`, `products`, `orders`, `order_items`, `invoices`)
7. Added Phase 04 Make targets:
   - `dbt-profile-setup`, `dbt-install-deps`, `dbt-deps`, `dbt-parse`, `dbt-compile`, `dbt-raw-source-readiness`, `dbt-run`, `dbt-test`
8. Added explicit raw-source readiness checker:
   - `tools/validate/check_dbt_raw_sources.py`
9. Phase 04 hardening follow-up completed:
   - Aligned dbt package pins in `analytics/dbt/requirements.txt` to `dbt-core==1.10.13` and `dbt-postgres==1.10.0`
   - Added explicit dbt schema resolution macro (`analytics/dbt/macros/generate_schema_name.sql`) so configured model schemas are used exactly
   - Updated warehouse bootstrap SQL to create `analytics` plus layer schemas (`analytics_staging`, `analytics_intermediate`, `analytics_marts`)
   - Tightened Docker infra validation coverage to require warehouse init script and clearer Phase 4 messaging
   - Restored operations/contract script-documentation coverage for warehouse init/bootstrap scripts
   - Added repo-local dbt artifact ignore rules for profile/target/packages/logs
   - Final Phase 4 wording/docs cleanup aligned validator messaging, validation-tools directory lists, and reset/reseed docs with implemented warehouse fresh-volume bootstrap behavior

## Validation performed

- `cp .env.example .env`
- `make validate`
- `make docker-up`
- `make warehouse-bootstrap`
- `make dbt-install-deps`
  - Installs pinned dbt adapter/runtime packages from `analytics/dbt/requirements.txt` via `python3 -m pip install -r analytics/dbt/requirements.txt`
- `python3 -m pip show dbt-core dbt-postgres`
- `make dbt-profile-setup`
- `make dbt-deps`
- `make dbt-parse`
- `make dbt-compile`
- `make dbt-raw-source-readiness`

When raw readiness fails because manual Fivetran sync has not landed required tables, `dbt run` and `dbt test` are intentionally blocked and not treated as passing.

## Remaining intentional blockers

- Manual Fivetran trial setup and manual connector sync are still required to create and populate raw warehouse tables.
- Until those actions are completed, `make dbt-raw-source-readiness` fails by design and `make dbt-run` / `make dbt-test` cannot complete successfully.

## Explicitly out of scope

- Any fake ingestion path from source systems into warehouse
- Any automated Fivetran account or connector actions
- Phase 05 mutation/re-sync scenarios
