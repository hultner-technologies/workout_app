-- Migration: Add Search Path Protection to Functions
-- Description: Add SET search_path = public to all remaining functions
-- Created: 2025-11-21
-- Priority: WARN level (Medium - search_path hijacking risk)

-- ============================================================================
-- FUNCTION SEARCH PATH PROTECTION
-- ============================================================================
-- Issue: Functions without search_path protection vulnerable to hijacking
-- Fix: Add SET search_path = public to all functions
-- Defense: Prevents malicious users from creating conflicting functions/tables
-- Reference: Supabase linter - function_search_path_mutable

-- Note: Some functions already have search_path from previous migrations:
-- - create_session_from_name, create_full_session, create_session_exercises (Priority 3)
-- - generate_unique_username (Priority 2)

-- ============================================================================
-- EXERCISE METADATA FUNCTIONS (from 065_ExerciseMetadata_Normalized.sql)
-- ============================================================================

-- Add search_path to find_exercises_by_muscle
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
SET search_path = public
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

COMMENT ON FUNCTION find_exercises_by_muscle IS
    'Find exercises that target a specific muscle group (uses normalized tables). '
    'SET search_path protects against search_path hijacking attacks.';

-- Add search_path to add_primary_muscle
CREATE OR REPLACE FUNCTION add_primary_muscle(
    p_base_exercise_id uuid,
    p_muscle_name text,
    p_sort_order int DEFAULT 0
)
RETURNS void
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
    v_muscle_id uuid;
BEGIN
    SELECT muscle_group_id INTO v_muscle_id
    FROM muscle_group
    WHERE name = p_muscle_name;

    IF v_muscle_id IS NULL THEN
        RAISE EXCEPTION 'Muscle group % not found', p_muscle_name;
    END IF;

    INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
    VALUES (p_base_exercise_id, v_muscle_id, p_sort_order)
    ON CONFLICT (base_exercise_id, muscle_group_id)
    DO UPDATE SET sort_order = p_sort_order;
END;
$$;

COMMENT ON FUNCTION add_primary_muscle IS
    'Add a primary muscle to an exercise. '
    'SET search_path protects against search_path hijacking attacks.';

-- Add search_path to add_secondary_muscle
CREATE OR REPLACE FUNCTION add_secondary_muscle(
    p_base_exercise_id uuid,
    p_muscle_name text,
    p_sort_order int DEFAULT 0
)
RETURNS void
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
    v_muscle_id uuid;
BEGIN
    SELECT muscle_group_id INTO v_muscle_id
    FROM muscle_group
    WHERE name = p_muscle_name;

    IF v_muscle_id IS NULL THEN
        RAISE EXCEPTION 'Muscle group % not found', p_muscle_name;
    END IF;

    INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
    VALUES (p_base_exercise_id, v_muscle_id, p_sort_order)
    ON CONFLICT (base_exercise_id, muscle_group_id)
    DO UPDATE SET sort_order = p_sort_order;
END;
$$;

COMMENT ON FUNCTION add_secondary_muscle IS
    'Add a secondary muscle to an exercise. '
    'SET search_path protects against search_path hijacking attacks.';

-- Add search_path to set_exercise_muscles
CREATE OR REPLACE FUNCTION set_exercise_muscles(
    p_base_exercise_id uuid,
    p_primary_muscles text[],
    p_secondary_muscles text[]
)
RETURNS void
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
    v_muscle text;
    v_sort_order int;
BEGIN
    -- Clear existing muscles
    DELETE FROM base_exercise_primary_muscle WHERE base_exercise_id = p_base_exercise_id;
    DELETE FROM base_exercise_secondary_muscle WHERE base_exercise_id = p_base_exercise_id;

    -- Add primary muscles
    v_sort_order := 0;
    FOREACH v_muscle IN ARRAY p_primary_muscles
    LOOP
        PERFORM add_primary_muscle(p_base_exercise_id, v_muscle, v_sort_order);
        v_sort_order := v_sort_order + 1;
    END LOOP;

    -- Add secondary muscles
    v_sort_order := 0;
    FOREACH v_muscle IN ARRAY p_secondary_muscles
    LOOP
        PERFORM add_secondary_muscle(p_base_exercise_id, v_muscle, v_sort_order);
        v_sort_order := v_sort_order + 1;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION set_exercise_muscles IS
    'Set all muscles for an exercise from arrays (replaces existing). '
    'SET search_path protects against search_path hijacking attacks.';

