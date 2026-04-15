CREATE TABLE products (
  product_id BIGINT PRIMARY KEY,
  sku TEXT NOT NULL UNIQUE,
  product_name TEXT NOT NULL,
  product_family TEXT NOT NULL,
  unit_price_usd NUMERIC(12,2) NOT NULL CHECK (unit_price_usd >= 0),
  is_active BOOLEAN NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);
