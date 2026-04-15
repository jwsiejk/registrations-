# Phase 05/06 Mutation Troubleshooting Runbook

This runbook documents controlled, source-side mutation scenarios and the required manual re-sync expectations for downstream validation.

## Guardrails

- Mutations are source-side only (`postgres-crm` and `postgres-erp`).
- Warehouse raw schemas are never mutated directly in this repo.
- Manual Fivetran actions remain manual by design.
- No fake ingestion path exists in this repository.

## Preconditions

```bash
cp .env.example .env
make docker-up
make mutate-list
```

## Manual re-sync expectation (critical)

After **any** source mutation, downstream warehouse/dbt impact is not expected until manual sync runs for the affected connector(s).

- CRM mutation -> manual CRM connector sync
- ERP mutation -> manual ERP connector sync
- Mixed scenario -> sync both as needed

If sync has not yet completed, `make dbt-raw-source-readiness` may still fail or downstream dbt outputs may still reflect old raw data.

## Mutation runner

Script: `infra/docker/scripts/apply-mutation`

Usage:

```bash
bash infra/docker/scripts/apply-mutation <crm|erp> <mutation-file.sql>
```

The script fails clearly when `.env` is missing, target container is unavailable, mutation file is missing, or SQL execution fails.

## Scenario catalog

### CRM scenarios

1. `make mutate-crm-new-opportunity`
   - SQL: `db/crm/mutate/010_new_opportunity.sql`
   - Adds deterministic open opportunity `3091` and history `4091`
   - Next manual action: re-sync CRM connector

2. `make mutate-crm-stage-progression`
   - SQL: `db/crm/mutate/020_stage_progression.sql`
   - Advances opportunity `3014` to `proposal` and adds history `4092`
   - Next manual action: re-sync CRM connector

3. `make mutate-crm-schema-drift`
   - SQL: `db/crm/mutate/030_schema_change_customer_priority.sql`
   - Adds nullable `accounts.customer_priority` and deterministic values
   - Next manual action: re-sync CRM connector; perform schema accept/reload actions manually if required by your Fivetran setup

### ERP scenarios

4. `make mutate-erp-new-order`
   - SQL: `db/erp/mutate/010_new_order.sql`
   - Adds deterministic order `7091` and line items `8091`, `8092` with no invoice
   - Next manual action: re-sync ERP connector

5. `make mutate-erp-late-invoice`
   - SQL: `db/erp/mutate/020_late_arriving_invoice.sql`
   - Adds late invoice `9091` for order `7091`
   - Dependency: scenario 4 must run first
   - Next manual action: re-sync ERP connector

6. `make mutate-erp-data-quality-edge`
   - SQL: `db/erp/mutate/030_data_quality_invoice_mismatch.sql`
   - Adds deterministic invoice mismatch case (`7092`/`9092`)
   - Next manual action: re-sync ERP connector

## Post-sync validation sequence

After manual sync completion:

```bash
make dbt-raw-source-readiness
make dbt-run
make dbt-test
```

## Reset/reseed behavior

To restore source baseline:

```bash
make docker-reseed-sources
```

Important:
- Reseed resets CRM/ERP sources only.
- Warehouse is not reset by source reseed.
- Manual re-sync is required to realign warehouse raw state with reseeded sources.

For full destructive reset + fresh volume bootstrap, use guidance in [`reset-reseed.md`](./reset-reseed.md).

## Related docs

- Manual setup flow: [`fivetran-setup.md`](./fivetran-setup.md)
- Proxy Agent guidance: [`proxy-agent.md`](./proxy-agent.md)
- Validation workflow: [`validation.md`](./validation.md)
