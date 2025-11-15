-- Set up database
--
-- General setup before creating the domain model.
--
-- Created: 2019-08-31
-- Author: Alexander Hultnér <ahultner@gmail.com>, 2019

-- Set up db
-- Should we create schema and database? If so should we set them.
-- It's reasonable that these would be configurable, might be better to do in
-- the deployment script.
-- CREATE database workout_app;

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Custom data types and domains
DO $$
    BEGIN
        IF NOT EXISTS(SELECT 1 from pg_type WHERE typname = 'positive_int') THEN
            CREATE DOMAIN positive_int AS int
                CHECK(VALUE >= 0);
        END IF;
    END
$$;


