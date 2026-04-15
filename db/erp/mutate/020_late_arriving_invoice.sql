-- Phase 05 mutation: deterministic late-arriving invoice for order 7091.
-- Dependency: apply db/erp/mutate/010_new_order.sql first.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM orders WHERE order_id = 7091) THEN
    RAISE EXCEPTION 'Required order_id 7091 is missing. Apply 010_new_order.sql first.';
  END IF;
END
$$;

INSERT INTO invoices (
  invoice_id,
  order_id,
  invoice_number,
  invoice_status,
  invoice_date,
  due_date,
  paid_at,
  total_amount_usd,
  created_at,
  updated_at
) VALUES (
  9091,
  7091,
  'INV-2026-7091',
  'open',
  '2026-04-20',
  '2026-05-20',
  NULL,
  57000.00,
  '2026-04-20T08:30:00Z',
  '2026-04-20T08:30:00Z'
)
ON CONFLICT (invoice_id) DO NOTHING;
