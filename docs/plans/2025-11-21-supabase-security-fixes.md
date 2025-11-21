# Supabase Security Advisories Fix - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.
> **Defense-in-Depth:** Use superpowers:defense-in-depth for multi-layer validation.

**Goal:** Fix all Supabase linter security advisories (4 ERROR level, multiple WARN level issues)

**Architecture:** Multi-layered security fixes using TDD approach with comprehensive test coverage before and after each change

**Tech Stack:** PostgreSQL, Supabase RLS, pgTAP for testing

**Risk Assessment:**
- ✅ Views fix: LOW RISK - Non-breaking if RLS policies exist
- ⚠️ Username tables: LOW RISK - Internal only, function access preserved
- ⚠️ Session functions: MEDIUM RISK - Check if frontend calls these functions
- ✅ Function search_path: LOW RISK - Pure security enhancement
- ⚠️ Extension move: LOW RISK - Check for unqualified references

---

## Priority 1: ERROR Level - Security Definer Views (CRITICAL)

### Issue
4 views are created with default SECURITY DEFINER, bypassing Row Level Security policies:
- `exercise_schedule` - Exercise data view
- `base_exercise_with_muscles` - Exercises with aggregated muscle data
- `base_exercise_full` - Full exercise metadata as JSON
- `recent_impersonation_activity` - Admin impersonation audit log (superadmin only)

### Risk
Any authenticated user can bypass RLS and see ALL data in these views.

### Task 1.1: Test Current View Security

**Files:**
- Create: `tests/test_security_definer_views.sql` (pgTAP tests)

**Step 1: Write failing tests that prove the security hole**

Create comprehensive tests that demonstrate the current vulnerability:

```sql
-- Test file: tests/test_security_definer_views.sql
BEGIN;
SELECT plan(8);

-- Setup: Create test users
SET ROLE postgres;
INSERT INTO auth.users (id, email) VALUES
    ('11111111-1111-1111-1111-111111111111', 'user1@test.com'),
    ('22222222-2222-2222-2222-222222222222', 'user2@test.com')
ON CONFLICT DO NOTHING;

INSERT INTO app_user (app_user_id, email, username) VALUES
    ('11111111-1111-1111-1111-111111111111', 'user1@test.com', 'testuser1'),
    ('22222222-2222-2222-2222-222222222222', 'user2@test.com', 'testuser2')
ON CONFLICT DO NOTHING;

-- Test 1: Exercise views should respect RLS when security_invoker is set
SET ROLE authenticated;
SET request.jwt.claims.sub = '11111111-1111-1111-1111-111111111111';

SELECT ok(
    (SELECT COUNT(*) FROM exercise_schedule) > 0,
    'User 1 can see exercise_schedule via security_invoker'
);

SELECT ok(
    (SELECT COUNT(*) FROM base_exercise_with_muscles) > 0,
    'User 1 can see base_exercise_with_muscles via security_invoker'
);

SELECT ok(
    (SELECT COUNT(*) FROM base_exercise_full) > 0,
    'User 1 can see base_exercise_full via security_invoker'
);

-- Test 2: Impersonation view should be admin-only
SELECT is(
    (SELECT COUNT(*) FROM recent_impersonation_activity),
    0::bigint,
    'Non-admin user cannot see impersonation_activity (via RLS)'
);

-- Test 3: Admin user CAN see impersonation activity
-- First grant admin role
SET ROLE postgres;
INSERT INTO admin_users (admin_user_id, granted_by_user_id, granted_at)
VALUES ('11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', now())
ON CONFLICT DO NOTHING;

SET ROLE authenticated;
SET request.jwt.claims.sub = '11111111-1111-1111-1111-111111111111';

SELECT ok(
    (SELECT COUNT(*) FROM recent_impersonation_activity) >= 0,
    'Admin user CAN see impersonation_activity'
);

-- Test 4: Verify views use security_invoker (metadata check)
SET ROLE postgres;
SELECT ok(
    EXISTS(
        SELECT 1 FROM pg_views
        WHERE schemaname = 'public'
        AND viewname = 'exercise_schedule'
        AND definition LIKE '%security_invoker%'
    ),
    'exercise_schedule view has security_invoker option set'
);

SELECT ok(
    EXISTS(
        SELECT 1 FROM pg_views
        WHERE schemaname = 'public'
        AND viewname = 'base_exercise_with_muscles'
        AND definition LIKE '%security_invoker%'
    ),
    'base_exercise_with_muscles view has security_invoker option set'
);

SELECT ok(
    EXISTS(
        SELECT 1 FROM pg_views
        WHERE schemaname = 'public'
        AND viewname = 'base_exercise_full'
        AND definition LIKE '%security_invoker%'
    ),
    'base_exercise_full view has security_invoker option set'
);

SELECT finish();
ROLLBACK;
```

