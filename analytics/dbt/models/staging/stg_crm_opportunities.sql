select
  opportunity_id,
  account_id,
  primary_contact_id,
  opportunity_name,
  stage,
  amount_usd,
  close_date,
  is_closed,
  is_won,
  created_at,
  updated_at
from {{ source('fivetran_crm', 'opportunities') }}
