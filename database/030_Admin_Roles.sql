-- Migration: Admin Roles System
-- Description: Create admin_users table and helper functions for admin permissions
-- Phase: 2.2.1 - Admin Impersonation System
-- Created: 2025-11-16

-- =============================================================================
-- ADMIN USERS TABLE
-- =============================================================================

-- Table to track admin users and their roles
CREATE TABLE admin_users (
  admin_user_id uuid REFERENCES app_user(app_user_id) ON DELETE CASCADE PRIMARY KEY,
  role text NOT NULL DEFAULT 'support',
  granted_by uuid REFERENCES admin_users(admin_user_id),
  granted_at timestamptz DEFAULT now() NOT NULL,
  revoked_at timestamptz,
  notes text,

  -- Constraint: Only valid admin roles
  CONSTRAINT valid_admin_role CHECK (role IN ('support', 'admin', 'superadmin')),

  -- Constraint: Cannot revoke before granting
  CONSTRAINT revoked_after_granted CHECK (revoked_at IS NULL OR revoked_at >= granted_at)
);

-- Comment on table
COMMENT ON TABLE admin_users IS 'Admin users with role-based permissions for impersonation and management';
COMMENT ON COLUMN admin_users.admin_user_id IS 'Reference to app_user - this user has admin privileges';
COMMENT ON COLUMN admin_users.role IS 'Admin role level: support < admin < superadmin';
COMMENT ON COLUMN admin_users.granted_by IS 'Admin who granted this role (NULL for initial/manual grants)';
COMMENT ON COLUMN admin_users.granted_at IS 'When admin role was granted';
COMMENT ON COLUMN admin_users.revoked_at IS 'When admin role was revoked (NULL if still active)';
COMMENT ON COLUMN admin_users.notes IS 'Optional notes about why role was granted/revoked';

-- =============================================================================
-- INDEXES
-- =============================================================================

-- Index for finding active admins (most common query)
CREATE INDEX idx_admin_users_active
  ON admin_users(admin_user_id)
  WHERE revoked_at IS NULL;

COMMENT ON INDEX idx_admin_users_active IS 'Partial index for active (non-revoked) admins - used by is_admin()';

-- Index for audit trail queries
CREATE INDEX idx_admin_users_granted_by
  ON admin_users(granted_by, granted_at DESC)
  WHERE granted_by IS NOT NULL;

COMMENT ON INDEX idx_admin_users_granted_by IS 'Index for finding who granted admin roles';

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================

-- Enable RLS on admin_users
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Policy: Only admins can view admin_users table
CREATE POLICY "Admins can view all admin users"
  ON admin_users
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE admin_user_id = (SELECT auth.uid())
        AND revoked_at IS NULL
    )
  );

COMMENT ON POLICY "Admins can view all admin users" ON admin_users
  IS 'Only active admins can view the admin_users table (self-referential check)';

-- Policy: Block direct inserts/updates/deletes (admins managed manually via SQL)
CREATE POLICY "Block direct admin modifications"
  ON admin_users
  FOR ALL
  TO authenticated
  USING (false)
  WITH CHECK (false);

COMMENT ON POLICY "Block direct admin modifications" ON admin_users
  IS 'Admin roles must be managed manually via database or through dedicated admin management functions';

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

-- Function: Check if a user is an admin
CREATE OR REPLACE FUNCTION is_admin(user_id uuid DEFAULT auth.uid())
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM admin_users
    WHERE admin_user_id = user_id
      AND revoked_at IS NULL
  );
$$;

COMMENT ON FUNCTION is_admin IS 'Check if a user has active admin privileges (any role). Uses SECURITY DEFINER to bypass RLS for auth checks.';

-- Grant execute to authenticated users (needed for RLS policies)
GRANT EXECUTE ON FUNCTION is_admin(uuid) TO authenticated;


-- Function: Get admin role for a user
CREATE OR REPLACE FUNCTION get_admin_role(user_id uuid DEFAULT auth.uid())
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM admin_users
  WHERE admin_user_id = user_id
    AND revoked_at IS NULL
  LIMIT 1;
$$;

COMMENT ON FUNCTION get_admin_role IS 'Get the admin role for a user (support, admin, or superadmin). Returns NULL if not an admin. Uses SECURITY DEFINER to bypass RLS.';

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION get_admin_role(uuid) TO authenticated;


-- Function: Check if a user can impersonate another user
CREATE OR REPLACE FUNCTION can_impersonate_user(
  p_admin_user_id uuid,
  p_target_user_id uuid
)
RETURNS boolean
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_admin_role text;
  v_target_is_admin boolean;
BEGIN
  -- Get admin's role
  v_admin_role := get_admin_role(p_admin_user_id);

  -- If requester is not an admin, cannot impersonate
  IF v_admin_role IS NULL THEN
    RETURN false;
  END IF;

  -- Check if target is an admin
  v_target_is_admin := is_admin(p_target_user_id);

  -- Admins cannot impersonate other admins (prevents lateral movement)
  IF v_target_is_admin THEN
    RETURN false;
  END IF;

  -- Admin can impersonate regular (non-admin) users
  RETURN true;
