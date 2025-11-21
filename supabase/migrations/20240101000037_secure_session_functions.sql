-- Migration: Session Function Security - Search Path Protection
-- Description: Add search_path protection to session creation functions
-- Created: 2025-11-21
-- Priority: WARN level (search_path hijacking prevention)

-- ============================================================================
-- SESSION FUNCTION SECURITY - SEARCH PATH PROTECTION
-- ============================================================================
-- Issue: Functions lacked search_path protection against hijacking attacks
-- Fix: Add SET search_path = public to all session creation functions
-- Security Model: RLS enforces user isolation, functions use SECURITY INVOKER
-- Result: NON-BREAKING - existing function signatures unchanged
--
-- HOW SECURITY WORKS:
-- - SECURITY INVOKER (default): Functions run as calling user, respect RLS
-- - RLS Policy: WITH CHECK (app_user_id = auth.uid()) on performed_session
-- - Authenticated users: Can only insert sessions where app_user_id = auth.uid()
-- - Service role (superuser): Bypasses RLS, can insert for any user_id
-- - search_path = public: Prevents function hijacking attacks

-- ============================================================================
-- UPDATE EXISTING FUNCTIONS WITH SEARCH PATH PROTECTION
-- ============================================================================

-- Update create_session_from_name with search_path protection
CREATE OR REPLACE FUNCTION create_session_from_name(
    schedule_name text,
    app_user_id uuid DEFAULT '65585c04-0525-11ed-9a8f-0bd67a64ac86'::uuid
)
RETURNS TABLE("like" performed_session)
LANGUAGE sql
SET search_path = public
AS $$
    INSERT INTO performed_session (session_schedule_id, app_user_id)
    VALUES (
        (SELECT ss.session_schedule_id FROM session_schedule ss WHERE ss.name = schedule_name),
        app_user_id
    )
    RETURNING *;
$$;

COMMENT ON FUNCTION create_session_from_name IS
    'Create a session for specified user. '
    'SECURITY INVOKER (default): Runs as calling user, respects RLS policies. '
    'RLS enforces: Authenticated users can only insert app_user_id = auth.uid(). '
    'Service role (superuser): Bypasses RLS, can create for any user_id. '
    'Search path protection prevents hijacking attacks.';

-- Update create_full_session with search_path protection
CREATE OR REPLACE FUNCTION create_full_session(
    schedule_name text,
    app_user_id uuid DEFAULT '65585c04-0525-11ed-9a8f-0bd67a64ac86'::uuid
)
RETURNS TABLE("like" performed_exercise)
LANGUAGE sql
SET search_path = public
AS $$
    SELECT * FROM create_session_exercises(
        (SELECT performed_session_id FROM create_session_from_name(schedule_name, app_user_id))
    );
$$;

COMMENT ON FUNCTION create_full_session IS
    'Create a full session with exercises for specified user. '
    'SECURITY INVOKER: Runs as calling user, respects RLS policies. '
    'RLS enforces user isolation automatically. '
    'Service role bypasses RLS for legacy backend compatibility.';

-- Update create_session_exercises with search_path protection
-- (RLS on performed_exercise ensures user can only insert for their own sessions)
CREATE OR REPLACE FUNCTION create_session_exercises(performed_session_id_ uuid)
RETURNS TABLE ("like" performed_exercise)
LANGUAGE sql
SET search_path = public
AS $$
    INSERT INTO performed_exercise (exercise_id, performed_session_id, name, reps, rest, weight)
    SELECT * FROM draft_session_exercises(performed_session_id_)
    RETURNING *;
$$;

COMMENT ON FUNCTION create_session_exercises IS
    'Create exercises for a session. '
    'SECURITY INVOKER: Runs as calling user, respects RLS on performed_exercise. '
    'RLS ensures user can only access their own sessions. '
    'Search path protection prevents hijacking.';

-- ============================================================================
-- CONVENIENCE FUNCTIONS FOR SIMPLER API
-- ============================================================================
-- These functions automatically use auth.uid() - simpler API for new frontend code
-- No user_id parameter needed - always uses authenticated user's ID

-- Create session from schedule name for authenticated user
CREATE OR REPLACE FUNCTION create_my_session_from_name(schedule_name text)
RETURNS TABLE("like" performed_session)
LANGUAGE sql
SET search_path = public
AS $$
    SELECT * FROM create_session_from_name(schedule_name, auth.uid());
$$;

COMMENT ON FUNCTION create_my_session_from_name IS
    'Convenience function: Create session for authenticated user (no user_id parameter). '
    'Automatically uses auth.uid(). Simpler API for new frontend code. '
    'SECURITY INVOKER with RLS enforcement.';

GRANT EXECUTE ON FUNCTION create_my_session_from_name(text) TO authenticated;

-- Create full session with exercises for authenticated user
CREATE OR REPLACE FUNCTION create_my_full_session(schedule_name text)
RETURNS TABLE("like" performed_exercise)
LANGUAGE sql
SET search_path = public
AS $$
    SELECT * FROM create_full_session(schedule_name, auth.uid());
$$;

COMMENT ON FUNCTION create_my_full_session IS
    'Convenience function: Create full session for authenticated user (no user_id parameter). '
    'Automatically uses auth.uid(). Simpler API for new frontend code. '
    'SECURITY INVOKER with RLS enforcement.';

GRANT EXECUTE ON FUNCTION create_my_full_session(text) TO authenticated;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- All session creation functions now have proper security configuration:
-- 1. SECURITY INVOKER (default): Functions run as calling user, respect RLS
-- 2. RLS policies enforce: authenticated users can only insert app_user_id = auth.uid()
-- 3. search_path = public: Prevents function hijacking attacks
--
-- NON-BREAKING CHANGES:
-- - Legacy backend (service role/superuser): Bypasses RLS, can create for any user ✅
-- - New frontend (authenticated): RLS enforces app_user_id = auth.uid() ✅
-- - Convenience functions available for simpler API: create_my_*() ✅
-- - No SECURITY DEFINER used (follows SECURITY_MODEL.md) ✅
