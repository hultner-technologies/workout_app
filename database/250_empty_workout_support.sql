-- Support for empty workout templates
--
-- Problem: Session schedules without exercises return 0 rows from views/functions,
-- making it impossible to distinguish between "session doesn't exist" and
-- "session exists but has no exercises".
--
-- Solution: Return session metadata with exercises aggregated in JSON array.
-- Always returns 1 row (or 0 if doesn't exist), with empty array for empty workouts.
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


-- Function: draft_session_exercises
-- Returns session metadata with exercises aggregated into a JSON array
DROP FUNCTION IF EXISTS draft_session_exercises_v2(uuid);
DROP FUNCTION IF EXISTS draft_session_exercises_v3(uuid);

CREATE OR REPLACE FUNCTION draft_session_exercises(performed_session_id_ uuid)
    RETURNS TABLE (
        performed_session_id uuid,
        session_schedule_id uuid,
        session_name text,
        app_user_id uuid,
        started_at timestamp,
        completed_at timestamp,
        has_exercises boolean,
        exercise_count integer,
        exercises jsonb
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
        ps.started_at,
        ps.completed_at,
        ss.name as session_name,
        EXISTS(
            SELECT 1 FROM exercise e
            WHERE e.session_schedule_id = ps.session_schedule_id
        ) as has_exercises
    FROM performed_session ps
    JOIN session_schedule ss ON ps.session_schedule_id = ss.session_schedule_id
    WHERE ps.performed_session_id = performed_session_id_
),
exercise_data AS (
    SELECT
        DISTINCT ON (fe.exercise_id)
        si.performed_session_id,
        fe.exercise_id,
        fe.name,
        fe.sort_order,
        array_fill(fe.reps, array[fe.sets]) as reps,
        array_fill(fe.rest, array[fe.sets]) as rest,
        COALESCE(max(pe.weight), 0)
            + (CASE WHEN pe.successful THEN fe.step_increment ELSE 0 END) as weight
    FROM session_info si
    LEFT JOIN full_exercise fe ON si.session_schedule_id = fe.session_schedule_id
    LEFT JOIN performed_exercise_base pe
        ON fe.base_exercise_id = pe.base_exercise_id
        AND pe.app_user_id = si.app_user_id
        AND successful IS TRUE
    WHERE si.performed_session_id = performed_session_id_
        AND fe.exercise_id IS NOT NULL
    GROUP BY
        fe.base_exercise_id,
        fe.name,
        fe.exercise_id,
        fe.sort_order,
        si.performed_session_id,
        fe.reps,
        fe.sets,
        fe.rest,
        fe.step_increment,
        pe.successful
    ORDER BY fe.exercise_id, fe.sort_order
)
SELECT
    si.performed_session_id,
    si.session_schedule_id,
    si.session_name,
    si.app_user_id,
    si.started_at,
    si.completed_at,
    si.has_exercises,
    COALESCE(COUNT(ed.exercise_id), 0)::integer as exercise_count,
    COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'exercise_id', ed.exercise_id,
                'name', ed.name,
                'reps', ed.reps,
                'rest', ed.rest,
                'weight', ed.weight,
                'sort_order', ed.sort_order
            )
            ORDER BY ed.sort_order, ed.name
        ) FILTER (WHERE ed.exercise_id IS NOT NULL),
        '[]'::jsonb
    ) as exercises
FROM session_info si
LEFT JOIN exercise_data ed ON si.performed_session_id = ed.performed_session_id
GROUP BY
    si.performed_session_id,
    si.session_schedule_id,
    si.session_name,
    si.app_user_id,
    si.started_at,
    si.completed_at,
    si.has_exercises;
$$
LANGUAGE SQL;

COMMENT ON FUNCTION draft_session_exercises(uuid) IS
    'Returns session metadata with exercises aggregated into a JSON array. '
    'Always returns exactly 1 row (or 0 if session does not exist). '
    'Empty workouts return exercises: [] with has_exercises: false. '
    'Clean interface: session metadata at top level, exercises nested. '
    'Uses SECURITY INVOKER to respect RLS policies.';


-- Function: performed_session_details
-- Check if a performed session exists and get its metadata
DROP FUNCTION IF EXISTS performed_session_exists(uuid);
DROP FUNCTION IF EXISTS performed_session_details_v2(uuid);

CREATE OR REPLACE FUNCTION performed_session_details(performed_session_id_ uuid)
    RETURNS TABLE (
        "exists" boolean,
        performed_session_id uuid,
        session_schedule_id uuid,
        session_name text,
        app_user_id uuid,
        started_at timestamp,
        completed_at timestamp,
        has_exercises boolean,
        exercise_count integer,
        is_empty boolean
    )
    SECURITY INVOKER
    SET search_path = 'public'
AS $$
    SELECT
        true as "exists",
        ps.performed_session_id,
        ps.session_schedule_id,
        ss.name as session_name,
        ps.app_user_id,
        ps.started_at,
        ps.completed_at,
        COUNT(e.exercise_id) > 0 as has_exercises,
        COUNT(e.exercise_id)::integer as exercise_count,
        COUNT(e.exercise_id) = 0 as is_empty
    FROM performed_session ps
    JOIN session_schedule ss ON ps.session_schedule_id = ss.session_schedule_id
    LEFT JOIN exercise e ON ss.session_schedule_id = e.session_schedule_id
    WHERE ps.performed_session_id = performed_session_id_
    GROUP BY
        ps.performed_session_id,
        ps.session_schedule_id,
        ss.name,
        ps.app_user_id,
        ps.started_at,
        ps.completed_at;
$$
LANGUAGE SQL;

COMMENT ON FUNCTION performed_session_details(uuid) IS
    'Check if a performed session exists and get its metadata. '
    'Returns 0 rows if session does not exist, 1 row with details if it exists. '
    'Includes has_exercises, exercise_count, and is_empty flags. '
    'Uses SECURITY INVOKER to respect RLS policies.';


-- View: session_schedule_with_exercises
-- Shows session schedules with aggregated exercise information
DROP VIEW IF EXISTS session_schedule_with_exercises;

CREATE OR REPLACE VIEW session_schedule_with_exercises
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
    COALESCE(COUNT(e.exercise_id), 0)::integer as exercise_count,
    COUNT(e.exercise_id) = 0 as is_empty,
    COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'exercise_id', e.exercise_id,
                'name', be.name,
                'reps', e.reps,
                'sets', e.sets,
                'rest', e.rest,
                'step_increment', e.step_increment,
                'sort_order', e.sort_order,
                'description', COALESCE(e.description, be.description),
                'links', COALESCE(e.links, be.links)
            )
            ORDER BY e.sort_order, be.name
        ) FILTER (WHERE e.exercise_id IS NOT NULL),
        '[]'::jsonb
    ) as exercises
FROM session_schedule ss
JOIN plan p ON ss.plan_id = p.plan_id
LEFT JOIN exercise e ON ss.session_schedule_id = e.session_schedule_id
LEFT JOIN base_exercise be ON e.base_exercise_id = be.base_exercise_id
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

COMMENT ON VIEW session_schedule_with_exercises IS
    'Session schedules with exercises aggregated into a JSON array. '
    'Clean interface for fetching templates: single row per schedule with nested exercises. '
    'Uses security_invoker=on to respect RLS policies.';
