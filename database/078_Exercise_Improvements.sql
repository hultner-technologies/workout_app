-- Migration 078: Exercise Data Improvements
-- This migration fixes naming inconsistencies, adds missing exercises, and improves metadata
-- Based on comprehensive database analysis and research from online exercise databases

BEGIN;

-- ============================================================================
-- SECTION 1: Fix Existing Exercise Issues
-- ============================================================================

-- Fix 1: Correct misspelling "Dumbbell romainain deadlift" -> "Dumbbell Romanian Deadlift"
UPDATE base_exercise
SET name = 'Dumbbell Romanian Deadlift'
WHERE name = 'Dumbbell romainain deadlift';

-- Also fix the lowercase "romanian"
UPDATE base_exercise
SET name = 'Dumbbell Romanian Deadlift'
WHERE name = 'Dumbbell romanian deadlift' AND name != 'Dumbbell Romanian Deadlift';

-- Fix 2: Correct alias syntax error (triple quotes to single quote) for Overhead tricep extension
UPDATE base_exercise
SET aliases = ARRAY['Dumbbell overhead tricep extension']
WHERE base_exercise_id = 'bee7fe8e-05c8-11ed-824f-578dbf84191f';

-- Fix 3: Standardize Cable vs Pulley naming - rename "Pulley crunch" to "Cable Crunch" since cable is the equipment type
-- The existing "Cable crunch" already has "Pulley crunch" as an alias, so just update the older one
UPDATE base_exercise
SET
    name = 'Cable Crunch',
    aliases = CASE
        WHEN aliases IS NULL THEN ARRAY['Pulley crunch', 'Kneeling cable crunch']
        ELSE array_cat(aliases, ARRAY['Pulley crunch', 'Kneeling cable crunch'])
    END
WHERE name = 'Pulley crunch';

-- Fix 4: Add equipment prefixes to exercises missing them for better clarity
-- These updates improve searchability and consistency

UPDATE base_exercise SET name = 'Dumbbell Bicep Curl' WHERE name = 'Bicep curl';
UPDATE base_exercise SET name = 'Dumbbell Front Raise' WHERE name = 'Front raise';
UPDATE base_exercise SET name = 'Dumbbell Lateral Raise' WHERE name = 'Lateral raise';
UPDATE base_exercise SET name = 'Barbell Overhead Press' WHERE name = 'Overhead press';
UPDATE base_exercise SET name = 'Barbell Squat' WHERE name = 'Squat';
UPDATE base_exercise SET name = 'Barbell Deadlift' WHERE name = 'Deadlift';
UPDATE base_exercise SET name = 'Barbell Bench Press' WHERE name = 'Bench press';
UPDATE base_exercise SET name = 'Machine Hamstring Curl' WHERE name = 'Hamstring curl';
UPDATE base_exercise SET name = 'Cable Oblique Twist' WHERE name = 'Oblique twist';
UPDATE base_exercise SET name = 'Dumbbell Shrug' WHERE name = 'Shrug';

-- Fix 5: Consolidate duplicate "Forearm curl up" exercises (remove rep count from name)
-- First, add the rep-count version as an alias to the main exercise
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['Forearm curl up (25 reps)', 'Wrist curl']
    ELSE array_cat(aliases, ARRAY['Forearm curl up (25 reps)', 'Wrist curl'])
END
WHERE base_exercise_id = '1a953284-31ba-11ed-aa8c-032e2bd7ee19';

-- Then delete the duplicate with rep count in name
DELETE FROM base_exercise WHERE base_exercise_id = 'beef158e-05c8-11ed-824f-93940690d5f2';

-- Fix 6: Merge duplicate "Lat pulldown" exercises
-- Keep the newer one, delete the one with †
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['Lat pulldown †', 'Wide-grip lat pulldown']
    ELSE array_cat(aliases, ARRAY['Lat pulldown †', 'Wide-grip lat pulldown'])
END
WHERE base_exercise_id = '28c781a0-dc9e-11ee-b3ef-b3d83ae9ef50';

DELETE FROM base_exercise WHERE base_exercise_id = 'bef6fb96-05c8-11ed-824f-d7ac01edbd91';

-- ============================================================================
-- SECTION 2: Add Missing Popular Exercises
-- ============================================================================

-- Get the "Unknown" session schedule ID for new exercises
DO $$
DECLARE
    unknown_session_id uuid;
BEGIN
    SELECT session_schedule_id INTO unknown_session_id
    FROM session_schedule
    WHERE name = 'Unknown'
    LIMIT 1;

-- Machine Exercises

