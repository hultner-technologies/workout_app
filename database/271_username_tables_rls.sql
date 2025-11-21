-- Migration: Enable RLS on Username Generation Tables
-- Description: Enable RLS with blocking policies on internal-only tables
-- Issue: https://supabase.com/docs/guides/database/database-linter?lint=0013_rls_disabled_in_public
-- Created: 2025-11-21
-- Priority: ERROR level (Critical security issue)

-- ============================================================================
-- ENABLE RLS ON USERNAME GENERATION TABLES
-- ============================================================================
-- Issue: username_adjectives and username_nouns exposed via PostgREST without RLS
-- Risk: Internal data tables shouldn't be directly accessible via API
-- Fix: Enable RLS with blocking policies (function access preserved via SECURITY DEFINER)
-- Result: Tables blocked from direct API access, function still works

-- ============================================================================
-- ENABLE RLS
-- ============================================================================

ALTER TABLE username_adjectives ENABLE ROW LEVEL SECURITY;
ALTER TABLE username_nouns ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- CREATE BLOCKING POLICIES
-- ============================================================================
-- Block direct access from all roles (internal-only tables)
-- The generate_unique_username() function can still access them via SECURITY DEFINER

CREATE POLICY "Block direct access to username_adjectives"
    ON username_adjectives
    FOR ALL
    TO public
    USING (false)
    WITH CHECK (false);

COMMENT ON POLICY "Block direct access to username_adjectives" ON username_adjectives IS
    'Internal-only table for username generation. '
    'Direct API access blocked. Function access preserved via SECURITY DEFINER.';

CREATE POLICY "Block direct access to username_nouns"
    ON username_nouns
    FOR ALL
    TO public
    USING (false)
    WITH CHECK (false);

COMMENT ON POLICY "Block direct access to username_nouns" ON username_nouns IS
    'Internal-only table for username generation. '
    'Direct API access blocked. Function access preserved via SECURITY DEFINER.';

-- ============================================================================
-- UPDATE FUNCTION WITH SECURITY DEFINER AND SEARCH PATH
-- ============================================================================
-- Ensure generate_unique_username is SECURITY DEFINER (should already be)
-- Add search_path protection (defense-in-depth)
-- This allows the function to bypass RLS and access the tables

CREATE OR REPLACE FUNCTION generate_unique_username()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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
    -- Select random adjective and noun from tables (SECURITY DEFINER bypasses RLS)
    SELECT word INTO selected_adjective
    FROM username_adjectives
    ORDER BY random()
    LIMIT 1;

    SELECT word INTO selected_noun
    FROM username_nouns
    ORDER BY random()
    LIMIT 1;

    -- Generate AdjectiveNoun combination (e.g., SwoleRat, IronLifter)
    new_username := selected_adjective || selected_noun;

    -- Add random 2-4 digit number if we've had collisions
    IF attempt_count > 0 THEN
      new_username := new_username || (10 + floor(random() * 9990))::text;
    END IF;

    -- Check if username already exists in app_user
    SELECT EXISTS(SELECT 1 FROM app_user WHERE username = new_username)
    INTO username_exists;

    -- Exit loop if username is unique
    EXIT WHEN NOT username_exists;

    attempt_count := attempt_count + 1;

    -- Safety check: prevent infinite loop
    -- After 5 attempts, guarantee uniqueness with timestamp
    IF attempt_count >= max_attempts THEN
      new_username := new_username || extract(epoch from now())::bigint::text;
      EXIT;
    END IF;
  END LOOP;

  RETURN new_username;
END;
$$;

COMMENT ON FUNCTION generate_unique_username() IS
    'Generates unique Reddit-style username using AdjectiveNoun pattern. '
    'Examples: SwoleRat, IronLifter, BuffBarbell, MightyBeast. '
    'SECURITY DEFINER allows bypassing RLS on username tables. '
    'SET search_path protects against search_path hijacking attacks. '
    'Namespace: 140 adjectives × 182 nouns = 25,480 base combinations.';

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- RLS is now enabled on username tables
-- Direct access via PostgREST is blocked (RLS policies return false)
-- generate_unique_username() still works (SECURITY DEFINER bypasses RLS)
-- Non-breaking change: Users never needed direct access to these tables
