select
  coalesce(e.customer_external_id, c.customer_external_id) as customer_external_id,
  e.customer_id,
  c.account_id,
  e.customer_name,
  c.account_name,
  e.customer_status,
  c.account_status,
  e.account_manager,
  c.industry,
  c.account_tier,
  c.billing_country_code,
  e.payment_terms_days,
  e.credit_limit_usd,
  c.annual_revenue_usd,
  e.created_at as erp_created_at,
  c.created_at as crm_created_at,
  greatest(e.updated_at, c.updated_at) as bridged_updated_at
from {{ ref('stg_erp_customers') }} as e
full outer join {{ ref('stg_crm_accounts') }} as c
  on e.customer_external_id = c.customer_external_id
