CREATE TABLE session_schedule (
    session_schedule_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , plan_id uuid REFERENCES plan(plan_id) NOT NULL
    , name text NOT NULL
    , description text
    , progression_limit numeric(2,1) default 1 NOT NULL CHECK (progression_limit > 0
                                                                   and
                                                               progression_limit <= 1 )
    , links text[]
    , data jsonb
);