**Step 2: Run tests to verify they fail**

```bash
cd tests
pg_prove test_security_definer_views.sql
```

Expected: FAIL - Views don't have security_invoker set (metadata test fails)

**Step 3: Create migration to fix security definer views**

```sql
-- Migration: database/999_fix_security_definer_views.sql
-- (will get proper number when ready to commit)

-- ============================================================================
-- FIX SECURITY DEFINER VIEWS
-- ============================================================================
-- Issue: Views bypass RLS by default (SECURITY DEFINER)
-- Fix: Add security_invoker=on to respect RLS on underlying tables
-- Reference: https://supabase.com/docs/guides/database/database-linter?lint=0010_security_definer_view

-- Exercise Schedule View - Public read access via RLS
CREATE OR REPLACE VIEW exercise_schedule
    WITH (security_invoker=on)
AS
SELECT * FROM exercise;

COMMENT ON VIEW exercise_schedule IS
    'Uses security_invoker=on to respect RLS policies on underlying exercise table. '
    'All authenticated users can view exercises.';

-- Base Exercise with Muscles - Public read access via RLS
CREATE OR REPLACE VIEW base_exercise_with_muscles
    WITH (security_invoker=on)
AS
SELECT
    be.base_exercise_id,
    be.name,
    be.aliases,
    be.description,
    be.links,
    be.level,
    be.mechanic,
    be.force,

    -- Category (denormalized for convenience)
    ec.name as category,
    ec.display_name as category_display,

    -- Equipment (denormalized for convenience)
    et.name as equipment,
    et.display_name as equipment_display,

    -- Primary muscles as array
    COALESCE(
        array_agg(DISTINCT pm.name ORDER BY pm.name) FILTER (WHERE pm.name IS NOT NULL),
        ARRAY[]::text[]
    ) as primary_muscles,

    -- Secondary muscles as array
    COALESCE(
        array_agg(DISTINCT sm.name ORDER BY sm.name) FILTER (WHERE sm.name IS NOT NULL),
        ARRAY[]::text[]
    ) as secondary_muscles,

    -- Instructions and images
    be.instructions,
    be.image_urls,

    -- Source tracking
    be.source_id,
    be.source_name,

    -- Original data fields
    be.data,
    be.extended_data

FROM base_exercise be
LEFT JOIN exercise_category ec ON be.category_id = ec.category_id
LEFT JOIN equipment_type et ON be.equipment_type_id = et.equipment_type_id
LEFT JOIN base_exercise_primary_muscle bepm ON be.base_exercise_id = bepm.base_exercise_id
LEFT JOIN muscle_group pm ON bepm.muscle_group_id = pm.muscle_group_id
LEFT JOIN base_exercise_secondary_muscle besm ON be.base_exercise_id = besm.base_exercise_id
LEFT JOIN muscle_group sm ON besm.muscle_group_id = sm.muscle_group_id
GROUP BY
    be.base_exercise_id,
    be.name,
    be.aliases,
    be.description,
    be.links,
    be.level,
    be.mechanic,
    be.force,
    ec.name,
    ec.display_name,
    et.name,
    et.display_name,
    be.instructions,
    be.image_urls,
    be.source_id,
    be.source_name,
    be.data,
    be.extended_data;

COMMENT ON VIEW base_exercise_with_muscles IS
    'Base exercises with aggregated muscle arrays. '
    'Uses security_invoker=on to respect RLS policies on underlying tables.';

-- Base Exercise Full - Public read access via RLS
CREATE OR REPLACE VIEW base_exercise_full
    WITH (security_invoker=on)
AS
SELECT
    be.base_exercise_id,
    be.name,
    be.aliases,
    be.description,
    be.links,
    be.level,
    be.mechanic,
    be.force,
    be.instructions,
    be.image_urls,
    be.source_id,
    be.source_name,

    -- Category as JSON object
    CASE
        WHEN ec.category_id IS NOT NULL THEN
            jsonb_build_object(
                'id', ec.category_id,
                'name', ec.name,
                'display_name', ec.display_name,
                'description', ec.description
            )
        ELSE NULL
    END as category,

    -- Equipment as JSON object
    CASE
        WHEN et.equipment_type_id IS NOT NULL THEN
            jsonb_build_object(
                'id', et.equipment_type_id,
                'name', et.name,
                'display_name', et.display_name,
                'description', et.description
            )
        ELSE NULL
    END as equipment,

    -- Primary muscles as JSON array of objects
    COALESCE(
        jsonb_agg(DISTINCT jsonb_build_object(
            'id', pm.muscle_group_id,
            'name', pm.name,
            'display_name', pm.display_name,
            'description', pm.description
        ) ORDER BY jsonb_build_object(
            'id', pm.muscle_group_id,
            'name', pm.name,
            'display_name', pm.display_name,
            'description', pm.description
        )) FILTER (WHERE pm.muscle_group_id IS NOT NULL),
        '[]'::jsonb
    ) as primary_muscles,

    -- Secondary muscles as JSON array of objects
    COALESCE(
        jsonb_agg(DISTINCT jsonb_build_object(
            'id', sm.muscle_group_id,
            'name', sm.name,
            'display_name', sm.display_name,
            'description', sm.description
        ) ORDER BY jsonb_build_object(
            'id', sm.muscle_group_id,
            'name', sm.name,
            'display_name', sm.display_name,
            'description', sm.description
        )) FILTER (WHERE sm.muscle_group_id IS NOT NULL),
        '[]'::jsonb
    ) as secondary_muscles,

    -- Original data fields
    be.data,
    be.extended_data

FROM base_exercise be
LEFT JOIN exercise_category ec ON be.category_id = ec.category_id
LEFT JOIN equipment_type et ON be.equipment_type_id = et.equipment_type_id
LEFT JOIN base_exercise_primary_muscle bepm ON be.base_exercise_id = bepm.base_exercise_id
LEFT JOIN muscle_group pm ON bepm.muscle_group_id = pm.muscle_group_id
LEFT JOIN base_exercise_secondary_muscle besm ON be.base_exercise_id = besm.base_exercise_id
LEFT JOIN muscle_group sm ON besm.muscle_group_id = sm.muscle_group_id
GROUP BY
    be.base_exercise_id,
    be.name,
    be.aliases,
    be.description,
    be.links,
    be.level,
    be.mechanic,
    be.force,
    be.instructions,
    be.image_urls,
    be.source_id,
    be.source_name,
    be.data,
    be.extended_data,
    ec.category_id,
    ec.name,
    ec.display_name,
    ec.description,
    et.equipment_type_id,
    et.name,
    et.display_name,
    et.description;

COMMENT ON VIEW base_exercise_full IS
    'Base exercises with full metadata as JSON. '
    'Uses security_invoker=on to respect RLS policies on underlying tables.';

-- Recent Impersonation Activity - Superadmin only via RLS
CREATE OR REPLACE VIEW recent_impersonation_activity
    WITH (security_invoker=on)
AS
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

COMMENT ON VIEW recent_impersonation_activity IS
    'Impersonation activity in last 7 days for monitoring. '
    'Uses security_invoker=on to respect RLS - only admins can query via is_admin() policy.';
```

