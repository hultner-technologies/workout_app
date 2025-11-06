-- Comprehensive test for v3 interface
-- Tests draft_session_exercises_v3 function

\echo '========================================'
\echo 'Testing v3 Interface (JSON Aggregation)'
\echo '========================================'
\echo ''

-- =============================================================================
-- Test 1: Empty workout returns single row with empty array
-- =============================================================================

\echo '1. Test empty workout (should return 1 row):'
\echo ''

SELECT
    jsonb_pretty(
        to_jsonb(result)
    ) as empty_workout_response
FROM draft_session_exercises_v3('empty-ps-1111-1111-111111111111'::uuid) as result;

\echo ''
\echo 'Expected:'
\echo '  - Returns exactly 1 row'
\echo '  - has_exercises = false'
\echo '  - exercise_count = 0'
\echo '  - exercises = [] (empty array)'
\echo ''

-- =============================================================================
-- Test 2: Session with exercises returns single row with nested array
-- =============================================================================

\echo '2. Test session with exercises (should return 1 row with nested exercises):'
\echo ''

-- First create test data
DO $$
BEGIN
    -- Create base exercises
    INSERT INTO base_exercise (base_exercise_id, name, description)
    VALUES
        ('b3333333-3333-3333-3333-333333333333'::uuid, 'Bench Press', 'Chest exercise'),
        ('b4444444-4444-4444-4444-444444444444'::uuid, 'Squat', 'Leg exercise'),
        ('b5555555-5555-5555-5555-555555555555'::uuid, 'Deadlift', 'Back exercise')
    ON CONFLICT (base_exercise_id) DO NOTHING;

    -- Create plan
    INSERT INTO plan (plan_id, name, description)
    VALUES ('p3333333-3333-3333-3333-333333333333'::uuid, 'Test Plan V3', 'For testing v3')
    ON CONFLICT (plan_id) DO NOTHING;

    -- Create session schedule
    INSERT INTO session_schedule (session_schedule_id, plan_id, name, description)
    VALUES (
        's3333333-3333-3333-3333-333333333333'::uuid,
        'p3333333-3333-3333-3333-333333333333'::uuid,
        'Test Session V3',
        'Session with 3 exercises'
    )
    ON CONFLICT (session_schedule_id) DO NOTHING;

    -- Add exercises in specific order
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, sort_order, step_increment
    )
    VALUES
        (
            'e3333333-3333-3333-3333-333333333333'::uuid,
            'b3333333-3333-3333-3333-333333333333'::uuid,
            's3333333-3333-3333-3333-333333333333'::uuid,
            10, 5, 1, 2500
        ),
        (
            'e4444444-4444-4444-4444-444444444444'::uuid,
            'b4444444-4444-4444-4444-444444444444'::uuid,
            's3333333-3333-3333-3333-333333333333'::uuid,
            8, 5, 2, 5000
        ),
        (
            'e5555555-5555-5555-5555-555555555555'::uuid,
            'b5555555-5555-5555-5555-555555555555'::uuid,
            's3333333-3333-3333-3333-333333333333'::uuid,
            5, 3, 3, 5000
        )
    ON CONFLICT (exercise_id) DO NOTHING;

    -- Create user
    INSERT INTO app_user (app_user_id, name, email)
    VALUES (
        'u3333333-3333-3333-3333-333333333333'::uuid,
        'Test User V3',
        'testv3@example.com'
    )
    ON CONFLICT (app_user_id) DO NOTHING;

    -- Create performed session
    INSERT INTO performed_session (
        performed_session_id,
        session_schedule_id,
        app_user_id,
        started_at,
        completed_at
    )
    VALUES (
        'p3333333-3333-3333-3333-333333333333'::uuid,
        's3333333-3333-3333-3333-333333333333'::uuid,
        'u3333333-3333-3333-3333-333333333333'::uuid,
        NOW() - interval '1 hour',
        NOW()
    )
    ON CONFLICT (performed_session_id) DO NOTHING;
END $$;

SELECT
    jsonb_pretty(
        to_jsonb(result)
    ) as workout_with_exercises_response
FROM draft_session_exercises_v3('p3333333-3333-3333-3333-333333333333'::uuid) as result;

\echo ''
\echo 'Expected:'
\echo '  - Returns exactly 1 row'
\echo '  - has_exercises = true'
\echo '  - exercise_count = 3'
\echo '  - exercises = array with 3 objects'
\echo '  - exercises ordered by sort_order (1, 2, 3)'
\echo ''

-- =============================================================================
-- Test 3: Non-existent session returns 0 rows
-- =============================================================================

\echo '3. Test non-existent session (should return 0 rows):'
\echo ''

SELECT COUNT(*) as row_count
FROM draft_session_exercises_v3('00000000-0000-0000-0000-000000000000'::uuid);

