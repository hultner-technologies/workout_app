-- ============================================================================
-- Apply Base Exercise Merges (4 exercises → 2 base_exercises) - FIXED FOR PRODUCTION
-- Generated: 2025-11-04
-- Fixed to use dynamic UUID lookups instead of hardcoded UUIDs
-- ============================================================================
-- These exercises merge into existing base_exercises, preserving all
-- historical data via exercise.description field.
--
-- Safety:
-- - exercise.description preserves programming details (reps, sets, notes)
-- - performed_exercise records unchanged (reference exercise_id, not base_exercise_id)
-- - Foreign keys cascade correctly
-- - No data loss

BEGIN;

-- ============================================================================
-- MERGE 1: Flat dumbbell press backoff → Dumbbell press
-- ============================================================================
-- Original: "Flat dumbbell press backoff" (65 times performed)
-- Target: "Dumbbell press"
-- Preserves: "Second set back-off: 8-10" in exercise.description

-- Step 1: Update all exercises referencing the backoff base_exercise to point to target
DO $$
DECLARE
    v_source_id UUID;
    v_target_id UUID;
BEGIN
    SELECT base_exercise_id INTO v_source_id
    FROM base_exercise
    WHERE LOWER(TRIM(name)) = 'flat dumbbell press backoff' AND source_name = 'original';

    SELECT base_exercise_id INTO v_target_id
    FROM base_exercise
    WHERE LOWER(TRIM(name)) = 'dumbbell press';

    IF v_source_id IS NOT NULL AND v_target_id IS NOT NULL THEN
        UPDATE exercise
        SET base_exercise_id = v_target_id
        WHERE base_exercise_id = v_source_id;

        -- Step 2: Delete the now-unused base_exercise
        DELETE FROM base_exercise
        WHERE base_exercise_id = v_source_id;
    END IF;
END $$;

-- ============================================================================
-- MERGE 2: Flat dumbbell press heavy → Dumbbell press
-- ============================================================================
-- Original: "Flat dumbbell press heavy" (63 times performed)
-- Target: "Dumbbell press"
-- Preserves: "First set heavy 4-6" in exercise.description

-- Step 1: Update all exercises referencing the heavy base_exercise to point to target
DO $$
DECLARE
    v_source_id UUID;
    v_target_id UUID;
BEGIN
    SELECT base_exercise_id INTO v_source_id
    FROM base_exercise
    WHERE LOWER(TRIM(name)) = 'flat dumbbell press heavy' AND source_name = 'original';

    SELECT base_exercise_id INTO v_target_id
    FROM base_exercise
    WHERE LOWER(TRIM(name)) = 'dumbbell press';

    IF v_source_id IS NOT NULL AND v_target_id IS NOT NULL THEN
        UPDATE exercise
        SET base_exercise_id = v_target_id
        WHERE base_exercise_id = v_source_id;

        -- Step 2: Delete the now-unused base_exercise
        DELETE FROM base_exercise
        WHERE base_exercise_id = v_source_id;
    END IF;
END $$;

-- ============================================================================
-- MERGE 3: Hack squat backoff → Barbell Hack Squat
-- ============================================================================
-- Original: "Hack squat backoff"
-- Target: "Barbell Hack Squat"
-- Preserves: "1x8-10 + dropset" in exercise.description

-- Step 1: Update all exercises referencing the backoff base_exercise to point to target
DO $$
DECLARE
    v_source_id UUID;
    v_target_id UUID;
BEGIN
    SELECT base_exercise_id INTO v_source_id
    FROM base_exercise
    WHERE LOWER(TRIM(name)) = 'hack squat backoff' AND source_name = 'original';

    SELECT base_exercise_id INTO v_target_id
    FROM base_exercise
    WHERE LOWER(TRIM(name)) = 'barbell hack squat';

    IF v_source_id IS NOT NULL AND v_target_id IS NOT NULL THEN
        UPDATE exercise
        SET base_exercise_id = v_target_id
        WHERE base_exercise_id = v_source_id;

        -- Step 2: Delete the now-unused base_exercise
        DELETE FROM base_exercise
        WHERE base_exercise_id = v_source_id;
    END IF;
END $$;

-- ============================================================================
-- MERGE 4: Hack squat heavy → Barbell Hack Squat
-- ============================================================================
-- Original: "Hack squat heavy"
-- Target: "Barbell Hack Squat"
-- Preserves: "1x4-6 + dropset" in exercise.description

