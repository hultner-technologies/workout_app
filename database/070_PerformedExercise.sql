
CREATE TABLE performed_exercise (
    performed_exercise_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , exercise_id uuid REFERENCES exercise(exercise_id) ON DELETE SET NULL
    , performed_session_id uuid REFERENCES performed_session(performed_session_id) NOT NULL ON DELETE CASCADE
    , name text
    -- Sets is a list of reps e.g. [ 10, 10, 9, 8, 7, ], sets is the length
    , reps positive_int[] default ARRAY [ 10, 10, 10, 10, 10 ] NOT NULL
    , sets positive_int GENERATED ALWAYS AS (array_length(reps, 1)) STORED
    -- The generated column above is a PG12 feature, if you use PG11 comment
    -- it out and use the row below for now.
    -- , sets positive_int
    -- TODO: See if I can set default via session_schedule_id foreign key,
    -- for both rest and reps
    , rest interval[] DEFAULT ARRAY[
        interval '00:02:00'
        , interval '00:02:00'
        , interval '00:02:00'
        , interval '00:02:00'
        , interval '00:02:00'
        ] NOT NULL
    , weight positive_int
    , started_at timestamp default now()
    , completed_at timestamp default null
    , note text
    , data jsonb
);