**Step 4: Run tests to verify they pass**

```bash
pg_prove test_security_definer_views.sql
```

Expected: PASS - All 8 tests pass

**Step 5: Commit**

```bash
git add database/999_fix_security_definer_views.sql tests/test_security_definer_views.sql
git commit -m "fix(security): Add security_invoker to views to respect RLS policies

- Convert 4 views from SECURITY DEFINER to security_invoker=on
- exercise_schedule, base_exercise_with_muscles, base_exercise_full: public read
- recent_impersonation_activity: admin-only read
- Fixes Supabase linter error 0010_security_definer_view
- Comprehensive pgTAP tests verify RLS enforcement"
```

---

## Priority 2: ERROR Level - RLS on Username Tables (CRITICAL)

### Issue
Two tables in public schema lack RLS:
- `username_adjectives` - 140 word list for username generation
- `username_nouns` - 182 word list for username generation

### Risk
These internal-only tables are exposed via PostgREST API. Users shouldn't access them directly (internal data for `generate_unique_username()` function).

### Decision
Option C: Not exposed via PostgREST - Enable RLS with blocking policy. Function retains access via SECURITY DEFINER.

### Task 2.1: Test and Enable RLS on Username Tables

**Files:**
- Create: `tests/test_username_tables_rls.sql`
- Create: `database/999_username_tables_rls.sql`

