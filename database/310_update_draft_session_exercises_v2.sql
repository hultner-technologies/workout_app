-- Migration: Update draft_session_exercises_v2 to use performed_exercise_set table
--
-- This replaces the deprecated performed_exercise.weight/reps fields with
-- aggregations from the performed_exercise_set table in the v2 function.
--
-- Changes:
-- - successful: Now checks minimum reps from performed_exercise_set
-- - weight: Now uses max weight from performed_exercise_set
--
-- Created: 2025-11-21

DROP FUNCTION IF EXISTS draft_session_exercises_v2(uuid);

CREATE OR REPLACE FUNCTION draft_session_exercises_v2(performed_session_id_ uuid)
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
           -- Check if progression was successful by comparing minimum reps from sets
           -- with the progression limit
           (
               SELECT MIN(pes.reps)
               FROM performed_exercise_set pes
               WHERE pes.performed_exercise_id = pe.performed_exercise_id
           ) >= s.progression_limit * e.reps AS successful
    FROM performed_exercise pe
    JOIN exercise e ON pe.exercise_id = e.exercise_id
    JOIN performed_session p ON pe.performed_session_id = p.performed_session_id
    JOIN session_schedule s ON e.session_schedule_id = s.session_schedule_id
    -- Only include exercises that have sets data
    WHERE EXISTS (
        SELECT 1
        FROM performed_exercise_set pes
        WHERE pes.performed_exercise_id = pe.performed_exercise_id
    )
    AND p.completed_at >= (now() + interval '3 months ago')
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
        -- Calculate recommended weight: previous max weight + step increment if successful
        COALESCE(
            (
                SELECT MAX(pes.weight)
                FROM performed_exercise_set pes
                WHERE pes.performed_exercise_id = pe.performed_exercise_id
            ),
            0
        ) + (CASE WHEN pe.successful THEN fe.step_increment ELSE 0 END) as weight
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
        pe.successful,
        pe.performed_exercise_id
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

COMMENT ON FUNCTION draft_session_exercises_v2(uuid) IS
    'Returns session metadata with exercises aggregated into a JSON array. '
    'Always returns exactly 1 row (or 0 if session does not exist). '
    'Empty workouts return exercises: [] with has_exercises: false. '
    'Clean interface: session metadata at top level, exercises nested. '
    'Uses SECURITY INVOKER to respect RLS policies. '
    'Version 2: Supports empty workouts. Use draft_session_exercises() for legacy flat format. '
    'Updated 2025-11-21 to use performed_exercise_set instead of legacy '
    'performed_exercise.weight/reps fields.';
