CREATE TABLE opportunities (
  opportunity_id BIGINT PRIMARY KEY,
  account_id BIGINT NOT NULL REFERENCES accounts(account_id),
  primary_contact_id BIGINT REFERENCES contacts(contact_id),
  opportunity_name TEXT NOT NULL,
  stage TEXT NOT NULL CHECK (stage IN ('prospecting', 'qualification', 'proposal', 'negotiation', 'closed_won', 'closed_lost')),
  amount_usd NUMERIC(14,2) NOT NULL CHECK (amount_usd >= 0),
  close_date DATE NOT NULL,
  is_closed BOOLEAN NOT NULL,
  is_won BOOLEAN NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  CONSTRAINT opportunities_closed_won_consistency CHECK (
    (is_won = TRUE AND stage = 'closed_won' AND is_closed = TRUE)
    OR (is_won = FALSE AND stage IN ('prospecting', 'qualification', 'proposal', 'negotiation', 'closed_lost'))
  ),
  CONSTRAINT opportunities_open_closed_consistency CHECK (
    (is_closed = FALSE AND stage IN ('prospecting', 'qualification', 'proposal', 'negotiation'))
    OR (is_closed = TRUE AND stage IN ('closed_won', 'closed_lost'))
  )
);