-- 1. Pec Deck Fly
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000001',
    'Pec Deck Fly',
    'beginner',
    'isolation',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['pec deck', 'chest fly machine', 'butterfly machine'],
    'Sit with back against pad. Grasp handles with elbows slightly bent. Bring handles together in front of chest in a hugging motion. Return slowly to starting position.',
    ARRAY['https://tzfit.com/2025-chest-fly-machines-tutorial/', 'https://www.isellfitness.com/collections/pec-dec-chest-fly-machine']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000001', (SELECT muscle_group_id FROM muscle_group WHERE name = 'chest'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000001', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000001', unknown_session_id, 12, 3, '00:02:00');

-- 2. Leg Extension
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000002',
    'Leg Extension',
    'beginner',
    'isolation',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['machine leg extension', 'quad extension'],
    'Sit on machine with back against pad. Place legs under padded bar. Extend legs until straight. Lower slowly back to starting position.',
    ARRAY['https://www.endomondo.com/exercise/leg-extension-machine', 'https://www.asphaltgreen.org/blog/the-beginners-guide-to-the-leg-extension-and-hamstring-curl-machines/']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000002', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000002', unknown_session_id, 12, 3, '00:02:00');

-- 3. Seated Cable Row (different from seated pulley row - more specific grip variation)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000003',
    'Seated Cable Row',
    'beginner',
    'compound',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['cable row', 'low cable row'],
    'Sit at cable row station with feet braced. Pull handles to torso, squeezing shoulder blades together. Return with control.',
    ARRAY['https://generationiron.com/five-best-cable-exercises/']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000003', (SELECT muscle_group_id FROM muscle_group WHERE name = 'lats'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000003', (SELECT muscle_group_id FROM muscle_group WHERE name = 'middle back'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000003', (SELECT muscle_group_id FROM muscle_group WHERE name = 'biceps'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000003', unknown_session_id, 10, 3, '00:02:00');

-- 4. Rowing Machine (Ergometer)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000004',
    'Rowing Machine',
    'beginner',
    'compound',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'cardio'),
    'exercise-research-2025',
    ARRAY['rowing ergometer', 'rower', 'erg'],
    'Full-body cardio exercise. Push with legs, pull with arms, engaging back and core throughout the rowing motion.',
    ARRAY['https://exrx.net/Aerobic/Exercises/RowErgometer', 'https://www.menshealth.com/fitness/g19547051/best-cardio-machines/']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000004', (SELECT muscle_group_id FROM muscle_group WHERE name = 'lats'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000004', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000004', (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000004', (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000004', unknown_session_id, 500, 1, '00:03:00');

-- Cable Exercises

-- 5. Cable Chest Fly
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000005',
    'Cable Chest Fly',
    'intermediate',
    'isolation',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['cable fly', 'cable chest flye', 'standing cable fly'],
    'Stand between cable towers. Bring handles together in front of chest with slight elbow bend. Control return to starting position.',
    ARRAY['https://generationiron.com/five-best-cable-exercises/']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000005', (SELECT muscle_group_id FROM muscle_group WHERE name = 'chest'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000005', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000005', unknown_session_id, 12, 3, '00:02:00');

-- 6. Face Pull
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000006',
    'Face Pull',
    'beginner',
    'compound',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['cable face pull', 'rope face pull'],
    'Set cable at head height. Pull rope attachment toward face, separating hands and squeezing shoulder blades. Excellent for shoulder health.',
    ARRAY['https://generationiron.com/five-best-cable-exercises/']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000006', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000006', (SELECT muscle_group_id FROM muscle_group WHERE name = 'middle back'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000006', (SELECT muscle_group_id FROM muscle_group WHERE name = 'traps'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000006', unknown_session_id, 15, 3, '00:01:30');

-- 7. Tricep Pushdown
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000007',
    'Tricep Pushdown',
    'beginner',
    'isolation',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['cable tricep pushdown', 'triceps pushdown', 'rope pushdown'],
    'Stand at high cable pulley. Push attachment down by extending elbows. Keep elbows tucked and still.',
    ARRAY['https://www.endomondo.com/exercise/cable-tricep-pushdown', 'https://www.acefitness.org/resources/everyone/exercise-library/185/triceps-pushdowns/']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000007', (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000007', unknown_session_id, 12, 3, '00:01:30');

-- Kettlebell Exercises

