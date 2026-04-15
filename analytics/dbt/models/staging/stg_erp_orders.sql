select
  order_id,
  customer_id,
  order_number,
  order_status,
  order_date,
  required_ship_date,
  shipped_at,
  completed_at,
  created_at,
  updated_at
from {{ source('fivetran_erp', 'orders') }}
