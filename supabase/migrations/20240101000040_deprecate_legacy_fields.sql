-- Migration: Add deprecation warnings to legacy performed_exercise fields
--
-- The weight, reps, sets, and rest fields in performed_exercise are now deprecated
-- in favor of the performed_exercise_set table. These fields are maintained for
-- backward compatibility but should not be used in new code.
--
-- All new code should use performed_exercise_set table and its aggregations.
--
-- Created: 2025-11-21

-- Add deprecation comments to the table
COMMENT ON TABLE performed_exercise IS
    'Records of exercises performed during workout sessions. '
    'IMPORTANT: The weight, reps, sets, and rest fields are DEPRECATED as of 2025-11-21. '
    'Use the performed_exercise_set table instead for all new code. '
    'Legacy fields are maintained for backward compatibility only.';

-- Add deprecation comments to specific columns
COMMENT ON COLUMN performed_exercise.weight IS
    'DEPRECATED: Use performed_exercise_set table instead. '
    'This field is maintained for backward compatibility only. '
    'For historical data (pre-2024), this was the single weight used for all sets. '
    'New workouts should store per-set weights in performed_exercise_set.weight.';

COMMENT ON COLUMN performed_exercise.reps IS
    'DEPRECATED: Use performed_exercise_set table instead. '
    'This field is maintained for backward compatibility only. '
    'For historical data (pre-2024), this was an array of reps for each set. '
    'New workouts should store per-set reps in performed_exercise_set.reps.';

COMMENT ON COLUMN performed_exercise.sets IS
    'DEPRECATED: Use performed_exercise_set table instead. '
    'This field is maintained for backward compatibility only. '
    'This is a generated column from array_length(reps, 1). '
    'New workouts should count rows in performed_exercise_set for the set count.';

COMMENT ON COLUMN performed_exercise.rest IS
    'DEPRECATED: Use performed_exercise_set table instead. '
    'This field is maintained for backward compatibility only. '
    'For historical data (pre-2024), this was an array of rest intervals between sets. '
    'New workouts should store per-set rest intervals in performed_exercise_set.rest.';

-- Add guidance comment to performed_exercise_set table
COMMENT ON TABLE performed_exercise_set IS
    'Individual sets for performed exercises. This is the PRIMARY source of truth '
    'for exercise data as of 2025-11-21. Supports advanced set types (drop-set, '
    'pyramid-set, myo-rep, etc.) and per-set tracking of weight, reps, rest, and timing. '
    'All new code should use this table instead of the deprecated performed_exercise '
    'weight/reps/sets/rest fields.';

COMMENT ON COLUMN performed_exercise_set.exercise_set_type IS
    'Type of set: regular, warm-up, drop-set, pyramid-set, myo-rep, super-set, AMRAP, or other. '
    'See exercise_set_type table for full definitions.';

COMMENT ON COLUMN performed_exercise_set.weight IS
    'Weight used for this specific set, in grams. '
    'Allows for varying weights across sets (e.g., drop-sets, pyramid sets).';

COMMENT ON COLUMN performed_exercise_set.reps IS
    'Number of repetitions performed in this specific set.';

COMMENT ON COLUMN performed_exercise_set.rest IS
    'Rest interval after this set before the next set.';

COMMENT ON COLUMN performed_exercise_set."order" IS
    'Order of this set within the exercise (1-indexed). '
    'Used to maintain set sequence when querying.';

COMMENT ON COLUMN performed_exercise_set.parent_performed_exercise_set_id IS
    'Parent set ID for nested set types like super-sets and myo-reps. '
    'NULL for top-level sets.';
