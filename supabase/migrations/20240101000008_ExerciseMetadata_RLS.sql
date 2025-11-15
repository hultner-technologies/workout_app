-- Row Level Security for Exercise Metadata Tables
-- This ensures proper access control for Supabase

-- ============================================================================
-- Reference Tables (Read-Only for All Users)
-- ============================================================================

-- muscle_group table
ALTER TABLE muscle_group ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for all users" ON muscle_group
    FOR SELECT
    USING (true);

CREATE POLICY "Prevent insert for all users" ON muscle_group
    FOR INSERT
    WITH CHECK (false);

CREATE POLICY "Prevent update for all users" ON muscle_group
    FOR UPDATE
    USING (false);

CREATE POLICY "Prevent delete for all users" ON muscle_group
    FOR DELETE
    USING (false);

COMMENT ON POLICY "Allow read access for all users" ON muscle_group IS 
    'All users can read muscle groups for exercise filtering and display';

-- equipment_type table
ALTER TABLE equipment_type ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for all users" ON equipment_type
    FOR SELECT
    USING (true);

CREATE POLICY "Prevent insert for all users" ON equipment_type
    FOR INSERT
    WITH CHECK (false);

CREATE POLICY "Prevent update for all users" ON equipment_type
    FOR UPDATE
    USING (false);

CREATE POLICY "Prevent delete for all users" ON equipment_type
    FOR DELETE
    USING (false);

COMMENT ON POLICY "Allow read access for all users" ON equipment_type IS 
    'All users can read equipment types for exercise filtering and display';

-- exercise_category table
ALTER TABLE exercise_category ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for all users" ON exercise_category
    FOR SELECT
    USING (true);

CREATE POLICY "Prevent insert for all users" ON exercise_category
    FOR INSERT
    WITH CHECK (false);

CREATE POLICY "Prevent update for all users" ON exercise_category
    FOR UPDATE
    USING (false);

CREATE POLICY "Prevent delete for all users" ON exercise_category
    FOR DELETE
    USING (false);

COMMENT ON POLICY "Allow read access for all users" ON exercise_category IS 
    'All users can read exercise categories for exercise filtering and display';

-- ============================================================================
-- base_exercise table (Read-Only for All Users)
-- ============================================================================

ALTER TABLE base_exercise ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for all users" ON base_exercise
    FOR SELECT
    USING (true);

-- Note: For user-generated exercises in the future, modify these policies
-- Currently, exercises are managed by admins only

CREATE POLICY "Prevent insert for regular users" ON base_exercise
    FOR INSERT
    WITH CHECK (false);

CREATE POLICY "Prevent update for regular users" ON base_exercise
    FOR UPDATE
    USING (false);

CREATE POLICY "Prevent delete for regular users" ON base_exercise
    FOR DELETE
    USING (false);

COMMENT ON POLICY "Allow read access for all users" ON base_exercise IS 
    'All users can read base exercises. Modify these policies to allow user-generated exercises in the future.';

-- ============================================================================
-- Junction Tables (Read-Only for All Users)
-- ============================================================================

-- base_exercise_primary_muscle
ALTER TABLE base_exercise_primary_muscle ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for all users" ON base_exercise_primary_muscle
    FOR SELECT
    USING (true);

CREATE POLICY "Prevent insert for regular users" ON base_exercise_primary_muscle
    FOR INSERT
    WITH CHECK (false);

CREATE POLICY "Prevent update for regular users" ON base_exercise_primary_muscle
    FOR UPDATE
    USING (false);

CREATE POLICY "Prevent delete for regular users" ON base_exercise_primary_muscle
    FOR DELETE
    USING (false);

-- base_exercise_secondary_muscle
ALTER TABLE base_exercise_secondary_muscle ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for all users" ON base_exercise_secondary_muscle
    FOR SELECT
    USING (true);

CREATE POLICY "Prevent insert for regular users" ON base_exercise_secondary_muscle
    FOR INSERT
    WITH CHECK (false);

