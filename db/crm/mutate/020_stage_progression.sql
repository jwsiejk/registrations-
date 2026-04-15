-- Phase 05 mutation: deterministic CRM stage progression for existing opportunity 3014.
UPDATE opportunities
SET
  stage = 'proposal',
  updated_at = '2026-04-15T10:30:00Z'
WHERE
  opportunity_id = 3014
  AND stage = 'qualification';

INSERT INTO opportunity_history (
  opportunity_history_id,
  opportunity_id,
  previous_stage,
  new_stage,
  changed_at,
  changed_by,
  notes
)
SELECT
  4092,
  3014,
  'qualification',
  'proposal',
  '2026-04-15T10:30:00Z',
  'sales_mgr_lchen',
  'Phase 05 deterministic stage progression mutation'
WHERE
  EXISTS (
    SELECT 1
    FROM opportunities
    WHERE opportunity_id = 3014
      AND stage = 'proposal'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM opportunity_history
    WHERE opportunity_history_id = 4092
  );
