CREATE TABLE opportunity_history (
  opportunity_history_id BIGINT PRIMARY KEY,
  opportunity_id BIGINT NOT NULL REFERENCES opportunities(opportunity_id) ON DELETE CASCADE,
  previous_stage TEXT CHECK (previous_stage IN ('prospecting', 'qualification', 'proposal', 'negotiation', 'closed_won', 'closed_lost')),
  new_stage TEXT NOT NULL CHECK (new_stage IN ('prospecting', 'qualification', 'proposal', 'negotiation', 'closed_won', 'closed_lost')),
  changed_at TIMESTAMPTZ NOT NULL,
  changed_by TEXT NOT NULL,
  notes TEXT
);
