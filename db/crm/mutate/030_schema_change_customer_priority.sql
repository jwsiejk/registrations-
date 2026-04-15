-- Phase 05 mutation: additive schema drift in CRM accounts table.
ALTER TABLE accounts
ADD COLUMN IF NOT EXISTS customer_priority TEXT;

UPDATE accounts
SET customer_priority = CASE account_id
  WHEN 1001 THEN 'high'
  WHEN 1003 THEN 'medium'
  WHEN 1008 THEN 'high'
  ELSE customer_priority
END
WHERE account_id IN (1001, 1003, 1008);
