-- Migration: Impersonation Audit Log
-- Description: Create impersonation_audit table and logging functions
-- Phase: 2.2.1 - Admin Impersonation System
-- Created: 2025-11-16
-- Depends on: 030_Admin_Roles.sql

-- =============================================================================
-- IMPERSONATION AUDIT TABLE
-- =============================================================================

-- Table to audit all impersonation events
CREATE TABLE impersonation_audit (
  audit_id uuid PRIMARY KEY DEFAULT uuid_generate_v1mc(),
  admin_user_id uuid NOT NULL REFERENCES app_user(app_user_id) ON DELETE CASCADE,
  target_user_id uuid NOT NULL REFERENCES app_user(app_user_id) ON DELETE CASCADE,
  started_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz,
  ended_reason text,
  ip_address inet,
  user_agent text,
  notes text,

  -- Constraint: Ended reason must be valid
  CONSTRAINT valid_ended_reason CHECK (
    ended_reason IS NULL OR
    ended_reason IN ('manual', 'timeout', 'session_revoked', 'admin_logout')
  ),

  -- Constraint: Cannot end before starting
  CONSTRAINT end_after_start CHECK (
    ended_at IS NULL OR ended_at >= started_at
  ),

  -- Constraint: Cannot impersonate yourself
  CONSTRAINT no_self_impersonation CHECK (
    admin_user_id != target_user_id
  )
);

-- Comments on table and columns
COMMENT ON TABLE impersonation_audit IS 'Audit log of all admin impersonation sessions for compliance and security monitoring';
COMMENT ON COLUMN impersonation_audit.audit_id IS 'Unique identifier for this impersonation session';
COMMENT ON COLUMN impersonation_audit.admin_user_id IS 'Admin who initiated the impersonation';
COMMENT ON COLUMN impersonation_audit.target_user_id IS 'User being impersonated';
COMMENT ON COLUMN impersonation_audit.started_at IS 'When impersonation session began';
COMMENT ON COLUMN impersonation_audit.ended_at IS 'When impersonation session ended (NULL if still active)';
COMMENT ON COLUMN impersonation_audit.ended_reason IS 'Why the session ended: manual (user clicked exit), timeout (2hr limit), session_revoked (admin kicked), admin_logout';
COMMENT ON COLUMN impersonation_audit.ip_address IS 'IP address of admin when impersonation started';
COMMENT ON COLUMN impersonation_audit.user_agent IS 'Browser/app user agent of admin';
COMMENT ON COLUMN impersonation_audit.notes IS 'Optional notes about why impersonation occurred';

-- =============================================================================
-- INDEXES
-- =============================================================================

-- Index for finding impersonation history by admin
CREATE INDEX idx_impersonation_audit_admin
  ON impersonation_audit(admin_user_id, started_at DESC);

COMMENT ON INDEX idx_impersonation_audit_admin IS 'Find all impersonation sessions by a specific admin, sorted by most recent';

-- Index for finding who impersonated a target user
CREATE INDEX idx_impersonation_audit_target
  ON impersonation_audit(target_user_id, started_at DESC);

COMMENT ON INDEX idx_impersonation_audit_target IS 'Find all impersonation sessions for a specific user, sorted by most recent';

-- Index for finding active impersonation sessions
CREATE INDEX idx_impersonation_audit_active
  ON impersonation_audit(started_at DESC)
  WHERE ended_at IS NULL;

COMMENT ON INDEX idx_impersonation_audit_active IS 'Partial index for currently active impersonation sessions';

-- Index for time-based queries and session timeout checks
CREATE INDEX idx_impersonation_audit_started
  ON impersonation_audit(started_at DESC);

COMMENT ON INDEX idx_impersonation_audit_started IS 'Index for time-based audit queries and finding sessions that need timeout';

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================

-- Enable RLS on impersonation_audit
ALTER TABLE impersonation_audit ENABLE ROW LEVEL SECURITY;

-- Policy: Only admins can view audit log
CREATE POLICY "Admins can view all impersonation logs"
  ON impersonation_audit
  FOR SELECT
  TO authenticated
  USING (is_admin());

COMMENT ON POLICY "Admins can view all impersonation logs" ON impersonation_audit
  IS 'Only active admins can view the impersonation audit log';

-- Policy: Block direct inserts/updates/deletes (use functions instead)
CREATE POLICY "Block direct audit modifications"
  ON impersonation_audit
  FOR ALL
  TO authenticated
  USING (false)
  WITH CHECK (false);

COMMENT ON POLICY "Block direct audit modifications" ON impersonation_audit
  IS 'Audit logs must be created via log_impersonation_start/end functions to ensure data integrity';

-- =============================================================================
-- AUDIT LOGGING FUNCTIONS
-- =============================================================================

