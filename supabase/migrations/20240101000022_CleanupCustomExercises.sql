-- Migration: 076_CleanupCustomExercises.sql
-- Purpose: Clean up performed_exercises with null exercise_id
-- Generated: 2025-11-04T14:54:01.830214
-- Author: Claude Code Agent

BEGIN;

-- ============================================================================
-- PART 1: Add aliases to existing database exercises
-- ============================================================================

-- Add alias: dumbell bench press
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['dumbell bench press']
    WHEN NOT (aliases @> ARRAY['dumbell bench press']) THEN array_append(aliases, 'dumbell bench press')
    ELSE aliases
END
WHERE base_exercise_id = '02a1a38a-70f9-11ef-bc64-d72b6479cb97';

-- Add alias: cable overhead press
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['cable overhead press']
    WHEN NOT (aliases @> ARRAY['cable overhead press']) THEN array_append(aliases, 'cable overhead press')
    ELSE aliases
END
WHERE base_exercise_id = '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22';

-- Add alias: dumbell overhead press
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['dumbell overhead press']
    WHEN NOT (aliases @> ARRAY['dumbell overhead press']) THEN array_append(aliases, 'dumbell overhead press')
    ELSE aliases
END
WHERE base_exercise_id = '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22';

-- Add alias: kettlebell overhead press
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['kettlebell overhead press']
    WHEN NOT (aliases @> ARRAY['kettlebell overhead press']) THEN array_append(aliases, 'kettlebell overhead press')
    ELSE aliases
END
WHERE base_exercise_id = '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22';

-- Add alias: machine overhead press
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['machine overhead press']
    WHEN NOT (aliases @> ARRAY['machine overhead press']) THEN array_append(aliases, 'machine overhead press')
    ELSE aliases
END
WHERE base_exercise_id = '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22';

-- Add alias: smith squat
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['smith squat']
    WHEN NOT (aliases @> ARRAY['smith squat']) THEN array_append(aliases, 'smith squat')
    ELSE aliases
END
WHERE base_exercise_id = '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1';

-- Add alias: flat bench press backoff
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['flat bench press backoff']
    WHEN NOT (aliases @> ARRAY['flat bench press backoff']) THEN array_append(aliases, 'flat bench press backoff')
    ELSE aliases
END
WHERE base_exercise_id = '2885f762-dc9e-11ee-b3ef-0fa909073fa5';

-- Add alias: lat pulldown machine
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['lat pulldown machine']
    WHEN NOT (aliases @> ARRAY['lat pulldown machine']) THEN array_append(aliases, 'lat pulldown machine')
    ELSE aliases
END
WHERE base_exercise_id = '28c781a0-dc9e-11ee-b3ef-b3d83ae9ef50';

-- Add alias: sandbag step-up
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['sandbag step-up']
    WHEN NOT (aliases @> ARRAY['sandbag step-up']) THEN array_append(aliases, 'sandbag step-up')
    ELSE aliases
END
WHERE base_exercise_id = '28e81f6e-dc9e-11ee-b3ef-5b9f8379af2d';

-- Add alias: high incline smith presss
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['high incline smith presss']
    WHEN NOT (aliases @> ARRAY['high incline smith presss']) THEN array_append(aliases, 'high incline smith presss')
    ELSE aliases
END
WHERE base_exercise_id = '29b44c42-dc9e-11ee-b3ef-53720d6ec33a';

-- Add alias: t-bar row machine
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['t-bar row machine']
    WHEN NOT (aliases @> ARRAY['t-bar row machine']) THEN array_append(aliases, 't-bar row machine')
    ELSE aliases
END
WHERE base_exercise_id = '29d5069e-dc9e-11ee-b3ef-574f7b65abee';

-- Add alias: ez-bar preacher curl
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['ez-bar preacher curl']
    WHEN NOT (aliases @> ARRAY['ez-bar preacher curl']) THEN array_append(aliases, 'ez-bar preacher curl')
    ELSE aliases
END
WHERE base_exercise_id = '2a163cfe-dc9e-11ee-b3ef-575801647e7d';

-- Add alias: cable lateral raise
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['cable lateral raise']
    WHEN NOT (aliases @> ARRAY['cable lateral raise']) THEN array_append(aliases, 'cable lateral raise')
    ELSE aliases
END
WHERE base_exercise_id = 'a3532824-4bc2-11ee-8c75-ebab3389e058';

