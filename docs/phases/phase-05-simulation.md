# Phase 05 - Simulation

## Status
Completed.

## Intent
Introduce controlled, deterministic source-side mutation workflows for incremental sync discussion, schema drift, late-arriving data, and data-quality troubleshooting.

## Design guardrails preserved

- No fake source-to-warehouse copy path was introduced.
- Manual Fivetran actions remain manual.
- Mutations are source-side only (`postgres-crm`, `postgres-erp`).
- Baseline Phase 03 seed assets remain unchanged.

## What changed in this phase

1. Added CRM mutation SQL assets:
   - `db/crm/mutate/010_new_opportunity.sql`
   - `db/crm/mutate/020_stage_progression.sql`
   - `db/crm/mutate/030_schema_change_customer_priority.sql`
2. Added ERP mutation SQL assets:
   - `db/erp/mutate/010_new_order.sql`
   - `db/erp/mutate/020_late_arriving_invoice.sql`
   - `db/erp/mutate/030_data_quality_invoice_mismatch.sql`
3. Added explicit mutation runner script:
   - `infra/docker/scripts/apply-mutation`
4. Added explicit Make targets:
   - `mutate-list`
   - `mutate-crm-new-opportunity`
   - `mutate-crm-stage-progression`
   - `mutate-crm-schema-drift`
   - `mutate-erp-new-order`
   - `mutate-erp-late-invoice`
   - `mutate-erp-data-quality-edge`
5. Extended Docker infra validation for mutation layer:
   - `tools/validate/check_docker_infra.py`
   - Requires `infra/docker/scripts/apply-mutation`
   - Requires `db/crm/mutate` and `db/erp/mutate`
   - Requires mutate directories to contain `.sql` files
6. Added Phase 05 operations runbook:
   - `docs/operations/troubleshooting.md`
7. Updated docs and contract mapping:
   - `README.md`
   - `docs/README.md`
   - `docs/operations/reset-reseed.md`
   - `docs/operations/validation.md`
   - `docs/operations/validation-tools.md`
   - `docs/architecture/overview.md`
   - `docs/standards/repo-contract.md`
   - `tools/validate/check_required_docs.py`

Final Phase 05 cleanup alignment also updated:
- architecture overview wording
- testing standard wording
- explicit mutation-runner script documentation
- validation-tools wording for Docker infra validator scope
- Makefile help formatting for mutation targets

## Mutation scenarios added

- CRM deterministic new open opportunity (`3091`) with initial history (`4091`).
- CRM deterministic progression of existing opportunity `3014` from `qualification` to `proposal` with new history (`4092`).
- CRM additive schema drift: `accounts.customer_priority` with deterministic updates.
- ERP deterministic new order (`7091`) with line items (`8091`, `8092`) and no initial invoice.
- ERP deterministic late-arriving invoice (`9091`) for order `7091`, with explicit dependency on prior new-order scenario.
- ERP deterministic controlled data-quality edge case (`7092`/`9092`) with intentional invoice-vs-line mismatch for troubleshooting.

## Validation performed

- Core repo checks and Docker infra validation (`make validate`).
- Source mutation command execution via explicit `make mutate-*` targets.
- Direct SQL verification for each required mutation effect.
- Source baseline restoration via `make docker-reseed-sources`.
- Direct SQL verification that mutation-created rows are removed after reseed.

## What remains manual by design

- Fivetran connector actions, schema reloads, and sync triggers.
- Downstream warehouse/dbt mutation-effect validation until manual Fivetran re-sync is completed.

## Explicitly out of scope

- Any automation of Fivetran account actions.
- Any warehouse raw-table mutation or fake ingestion fallback.
- Phase 06 operator-runbook implementation.