-- Function: Log the start of an impersonation session
CREATE OR REPLACE FUNCTION log_impersonation_start(
  p_admin_user_id uuid,
  p_target_user_id uuid,
  p_ip_address inet DEFAULT NULL,
  p_user_agent text DEFAULT NULL,
  p_notes text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_audit_id uuid;
BEGIN
  -- Verify admin permission
  IF NOT is_admin(p_admin_user_id) THEN
    RAISE EXCEPTION 'User % is not an admin and cannot impersonate users', p_admin_user_id;
  END IF;

  -- Verify target user exists
  IF NOT EXISTS (SELECT 1 FROM app_user WHERE app_user_id = p_target_user_id) THEN
    RAISE EXCEPTION 'Target user % does not exist', p_target_user_id;
  END IF;

  -- Verify admin can impersonate target (not another admin)
  IF NOT can_impersonate_user(p_admin_user_id, p_target_user_id) THEN
    RAISE EXCEPTION 'Admin % cannot impersonate user % (target may be an admin)', p_admin_user_id, p_target_user_id;
  END IF;

  -- Check for existing active impersonation by this admin
  IF EXISTS (
    SELECT 1 FROM impersonation_audit
    WHERE admin_user_id = p_admin_user_id
      AND ended_at IS NULL
  ) THEN
    RAISE EXCEPTION 'Admin % already has an active impersonation session. End it before starting a new one.', p_admin_user_id;
  END IF;

  -- Insert audit record
  INSERT INTO impersonation_audit (
    admin_user_id,
    target_user_id,
    started_at,
    ip_address,
    user_agent,
    notes
  ) VALUES (
    p_admin_user_id,
    p_target_user_id,
    now(),
    p_ip_address,
    p_user_agent,
    p_notes
  )
  RETURNING audit_id INTO v_audit_id;

  RAISE NOTICE 'Started impersonation session % (admin: %, target: %)', v_audit_id, p_admin_user_id, p_target_user_id;

  RETURN v_audit_id;
END;
$$;

COMMENT ON FUNCTION log_impersonation_start IS 'Log the start of an impersonation session. Verifies admin permissions and creates audit record. Returns audit_id. Prevents multiple active sessions per admin.';

-- Grant execute to authenticated users (function checks permissions internally)
GRANT EXECUTE ON FUNCTION log_impersonation_start(uuid, uuid, inet, text, text) TO authenticated;


-- Function: Log the end of an impersonation session
CREATE OR REPLACE FUNCTION log_impersonation_end(
  p_audit_id uuid,
  p_ended_reason text DEFAULT 'manual'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_admin_user_id uuid;
  v_target_user_id uuid;
BEGIN
  -- Verify ended_reason is valid
  IF p_ended_reason NOT IN ('manual', 'timeout', 'session_revoked', 'admin_logout') THEN
    RAISE EXCEPTION 'Invalid ended_reason: %. Must be manual, timeout, session_revoked, or admin_logout', p_ended_reason;
  END IF;

  -- Get session details before updating
  SELECT admin_user_id, target_user_id
  INTO v_admin_user_id, v_target_user_id
  FROM impersonation_audit
  WHERE audit_id = p_audit_id
    AND ended_at IS NULL;

  -- Check if session exists and is still active
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Impersonation session % not found or already ended', p_audit_id;
  END IF;

  -- Update audit record with end time and reason
  UPDATE impersonation_audit
  SET ended_at = now(),
      ended_reason = p_ended_reason
  WHERE audit_id = p_audit_id
    AND ended_at IS NULL;

  RAISE NOTICE 'Ended impersonation session % (admin: %, target: %, reason: %)',
    p_audit_id, v_admin_user_id, v_target_user_id, p_ended_reason;
END;
$$;

COMMENT ON FUNCTION log_impersonation_end IS 'Log the end of an impersonation session. Updates ended_at and ended_reason. Session must exist and be active.';

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION log_impersonation_end(uuid, text) TO authenticated;


-- Function: Get active impersonation sessions (for monitoring/cleanup)
CREATE OR REPLACE FUNCTION get_active_impersonation_sessions()
RETURNS TABLE (
  audit_id uuid,
  admin_user_id uuid,
  admin_username text,
  target_user_id uuid,
  target_username text,
  started_at timestamptz,
  duration_minutes int,
  ip_address inet,
  should_timeout boolean
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    ia.audit_id,
    ia.admin_user_id,
    au_admin.username AS admin_username,
    ia.target_user_id,
    au_target.username AS target_username,
    ia.started_at,
    EXTRACT(EPOCH FROM (now() - ia.started_at)) / 60 AS duration_minutes,
    ia.ip_address,
    (now() - ia.started_at) > interval '2 hours' AS should_timeout
  FROM impersonation_audit ia
  JOIN app_user au_admin ON ia.admin_user_id = au_admin.app_user_id
  JOIN app_user au_target ON ia.target_user_id = au_target.app_user_id
  WHERE ia.ended_at IS NULL
  ORDER BY ia.started_at DESC;
$$;

COMMENT ON FUNCTION get_active_impersonation_sessions IS 'Get all currently active impersonation sessions with admin/target usernames and duration. Includes should_timeout flag for sessions > 2 hours.';

-- Grant execute to authenticated users (requires admin check in calling code)
GRANT EXECUTE ON FUNCTION get_active_impersonation_sessions() TO authenticated;


-- Function: Auto-timeout old impersonation sessions (run periodically)
CREATE OR REPLACE FUNCTION timeout_expired_impersonation_sessions()
RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_timeout_count int;
BEGIN
  -- Update sessions older than 2 hours
  WITH timed_out AS (
    UPDATE impersonation_audit
    SET ended_at = now(),
        ended_reason = 'timeout'
    WHERE ended_at IS NULL
      AND (now() - started_at) > interval '2 hours'
    RETURNING audit_id
  )
  SELECT COUNT(*) INTO v_timeout_count FROM timed_out;

  IF v_timeout_count > 0 THEN
    RAISE NOTICE 'Timed out % expired impersonation session(s)', v_timeout_count;
  END IF;

  RETURN v_timeout_count;
END;
$$;

COMMENT ON FUNCTION timeout_expired_impersonation_sessions IS 'Auto-timeout impersonation sessions older than 2 hours. Returns number of sessions timed out. Should be run periodically (e.g., via cron).';

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION timeout_expired_impersonation_sessions() TO authenticated;


-- Function: Get impersonation history for a user (either as admin or target)
CREATE OR REPLACE FUNCTION get_impersonation_history(
  p_user_id uuid,
  p_limit int DEFAULT 50
)
RETURNS TABLE (
  audit_id uuid,
  admin_user_id uuid,
  admin_username text,
  target_user_id uuid,
  target_username text,
  started_at timestamptz,
  ended_at timestamptz,
  duration_minutes int,
  ended_reason text,
  role_in_session text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    ia.audit_id,
    ia.admin_user_id,
    au_admin.username AS admin_username,
    ia.target_user_id,
    au_target.username AS target_username,
    ia.started_at,
    ia.ended_at,
    EXTRACT(EPOCH FROM (COALESCE(ia.ended_at, now()) - ia.started_at)) / 60 AS duration_minutes,
    ia.ended_reason,
    CASE
      WHEN ia.admin_user_id = p_user_id THEN 'admin'
      WHEN ia.target_user_id = p_user_id THEN 'target'
      ELSE 'unknown'
    END AS role_in_session
  FROM impersonation_audit ia
  JOIN app_user au_admin ON ia.admin_user_id = au_admin.app_user_id
  JOIN app_user au_target ON ia.target_user_id = au_target.app_user_id
  WHERE ia.admin_user_id = p_user_id
     OR ia.target_user_id = p_user_id
  ORDER BY ia.started_at DESC
  LIMIT p_limit;
$$;

COMMENT ON FUNCTION get_impersonation_history IS 'Get impersonation history for a user (as admin or target). Returns role_in_session to distinguish. Limited to 50 by default.';

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION get_impersonation_history(uuid, int) TO authenticated;


-- =============================================================================
-- MAINTENANCE & MONITORING
-- =============================================================================

-- Create view for easy querying of recent impersonation activity
CREATE OR REPLACE VIEW recent_impersonation_activity AS
  SELECT
    ia.audit_id,
    au_admin.username AS admin_username,
    au_admin.email AS admin_email,
    au_target.username AS target_username,
    au_target.email AS target_email,
    ia.started_at,
    ia.ended_at,
    EXTRACT(EPOCH FROM (COALESCE(ia.ended_at, now()) - ia.started_at)) / 60 AS duration_minutes,
    ia.ended_reason,
    ia.ended_at IS NULL AS is_active,
    (now() - ia.started_at) > interval '2 hours' AS should_timeout
  FROM impersonation_audit ia
  JOIN app_user au_admin ON ia.admin_user_id = au_admin.app_user_id
  JOIN app_user au_target ON ia.target_user_id = au_target.app_user_id
  WHERE ia.started_at > now() - interval '7 days'
  ORDER BY ia.started_at DESC;

COMMENT ON VIEW recent_impersonation_activity IS 'View of impersonation activity in the last 7 days for monitoring and reporting';

-- Grant select on view to authenticated users (requires admin check)
GRANT SELECT ON recent_impersonation_activity TO authenticated;


-- =============================================================================
-- NOTES
-- =============================================================================

-- Usage Examples:
--
-- 1. Start impersonation:
--    SELECT log_impersonation_start(
--      'admin-uuid',
--      'target-user-uuid',
--      '192.168.1.1'::inet,
--      'Mozilla/5.0...',
--      'Debugging reported issue #123'
--    );
--
-- 2. End impersonation:
--    SELECT log_impersonation_end('audit-uuid', 'manual');
--
-- 3. View active sessions:
--    SELECT * FROM get_active_impersonation_sessions();
--
-- 4. Timeout expired sessions (should be run periodically):
--    SELECT timeout_expired_impersonation_sessions();
--
-- 5. View recent activity:
--    SELECT * FROM recent_impersonation_activity WHERE is_active = true;
