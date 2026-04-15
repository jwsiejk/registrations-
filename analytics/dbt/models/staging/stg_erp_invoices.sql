select
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
from {{ source('fivetran_erp', 'invoices') }}
