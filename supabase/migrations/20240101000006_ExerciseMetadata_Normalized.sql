-- Exercise Metadata Enhancement Migration - NORMALIZED VERSION
-- This migration adds rich exercise metadata with full normalization
-- Views provide simple array/JSON access for application layer
-- All new columns/tables support backward compatibility

-- ============================================================================
-- Reference Tables for Exercise Metadata
-- ============================================================================

-- Muscle groups reference table
CREATE TABLE IF NOT EXISTS muscle_group (
    muscle_group_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY,
    name text UNIQUE NOT NULL,
    display_name text NOT NULL,
    description text,
    created_at timestamptz DEFAULT now()
);

COMMENT ON TABLE muscle_group IS 'Reference table for all muscle groups that can be targeted by exercises';
COMMENT ON COLUMN muscle_group.name IS 'Internal identifier (lowercase, underscore-separated)';
COMMENT ON COLUMN muscle_group.display_name IS 'User-facing display name';

-- Equipment types reference table
CREATE TABLE IF NOT EXISTS equipment_type (
    equipment_type_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY,
    name text UNIQUE NOT NULL,
    display_name text NOT NULL,
    description text,
    created_at timestamptz DEFAULT now()
);

COMMENT ON TABLE equipment_type IS 'Reference table for all types of equipment used in exercises';

-- Exercise categories reference table
CREATE TABLE IF NOT EXISTS exercise_category (
    category_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY,
    name text UNIQUE NOT NULL,
    display_name text NOT NULL,
    description text,
    created_at timestamptz DEFAULT now()
);

COMMENT ON TABLE exercise_category IS 'Reference table for exercise categories (strength, cardio, stretching, etc.)';

-- ============================================================================
-- Enhanced base_exercise table (normalized foreign keys)
-- ============================================================================

-- Add new columns to base_exercise (all nullable for backward compatibility)
ALTER TABLE base_exercise 
    ADD COLUMN IF NOT EXISTS level text,
    ADD COLUMN IF NOT EXISTS mechanic text,
    ADD COLUMN IF NOT EXISTS force text,
    ADD COLUMN IF NOT EXISTS category_id uuid REFERENCES exercise_category(category_id),
    ADD COLUMN IF NOT EXISTS equipment_type_id uuid REFERENCES equipment_type(equipment_type_id),
    ADD COLUMN IF NOT EXISTS instructions text[],
    ADD COLUMN IF NOT EXISTS image_urls text[],
    ADD COLUMN IF NOT EXISTS source_id text,
    ADD COLUMN IF NOT EXISTS source_name text,
    ADD COLUMN IF NOT EXISTS extended_data jsonb;

-- Add constraints for known enum values
ALTER TABLE base_exercise 
    DROP CONSTRAINT IF EXISTS base_exercise_level_check,
    ADD CONSTRAINT base_exercise_level_check 
        CHECK (level IS NULL OR level IN ('beginner', 'intermediate', 'expert'));

ALTER TABLE base_exercise 
    DROP CONSTRAINT IF EXISTS base_exercise_mechanic_check,
    ADD CONSTRAINT base_exercise_mechanic_check 
        CHECK (mechanic IS NULL OR mechanic IN ('isolation', 'compound'));

ALTER TABLE base_exercise 
    DROP CONSTRAINT IF EXISTS base_exercise_force_check,
    ADD CONSTRAINT base_exercise_force_check 
        CHECK (force IS NULL OR force IN ('push', 'pull', 'static'));

-- Add comments for documentation
COMMENT ON COLUMN base_exercise.level IS 'Difficulty level: beginner, intermediate, or expert (nullable for user-generated exercises)';
COMMENT ON COLUMN base_exercise.mechanic IS 'Movement type: isolation or compound (nullable)';
COMMENT ON COLUMN base_exercise.force IS 'Force direction: push, pull, or static (nullable)';
COMMENT ON COLUMN base_exercise.category_id IS 'Exercise category FK (strength, cardio, stretching, etc.)';
COMMENT ON COLUMN base_exercise.equipment_type_id IS 'Required equipment type FK';
COMMENT ON COLUMN base_exercise.instructions IS 'Step-by-step instructions array';
COMMENT ON COLUMN base_exercise.image_urls IS 'Array of image URLs for exercise demonstration';
COMMENT ON COLUMN base_exercise.source_id IS 'Original ID from source database (for tracking imports)';
COMMENT ON COLUMN base_exercise.source_name IS 'Source database name (e.g., "free-exercise-db")';
COMMENT ON COLUMN base_exercise.extended_data IS 'Additional flexible data for future extensions';