-- Add search_path to get_exercise_metadata_stats
CREATE OR REPLACE FUNCTION get_exercise_metadata_stats()
RETURNS TABLE (
    total_exercises bigint,
    exercises_with_muscles bigint,
    exercises_with_instructions bigint,
    exercises_with_images bigint,
    exercises_by_level jsonb,
    exercises_by_category jsonb,
    exercises_by_equipment jsonb
)
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT be.base_exercise_id)::bigint as total_exercises,
        COUNT(DISTINCT CASE WHEN bepm.base_exercise_id IS NOT NULL THEN be.base_exercise_id END)::bigint as exercises_with_muscles,
        COUNT(CASE WHEN be.instructions IS NOT NULL THEN 1 END)::bigint as exercises_with_instructions,
        COUNT(CASE WHEN be.image_urls IS NOT NULL THEN 1 END)::bigint as exercises_with_images,

        (SELECT jsonb_object_agg(COALESCE(l.level, 'unspecified'), l.count)
         FROM (SELECT level, COUNT(*) as count FROM base_exercise GROUP BY level) l
        ) as exercises_by_level,

        (SELECT jsonb_object_agg(COALESCE(ec.name, 'unspecified'), bc.count)
         FROM (
             SELECT category_id, COUNT(*) as count
             FROM base_exercise
             GROUP BY category_id
         ) bc
         LEFT JOIN exercise_category ec ON bc.category_id = ec.category_id
        ) as exercises_by_category,

        (SELECT jsonb_object_agg(COALESCE(et.name, 'unspecified'), be_eq.count)
         FROM (
             SELECT equipment_type_id, COUNT(*) as count
             FROM base_exercise
             GROUP BY equipment_type_id
         ) be_eq
         LEFT JOIN equipment_type et ON be_eq.equipment_type_id = et.equipment_type_id
        ) as exercises_by_equipment

    FROM base_exercise be
    LEFT JOIN base_exercise_primary_muscle bepm ON be.base_exercise_id = bepm.base_exercise_id;
END;
$$;

COMMENT ON FUNCTION get_exercise_metadata_stats IS
    'Get comprehensive statistics about exercise metadata. '
    'SET search_path protects against search_path hijacking attacks.';

-- ============================================================================
-- RLS DEBUGGING FUNCTION (from 265_RLS_Performance_Updates.sql)
-- ============================================================================

-- Add search_path to debug_rls_performance
CREATE OR REPLACE FUNCTION debug_rls_performance(table_name text)
RETURNS TABLE(
  policy_name text,
  policy_definition text,
  policy_roles text[]
)
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    pol.polname::text,
    pg_get_expr(pol.polqual, pol.polrelid)::text,
    ARRAY(
      SELECT rolname::text
      FROM pg_roles
      WHERE oid = ANY(pol.polroles)
    )
  FROM pg_policy pol
  JOIN pg_class cls ON pol.polrelid = cls.oid
  WHERE cls.relname = table_name;
END;
$$;

COMMENT ON FUNCTION debug_rls_performance IS
    'Debug helper to show RLS policies for a table. '
    'SET search_path protects against search_path hijacking attacks.';

-- ============================================================================
-- AUTH MIGRATION FUNCTION (from 025_AppUser_Auth_Migration.sql)
-- ============================================================================

-- Add search_path to backfill_username_on_insert
CREATE OR REPLACE FUNCTION backfill_username_on_insert()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  generated_username text;
BEGIN
  IF NEW.username IS NULL THEN
    generated_username := generate_unique_username();
    NEW.username := generated_username;
  END IF;
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION backfill_username_on_insert IS
    'Trigger function to backfill NULL usernames during seed/migration. '
    'SET search_path protects against search_path hijacking attacks.';

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- All functions now have SET search_path = public
-- This prevents search_path hijacking attacks where malicious users
-- could create conflicting function/table names in their schema
-- Non-breaking change: Pure security enhancement
