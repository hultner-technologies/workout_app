CREATE TABLE Exercise (
    exercise_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , session_schedule_id uuid REFERENCES SessionSchedule(session_schedule_id) NOT NULL
    , name text NOT NULL
    , reps positive_int NOT NULL DEFAULT 10
    , sets positive_int NOT NULL DEFAULT 5
    -- Default to 1 minute
    , rest interval NOT NULL DEFAULT interval '00:01:00'
    , description text
    , links text[]
    , data jsonb
);
