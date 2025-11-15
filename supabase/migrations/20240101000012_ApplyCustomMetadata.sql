-- ============================================================================
-- Apply Custom Metadata (6 exercises) - FIXED FOR PRODUCTION
-- Generated: 2025-11-04
-- Fixed to use dynamic UUID lookups instead of hardcoded UUIDs
-- ============================================================================
-- These exercises require custom metadata by blending or modifying base matches.
-- Includes equipment overrides and custom adaptations.

BEGIN;

-- ============================================================================
-- 6. Dumbbell romanian deadlift → CUSTOM (Equipment Override: Barbell → Dumbbell)
-- ============================================================================
-- Base: Romanian Deadlift (barbell), override equipment to dumbbell
UPDATE base_exercise
SET
    level = src.level,
    mechanic = src.mechanic,
    force = src.force,
    category_id = src.category_id,
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'dumbbell'),
    instructions = src.instructions,  -- Instructions work for both barbell and dumbbell
    source_name = 'GymR8'
FROM base_exercise src
WHERE base_exercise.base_exercise_id = (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'dumbbell romanian deadlift' AND source_name = 'original')
  AND src.base_exercise_id = (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'romanian deadlift');

-- Copy primary muscles (Hamstrings)
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'dumbbell romanian deadlift' AND source_name = 'original'),
    muscle_group_id
FROM base_exercise_primary_muscle
WHERE base_exercise_id = (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'romanian deadlift')
ON CONFLICT DO NOTHING;

-- Copy secondary muscles (Glutes, Lower Back, Calves)
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
SELECT
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'dumbbell romanian deadlift' AND source_name = 'original'),
    muscle_group_id
FROM base_exercise_secondary_muscle
WHERE base_exercise_id = (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'romanian deadlift')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 17. High incline smith press → CUSTOM (Blend Smith OH Press + Smith Incline)
-- ============================================================================
-- Blend metadata from Smith OH Press and Smith Incline Press
-- Equipment: Machine (Smith), Primary: Chest + Shoulders, Angle: 45-60°
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'compound',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    instructions = ARRAY[
        'Set up an adjustable bench in a Smith machine at a 45-60 degree incline (high incline, between incline press and overhead press).',
        'Position yourself on the bench so that the bar is aligned with your upper chest.',
        'Grasp the bar with a pronated grip (palms facing forward) slightly wider than shoulder width. Unlock the bar and hold it with arms extended. This is your starting position.',
        'Inhale and slowly lower the bar to your upper chest in a controlled manner.',
        'Pause briefly at the bottom, then exhale as you press the bar back up to the starting position, engaging both chest and shoulders.',
        'Lock your arms at the top, pause briefly, then repeat for the prescribed number of repetitions.',
        'When finished, re-rack the bar by rotating your wrists to lock it in place.',
        'Note: This exercise typically supersets with the following exercise in the workout.'
    ],
    source_name = 'GymR8'
WHERE base_exercise_id = (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'high incline smith press' AND source_name = 'original');

-- Primary muscles: Chest
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT
    base_exercise_id,
    (SELECT muscle_group_id FROM muscle_group WHERE name = 'chest'),
    1
FROM base_exercise
WHERE LOWER(TRIM(name)) = 'high incline smith press'
  AND source_name = 'original'
ON CONFLICT DO NOTHING;

-- Secondary muscles: Shoulders, Triceps
DO $$
DECLARE
    v_exercise_id UUID;
