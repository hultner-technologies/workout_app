-- Migration 079: Add Standard Machine Chest Press
-- Adds the standard machine chest press (both handles on same weight stack)
-- as distinct from Leverage Chest Press (iso-lateral, independent arms)

BEGIN;

-- Update Leverage Chest Press to remove "machine chest press" alias
-- since that will now be a separate exercise
UPDATE base_exercise
SET aliases = ARRAY['iso lateral chest press', 'iso-lateral bench press', 'iso-lateral bench press machine']
WHERE base_exercise_id = '8c025811-7f8a-44a0-9eb6-5f53e4a7c19e'
  AND name = 'Leverage Chest Press';

-- Get the "Unknown" session schedule ID for the new exercise
DO $$
DECLARE
    unknown_session_id uuid;
BEGIN
    SELECT session_schedule_id INTO unknown_session_id
    FROM session_schedule
    WHERE name = 'Unknown'
    LIMIT 1;

-- Add standard Machine Chest Press
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'b2222222-2222-2222-2222-000000000001',
    'Machine Chest Press',
    'beginner',
    'compound',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['chest press machine', 'seated chest press', 'selectorized chest press'],
    'Standard machine chest press with both handles connected to the same weight stack. Sit with back against pad, push handles forward until arms are extended. Different from iso-lateral/leverage press where each arm can move independently with different weights.',
    ARRAY['https://www.endomondo.com/exercise/machine-chest-press', 'https://www.muscleandstrength.com/exercises/machine-chest-press.html']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('b2222222-2222-2222-2222-000000000001', (SELECT muscle_group_id FROM muscle_group WHERE name = 'chest'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('b2222222-2222-2222-2222-000000000001', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('b2222222-2222-2222-2222-000000000001', (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'));

-- Add to Unknown program
INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'b2222222-2222-2222-2222-000000000001', unknown_session_id, 10, 3, '00:02:00');

END $$;

COMMIT;

-- Post-Migration Notes:
-- This migration adds the standard machine chest press as distinct from the leverage/iso-lateral version.
-- Key differences:
-- - Machine Chest Press: Both handles on same weight stack, move together
-- - Leverage Chest Press: Independent handles, each can have different weight, allows unilateral training
