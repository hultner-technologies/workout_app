-- Migration: Backfill performed_exercise_set from legacy performed_exercise data
--
-- Context: Since 2024, we've been using the performed_exercise_set table for new workouts
-- to support advanced set types (drop-sets, pyramid sets, etc.) and per-set tracking.
-- However, historical data (2019-2024) still only exists in the legacy performed_exercise
-- weight/reps fields. This migration backfills that historical data into the sets table
-- so we can fully deprecate the legacy fields and update all views/functions.
--
-- Created: 2025-11-21

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
    -- Loop through all completed performed_exercises that don't have sets yet
    FOR pe_record IN
        SELECT
            pe.performed_exercise_id,
            pe.weight,
            pe.reps,
            pe.rest,
            pe.started_at,
            pe.completed_at,
            pe.sets
        FROM performed_exercise pe
        WHERE pe.completed_at IS NOT NULL  -- Only finished exercises
          AND pe.weight IS NOT NULL        -- Must have weight data
          AND pe.sets IS NOT NULL          -- Must have sets
          AND pe.sets > 0                  -- Must have at least one set
          -- Don't backfill if sets already exist
          AND NOT EXISTS (
              SELECT 1
              FROM performed_exercise_set pes
              WHERE pes.performed_exercise_id = pe.performed_exercise_id
          )
        ORDER BY pe.started_at
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
                pe_record.weight,  -- Same weight for all sets in legacy data
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

        -- Log progress every 1000 exercises
        IF pe_record.performed_exercise_id::text = ANY(
            ARRAY(
                SELECT performed_exercise_id::text
                FROM performed_exercise
                WHERE completed_at IS NOT NULL
                  AND weight IS NOT NULL
                  AND NOT EXISTS (
                      SELECT 1 FROM performed_exercise_set pes
                      WHERE pes.performed_exercise_id = performed_exercise.performed_exercise_id
                  )
                ORDER BY started_at
                OFFSET 1000 * (
                    SELECT COUNT(*)::integer / 1000
                    FROM performed_exercise pe2
                    WHERE pe2.started_at <= pe_record.started_at
                      AND pe2.completed_at IS NOT NULL
                      AND pe2.weight IS NOT NULL
                      AND NOT EXISTS (
                          SELECT 1 FROM performed_exercise_set pes2
                          WHERE pes2.performed_exercise_id = pe2.performed_exercise_id
                      )
                )
                LIMIT 1
            )
        ) THEN
            RAISE NOTICE 'Backfilled sets up to %', pe_record.started_at;
        END IF;
    END LOOP;

    RAISE NOTICE 'Backfill complete!';

    -- Report statistics
    RAISE NOTICE 'Total performed_exercises with sets: %',
        (SELECT COUNT(*) FROM performed_exercise_set);
    RAISE NOTICE 'Total performed_exercises completed: %',
        (SELECT COUNT(*) FROM performed_exercise WHERE completed_at IS NOT NULL);
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
