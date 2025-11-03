/*
This migration script copies descriptions and links from base_exercise to exercise
only for exercises where these fields are not already set.

This ensures exercises inherit their base exercise metadata when specific overrides
don't exist at the exercise level.
*/

BEGIN;

-- Update description where the exercise description is null
UPDATE exercise e
SET description = be.description
FROM base_exercise be
WHERE e.base_exercise_id = be.base_exercise_id
AND e.description IS NULL
AND be.description IS NOT NULL;

-- Update links where the exercise links are null
UPDATE exercise e
SET links = be.links
FROM base_exercise be
WHERE e.base_exercise_id = be.base_exercise_id
AND e.links IS NULL
AND be.links IS NOT NULL;

-- Log the count of updates for verification
DO $$
DECLARE
  desc_count INT;
  links_count INT;
BEGIN
  GET DIAGNOSTICS desc_count = ROW_COUNT;
  RAISE NOTICE 'Updated descriptions for % exercises', desc_count;
  
  GET DIAGNOSTICS links_count = ROW_COUNT;
  RAISE NOTICE 'Updated links for % exercises', links_count;
END $$;

COMMIT;