CREATE POLICY "Prevent update for regular users" ON base_exercise_secondary_muscle
    FOR UPDATE
    USING (false);

CREATE POLICY "Prevent delete for regular users" ON base_exercise_secondary_muscle
    FOR DELETE
    USING (false);

-- ============================================================================
-- Future: User-Generated Exercises
-- ============================================================================

-- When you want to allow users to create custom exercises, replace the policies above with:
--
-- CREATE POLICY "Allow insert for authenticated users" ON base_exercise
--     FOR INSERT
--     TO authenticated
--     WITH CHECK (
--         -- Option 1: Allow all authenticated users to create exercises
--         auth.uid() IS NOT NULL
--         
--         -- Option 2: Add a creator_id column and check ownership
--         -- creator_id = auth.uid()
--     );
--
-- CREATE POLICY "Allow update for exercise creator" ON base_exercise
--     FOR UPDATE
--     TO authenticated
--     USING (
--         -- Requires adding creator_id column to base_exercise
--         creator_id = auth.uid()
--     );
--
-- CREATE POLICY "Allow delete for exercise creator" ON base_exercise
--     FOR DELETE
--     TO authenticated
--     USING (
--         -- Requires adding creator_id column to base_exercise
--         creator_id = auth.uid()
--     );

-- ============================================================================
-- Grant Permissions for Views
-- ============================================================================

-- Grant SELECT on views to anon and authenticated roles
GRANT SELECT ON base_exercise_with_muscles TO anon;
GRANT SELECT ON base_exercise_with_muscles TO authenticated;

GRANT SELECT ON base_exercise_full TO anon;
GRANT SELECT ON base_exercise_full TO authenticated;

-- Grant SELECT on reference tables
GRANT SELECT ON muscle_group TO anon;
GRANT SELECT ON muscle_group TO authenticated;

GRANT SELECT ON equipment_type TO anon;
GRANT SELECT ON equipment_type TO authenticated;

GRANT SELECT ON exercise_category TO anon;
GRANT SELECT ON exercise_category TO authenticated;

-- Grant SELECT on base_exercise (through RLS policies)
GRANT SELECT ON base_exercise TO anon;
GRANT SELECT ON base_exercise TO authenticated;

-- Grant SELECT on junction tables (through RLS policies)
GRANT SELECT ON base_exercise_primary_muscle TO anon;
GRANT SELECT ON base_exercise_primary_muscle TO authenticated;

GRANT SELECT ON base_exercise_secondary_muscle TO anon;
GRANT SELECT ON base_exercise_secondary_muscle TO authenticated;

-- Grant EXECUTE on helper functions
GRANT EXECUTE ON FUNCTION find_exercises_by_muscle(text, boolean) TO anon;
GRANT EXECUTE ON FUNCTION find_exercises_by_muscle(text, boolean) TO authenticated;

GRANT EXECUTE ON FUNCTION get_exercise_metadata_stats() TO anon;
GRANT EXECUTE ON FUNCTION get_exercise_metadata_stats() TO authenticated;

-- Admin functions (not granted to public)
-- add_primary_muscle, add_secondary_muscle, set_exercise_muscles
-- These remain accessible only to service_role for data imports

COMMENT ON POLICY "Allow read access for all users" ON base_exercise_primary_muscle IS 
    'All users can read muscle-exercise relationships through views';

COMMENT ON POLICY "Allow read access for all users" ON base_exercise_secondary_muscle IS 
    'All users can read muscle-exercise relationships through views';

-- ============================================================================
-- Security Notes
-- ============================================================================

-- Current setup:
-- - All exercise data is read-only for regular users
-- - Only service_role can insert/update/delete exercises
-- - All users (including anonymous) can browse exercises
-- - Reference tables are fully locked down
--
-- Future enhancements:
-- - Add creator_id column to base_exercise for user ownership
-- - Modify policies to allow authenticated users to create exercises
-- - Add sharing/privacy settings (public/private exercises)
-- - Add admin role for managing shared exercise library
