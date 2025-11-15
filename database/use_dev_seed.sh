#!/bin/bash
# Use minimal development seed data
#
# Overwrites supabase/seed.sql with minimal test data for development.
# Run this before `supabase db reset` to use dev data instead of production.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SEED_FILE="$PROJECT_ROOT/supabase/seed.sql"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Creating minimal development seed data...${NC}"
echo ""

cat > "$SEED_FILE" << 'EOF'
-- ============================================================================
-- Development Seed Data (Minimal)
-- ============================================================================
-- This file is automatically run after migrations during `supabase db reset`
--
-- Contains minimal test data for development.
-- To use production data instead: ./database/dump_production_full.sh
-- ============================================================================

BEGIN;

-- Create a test user (if not exists)
INSERT INTO app_user (email, name)
SELECT 'dev@example.com', 'Dev User'
WHERE NOT EXISTS (SELECT 1 FROM app_user WHERE email = 'dev@example.com');

-- The "Unknown" plan is created by migration 075_PopulateUnknownPlan.sql
-- It contains all base_exercises automatically

-- Create a sample workout plan (if not exists)
INSERT INTO plan (name, description)
SELECT 'Starter Plan', 'A simple 3-day workout plan for development testing'
WHERE NOT EXISTS (SELECT 1 FROM plan WHERE name = 'Starter Plan');

-- Create session schedules for the starter plan
WITH plan_id AS (
    SELECT plan_id FROM plan WHERE name = 'Starter Plan' LIMIT 1
)
INSERT INTO session_schedule (plan_id, name, description, progression_limit)
SELECT
    p.plan_id,
    s.name,
    s.description,
    0.9
FROM plan_id p
CROSS JOIN (VALUES
    ('Day A - Push', 'Chest, shoulders, triceps'),
    ('Day B - Pull', 'Back and biceps'),
    ('Day C - Legs', 'Legs and core')
) AS s(name, description)
WHERE NOT EXISTS (
    SELECT 1 FROM session_schedule ss
    WHERE ss.plan_id = p.plan_id AND ss.name = s.name
);

COMMIT;

-- Show what was seeded
DO $$
BEGIN
    RAISE NOTICE '✓ Development seed data loaded (minimal)';
    RAISE NOTICE '  - Plans: %', (SELECT COUNT(*) FROM plan);
    RAISE NOTICE '  - Session schedules: %', (SELECT COUNT(*) FROM session_schedule);
    RAISE NOTICE '  - Users: %', (SELECT COUNT(*) FROM app_user);
    RAISE NOTICE '';
    RAISE NOTICE 'For production data: ./database/dump_production_full.sh';
END $$;
EOF

echo -e "${GREEN}✓ Development seed configured${NC}"
echo ""
echo "Next: supabase db reset"
echo ""
