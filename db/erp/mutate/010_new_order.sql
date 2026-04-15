-- Phase 05 mutation: deterministic ERP order without invoice (late-arriving invoice dependency).
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
  7091,
  5008,
  'SO-2026-7091',
  'booked',
  '2026-04-15',
  '2026-04-22',
  NULL,
  NULL,
  '2026-04-15T11:00:00Z',
  '2026-04-15T11:00:00Z'
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
  (8091, 7091, 6001, 4, 12000.00, '2026-04-15T11:05:00Z', '2026-04-15T11:05:00Z'),
  (8092, 7091, 6007, 1, 9000.00, '2026-04-15T11:06:00Z', '2026-04-15T11:06:00Z')
ON CONFLICT (order_item_id) DO NOTHING;
