-- Rollback: Enable RLS on Username Generation Tables
-- Description: Disable RLS and remove policies from username tables
-- WARNING: This rollback exposes internal tables via PostgREST API!
-- Only use if migration 271 causes critical issues

BEGIN;

-- ============================================================================
-- ROLLBACK: REMOVE POLICIES AND DISABLE RLS
-- ============================================================================

-- Drop blocking policies
DROP POLICY IF EXISTS "Block direct access to username_adjectives" ON username_adjectives;
DROP POLICY IF EXISTS "Block direct access to username_nouns" ON username_nouns;

-- Disable RLS
ALTER TABLE username_adjectives DISABLE ROW LEVEL SECURITY;
ALTER TABLE username_nouns DISABLE ROW LEVEL SECURITY;

-- Revert function to original (without search_path protection)
CREATE OR REPLACE FUNCTION generate_unique_username()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  selected_adjective text;
  selected_noun text;
  new_username text;
  username_exists boolean;
  attempt_count integer := 0;
  max_attempts integer := 5;
BEGIN
  LOOP
    SELECT word INTO selected_adjective
    FROM username_adjectives
    ORDER BY random()
    LIMIT 1;

    SELECT word INTO selected_noun
    FROM username_nouns
    ORDER BY random()
    LIMIT 1;

    new_username := selected_adjective || selected_noun;

    IF attempt_count > 0 THEN
      new_username := new_username || (10 + floor(random() * 9990))::text;
    END IF;

    SELECT EXISTS(SELECT 1 FROM app_user WHERE username = new_username)
    INTO username_exists;

    EXIT WHEN NOT username_exists;

    attempt_count := attempt_count + 1;

    IF attempt_count >= max_attempts THEN
      new_username := new_username || extract(epoch from now())::bigint::text;
      EXIT;
    END IF;
  END LOOP;

  RETURN new_username;
END;
$$;

COMMENT ON FUNCTION generate_unique_username IS
    '⚠️ ROLLBACK: Function without SECURITY DEFINER or search_path protection. '
    'This is the pre-migration state with security vulnerabilities.';

-- Update table comments
COMMENT ON TABLE username_adjectives IS
    '⚠️ ROLLBACK: Table WITHOUT RLS (exposed via PostgREST API). '
    'This is the pre-migration state with security vulnerability.';

COMMENT ON TABLE username_nouns IS
    '⚠️ ROLLBACK: Table WITHOUT RLS (exposed via PostgREST API). '
    'This is the pre-migration state with security vulnerability.';

COMMIT;
