-- Create an updateable view that mirrors the exercise table
-- This view will eventually replace the exercise table when it's renamed to exercise_schedule

CREATE OR REPLACE VIEW exercise_schedule AS
SELECT 
    *
FROM exercise;
