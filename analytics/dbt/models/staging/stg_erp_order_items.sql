select
  order_item_id,
  order_id,
  product_id,
  quantity,
  unit_price_usd,
  created_at,
  updated_at
from {{ source('fivetran_erp', 'order_items') }}
