# Testing Standard

## Objective
Ensure every phase introduces verifiable checks and keeps quality gates executable locally and in CI.

## Baseline testing requirements

- Validation checks must be runnable locally and in CI.
- Failures must return non-zero exit codes.
- Error output must identify what failed and where.
- `make validate` must remain the primary repository validation entrypoint.
- Direct script execution must also be supported for targeted checks.

## Validation and CI gate categories

The repository testing/validation standard distinguishes these gates:

1. **Repository validation gates**
   - Policy/documentation/index/top-level checks and Docker/bootstrap structure checks.
2. **dbt project structure gate**
   - Required dbt files/directories exist and remain coherent.
3. **dbt parse/compile gates**
   - dbt project parses/compiles with pinned dependencies and a generated profile.
4. **Raw-source readiness gate (separate, honest gate)**
   - Required raw Fivetran schemas/tables must exist before `dbt run`/`dbt test`.
5. **Mutation-list usability gate**
   - Mutation targets are listed and available to operators.

## CI enforcement baseline

CI must enforce at least:

- `cp .env.example .env`
- Full repository validation (`bash tools/validate/run_all.sh`)
- dbt dependency installation from `analytics/dbt/requirements.txt`
- dbt profile setup from template
- `make dbt-parse`
- `make mutate-list`

When compile is truthful in CI environment, CI should also run `make dbt-compile`.

## Honest boundary

Unless environment state actually exists, CI does **not** prove:

- Manual Fivetran sync success
- Raw-source readiness success
- `dbt run`/`dbt test` success against real landed raw tables
