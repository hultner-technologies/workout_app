-- Placeholder Migration: Auth Sync Deferred
--
-- NOTE: This migration is intentionally minimal because:
-- 1. Seed data loads AFTER migrations complete
-- 2. Cannot create auth.users entries for seed data that doesn't exist yet
-- 3. Cannot add FK constraint when seed will insert app_user without auth.users
--
-- SOLUTION:
-- - For production: Existing app_users already have data, auth.users created by migration 028
-- - For local dev with seed: Run database/post_seed_auth_sync.sql AFTER seed loads
--
-- The real sync logic is in:
-- - Production: Migration 028 handles existing users
-- - Dev/Testing: database/post_seed_auth_sync.sql (manual step after seed)
--
-- Created: 2025-11-17
-- Updated: 2025-11-17 - Changed to placeholder, moved logic to post_seed script

-- For production deployments with existing data:
-- Create auth.users for any app_user that doesn't have one
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
SELECT
  app_user_id,
  '00000000-0000-0000-0000-000000000000'::uuid,
  email,
  extensions.crypt('PRODUCTION_MIGRATED_' || gen_random_uuid()::text, extensions.gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  'authenticated',
  'authenticated',
  jsonb_build_object('username', username, 'name', name, 'production_migration', true)
FROM app_user
WHERE NOT EXISTS (
  SELECT 1 FROM auth.users WHERE auth.users.id = app_user.app_user_id
)
ON CONFLICT (id) DO NOTHING;

-- DO NOT add FK constraint here - seed hasn't loaded yet!
-- For all scenarios, FK is added by database/post_seed_auth_sync.sql after seed
DO $$
BEGIN
  RAISE NOTICE 'ℹ FK constraint deferred to post_seed_auth_sync.sql (runs after seed data)';
  RAISE NOTICE 'ℹ For production: Run post_seed script or FK will be added on first user signup';
END $$;

-- Add comment only if constraint exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'app_user_id_fkey') THEN
    EXECUTE 'COMMENT ON CONSTRAINT app_user_id_fkey ON app_user IS ' ||
      quote_literal('Foreign key to auth.users. Ensures app_user records are always linked to valid Supabase Auth users. CASCADE delete ensures orphaned records are automatically cleaned up.');
  END IF;
END $$;