-- ============================================================================
-- Junction Tables for Many-to-Many Relationships
-- ============================================================================

-- Primary muscles targeted by exercise
CREATE TABLE IF NOT EXISTS base_exercise_primary_muscle (
    base_exercise_id uuid REFERENCES base_exercise(base_exercise_id) ON DELETE CASCADE,
    muscle_group_id uuid REFERENCES muscle_group(muscle_group_id) ON DELETE CASCADE,
    sort_order int DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    PRIMARY KEY (base_exercise_id, muscle_group_id)
);

COMMENT ON TABLE base_exercise_primary_muscle IS 'Primary muscle groups targeted by each exercise';
COMMENT ON COLUMN base_exercise_primary_muscle.sort_order IS 'Order of importance (0 = most important)';

-- Secondary muscles engaged by exercise
CREATE TABLE IF NOT EXISTS base_exercise_secondary_muscle (
    base_exercise_id uuid REFERENCES base_exercise(base_exercise_id) ON DELETE CASCADE,
    muscle_group_id uuid REFERENCES muscle_group(muscle_group_id) ON DELETE CASCADE,
    sort_order int DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    PRIMARY KEY (base_exercise_id, muscle_group_id)
);

COMMENT ON TABLE base_exercise_secondary_muscle IS 'Secondary muscle groups engaged by each exercise';

-- ============================================================================
-- Indexes for efficient querying
-- ============================================================================

-- Indexes on base_exercise foreign keys
CREATE INDEX IF NOT EXISTS idx_base_exercise_category_id 
    ON base_exercise (category_id) WHERE category_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_base_exercise_equipment_type_id 
    ON base_exercise (equipment_type_id) WHERE equipment_type_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_base_exercise_level 
    ON base_exercise (level) WHERE level IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_base_exercise_source 
    ON base_exercise (source_name, source_id) WHERE source_name IS NOT NULL;

-- Indexes on junction tables
CREATE INDEX IF NOT EXISTS idx_base_exercise_primary_muscle_exercise 
    ON base_exercise_primary_muscle (base_exercise_id);

CREATE INDEX IF NOT EXISTS idx_base_exercise_primary_muscle_muscle 
    ON base_exercise_primary_muscle (muscle_group_id);

CREATE INDEX IF NOT EXISTS idx_base_exercise_secondary_muscle_exercise 
    ON base_exercise_secondary_muscle (base_exercise_id);

CREATE INDEX IF NOT EXISTS idx_base_exercise_secondary_muscle_muscle 
    ON base_exercise_secondary_muscle (muscle_group_id);

-- Full text search helper function
-- PostgreSQL requires functions used in index expressions to be marked IMMUTABLE.
-- This guarantees that the same input always produces the same output, which is
-- necessary for index consistency. We create this wrapper function to make the
-- text search vector generation IMMUTABLE and PARALLEL SAFE.
CREATE OR REPLACE FUNCTION base_exercise_searchable(base_exercise)
RETURNS tsvector
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
AS $$
    SELECT to_tsvector('english',
        $1.name || ' ' || COALESCE(array_to_string($1.aliases, ' '), '')
    )
$$;

COMMENT ON FUNCTION base_exercise_searchable(base_exercise) IS
    'Generates a full-text search vector for base_exercise by combining name and aliases. '
    'Marked IMMUTABLE for use in GIN indexes. PARALLEL SAFE for query optimization.';

-- Full text search index on name and aliases
-- Uses the IMMUTABLE function above to allow indexing on the combined search text
CREATE INDEX IF NOT EXISTS idx_base_exercise_search
    ON base_exercise USING GIN (base_exercise_searchable(base_exercise.*));

-- ============================================================================
-- Aggregated Views for Simple Querying
-- ============================================================================

-- Main view: base_exercise with aggregated muscles as arrays
CREATE OR REPLACE VIEW base_exercise_with_muscles AS
SELECT 
    be.base_exercise_id,
    be.name,
    be.aliases,
    be.description,
    be.links,
    be.level,
    be.mechanic,
    be.force,
    
    -- Category (denormalized for convenience)
    ec.name as category,
    ec.display_name as category_display,
    
    -- Equipment (denormalized for convenience)
    et.name as equipment,
    et.display_name as equipment_display,
    
    -- Primary muscles as array
    COALESCE(
        array_agg(DISTINCT pm.name ORDER BY pm.name) FILTER (WHERE pm.name IS NOT NULL),
        ARRAY[]::text[]
    ) as primary_muscles,
    
    -- Secondary muscles as array
    COALESCE(
        array_agg(DISTINCT sm.name ORDER BY sm.name) FILTER (WHERE sm.name IS NOT NULL),
        ARRAY[]::text[]
    ) as secondary_muscles,
    
    -- Instructions and images
    be.instructions,
    be.image_urls,
    
    -- Source tracking
    be.source_id,
    be.source_name,
    
    -- Original data fields
    be.data,
    be.extended_data
    
