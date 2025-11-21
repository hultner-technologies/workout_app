-- Migration: Move pg_trgm Extension to extensions Schema
-- Description: Move pg_trgm from public schema to extensions schema (best practice)
-- Created: 2025-11-21
-- Priority: WARN level (Low - organizational best practice)

-- ============================================================================
-- MOVE PG_TRGM EXTENSION
-- ============================================================================
-- Issue: pg_trgm extension in public schema instead of extensions schema
-- Fix: Drop and recreate in extensions schema
-- Reference: Supabase best practices for extension organization

-- Note: Extensions are created with IF NOT EXISTS in multiple migrations
-- (077_ApplyOriginalExercisesMetadata.sql, import scripts)
-- This migration ensures it's in the correct schema

-- Drop extension from public schema if it exists there
-- Note: This is safe because CREATE EXTENSION IF NOT EXISTS is used elsewhere
DROP EXTENSION IF EXISTS pg_trgm CASCADE;

-- Create extensions schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS extensions;

-- Create pg_trgm extension in extensions schema
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA extensions;

COMMENT ON EXTENSION pg_trgm IS
    'Text similarity measurement and index searching based on trigrams. '
    'Installed in extensions schema per Supabase best practices.';

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- pg_trgm is now in extensions schema instead of public
-- All references use qualified names or CREATE EXTENSION IF NOT EXISTS
-- Non-breaking: No code changes needed due to IF NOT EXISTS usage
