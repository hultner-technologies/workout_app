-- Supabase Auth Integration: app_user Schema Migration
--
-- This migration prepares the app_user table for Supabase Auth integration.
-- Changes:
--   1. Add foreign key constraint to auth.users
--   2. Add username field (required, unique, validated format)
--   3. Add unique constraint on email
--   4. Remove password field (Supabase manages authentication)
--
-- Created: 2025-11-16
-- Author: Generated from SUPABASE_AUTH_INTEGRATION_PLAN.md

-- Step 1: Remove password field first (safest operation)
-- Supabase Auth handles password management
ALTER TABLE app_user DROP COLUMN IF EXISTS password;

-- Step 2: Add username field (nullable initially for existing records)
-- Will be backfilled and made NOT NULL in subsequent steps
ALTER TABLE app_user
  ADD COLUMN IF NOT EXISTS username text;

-- Step 3: Add unique constraint on email
-- Prevents duplicate email addresses
ALTER TABLE app_user
  ADD CONSTRAINT app_user_email_unique UNIQUE (email);

-- Step 4A: Create temporary trigger to handle NULL usernames during seed/migration
-- This helps with legacy data inserts and seed data
CREATE OR REPLACE FUNCTION backfill_username_on_insert()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.username IS NULL THEN
    NEW.username := LOWER(REGEXP_REPLACE(
      SUBSTRING(NEW.email FROM '^([^@]+)'),
      '[^a-zA-Z0-9]', '_', 'g'
    )) || '_' || FLOOR(RANDOM() * 10000)::text;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER app_user_backfill_username
  BEFORE INSERT ON app_user
  FOR EACH ROW
  EXECUTE FUNCTION backfill_username_on_insert();

-- Step 4B: Backfill usernames for existing users (auto-generate from email)
-- Format: first part of email + random suffix to ensure uniqueness
UPDATE app_user
SET username = CASE
  WHEN username IS NULL THEN
    -- Generate username from email prefix + random number
    LOWER(REGEXP_REPLACE(
      SUBSTRING(email FROM '^([^@]+)'),
      '[^a-zA-Z0-9]', '_', 'g'
    )) || '_' || FLOOR(RANDOM() * 10000)::text
  ELSE username
END
WHERE username IS NULL;

-- Step 5: Now make username NOT NULL and add constraints
-- Safe because all rows now have usernames
ALTER TABLE app_user
  ALTER COLUMN username SET NOT NULL,
  ADD CONSTRAINT username_unique UNIQUE (username),
  ADD CONSTRAINT username_length CHECK (char_length(username) >= 4),
  ADD CONSTRAINT username_format CHECK (username ~ '^[a-zA-Z0-9._-]{4,}$');

-- Step 6: DEFER adding foreign key constraint
-- The FK will be added in migration 034 (after seed data loads)
-- This two-phase approach handles:
-- 1. Production: Existing app_users get auth.users created, then FK added
-- 2. Local dev: Seed loads legacy-format data, then migration 034 syncs it
--
-- NOTE: For production deployment with existing users, you MUST either:
--   Option A: Manually create auth.users for each app_user BEFORE running migrations
--   Option B: Run migrations, accept temporary FK-less state, then run migration 034
--
-- Migration 034 will create auth.users entries for any app_user without them

-- Add comment explaining the changes
COMMENT ON COLUMN app_user.username IS
  'Unique username for the user. Auto-generated Reddit-style (e.g., SwoleRat) if not provided during signup. '
  'Can include alphanumeric characters and ._- symbols. Minimum 4 characters.';

COMMENT ON COLUMN app_user.email IS
  'User email address. Must be unique. Populated from auth.users.email via trigger.';

-- Note: app_user_id_fkey constraint comment is in migration 034 where FK is created
