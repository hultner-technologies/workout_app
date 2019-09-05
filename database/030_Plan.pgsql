CREATE TABLE Plan (
    plan_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , name text NOT NULL
    , description text
    , links text[]
    , data jsonb
);