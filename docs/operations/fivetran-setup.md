# Manual Fivetran Setup Runbook (Phase 06)

This is the primary operator runbook for using this repository as a real local ELT lab with manual Fivetran trial setup.

## 1) Purpose and scope

This document covers:
- local runtime preparation from this repository
- exact local connection values to use for source and destination databases
- manual Fivetran source/destination setup expectations
- Proxy Agent usage expectations in a local/private network context
- first-sync and ongoing re-sync workflow with honest validation boundaries

Manual Fivetran actions are **manual by design**. This repository intentionally does **not** automate:
- Fivetran account creation
- connector creation
- destination creation
- Proxy Agent registration
- manual sync triggers
- schema acceptance/reload actions

The repository provides local systems, deterministic source data, dbt project assets, and validation runbooks—not vendor-account automation.

## 2) Exact local connection values (repo-derived)

Use these repo-local values unless you intentionally override host ports in root `.env`.

### Source: CRM (`postgres-crm`)

- Host: `localhost` (or the Docker host reachable from your Proxy Agent runtime)
- Host port: `5433` by default (`CRM_DB_PORT` override in root `.env`)
- Database: `crm`
- User: `crm_user`
- Password: `crm_password`

Source of truth:
- Port mapping: `infra/docker/compose.yaml`
- Default host port variable: `.env.example`
- DB name/user/password: `infra/docker/compose/postgres-crm.env`

### Source: ERP (`postgres-erp`)

- Host: `localhost` (or the Docker host reachable from your Proxy Agent runtime)
- Host port: `5434` by default (`ERP_DB_PORT` override in root `.env`)
- Database: `erp`
- User: `erp_user`
- Password: `erp_password`

Source of truth:
- Port mapping: `infra/docker/compose.yaml`
- Default host port variable: `.env.example`
- DB name/user/password: `infra/docker/compose/postgres-erp.env`

### Destination: Warehouse (`postgres-warehouse`)

- Host: `localhost` (or the Docker host reachable from your Proxy Agent runtime)
- Host port: `5435` by default (`WAREHOUSE_DB_PORT` override in root `.env`)
- Database: `warehouse`
- User: `warehouse_user`
- Password: `warehouse_password`

Source of truth:
- Port mapping: `infra/docker/compose.yaml`
- Default host port variable: `.env.example`
- DB name/user/password: `infra/docker/compose/postgres-warehouse.env`

## 2b) TLS settings for manual Postgres connectors/destination

All local Postgres services are TLS-enabled. For manual Fivetran configuration through Proxy Agent, configure PostgreSQL SSL mode as follows:

- **Minimum:** `require`
- **Preferred for validation-heavy runs:** `verify-ca` with CA certificate from:
  - `infra/docker/tls/crm/ca.crt`
  - `infra/docker/tls/erp/ca.crt`
  - `infra/docker/tls/warehouse/ca.crt`

The certificate assets are generated locally by `make docker-up` (or manually via `make docker-tls-setup`).

## 3) Source table and destination schema expectations

### Expected source tables

CRM source (`public`):
- `accounts`
- `contacts`
- `opportunities`
- `opportunity_history`

ERP source (`public`):
- `customers`
- `products`
- `orders`
- `order_items`
- `invoices`

### Expected destination raw schemas

Manual Fivetran sync is expected to land raw tables in:
- `fivetran_crm_public`
- `fivetran_erp_public`

These raw schema/table expectations are enforced by `make dbt-raw-source-readiness`.

### Expected dbt analytics schemas

Warehouse bootstrap + dbt modeling use:
- `analytics`
- `analytics_staging`
- `analytics_intermediate`
- `analytics_marts`

## 4) End-to-end operator runbook

1. Create local environment file:

   ```bash
   cp .env.example .env
   ```

2. Start local services:

   ```bash
   make docker-up
   ```

3. Bootstrap warehouse analytics schemas:

   ```bash
   make warehouse-bootstrap
   ```

4. Prepare dbt profile and dependencies:

   ```bash
   make dbt-install-deps
   make dbt-profile-setup
   make dbt-deps
   ```

5. In your Fivetran account, configure source connectors manually:
   - one connector for CRM source Postgres
   - one connector for ERP source Postgres
   - use repo-derived source connection values from Section 2

6. In your Fivetran account, configure the warehouse destination manually:
   - PostgreSQL destination targeting `postgres-warehouse`
   - use repo-derived destination connection values from Section 2

7. Use Proxy Agent appropriately:
   - ensure the agent is installed/registered manually
   - ensure it can reach the Docker host + mapped source/destination ports
   - follow [`proxy-agent.md`](./proxy-agent.md)

8. Run first manual sync in Fivetran:
   - trigger connector sync(s) manually
   - wait for completion in Fivetran

9. Check raw-source readiness locally:

   ```bash
   make dbt-raw-source-readiness
   ```

10. When readiness passes, run dbt workflow:

    ```bash
    make dbt-parse
    make dbt-compile
    make dbt-run
    make dbt-test
    ```

11. Apply deterministic mutation scenarios as needed:

    ```bash
    make mutate-list
    # then one or more make mutate-* targets
    ```

12. Manually re-sync only affected connector(s) in Fivetran:
    - CRM mutation -> re-sync CRM connector
    - ERP mutation -> re-sync ERP connector
    - cross-system scenario -> re-sync both as needed

13. Validate again after sync completion:

    ```bash
    make dbt-raw-source-readiness
    make dbt-run
    make dbt-test
    ```

14. Reset/reseed when needed:

    ```bash
    make docker-reseed-sources
    # or make docker-reset + make docker-up for full reset
    ```

    Then manually re-sync affected connector(s) so warehouse raw state catches up.

## 5) Manual action boundaries

These manual actions remain required:

- **After initial setup:** manually create source connectors, destination, Proxy Agent registration, and first sync.
- **After schema drift mutation (`make mutate-crm-schema-drift`):** manually re-sync CRM and perform any Fivetran schema-accept/reload actions your setup requires.
- **After late-arriving data mutation (`make mutate-erp-late-invoice`):** manually re-sync ERP.
- **After source reseed (`make docker-reseed-sources`):** manually re-sync affected connector(s) to realign raw warehouse state.

## 6) Honest validation expectations

- `make dbt-raw-source-readiness` is expected to fail **before** manual Fivetran sync lands required raw tables.
- `make dbt-run` and `make dbt-test` are correctly blocked until raw-source readiness passes.
- Source-side mutation commands can still be run and source-side SQL verification can still pass independently before manual re-sync.

## Related docs

- Proxy Agent guidance: [`proxy-agent.md`](./proxy-agent.md)
- Networking reference: [`../architecture/networking.md`](../architecture/networking.md)
- Validation workflow: [`validation.md`](./validation.md)
- Mutation troubleshooting: [`troubleshooting.md`](./troubleshooting.md)
- Reset/reseed behavior: [`reset-reseed.md`](./reset-reseed.md)