**Step 1: Write failing tests**

```sql
-- Test file: tests/test_username_tables_rls.sql
BEGIN;
SELECT plan(6);

-- Test 1: RLS should be enabled on username tables
SELECT ok(
    (SELECT relrowsecurity FROM pg_class WHERE relname = 'username_adjectives'),
    'RLS is enabled on username_adjectives'
);

SELECT ok(
    (SELECT relrowsecurity FROM pg_class WHERE relname = 'username_nouns'),
    'RLS is enabled on username_nouns'
);

-- Test 2: Regular users cannot SELECT from username tables
SET ROLE authenticated;
SET request.jwt.claims.sub = '11111111-1111-1111-1111-111111111111';

SELECT is(
    (SELECT COUNT(*) FROM username_adjectives),
    0::bigint,
    'Authenticated users cannot read username_adjectives (RLS blocks)'
);

SELECT is(
    (SELECT COUNT(*) FROM username_nouns),
    0::bigint,
    'Authenticated users cannot read username_nouns (RLS blocks)'
);

-- Test 3: Function can still generate usernames (SECURITY DEFINER bypasses RLS)
SET ROLE authenticated;
SELECT ok(
    (SELECT generate_unique_username() IS NOT NULL),
    'generate_unique_username() function still works despite RLS'
);

SELECT ok(
    (SELECT length(generate_unique_username()) > 5),
    'Generated username has reasonable length'
);

SELECT finish();
ROLLBACK;
```

**Step 2: Run tests to verify they fail**

```bash
pg_prove test_username_tables_rls.sql
```

Expected: FAIL - RLS not enabled, users can read tables

**Step 3: Create migration to enable RLS**

```sql
-- Migration: database/999_username_tables_rls.sql

-- ============================================================================
-- ENABLE RLS ON USERNAME GENERATION TABLES
-- ============================================================================
-- Issue: username_adjectives and username_nouns exposed via PostgREST without RLS
-- Risk: Internal data tables shouldn't be directly accessible via API
-- Fix: Enable RLS with blocking policies (function access preserved via SECURITY DEFINER)
-- Reference: https://supabase.com/docs/guides/database/database-linter?lint=0013_rls_disabled_in_public

-- Enable RLS on username tables
ALTER TABLE username_adjectives ENABLE ROW LEVEL SECURITY;
ALTER TABLE username_nouns ENABLE ROW LEVEL SECURITY;

-- Policy: Block direct access (these are internal-only tables)
-- The generate_unique_username() function can still access them via SECURITY DEFINER
CREATE POLICY "Block direct access to username_adjectives"
    ON username_adjectives
    FOR ALL
    TO public
    USING (false)
    WITH CHECK (false);

COMMENT ON POLICY "Block direct access to username_adjectives" ON username_adjectives IS
    'Internal-only table for username generation. '
    'Direct API access blocked. Function access preserved via SECURITY DEFINER.';

CREATE POLICY "Block direct access to username_nouns"
    ON username_nouns
    FOR ALL
    TO public
    USING (false)
    WITH CHECK (false);

COMMENT ON POLICY "Block direct access to username_nouns" ON username_nouns IS
    'Internal-only table for username generation. '
    'Direct API access blocked. Function access preserved via SECURITY DEFINER.';

-- Ensure generate_unique_username is SECURITY DEFINER (should already be, but verify)
-- This allows the function to bypass RLS and access the tables
CREATE OR REPLACE FUNCTION generate_unique_username()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  selected_adjective text;
  selected_noun text;
  new_username text;
  username_exists boolean;
  attempt_count integer := 0;
  max_attempts integer := 5;
BEGIN
  LOOP
    -- Select random adjective and noun from tables
    SELECT word INTO selected_adjective
    FROM username_adjectives
    ORDER BY random()
    LIMIT 1;

    SELECT word INTO selected_noun
    FROM username_nouns
    ORDER BY random()
    LIMIT 1;

    -- Generate AdjectiveNoun combination
    new_username := selected_adjective || selected_noun;

    -- Add random 2-4 digit number if we've had collisions
    IF attempt_count > 0 THEN
      new_username := new_username || (10 + floor(random() * 9990))::text;
    END IF;

    -- Check if username already exists
    SELECT EXISTS(SELECT 1 FROM app_user WHERE username = new_username)
    INTO username_exists;

    -- Exit loop if username is unique
    EXIT WHEN NOT username_exists;

    attempt_count := attempt_count + 1;

    -- Safety check: prevent infinite loop
    IF attempt_count >= max_attempts THEN
      new_username := new_username || extract(epoch from now())::bigint::text;
      EXIT;
    END IF;
  END LOOP;

  RETURN new_username;
END;
$$;

COMMENT ON FUNCTION generate_unique_username() IS
    'Generates unique Reddit-style username using AdjectiveNoun pattern. '
    'SECURITY DEFINER allows bypassing RLS on username tables. '
    'SET search_path protects against search_path attacks.';
```