\echo ''
\echo 'Expected: row_count = 0'
\echo ''

-- =============================================================================
-- Test 4: Compare v2 vs v3 output
-- =============================================================================

\echo '4. Comparison: v2 (multiple rows) vs v3 (single row):'
\echo ''

\echo 'v2 output (3 rows, repeated session info):'
SELECT
    exercise_id,
    name,
    session_name,
    has_exercises
FROM draft_session_exercises_v2('p3333333-3333-3333-3333-333333333333'::uuid)
LIMIT 3;

\echo ''
\echo 'v3 output (1 row, nested exercises):'
SELECT
    session_name,
    has_exercises,
    exercise_count,
    jsonb_array_length(exercises) as exercises_array_length
FROM draft_session_exercises_v3('p3333333-3333-3333-3333-333333333333'::uuid);

\echo ''

-- =============================================================================
-- Test 5: View test - session_schedule_with_exercises
-- =============================================================================

\echo '5. Test session_schedule_with_exercises view:'
\echo ''

SELECT
    name,
    plan_name,
    exercise_count,
    is_empty,
    jsonb_array_length(exercises) as exercises_array_length
FROM session_schedule_with_exercises
WHERE session_schedule_id = 's3333333-3333-3333-3333-333333333333'::uuid;

\echo ''
\echo 'Expected:'
\echo '  - exercise_count = 3'
\echo '  - is_empty = false'
\echo '  - exercises_array_length = 3'
\echo ''

-- =============================================================================
-- Test 6: Verify JSON structure of exercises
-- =============================================================================

\echo '6. Verify JSON structure of exercises array:'
\echo ''

SELECT
    jsonb_pretty(exercises) as exercises_json
FROM draft_session_exercises_v3('p3333333-3333-3333-3333-333333333333'::uuid);

\echo ''
\echo 'Expected: Array with 3 objects, each containing:'
\echo '  - exercise_id (uuid)'
\echo '  - name (text)'
\echo '  - reps (int[])'
\echo '  - rest (interval[])'
\echo '  - weight (int)'
\echo '  - sort_order (int)'
\echo ''

-- =============================================================================
-- Test 7: Test with performed_session_details_v2
-- =============================================================================

\echo '7. Test performed_session_details_v2 (metadata only):'
\echo ''

SELECT
    exists,
    session_name,
    has_exercises,
    exercise_count,
    is_empty
FROM performed_session_details_v2('p3333333-3333-3333-3333-333333333333'::uuid);

\echo ''
\echo 'For empty workout:'
SELECT
    exists,
    session_name,
    has_exercises,
    exercise_count,
    is_empty
FROM performed_session_details_v2('empty-ps-1111-1111-111111111111'::uuid);

\echo ''

-- =============================================================================
-- Test 8: Performance comparison
-- =============================================================================

\echo '8. Performance test (timing):'
\echo ''

\timing on

\echo 'v2 query:'
SELECT COUNT(*) FROM draft_session_exercises_v2('p3333333-3333-3333-3333-333333333333'::uuid);

\echo 'v3 query:'
SELECT COUNT(*) FROM draft_session_exercises_v3('p3333333-3333-3333-3333-333333333333'::uuid);

\timing off

\echo ''

-- =============================================================================
-- Test 9: Test ordering of exercises
-- =============================================================================

\echo '9. Verify exercises are ordered by sort_order:'
\echo ''

SELECT
    jsonb_array_elements(exercises)->>'name' as exercise_name,
    (jsonb_array_elements(exercises)->>'sort_order')::int as sort_order
FROM draft_session_exercises_v3('p3333333-3333-3333-3333-333333333333'::uuid);

\echo ''
\echo 'Expected order: Bench Press (1), Squat (2), Deadlift (3)'
\echo ''

-- =============================================================================
-- Summary
-- =============================================================================

\echo '========================================'
\echo 'V3 Interface Test Summary'
\echo '========================================'
\echo ''
\echo 'Benefits of v3 over v2:'
\echo '  ✅ Always returns 1 row (easier to handle)'
\echo '  ✅ Session metadata at top level (no repetition)'
\echo '  ✅ Exercises as JSON array (no client aggregation)'
\echo '  ✅ Cleaner API responses'
\echo '  ✅ Less data transfer'
\echo '  ✅ Ordered automatically'
\echo ''
\echo 'API changes needed:'
\echo '  - Use draft_session_exercises_v3() instead of v2'
\echo '  - Use .single() in Supabase (always 1 row)'
\echo '  - Access exercises via result.exercises (already an array)'
\echo '  - Check result.has_exercises boolean'
\echo ''
\echo 'Documentation:'
\echo '  - database/queries/RESPONSE_V3.md - Complete v3 docs'
\echo '  - database/270_improved_session_interface.sql - Implementation'
\echo '========================================'
