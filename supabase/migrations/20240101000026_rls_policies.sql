-- Row Level Security (RLS) Policies
--
-- This file adds comprehensive RLS policies to ensure users can only access
-- their own data in Supabase. Required for multi-tenant security.
--
-- Security Model:
-- - Users can only read/write their own performed_session and performed_exercise records
-- - Session schedules and plans are public (read-only for all users)
-- - Base exercises are public (read-only for all users)
-- - Exercise definitions within a session schedule are public (read-only)
--
-- Note: Supabase uses auth.uid() to get the authenticated user's UUID
--
-- Created: 2025-11-06
-- Author: Claude (Anthropic)

-- =============================================================================
-- TABLE: performed_session
-- Users should only see their own workout sessions
-- =============================================================================

ALTER TABLE public.performed_session ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own performed sessions
CREATE POLICY "Allow read access for own performed_session"
    ON public.performed_session
    FOR SELECT
    TO authenticated
    USING (app_user_id = (SELECT auth.uid()));

-- Drop anonymous access policy if it exists (security fix: anon users shouldn't see all workouts)
-- This policy was overly permissive and allowed any anonymous user to read all workout data
DROP POLICY IF EXISTS "Allow read access for anon performed_session" ON public.performed_session;

-- Allow users to insert their own performed sessions
CREATE POLICY "Allow insert access for own performed_session"
    ON public.performed_session
    FOR INSERT
    TO authenticated
    WITH CHECK (app_user_id = (SELECT auth.uid()));

-- Allow users to update their own performed sessions
CREATE POLICY "Allow update access for own performed_session"
    ON public.performed_session
    FOR UPDATE
    TO authenticated
    USING (app_user_id = (SELECT auth.uid()))
    WITH CHECK (app_user_id = (SELECT auth.uid()));

-- Allow users to delete their own performed sessions
CREATE POLICY "Allow delete access for own performed_session"
    ON public.performed_session
    FOR DELETE
    TO authenticated
    USING (app_user_id = (SELECT auth.uid()));

-- =============================================================================
-- TABLE: performed_exercise
-- Users should only see exercises from their own sessions
-- =============================================================================

ALTER TABLE public.performed_exercise ENABLE ROW LEVEL SECURITY;

-- Allow users to read exercises from their own sessions
CREATE POLICY "Allow read access for own performed_exercise"
    ON public.performed_exercise
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM public.performed_session ps
            WHERE ps.performed_session_id = performed_exercise.performed_session_id
                AND ps.app_user_id = (SELECT auth.uid())
        )
    );

-- Drop anonymous access policy if it exists (security fix: anon users shouldn't see all exercises)
-- This policy was overly permissive and allowed any anonymous user to read all exercise data
DROP POLICY IF EXISTS "Allow read access for anon performed_exercise" ON public.performed_exercise;

-- Allow users to insert exercises into their own sessions
CREATE POLICY "Allow insert access for own performed_exercise"
    ON public.performed_exercise
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.performed_session ps
            WHERE ps.performed_session_id = performed_exercise.performed_session_id
                AND ps.app_user_id = (SELECT auth.uid())
        )
    );

-- Allow users to update exercises in their own sessions
CREATE POLICY "Allow update access for own performed_exercise"
    ON public.performed_exercise
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM public.performed_session ps
            WHERE ps.performed_session_id = performed_exercise.performed_session_id
                AND ps.app_user_id = (SELECT auth.uid())
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.performed_session ps
            WHERE ps.performed_session_id = performed_exercise.performed_session_id
                AND ps.app_user_id = (SELECT auth.uid())
        )
    );

-- Allow users to delete exercises from their own sessions
CREATE POLICY "Allow delete access for own performed_exercise"
    ON public.performed_exercise
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM public.performed_session ps
            WHERE ps.performed_session_id = performed_exercise.performed_session_id
                AND ps.app_user_id = (SELECT auth.uid())
        )
    );

-- =============================================================================
-- TABLE: session_schedule (read-only for all users)
-- Public workout templates that all users can view
-- =============================================================================

ALTER TABLE public.session_schedule ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read session schedules
CREATE POLICY "Allow read access for all session_schedule"
    ON public.session_schedule
    FOR SELECT
    TO authenticated, anon
    USING (true);

-- Prevent users from modifying session schedules
-- (Only admins can do this via direct database access)
CREATE POLICY "Prevent insert access session_schedule"
    ON public.session_schedule
    FOR INSERT
    TO authenticated, anon
    WITH CHECK (false);

CREATE POLICY "Prevent update access session_schedule"
    ON public.session_schedule
    FOR UPDATE
    TO authenticated, anon
    WITH CHECK (false);

CREATE POLICY "Prevent delete access session_schedule"
    ON public.session_schedule
    FOR DELETE
    TO authenticated, anon
    USING (false);

-- =============================================================================
-- TABLE: plan (read-only for all users)
-- Public workout plans that all users can view
-- =============================================================================

ALTER TABLE public.plan ENABLE ROW LEVEL SECURITY;

-- Allow all users to read plans
CREATE POLICY "Allow read access for all plan"
    ON public.plan
    FOR SELECT
    TO authenticated, anon
    USING (true);

-- Prevent users from modifying plans
CREATE POLICY "Prevent insert access plan"
    ON public.plan
    FOR INSERT
    TO authenticated, anon
    WITH CHECK (false);

CREATE POLICY "Prevent update access plan"
    ON public.plan
    FOR UPDATE
    TO authenticated, anon
    WITH CHECK (false);

CREATE POLICY "Prevent delete access plan"
    ON public.plan
    FOR DELETE
    TO authenticated, anon
    USING (false);