BEGIN
    SELECT base_exercise_id INTO v_exercise_id
    FROM base_exercise
    WHERE LOWER(TRIM(name)) = 'high incline smith press'
      AND source_name = 'original';

    IF v_exercise_id IS NOT NULL THEN
        INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
        VALUES
            (v_exercise_id, (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'), 1),
            (v_exercise_id, (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'), 2)
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- ============================================================================
-- 18. Julian tricep extension → CUSTOM (One-arm overhead cable variation)
-- ============================================================================
-- Base: Cable Rope Overhead Triceps Extension, adapted for one arm
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable'),
    instructions = ARRAY[
        'Attach a single handle to the low pulley of a cable machine.',
        'Grasp the handle with one hand and face away from the machine.',
        'Extend your working arm overhead with your hand directly above your head, palm facing forward. Your elbow should be close to your head with the upper arm perpendicular to the floor. This is your starting position.',
        'Slowly lower the handle behind your head by bending at the elbow, keeping your upper arm stationary. Inhale as you perform this movement.',
        'Pause when your tricep is fully stretched at the bottom of the movement.',
        'Return to the starting position by extending your elbow and flexing your tricep. Exhale during this portion.',
        'Complete all repetitions on one side, then switch arms and repeat.',
        'Note: Consider padding your back with a yoga mat for comfort during this exercise.'
    ],
    source_name = 'GymR8'
WHERE base_exercise_id = (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'julian tricep extension' AND source_name = 'original');

-- Primary muscle: Triceps
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT
    base_exercise_id,
    (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps')
FROM base_exercise
WHERE LOWER(TRIM(name)) = 'julian tricep extension'
  AND source_name = 'original'
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 20. Machine lateral raise → CUSTOM (Equipment Override: Dumbbell → Machine)
-- ============================================================================
-- Base: Side Lateral Raise (dumbbell), override equipment to machine
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    instructions = ARRAY[
        'Adjust the seat height of the lateral raise machine so that the pivot point aligns with your shoulders.',
        'Sit down and grasp the handles with a neutral grip (palms facing inward).',
        'Keep your back straight against the pad and your feet flat on the floor. This is your starting position.',
        'Exhale as you raise the handles upward and outward in a wide arc, leading with your elbows.',
        'Continue raising until your arms are parallel to the floor, focusing on using your lateral deltoids.',
        'Pause briefly at the top of the movement, feeling the contraction in your shoulders.',
        'Inhale as you slowly lower the handles back to the starting position in a controlled manner.',
        'Repeat for the recommended number of repetitions.'
    ],
    source_name = 'GymR8'
WHERE base_exercise_id = (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'machine lateral raise' AND source_name = 'original');

-- Primary muscle: Shoulders (lateral deltoid)
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT
    base_exercise_id,
    (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders')
FROM base_exercise
WHERE LOWER(TRIM(name)) = 'machine lateral raise'
  AND source_name = 'original'
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 21. Oblique twist → CUSTOM NAME (Rename + Alias)
-- ============================================================================
-- Base: Cable Russian Twists, rename to "Cable Oblique Twist"
UPDATE base_exercise target
SET
    name = 'Cable Oblique Twist',
    aliases = array_append(COALESCE(target.aliases, ARRAY[]::text[]), 'Cable Russian Twists'),
    level = src.level,
    mechanic = src.mechanic,
    force = src.force,
    category_id = src.category_id,
    equipment_type_id = src.equipment_type_id,
    instructions = src.instructions,
    source_name = 'GymR8'
FROM base_exercise src
WHERE target.base_exercise_id = (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'oblique twist' AND source_name = 'original')
  AND src.base_exercise_id = (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'cable russian twists');

-- Copy primary muscles (Abdominals/Obliques)
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'cable oblique twist'),
    muscle_group_id
FROM base_exercise_primary_muscle
WHERE base_exercise_id = (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'cable russian twists')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 28. T-Bar row → CUSTOM (Equipment Override: Barbell → Machine)
-- ============================================================================
-- Base: Lying T-Bar Row, override to chest-supported machine version
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    instructions = ARRAY[
        'Load the T-Bar Row machine with the desired weight.',
        'Adjust the chest pad height so that your upper chest rests comfortably at the top of the pad when seated or standing.',
        'Position yourself against the chest pad and grasp the handles with your preferred grip (palms down, palms up, or neutral grip depending on your focus).',
        'Extend your arms fully in front of you. This is your starting position.',
        'Exhale as you pull the handles toward your torso, squeezing your shoulder blades together at the top of the movement.',
        'Keep your upper arms close to your torso throughout the movement to maximize back engagement. Do not lift your chest off the pad.',
        'Pause briefly at the peak contraction.',
        'Inhale as you slowly lower the weight back to the starting position with control.',
        'Repeat for the recommended number of repetitions.'
    ],
    source_name = 'GymR8'
WHERE base_exercise_id = (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 't-bar row' AND source_name = 'original');

-- Copy primary muscles (Middle Back)
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
SELECT
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 't-bar row' AND source_name = 'original'),
    muscle_group_id
FROM base_exercise_primary_muscle
WHERE base_exercise_id = (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'lying t-bar row')
ON CONFLICT DO NOTHING;

-- Copy secondary muscles (Lats, Biceps)
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
SELECT
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 't-bar row' AND source_name = 'original'),
    muscle_group_id
FROM base_exercise_secondary_muscle
WHERE base_exercise_id = (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'lying t-bar row')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- Verification: Count exercises with custom metadata
-- ============================================================================
DO $$
DECLARE
    custom_count INTEGER;
    custom_names TEXT[] := ARRAY[
        'dumbbell romanian deadlift',
        'high incline smith press',
        'julian tricep extension',
        'machine lateral raise',
        'cable oblique twist',
        't-bar row'
    ];
BEGIN
    SELECT COUNT(*) INTO custom_count
    FROM base_exercise
    WHERE LOWER(TRIM(name)) = ANY(custom_names)
      AND level IS NOT NULL
      AND source_name = 'GymR8';

    RAISE NOTICE '✓ Applied custom metadata to % exercises', custom_count;

    IF custom_count != 6 THEN
        RAISE WARNING 'Expected 6 custom metadata updates, got %', custom_count;
        RAISE NOTICE 'This may be normal if some exercises do not exist in production';
    END IF;
END $$;

COMMIT;

-- ============================================================================
-- End of custom metadata
-- ============================================================================
