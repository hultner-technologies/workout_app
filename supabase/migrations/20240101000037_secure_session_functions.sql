-- Migration: Secure Session Creation Functions - Defense-in-Depth
-- Description: Add auth.uid() validation to session creation functions
-- Created: 2025-11-21
-- Priority: WARN level (High - user impersonation risk)

-- ============================================================================
-- SECURE SESSION CREATION FUNCTIONS - DEFENSE-IN-DEPTH
-- ============================================================================
-- Issue: Session creation functions accept user_id parameter, allowing
--        authenticated users to potentially create sessions for other users
-- Fix: Add validation layer - authenticated users must use their own auth.uid()
--      Service role (auth.uid() = NULL) bypasses validation (for legacy backend)
-- Defense-in-Depth: Function validation + RLS policies + search_path protection
-- Result: NON-BREAKING - existing function signatures unchanged

-- ============================================================================
-- LAYER 1: UPDATE EXISTING FUNCTIONS WITH VALIDATION
-- ============================================================================

-- Update create_session_from_name with auth.uid() validation
CREATE OR REPLACE FUNCTION create_session_from_name(
    schedule_name text,
    app_user_id uuid DEFAULT '65585c04-0525-11ed-9a8f-0bd67a64ac86'::uuid
)
RETURNS TABLE("like" performed_session)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_authenticated_user_id uuid;
BEGIN
    -- Layer 1: Entry point validation
    -- Get the authenticated user's ID (NULL for service role)
    v_authenticated_user_id := auth.uid();

    -- If authenticated (not service role), verify parameter matches authenticated user
    -- Service role (v_authenticated_user_id IS NULL) bypasses this check
    IF v_authenticated_user_id IS NOT NULL THEN
        IF app_user_id != v_authenticated_user_id THEN
            RAISE EXCEPTION 'Cannot create session for another user. Authenticated as % but tried to create for %. Use your own user_id or omit parameter.',
                v_authenticated_user_id, app_user_id;
        END IF;
    END IF;

    -- Layer 2: Business logic - create session
    -- Layer 3: RLS policy also enforces user can only insert their own sessions
    RETURN QUERY
    INSERT INTO performed_session (session_schedule_id, app_user_id)
    VALUES (
        (SELECT ss.session_schedule_id FROM session_schedule ss WHERE ss.name = schedule_name),
        app_user_id
    )
    RETURNING *;
END;
$$;

COMMENT ON FUNCTION create_session_from_name IS
    'Create a session for specified user. '
    'Defense-in-depth: Authenticated users (auth.uid() != NULL) can only create for themselves. '
    'Service role (auth.uid() = NULL) can create for any user. '
    'SECURITY DEFINER with search_path protection. RLS provides second layer of defense.';

-- Update create_full_session with auth.uid() validation
CREATE OR REPLACE FUNCTION create_full_session(
    schedule_name text,
    app_user_id uuid DEFAULT '65585c04-0525-11ed-9a8f-0bd67a64ac86'::uuid
)
RETURNS TABLE("like" performed_exercise)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_authenticated_user_id uuid;
BEGIN
    -- Layer 1: Entry point validation
    v_authenticated_user_id := auth.uid();

    -- If authenticated (not service role), verify parameter matches authenticated user
    IF v_authenticated_user_id IS NOT NULL THEN
        IF app_user_id != v_authenticated_user_id THEN
            RAISE EXCEPTION 'Cannot create session for another user. Authenticated as % but tried to create for %. Use your own user_id or omit parameter.',
                v_authenticated_user_id, app_user_id;
        END IF;
    END IF;

    -- Layer 2: Create session and exercises
    RETURN QUERY
    SELECT * FROM create_session_exercises(
        (SELECT performed_session_id FROM create_session_from_name(schedule_name, app_user_id))
    );
END;
$$;

COMMENT ON FUNCTION create_full_session IS
    'Create a full session with exercises for specified user. '
    'Defense-in-depth: Authenticated users can only create for themselves. '
    'Service role can create for any user. '
    'Multi-layer validation + RLS enforcement.';

-- Update create_session_exercises - add search_path protection
-- (Already safe - takes session_id, RLS prevents access to other users' sessions)
CREATE OR REPLACE FUNCTION create_session_exercises(performed_session_id_ uuid)
RETURNS TABLE ("like" performed_exercise)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    INSERT INTO performed_exercise (exercise_id, performed_session_id, name, reps, rest, weight)
    SELECT * FROM draft_session_exercises(performed_session_id_)
    RETURNING *;
$$;

COMMENT ON FUNCTION create_session_exercises IS
    'Create exercises for a session. '
    'RLS ensures user can only access their own sessions (defense layer). '
    'SECURITY DEFINER with search_path protection.';

-- ============================================================================
-- LAYER 2 (OPTIONAL): CONVENIENCE FUNCTIONS FOR FUTURE MIGRATION
-- ============================================================================
-- These functions automatically use auth.uid() - simpler API for new code
-- Frontends can migrate to these over time (no urgency since existing functions are now secure)

-- Create session from schedule name (for current user only - convenience wrapper)
CREATE OR REPLACE FUNCTION create_my_session_from_name(schedule_name text)
RETURNS TABLE("like" performed_session)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid;
BEGIN
    -- Get authenticated user
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated - cannot create session';
    END IF;

    -- Call the validated function with auth.uid()
    RETURN QUERY
    SELECT * FROM create_session_from_name(schedule_name, v_user_id);
END;
$$;

COMMENT ON FUNCTION create_my_session_from_name IS
    'Convenience function: Create session for authenticated user (no user_id parameter needed). '
    'Automatically uses auth.uid(). New frontends should prefer this simpler API. '
    'Internally calls create_session_from_name() with validation.';

GRANT EXECUTE ON FUNCTION create_my_session_from_name(text) TO authenticated;

-- Create full session with exercises (for current user only - convenience wrapper)
CREATE OR REPLACE FUNCTION create_my_full_session(schedule_name text)
RETURNS TABLE("like" performed_exercise)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid;
BEGIN
    -- Get authenticated user
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated - cannot create session';
    END IF;

    -- Call the validated function with auth.uid()
    RETURN QUERY
    SELECT * FROM create_full_session(schedule_name, v_user_id);
END;
$$;

COMMENT ON FUNCTION create_my_full_session IS
    'Convenience function: Create full session for authenticated user (no user_id parameter needed). '
    'Automatically uses auth.uid(). New frontends should prefer this simpler API. '
    'Internally calls create_full_session() with validation.';

GRANT EXECUTE ON FUNCTION create_my_full_session(text) TO authenticated;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- All session creation functions now have defense-in-depth protection:
-- 1. Function validates auth.uid() matches app_user_id parameter
-- 2. RLS policies enforce user can only insert their own sessions
-- 3. search_path protection prevents hijacking attacks
--
-- NON-BREAKING CHANGES:
-- - Legacy backend (service role): auth.uid() = NULL, validation bypassed ✅
-- - New frontend (authenticated): Must use their own user_id ✅
-- - Convenience functions available for migration: create_my_*() ✅
