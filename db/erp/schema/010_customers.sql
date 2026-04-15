CREATE TABLE customers (
  customer_id BIGINT PRIMARY KEY,
  customer_external_id TEXT NOT NULL UNIQUE,
  customer_name TEXT NOT NULL,
  account_manager TEXT NOT NULL,
  customer_status TEXT NOT NULL CHECK (customer_status IN ('active', 'inactive')),
  payment_terms_days INTEGER NOT NULL CHECK (payment_terms_days > 0),
  credit_limit_usd NUMERIC(14,2) NOT NULL CHECK (credit_limit_usd >= 0),
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);