FROM base_exercise be
LEFT JOIN exercise_category ec ON be.category_id = ec.category_id
LEFT JOIN equipment_type et ON be.equipment_type_id = et.equipment_type_id
LEFT JOIN base_exercise_primary_muscle bepm ON be.base_exercise_id = bepm.base_exercise_id
LEFT JOIN muscle_group pm ON bepm.muscle_group_id = pm.muscle_group_id
LEFT JOIN base_exercise_secondary_muscle besm ON be.base_exercise_id = besm.base_exercise_id
LEFT JOIN muscle_group sm ON besm.muscle_group_id = sm.muscle_group_id
GROUP BY 
    be.base_exercise_id,
    be.name,
    be.aliases,
    be.description,
    be.links,
    be.level,
    be.mechanic,
    be.force,
    ec.name,
    ec.display_name,
    et.name,
    et.display_name,
    be.instructions,
    be.image_urls,
    be.source_id,
    be.source_name,
    be.data,
    be.extended_data;

COMMENT ON VIEW base_exercise_with_muscles IS 'Base exercises with aggregated muscle arrays for simple querying';

-- Enhanced view: base_exercise with full metadata as JSON
CREATE OR REPLACE VIEW base_exercise_full AS
SELECT 
    be.base_exercise_id,
    be.name,
    be.aliases,
    be.description,
    be.links,
    be.level,
    be.mechanic,
    be.force,
    be.instructions,
    be.image_urls,
    be.source_id,
    be.source_name,
    
    -- Category as JSON object
    CASE 
        WHEN ec.category_id IS NOT NULL THEN
            jsonb_build_object(
                'id', ec.category_id,
                'name', ec.name,
                'display_name', ec.display_name,
                'description', ec.description
            )
        ELSE NULL
    END as category,
    
    -- Equipment as JSON object
    CASE 
        WHEN et.equipment_type_id IS NOT NULL THEN
            jsonb_build_object(
                'id', et.equipment_type_id,
                'name', et.name,
                'display_name', et.display_name,
                'description', et.description
            )
        ELSE NULL
    END as equipment,
    
    -- Primary muscles as JSON array of objects
    COALESCE(
        jsonb_agg(DISTINCT jsonb_build_object(
            'id', pm.muscle_group_id,
            'name', pm.name,
            'display_name', pm.display_name,
            'description', pm.description
        ) ORDER BY jsonb_build_object(
            'id', pm.muscle_group_id,
            'name', pm.name,
            'display_name', pm.display_name,
            'description', pm.description
        )) FILTER (WHERE pm.muscle_group_id IS NOT NULL),
        '[]'::jsonb
    ) as primary_muscles,
    
    -- Secondary muscles as JSON array of objects
    COALESCE(
        jsonb_agg(DISTINCT jsonb_build_object(
            'id', sm.muscle_group_id,
            'name', sm.name,
            'display_name', sm.display_name,
            'description', sm.description
        ) ORDER BY jsonb_build_object(
            'id', sm.muscle_group_id,
            'name', sm.name,
            'display_name', sm.display_name,
            'description', sm.description
        )) FILTER (WHERE sm.muscle_group_id IS NOT NULL),
        '[]'::jsonb
    ) as secondary_muscles,
    
    -- Original data fields
    be.data,
    be.extended_data
    
FROM base_exercise be
LEFT JOIN exercise_category ec ON be.category_id = ec.category_id
LEFT JOIN equipment_type et ON be.equipment_type_id = et.equipment_type_id
LEFT JOIN base_exercise_primary_muscle bepm ON be.base_exercise_id = bepm.base_exercise_id
LEFT JOIN muscle_group pm ON bepm.muscle_group_id = pm.muscle_group_id
LEFT JOIN base_exercise_secondary_muscle besm ON be.base_exercise_id = besm.base_exercise_id
LEFT JOIN muscle_group sm ON besm.muscle_group_id = sm.muscle_group_id
GROUP BY 
    be.base_exercise_id,
    be.name,
    be.aliases,
    be.description,
    be.links,
    be.level,
    be.mechanic,
    be.force,
    be.instructions,
    be.image_urls,
    be.source_id,
    be.source_name,
    be.data,
    be.extended_data,
    ec.category_id,
    ec.name,
    ec.display_name,
    ec.description,
    et.equipment_type_id,
    et.name,
    et.display_name,
    et.description;

