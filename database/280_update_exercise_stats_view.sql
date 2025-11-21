-- Migration: Update exercise_stats view to use performed_exercise_set table
--
-- This replaces the deprecated performed_exercise.weight/reps fields with
-- aggregations from the performed_exercise_set table.
--
-- Changes:
-- - weight: Now max weight from all sets (previously single weight value)
-- - reps: Now array of reps from all sets (aggregated from set table)
-- - brzycki_1_rm_max: Now calculated from max reps across all sets
-- - volume_kg: Now sum of (weight * reps) for each individual set
--
-- Created: 2025-11-21

CREATE OR REPLACE VIEW exercise_stats
    WITH (security_invoker=on)
    AS
(
SELECT pe.name
     -- Aggregate weight from sets (max weight used in any set)
     , (
         SELECT MAX(pes.weight)
         FROM performed_exercise_set pes
         WHERE pes.performed_exercise_id = pe.performed_exercise_id
       ) as weight
     -- Calculate estimated 1RM using Brzycki formula
     -- Uses the maximum reps achieved in any set for the calculation
     , (
         SELECT ROUND(
             MAX(pes.weight) * (
                 36.0 / (37.0 - (
                     SELECT MAX(pes2.reps)
                     FROM performed_exercise_set pes2
                     WHERE pes2.performed_exercise_id = pe.performed_exercise_id
                 ))
             )
         )
         FROM performed_exercise_set pes
         WHERE pes.performed_exercise_id = pe.performed_exercise_id
       ) as brzycki_1_rm_max
     -- Aggregate reps from sets (array of all reps, ordered by set order)
     , (
         SELECT ARRAY_AGG(pes.reps ORDER BY pes."order")
         FROM performed_exercise_set pes
         WHERE pes.performed_exercise_id = pe.performed_exercise_id
       ) as reps
     -- Calculate total volume in kg (sum of weight * reps for each set)
     , (
         SELECT SUM(pes.weight * pes.reps) / 1000::decimal
         FROM performed_exercise_set pes
         WHERE pes.performed_exercise_id = pe.performed_exercise_id
       ) as volume_kg
     , pe.started_at
     , pe.completed_at
     , pe.completed_at - pe.started_at as exercise_time
     , ss.name as session_name
     , pe.note
     , ps.completed_at - ps.started_at as workout_time
     , date(pe.completed_at) as date
     , e.step_increment
     , e.sort_order
     , ps.performed_session_id
     , ss.session_schedule_id
     , ss.plan_id
     , pe.performed_exercise_id
     , pe.exercise_id
FROM performed_exercise pe
     JOIN performed_session ps ON pe.performed_session_id = ps.performed_session_id
     JOIN session_schedule ss ON ps.session_schedule_id = ss.session_schedule_id
     -- An extra non registered exercise can be included in a session, in
     -- this case the exercise id is likely to be null.
     LEFT JOIN exercise e ON pe.exercise_id = e.exercise_id
     -- Only include exercises that have sets data
     -- (either new data or backfilled legacy data)
WHERE EXISTS (
    SELECT 1
    FROM performed_exercise_set pes
    WHERE pes.performed_exercise_id = pe.performed_exercise_id
)
ORDER BY ss.session_schedule_id, ps.completed_at DESC, e.sort_order
);

COMMENT ON VIEW exercise_stats IS
    'Exercise statistics aggregated from performed_exercise_set table. '
    'Provides weight, reps, 1RM estimates, and volume calculations. '
    'Updated 2025-11-21 to use performed_exercise_set instead of legacy '
    'performed_exercise.weight/reps fields.';
