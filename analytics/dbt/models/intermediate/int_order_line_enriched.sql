select
  oi.order_item_id,
  oi.order_id,
  o.order_number,
  o.customer_id,
  oi.product_id,
  p.sku,
  p.product_name,
  p.product_family,
  oi.quantity,
  oi.unit_price_usd,
  (oi.quantity * oi.unit_price_usd) as line_amount_usd,
  o.order_status,
  o.order_date,
  o.required_ship_date,
  o.shipped_at,
  o.completed_at
from {{ ref('stg_erp_order_items') }} as oi
inner join {{ ref('stg_erp_orders') }} as o
  on oi.order_id = o.order_id
inner join {{ ref('stg_erp_products') }} as p
  on oi.product_id = p.product_id
