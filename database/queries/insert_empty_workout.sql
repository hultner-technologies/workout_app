-- Insert an empty workout plan for testing
-- This creates a plan with a session schedule but NO exercises
-- Use case: Users who want to create a blank template to fill in later

-- Create the "Empty Workout" plan
INSERT INTO plan (plan_id, name, description)
VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'Empty Workout',
    'A blank workout template for users to customize with their own exercises'
)
ON CONFLICT (plan_id) DO UPDATE
SET name = EXCLUDED.name,
    description = EXCLUDED.description;

-- Create a session schedule for the empty workout (no exercises)
INSERT INTO session_schedule (
    session_schedule_id,
    plan_id,
    name,
    description,
    progression_limit
)
VALUES (
    'a1111111-1111-1111-1111-111111111111'::uuid,
    '11111111-1111-1111-1111-111111111111'::uuid,
    'Custom Workout',
    'Add your own exercises to this session',
    0.8
)
ON CONFLICT (session_schedule_id) DO UPDATE
SET name = EXCLUDED.name,
    description = EXCLUDED.description,
    progression_limit = EXCLUDED.progression_limit;

-- Note: Intentionally NOT inserting any exercises
-- This creates an empty workout template
