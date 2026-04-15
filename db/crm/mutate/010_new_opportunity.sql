-- Phase 05 mutation: deterministic CRM new open opportunity.
INSERT INTO opportunities (
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
) VALUES (
  3091,
  1008,
  2015,
  'Peakline Telecom Expansion - West Region',
  'qualification',
  365000.00,
  '2026-09-15',
  FALSE,
  FALSE,
  '2026-04-15T09:00:00Z',
  '2026-04-15T09:00:00Z'
)
ON CONFLICT (opportunity_id) DO NOTHING;

INSERT INTO opportunity_history (
  opportunity_history_id,
  opportunity_id,
  previous_stage,
  new_stage,
  changed_at,
  changed_by,
  notes
) VALUES (
  4091,
  3091,
  NULL,
  'qualification',
  '2026-04-15T09:00:00Z',
  'sales_rep_tramirez',
  'Phase 05 deterministic mutation opportunity created for incremental sync simulation'
)
ON CONFLICT (opportunity_history_id) DO NOTHING;
