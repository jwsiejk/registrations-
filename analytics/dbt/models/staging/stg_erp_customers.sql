select
  customer_id,
  customer_external_id,
  customer_name,
  account_manager,
  customer_status,
  payment_terms_days,
  credit_limit_usd,
  created_at,
  updated_at
from {{ source('fivetran_erp', 'customers') }}