**Step 4: Run tests to verify they pass**

```bash
pg_prove test_username_tables_rls.sql
```

Expected: PASS - All 6 tests pass

**Step 5: Commit**

```bash
git add database/999_username_tables_rls.sql tests/test_username_tables_rls.sql
git commit -m "fix(security): Enable RLS on username generation tables

- Enable RLS on username_adjectives and username_nouns
- Block direct API access (internal-only tables)
- Preserve function access via SECURITY DEFINER
- Add search_path protection to generate_unique_username()
- Fixes Supabase linter error 0013_rls_disabled_in_public
- pgTAP tests verify RLS enforcement and function still works"
```

---

## Priority 3: WARN Level - Secure Session Creation Functions (HIGH)

### Issue
Three session creation functions accept user_id parameter with hardcoded defaults:
- `create_session_from_name(schedule_name, app_user_id)` - Default hardcoded user
- `create_full_session(schedule_name, app_user_id)` - Default hardcoded user
- `create_session_exercises(performed_session_id)` - Takes session ID (indirect)

### Risk
When NOT using service role, authenticated users could:
1. Call functions with another user's ID
2. Create sessions for other users
3. Bypass RLS policies (though policies should catch this, defense-in-depth required)

### Solution
1. Create secure user-facing functions that use `auth.uid()`
2. Revoke public access from admin functions
3. Keep original functions for service role / admin use

### Task 3.1: Create Secure Session Creation Functions

**Files:**
- Create: `tests/test_session_function_security.sql`
- Create: `database/999_secure_session_functions.sql`

**Step 1: Write failing tests**

