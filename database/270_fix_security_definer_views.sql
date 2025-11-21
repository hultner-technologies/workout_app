-- Migration: Fix Security Definer Views
-- Description: Add security_invoker=on to views to respect RLS policies
-- Issue: https://supabase.com/docs/guides/database/database-linter?lint=0010_security_definer_view
-- Created: 2025-11-21
-- Priority: ERROR level (Critical security issue)

-- ============================================================================
-- FIX SECURITY DEFINER VIEWS
-- ============================================================================
-- Issue: By default, PostgreSQL views are SECURITY DEFINER (bypass RLS)
-- Fix: Add WITH (security_invoker=on) to respect RLS on underlying tables
-- Result: Views now enforce RLS policies, protecting sensitive data

-- ============================================================================
-- EXERCISE SCHEDULE VIEW
-- ============================================================================
-- Public read access via RLS on underlying exercise table

CREATE OR REPLACE VIEW exercise_schedule
    WITH (security_invoker=on)
AS
SELECT * FROM exercise;

COMMENT ON VIEW exercise_schedule IS
    'Updateable view that mirrors the exercise table. '
    'Uses security_invoker=on to respect RLS policies on underlying exercise table. '
    'All authenticated users can view exercises per RLS policies.';

-- ============================================================================
-- BASE EXERCISE WITH MUSCLES VIEW
-- ============================================================================
-- Public read access via RLS on underlying tables

CREATE OR REPLACE VIEW base_exercise_with_muscles
    WITH (security_invoker=on)
AS
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

COMMENT ON VIEW base_exercise_with_muscles IS
    'Base exercises with aggregated muscle arrays for simple querying. '
    'Uses security_invoker=on to respect RLS policies on underlying tables. '
    'Public read access per RLS policies.';

-- ============================================================================
-- BASE EXERCISE FULL VIEW
-- ============================================================================
-- Public read access via RLS on underlying tables

CREATE OR REPLACE VIEW base_exercise_full
    WITH (security_invoker=on)
AS
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

COMMENT ON VIEW base_exercise_full IS
    'Base exercises with full metadata as JSON objects for frontend consumption. '
    'Uses security_invoker=on to respect RLS policies on underlying tables. '
    'Public read access per RLS policies.';

-- ============================================================================
-- RECENT IMPERSONATION ACTIVITY VIEW
-- ============================================================================
-- Admin-only access via RLS (is_admin() check)

CREATE OR REPLACE VIEW recent_impersonation_activity
    WITH (security_invoker=on)
AS
SELECT
    ia.audit_id,
    au_admin.username AS admin_username,
    au_admin.email AS admin_email,
    au_target.username AS target_username,
    au_target.email AS target_email,
    ia.started_at,
    ia.ended_at,
    EXTRACT(EPOCH FROM (COALESCE(ia.ended_at, now()) - ia.started_at)) / 60 AS duration_minutes,
    ia.ended_reason,
    ia.ended_at IS NULL AS is_active,
    (now() - ia.started_at) > interval '2 hours' AS should_timeout
FROM impersonation_audit ia
JOIN app_user au_admin ON ia.admin_user_id = au_admin.app_user_id
JOIN app_user au_target ON ia.target_user_id = au_target.app_user_id
WHERE ia.started_at > now() - interval '7 days'
ORDER BY ia.started_at DESC;

COMMENT ON VIEW recent_impersonation_activity IS
    'Impersonation activity in last 7 days for monitoring and reporting. '
    'Uses security_invoker=on to respect RLS - only admins can query via is_admin() policy on impersonation_audit table. '
    'Non-admin users will see zero rows due to RLS enforcement.';

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- All views now have security_invoker=on and will respect RLS policies
-- Non-breaking change: RLS policies already exist on underlying tables
-- Exercise views: Public read access (intended behavior)
-- Impersonation view: Admin-only access (intended behavior)
