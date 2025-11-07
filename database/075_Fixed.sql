-- ============================================================================
-- Populate Unknown Plan with All Base Exercises - FIXED FOR PRODUCTION
-- Generated: 2025-11-04
-- Fixed to use dynamic UUID lookups instead of hardcoded UUIDs
-- ============================================================================
-- Adds all base_exercises that aren't already in the Unknown plan
-- Default values: 10 reps, 3 sets, 60 seconds rest

BEGIN;

-- Insert exercises for all base_exercises not yet in Unknown plan
INSERT INTO exercise (
    base_exercise_id,
    session_schedule_id,
    description,
    reps,
    sets,
    rest,
    sort_order
)
SELECT
    be.base_exercise_id,
    (SELECT ss.session_schedule_id
     FROM session_schedule ss
     JOIN plan p ON ss.plan_id = p.plan_id
     WHERE p.name = 'Unknown'
     LIMIT 1) as session_schedule_id,
    'Added automatically to Unknown plan' as description,
    10 as reps,
    3 as sets,
    '00:01:00'::interval as rest,
    0 as sort_order
FROM base_exercise be
WHERE NOT EXISTS (
    SELECT 1 FROM exercise e
    WHERE e.base_exercise_id = be.base_exercise_id
      AND e.session_schedule_id = (
          SELECT ss.session_schedule_id
          FROM session_schedule ss
          JOIN plan p ON ss.plan_id = p.plan_id
          WHERE p.name = 'Unknown'
          LIMIT 1
      )
)
ORDER BY be.name;

-- Verification
DO $$
DECLARE
    total_base_exercises INTEGER;
    unknown_plan_exercises INTEGER;
    inserted_count INTEGER;
    v_session_schedule_id UUID;
BEGIN
    -- Get Unknown plan session schedule
    SELECT ss.session_schedule_id INTO v_session_schedule_id
    FROM session_schedule ss
    JOIN plan p ON ss.plan_id = p.plan_id
    WHERE p.name = 'Unknown'
    LIMIT 1;

    IF v_session_schedule_id IS NULL THEN
        RAISE EXCEPTION 'Unknown plan session schedule not found';
    END IF;

    -- Count total base_exercises
    SELECT COUNT(*) INTO total_base_exercises FROM base_exercise;

    -- Count exercises in Unknown plan
    SELECT COUNT(*) INTO unknown_plan_exercises
    FROM exercise
    WHERE session_schedule_id = v_session_schedule_id;

    -- Calculate how many were just inserted
    SELECT COUNT(*) INTO inserted_count
    FROM exercise
    WHERE session_schedule_id = v_session_schedule_id
      AND description = 'Added automatically to Unknown plan';

    RAISE NOTICE '✓ Total base_exercises: %', total_base_exercises;
    RAISE NOTICE '✓ Exercises in Unknown plan: %', unknown_plan_exercises;
    RAISE NOTICE '✓ Just inserted: %', inserted_count;

    -- Verify we have at least as many exercises as base_exercises
    IF unknown_plan_exercises < total_base_exercises THEN
        RAISE WARNING 'Unknown plan has % exercises but there are % base_exercises',
            unknown_plan_exercises, total_base_exercises;
    END IF;
END $$;

COMMIT;

-- ============================================================================
-- End of Unknown plan population
-- ============================================================================
