-- Find potential duplicates between original Supabase exercises and free-exercise-db imports
-- This query uses fuzzy matching to find similar exercise names

-- Enable pg_trgm for similarity matching
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Find duplicates using similarity matching
SELECT
    orig.base_exercise_id as original_id,
    orig.name as original_name,
    orig.description as original_description,
    imported.base_exercise_id as imported_id,
    imported.name as imported_name,
    imported.source_id as imported_source_id,
    similarity(orig.name, imported.name) as similarity_score,
    imported.level,
    imported.equipment_type_id,
    imported.category_id,
    ARRAY(
        SELECT mg.name
        FROM base_exercise_primary_muscle bepm
        JOIN muscle_group mg ON bepm.muscle_group_id = mg.muscle_group_id
        WHERE bepm.base_exercise_id = imported.base_exercise_id
        ORDER BY mg.name
    ) as imported_primary_muscles,
    ARRAY(
        SELECT mg.name
        FROM base_exercise_secondary_muscle besm
        JOIN muscle_group mg ON besm.muscle_group_id = mg.muscle_group_id
        WHERE besm.base_exercise_id = imported.base_exercise_id
        ORDER BY mg.name
    ) as imported_secondary_muscles
FROM base_exercise orig
CROSS JOIN base_exercise imported
WHERE
    -- Original exercises (no source_name)
    orig.source_name IS NULL
    -- Imported exercises (has source_name)
    AND imported.source_name = 'free-exercise-db'
    -- Similar names (threshold 0.3 to catch variations)
    AND similarity(orig.name, imported.name) > 0.3
ORDER BY
    orig.name,
    similarity_score DESC;

-- Count potential duplicates
SELECT
    COUNT(DISTINCT orig.base_exercise_id) as original_exercises_with_potential_duplicates,
    COUNT(*) as total_potential_matches
FROM base_exercise orig
CROSS JOIN base_exercise imported
WHERE
    orig.source_name IS NULL
    AND imported.source_name = 'free-exercise-db'
    AND similarity(orig.name, imported.name) > 0.3;