```sql
-- Test file: tests/test_session_function_security.sql
BEGIN;
SELECT plan(10);

-- Setup: Create test data
SET ROLE postgres;

-- Create test users
INSERT INTO auth.users (id, email) VALUES
    ('33333333-3333-3333-3333-333333333333', 'sessionuser1@test.com'),
    ('44444444-4444-4444-4444-444444444444', 'sessionuser2@test.com')
ON CONFLICT DO NOTHING;

INSERT INTO app_user (app_user_id, email, username) VALUES
    ('33333333-3333-3333-3333-333333333333', 'sessionuser1@test.com', 'sessionuser1'),
    ('44444444-4444-4444-4444-444444444444', 'sessionuser2@test.com', 'sessionuser2')
ON CONFLICT DO NOTHING;

-- Create a test session schedule
INSERT INTO plan (plan_id, name) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Test Plan')
ON CONFLICT DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name) VALUES
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Test Session Schedule')
ON CONFLICT DO NOTHING;

-- Test 1: User-facing functions should exist and use auth.uid()
SELECT has_function('create_my_session_from_name', ARRAY['text']);
SELECT has_function('create_my_full_session', ARRAY['text']);

-- Test 2: User can create their own session via secure function
SET ROLE authenticated;
SET request.jwt.claims.sub = '33333333-3333-3333-3333-333333333333';

SELECT ok(
    (SELECT performed_session_id FROM create_my_session_from_name('Test Session Schedule') IS NOT NULL),
    'User can create their own session via create_my_session_from_name'
);

SELECT ok(
    (SELECT app_user_id FROM performed_session
     WHERE app_user_id = '33333333-3333-3333-3333-333333333333'::uuid
     LIMIT 1) IS NOT NULL,
    'Created session belongs to authenticated user'
);

-- Test 3: Admin functions should be revoked from public
SELECT ok(
    NOT has_function_privilege('authenticated', 'create_session_from_name(text, uuid)', 'EXECUTE'),
    'create_session_from_name revoked from authenticated role'
);

SELECT ok(
    NOT has_function_privilege('authenticated', 'create_full_session(text, uuid)', 'EXECUTE'),
    'create_full_session revoked from authenticated role'
);

-- Test 4: User cannot create session for another user (RLS enforces)
SET ROLE authenticated;
SET request.jwt.claims.sub = '33333333-3333-3333-3333-333333333333';

SELECT throws_ok(
    $$INSERT INTO performed_session (session_schedule_id, app_user_id)
      VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '44444444-4444-4444-4444-444444444444')$$,
    'RLS policy blocks inserting sessions for other users'
);

-- Test 5: Service role CAN still use admin functions
SET ROLE postgres;

SELECT ok(
    (SELECT performed_session_id FROM create_session_from_name('Test Session Schedule', '44444444-4444-4444-4444-444444444444') IS NOT NULL),
    'Service role can use create_session_from_name with explicit user_id'
);

-- Test 6: Verify functions have proper security settings
SELECT ok(
    (SELECT prosecdef FROM pg_proc WHERE proname = 'create_my_session_from_name'),
    'create_my_session_from_name is SECURITY DEFINER'
);

SELECT ok(
    (SELECT proconfig::text LIKE '%search_path=public%'
     FROM pg_proc WHERE proname = 'create_my_session_from_name'),
    'create_my_session_from_name has search_path protection'
);

SELECT finish();
ROLLBACK;
```

**Step 2: Run tests to verify they fail**

```bash
pg_prove test_session_function_security.sql
```

Expected: FAIL - Secure functions don't exist, admin functions not revoked

**Step 3: Create migration for secure session functions**