-- Add alias: dumbbell lateral raise
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['dumbbell lateral raise']
    WHEN NOT (aliases @> ARRAY['dumbbell lateral raise']) THEN array_append(aliases, 'dumbbell lateral raise')
    ELSE aliases
END
WHERE base_exercise_id = 'a3532824-4bc2-11ee-8c75-ebab3389e058';

-- Add alias: cable bicep curl
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['cable bicep curl']
    WHEN NOT (aliases @> ARRAY['cable bicep curl']) THEN array_append(aliases, 'cable bicep curl')
    ELSE aliases
END
WHERE base_exercise_id = 'bee63c0c-05c8-11ed-824f-673da9665bfa';

-- Add alias: machine bicep curl
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['machine bicep curl']
    WHEN NOT (aliases @> ARRAY['machine bicep curl']) THEN array_append(aliases, 'machine bicep curl')
    ELSE aliases
END
WHERE base_exercise_id = 'bee63c0c-05c8-11ed-824f-673da9665bfa';

-- Add alias: dumbbell toe raises
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['dumbbell toe raises']
    WHEN NOT (aliases @> ARRAY['dumbbell toe raises']) THEN array_append(aliases, 'dumbbell toe raises')
    ELSE aliases
END
WHERE base_exercise_id = 'bef283ae-05c8-11ed-824f-870b793b71df';

-- Add alias: smith machine calf raise
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['smith machine calf raise']
    WHEN NOT (aliases @> ARRAY['smith machine calf raise']) THEN array_append(aliases, 'smith machine calf raise')
    ELSE aliases
END
WHERE base_exercise_id = 'bef283ae-05c8-11ed-824f-870b793b71df';

-- Add alias: pulley row
UPDATE base_exercise
SET aliases = CASE
    WHEN aliases IS NULL THEN ARRAY['pulley row']
    WHEN NOT (aliases @> ARRAY['pulley row']) THEN array_append(aliases, 'pulley row')
    ELSE aliases
END
WHERE base_exercise_id = 'bef59bde-05c8-11ed-824f-efb3c762cda1';

-- ============================================================================
-- PART 2: Import exercises from free-exercise-db
-- ============================================================================

