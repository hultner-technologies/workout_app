-- Supabase Auth Integration: Auto-Profile Creation Trigger
--
-- This migration creates a database trigger that automatically creates an app_user
-- record when a new user signs up through Supabase Auth.
--
-- Flow:
--   1. User signs up via Supabase Auth (email/password or OAuth)
--   2. Record created in auth.users table
--   3. Trigger fires: on_auth_user_created
--   4. handle_new_user() function executes
--   5. app_user record created automatically
--
-- Features:
--   - Auto-generates username if not provided
--   - Uses username as default name if name not provided
--   - Handles race conditions with exception handling
--   - Uses SECURITY DEFINER to bypass RLS during insertion
--
-- Created: 2025-11-16
-- Author: Generated from SUPABASE_AUTH_INTEGRATION_PLAN.md

-- =============================================================================
-- TRIGGER FUNCTION: handle_new_user()
-- =============================================================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_username text;
  user_name text;
BEGIN
  -- Get username from metadata or generate Reddit-style username
  -- If user provides username in signup metadata, use it
  -- Otherwise, generate one like: SwoleRat, IronLifter, BuffBarbell
  user_username := COALESCE(
    NEW.raw_user_meta_data->>'username',
    generate_unique_username()
  );

  -- Get name from metadata, or use username as fallback
  -- This ensures name is never NULL
  user_name := COALESCE(
    NEW.raw_user_meta_data->>'name',
    user_username
  );

  -- Insert new app_user record
  -- app_user_id matches auth.users.id (foreign key)
  INSERT INTO app_user (app_user_id, name, email, username, data)
  VALUES (
    NEW.id,
    user_name,
    NEW.email,
    user_username,
    '{}'::jsonb
  );

  RETURN NEW;

EXCEPTION
  WHEN unique_violation THEN
    -- Handle edge case: username collision due to race condition
    -- This is extremely rare with 25k+ combinations, but we handle it gracefully
    -- Generate a new username and try again
    user_username := generate_unique_username();
    user_name := COALESCE(NEW.raw_user_meta_data->>'name', user_username);

    INSERT INTO app_user (app_user_id, name, email, username, data)
    VALUES (
      NEW.id,
      user_name,
      NEW.email,
      user_username,
      '{}'::jsonb
    );

    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION handle_new_user() IS
  'Trigger function that automatically creates an app_user record when a new user signs up via Supabase Auth. '
  'Pulls email and optional name/username from auth.users metadata. '
  'Auto-generates Reddit-style username (e.g., SwoleRat) if not provided. '
  'Uses SECURITY DEFINER to bypass RLS policies during user creation. '
  'Handles username collisions gracefully with exception handling.';

-- =============================================================================
-- CREATE TRIGGER: on_auth_user_created
-- =============================================================================

-- Drop existing trigger if it exists (for safe re-running of migration)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger that fires AFTER INSERT on auth.users
-- This ensures the auth.users record is fully created before we reference it
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

COMMENT ON TRIGGER on_auth_user_created ON auth.users IS
  'Automatically creates an app_user profile when a new user signs up. '
  'Fires after insertion into auth.users table. '
  'Calls handle_new_user() function to create the corresponding app_user record.';

-- =============================================================================
-- UPDATE RLS POLICY TO ALLOW TRIGGER-BASED INSERTS
-- =============================================================================

-- The current RLS policy blocks ALL inserts to app_user
-- We need to keep blocking direct client inserts, but allow the trigger to insert
-- Since the trigger uses SECURITY DEFINER, it bypasses RLS automatically
-- However, we update the policy for clarity and documentation

-- Drop the blanket "prevent insert" policy if it exists
DROP POLICY IF EXISTS "Prevent insert access app_user" ON public.app_user;

-- Create new policy that explicitly blocks client inserts
-- The trigger will bypass this due to SECURITY DEFINER
CREATE POLICY "Block direct client insert to app_user"
  ON public.app_user
  FOR INSERT
  TO authenticated, anon
  WITH CHECK (false);

COMMENT ON POLICY "Block direct client insert to app_user" ON public.app_user IS
  'Prevents direct client inserts to app_user table. '
  'User records must be created via the Supabase Auth signup flow, which triggers handle_new_user(). '
  'The trigger function uses SECURITY DEFINER to bypass this policy.';
