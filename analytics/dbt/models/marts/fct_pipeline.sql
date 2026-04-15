select
  p.opportunity_id,
  p.account_id,
  p.customer_external_id,
  p.primary_contact_id,
  p.opportunity_name,
  p.stage,
  p.amount_usd,
  p.close_date,
  p.is_closed,
  p.is_won,
  p.created_at,
  p.updated_at,
  p.last_stage_changed_at,
  p.stage_change_count
from {{ ref('int_pipeline_enriched') }} as p
