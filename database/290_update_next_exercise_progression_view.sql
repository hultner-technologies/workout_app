-- Migration: Update next_exercise_progression view to use performed_exercise_set table
--
-- This replaces the deprecated performed_exercise.weight/reps fields with
-- aggregations from the performed_exercise_set table.
--
-- Changes:
-- - successful: Now checks minimum reps from performed_exercise_set
-- - weight: Now uses max weight from performed_exercise_set
--
-- Created: 2025-11-21

-- There's a bug in this view. This should only include one value per session,
-- user and exercise.
-- This view isn't used by anything so not critical.
-- The draft exercises version seem to function correctly.
CREATE OR REPLACE VIEW next_exercise_progression
    WITH (security_invoker=on)
    AS (
WITH performed_exercise_base AS (
    SELECT pe.*
         , base_exercise_id
         , app_user_id
         -- Check if progression was successful by comparing minimum reps from sets
         -- with the progression limit
         , (
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
         -- Only include somewhat recent lifts, to not skew recommendations after a
         -- long hiatus.
         AND p.completed_at >= (now() + interval '3 months ago')
)
SELECT
    DISTINCT ON (fe.exercise_id, ps.performed_session_id)
    fe.exercise_id,
    ps.performed_session_id,
    ps.app_user_id,
    fe.name                         AS name,
    array_fill(fe.reps, array[fe.sets]) AS reps,
    array_fill(fe.rest, array[fe.sets]) AS rest,
    -- Calculate recommended weight: previous max weight + step increment if successful
    COALESCE(
        (
            SELECT MAX(pes.weight)
            FROM performed_exercise_set pes
            WHERE pes.performed_exercise_id = pe.performed_exercise_id
        ),
        0
    ) + (CASE WHEN pe.successful THEN fe.step_increment ELSE 0 END) AS weight
FROM performed_session ps
     JOIN full_exercise fe ON ps.session_schedule_id = fe.session_schedule_id
     LEFT JOIN performed_exercise_base pe
               ON fe.base_exercise_id = pe.base_exercise_id
               AND pe.app_user_id = ps.app_user_id
GROUP BY fe.base_exercise_id
       , fe.name
       , fe.exercise_id
       , ps.performed_session_id
       , fe.reps
       , fe.sets
       , fe.rest
       , fe.step_increment
       , pe.successful
       , pe.performed_exercise_id
ORDER BY fe.exercise_id
);

COMMENT ON VIEW next_exercise_progression IS
    'Calculates recommended exercise parameters for the next workout session. '
    'Determines if previous performance met progression criteria and adjusts weight accordingly. '
    'NOTE: This view has a known bug - should only include one value per session/user/exercise. '
    'Not currently used in production. See draft_session_exercises functions for working version. '
    'Updated 2025-11-21 to use performed_exercise_set instead of legacy fields.';
