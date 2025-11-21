-- Optional: Audit Log Archival Strategy
--
-- This file provides an archival system for impersonation_audit logs.
-- Run this migration ONLY if you want automatic archival of old audit records.
--
-- WHEN TO USE:
-- - After 6-12 months of production use
-- - When impersonation_audit table grows beyond comfortable size
-- - When you need to maintain compliance while managing storage costs
--
-- RETENTION POLICY:
-- - Keep recent 2 years in main table (hot data, fast queries)
-- - Archive older records to separate table (cold storage, compliance)
-- - Provides unified view across both tables
--
-- Created: 2025-11-17

-- Step 1: Create archive table
CREATE TABLE IF NOT EXISTS impersonation_audit_archive (
  LIKE impersonation_audit INCLUDING ALL
);

COMMENT ON TABLE impersonation_audit_archive IS
  'Archived impersonation audit records older than 2 years. '
  'Used for compliance retention while keeping main table performant.';

-- Step 2: Create function to archive old records
CREATE OR REPLACE FUNCTION archive_old_impersonation_audits()
RETURNS TABLE (
  archived_count bigint,
  oldest_archived timestamptz,
  newest_archived timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_cutoff_date timestamptz;
  v_archived_count bigint;
  v_oldest timestamptz;
  v_newest timestamptz;
BEGIN
  -- Archive records older than 2 years
  v_cutoff_date := NOW() - INTERVAL '2 years';

  -- Move old records to archive
  WITH moved_records AS (
    DELETE FROM impersonation_audit
    WHERE started_at < v_cutoff_date
    RETURNING *
  ),
  inserted_records AS (
    INSERT INTO impersonation_audit_archive
    SELECT * FROM moved_records
    RETURNING *
  )
  SELECT
    COUNT(*),
    MIN(started_at),
    MAX(started_at)
  INTO
    v_archived_count,
    v_oldest,
    v_newest
  FROM inserted_records;

  RETURN QUERY SELECT v_archived_count, v_oldest, v_newest;
END;
$$;

COMMENT ON FUNCTION archive_old_impersonation_audits() IS
  'Archives impersonation audit records older than 2 years. '
  'Returns count and date range of archived records. '
  'Run monthly or quarterly as needed.';

-- Step 3: Create unified view for querying across main + archive
CREATE OR REPLACE VIEW impersonation_audit_all AS
SELECT
  'current'::text as source,
  *
FROM impersonation_audit
UNION ALL
SELECT
  'archive'::text as source,
  *
FROM impersonation_audit_archive
ORDER BY started_at DESC;

COMMENT ON VIEW impersonation_audit_all IS
  'Unified view of current and archived impersonation audit records. '
  'Use this for compliance queries spanning multiple years.';

-- Step 4: Create monthly archival job helper
-- NOTE: This is a manual helper function - you need to schedule it externally
-- Options: pg_cron, cron job, scheduled cloud function, etc.

CREATE OR REPLACE FUNCTION schedule_monthly_audit_archival()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  v_result record;
  v_message text;
BEGIN
  -- Run archival
  SELECT * INTO v_result
  FROM archive_old_impersonation_audits();

  IF v_result.archived_count > 0 THEN
    v_message := format(
      'Archived %s records from %s to %s',
      v_result.archived_count,
      v_result.oldest_archived,
      v_result.newest_archived
    );
  ELSE
    v_message := 'No records to archive (none older than 2 years)';
  END IF;

  -- Log the operation
  RAISE NOTICE '%', v_message;

  RETURN v_message;
END;
$$;

COMMENT ON FUNCTION schedule_monthly_audit_archival() IS
  'Helper function for scheduled archival jobs. '
  'Call this from an external scheduler (cron, pg_cron, cloud function).';

-- Step 5: Manual archival instructions
COMMENT ON TABLE impersonation_audit IS
  'Active impersonation audit log (recommended retention: 2 years). '
  'For archival of older records, run: SELECT * FROM archive_old_impersonation_audits(); '
  'To query all records: SELECT * FROM impersonation_audit_all;';

-- Example usage:
-- ============================================================================
--
-- Manual archival (run as needed):
--   SELECT * FROM archive_old_impersonation_audits();
--
-- Query recent audit logs (fast):
--   SELECT * FROM impersonation_audit WHERE started_at > NOW() - INTERVAL '90 days';
--
-- Query all audit logs including archive (slower):
--   SELECT * FROM impersonation_audit_all WHERE admin_user_id = 'uuid-here';
--
-- Check archive stats:
--   SELECT
--     COUNT(*) as total_archived,
--     MIN(started_at) as oldest,
--     MAX(started_at) as newest
--   FROM impersonation_audit_archive;
--
-- ============================================================================

-- Verify setup
DO $$
BEGIN
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Audit Archival System Installed';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Tables:';
  RAISE NOTICE '  - impersonation_audit (main, hot data)';
  RAISE NOTICE '  - impersonation_audit_archive (cold storage)';
  RAISE NOTICE '';
  RAISE NOTICE 'Views:';
  RAISE NOTICE '  - impersonation_audit_all (unified)';
  RAISE NOTICE '';
  RAISE NOTICE 'Functions:';
  RAISE NOTICE '  - archive_old_impersonation_audits()';
  RAISE NOTICE '  - schedule_monthly_audit_archival()';
  RAISE NOTICE '';
  RAISE NOTICE 'Retention Policy: 2 years in main table';
  RAISE NOTICE '';
  RAISE NOTICE 'To archive old records:';
  RAISE NOTICE '  SELECT * FROM archive_old_impersonation_audits();';
  RAISE NOTICE '============================================';
END $$;
