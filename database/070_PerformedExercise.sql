
CREATE TABLE performed_exercise (
    performed_exercise_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , exercise_id uuid REFERENCES exercise(exercise_id)
    , performed_session_id uuid REFERENCES performed_session(performed_session_id) NOT NULL
    , name text
    -- Sets is a list of reps e.g. [ 10, 10, 9, 8, 7, ], sets is the lenght
    , reps positive_int[] NOT NULL
    , sets positive_int GENERATED ALWAYS AS (array_length(reps, 1)) STORED
    -- The generated column above is a PG12 feature, if you use PG11 comment
    -- it out and use the row below for now.
    -- , sets positive_int
    -- TODO: See if I can set default via session_schedule_id foreign key,
    -- for both rest and reps
    , rest interval[] DEFAULT ARRAY[
        interval '00:01:00'
        , interval '00:01:00'
        , interval '00:01:00'
        , interval '00:01:00'
        , interval '00:01:00'
        ]
    , weight positive_int
    , started_at timestamp default now()
    , completed_at timestamp default now()
    , note text
    , data jsonb
);
