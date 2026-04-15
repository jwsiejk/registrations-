select
  contact_id,
  account_id,
  first_name,
  last_name,
  email,
  job_title,
  lifecycle_stage,
  is_primary,
  created_at,
  updated_at
from {{ source('fivetran_crm', 'contacts') }}
