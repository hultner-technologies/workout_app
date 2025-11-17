-- Supabase Auth Integration: RLS Performance Optimizations
--
-- This migration verifies and optimizes Row Level Security policies for
-- performance with Supabase Auth integration.
--
-- Key Optimization: Using (SELECT auth.uid()) instead of bare auth.uid()
-- Benefits:
--   - PostgreSQL optimizer creates an "InitPlan" that caches the result
--   - auth.uid() is called once per statement instead of once per row
--   - Significant performance improvement for multi-row queries
--
-- Status: Most policies already optimized in 260_rls_policies.sql
-- This migration adds any missing optimizations and documentation
--
-- Created: 2025-11-16
-- Author: Generated from SUPABASE_AUTH_INTEGRATION_PLAN.md

-- =============================================================================
-- VERIFICATION: Check that policies use optimized auth.uid()
-- =============================================================================

-- The existing RLS policies in 260_rls_policies.sql already use the optimized
-- (SELECT auth.uid()) pattern. This is confirmed by reviewing policies:
--
-- ✓ performed_session SELECT: USING (app_user_id = (SELECT auth.uid()))
-- ✓ performed_session INSERT: WITH CHECK (app_user_id = (SELECT auth.uid()))
-- ✓ performed_session UPDATE: USING/WITH CHECK use (SELECT auth.uid())
-- ✓ performed_session DELETE: USING (app_user_id = (SELECT auth.uid()))
-- ✓ performed_exercise policies: Use EXISTS with (SELECT auth.uid())
-- ✓ app_user SELECT: USING (app_user_id = (SELECT auth.uid()))
-- ✓ app_user UPDATE: USING/WITH CHECK use (SELECT auth.uid())
--
-- No changes needed! Policies are already optimized.

-- =============================================================================
-- ADDITIONAL OPTIMIZATIONS: Index Verification
-- =============================================================================

-- RLS policies filter by app_user_id extensively
-- Verify that appropriate indexes exist for optimal performance
-- (These were added in 260_rls_policies.sql but we document them here)

-- Index on performed_session.app_user_id (for SELECT WHERE app_user_id = ...)
-- Already exists: idx_performed_session_app_user_id

-- Composite index for user + date queries (common pattern in workout apps)
-- Already exists: idx_performed_session_user_completed

-- Index for performed_exercise JOIN performance
-- Already exists: idx_performed_exercise_session_id

-- Composite index for RLS join filters
-- Already exists: idx_performed_session_id_user

-- =============================================================================
-- NEW: Add helpful query monitoring function
-- =============================================================================

CREATE OR REPLACE FUNCTION debug_rls_performance(table_name text)
RETURNS TABLE(
  policy_name text,
  policy_definition text,
  uses_optimized_auth_uid boolean
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    pol.polname::text AS policy_name,
    pg_get_expr(pol.polqual, pol.polrelid)::text AS policy_definition,
    pg_get_expr(pol.polqual, pol.polrelid) LIKE '%(SELECT auth.uid())%' AS uses_optimized_auth_uid
  FROM pg_policy pol
  JOIN pg_class cls ON pol.polrelid = cls.oid
  WHERE cls.relname = table_name;
END;
$$;

COMMENT ON FUNCTION debug_rls_performance(text) IS
  'Debug helper to verify RLS policies use optimized (SELECT auth.uid()) pattern. '
  'Usage: SELECT * FROM debug_rls_performance(''performed_session''); '
  'Returns policy definitions and whether they use the optimized auth.uid() call.';

-- =============================================================================
-- DOCUMENTATION: RLS Best Practices
-- =============================================================================

-- Add comments documenting RLS performance best practices

COMMENT ON POLICY "Allow read access for own performed_session" ON public.performed_session IS
  'RLS policy for SELECT on performed_session. '
  'Uses (SELECT auth.uid()) for performance - auth.uid() is cached per statement. '
  'Indexed on app_user_id for fast filtering.';

COMMENT ON POLICY "Allow insert access for own performed_session" ON public.performed_session IS
  'RLS policy for INSERT on performed_session. '
  'Uses (SELECT auth.uid()) for performance. '
  'Ensures users can only insert sessions for themselves.';

COMMENT ON POLICY "Allow update access for own performed_session" ON public.performed_session IS
  'RLS policy for UPDATE on performed_session. '
  'Uses (SELECT auth.uid()) in both USING and WITH CHECK for performance. '
  'Prevents users from transferring sessions to other users.';

COMMENT ON POLICY "Allow delete access for own performed_session" ON public.performed_session IS
  'RLS policy for DELETE on performed_session. '
  'Uses (SELECT auth.uid()) for performance. '
  'Ensures users can only delete their own sessions.';

COMMENT ON POLICY "Allow read access for own app_user" ON public.app_user IS
  'RLS policy for SELECT on app_user. '
  'Uses (SELECT auth.uid()) for performance. '
  'Users can only see their own profile.';

COMMENT ON POLICY "Allow update access for own app_user" ON public.app_user IS
  'RLS policy for UPDATE on app_user. '
  'Uses (SELECT auth.uid()) for performance. '
  'Users can only update their own profile (name, data fields). '
  'Note: Username and email changes should be handled separately with additional validation.';

-- =============================================================================
-- PERFORMANCE TIPS DOCUMENTATION
-- =============================================================================

/*
RLS PERFORMANCE BEST PRACTICES FOR GYMR8
=========================================

1. ALWAYS USE (SELECT auth.uid()) NOT auth.uid()
   ✓ Good: WHERE app_user_id = (SELECT auth.uid())
   ✗ Bad:  WHERE app_user_id = auth.uid()

2. ENSURE INDEXES ON FILTERED COLUMNS
   ✓ Index on app_user_id (for RLS filtering)
   ✓ Composite indexes for common query patterns

3. AVOID COMPLEX JOINS IN RLS POLICIES
   ✓ Use EXISTS for simple checks
   ✗ Avoid deep JOIN chains in policy definitions

4. TEST QUERY PLANS
   Use EXPLAIN ANALYZE to verify RLS policies are using indexes:

   EXPLAIN ANALYZE
   SELECT * FROM performed_session
   WHERE app_user_id = (SELECT auth.uid());

   Look for:
   - "InitPlan" - means auth.uid() is cached ✓
   - "Index Scan" on app_user_id ✓
   - "Seq Scan" - might need optimization ⚠️

5. MONITOR PERFORMANCE
   Use debug_rls_performance() function to verify policies:

   SELECT * FROM debug_rls_performance('performed_session');
   SELECT * FROM debug_rls_performance('performed_exercise');
   SELECT * FROM debug_rls_performance('app_user');

6. SECURITY_INVOKER VS SECURITY_DEFINER
   - Functions with SECURITY DEFINER bypass RLS (use sparingly!)
   - Functions with SECURITY INVOKER respect RLS (preferred for queries)
   - handle_new_user() uses SECURITY DEFINER (needed for user creation)

CURRENT STATUS: All RLS policies are optimized ✓
*/
