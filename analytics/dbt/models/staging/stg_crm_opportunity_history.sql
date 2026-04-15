select
  opportunity_history_id,
  opportunity_id,
  previous_stage,
  new_stage,
  changed_at,
  changed_by,
  notes
from {{ source('fivetran_crm', 'opportunity_history') }}
