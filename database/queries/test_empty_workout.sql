-- Test script to demonstrate the issue with empty workouts
-- Run this after setting up the database schema and inserting the empty workout

\echo '========================================'
\echo 'Testing Empty Workout Behavior'
\echo '========================================'
\echo ''

-- First, verify the plan and session_schedule exist
\echo '1. Verify Plan exists:'
SELECT plan_id, name, description
FROM plan
WHERE plan_id = 'e1111111-1111-1111-1111-111111111111'::uuid;

\echo ''
\echo '2. Verify Session Schedule exists:'
SELECT session_schedule_id, plan_id, name, description
FROM session_schedule
WHERE session_schedule_id = 's1111111-1111-1111-1111-111111111111'::uuid;

\echo ''
\echo '3. Check if any exercises exist for this session (should be 0):'
SELECT COUNT(*) as exercise_count
FROM exercise
WHERE session_schedule_id = 's1111111-1111-1111-1111-111111111111'::uuid;

\echo ''
\echo '4. Query full_exercise view for empty workout:'
\echo '   ISSUE: This returns 0 rows instead of showing the session exists'
SELECT *
FROM full_exercise
WHERE session_schedule_id = 's1111111-1111-1111-1111-111111111111'::uuid;

\echo ''
\echo '5. Create a test user and performed_session for the empty workout:'
-- Insert a test user
INSERT INTO app_user (app_user_id, name)
VALUES ('u1111111-1111-1111-1111-111111111111'::uuid, 'Test User')
ON CONFLICT (app_user_id) DO NOTHING;

-- Create a performed_session for the empty workout
INSERT INTO performed_session (
    performed_session_id,
    session_schedule_id,
    app_user_id,
    started_at
)
VALUES (
    'p1111111-1111-1111-1111-111111111111'::uuid,
    's1111111-1111-1111-1111-111111111111'::uuid,
    'u1111111-1111-1111-1111-111111111111'::uuid,
    NOW()
)
ON CONFLICT (performed_session_id) DO NOTHING;

SELECT 'Created test performed_session' as status;

\echo ''
\echo '6. Call draft_session_exercises function:'
\echo '   ISSUE: This returns 0 rows for an empty workout!'
\echo '   Expected: Should return an empty result set with proper metadata'
\echo '            OR indicate the session exists but has no exercises'
SELECT *
FROM draft_session_exercises('p1111111-1111-1111-1111-111111111111'::uuid);

\echo ''
\echo '7. Check performed_session exists in database:'
SELECT
    ps.performed_session_id,
    ps.session_schedule_id,
    ss.name as session_name,
    ps.app_user_id,
    ps.started_at
FROM performed_session ps
JOIN session_schedule ss ON ps.session_schedule_id = ss.session_schedule_id
WHERE ps.performed_session_id = 'p1111111-1111-1111-1111-111111111111'::uuid;

\echo ''
\echo '========================================'
\echo 'SUMMARY OF ISSUES:'
\echo '========================================'
\echo 'When a session_schedule has no exercises:'
\echo '  - full_exercise view returns 0 rows'
\echo '  - draft_session_exercises() returns 0 rows'
\echo '  - API consumers cannot distinguish between:'
\echo '    a) Session does not exist'
\echo '    b) Session exists but has no exercises'
\echo ''
\echo 'This makes empty workout templates unusable!'
\echo '========================================'
