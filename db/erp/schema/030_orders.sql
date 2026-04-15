CREATE TABLE orders (
  order_id BIGINT PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(customer_id),
  order_number TEXT NOT NULL UNIQUE,
  order_status TEXT NOT NULL CHECK (order_status IN ('booked', 'shipped', 'completed', 'cancelled')),
  order_date DATE NOT NULL,
  required_ship_date DATE,
  shipped_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  CONSTRAINT orders_shipped_status_consistency CHECK (
    (order_status IN ('shipped', 'completed') AND shipped_at IS NOT NULL)
    OR (order_status IN ('booked', 'cancelled') AND shipped_at IS NULL)
  ),
  CONSTRAINT orders_completed_status_consistency CHECK (
    (order_status = 'completed' AND completed_at IS NOT NULL)
    OR (order_status <> 'completed' AND completed_at IS NULL)
  )
);
