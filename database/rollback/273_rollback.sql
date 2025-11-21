-- Rollback: Function Search Path Protection
-- Description: Remove SET search_path from functions
-- WARNING: This rollback removes protection against search_path hijacking!
-- Only use if migration 273 causes critical issues

BEGIN;

-- ============================================================================
-- ROLLBACK: REMOVE search_path FROM FUNCTIONS
-- ============================================================================
-- Note: This just shows the concept - in practice, functions would be reverted
-- to their original versions without SET search_path = public

-- The rollback would recreate each function without the SET search_path clause
-- For brevity, showing one example:

CREATE OR REPLACE FUNCTION find_exercises_by_muscle(
    muscle_name text,
    include_secondary boolean DEFAULT true
)
RETURNS TABLE (
    base_exercise_id uuid,
    name text,
    level text,
    equipment text,
    is_primary boolean
)
LANGUAGE plpgsql
-- NO SET search_path = public here
AS $$
BEGIN
    RETURN QUERY
    SELECT
        be.base_exercise_id,
        be.name,
        be.level,
        et.name as equipment,
        true as is_primary
    FROM base_exercise be
    LEFT JOIN equipment_type et ON be.equipment_type_id = et.equipment_type_id
    JOIN base_exercise_primary_muscle bepm ON be.base_exercise_id = bepm.base_exercise_id
    JOIN muscle_group mg ON bepm.muscle_group_id = mg.muscle_group_id
    WHERE mg.name = muscle_name

    UNION ALL

    SELECT
        be.base_exercise_id,
        be.name,
        be.level,
        et.name as equipment,
        false as is_primary
    FROM base_exercise be
    LEFT JOIN equipment_type et ON be.equipment_type_id = et.equipment_type_id
    JOIN base_exercise_secondary_muscle besm ON be.base_exercise_id = besm.base_exercise_id
    JOIN muscle_group mg ON besm.muscle_group_id = mg.muscle_group_id
    WHERE include_secondary AND mg.name = muscle_name;
END;
$$;

-- Similar rollbacks would be applied to:
-- - add_primary_muscle
-- - add_secondary_muscle
-- - set_exercise_muscles
-- - get_exercise_metadata_stats
-- - debug_rls_performance
-- - backfill_username_on_insert

COMMENT ON FUNCTION find_exercises_by_muscle IS
    '⚠️ ROLLBACK: Function WITHOUT search_path protection. '
    'This is the pre-migration state - vulnerable to search_path hijacking.';

COMMIT;
