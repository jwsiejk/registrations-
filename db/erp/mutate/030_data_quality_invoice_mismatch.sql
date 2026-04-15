-- Phase 05 mutation: deterministic controlled data-quality scenario for troubleshooting.
-- Intentional edge case: invoice total differs from summed order line amount.
INSERT INTO orders (
  order_id,
  customer_id,
  order_number,
  order_status,
  order_date,
  required_ship_date,
  shipped_at,
  completed_at,
  created_at,
  updated_at
) VALUES (
  7092,
  5005,
  'SO-2026-7092',
  'booked',
  '2026-04-15',
  '2026-04-23',
  NULL,
  NULL,
  '2026-04-15T12:00:00Z',
  '2026-04-15T12:00:00Z'
)
ON CONFLICT (order_id) DO NOTHING;

INSERT INTO order_items (
  order_item_id,
  order_id,
  product_id,
  quantity,
  unit_price_usd,
  created_at,
  updated_at
) VALUES
  (8093, 7092, 6003, 5, 3200.00, '2026-04-15T12:05:00Z', '2026-04-15T12:05:00Z'),
  (8094, 7092, 6004, 3, 1800.00, '2026-04-15T12:06:00Z', '2026-04-15T12:06:00Z')
ON CONFLICT (order_item_id) DO NOTHING;

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
  9092,
  7092,
  'INV-2026-7092',
  'open',
  '2026-04-16',
  '2026-05-16',
  NULL,
  21450.00,
  '2026-04-16T09:10:00Z',
  '2026-04-16T09:10:00Z'
)
ON CONFLICT (invoice_id) DO NOTHING;
