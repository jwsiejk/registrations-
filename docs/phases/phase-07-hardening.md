# Phase 07 - Hardening

## Status
Completed.

## Intent
Harden CI and repository hygiene without changing ELT lab runtime behavior, source/warehouse logic, or dbt business logic.

## Guardrails preserved

- No fake ingestion path was added.
- Manual Fivetran account/setup/sync actions remain manual.
- No dbt model business logic changes were introduced.
- No mutation runtime logic changes were introduced.

## What changed in this phase

1. Added explicit Phase 07 documentation record:
   - `docs/phases/phase-07-hardening.md`
2. Enforced Phase 07 doc presence in required-doc validation:
   - `tools/validate/check_required_docs.py`
3. Added focused dbt project structure validator:
   - `tools/validate/check_dbt_project.py`
   - Validates required dbt files and directories only (structure-level contract).
4. Wired dbt project structure validation into local validation flow:
   - `tools/validate/run_all.sh`
   - `Makefile` (`make validate-dbt-project`, included in `make validate` flow)
5. Hardened CI validation workflow:
   - `.github/workflows/ci-validate.yml`
   - CI now:
     - copies `.env.example` to `.env`
     - runs full repo validation (`bash tools/validate/run_all.sh`)
     - installs pinned dbt dependencies (`make dbt-install-deps`)
     - creates dbt profile (`make dbt-profile-setup`)
     - runs dbt parse (`make dbt-parse`)
     - checks mutation target list (`make mutate-list`)
6. Updated docs to describe CI enforcement scope and honest boundaries:
   - `README.md`
   - `docs/operations/validation.md`
   - `docs/operations/validation-tools.md`
   - `docs/standards/testing-standard.md`
   - `docs/README.md`

## Validation performed

- `cp .env.example .env`
- `make validate`
- `python3 tools/validate/check_dbt_project.py`
- `make dbt-install-deps`
- `make dbt-profile-setup`
- `make dbt-parse`
- `make dbt-compile` (failed in this test environment because `dbt` was unavailable after dependency-install network/proxy failure)
- `make mutate-list`

## CI enforcement in this phase

CI enforces:

- Repository validation scripts
- Docker/bootstrap structure validation
- dbt project structure validation
- dbt dependency installation from pinned requirements
- dbt parse
- mutation target listing

CI does **not** enforce, unless corresponding real environment state exists:

- dbt compile (excluded from CI in this phase because local validation showed environment-related dbt installation failure: `ProxyError ... Tunnel connection failed: 403 Forbidden`, followed by `/bin/sh: 1: dbt: not found`)
- manual Fivetran sync success
- raw-source readiness success (`make dbt-raw-source-readiness`)
- `dbt run`/`dbt test` against truly landed raw tables

## Explicitly out of scope

- Fivetran account automation or connector UI automation
- Fake raw-table generation
- Source/warehouse runtime behavior changes
- dbt transformation business logic changes
- Mutation behavior changes
