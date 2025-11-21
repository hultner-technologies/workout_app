-- Rollback: Fix Security Definer Views
-- Description: Revert views to default SECURITY DEFINER behavior (bypass RLS)
-- WARNING: This rollback removes security fix and exposes data!
-- Only use if migration 270 causes critical issues

BEGIN;

-- ============================================================================
-- ROLLBACK: REMOVE security_invoker FROM VIEWS
-- ============================================================================
-- This reverts views to SECURITY DEFINER (default) which bypasses RLS
-- WARNING: This exposes all data in views to all authenticated users!

-- Rollback exercise_schedule view
CREATE OR REPLACE VIEW exercise_schedule AS
SELECT * FROM exercise;

COMMENT ON VIEW exercise_schedule IS
    '⚠️ ROLLBACK: View WITHOUT security_invoker (bypasses RLS). '
    'This is the pre-migration state with security vulnerability.';

-- Rollback base_exercise_with_muscles view
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
    ec.name as category,
    ec.display_name as category_display,
    et.name as equipment,
    et.display_name as equipment_display,
    COALESCE(
        array_agg(DISTINCT pm.name ORDER BY pm.name) FILTER (WHERE pm.name IS NOT NULL),
        ARRAY[]::text[]
    ) as primary_muscles,
    COALESCE(
        array_agg(DISTINCT sm.name ORDER BY sm.name) FILTER (WHERE sm.name IS NOT NULL),
        ARRAY[]::text[]
    ) as secondary_muscles,
    be.instructions,
    be.image_urls,
    be.source_id,
    be.source_name,
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
    '⚠️ ROLLBACK: View WITHOUT security_invoker (bypasses RLS). '
    'This is the pre-migration state with security vulnerability.';

-- Rollback base_exercise_full view
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
    '⚠️ ROLLBACK: View WITHOUT security_invoker (bypasses RLS). '
    'This is the pre-migration state with security vulnerability.';

-- Rollback recent_impersonation_activity view
CREATE OR REPLACE VIEW recent_impersonation_activity AS
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
    '⚠️ ROLLBACK: View WITHOUT security_invoker (bypasses RLS). '
    'This is the pre-migration state with security vulnerability. '
    'All authenticated users can see impersonation activity!';

COMMIT;
