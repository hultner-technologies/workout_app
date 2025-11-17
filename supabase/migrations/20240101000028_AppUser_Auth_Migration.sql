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

-- Add foreign key constraint to auth.users
-- This ensures data integrity and enables CASCADE deletes
ALTER TABLE app_user
  ADD CONSTRAINT app_user_id_fkey
  FOREIGN KEY (app_user_id)
  REFERENCES auth.users(id)
  ON DELETE CASCADE;

-- Add username field with constraints
-- - Required (NOT NULL)
-- - Unique across all users
-- - Minimum 4 characters
-- - Format: alphanumeric + common chars (._-)
ALTER TABLE app_user
  ADD COLUMN username text NOT NULL UNIQUE
  CONSTRAINT username_length CHECK (char_length(username) >= 4)
  CONSTRAINT username_format CHECK (username ~ '^[a-zA-Z0-9._-]{4,}$');

-- Add unique constraint on email
-- Prevents duplicate email addresses
ALTER TABLE app_user
  ADD CONSTRAINT app_user_email_unique UNIQUE (email);

-- Remove password field
-- Supabase Auth handles password management
ALTER TABLE app_user DROP COLUMN IF EXISTS password;

-- Add comment explaining the changes
COMMENT ON COLUMN app_user.username IS
  'Unique username for the user. Auto-generated Reddit-style (e.g., SwoleRat) if not provided during signup. '
  'Can include alphanumeric characters and ._- symbols. Minimum 4 characters.';

COMMENT ON COLUMN app_user.email IS
  'User email address. Must be unique. Populated from auth.users.email via trigger.';

COMMENT ON CONSTRAINT app_user_id_fkey ON app_user IS
  'Foreign key to auth.users. Ensures app_user records are always linked to valid Supabase Auth users. '
  'CASCADE delete ensures orphaned records are automatically cleaned up.';
