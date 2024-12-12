-- Special sets are a special type of set for a performed_exercise.
-- These include warm-up, drop sets, super sets, myo reps, pyramid sets, AMRAP,
-- and so on.
-- Drop-sets are a set where you decrease the weight after each set.
-- Super-sets are a set where you do two exercises back to back.
-- Myo-reps are a set where you do a set to failure, rest for a short period,
-- then do another set to failure, and so on.
-- Pyramid sets are a set where you increase the weight after each set.
-- AMRAP is as many reps as possible.
-- The performed_exercise_set table is a many-to-many relationship between performed_exercise
-- and performed_exercise_set_type.
-- The performed_exercise_set_type table is a list of special set types.
-- The performed_exercise_set table has a weight column to allow for drop sets and pyramid
-- sets.
-- The performed_exercise_set table has a reps column to allow for AMRAP.
-- The performed_exercise_set table has a rest column to allow for myo-reps.
-- The performed_exercise_set table has a order column to allow for pyramid sets.
-- The performed_exercise_set table has a note column to allow for notes.
-- The performed_exercise_set table has a data column to allow for future expansion.
-- The performed_exercise_set table has a started_at column to allow for auditing.
-- The performed_exercise_set table has a completed_at column to allow for auditing.
-- The performed_exercise_set table has a parent_performed_exercise_set_id column to allow for super sets
-- and myo-reps to be nested.
-- The performed_exercise_set table has a performed_exercise_id column to allow for the set to
-- connect to a performed_exercise.

create table exercise_set_type (
    name text PRIMARY KEY CHECK (name <> '')
    , description text
);
insert into exercise_set_type (name, description)
values
    ('warm-up', 'A warm-up set.')
    , ('drop-set', 'A set where you decrease the weight after each set.')
    , ('super-set', 'A set where you do two exercises back to back.')
    , ('myo-rep', 'A set where you do a set to failure, rest for a short period, then do another set to failure, and so on.')
    , ('pyramid-set', 'A set where you increase the weight after each set.')
    , ('AMRAP', 'As many reps as possible.')
    , ('other', 'A set that does not fit into the other categories.');


CREATE TABLE performed_exercise_set (
    performed_exercise_set_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , performed_exercise_id uuid REFERENCES performed_exercise(performed_exercise_id) NOT NULL
    , exercise_set_type text REFERENCES exercise_set_type(name) NOT NULL
    , weight positive_int NOT NULL
    , reps positive_int NOT NULL
    , rest interval NOT NULL default interval '00:01:00'
    , "order" positive_int NOT NULL
    , note text
    , data jsonb
    , started_at timestamp default now()
    , completed_at timestamp default null
    , parent_performed_exercise_set_id uuid REFERENCES performed_exercise_set(performed_exercise_set_id)
);