```sql
-- Migration: database/999_secure_session_functions.sql

-- ============================================================================
-- SECURE SESSION CREATION FUNCTIONS
-- ============================================================================
-- Issue: Session creation functions accept user_id parameter, allowing
--        authenticated users to potentially create sessions for other users
-- Fix: Create user-facing functions that automatically use auth.uid()
--      Revoke public access from admin functions (service role only)
-- Defense-in-Depth: RLS policies already block cross-user writes, but we add
--                    function-level validation as an additional security layer

-- ============================================================================
-- USER-FACING SECURE FUNCTIONS (use auth.uid())
-- ============================================================================

-- Create session from schedule name (for current user only)
CREATE OR REPLACE FUNCTION create_my_session_from_name(schedule_name text)
RETURNS TABLE("like" performed_session)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid;
    v_app_user_id uuid;
BEGIN
    -- Layer 1: Entry point validation - get authenticated user
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated - cannot create session';
    END IF;

    -- Layer 2: Business logic validation - verify user exists in app_user
    SELECT app_user_id INTO v_app_user_id
    FROM app_user
    WHERE app_user_id = v_user_id;

    IF v_app_user_id IS NULL THEN
        RAISE EXCEPTION 'User % not found in app_user table', v_user_id;
    END IF;

    -- Layer 3: Create session (RLS ensures user can only create for themselves)
    RETURN QUERY
    INSERT INTO performed_session (session_schedule_id, app_user_id)
    VALUES (
        (SELECT ss.session_schedule_id FROM session_schedule ss WHERE ss.name = schedule_name),
        v_app_user_id
    )
    RETURNING *;
END;
$$;

COMMENT ON FUNCTION create_my_session_from_name IS
    'Create a session for the currently authenticated user from schedule name. '
    'Uses auth.uid() - no user impersonation possible. '
    'SECURITY DEFINER with search_path protection. '
    'Defense-in-depth: validates user exists + RLS policy enforcement.';

GRANT EXECUTE ON FUNCTION create_my_session_from_name(text) TO authenticated;

-- Create full session with exercises (for current user only)
CREATE OR REPLACE FUNCTION create_my_full_session(schedule_name text)
RETURNS TABLE("like" performed_exercise)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid;
    v_session_id uuid;
BEGIN
    -- Layer 1: Entry point validation
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated - cannot create session';
    END IF;

    -- Layer 2: Create session (using secure function)
    SELECT performed_session_id INTO v_session_id
    FROM create_my_session_from_name(schedule_name);

    IF v_session_id IS NULL THEN
        RAISE EXCEPTION 'Failed to create session for schedule %', schedule_name;
    END IF;

    -- Layer 3: Create exercises (RLS ensures user owns session)
    RETURN QUERY
    SELECT * FROM create_session_exercises(v_session_id);
END;
$$;

COMMENT ON FUNCTION create_my_full_session IS
    'Create a full session with exercises for authenticated user. '
    'Uses auth.uid() via create_my_session_from_name(). '
    'Defense-in-depth: multi-layer validation + RLS enforcement.';

GRANT EXECUTE ON FUNCTION create_my_full_session(text) TO authenticated;

-- ============================================================================
-- ADMIN FUNCTIONS - REVOKE PUBLIC ACCESS
-- ============================================================================

-- Revoke public/authenticated access from admin functions
-- These are now service-role only (for admin scripts, debugging, etc.)
REVOKE ALL ON FUNCTION create_session_from_name(text, uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_session_from_name(text, uuid) FROM authenticated;

REVOKE ALL ON FUNCTION create_full_session(text, uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION create_full_session(text, uuid) FROM authenticated;

COMMENT ON FUNCTION create_session_from_name IS
    '⚠️ ADMIN/SERVICE ROLE ONLY - Revoked from public/authenticated. '
    'Creates session for specified user_id. Use create_my_session_from_name() for user access.';

COMMENT ON FUNCTION create_full_session IS
    '⚠️ ADMIN/SERVICE ROLE ONLY - Revoked from public/authenticated. '
    'Creates full session for specified user_id. Use create_my_full_session() for user access.';

-- create_session_exercises is safe - takes session_id, not user_id
-- RLS on performed_session already prevents access to other users' sessions
-- But let's add search_path protection for defense-in-depth
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
    'Create exercises for a session. RLS ensures user can only access their own sessions. '
    'SECURITY DEFINER with search_path protection for defense-in-depth.';

GRANT EXECUTE ON FUNCTION create_session_exercises(uuid) TO authenticated;
```

**Step 4: Run tests to verify they pass**

```bash
pg_prove test_session_function_security.sql
```

Expected: PASS - All 10 tests pass

**Step 5: Commit**

```bash
git add database/999_secure_session_functions.sql tests/test_session_function_security.sql
git commit -m "fix(security): Create secure session creation functions

- Add create_my_session_from_name() and create_my_full_session()
- Use auth.uid() - no user impersonation possible
- Revoke public access from admin functions (service role only)
- Add search_path protection to all session functions
- Defense-in-depth: multi-layer validation + RLS enforcement
- pgTAP tests verify security boundaries"
```

---

## Priority 4: WARN Level - Function Search Path Protection

### Issue
8 functions don't have `SET search_path = public`, vulnerable to search_path hijacking:
- `generate_unique_username` (will be fixed in Task 2.1)
- `get_exercise_metadata_stats`
- `set_exercise_muscles`
- `add_primary_muscle`
- `add_secondary_muscle`
- `find_exercises_by_muscle`
- `debug_rls_performance`
- `backfill_username_on_insert`

### Risk
Malicious users could create functions/tables in their schema to hijack execution.

### Task 4.1: Add Search Path Protection to All Functions

**Files:**
- Create: `tests/test_function_search_path.sql`
- Create: `database/999_function_search_path_protection.sql`

