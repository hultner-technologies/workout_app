-- Post-Seed Auth Synchronization Script
--
-- Run this AFTER loading production seed data to sync app_user with auth.users
-- This is a one-time migration helper for production deployment
--
-- Usage:
--   After running migrations and loading seed:
--   psql $DATABASE_URL < database/post_seed_auth_sync.sql

BEGIN;

-- Create auth.users entries for seed data users
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
  crypt('SEED_USER_' || gen_random_uuid()::text, gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  'authenticated',
  'authenticated',
  jsonb_build_object('username', username, 'name', name, 'seed_data', true)
FROM app_user
WHERE NOT EXISTS (
  SELECT 1 FROM auth.users WHERE auth.users.id = app_user.app_user_id
)
ON CONFLICT (id) DO NOTHING;

-- Now add the FK constraint if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'app_user_id_fkey'
  ) THEN
    ALTER TABLE app_user
      ADD CONSTRAINT app_user_id_fkey
      FOREIGN KEY (app_user_id)
      REFERENCES auth.users(id)
      ON DELETE CASCADE;

    RAISE NOTICE '✓ Foreign key constraint added';
  ELSE
    RAISE NOTICE '✓ Foreign key constraint already exists';
  END IF;
END $$;

-- Verify sync
DO $$
DECLARE
  v_app_user_count int;
  v_auth_user_count int;
  v_orphaned_count int;
BEGIN
  SELECT COUNT(*) INTO v_app_user_count FROM app_user;

  SELECT COUNT(*) INTO v_auth_user_count
  FROM app_user au
  JOIN auth.users u ON au.app_user_id = u.id;

  v_orphaned_count := v_app_user_count - v_auth_user_count;

  RAISE NOTICE '============================================';
  RAISE NOTICE 'Auth Synchronization Complete';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Total app_user records: %', v_app_user_count;
  RAISE NOTICE 'Synced with auth.users: %', v_auth_user_count;
  RAISE NOTICE 'Orphaned records: %', v_orphaned_count;

  IF v_orphaned_count > 0 THEN
    RAISE EXCEPTION 'Found % orphaned app_user records without auth.users entries', v_orphaned_count;
  END IF;

  RAISE NOTICE '✓ All app_user records have auth.users entries';
  RAISE NOTICE '============================================';
END $$;

COMMIT;
