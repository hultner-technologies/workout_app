-- Fix for empty workout issue
-- The problem: Views and functions use INNER JOINs with the exercise table,
-- causing them to return 0 rows for session_schedules with no exercises.
-- This makes it impossible to distinguish between:
--   a) Session doesn't exist
--   b) Session exists but has no exercises

-- Solution 1: Create a helper view for session schedule metadata
-- This view shows all session schedules with their exercise counts
CREATE OR REPLACE VIEW session_schedule_metadata
    WITH (security_invoker=on)
    AS
SELECT
    ss.session_schedule_id,
    ss.plan_id,
    ss.name,
    ss.description,
    ss.progression_limit,
    ss.links,
    ss.data,
    p.name as plan_name,
    p.description as plan_description,
    COALESCE(COUNT(e.exercise_id), 0) as exercise_count,
    CASE
        WHEN COUNT(e.exercise_id) = 0 THEN true
        ELSE false
    END as is_empty
FROM session_schedule ss
JOIN plan p ON ss.plan_id = p.plan_id
LEFT JOIN exercise e ON ss.session_schedule_id = e.session_schedule_id
GROUP BY
    ss.session_schedule_id,
    ss.plan_id,
    ss.name,
    ss.description,
    ss.progression_limit,
    ss.links,
    ss.data,
    p.name,
    p.description;

COMMENT ON VIEW session_schedule_metadata IS
    'Provides session schedule information including exercise counts. '
    'Use this to check if a session exists and whether it has exercises. '
    'Useful for handling empty workout templates.';


-- Solution 2: Create an improved draft_session_exercises function
-- This version returns session information even when there are no exercises
DROP FUNCTION IF EXISTS draft_session_exercises_v2(uuid);

CREATE OR REPLACE FUNCTION draft_session_exercises_v2(performed_session_id_ uuid)
    RETURNS TABLE (
        exercise_id uuid,
        performed_session_id uuid,
        name text,
        reps int[],
        rest interval[],
        weight int,
        session_schedule_id uuid,
        session_name text,
        has_exercises boolean
    )
    SET search_path = 'public'
AS $$
WITH performed_exercise_base AS (
    SELECT pe.*,
           base_exercise_id,
           app_user_id,
           (SELECT min(r) FROM unnest(pe.reps) r)
               >= s.progression_limit * e.reps
           AS successful
    FROM performed_exercise pe
    JOIN exercise e ON pe.exercise_id = e.exercise_id
    JOIN performed_session p ON pe.performed_session_id = p.performed_session_id
    JOIN session_schedule s ON e.session_schedule_id = s.session_schedule_id
    WHERE p.completed_at >= (now() + interval '3 months ago')
),
session_info AS (
    SELECT
        ps.performed_session_id,
        ps.session_schedule_id,
        ps.app_user_id,
        ss.name as session_name,
        EXISTS(
            SELECT 1 FROM exercise e
            WHERE e.session_schedule_id = ps.session_schedule_id
        ) as has_exercises
    FROM performed_session ps
    JOIN session_schedule ss ON ps.session_schedule_id = ss.session_schedule_id
    WHERE ps.performed_session_id = performed_session_id_
)
SELECT
    DISTINCT ON (fe.exercise_id)
    fe.exercise_id,
    si.performed_session_id,
    fe.name,
    array_fill(fe.reps, array[fe.sets]) as reps,
    array_fill(fe.rest, array[fe.sets]) as rest,
    COALESCE(max(pe.weight), 0)
        + (CASE WHEN pe.successful THEN fe.step_increment ELSE 0 END) as weight,
    si.session_schedule_id,
    si.session_name,
    si.has_exercises
FROM session_info si
LEFT JOIN full_exercise fe ON si.session_schedule_id = fe.session_schedule_id
LEFT JOIN performed_exercise_base pe
    ON fe.base_exercise_id = pe.base_exercise_id
    AND pe.app_user_id = si.app_user_id
    AND successful IS TRUE
WHERE si.performed_session_id = performed_session_id_
GROUP BY
    fe.base_exercise_id,
    fe.name,
    fe.exercise_id,
    si.performed_session_id,
    fe.reps,
    fe.sets,
    fe.rest,
    fe.step_increment,
    pe.successful,
    si.session_schedule_id,
    si.session_name,
    si.has_exercises
ORDER BY fe.exercise_id;
$$
LANGUAGE SQL;

COMMENT ON FUNCTION draft_session_exercises_v2(uuid) IS
    'Improved version that returns session info even for empty workouts. '
    'Returns exercise data if available, but always includes session metadata. '
    'Check the has_exercises field to determine if the session has any exercises.';


-- Solution 3: Create a simple helper function to check if a session exists
CREATE OR REPLACE FUNCTION performed_session_exists(performed_session_id_ uuid)
    RETURNS TABLE (
        exists boolean,
        performed_session_id uuid,
        session_schedule_id uuid,
        session_name text,
        app_user_id uuid,
        exercise_count bigint,
        is_empty boolean
    )
    SET search_path = 'public'
AS $$
    SELECT
        true as exists,
        ps.performed_session_id,
        ps.session_schedule_id,
        ss.name as session_name,
        ps.app_user_id,
        COUNT(e.exercise_id) as exercise_count,
        COUNT(e.exercise_id) = 0 as is_empty
    FROM performed_session ps
    JOIN session_schedule ss ON ps.session_schedule_id = ss.session_schedule_id
    LEFT JOIN exercise e ON ss.session_schedule_id = e.session_schedule_id
    WHERE ps.performed_session_id = performed_session_id_
    GROUP BY
        ps.performed_session_id,
        ps.session_schedule_id,
        ss.name,
        ps.app_user_id;
$$
LANGUAGE SQL;

COMMENT ON FUNCTION performed_session_exists(uuid) IS
    'Check if a performed session exists and get its metadata, including whether it has exercises. '
    'Useful for distinguishing between non-existent sessions and empty workout templates.';
