CREATE TABLE contacts (
  contact_id BIGINT PRIMARY KEY,
  account_id BIGINT NOT NULL REFERENCES accounts(account_id),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  job_title TEXT NOT NULL,
  lifecycle_stage TEXT NOT NULL CHECK (lifecycle_stage IN ('lead', 'marketing_qualified', 'sales_qualified', 'customer', 'former_customer')),
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);
