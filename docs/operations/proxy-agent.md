# Proxy Agent Guidance (Phase 06)

This document explains the Proxy Agent role in the local/private ELT lab without relying on brittle vendor-UI wording.

## 1) Purpose

In this lab, source and destination PostgreSQL services are local/private Docker services rather than internet-public databases.

A Proxy Agent (operator-installed, operator-managed) acts as a bridge so Fivetran cloud services can securely reach those local/private endpoints.

Within this repository design, Proxy Agent enables the intended flow:

`source Postgres -> manual Fivetran sync -> warehouse raw schemas -> dbt`

## 2) Placement and network role

Conceptually, place Proxy Agent where it can reach:
- the Docker host/local machine network where Postgres ports are exposed
- CRM source endpoint (`postgres-crm` host port)
- ERP source endpoint (`postgres-erp` host port)
- warehouse destination endpoint (`postgres-warehouse` host port)

High-level path:
- Fivetran cloud communicates with the registered Proxy Agent
- Proxy Agent forwards source read and destination write traffic to your local Postgres endpoints

See networking details in [`../architecture/networking.md`](../architecture/networking.md).

## 3) Required reachability

Before configuring connectors/destination, ensure the machine running Proxy Agent can resolve and reach the Docker host and mapped ports.

Repo-local defaults:
- CRM source: host port `5433` (override: `CRM_DB_PORT`)
- ERP source: host port `5434` (override: `ERP_DB_PORT`)
- Warehouse destination: host port `5435` (override: `WAREHOUSE_DB_PORT`)

If ports are overridden in root `.env`, those override values are the ones the agent path must reach.

## 4) Practical validation and health checks

Use this order before blaming Fivetran.

### A) Verify local services are up

```bash
make docker-status
```

If services are not running/healthy:
- run `make docker-up`
- re-check health before testing connector connectivity

### B) Verify warehouse bootstrap baseline exists

```bash
make warehouse-bootstrap
```

This ensures analytics schemas exist; it does **not** create raw Fivetran tables.

### C) Verify local credentials and endpoints match repo values

Check:
- `infra/docker/compose/postgres-crm.env`
- `infra/docker/compose/postgres-erp.env`
- `infra/docker/compose/postgres-warehouse.env`
- `infra/docker/compose.yaml`
- root `.env`

### D) Distinguish common failure classes

- **Local service down:** `make docker-status` shows service unavailable/unhealthy; local runtime issue.
- **Bad credentials:** service is healthy but connector/destination auth fails; compare against env files above.
- **Proxy Agent not healthy/registered:** local DBs are reachable from host, but Fivetran cannot connect through agent; check agent installation/registration/runtime health in your Fivetran account tooling.
- **Raw-source sync not completed yet:** local services and credentials are correct, but `make dbt-raw-source-readiness` still reports missing `fivetran_crm` / `fivetran_erp` tables; manual sync has not landed all required raw tables yet.

## 5) What remains manual

Manual by design:
- Proxy Agent installation and registration
- any Fivetran-side agent/connector/destination configuration
- manual sync triggering and any schema-accept/reload actions

This repository intentionally does not automate these external-account actions.

## Related docs

- Primary setup runbook: [`fivetran-setup.md`](./fivetran-setup.md)
- Validation flow: [`validation.md`](./validation.md)
- Troubleshooting runbook: [`troubleshooting.md`](./troubleshooting.md)
