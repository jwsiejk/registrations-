select
  account_id,
  customer_external_id,
  account_name,
  industry,
  account_tier,
  account_status,
  billing_country_code,
  annual_revenue_usd,
  created_at,
  updated_at
from {{ source('fivetran_crm', 'accounts') }}
