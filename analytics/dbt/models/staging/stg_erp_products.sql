select
  product_id,
  sku,
  product_name,
  product_family,
  unit_price_usd,
  is_active,
  created_at,
  updated_at
from {{ source('fivetran_erp', 'products') }}
