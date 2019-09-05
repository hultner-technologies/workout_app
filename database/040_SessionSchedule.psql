CREATE TABLE SessionSchedule (
    session_schedule_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , plan_id uuid REFERENCES Plan(plan_id) NOT NULL
    , name text NOT NULL
    , description text
    , links text[]
    , data jsonb
);