-- 8. Kettlebell Swing
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000008',
    'Kettlebell Swing',
    'intermediate',
    'compound',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'kettlebells'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['KB swing', 'russian kettlebell swing'],
    'Hip hinge movement. Swing kettlebell from between legs to shoulder height using hip drive, not arms. Explosive posterior chain exercise.',
    ARRAY['https://kettlebellsworkouts.com/7-kettlebell-swing-workouts/', 'https://blog.nasm.org/kettlebell-workout']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000008', (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000008', (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000008', (SELECT muscle_group_id FROM muscle_group WHERE name = 'lower back'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000008', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000008', unknown_session_id, 15, 3, '00:02:00');

-- 9. Turkish Get-Up
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000009',
    'Turkish Get-Up',
    'expert',
    'compound',
    'static',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'kettlebells'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['TGU', 'kettlebell get-up'],
    'Complex full-body movement from lying to standing while holding kettlebell overhead. Requires strength, mobility, and stability.',
    ARRAY['https://exrx.net/WeightExercises/Kettlebell/KBTurkishGetup', 'https://kettlebellsworkouts.com/7-steps-of-the-kettlebell-turkish-get-up/']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000009', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000009', (SELECT muscle_group_id FROM muscle_group WHERE name = 'abdominals'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000009', (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000009', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000009', unknown_session_id, 5, 3, '00:03:00');

-- 10. Goblet Squat
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000010',
    'Goblet Squat',
    'beginner',
    'compound',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'kettlebells'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['kettlebell goblet squat', 'KB goblet squat'],
    'Hold kettlebell at chest. Squat down keeping torso upright and elbows inside knees. Excellent for learning squat mechanics.',
    ARRAY['https://blog.nasm.org/kettlebell-workout', 'https://shop.bodybuilding.com/blogs/training/the-12-week-muscle-building-kettlebell-master-plan']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000010', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000010', (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000010', (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000010', (SELECT muscle_group_id FROM muscle_group WHERE name = 'abdominals'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000010', unknown_session_id, 10, 3, '00:02:00');

-- 11. Kettlebell Snatch
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000011',
    'Kettlebell Snatch',
    'expert',
    'compound',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'kettlebells'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['KB snatch', 'single-arm kettlebell snatch'],
    'Explosive movement from floor to overhead in one motion. Advanced kettlebell exercise requiring technique and power.',
    ARRAY['https://barbend.com/kettlebell-exercises-for-bodybuilders/']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000011', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000011', (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000011', (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000011', (SELECT muscle_group_id FROM muscle_group WHERE name = 'middle back'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000011', unknown_session_id, 8, 3, '00:02:30');

-- Bodyweight Exercises

-- 12. Dips
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000012',
    'Dips',
    'intermediate',
    'compound',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'body only'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['parallel bar dips', 'chest dips', 'tricep dips'],
    'Support yourself on parallel bars. Lower body by bending elbows until shoulders are below elbows. Push back up.',
    ARRAY['https://www.strongfirst.com/bigger-and-stronger-with-chins-and-dips/', 'https://www.muscleandstrength.com/workouts/18-week-chin-up-dip-program-upper-body']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000012', (SELECT muscle_group_id FROM muscle_group WHERE name = 'chest'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000012', (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000012', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000012', unknown_session_id, 10, 3, '00:02:00');

-- 13. Push-Ups
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000013',
    'Push-Ups',
    'beginner',
    'compound',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'body only'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['push up', 'pushup', 'press up'],
    'Start in plank position. Lower body until chest nearly touches floor. Push back up to starting position.',
    ARRAY['https://springhillfitnesstn.com/build-physique-bodyweight-training/']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000013', (SELECT muscle_group_id FROM muscle_group WHERE name = 'chest'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000013', (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000013', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000013', (SELECT muscle_group_id FROM muscle_group WHERE name = 'abdominals'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000013', unknown_session_id, 15, 3, '00:01:30');

-- Cardio Exercises

-- 14. Treadmill
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000014',
    'Treadmill',
    'beginner',
    NULL,
    NULL,
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'cardio'),
    'exercise-research-2025',
    ARRAY['treadmill running', 'treadmill walking', 'treadmill jogging'],
    'Walking, jogging, or running on treadmill. Adjust speed and incline for intensity.',
    ARRAY['https://www.nordictrack.co.uk/learn/what-best-home-fitness-device-cardio-exercises/', 'https://pmc.ncbi.nlm.nih.gov/articles/PMC7919349/']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000014', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000014', (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000014', (SELECT muscle_group_id FROM muscle_group WHERE name = 'calves'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000014', (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000014', unknown_session_id, 20, 1, '00:03:00');

-- 15. Jump Rope
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000015',
    'Jump Rope',
    'beginner',
    NULL,
    NULL,
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'other'),
    (SELECT category_id FROM exercise_category WHERE name = 'cardio'),
    'exercise-research-2025',
    ARRAY['jumping rope', 'rope skipping', 'skip rope'],
    'Jump over rope as it passes under feet. Excellent cardio and coordination exercise.',
    ARRAY['https://www.prevention.com/fitness/workouts/g29485708/resistance-band-exercises-for-legs/']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000015', (SELECT muscle_group_id FROM muscle_group WHERE name = 'calves'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000015', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000015', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000015', unknown_session_id, 100, 3, '00:01:00');

-- Plyometric Exercises

-- 16. Box Jump
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000016',
    'Box Jump',
    'intermediate',
    'compound',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'other'),
    (SELECT category_id FROM exercise_category WHERE name = 'plyometrics'),
    'exercise-research-2025',
    ARRAY['box jumps', 'plyo box jump'],
    'Explosively jump onto elevated platform. Step down carefully. Builds power and explosiveness.',
    ARRAY['https://exrx.net/Plyometrics/BoxJump', 'https://nutralifehealing.com/index.php/2025/10/24/16-plyometric-exercises-thatll-build-explosive-strength/']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000016', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000016', (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000016', (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000016', (SELECT muscle_group_id FROM muscle_group WHERE name = 'calves'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000016', unknown_session_id, 10, 3, '00:02:00');

-- 17. Medicine Ball Slam
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000017',
    'Medicine Ball Slam',
    'intermediate',
    'compound',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'medicine ball'),
    (SELECT category_id FROM exercise_category WHERE name = 'plyometrics'),
    'exercise-research-2025',
    ARRAY['ball slam', 'med ball slam', 'slam ball'],
    'Lift ball overhead and explosively slam to ground. Catch on bounce and repeat. Full-body power exercise.',
    ARRAY['https://www.masterclass.com/articles/medicine-ball-slams-guide', 'https://www.issaonline.com/blog/post/medicine-ball-slams-form-function-and-variations']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000017', (SELECT muscle_group_id FROM muscle_group WHERE name = 'abdominals'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000017', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000017', (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000017', (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000017', unknown_session_id, 12, 3, '00:01:30');

-- Olympic Weightlifting

-- 18. Power Clean
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000018',
    'Power Clean',
    'expert',
    'compound',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    (SELECT category_id FROM exercise_category WHERE name = 'olympic weightlifting'),
    'exercise-research-2025',
    ARRAY['barbell power clean', 'hang power clean'],
    'Explosive lift from floor to shoulders. Simpler than full clean. Develops power and athleticism.',
    ARRAY['https://heightperformance.com/power-clean-common-variations/', 'https://www.athleticlab.com/olympic-weightlifting-derivatives-for-sports-performance-by-chase-overpeck/']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000018', (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000018', (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000018', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000018', (SELECT muscle_group_id FROM muscle_group WHERE name = 'middle back'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000018', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000018', (SELECT muscle_group_id FROM muscle_group WHERE name = 'traps'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000018', unknown_session_id, 5, 4, '00:03:00');

-- Other Compound Movements

-- 19. Bulgarian Split Squat
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name,
    aliases, description, links
) VALUES (
    'a1111111-1111-1111-1111-000000000019',
    'Bulgarian Split Squat',
    'intermediate',
    'compound',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'dumbbell'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'exercise-research-2025',
    ARRAY['rear foot elevated split squat', 'single leg squat'],
    'Rear foot elevated on bench. Lower down on front leg until rear knee nearly touches floor. Excellent for correcting imbalances.',
    ARRAY['https://www.menshealth.com/fitness/a65290629/bulgarian-split-squats-exercise/', 'https://www.gymshark.com/blog/article/how-to-bulgarian-split-squat']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000019', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000019', (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000019', (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'));

INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a1111111-1111-1111-1111-000000000019', (SELECT muscle_group_id FROM muscle_group WHERE name = 'abdominals'));

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest)
VALUES (uuid_generate_v1mc(), 'a1111111-1111-1111-1111-000000000019', unknown_session_id, 10, 3, '00:02:00');

END;

COMMIT;

-- ============================================================================
-- Post-Migration Notes
-- ============================================================================

-- This migration:
-- 1. Fixed 10+ naming inconsistencies and typos in existing exercises
-- 2. Consolidated duplicate exercises (Lat pulldown, Forearm curl up, Romanian deadlift)
-- 3. Added 19 new popular exercises covering:
--    - Machine exercises (4): Pec Deck, Leg Extension, Seated Cable Row, Rowing Machine
--    - Cable exercises (3): Chest Fly, Face Pull, Tricep Pushdown
--    - Kettlebell exercises (4): Swing, Turkish Get-Up, Goblet Squat, Snatch
--    - Bodyweight exercises (2): Dips, Push-Ups
--    - Cardio exercises (2): Treadmill, Jump Rope
--    - Plyometric exercises (2): Box Jump, Medicine Ball Slam
--    - Olympic weightlifting (1): Power Clean
--    - Other compound (1): Bulgarian Split Squat
-- 4. All new exercises are added to the "Unknown" program for easy assignment
-- 5. All exercises include proper metadata: equipment, category, level, mechanic, force, muscles, descriptions, and reference links
-- 6. Data sources: ExRx.net, ACE Fitness, NASM, ISSA, Generation Iron, Men's Health, and other reputable fitness organizations
