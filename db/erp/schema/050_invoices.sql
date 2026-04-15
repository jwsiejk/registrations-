CREATE TABLE invoices (
  invoice_id BIGINT PRIMARY KEY,
  order_id BIGINT NOT NULL UNIQUE REFERENCES orders(order_id),
  invoice_number TEXT NOT NULL UNIQUE,
  invoice_status TEXT NOT NULL CHECK (invoice_status IN ('open', 'paid', 'void')),
  invoice_date DATE NOT NULL,
  due_date DATE NOT NULL,
  paid_at TIMESTAMPTZ,
  total_amount_usd NUMERIC(14,2) NOT NULL CHECK (total_amount_usd >= 0),
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  CONSTRAINT invoices_paid_status_consistency CHECK (
    (invoice_status = 'paid' AND paid_at IS NOT NULL)
    OR (invoice_status IN ('open', 'void') AND paid_at IS NULL)
  )
);
