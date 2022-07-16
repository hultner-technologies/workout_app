CREATE TABLE base_exercise (
    base_exercise_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , name text NOT NULL
    -- Default to 1 minute
    , description text
    , links text[]
    , data jsonb
);

CREATE TABLE exercise (
    exercise_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , base_exercise_id uuid REFERENCES base_exercise(base_exercise_id) NOT NULL
    , session_schedule_id uuid REFERENCES session_schedule(session_schedule_id) NOT NULL
    , reps positive_int NOT NULL DEFAULT 10
    , sets positive_int NOT NULL DEFAULT 5
    -- Default to 1 minute
    , rest interval NOT NULL DEFAULT interval '00:01:00'
    , data jsonb
);
