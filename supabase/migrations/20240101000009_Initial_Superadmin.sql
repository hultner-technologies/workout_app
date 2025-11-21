-- Initial Superadmin Setup
--
-- Creates the initial superadmin user for production deployment.
-- This migration is idempotent and safe to run multiple times.
--
-- IMPORTANT: Configure these via environment variables or SQL parameters:
--   - SUPERADMIN_USER_ID: UUID for the initial superadmin
--   - SUPERADMIN_EMAIL: Email address
--   - SUPERADMIN_USERNAME: Username
--   - SUPERADMIN_NAME: Display name
--
-- For local development, defaults are used (customize in .env.local)
--
-- Created: 2025-11-17

-- Use environment variables if available, otherwise use safe defaults
-- In production, set these via Supabase secrets or environment config
DO $$
DECLARE
  v_user_id uuid;
  v_email text;
  v_username text;
  v_name text;
  v_is_admin boolean;
  v_role text;
BEGIN
  -- Get configuration from environment or use defaults
  -- Production: Set these in Supabase Dashboard > Settings > Secrets
  v_user_id := COALESCE(
    current_setting('app.superadmin_user_id', true)::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid  -- Default for dev
  );
  v_email := COALESCE(
    current_setting('app.superadmin_email', true),
    'superadmin@localhost'  -- Default for dev (avoids test conflicts)
  );
  v_username := COALESCE(
    current_setting('app.superadmin_username', true),
    'superadmin'  -- Default for dev
  );
  v_name := COALESCE(
    current_setting('app.superadmin_name', true),
    'System Administrator'  -- Default for dev
  );

  -- Step 1: Ensure app_user entry exists FIRST (before auth.users trigger fires)
  INSERT INTO app_user (
    app_user_id,
    name,
    email,
    username,
    data
  )
  VALUES (
    v_user_id,
    v_name,
    v_email,
    v_username,
    NULL
  )
  ON CONFLICT (app_user_id) DO UPDATE SET
    username = EXCLUDED.username,
    email = EXCLUDED.email,
    name = EXCLUDED.name;

  -- Step 2: Ensure auth.users entry exists
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    aud,
    role,
    raw_user_meta_data
  )
  VALUES (
    v_user_id,
    '00000000-0000-0000-0000-000000000000'::uuid,
    v_email,
    extensions.crypt('TEMP_PASSWORD_' || gen_random_uuid()::text, extensions.gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    'authenticated',
    'authenticated',
    jsonb_build_object('username', v_username, 'name', v_name)
  )
  ON CONFLICT (id) DO UPDATE SET
    raw_user_meta_data = jsonb_build_object('username', EXCLUDED.raw_user_meta_data->>'username', 'name', EXCLUDED.raw_user_meta_data->>'name'),
    email = EXCLUDED.email;

  -- Step 3: Grant superadmin role
  INSERT INTO admin_users (
    admin_user_id,
    role,
    granted_at,
    notes
  )
  VALUES (
    v_user_id,
    'superadmin',
    NOW(),
    'Initial superadmin created by migration'
  )
  ON CONFLICT (admin_user_id) DO UPDATE SET
    role = 'superadmin',
    revoked_at = NULL,
    notes = 'Initial superadmin created by migration';

  -- Verify setup
  v_is_admin := is_admin(v_user_id);
  v_role := get_admin_role(v_user_id);

  IF NOT v_is_admin OR v_role != 'superadmin' THEN
    RAISE EXCEPTION 'Superadmin setup verification failed';
  END IF;

  RAISE NOTICE '✓ Superadmin setup complete';
  RAISE NOTICE '  Username: %', v_username;
  RAISE NOTICE '  Email: %', v_email;
  RAISE NOTICE '  Role: superadmin';
  RAISE NOTICE '  Action: Reset password via Supabase Dashboard';
END $$;
