# Phase 05 Mutation Troubleshooting Runbook

This runbook documents controlled, source-side mutation scenarios used to discuss incremental sync behavior, schema drift, late-arriving data, and data-quality troubleshooting.

## Guardrails

- Mutations are source-side only (`postgres-crm` and `postgres-erp`).
- Warehouse raw schemas are never mutated directly in this repo.
- Manual Fivetran actions remain manual by design.
- Mutation SQL is deterministic (fixed IDs/timestamps/values) and committed under `db/*/mutate`.

## Preconditions

1. Create environment file:

   ```bash
   cp .env.example .env
   ```

2. Start containers:

   ```bash
   make docker-up
   ```

3. List available scenarios:

   ```bash
   make mutate-list
   ```

## Mutation runner

Script: `infra/docker/scripts/apply-mutation`

Usage:

```bash
bash infra/docker/scripts/apply-mutation <crm|erp> <mutation-file.sql>
```

The script fails clearly when `.env` is missing, the target container is unavailable, the mutation file does not exist, or SQL execution fails.

## CRM mutation scenarios

### 1) New opportunity
- SQL: `db/crm/mutate/010_new_opportunity.sql`
- Command:

  ```bash
  make mutate-crm-new-opportunity
  ```

- Source change:
  - Inserts `opportunities.opportunity_id = 3091` for account `1008` and contact `2015`
  - Inserts history row `opportunity_history_id = 4091`
- Dependency: none.
- Manual Fivetran next step: run CRM connector sync manually.
- Expected downstream impact after manual sync + dbt run:
  - New open pipeline row appears for customer `CUST-1008`.

### 2) Stage progression
- SQL: `db/crm/mutate/020_stage_progression.sql`
- Command:

  ```bash
  make mutate-crm-stage-progression
  ```

- Source change:
  - Advances `opportunity_id = 3014` from `qualification` to `proposal`
  - Updates `updated_at`
  - Inserts deterministic history row `opportunity_history_id = 4092`
- Dependency: none.
- Manual Fivetran next step: run CRM connector sync manually.
- Expected downstream impact after manual sync + dbt run:
  - `fct_pipeline` reflects stage `proposal`; stage-change metrics advance.

### 3) Additive schema drift
- SQL: `db/crm/mutate/030_schema_change_customer_priority.sql`
- Command:

  ```bash
  make mutate-crm-schema-drift
  ```

- Source change:
  - Adds nullable `accounts.customer_priority`
  - Populates deterministic values for accounts `1001`, `1003`, `1008`
- Dependency: none.
- Manual Fivetran next step: run CRM connector sync manually (and perform connector schema refresh if your Fivetran setup requires explicit schema acceptance).
- Expected downstream impact after manual sync + dbt updates:
  - New raw column becomes available in `fivetran_crm.accounts`; dbt models can be extended intentionally in later changes.

## ERP mutation scenarios

### 4) New order (no invoice)
- SQL: `db/erp/mutate/010_new_order.sql`
- Command:

  ```bash
  make mutate-erp-new-order
  ```

- Source change:
  - Inserts `orders.order_id = 7091` for active customer `5008`
  - Inserts line items `order_item_id = 8091`, `8092`
  - Leaves invoice absent for late-arriving invoice simulation
- Dependency: none.
- Manual Fivetran next step: run ERP connector sync manually.
- Expected downstream impact after manual sync + dbt run:
  - `fct_orders` includes a new order with null invoice fields until invoice arrives.

### 5) Late-arriving invoice
- SQL: `db/erp/mutate/020_late_arriving_invoice.sql`
- Command:

  ```bash
  make mutate-erp-late-invoice
  ```

- Source change:
  - Inserts late invoice `invoice_id = 9091` for `order_id = 7091`
- Dependency:
  - Requires scenario 4 (`make mutate-erp-new-order`) first; SQL fails clearly if `order_id = 7091` is missing.
- Manual Fivetran next step: run ERP connector sync manually.
- Expected downstream impact after manual sync + dbt run:
  - Existing order `7091` gains invoice fields in marts.

### 6) Controlled data-quality edge case
- SQL: `db/erp/mutate/030_data_quality_invoice_mismatch.sql`
- Command:

  ```bash
  make mutate-erp-data-quality-edge
  ```

- Source change:
  - Inserts `orders.order_id = 7092` for active customer `5005`
  - Inserts line items `order_item_id = 8093`, `8094`
  - Inserts invoice `invoice_id = 9092`
  - Intentionally sets invoice total to differ slightly from summed line amount
- Dependency: none.
- Manual Fivetran next step: run ERP connector sync manually.
- Expected downstream impact after manual sync + dbt run:
  - `fct_orders` exposes deterministic mismatch useful for troubleshooting/tests.

## Manual Fivetran step (always required)

After applying any mutation scenario:
1. Open your Fivetran account.
2. Trigger manual sync for affected connector(s): CRM and/or ERP.
3. Wait for sync completion.
4. Re-run readiness and dbt checks as appropriate:

```bash
make dbt-raw-source-readiness
make dbt-run
make dbt-test
```

If manual sync has not occurred, downstream warehouse/dbt validation remains intentionally blocked.

## Return to baseline

Use source reseed to remove mutation effects from CRM/ERP:

```bash
make docker-reseed-sources
```

Important:
- This resets CRM and ERP only.
- Warehouse is not reset by source reseed.
- To align warehouse raw state with reset sources, manually re-sync Fivetran after reseed.
