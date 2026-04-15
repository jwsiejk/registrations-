CREATE TABLE accounts (
  account_id BIGINT PRIMARY KEY,
  customer_external_id TEXT NOT NULL UNIQUE,
  account_name TEXT NOT NULL,
  industry TEXT NOT NULL,
  account_tier TEXT NOT NULL,
  account_status TEXT NOT NULL CHECK (account_status IN ('active', 'inactive')),
  billing_country_code CHAR(2) NOT NULL,
  annual_revenue_usd NUMERIC(14,2) NOT NULL CHECK (annual_revenue_usd >= 0),
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);
