select
  date_trunc('month', order_date)::date as revenue_month,
  count(distinct order_id) as order_count,
  sum(gross_order_amount_usd) as gross_order_amount_usd,
  sum(invoiced_amount_usd) as invoiced_amount_usd,
  sum(case when invoice_status = 'paid' then invoiced_amount_usd else 0 end) as paid_revenue_usd,
  sum(case when invoice_status = 'open' then invoiced_amount_usd else 0 end) as open_revenue_usd,
  sum(case when invoice_status = 'void' then invoiced_amount_usd else 0 end) as void_revenue_usd
from {{ ref('fct_orders') }}
group by 1
order by 1
