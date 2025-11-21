-- Rollback: Move pg_trgm Extension
-- Description: Move pg_trgm back to public schema
-- WARNING: This is generally not needed, but provided for completeness

BEGIN;

-- Drop from extensions schema
DROP EXTENSION IF EXISTS pg_trgm CASCADE;

-- Recreate in public schema (original location)
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;

COMMENT ON EXTENSION pg_trgm IS
    '⚠️ ROLLBACK: Extension in public schema (not recommended). '
    'This is the pre-migration state.';

COMMIT;