-- Pullups (source_id: Pullups)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    'f1cb7f09-b4d1-48db-9da0-e8c05f51c64a',
    'Pullups',
    'beginner',
    'compound',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'body only'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Pullups',
    'free-exercise-db',
    ARRAY['pull up', 'pull-up', 'pullup']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('f1cb7f09-b4d1-48db-9da0-e8c05f51c64a', (SELECT muscle_group_id FROM muscle_group WHERE name = 'lats'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('f1cb7f09-b4d1-48db-9da0-e8c05f51c64a', (SELECT muscle_group_id FROM muscle_group WHERE name = 'biceps'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('f1cb7f09-b4d1-48db-9da0-e8c05f51c64a', (SELECT muscle_group_id FROM muscle_group WHERE name = 'middle back'));

-- Butterfly (source_id: Butterfly)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    'e779d12d-6e7e-4e8f-85f7-7408d0e58d5a',
    'Butterfly',
    'beginner',
    'isolation',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Butterfly',
    'free-exercise-db',
    ARRAY['chest fly machine', 'machine chest fly']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e779d12d-6e7e-4e8f-85f7-7408d0e58d5a', (SELECT muscle_group_id FROM muscle_group WHERE name = 'chest'));

-- Leg Press (source_id: Leg_Press)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    'e9b5e044-2b1e-4c01-9024-fc30a5823661',
    'Leg Press',
    'beginner',
    'compound',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Leg_Press',
    'free-exercise-db',
    ARRAY['cybex leg-press', 'leg press machine']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e9b5e044-2b1e-4c01-9024-fc30a5823661', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e9b5e044-2b1e-4c01-9024-fc30a5823661', (SELECT muscle_group_id FROM muscle_group WHERE name = 'calves'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e9b5e044-2b1e-4c01-9024-fc30a5823661', (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e9b5e044-2b1e-4c01-9024-fc30a5823661', (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'));

-- Leverage Iso Row (source_id: Leverage_Iso_Row)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    '6ebbbb2a-71b0-4fae-8e8e-cdc677ac426a',
    'Leverage Iso Row',
    'beginner',
    'compound',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Leverage_Iso_Row',
    'free-exercise-db',
    ARRAY['machine row']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('6ebbbb2a-71b0-4fae-8e8e-cdc677ac426a', (SELECT muscle_group_id FROM muscle_group WHERE name = 'lats'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('6ebbbb2a-71b0-4fae-8e8e-cdc677ac426a', (SELECT muscle_group_id FROM muscle_group WHERE name = 'biceps'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('6ebbbb2a-71b0-4fae-8e8e-cdc677ac426a', (SELECT muscle_group_id FROM muscle_group WHERE name = 'middle back'));

-- Machine Preacher Curls (source_id: Machine_Preacher_Curls)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    'f064f40c-dd58-41ea-830e-5d99a026c9d2',
    'Machine Preacher Curls',
    'beginner',
    'isolation',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Machine_Preacher_Curls',
    'free-exercise-db',
    ARRAY['bicep preacher curl machine', 'machine preacher curl', 'preacher curl machine']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('f064f40c-dd58-41ea-830e-5d99a026c9d2', (SELECT muscle_group_id FROM muscle_group WHERE name = 'biceps'));

-- Reverse Machine Flyes (source_id: Reverse_Machine_Flyes)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    '37e703b6-a994-4e3f-87f0-7247e50b640b',
    'Reverse Machine Flyes',
    'beginner',
    'isolation',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Reverse_Machine_Flyes',
    'free-exercise-db',
    ARRAY['reverse machine fly']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('37e703b6-a994-4e3f-87f0-7247e50b640b', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

-- Preacher Curl (source_id: Preacher_Curl)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    '444cecdb-1e94-4cbf-99de-3df69eb5ee26',
    'Preacher Curl',
    'beginner',
    'isolation',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Preacher_Curl',
    'free-exercise-db',
    ARRAY['barbell preacher curl']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('444cecdb-1e94-4cbf-99de-3df69eb5ee26', (SELECT muscle_group_id FROM muscle_group WHERE name = 'biceps'));

-- Leverage Chest Press (source_id: Leverage_Chest_Press)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    '8c025811-7f8a-44a0-9eb6-5f53e4a7c19e',
    'Leverage Chest Press',
    'beginner',
    'compound',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Leverage_Chest_Press',
    'free-exercise-db',
    ARRAY['iso lateral chest press', 'iso-lateral bench press', 'iso-lateral bench press machine', 'machine chest press']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('8c025811-7f8a-44a0-9eb6-5f53e4a7c19e', (SELECT muscle_group_id FROM muscle_group WHERE name = 'chest'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('8c025811-7f8a-44a0-9eb6-5f53e4a7c19e', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('8c025811-7f8a-44a0-9eb6-5f53e4a7c19e', (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'));

-- Machine Shoulder (Military) Press (source_id: Machine_Shoulder_Military_Press)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    '997544a4-1a16-43ae-8965-69b0b2f859b4',
    'Machine Shoulder (Military) Press',
    'beginner',
    'compound',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Machine_Shoulder_Military_Press',
    'free-exercise-db',
    ARRAY['machine shoulder press', 'shoulder press machine']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('997544a4-1a16-43ae-8965-69b0b2f859b4', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('997544a4-1a16-43ae-8965-69b0b2f859b4', (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'));

-- Leverage Shoulder Press (source_id: Leverage_Shoulder_Press)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    'e5572004-a750-4977-8549-5e61843e4c5b',
    'Leverage Shoulder Press',
    'beginner',
    'compound',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Leverage_Shoulder_Press',
    'free-exercise-db',
    ARRAY['iso-lateral shoulder press', 'iso-lateral shoulder press machine']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e5572004-a750-4977-8549-5e61843e4c5b', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e5572004-a750-4977-8549-5e61843e4c5b', (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'));

-- Chin-Up (source_id: Chin-Up)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    'e6f90dc6-dcd4-4b99-8c3a-5bc3d2cb2bcd',
    'Chin-Up',
    'beginner',
    'compound',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'body only'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Chin-Up',
    'free-exercise-db',
    ARRAY['chin up']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e6f90dc6-dcd4-4b99-8c3a-5bc3d2cb2bcd', (SELECT muscle_group_id FROM muscle_group WHERE name = 'lats'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e6f90dc6-dcd4-4b99-8c3a-5bc3d2cb2bcd', (SELECT muscle_group_id FROM muscle_group WHERE name = 'biceps'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e6f90dc6-dcd4-4b99-8c3a-5bc3d2cb2bcd', (SELECT muscle_group_id FROM muscle_group WHERE name = 'forearms'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e6f90dc6-dcd4-4b99-8c3a-5bc3d2cb2bcd', (SELECT muscle_group_id FROM muscle_group WHERE name = 'middle back'));

-- Push Press (source_id: Push_Press)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    '3c089a3c-fe52-4e10-a97a-62704da46670',
    'Push Press',
    'expert',
    'compound',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    (SELECT category_id FROM exercise_category WHERE name = 'olympic weightlifting'),
    'Push_Press',
    'free-exercise-db',
    NULL
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('3c089a3c-fe52-4e10-a97a-62704da46670', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('3c089a3c-fe52-4e10-a97a-62704da46670', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('3c089a3c-fe52-4e10-a97a-62704da46670', (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'));

-- Band Assisted Pull-Up (source_id: Band_Assisted_Pull-Up)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    '275a8887-5108-4a3a-83b4-ee81a3f22cd0',
    'Band Assisted Pull-Up',
    'beginner',
    'compound',
    NULL,
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'other'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Band_Assisted_Pull-Up',
    'free-exercise-db',
    ARRAY['assisted pullup']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('275a8887-5108-4a3a-83b4-ee81a3f22cd0', (SELECT muscle_group_id FROM muscle_group WHERE name = 'lats'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('275a8887-5108-4a3a-83b4-ee81a3f22cd0', (SELECT muscle_group_id FROM muscle_group WHERE name = 'abdominals'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('275a8887-5108-4a3a-83b4-ee81a3f22cd0', (SELECT muscle_group_id FROM muscle_group WHERE name = 'forearms'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('275a8887-5108-4a3a-83b4-ee81a3f22cd0', (SELECT muscle_group_id FROM muscle_group WHERE name = 'middle back'));

-- Bodyweight Walking Lunge (source_id: Bodyweight_Walking_Lunge)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    '84a871e1-0c49-4853-9ece-66582cf883f4',
    'Bodyweight Walking Lunge',
    'beginner',
    'compound',
    'push',
    NULL,
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Bodyweight_Walking_Lunge',
    'free-exercise-db',
    ARRAY['body weight lunges']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('84a871e1-0c49-4853-9ece-66582cf883f4', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('84a871e1-0c49-4853-9ece-66582cf883f4', (SELECT muscle_group_id FROM muscle_group WHERE name = 'calves'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('84a871e1-0c49-4853-9ece-66582cf883f4', (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('84a871e1-0c49-4853-9ece-66582cf883f4', (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'));

-- Lying Dumbbell Tricep Extension (source_id: Lying_Dumbbell_Tricep_Extension)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    '0dc0e08e-6c95-4726-a9e2-be722389ddf2',
    'Lying Dumbbell Tricep Extension',
    'intermediate',
    'isolation',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'dumbbell'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Lying_Dumbbell_Tricep_Extension',
    'free-exercise-db',
    ARRAY['dumbbell lying tricep extension']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('0dc0e08e-6c95-4726-a9e2-be722389ddf2', (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('0dc0e08e-6c95-4726-a9e2-be722389ddf2', (SELECT muscle_group_id FROM muscle_group WHERE name = 'chest'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('0dc0e08e-6c95-4726-a9e2-be722389ddf2', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));

-- Lying Close-Grip Barbell Triceps Extension Behind The Head (source_id: Lying_Close-Grip_Barbell_Triceps_Extension_Behind_The_Head)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    '2e9fc3cb-da3c-4542-ba04-ea1e94a3cec5',
    'Lying Close-Grip Barbell Triceps Extension Behind The Head',
    'intermediate',
    'isolation',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Lying_Close-Grip_Barbell_Triceps_Extension_Behind_The_Head',
    'free-exercise-db',
    ARRAY['ez-bar lying tricep extension']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('2e9fc3cb-da3c-4542-ba04-ea1e94a3cec5', (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'));

-- Leg Extensions (source_id: Leg_Extensions)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    'c089902e-6e84-4952-9d1f-c1dfe8c7c63d',
    'Leg Extensions',
    'beginner',
    'isolation',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Leg_Extensions',
    'free-exercise-db',
    ARRAY['seated leg extension']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('c089902e-6e84-4952-9d1f-c1dfe8c7c63d', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));

-- Calf Press On The Leg Press Machine (source_id: Calf_Press_On_The_Leg_Press_Machine)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    '5ebd47d6-b301-49ba-9e7c-5b36a62fb0b1',
    'Calf Press On The Leg Press Machine',
    'beginner',
    'isolation',
    'push',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Calf_Press_On_The_Leg_Press_Machine',
    'free-exercise-db',
    ARRAY['leg press calf-press']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('5ebd47d6-b301-49ba-9e7c-5b36a62fb0b1', (SELECT muscle_group_id FROM muscle_group WHERE name = 'calves'));

-- Split Squats (source_id: Split_Squats)
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_id, source_name, aliases
) VALUES (
    'e5f398e9-3c13-4d95-89bc-909af1f4fe33',
    'Split Squats',
    'intermediate',
    NULL,
    'push',
    NULL,
    (SELECT category_id FROM exercise_category WHERE name = 'stretching'),
    'Split_Squats',
    'free-exercise-db',
    ARRAY['one-legged elevated squat']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e5f398e9-3c13-4d95-89bc-909af1f4fe33', (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e5f398e9-3c13-4d95-89bc-909af1f4fe33', (SELECT muscle_group_id FROM muscle_group WHERE name = 'calves'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e5f398e9-3c13-4d95-89bc-909af1f4fe33', (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('e5f398e9-3c13-4d95-89bc-909af1f4fe33', (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'));

-- ============================================================================
-- PART 3: Create new custom exercises
-- ============================================================================

-- Bayesian bicep curl
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name, aliases
) VALUES (
    'a107a0d7-29d1-490e-9062-efc58a603d6a',
    'Bayesian bicep curl',
    'beginner',
    'isolation',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Custom (User)',
    ARRAY['behind-the-back curl', 'face-away cable curl']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a107a0d7-29d1-490e-9062-efc58a603d6a', (SELECT muscle_group_id FROM muscle_group WHERE name = 'biceps'));

-- Cable reverse fly
INSERT INTO base_exercise (
    base_exercise_id, name, level, mechanic, force,
    equipment_type_id, category_id, source_name, aliases
) VALUES (
    'a892e5df-39fb-4321-b386-6476e30e1d42',
    'Cable reverse fly',
    'beginner',
    'isolation',
    'pull',
    (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable'),
    (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    'Custom (User)',
    ARRAY['reverse chest fly']
);

INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a892e5df-39fb-4321-b386-6476e30e1d42', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('a892e5df-39fb-4321-b386-6476e30e1d42', (SELECT muscle_group_id FROM muscle_group WHERE name = 'middle back'));

-- ============================================================================
-- PART 4: Create exercises in Unknown plan
-- ============================================================================

DO $$
DECLARE
    v_unknown_plan_id uuid;
    v_session_schedule_id uuid;
    v_max_sort_order integer;
BEGIN
    -- Get Unknown plan and its session schedule
    SELECT plan_id INTO v_unknown_plan_id
    FROM plan WHERE name = 'Unknown';

    IF v_unknown_plan_id IS NULL THEN
        RAISE EXCEPTION 'Unknown plan not found';
    END IF;

    SELECT session_schedule_id INTO v_session_schedule_id
    FROM session_schedule
    WHERE plan_id = v_unknown_plan_id
    LIMIT 1;

    -- Create session_schedule if it doesn't exist
    IF v_session_schedule_id IS NULL THEN
        INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit)
        VALUES (uuid_generate_v1mc(), v_unknown_plan_id, 'Default', 'Auto-created for custom exercises', 1.0)
        RETURNING session_schedule_id INTO v_session_schedule_id;
    END IF;

    -- Get max sort order
    SELECT COALESCE(MAX(sort_order), 0) INTO v_max_sort_order
    FROM exercise
    WHERE session_schedule_id = v_session_schedule_id;

    -- Exercise for: Pullups
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        'f1cb7f09-b4d1-48db-9da0-e8c05f51c64a',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 1
    );

    -- Exercise for: Butterfly
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        'e779d12d-6e7e-4e8f-85f7-7408d0e58d5a',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 2
    );

    -- Exercise for: Leg_Press
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        'e9b5e044-2b1e-4c01-9024-fc30a5823661',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 3
    );

    -- Exercise for: Leverage_Iso_Row
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        '6ebbbb2a-71b0-4fae-8e8e-cdc677ac426a',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 4
    );

    -- Exercise for: Machine_Preacher_Curls
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        'f064f40c-dd58-41ea-830e-5d99a026c9d2',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 5
    );

    -- Exercise for: Reverse_Machine_Flyes
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        '37e703b6-a994-4e3f-87f0-7247e50b640b',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 6
    );

    -- Exercise for: Preacher_Curl
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        '444cecdb-1e94-4cbf-99de-3df69eb5ee26',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 7
    );

    -- Exercise for: Leverage_Chest_Press
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        '8c025811-7f8a-44a0-9eb6-5f53e4a7c19e',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 8
    );

    -- Exercise for: Machine_Shoulder_Military_Press
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        '997544a4-1a16-43ae-8965-69b0b2f859b4',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 9
    );

    -- Exercise for: Leverage_Shoulder_Press
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        'e5572004-a750-4977-8549-5e61843e4c5b',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 10
    );

    -- Exercise for: Chin-Up
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        'e6f90dc6-dcd4-4b99-8c3a-5bc3d2cb2bcd',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 11
    );

    -- Exercise for: Push_Press
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        '3c089a3c-fe52-4e10-a97a-62704da46670',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 12
    );

    -- Exercise for: Band_Assisted_Pull-Up
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        '275a8887-5108-4a3a-83b4-ee81a3f22cd0',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 13
    );

    -- Exercise for: Bodyweight_Walking_Lunge
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        '84a871e1-0c49-4853-9ece-66582cf883f4',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 14
    );

    -- Exercise for: Lying_Dumbbell_Tricep_Extension
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        '0dc0e08e-6c95-4726-a9e2-be722389ddf2',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 15
    );

    -- Exercise for: Lying_Close-Grip_Barbell_Triceps_Extension_Behind_The_Head
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        '2e9fc3cb-da3c-4542-ba04-ea1e94a3cec5',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 16
    );

    -- Exercise for: Leg_Extensions
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        'c089902e-6e84-4952-9d1f-c1dfe8c7c63d',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 17
    );

    -- Exercise for: Calf_Press_On_The_Leg_Press_Machine
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        '5ebd47d6-b301-49ba-9e7c-5b36a62fb0b1',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 18
    );

    -- Exercise for: Split_Squats
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        'e5f398e9-3c13-4d95-89bc-909af1f4fe33',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 19
    );

    -- Exercise for: bayesian bicep curl
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        'a107a0d7-29d1-490e-9062-efc58a603d6a',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 20
    );

    -- Exercise for: cable reverse fly
    INSERT INTO exercise (
        exercise_id, base_exercise_id, session_schedule_id,
        reps, sets, rest, sort_order
    ) VALUES (
        uuid_generate_v1mc(),
        'a892e5df-39fb-4321-b386-6476e30e1d42',
        v_session_schedule_id,
        10,  -- default reps
        3,   -- default sets
        '60 seconds'::interval,  -- default rest
        v_max_sort_order + 21
    );

END $$;

-- ============================================================================
-- PART 5: Update performed_exercise records with exercise_id
-- ============================================================================

-- Update performed_exercises to reference exercises (any plan)
UPDATE performed_exercise pe
SET exercise_id = (
    SELECT e.exercise_id
    FROM exercise e
    JOIN base_exercise be ON e.base_exercise_id = be.base_exercise_id
    WHERE (
          -- Match by normalized name
          LOWER(TRIM(pe.name)) = LOWER(TRIM(be.name))
          -- Match by alias
          OR be.aliases @> ARRAY[LOWER(TRIM(pe.name))]
      )
    LIMIT 1
)
WHERE pe.exercise_id IS NULL;

-- ============================================================================
-- PART 6: Verification
-- ============================================================================

DO $$
DECLARE
    v_null_count integer;
    v_updated_count integer;
BEGIN
    SELECT COUNT(*) INTO v_null_count
    FROM performed_exercise
    WHERE exercise_id IS NULL;

    SELECT COUNT(*) INTO v_updated_count
    FROM performed_exercise pe
    JOIN exercise e ON pe.exercise_id = e.exercise_id
    JOIN session_schedule ss ON e.session_schedule_id = ss.session_schedule_id
    JOIN plan p ON ss.plan_id = p.plan_id
    WHERE p.name = 'Unknown';

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Migration Results:';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Performed exercises updated: %', v_updated_count;
    RAISE NOTICE 'Remaining NULL exercise_id: %', v_null_count;

    IF v_null_count > 0 THEN
        RAISE WARNING 'Still have % performed_exercises with null exercise_id!', v_null_count;
    ELSE
        RAISE NOTICE '✓ SUCCESS: All performed_exercises now have exercise_id';
    END IF;
END $$;

COMMIT;

-- Migration complete!
-- Added aliases to 13 existing exercises
-- Imported 19 exercises from free-exercise-db
-- Created 2 new custom exercises
-- Total new exercises in Unknown plan: 21