COMMENT ON VIEW base_exercise_full IS 'Base exercises with full metadata as JSON objects for frontend consumption';

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Function to find exercises by muscle group (uses normalized tables)
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
) AS $$
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
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION find_exercises_by_muscle IS 'Find exercises that target a specific muscle group (uses normalized tables)';

-- Function to add primary muscle to exercise
CREATE OR REPLACE FUNCTION add_primary_muscle(
    p_base_exercise_id uuid,
    p_muscle_name text,
    p_sort_order int DEFAULT 0
)
RETURNS void AS $$
DECLARE
    v_muscle_id uuid;
BEGIN
    -- Get muscle_group_id
    SELECT muscle_group_id INTO v_muscle_id
    FROM muscle_group
    WHERE name = p_muscle_name;
    
    IF v_muscle_id IS NULL THEN
        RAISE EXCEPTION 'Muscle group % not found', p_muscle_name;
    END IF;
    
    -- Insert or update
    INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
    VALUES (p_base_exercise_id, v_muscle_id, p_sort_order)
    ON CONFLICT (base_exercise_id, muscle_group_id) 
    DO UPDATE SET sort_order = p_sort_order;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION add_primary_muscle IS 'Add a primary muscle to an exercise';

-- Function to add secondary muscle to exercise
CREATE OR REPLACE FUNCTION add_secondary_muscle(
    p_base_exercise_id uuid,
    p_muscle_name text,
    p_sort_order int DEFAULT 0
)
RETURNS void AS $$
DECLARE
    v_muscle_id uuid;
BEGIN
    -- Get muscle_group_id
    SELECT muscle_group_id INTO v_muscle_id
    FROM muscle_group
    WHERE name = p_muscle_name;
    
    IF v_muscle_id IS NULL THEN
        RAISE EXCEPTION 'Muscle group % not found', p_muscle_name;
    END IF;
    
    -- Insert or update
    INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
    VALUES (p_base_exercise_id, v_muscle_id, p_sort_order)
    ON CONFLICT (base_exercise_id, muscle_group_id) 
    DO UPDATE SET sort_order = p_sort_order;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION add_secondary_muscle IS 'Add a secondary muscle to an exercise';

-- Function to set muscles from arrays (for easy import)
CREATE OR REPLACE FUNCTION set_exercise_muscles(
    p_base_exercise_id uuid,
    p_primary_muscles text[],
    p_secondary_muscles text[]
)
RETURNS void AS $$
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
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION set_exercise_muscles IS 'Set all muscles for an exercise from arrays (replaces existing)';

-- Function to get exercise statistics
CREATE OR REPLACE FUNCTION get_exercise_metadata_stats()
RETURNS TABLE (
    total_exercises bigint,
    exercises_with_muscles bigint,
    exercises_with_instructions bigint,
    exercises_with_images bigint,
    exercises_by_level jsonb,
    exercises_by_category jsonb,
    exercises_by_equipment jsonb
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(DISTINCT be.base_exercise_id)::bigint as total_exercises,
        COUNT(DISTINCT CASE WHEN bepm.base_exercise_id IS NOT NULL THEN be.base_exercise_id END)::bigint as exercises_with_muscles,
        COUNT(CASE WHEN be.instructions IS NOT NULL THEN 1 END)::bigint as exercises_with_instructions,
        COUNT(CASE WHEN be.image_urls IS NOT NULL THEN 1 END)::bigint as exercises_with_images,
        
        -- Exercises by level
        (SELECT jsonb_object_agg(COALESCE(l.level, 'unspecified'), l.count)
         FROM (SELECT level, COUNT(*) as count FROM base_exercise GROUP BY level) l
        ) as exercises_by_level,
        
        -- Exercises by category
        (SELECT jsonb_object_agg(COALESCE(ec.name, 'unspecified'), bc.count)
         FROM (
             SELECT category_id, COUNT(*) as count 
             FROM base_exercise 
             GROUP BY category_id
         ) bc
         LEFT JOIN exercise_category ec ON bc.category_id = ec.category_id
        ) as exercises_by_category,
        
        -- Exercises by equipment
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
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_exercise_metadata_stats IS 'Get comprehensive statistics about exercise metadata';
