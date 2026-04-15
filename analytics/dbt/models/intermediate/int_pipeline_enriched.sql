select
  o.opportunity_id,
  o.account_id,
  a.customer_external_id,
  o.primary_contact_id,
  o.opportunity_name,
  o.stage,
  o.amount_usd,
  o.close_date,
  o.is_closed,
  o.is_won,
  o.created_at,
  o.updated_at,
  max(h.changed_at) as last_stage_changed_at,
  count(h.opportunity_history_id) as stage_change_count
from {{ ref('stg_crm_opportunities') }} as o
inner join {{ ref('stg_crm_accounts') }} as a
  on o.account_id = a.account_id
left join {{ ref('stg_crm_opportunity_history') }} as h
  on o.opportunity_id = h.opportunity_id
group by
  o.opportunity_id,
  o.account_id,
  a.customer_external_id,
  o.primary_contact_id,
  o.opportunity_name,
  o.stage,
  o.amount_usd,
  o.close_date,
  o.is_closed,
  o.is_won,
  o.created_at,
  o.updated_at