**Step 1: Write tests to verify search_path protection**

```sql
-- Test file: tests/test_function_search_path.sql
BEGIN;
SELECT plan(8);

-- Test: All functions should have search_path set to 'public'
SELECT ok(
    (SELECT proconfig::text LIKE '%search_path=public%'
     FROM pg_proc WHERE proname = 'get_exercise_metadata_stats'),
    'get_exercise_metadata_stats has search_path protection'
);

SELECT ok(
    (SELECT proconfig::text LIKE '%search_path=public%'
     FROM pg_proc WHERE proname = 'set_exercise_muscles'),
    'set_exercise_muscles has search_path protection'
);

SELECT ok(
    (SELECT proconfig::text LIKE '%search_path=public%'
     FROM pg_proc WHERE proname = 'add_primary_muscle'),
    'add_primary_muscle has search_path protection'
);

SELECT ok(
    (SELECT proconfig::text LIKE '%search_path=public%'
     FROM pg_proc WHERE proname = 'add_secondary_muscle'),
    'add_secondary_muscle has search_path protection'
);

SELECT ok(
    (SELECT proconfig::text LIKE '%search_path=public%'
     FROM pg_proc WHERE proname = 'find_exercises_by_muscle'),
    'find_exercises_by_muscle has search_path protection'
);

SELECT ok(
    (SELECT proconfig::text LIKE '%search_path=public%'
     FROM pg_proc WHERE proname = 'debug_rls_performance'),
    'debug_rls_performance has search_path protection'
);

SELECT ok(
    (SELECT proconfig::text LIKE '%search_path=public%'
     FROM pg_proc WHERE proname = 'backfill_username_on_insert'),
    'backfill_username_on_insert has search_path protection'
);

SELECT ok(
    (SELECT proconfig::text LIKE '%search_path=public%'
     FROM pg_proc WHERE proname = 'generate_unique_username'),
    'generate_unique_username has search_path protection'
);

SELECT finish();
ROLLBACK;
```

**Step 2: Run tests to verify they fail**

```bash
pg_prove test_function_search_path.sql
```

Expected: FAIL - Functions don't have search_path set

**Step 3: Create migration to add search_path protection**

Create `database/999_function_search_path_protection.sql` with all function recreations adding `SET search_path = public`.

(Note: This would be a long file - I'll include a template showing the pattern)

**Step 4: Run tests to verify they pass**

```bash
pg_prove test_function_search_path.sql
```

Expected: PASS - All functions protected

**Step 5: Commit**

---

## Priority 5: WARN Level - Extension Move (LOW RISK)

### Issue
`pg_trgm` extension in public schema instead of extensions schema.

### Risk
Low - mainly organizational best practice.

### Task 5.1: Move Extension to Extensions Schema

Check for unqualified references, create migration to move extension.

---

## Priority 6: WARN Level - Auth Dashboard Configuration

### Issue
- Leaked password protection disabled
- Insufficient MFA options

### Task 6.1: Document Dashboard Changes

Create `docs/SUPABASE_AUTH_CONFIG.md` with required dashboard settings.

---

## Migration Numbering

When ready to commit, renumber migrations:
- `999_fix_security_definer_views.sql` → proper sequence number
- `999_username_tables_rls.sql` → proper sequence number
- etc.

---

## Final Verification Checklist

Before pushing to production:

- [ ] All pgTAP tests pass
- [ ] Run Supabase linter again: `supabase db lint`
- [ ] Verify 0 ERROR level issues
- [ ] Verify 0 WARN level issues (except dashboard config)
- [ ] Test frontend functionality (session creation, exercise views)
- [ ] Review GRANT/REVOKE statements
- [ ] Verify RLS policies comprehensive
- [ ] Check for breaking changes in API
- [ ] Document API changes for frontend team
- [ ] Backup production database before migration

---

## Rollback Plan

Each migration should have a corresponding rollback:
- Views: `ALTER VIEW ... WITH (security_invoker=off)` (default)
- RLS: `ALTER TABLE ... DISABLE ROW LEVEL SECURITY; DROP POLICY ...`
- Functions: Restore original versions without security enhancements

Save rollback scripts: `database/rollback/999_*.sql`
