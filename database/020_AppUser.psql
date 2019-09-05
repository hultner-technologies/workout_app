-- Why AppUser and not User?
-- User is a reserved keyword in postgres and must be qouted to be used.
-- It's commonly discouraged to use reserved keywords in table and key names
CREATE TABLE AppUser (
    app_user_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY
    , name text NOT NULL
    , email text NOT NULL
    -- Not sure we will actually allow storage of passwords.
    , password text
    , data jsonb
);