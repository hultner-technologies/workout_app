-- Rollback: Secure Session Creation Functions
-- Description: Revert session functions to original versions without validation
-- WARNING: This rollback removes security validation!
-- Only use if migration 272 causes critical issues

BEGIN;

-- ============================================================================
-- ROLLBACK: REMOVE VALIDATION FROM FUNCTIONS
-- ============================================================================

-- Revert create_session_from_name to original
CREATE OR REPLACE FUNCTION create_session_from_name(
    schedule_name text,
    app_user_id uuid DEFAULT '65585c04-0525-11ed-9a8f-0bd67a64ac86'::uuid
)
RETURNS TABLE("like" performed_session)
LANGUAGE sql
SET search_path = 'public'
AS $$
    INSERT INTO performed_session (session_schedule_id, app_user_id)
    VALUES (
        (SELECT ss.session_schedule_id FROM session_schedule ss WHERE ss.name = schedule_name),
        app_user_id
    )
    RETURNING *;
$$;

COMMENT ON FUNCTION create_session_from_name IS
    '⚠️ ROLLBACK: Function WITHOUT auth.uid() validation. '
    'This is the pre-migration state - authenticated users could specify any user_id.';

-- Revert create_full_session to original
CREATE OR REPLACE FUNCTION create_full_session(
    schedule_name text,
    app_user_id uuid DEFAULT '65585c04-0525-11ed-9a8f-0bd67a64ac86'::uuid
)
RETURNS TABLE("like" performed_exercise)
LANGUAGE sql
SET search_path = 'public'
AS $$
    SELECT * FROM create_session_exercises(
        (SELECT performed_session_id FROM create_session_from_name(schedule_name, app_user_id))
    );
$$;

COMMENT ON FUNCTION create_full_session IS
    '⚠️ ROLLBACK: Function WITHOUT auth.uid() validation. '
    'This is the pre-migration state - authenticated users could specify any user_id.';

-- Revert create_session_exercises to original (without SECURITY DEFINER)
CREATE OR REPLACE FUNCTION create_session_exercises(performed_session_id_ uuid)
RETURNS TABLE ("like" performed_exercise)
LANGUAGE sql
SET search_path = 'public'
AS $$
    INSERT INTO performed_exercise (exercise_id, performed_session_id, name, reps, rest, weight)
    SELECT * FROM draft_session_exercises(performed_session_id_)
    RETURNING *;
$$;

COMMENT ON FUNCTION create_session_exercises IS
    '⚠️ ROLLBACK: Function WITHOUT SECURITY DEFINER. '
    'This is the pre-migration state.';

-- Drop convenience functions (they didn't exist before migration)
DROP FUNCTION IF EXISTS create_my_session_from_name(text);
DROP FUNCTION IF EXISTS create_my_full_session(text);

COMMIT;
