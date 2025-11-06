-- Verification tests for the empty workout fix
-- Run this after applying the fix to verify it works correctly

\echo '========================================'
\echo 'Verifying Empty Workout Fix'
\echo '========================================'
\echo ''

-- Test 1: Check session_schedule_metadata view
\echo '1. Test session_schedule_metadata view (shows empty workouts):'
SELECT
    session_schedule_id,
    name,
    plan_name,
    exercise_count,
    is_empty
FROM session_schedule_metadata
WHERE session_schedule_id = 's1111111-1111-1111-1111-111111111111'::uuid;

\echo ''
\echo '   ✓ Expected: 1 row with is_empty = true, exercise_count = 0'
\echo ''

-- Test 2: Check performed_session_exists function
\echo '2. Test performed_session_exists function:'
SELECT *
FROM performed_session_exists('p1111111-1111-1111-1111-111111111111'::uuid);

\echo ''
\echo '   ✓ Expected: 1 row with exists = true, is_empty = true, exercise_count = 0'
\echo ''

-- Test 3: Check draft_session_exercises_v2 function
\echo '3. Test draft_session_exercises_v2 function (new version):'
SELECT
    exercise_id,
    name,
    session_schedule_id,
    session_name,
    has_exercises
FROM draft_session_exercises_v2('p1111111-1111-1111-1111-111111111111'::uuid);

\echo ''
\echo '   ✓ Expected: Returns session info even with no exercises'
\echo '   ✓ If empty: exercise_id and name may be NULL, but session info is present'
\echo ''

-- Test 4: Compare old vs new behavior
\echo '4. Compare old function (returns 0 rows) vs new function:'
\echo ''
\echo '   Old function result:'
SELECT COUNT(*) as row_count, 'draft_session_exercises (old)' as function_name
FROM draft_session_exercises('p1111111-1111-1111-1111-111111111111'::uuid);

\echo ''
\echo '   New function result:'
SELECT COUNT(*) as row_count, 'draft_session_exercises_v2 (new)' as function_name
FROM draft_session_exercises_v2('p1111111-1111-1111-1111-111111111111'::uuid);

\echo ''
\echo '   ✓ Old function returns 0 rows (ambiguous)'
\echo '   ✓ New function returns at least session metadata (clear indication)'
\echo ''

-- Test 5: Test with a non-existent session
\echo '5. Test with non-existent session (should return 0 rows):'
SELECT *
FROM performed_session_exists('00000000-0000-0000-0000-000000000000'::uuid);

\echo ''
\echo '   ✓ Expected: 0 rows (truly non-existent)'
\echo ''

-- Test 6: Create a session with exercises for comparison
\echo '6. Create a test session WITH exercises for comparison:'

-- Insert a base exercise
INSERT INTO base_exercise (base_exercise_id, name, description)
VALUES (
    'b2222222-2222-2222-2222-222222222222'::uuid,
    'Test Exercise',
    'A test exercise for comparison'
)
ON CONFLICT (base_exercise_id) DO NOTHING;

-- Create a plan with exercises
INSERT INTO plan (plan_id, name, description)
VALUES (
    'e2222222-2222-2222-2222-222222222222'::uuid,
    'Test Plan with Exercises',
    'A plan with exercises for comparison'
)
ON CONFLICT (plan_id) DO NOTHING;

-- Create session schedule
INSERT INTO session_schedule (
    session_schedule_id,
    plan_id,
    name,
    description,
    progression_limit
)
VALUES (
    's2222222-2222-2222-2222-222222222222'::uuid,
    'e2222222-2222-2222-2222-222222222222'::uuid,
    'Test Session with Exercise',
    'Session with one exercise',
    0.8
)
ON CONFLICT (session_schedule_id) DO NOTHING;

-- Add an exercise
INSERT INTO exercise (
    exercise_id,
    base_exercise_id,
    session_schedule_id,
    reps,
    sets,
    sort_order
)
VALUES (
    'x2222222-2222-2222-2222-222222222222'::uuid,
    'b2222222-2222-2222-2222-222222222222'::uuid,
    's2222222-2222-2222-2222-222222222222'::uuid,
    10,
    3,
    1
)
ON CONFLICT (exercise_id) DO NOTHING;

-- Create performed session
INSERT INTO performed_session (
    performed_session_id,
    session_schedule_id,
    app_user_id,
    started_at
)
VALUES (
    'p2222222-2222-2222-2222-222222222222'::uuid,
    's2222222-2222-2222-2222-222222222222'::uuid,
    'u1111111-1111-1111-1111-111111111111'::uuid,
    NOW()
)
ON CONFLICT (performed_session_id) DO NOTHING;

SELECT 'Created test session with exercises' as status;

\echo ''
\echo 'Compare empty vs non-empty sessions:'
SELECT
    session_schedule_id,
    name,
    exercise_count,
    is_empty,
    CASE
        WHEN is_empty THEN '❌ Empty (0 exercises)'
        ELSE '✓ Has exercises'
    END as status
FROM session_schedule_metadata
WHERE session_schedule_id IN (
    's1111111-1111-1111-1111-111111111111'::uuid,
    's2222222-2222-2222-2222-222222222222'::uuid
)
ORDER BY is_empty DESC;

\echo ''
\echo '========================================'
\echo 'SUMMARY OF FIX:'
\echo '========================================'
\echo 'The fix provides three solutions:'
\echo ''
\echo '1. session_schedule_metadata view:'
\echo '   - Shows ALL session schedules with exercise counts'
\echo '   - Includes is_empty flag'
\echo '   - Always returns a row for existing sessions'
\echo ''
\echo '2. draft_session_exercises_v2 function:'
\echo '   - Enhanced version of draft_session_exercises'
\echo '   - Returns session metadata even for empty workouts'
\echo '   - Includes has_exercises flag'
\echo ''
\echo '3. performed_session_exists function:'
\echo '   - Simple check if a performed session exists'
\echo '   - Returns exercise count and is_empty flag'
\echo '   - Returns 0 rows only if session truly does not exist'
\echo ''
\echo 'Use these to distinguish between:'
\echo '  a) Session does not exist (0 rows)'
\echo '  b) Session exists but has no exercises (1 row, is_empty=true)'
\echo '========================================'
