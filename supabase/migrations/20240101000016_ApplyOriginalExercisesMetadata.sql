-- Migration 077: Apply Metadata to Original 45 Exercises
-- This migration copies metadata from imported exercises to the original 45 exercises
-- that were created before the free-exercise-db import.

BEGIN;

-- Enable pg_trgm extension for fuzzy matching
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create a temporary table to store the matches
CREATE TEMP TABLE exercise_matches AS
WITH original_exercises AS (
  SELECT base_exercise_id, name, LOWER(TRIM(name)) as normalized_name
  FROM base_exercise
  WHERE source_name IS NULL
),
imported_exercises AS (
  SELECT base_exercise_id, name, level, mechanic, force, category_id, equipment_type_id, source_name, source_id
  FROM base_exercise
  WHERE source_name IS NOT NULL
),
-- Get the default category_id for 'strength'
default_category AS (
  SELECT category_id FROM exercise_category WHERE name = 'strength' LIMIT 1
),
-- Find best matches using fuzzy matching
fuzzy_matches AS (
  SELECT DISTINCT ON (o.base_exercise_id)
    o.base_exercise_id,
    o.name as original_name,
    i.base_exercise_id as matched_id,
    i.name as matched_name,
    i.level,
    i.mechanic,
    i.force,
    i.category_id,
    i.equipment_type_id,
    SIMILARITY(o.normalized_name, LOWER(TRIM(i.name))) as similarity_score
  FROM original_exercises o
  CROSS JOIN LATERAL (
    SELECT *
    FROM imported_exercises i
    ORDER BY SIMILARITY(o.normalized_name, LOWER(TRIM(i.name))) DESC
    LIMIT 1
  ) i
  ORDER BY o.base_exercise_id, SIMILARITY(o.normalized_name, LOWER(TRIM(i.name))) DESC
)
-- Select matches with manual overrides for better accuracy
SELECT
  fm.base_exercise_id,
  fm.original_name,
  fm.matched_id,
  fm.matched_name,
  fm.similarity_score,
  -- Use matched metadata if similarity > 0.4, otherwise use defaults
  CASE
    WHEN fm.similarity_score >= 0.4 THEN COALESCE(fm.level, 'beginner')
    ELSE 'beginner'
  END as level,
  CASE
    WHEN fm.similarity_score >= 0.4 THEN fm.mechanic
    -- Manual overrides for compound movements
    WHEN fm.original_name IN ('Bench press', 'Squat', 'Deadlift', 'Overhead press', 'Barbell Row',
                               'Incline chest press', 'Lat pulldown', 'Lat pulldown †',
                               'Seated pulley row †', 'Dumbbell shoulder press', 'Shrug',
                               'T-Bar row', 'Dumbbell romanian deadlift', 'Dumbbell romainain deadlift')
    THEN 'compound'
    ELSE 'isolation'
  END as mechanic,
  CASE
    WHEN fm.similarity_score >= 0.4 THEN fm.force
    -- Manual overrides for push exercises
    WHEN fm.original_name IN ('Bench press', 'Dumbbell press', 'Dumbbell incline press',
                               'Dumbbell shoulder press', 'Overhead press', 'Incline chest press',
                               'Overhead tricep extension', 'Julian tricep extension',
                               'Overhead cable tricep extension', 'Front raise', 'Lateral raise',
                               'Machine lateral raise', 'Flat dumbbell press heavy',
                               'Flat dumbbell press backoff', 'High incline smith press',
                               'Squat', 'Dumbbell squat', 'Hack squat heavy', 'Hack squat backoff',
                               'Leg press toe-press', 'Calf raise', 'Dumbbell step up')
    THEN 'push'
    -- Manual overrides for pull exercises
    WHEN fm.original_name IN ('Barbell Row', 'Lat pulldown', 'Lat pulldown †', 'Seated pulley row †',
                               'T-Bar row', 'Deadlift', 'Dumbbell romanian deadlift',
                               'Dumbbell romainain deadlift', 'Bicep curl', 'EZ-bar bicep curl',
                               'Hamstring curl', 'Seated leg curl', 'Cable crunch', 'Pulley crunch',
                               'Floor crunch', 'Machine crunch', 'Hanging leg raise †',
                               'Forearm curl up', 'Forearm curl in', 'Forearm curl back',
                               'Forearm curl up (25 reps)', 'Shrug')
    THEN 'pull'
    ELSE 'static'
  END as force,
  CASE
    WHEN fm.similarity_score >= 0.4 THEN fm.category_id
    ELSE (SELECT category_id FROM default_category)
  END as category_id,
  CASE
    WHEN fm.similarity_score >= 0.4 THEN fm.equipment_type_id
    -- Manual equipment type assignments based on exercise name
    WHEN fm.original_name ILIKE '%barbell%' THEN (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell')
    WHEN fm.original_name ILIKE '%dumbbell%' THEN (SELECT equipment_type_id FROM equipment_type WHERE name = 'dumbbell')
    WHEN fm.original_name ILIKE '%cable%' OR fm.original_name ILIKE '%pulley%' THEN (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable')
    WHEN fm.original_name ILIKE '%machine%' OR fm.original_name ILIKE '%smith%' OR fm.original_name ILIKE '%hack%'
         OR fm.original_name ILIKE '%leg press%' THEN (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine')
    WHEN fm.original_name ILIKE '%ez%bar%' OR fm.original_name ILIKE '%ez-bar%' THEN (SELECT equipment_type_id FROM equipment_type WHERE name = 'e-z curl bar')
    WHEN fm.original_name IN ('Floor crunch', 'Hanging leg raise †') THEN (SELECT equipment_type_id FROM equipment_type WHERE name = 'body only')
    ELSE NULL
  END as equipment_type_id
FROM fuzzy_matches fm, default_category;

-- Show the matches for review
SELECT
  original_name,
  matched_name,
  similarity_score,
  level,
  mechanic,
  force
FROM exercise_matches
ORDER BY original_name;

-- Update the original exercises with metadata
UPDATE base_exercise be
SET
  level = em.level,
  mechanic = em.mechanic,
  force = em.force,
  category_id = em.category_id,
  equipment_type_id = em.equipment_type_id,
  source_name = 'original',
  source_id = be.base_exercise_id::text
FROM exercise_matches em
WHERE be.base_exercise_id = em.base_exercise_id;

-- Copy muscle group relationships for good matches (similarity >= 0.5)
-- Primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT DISTINCT
  em.base_exercise_id,
  bpm.muscle_group_id
FROM exercise_matches em
JOIN base_exercise_primary_muscle bpm ON bpm.base_exercise_id = em.matched_id
WHERE em.similarity_score >= 0.5
ON CONFLICT DO NOTHING;

-- Secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
SELECT DISTINCT
  em.base_exercise_id,
  bsm.muscle_group_id
FROM exercise_matches em
JOIN base_exercise_secondary_muscle bsm ON bsm.base_exercise_id = em.matched_id
WHERE em.similarity_score >= 0.5
ON CONFLICT DO NOTHING;

-- For exercises with low similarity, add common muscle groups manually
-- This ensures all exercises have at least some muscle group data

-- Chest exercises (Bench press variations, Incline press)
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT be.base_exercise_id, mg.muscle_group_id
FROM base_exercise be
CROSS JOIN muscle_group mg
WHERE be.source_name = 'original'
  AND be.name IN ('Bench press', 'Dumbbell press', 'Dumbbell incline press', 'Incline chest press',
                  'Flat dumbbell press heavy', 'Flat dumbbell press backoff', 'High incline smith press')
  AND mg.name = 'chest'
ON CONFLICT DO NOTHING;

-- Back exercises (Rows, Pulldowns, Deadlifts)
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT be.base_exercise_id, mg.muscle_group_id
FROM base_exercise be
CROSS JOIN muscle_group mg
WHERE be.source_name = 'original'
  AND be.name IN ('Barbell Row', 'Lat pulldown', 'Lat pulldown †', 'Seated pulley row †', 'T-Bar row',
                  'Deadlift', 'Dumbbell romanian deadlift', 'Dumbbell romainain deadlift')
  AND mg.name IN ('lats', 'middle back')
ON CONFLICT DO NOTHING;

-- Shoulder exercises
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT be.base_exercise_id, mg.muscle_group_id
FROM base_exercise be
CROSS JOIN muscle_group mg
WHERE be.source_name = 'original'
  AND be.name IN ('Dumbbell shoulder press', 'Overhead press', 'Front raise', 'Lateral raise',
                  'Machine lateral raise', 'Shrug')
  AND mg.name = 'shoulders'
ON CONFLICT DO NOTHING;

-- Leg exercises (Squats, Leg press, Hamstring curls)
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT be.base_exercise_id, mg.muscle_group_id
FROM base_exercise be
CROSS JOIN muscle_group mg
WHERE be.source_name = 'original'
  AND be.name IN ('Squat', 'Dumbbell squat', 'Hack squat heavy', 'Hack squat backoff',
                  'Leg press toe-press', 'Dumbbell step up')
  AND mg.name IN ('quadriceps', 'glutes')
ON CONFLICT DO NOTHING;

-- Hamstring exercises
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT be.base_exercise_id, mg.muscle_group_id
FROM base_exercise be
CROSS JOIN muscle_group mg
WHERE be.source_name = 'original'
  AND be.name IN ('Hamstring curl', 'Seated leg curl', 'Dumbbell romanian deadlift', 'Dumbbell romainain deadlift')
  AND mg.name = 'hamstrings'
ON CONFLICT DO NOTHING;

-- Bicep exercises
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT be.base_exercise_id, mg.muscle_group_id
FROM base_exercise be
CROSS JOIN muscle_group mg
WHERE be.source_name = 'original'
  AND be.name IN ('Bicep curl', 'EZ-bar bicep curl')
  AND mg.name = 'biceps'
ON CONFLICT DO NOTHING;

-- Tricep exercises
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT be.base_exercise_id, mg.muscle_group_id
FROM base_exercise be
CROSS JOIN muscle_group mg
WHERE be.source_name = 'original'
  AND be.name IN ('Overhead tricep extension', 'Julian tricep extension', 'Overhead cable tricep extension')
  AND mg.name = 'triceps'
ON CONFLICT DO NOTHING;

-- Core/Ab exercises
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT be.base_exercise_id, mg.muscle_group_id
FROM base_exercise be
CROSS JOIN muscle_group mg
WHERE be.source_name = 'original'
  AND be.name IN ('Cable crunch', 'Pulley crunch', 'Floor crunch', 'Machine crunch',
                  'Hanging leg raise †', 'Oblique twist')
  AND mg.name = 'abdominals'
ON CONFLICT DO NOTHING;

-- Calf exercises
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT be.base_exercise_id, mg.muscle_group_id
FROM base_exercise be
CROSS JOIN muscle_group mg
WHERE be.source_name = 'original'
  AND be.name IN ('Calf raise', 'Leg press toe-press')
  AND mg.name = 'calves'
ON CONFLICT DO NOTHING;

-- Forearm exercises
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT be.base_exercise_id, mg.muscle_group_id
FROM base_exercise be
CROSS JOIN muscle_group mg
WHERE be.source_name = 'original'
  AND be.name IN ('Forearm curl up', 'Forearm curl in', 'Forearm curl back', 'Forearm curl up (25 reps)')
  AND mg.name = 'forearms'
ON CONFLICT DO NOTHING;

-- Verification: Show statistics
SELECT
  'Exercises with metadata' as category,
  COUNT(*) as count
FROM base_exercise
WHERE source_name IS NOT NULL

UNION ALL

SELECT
  'Exercises without metadata' as category,
  COUNT(*) as count
FROM base_exercise
WHERE source_name IS NULL

UNION ALL

SELECT
  'Total exercises' as category,
  COUNT(*) as count
FROM base_exercise;

-- Verification: Show any exercises still missing metadata
SELECT
  base_exercise_id,
  name,
  level,
  mechanic,
  force,
  category_id,
  equipment_type_id
FROM base_exercise
WHERE source_name IS NULL;

COMMIT;
