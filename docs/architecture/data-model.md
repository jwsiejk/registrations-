# Source Data Model (Phase 03)

Phase 03 adds deterministic, relational source schemas for CRM and ERP systems.

## CRM source schema (`postgres-crm`)

Tables:
- `accounts`
- `contacts`
- `opportunities`
- `opportunity_history`

Key relationships:
- `contacts.account_id -> accounts.account_id`
- `opportunities.account_id -> accounts.account_id`
- `opportunities.primary_contact_id -> contacts.contact_id`
- `opportunity_history.opportunity_id -> opportunities.opportunity_id`

Behavioral intent:
- Supports open and closed opportunities via `stage`, `is_closed`, and `is_won`
- Maintains mutable timestamps (`created_at`, `updated_at`) for future incremental sync discussions
- Captures stage progression history in `opportunity_history`

## ERP source schema (`postgres-erp`)

Tables:
- `customers`
- `products`
- `orders`
- `order_items`
- `invoices`

Key relationships:
- `orders.customer_id -> customers.customer_id`
- `order_items.order_id -> orders.order_id`
- `order_items.product_id -> products.product_id`
- `invoices.order_id -> orders.order_id` (1:1 invoice-to-order in this seed model)

Behavioral intent:
- Supports mixed operational states (`booked`, `shipped`, `completed`, `cancelled`)
- Supports invoice lifecycle states (`open`, `paid`, `void`)
- Enforces status/timestamp consistency with check constraints
- Maintains mutable timestamps (`created_at`, `updated_at`) for future incremental sync discussions

## Cross-system business bridge key

CRM and ERP are intentionally joinable through stable business keys:

- `crm.accounts.customer_external_id`
- `erp.customers.customer_external_id`

The seed portfolio uses shared `customer_external_id` values (`CUST-1001` ... `CUST-1008`) across both systems to support deterministic customer matching in future customer 360 modeling.

## Seed dataset shape

The committed seed dataset is deterministic and enterprise-like:
- Tens of rows across CRM and ERP tables
- Mixed active/inactive customers/accounts
- Mixed open/closed opportunities
- Mixed booked/shipped/completed/cancelled order statuses
- Mixed open/paid invoices
- Timestamp variation across records

No runtime randomness is used in schema or seed initialization.