END;
$$;

COMMENT ON FUNCTION can_impersonate_user IS 'Check if an admin user can impersonate a target user. Prevents admin-to-admin impersonation. Returns false if requester is not admin or target is admin.';

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION can_impersonate_user(uuid, uuid) TO authenticated;


-- =============================================================================
-- ADMIN MANAGEMENT FUNCTIONS (for future use)
-- =============================================================================

-- Function: Grant admin role (must be called by existing admin)
CREATE OR REPLACE FUNCTION grant_admin_role(
  p_target_user_id uuid,
  p_role text DEFAULT 'support',
  p_notes text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_granting_admin_id uuid;
  v_granting_admin_role text;
BEGIN
  -- Get the ID of the user calling this function
  v_granting_admin_id := auth.uid();

  -- Verify caller is an admin
  IF NOT is_admin(v_granting_admin_id) THEN
    RAISE EXCEPTION 'Only admins can grant admin roles';
  END IF;

  -- Get caller's role
  v_granting_admin_role := get_admin_role(v_granting_admin_id);

  -- Verify role hierarchy: can only grant roles at or below your level
  -- support < admin < superadmin
  IF v_granting_admin_role = 'support' THEN
    RAISE EXCEPTION 'Support users cannot grant admin roles';
  END IF;

  IF v_granting_admin_role = 'admin' AND p_role = 'superadmin' THEN
    RAISE EXCEPTION 'Only superadmins can grant superadmin role';
  END IF;

  -- Verify target user exists
  IF NOT EXISTS (SELECT 1 FROM app_user WHERE app_user_id = p_target_user_id) THEN
    RAISE EXCEPTION 'User % does not exist', p_target_user_id;
  END IF;

  -- Verify role is valid
  IF p_role NOT IN ('support', 'admin', 'superadmin') THEN
    RAISE EXCEPTION 'Invalid role: %. Must be support, admin, or superadmin', p_role;
  END IF;

  -- Check if user already has admin role
  IF EXISTS (
    SELECT 1 FROM admin_users
    WHERE admin_user_id = p_target_user_id
      AND revoked_at IS NULL
  ) THEN
    RAISE EXCEPTION 'User % already has an active admin role', p_target_user_id;
  END IF;

  -- Grant admin role
  INSERT INTO admin_users (
    admin_user_id,
    role,
    granted_by,
    granted_at,
    notes
  ) VALUES (
    p_target_user_id,
    p_role,
    v_granting_admin_id,
    now(),
    p_notes
  );

  RAISE NOTICE 'Granted % role to user %', p_role, p_target_user_id;
END;
$$;

COMMENT ON FUNCTION grant_admin_role IS 'Grant admin role to a user. Must be called by existing admin. Enforces role hierarchy (support cannot grant, admin cannot grant superadmin).';

-- Grant execute to authenticated users (function checks permissions internally)
GRANT EXECUTE ON FUNCTION grant_admin_role(uuid, text, text) TO authenticated;


-- Function: Revoke admin role
CREATE OR REPLACE FUNCTION revoke_admin_role(
  p_target_user_id uuid,
  p_notes text DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_revoking_admin_id uuid;
BEGIN
  -- Get the ID of the user calling this function
  v_revoking_admin_id := auth.uid();

  -- Verify caller is an admin
  IF NOT is_admin(v_revoking_admin_id) THEN
    RAISE EXCEPTION 'Only admins can revoke admin roles';
  END IF;

  -- Verify target has admin role
  IF NOT EXISTS (
    SELECT 1 FROM admin_users
    WHERE admin_user_id = p_target_user_id
      AND revoked_at IS NULL
  ) THEN
    RAISE EXCEPTION 'User % does not have an active admin role', p_target_user_id;
  END IF;

  -- Prevent self-revocation (safety measure)
  IF v_revoking_admin_id = p_target_user_id THEN
    RAISE EXCEPTION 'Cannot revoke your own admin role';
  END IF;

  -- Revoke admin role
  UPDATE admin_users
  SET revoked_at = now(),
      notes = COALESCE(p_notes, notes)
  WHERE admin_user_id = p_target_user_id
    AND revoked_at IS NULL;

  RAISE NOTICE 'Revoked admin role from user %', p_target_user_id;
END;
$$;

COMMENT ON FUNCTION revoke_admin_role IS 'Revoke admin role from a user. Must be called by existing admin. Prevents self-revocation.';

-- Grant execute to authenticated users (function checks permissions internally)
GRANT EXECUTE ON FUNCTION revoke_admin_role(uuid, text) TO authenticated;


-- =============================================================================
-- SEED DATA (for development/testing)
-- =============================================================================

-- Note: Initial admins must be created manually via SQL INSERT
-- Example:
--
-- INSERT INTO admin_users (admin_user_id, role, notes)
-- VALUES (
--   'your-uuid-here',
--   'superadmin',
--   'Initial superadmin - created manually'
-- );
--
-- After first superadmin exists, use grant_admin_role() function for subsequent admins.
