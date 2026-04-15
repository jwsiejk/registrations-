# Phase 06 - Operator Runbook

## Status
Completed.

## Intent
Finalize operator-facing documentation so the repository can be used as a real local ELT lab from day one with manual Fivetran trial sync and Proxy Agent connectivity.

## Guardrails preserved

- Manual Fivetran actions remain manual by design.
- No fake source-to-warehouse ingestion fallback was introduced.
- Phase 06 stays documentation-focused plus required-doc enforcement updates.

## Docs added in this phase

1. `docs/operations/fivetran-setup.md`
   - Primary operator runbook for manual Fivetran setup and sync lifecycle
2. `docs/operations/proxy-agent.md`
   - Proxy Agent role, placement, reachability, and health checks
3. `docs/architecture/networking.md`
   - Durable networking reference (flows, port mappings, traffic classes, schema boundaries)

## Docs updated in this phase

- `README.md`
- `docs/README.md`
- `docs/architecture/README.md`
- `docs/architecture/overview.md`
- `docs/operations/validation.md`
- `docs/operations/troubleshooting.md`
- `docs/phases/phase-06-operator-runbook.md`
- `tools/validate/check_required_docs.py`

Final cleanup note:
- Restored explicit contract-compliant script documentation coverage for `infra/docker/scripts/apply-mutation` in `docs/operations/troubleshooting.md` (purpose, inputs/arguments, exit behavior, example usage).

## Validation performed

- `cp .env.example .env`
- `make validate`
- `make docker-up`
- `make warehouse-bootstrap`
- `make dbt-profile-setup`
- `make mutate-list`
- `make dbt-raw-source-readiness`

Expected result note:
- If raw tables are not yet landed via manual Fivetran sync, readiness fails by design and correctly blocks `make dbt-run`/`make dbt-test`.

## What remains manual by design

- Fivetran account creation and account-level setup
- Connector creation and destination creation
- Proxy Agent installation and registration
- Manual connector sync trigger actions
- Any schema-acceptance/reload action required by your Fivetran setup

## Intentionally out of scope

- Any automation of Fivetran UI/account actions
- Any direct source-to-warehouse copy path in this repository
- Any fake raw table generation/stand-in pathway
- Phase 07 work

## Final operator journey summary

1. Start local runtime and bootstrap warehouse analytics schemas.
2. Configure Fivetran sources/destination manually using repo-derived connection values.
3. Ensure Proxy Agent is manually installed/healthy and can reach mapped local ports.
4. Trigger first manual sync and wait for completion.
5. Run raw readiness check, then dbt run/test when readiness passes.
6. Apply source mutations, manually re-sync affected connectors, then validate again.
7. Use source reseed/full reset runbooks for recovery and repeatable lab operation.
