with order_rollup as (
  select
    customer_external_id,
    count(*) as order_count,
    sum(gross_order_amount_usd) as gross_order_amount_usd,
    sum(invoiced_amount_usd) as invoiced_amount_usd,
    max(order_date) as last_order_date
  from {{ ref('fct_orders') }}
  group by customer_external_id
),
invoice_rollup as (
  select
    customer_external_id,
    count(*) filter (where invoice_status = 'open') as open_invoice_count,
    sum(invoiced_amount_usd) filter (where invoice_status = 'open') as open_invoice_amount_usd
  from {{ ref('fct_orders') }}
  group by customer_external_id
),
pipeline_rollup as (
  select
    customer_external_id,
    count(*) filter (where is_closed = false) as open_pipeline_count,
    sum(amount_usd) filter (where is_closed = false) as open_pipeline_amount_usd,
    count(*) filter (where is_won = true) as won_opportunity_count,
    sum(amount_usd) filter (where is_won = true) as won_opportunity_amount_usd
  from {{ ref('fct_pipeline') }}
  group by customer_external_id
)
select
  d.customer_external_id,
  d.customer_id,
  d.account_id,
  d.display_customer_name,
  d.customer_status,
  d.account_status,
  d.account_manager,
  d.industry,
  d.account_tier,
  d.billing_country_code,
  d.credit_limit_usd,
  o.order_count,
  o.gross_order_amount_usd,
  o.invoiced_amount_usd,
  o.last_order_date,
  i.open_invoice_count,
  i.open_invoice_amount_usd,
  p.open_pipeline_count,
  p.open_pipeline_amount_usd,
  p.won_opportunity_count,
  p.won_opportunity_amount_usd
from {{ ref('dim_customers') }} as d
left join order_rollup as o
  on d.customer_external_id = o.customer_external_id
left join invoice_rollup as i
  on d.customer_external_id = i.customer_external_id
left join pipeline_rollup as p
  on d.customer_external_id = p.customer_external_id
