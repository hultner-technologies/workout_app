-- ============================================================================
-- Apply Direct Metadata Copies (18 exercises) - FIXED FOR PRODUCTION
-- Generated: 2025-11-04
-- Fixed to use dynamic UUID lookups instead of hardcoded UUIDs
-- ============================================================================
-- These exercises copy metadata directly from matched imported exercises.
-- No equipment overrides or custom modifications needed.

BEGIN;

-- Helper function to copy metadata for one exercise
CREATE OR REPLACE FUNCTION copy_base_exercise_metadata(
    p_target_id uuid,
    p_source_id uuid
) RETURNS void AS $$
BEGIN
    -- Copy base metadata
    UPDATE base_exercise target
    SET
        level = src.level,
        mechanic = src.mechanic,
        force = src.force,
        category_id = src.category_id,
        equipment_type_id = src.equipment_type_id,
        instructions = src.instructions,
        source_name = src.source_name,
        source_id = src.source_id
    FROM base_exercise src
    WHERE target.base_exercise_id = p_target_id
      AND src.base_exercise_id = p_source_id;

    -- Copy primary muscles
    INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
    SELECT p_target_id, muscle_group_id, sort_order
    FROM base_exercise_primary_muscle
    WHERE base_exercise_id = p_source_id
    ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

    -- Copy secondary muscles
    INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
    SELECT p_target_id, muscle_group_id, sort_order
    FROM base_exercise_secondary_muscle
    WHERE base_exercise_id = p_source_id
    ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- 1. Barbell Row → Bent Over Barbell Row
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'barbell row' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'bent over barbell row')
);

-- 2. Bench press → Barbell Bench Press - Medium Grip
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'bench press' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'barbell bench press - medium grip')
);

-- 3. Bicep curl → Dumbbell Bicep Curl
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'bicep curl' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'dumbbell bicep curl')
);

-- 4. Calf raise → Standing Calf Raises
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'calf raise' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'standing calf raises')
);

-- 5. Deadlift → Barbell Deadlift
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'deadlift' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'barbell deadlift')
);

-- 9. Floor crunch → Crunches
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'floor crunch' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'crunches')
);

-- 10. Forearm curl back → Palms-Up Dumbbell Wrist Curl Over A Bench
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'forearm curl back' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'palms-up dumbbell wrist curl over a bench')
);

-- 11. Forearm curl in → Palms-Down Dumbbell Wrist Curl Over A Bench
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'forearm curl in' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'palms-down dumbbell wrist curl over a bench')
);

-- 12. Forearm curl up → Palms-Up Dumbbell Wrist Curl Over A Bench
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'forearm curl up' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'palms-up dumbbell wrist curl over a bench')
);

-- 13. Front raise → Front Dumbbell Raise
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'front raise' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'front dumbbell raise')
);

-- 16. Hamstring curl → Seated Leg Curl
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'hamstring curl' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'seated leg curl')
);

-- 19. Lat pulldown → Full Range-Of-Motion Lat Pulldown
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'lat pulldown' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'full range-of-motion lat pulldown')
);

-- 22. Overhead cable tricep extension → Cable Rope Overhead Triceps Extension
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'overhead cable tricep extension' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'cable rope overhead triceps extension')
);

-- 23. Overhead press → Barbell Shoulder Press
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'overhead press' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'barbell shoulder press')
);

-- 24. Pulley crunch → Cable Crunch
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'pulley crunch' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'cable crunch')
);

-- 25. Seated pulley row → Seated Cable Rows
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'seated pulley row' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'seated cable rows')
);

-- 26. Shrug → Barbell Shrug
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'shrug' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'barbell shrug')
);

-- 27. Squat → Barbell Squat
SELECT copy_base_exercise_metadata(
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'squat' AND source_name = 'original'),
    (SELECT base_exercise_id FROM base_exercise WHERE LOWER(TRIM(name)) = 'barbell squat')
);

-- Verification
DO $$
DECLARE
    updated_count INTEGER;
    original_names TEXT[] := ARRAY[
        'barbell row', 'bench press', 'bicep curl', 'calf raise', 'deadlift',
        'floor crunch', 'forearm curl back', 'forearm curl in', 'forearm curl up',
        'front raise', 'hamstring curl', 'lat pulldown', 'overhead cable tricep extension',
        'overhead press', 'pulley crunch', 'seated pulley row', 'shrug', 'squat'
    ];
BEGIN
    SELECT COUNT(*) INTO updated_count
    FROM base_exercise
    WHERE LOWER(TRIM(name)) = ANY(original_names)
      AND source_name != 'original'
      AND level IS NOT NULL;

    RAISE NOTICE '✓ Updated % exercises with direct metadata copies', updated_count;

    IF updated_count != 18 THEN
        RAISE WARNING 'Expected 18 metadata updates, got %', updated_count;
        RAISE NOTICE 'This may be normal if some exercises do not exist in production';
    END IF;
END $$;

DROP FUNCTION copy_base_exercise_metadata(uuid, uuid);

COMMIT;

-- ============================================================================
-- End of direct metadata copies
-- ============================================================================
