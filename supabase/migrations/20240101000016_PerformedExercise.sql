
CREATE TABLE performed_exercise (
    performed_exercise_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , exercise_id uuid REFERENCES exercise(exercise_id) ON DELETE SET NULL
    , performed_session_id uuid REFERENCES performed_session(performed_session_id) ON DELETE CASCADE NOT NULL
    , name text

    -- ========================================================================
    -- DEPRECATED FIELDS (as of 2025-11-21)
    -- ========================================================================
    -- The following fields are DEPRECATED and maintained for backward compatibility only.
    -- DO NOT use these fields in new code. Use performed_exercise_set table instead.
    --
    -- Historical context: These fields were used 2019-2024 to store a single weight
    -- with an array of reps. This model couldn't support drop-sets, pyramid sets,
    -- or per-set weight variations. The performed_exercise_set table (added 2024)
    -- is now the primary source of truth.
    --
    -- Migration: All historical data has been backfilled to performed_exercise_set.
    -- All views and functions now aggregate from performed_exercise_set.
    -- ========================================================================

    -- DEPRECATED: Use performed_exercise_set.reps instead
    -- Sets is a list of reps e.g. [ 10, 10, 9, 8, 7, ], sets is the length
    , reps positive_int[] default ARRAY [ 10, 10, 10, 10, 10 ] NOT NULL

    -- DEPRECATED: Use COUNT(*) from performed_exercise_set instead
    , sets positive_int GENERATED ALWAYS AS (array_length(reps, 1)) STORED
    -- The generated column above is a PG12 feature, if you use PG11 comment
    -- it out and use the row below for now.
    -- , sets positive_int

    -- DEPRECATED: Use performed_exercise_set.rest instead
    -- TODO: See if I can set default via session_schedule_id foreign key,
    -- for both rest and reps
    , rest interval[] DEFAULT ARRAY[
        interval '00:02:00'
        , interval '00:02:00'
        , interval '00:02:00'
        , interval '00:02:00'
        , interval '00:02:00'
        ] NOT NULL

    -- DEPRECATED: Use performed_exercise_set.weight instead
    -- This was a single weight for all sets. New model supports per-set weights.
    , weight positive_int

    -- ========================================================================
    -- END DEPRECATED FIELDS
    -- ========================================================================

    , started_at timestamp default now()
    , completed_at timestamp default null
    , note text
    , data jsonb
);