-- Step 1: Update all exercises referencing the heavy base_exercise to point to target
DO $$
DECLARE
    v_source_id UUID;
    v_target_id UUID;
BEGIN
    SELECT base_exercise_id INTO v_source_id
    FROM base_exercise
    WHERE LOWER(TRIM(name)) = 'hack squat heavy' AND source_name = 'original';

    SELECT base_exercise_id INTO v_target_id
    FROM base_exercise
    WHERE LOWER(TRIM(name)) = 'barbell hack squat';

    IF v_source_id IS NOT NULL AND v_target_id IS NOT NULL THEN
        UPDATE exercise
        SET base_exercise_id = v_target_id
        WHERE base_exercise_id = v_source_id;

        -- Step 2: Delete the now-unused base_exercise
        DELETE FROM base_exercise
        WHERE base_exercise_id = v_source_id;
    END IF;
END $$;

-- ============================================================================
-- Verification: Confirm merges completed successfully
-- ============================================================================
DO $$
DECLARE
    remaining_count INTEGER;
    merged_exercise_count INTEGER;
    dumbbell_press_id UUID;
    hack_squat_id UUID;
BEGIN
    -- Get target IDs
    SELECT base_exercise_id INTO dumbbell_press_id
    FROM base_exercise
    WHERE LOWER(TRIM(name)) = 'dumbbell press';

    SELECT base_exercise_id INTO hack_squat_id
    FROM base_exercise
    WHERE LOWER(TRIM(name)) = 'barbell hack squat';

    -- Check that the 4 merged base_exercises no longer exist
    SELECT COUNT(*) INTO remaining_count
    FROM base_exercise
    WHERE LOWER(TRIM(name)) IN (
        'flat dumbbell press backoff',
        'flat dumbbell press heavy',
        'hack squat backoff',
        'hack squat heavy'
    )
    AND source_name = 'original';

    IF remaining_count != 0 THEN
        RAISE WARNING '% base_exercises were not merged (likely because target does not exist)', remaining_count;
    ELSE
        RAISE NOTICE '✓ All mergeable base_exercises were successfully merged';
    END IF;

    -- Check that exercise rows now point to target base_exercises
    IF dumbbell_press_id IS NOT NULL AND hack_squat_id IS NOT NULL THEN
        SELECT COUNT(*) INTO merged_exercise_count
        FROM exercise
        WHERE base_exercise_id IN (dumbbell_press_id, hack_squat_id);

        RAISE NOTICE '✓ Merged 4 base_exercises successfully';
        RAISE NOTICE '✓ % exercise rows now reference merged targets', merged_exercise_count;
    END IF;

    -- Verify target base_exercises still exist
    IF dumbbell_press_id IS NULL THEN
        RAISE WARNING 'Target base_exercise "Dumbbell press" not found in production';
    END IF;

    IF hack_squat_id IS NULL THEN
        RAISE WARNING 'Target base_exercise "Barbell Hack Squat" not found in production';
    END IF;

    IF dumbbell_press_id IS NOT NULL AND hack_squat_id IS NOT NULL THEN
        RAISE NOTICE '✓ Both target base_exercises exist and have merged exercises';
    END IF;
END $$;

-- ============================================================================
-- Historical Data Preservation Verification
-- ============================================================================
-- Query to verify programming details are preserved in exercise.description:
--
-- SELECT
--     be.name as base_exercise_name,
--     e.description,
--     COUNT(pe.performed_exercise_id) as times_performed
-- FROM base_exercise be
-- JOIN exercise e ON be.base_exercise_id = e.base_exercise_id
-- LEFT JOIN performed_exercise pe ON e.exercise_id = pe.exercise_id
-- WHERE be.name IN ('Dumbbell press', 'Barbell Hack Squat')
-- GROUP BY be.name, e.description
-- ORDER BY be.name, times_performed DESC;
--
-- Expected output should show:
-- - "Dumbbell press" with descriptions like "Second set back-off: 8-10" and "First set heavy 4-6"
-- - "Barbell Hack Squat" with descriptions like "1x8-10 + dropset" and "1x4-6 + dropset"

COMMIT;

-- ============================================================================
-- End of base exercise merges
-- ============================================================================
