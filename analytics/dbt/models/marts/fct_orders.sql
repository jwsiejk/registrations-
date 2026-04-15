select
  o.order_id,
  o.order_number,
  o.customer_id,
  c.customer_external_id,
  o.order_status,
  o.order_date,
  o.required_ship_date,
  o.shipped_at,
  o.completed_at,
  count(distinct l.order_item_id) as line_count,
  sum(l.quantity) as total_quantity,
  sum(l.line_amount_usd) as gross_order_amount_usd,
  i.invoice_id,
  i.invoice_number,
  i.invoice_status,
  i.invoice_date,
  i.due_date,
  i.paid_at,
  i.total_amount_usd as invoiced_amount_usd
from {{ ref('stg_erp_orders') }} as o
inner join {{ ref('stg_erp_customers') }} as c
  on o.customer_id = c.customer_id
left join {{ ref('int_order_line_enriched') }} as l
  on o.order_id = l.order_id
left join {{ ref('stg_erp_invoices') }} as i
  on o.order_id = i.order_id
group by
  o.order_id,
  o.order_number,
  o.customer_id,
  c.customer_external_id,
  o.order_status,
  o.order_date,
  o.required_ship_date,
  o.shipped_at,
  o.completed_at,
  i.invoice_id,
  i.invoice_number,
  i.invoice_status,
  i.invoice_date,
  i.due_date,
  i.paid_at,
  i.total_amount_usd
