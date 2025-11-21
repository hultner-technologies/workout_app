-- Migration: Backfill performed_exercise_set from legacy performed_exercise data
--
-- Context: Since 2024, we've been using the performed_exercise_set table for new workouts
-- to support advanced set types (drop-sets, pyramid sets, etc.) and per-set tracking.
-- However, historical data (2019-2024) still only exists in the legacy performed_exercise
-- weight/reps fields. This migration backfills that historical data into the sets table
-- so we can fully deprecate the legacy fields and update all views/functions.
--
-- Strategy: Conservative session-level exclusion
--   - Skip entire performed_session if ANY exercise in it has sets
--   - Prevents mixing pre-migration and post-migration data in same session
--   - Safe for data integrity, can run additional passes if needed
--
-- Rules:
--   1. Only backfill if performed_session.completed_at IS NOT NULL
--   2. Allow NULL weight (body weight exercises like push-ups, pull-ups)
--   3. Use reps array as source of truth for number of sets
--   4. Handle mismatched rest arrays gracefully (use default if missing)
--
-- Created: 2025-11-21
-- Updated: 2025-11-21 (conservative session-level exclusion)

-- Backfill performed_exercise_set for all completed performed_exercises
-- that don't already have sets in the performed_exercise_set table
DO $$
DECLARE
    pe_record RECORD;
    rep_value positive_int;
    rest_value interval;
    set_index integer;
    set_count integer;
    exercise_duration interval;
    set_duration interval;
    default_rest interval := interval '00:02:00';
    current_started_at timestamp;
    current_completed_at timestamp;
BEGIN
    -- Loop through all performed_exercises in completed sessions that don't have sets yet
    -- Conservative approach: Skip entire session if ANY exercise in it has sets
    FOR pe_record IN
        SELECT
            pe.performed_exercise_id,
            pe.weight,
            pe.reps,
            pe.rest,
            pe.started_at,
            pe.completed_at,
            pe.sets,
            pe.performed_session_id
        FROM performed_exercise pe
        JOIN performed_session ps ON pe.performed_session_id = ps.performed_session_id
        WHERE ps.completed_at IS NOT NULL  -- Only backfill exercises in completed sessions
          AND pe.sets IS NOT NULL          -- Must have set count
          AND pe.sets > 0                  -- Must have at least one set
          AND pe.reps IS NOT NULL          -- Must have reps array
          AND array_length(pe.reps, 1) > 0 -- Reps array must not be empty
          -- Conservative session-level exclusion: Skip entire session if ANY exercise has sets
          AND NOT EXISTS (
              SELECT 1
              FROM performed_exercise_set pes
              JOIN performed_exercise pe2 ON pes.performed_exercise_id = pe2.performed_exercise_id
              WHERE pe2.performed_session_id = pe.performed_session_id
          )
        ORDER BY ps.completed_at, pe.started_at
    LOOP
        -- Calculate exercise duration (default to reasonable value if null)
        exercise_duration := COALESCE(
            pe_record.completed_at - pe_record.started_at,
            interval '5 minutes' * pe_record.sets  -- Default: 5 min per set
        );

        -- Calculate duration per set (divide total time by number of sets)
        set_duration := exercise_duration / pe_record.sets;

        -- Track timing for each set
        current_started_at := pe_record.started_at;

        -- Insert a performed_exercise_set for each rep count in the array
        set_count := array_length(pe_record.reps, 1);

        FOR set_index IN 1..set_count LOOP
            rep_value := pe_record.reps[set_index];

            -- Get rest interval for this set, use default if not properly set
            -- Check if rest array exists and has this index
            IF pe_record.rest IS NOT NULL AND array_length(pe_record.rest, 1) >= set_index THEN
                rest_value := pe_record.rest[set_index];
                -- If rest is exactly the default value, it was probably not customized
                -- but we'll keep it anyway for data consistency
            ELSE
                rest_value := default_rest;
            END IF;

            -- Calculate completed_at for this set
            current_completed_at := current_started_at + set_duration;

            -- Insert the set
            INSERT INTO performed_exercise_set (
                performed_exercise_id,
                exercise_set_type,
                weight,
                reps,
                rest,
                "order",
                started_at,
                completed_at,
                note,
                data
            ) VALUES (
                pe_record.performed_exercise_id,
                'regular',  -- All legacy sets are regular sets
                COALESCE(pe_record.weight, 0),  -- Body weight exercises: NULL → 0
                rep_value,
                rest_value,
                set_index,  -- Order is 1-indexed
                current_started_at,
                current_completed_at,
                NULL,  -- No per-set notes in legacy data
                NULL   -- No per-set data in legacy data
            );

            -- Update started_at for next set (completed_at of current set)
            current_started_at := current_completed_at;
        END LOOP;

        -- Log progress every 100 exercises (more frequent feedback)
        IF MOD((
            SELECT COUNT(*)::integer
            FROM performed_exercise_set pes2
            WHERE pes2.performed_exercise_id IN (
                SELECT pe3.performed_exercise_id
                FROM performed_exercise pe3
                WHERE pe3.performed_session_id = pe_record.performed_session_id
            )
        ), 100) = 0 THEN
            RAISE NOTICE 'Backfilled session % (exercise started at %)',
                pe_record.performed_session_id, pe_record.started_at;
        END IF;
    END LOOP;

    RAISE NOTICE 'Backfill complete!';

    -- Report statistics
    RAISE NOTICE '=== Backfill Statistics ===';
    RAISE NOTICE 'Total sets created: %',
        (SELECT COUNT(*) FROM performed_exercise_set);
    RAISE NOTICE 'Total exercises with sets: %',
        (SELECT COUNT(DISTINCT performed_exercise_id) FROM performed_exercise_set);
    RAISE NOTICE 'Total completed sessions: %',
        (SELECT COUNT(*) FROM performed_session WHERE completed_at IS NOT NULL);
    RAISE NOTICE 'Total completed exercises: %',
        (SELECT COUNT(*) FROM performed_exercise pe
         JOIN performed_session ps ON pe.performed_session_id = ps.performed_session_id
         WHERE ps.completed_at IS NOT NULL);
    RAISE NOTICE 'Sessions with sets (post-migration or backfilled): %',
        (SELECT COUNT(DISTINCT ps.performed_session_id)
         FROM performed_session ps
         WHERE EXISTS (
             SELECT 1
             FROM performed_exercise_set pes
             JOIN performed_exercise pe ON pes.performed_exercise_id = pe.performed_exercise_id
             WHERE pe.performed_session_id = ps.performed_session_id
         ));
    RAISE NOTICE '=========================';
END $$;

-- Create index to speed up queries that aggregate from sets
CREATE INDEX IF NOT EXISTS idx_performed_exercise_set_performed_exercise_id
    ON performed_exercise_set(performed_exercise_id);

CREATE INDEX IF NOT EXISTS idx_performed_exercise_set_completed_at
    ON performed_exercise_set(completed_at)
    WHERE completed_at IS NOT NULL;

-- Add comment to migration
COMMENT ON TABLE performed_exercise_set IS
    'Individual sets for performed exercises. Supports advanced set types (drop-set, '
    'pyramid-set, etc.) and per-set tracking. As of 2025-11-21, this is the primary '
    'source of truth for exercise data. Legacy performed_exercise.weight/reps fields '
    'are deprecated but maintained for backward compatibility.';