-- =============================================================================
-- TABLE: exercise (read-only for all users)
-- Exercise definitions within session schedules
-- =============================================================================

ALTER TABLE public.exercise ENABLE ROW LEVEL SECURITY;

-- Allow all users to read exercises
CREATE POLICY "Allow read access for all exercise"
    ON public.exercise
    FOR SELECT
    TO authenticated, anon
    USING (true);

-- Prevent users from modifying exercises
CREATE POLICY "Prevent insert access exercise"
    ON public.exercise
    FOR INSERT
    TO authenticated, anon
    WITH CHECK (false);

CREATE POLICY "Prevent update access exercise"
    ON public.exercise
    FOR UPDATE
    TO authenticated, anon
    WITH CHECK (false);

CREATE POLICY "Prevent delete access exercise"
    ON public.exercise
    FOR DELETE
    TO authenticated, anon
    USING (false);

-- =============================================================================
-- TABLE: base_exercise (read-only for all users)
-- Exercise catalog that all users can view
-- =============================================================================

ALTER TABLE public.base_exercise ENABLE ROW LEVEL SECURITY;

-- Allow all users to read base exercises
CREATE POLICY "Allow read access for all base_exercise"
    ON public.base_exercise
    FOR SELECT
    TO authenticated, anon
    USING (true);

-- Prevent users from modifying base exercises
CREATE POLICY "Prevent insert access base_exercise"
    ON public.base_exercise
    FOR INSERT
    TO authenticated, anon
    WITH CHECK (false);

CREATE POLICY "Prevent update access base_exercise"
    ON public.base_exercise
    FOR UPDATE
    TO authenticated, anon
    WITH CHECK (false);

CREATE POLICY "Prevent delete access base_exercise"
    ON public.base_exercise
    FOR DELETE
    TO authenticated, anon
    USING (false);

-- =============================================================================
-- TABLE: app_user (users can only read their own data)
-- =============================================================================

ALTER TABLE public.app_user ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own user record
CREATE POLICY "Allow read access for own app_user"
    ON public.app_user
    FOR SELECT
    TO authenticated
    USING (app_user_id = (SELECT auth.uid()));

-- Allow users to update their own profile
CREATE POLICY "Allow update access for own app_user"
    ON public.app_user
    FOR UPDATE
    TO authenticated
    USING (app_user_id = (SELECT auth.uid()))
    WITH CHECK (app_user_id = (SELECT auth.uid()));

-- Prevent direct user creation (should be handled by auth system)
CREATE POLICY "Prevent insert access app_user"
    ON public.app_user
    FOR INSERT
    TO authenticated, anon
    WITH CHECK (false);

-- Prevent user deletion (should be handled by auth system)
CREATE POLICY "Prevent delete access app_user"
    ON public.app_user
    FOR DELETE
    TO authenticated, anon
    USING (false);

-- =============================================================================
-- VIEWS: session_schedule_metadata
-- Inherits security from underlying tables
-- =============================================================================

-- Views with security_invoker=on run with the invoker's permissions
-- and automatically respect RLS policies on underlying tables.
-- No additional policies needed for session_schedule_metadata view.

COMMENT ON VIEW session_schedule_metadata IS
    'Provides session schedule information with exercise counts. '
    'Uses security_invoker=on, so respects RLS policies on underlying tables. '
    'Safe for use with Supabase RLS.';

-- =============================================================================
-- SECURITY NOTES FOR FUNCTIONS
-- =============================================================================

-- draft_session_exercises() uses:
--   - LANGUAGE SQL with default SECURITY INVOKER behavior
--   - Queries performed_session table which has RLS
--   - Will automatically filter to only the user's own sessions
--
-- performed_session_details() uses:
--   - LANGUAGE SQL with default SECURITY INVOKER behavior
--   - Queries performed_session table which has RLS
--   - Will automatically filter to only the user's own sessions
--
-- Both functions are secure because they:
-- 1. Use SECURITY INVOKER (default for SQL functions)
-- 2. Query tables with RLS enabled
-- 3. Respect the authenticated user's permissions

COMMENT ON FUNCTION draft_session_exercises_v2(uuid) IS
    'Secure function that respects RLS policies. '
    'Uses SECURITY INVOKER to run with caller permissions. '
    'Automatically filters to only sessions owned by auth.uid().';

COMMENT ON FUNCTION performed_session_details(uuid) IS
    'Secure function that respects RLS policies. '
    'Uses SECURITY INVOKER to run with caller permissions. '
    'Automatically filters to only sessions owned by auth.uid().';

-- =============================================================================
-- Performance Optimization: Indexes for RLS Queries
-- =============================================================================
--
-- RLS policies add WHERE app_user_id = auth.uid() to every query.
-- Without indexes, these queries will perform table scans.
-- These indexes dramatically improve performance for multi-tenant queries.

-- Index for filtering performed_session by app_user_id
-- Used by: SELECT policies on performed_session
CREATE INDEX IF NOT EXISTS idx_performed_session_app_user_id
    ON public.performed_session(app_user_id);

-- Index for JOINing performed_exercise to performed_session in RLS policies
-- Used by: EXISTS subqueries in performed_exercise policies
CREATE INDEX IF NOT EXISTS idx_performed_exercise_session_id
    ON public.performed_exercise(performed_session_id);

COMMENT ON INDEX idx_performed_session_app_user_id IS
    'Performance optimization for RLS policies that filter by app_user_id';

COMMENT ON INDEX idx_performed_exercise_session_id IS
    'Performance optimization for RLS policies that JOIN to performed_session';
