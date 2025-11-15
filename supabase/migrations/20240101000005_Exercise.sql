CREATE TABLE base_exercise (
    base_exercise_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , name text NOT NULL
    , aliases text[]
    -- Default to 1 minute
    , description text
    , links text[]
    , data jsonb
);

-- Plan exercise
CREATE TABLE exercise (
    exercise_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , base_exercise_id uuid REFERENCES base_exercise(base_exercise_id) NOT NULL
    , session_schedule_id uuid REFERENCES session_schedule(session_schedule_id) NOT NULL
    , reps positive_int NOT NULL DEFAULT 10
    , sets positive_int NOT NULL DEFAULT 5
    -- Default to 1 minute
    , rest interval NOT NULL DEFAULT interval '00:01:00'
    , step_increment positive_int NOT NULL DEFAULT 2500
    , sort_order positive_int NOT NULL DEFAULT 1000
    , description text
    , links text[]
    , data jsonb
);
