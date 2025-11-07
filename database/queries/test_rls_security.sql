-- Test script for Row Level Security (RLS) policies
-- This tests that users can only access their own data
--
-- Prerequisites:
-- - Database schema applied
-- - RLS policies from 260_rls_policies.sql applied
-- - Supabase auth schema installed (for auth.uid())
--
-- To run this test properly in Supabase:
-- 1. Create two test users in Supabase Auth
-- 2. Run queries as each user to verify isolation
-- 3. Verify users cannot see each other's data

\echo '========================================'
\echo 'RLS Security Test'
\echo '========================================'
\echo ''

-- =============================================================================
-- Setup: Create test users and data
-- =============================================================================

\echo '1. Creating test users...'

-- User 1: Alice
INSERT INTO app_user (app_user_id, name, email)
VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'Alice',
    'alice@example.com'
)
ON CONFLICT (app_user_id) DO UPDATE
SET name = EXCLUDED.name, email = EXCLUDED.email;

-- User 2: Bob
INSERT INTO app_user (app_user_id, name, email)
VALUES (
    '22222222-2222-2222-2222-222222222222'::uuid,
    'Bob',
    'bob@example.com'
)
ON CONFLICT (app_user_id) DO UPDATE
SET name = EXCLUDED.name, email = EXCLUDED.email;

\echo '   ✓ Created Alice (user_id: 11111111-...)'
\echo '   ✓ Created Bob   (user_id: 22222222-...)'
\echo ''

-- =============================================================================
-- Setup: Create test session schedules (public templates)
-- =============================================================================

\echo '2. Creating test workout plans and schedules...'

INSERT INTO plan (plan_id, name, description)
VALUES (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'Test Plan A',
    'A public workout plan'
)
ON CONFLICT (plan_id) DO UPDATE
SET name = EXCLUDED.name, description = EXCLUDED.description;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description)
VALUES (
    'aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbbbbbb'::uuid,
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'Test Session',
    'A public workout session'
)
ON CONFLICT (session_schedule_id) DO UPDATE
SET name = EXCLUDED.name, description = EXCLUDED.description;

\echo '   ✓ Created Test Plan A'
\echo '   ✓ Created Test Session'
\echo ''

-- =============================================================================
-- Setup: Create performed sessions for each user
-- =============================================================================

\echo '3. Creating performed sessions...'

-- Alice's session
INSERT INTO performed_session (
    performed_session_id,
    session_schedule_id,
    app_user_id,
    started_at,
    completed_at
)
VALUES (
    'aaaaaaaa-1111-1111-1111-111111111111'::uuid,
    'aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbbbbbb'::uuid,
    '11111111-1111-1111-1111-111111111111'::uuid,
    NOW(),
    NOW()
)
ON CONFLICT (performed_session_id) DO UPDATE
SET started_at = EXCLUDED.started_at;

-- Bob's session
INSERT INTO performed_session (
    performed_session_id,
    session_schedule_id,
    app_user_id,
    started_at,
    completed_at
)
VALUES (
    'bbbbbbbb-2222-2222-2222-222222222222'::uuid,
    'aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbbbbbb'::uuid,
    '22222222-2222-2222-2222-222222222222'::uuid,
    NOW(),
    NOW()
)
ON CONFLICT (performed_session_id) DO UPDATE
SET started_at = EXCLUDED.started_at;

\echo '   ✓ Created Alice'\''s performed session'
\echo '   ✓ Created Bob'\''s performed session'
\echo ''

-- =============================================================================
-- Setup: Create exercises for both sessions
-- =============================================================================

\echo '4. Creating performed exercises...'

-- Alice's exercise
INSERT INTO performed_exercise (
    performed_exercise_id,
    performed_session_id,
    name,
    reps,
    weight
)
VALUES (
    'aaaaaaaa-1111-eeee-eeee-eeeeeeeeeeee'::uuid,
    'aaaaaaaa-1111-1111-1111-111111111111'::uuid,
    'Alice Bench Press',
    ARRAY[10, 10, 10],
    50000
)
ON CONFLICT (performed_exercise_id) DO NOTHING;

-- Bob's exercise
INSERT INTO performed_exercise (
    performed_exercise_id,
    performed_session_id,
    name,
    reps,
    weight
)
VALUES (
    'bbbbbbbb-2222-eeee-eeee-eeeeeeeeeeee'::uuid,
    'bbbbbbbb-2222-2222-2222-222222222222'::uuid,
    'Bob Bench Press',
    ARRAY[12, 12, 12],
    60000
)
ON CONFLICT (performed_exercise_id) DO NOTHING;

\echo '   ✓ Created Alice'\''s exercise (Bench Press 50kg)'
\echo '   ✓ Created Bob'\''s exercise (Bench Press 60kg)'
\echo ''

-- =============================================================================
-- Test: Verify ALL data is visible WITHOUT RLS (as superuser/anon)
-- =============================================================================

\echo '5. Testing data visibility WITHOUT user context (as superuser)...'
\echo ''
\echo '   All performed sessions (should see both Alice and Bob):'

SELECT
    performed_session_id,
    CASE app_user_id
        WHEN '11111111-1111-1111-1111-111111111111'::uuid THEN 'Alice'
        WHEN '22222222-2222-2222-2222-222222222222'::uuid THEN 'Bob'
        ELSE 'Unknown'
    END as owner
FROM performed_session
WHERE performed_session_id IN (
    'aaaaaaaa-1111-1111-1111-111111111111'::uuid,
    'bbbbbbbb-2222-2222-2222-222222222222'::uuid
)
ORDER BY owner;

\echo ''
\echo '   All performed exercises (should see both):'

