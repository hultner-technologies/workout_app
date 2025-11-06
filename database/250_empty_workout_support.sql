-- Support for empty workout templates
--
-- Problem: Session schedules without exercises return 0 rows from views/functions,
-- making it impossible to distinguish between "session doesn't exist" and
-- "session exists but has no exercises".
--
-- Solution: Provide views and functions that use LEFT JOINs to handle empty workouts.
--
-- Created: 2025-11-06
-- Author: Claude (Anthropic)

-- View: session_schedule_metadata
-- Shows all session schedules with their exercise counts
-- Always returns a row for existing sessions, even if empty
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


-- Function: draft_session_exercises_v2
-- Enhanced version that returns session information even when there are no exercises
-- Returns session metadata along with exercise data (if any)
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
    SECURITY INVOKER
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
    'Improved version of draft_session_exercises that returns session info even for empty workouts. '
    'Returns exercise data if available, but always includes session metadata. '
    'Check the has_exercises field to determine if the session has any exercises.';


-- Function: performed_session_exists
-- Simple check to verify if a performed session exists and get its metadata
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
    SECURITY INVOKER
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
    'Useful for distinguishing between non-existent sessions and empty workout templates. '
    'Returns 0 rows if session does not exist, 1 row if it exists (check is_empty flag).';