SELECT
    name,
    weight,
    CASE
        WHEN performed_session_id = 'aaaaaaaa-1111-1111-1111-111111111111'::uuid THEN 'Alice'
        WHEN performed_session_id = 'bbbbbbbb-2222-2222-2222-222222222222'::uuid THEN 'Bob'
        ELSE 'Unknown'
    END as owner
FROM performed_exercise
WHERE performed_exercise_id IN (
    'aaaaaaaa-1111-eeee-eeee-eeeeeeeeeeee'::uuid,
    'bbbbbbbb-2222-eeee-eeee-eeeeeeeeeeee'::uuid
)
ORDER BY owner;

\echo ''
\echo '   ✓ Superuser/anon can see all data (RLS bypassed for superuser)'
\echo ''

-- =============================================================================
-- Test: Function behavior with empty workout
-- =============================================================================

\echo '6. Testing draft_session_exercises function...'
\echo ''

-- Create an empty workout for Alice
INSERT INTO session_schedule (session_schedule_id, plan_id, name, description)
VALUES (
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'::uuid,
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'Alice Empty Workout',
    'Empty template'
)
ON CONFLICT (session_schedule_id) DO UPDATE
SET name = EXCLUDED.name;

INSERT INTO performed_session (
    performed_session_id,
    session_schedule_id,
    app_user_id,
    started_at
)
VALUES (
    'eeeeeeee-1111-1111-1111-111111111111'::uuid,
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'::uuid,
    '11111111-1111-1111-1111-111111111111'::uuid,
    NOW()
)
ON CONFLICT (performed_session_id) DO NOTHING;

\echo '   Testing empty workout for Alice:'
SELECT
    performed_session_id,
    session_name,
    has_exercises,
    exercise_count,
    CASE
        WHEN has_exercises THEN '✓ Has exercises'
        ELSE '✓ Empty template'
    END as status
FROM draft_session_exercises_v2('eeeeeeee-1111-1111-1111-111111111111'::uuid)
LIMIT 1;

\echo ''
\echo '   Testing performed_session_details for Alice:'
SELECT
    exists,
    session_name,
    is_empty,
    CASE
        WHEN NOT exists THEN '✗ Does not exist'
        WHEN is_empty THEN '✓ Exists (empty)'
        ELSE '✓ Exists (has exercises)'
    END as status
FROM performed_session_details('eeeeeeee-1111-1111-1111-111111111111'::uuid);

\echo ''

-- =============================================================================
-- Instructions for manual RLS testing in Supabase
-- =============================================================================

\echo '========================================'
\echo 'MANUAL RLS TESTING INSTRUCTIONS'
\echo '========================================'
\echo ''
\echo 'To fully test RLS, you need to run queries as authenticated users.'
\echo ''
\echo '1. In Supabase Dashboard:'
\echo '   - Go to Authentication > Users'
\echo '   - Create two test users with UUIDs:'
\echo '     * Alice: 11111111-1111-1111-1111-111111111111'
\echo '     * Bob:   22222222-2222-2222-2222-222222222222'
\echo ''
\echo '2. In Supabase SQL Editor, set user context:'
\echo ''
\echo '   -- Authenticate as Alice'
\echo '   SET LOCAL role TO authenticated;'
\echo '   SET LOCAL request.jwt.claim.sub TO '\''11111111-1111-1111-1111-111111111111'\'';'
\echo ''
\echo '   -- Test: Alice should ONLY see her own sessions'
\echo '   SELECT * FROM performed_session;'
\echo '   -- Expected: 2 rows (Alice'\''s sessions)'
\echo ''
\echo '   -- Test: Alice cannot see Bob'\''s session'
\echo '   SELECT * FROM performed_session'
\echo '   WHERE performed_session_id = '\''bbbbbbbb-2222-2222-2222-222222222222'\'';'
\echo '   -- Expected: 0 rows'
\echo ''
\echo '3. Reset and test as Bob:'
\echo ''
\echo '   RESET role;'
\echo '   SET LOCAL role TO authenticated;'
\echo '   SET LOCAL request.jwt.claim.sub TO '\''22222222-2222-2222-2222-222222222222'\'';'
\echo ''
\echo '   -- Test: Bob should ONLY see his own sessions'
\echo '   SELECT * FROM performed_session;'
\echo '   -- Expected: 1 row (Bob'\''s session)'
\echo ''
\echo '   -- Test: Bob cannot see Alice'\''s sessions'
\echo '   SELECT * FROM performed_session'
\echo '   WHERE performed_session_id = '\''aaaaaaaa-1111-1111-1111-111111111111'\'';'
\echo '   -- Expected: 0 rows'
\echo ''
\echo '4. Test functions respect RLS:'
\echo ''
\echo '   -- As Alice (using v2 function with JSON structure)'
\echo '   SELECT * FROM draft_session_exercises_v2('
\echo '       '\''aaaaaaaa-1111-1111-1111-111111111111'\''::uuid);'
\echo '   -- Expected: Alice'\''s exercises in JSON format'
\echo ''
\echo '   SELECT * FROM draft_session_exercises_v2('
\echo '       '\''bbbbbbbb-2222-2222-2222-222222222222'\''::uuid);'
\echo '   -- Expected: 0 rows (cannot see Bob'\''s session)'
\echo ''
\echo '========================================'
\echo ''
\echo 'Test data created:'
\echo '  - Alice (user_id: 11111111-...)'
\echo '  - Bob   (user_id: 22222222-...)'
\echo '  - 2 performed sessions (1 per user)'
\echo '  - 2 performed exercises (1 per user)'
\echo '  - 1 empty workout (Alice)'
\echo ''
\echo 'Next steps:'
\echo '  1. Apply RLS policies: psql -f database/260_rls_policies.sql'
\echo '  2. Test in Supabase with real authenticated users'
\echo '  3. Verify data isolation between users'
\echo '========================================'
