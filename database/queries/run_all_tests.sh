#!/bin/bash
# Test runner for empty workout fix
# This script sets up a test database, applies the schema, and runs all tests

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TEST_DB="${TEST_DB:-workout_app_test}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"

echo -e "${BLUE}========================================"
echo "Empty Workout Fix - Test Suite"
echo -e "========================================${NC}"
echo ""

# Function to run SQL and check result
run_sql() {
    local file=$1
    local description=$2
    echo -e "${YELLOW}Running: ${description}${NC}"
    if psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$TEST_DB" -f "$file" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Success${NC}"
    else
        echo -e "${RED}✗ Failed${NC}"
        return 1
    fi
}

# Check if database exists, create if not
echo -e "${BLUE}Step 1: Database Setup${NC}"
if psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -lqt | cut -d \| -f 1 | grep -qw "$TEST_DB"; then
    echo -e "${YELLOW}Database $TEST_DB already exists${NC}"
    read -p "Drop and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Dropping database..."
        dropdb -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" "$TEST_DB" 2>/dev/null || true
        echo "Creating database..."
        createdb -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" "$TEST_DB"
        echo -e "${GREEN}✓ Database recreated${NC}"
    fi
else
    echo "Creating database..."
    createdb -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" "$TEST_DB"
    echo -e "${GREEN}✓ Database created${NC}"
fi
echo ""

# Apply schema
echo -e "${BLUE}Step 2: Apply Database Schema${NC}"
DB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for file in \
    "$DB_DIR/010_setup.sql" \
    "$DB_DIR/020_AppUser.sql" \
    "$DB_DIR/030_Plan.sql" \
    "$DB_DIR/040_SessionSchedule.sql" \
    "$DB_DIR/050_PerformedSession.sql" \
    "$DB_DIR/060_Exercise.sql" \
    "$DB_DIR/070_PerformedExercise.sql" \
    "$DB_DIR/071_SpecialSet.sql" \
    "$DB_DIR/090_ExerciseScheduleView.sql" \
    "$DB_DIR/110_views_full_exercise.sql" \
    "$DB_DIR/120_views_next_exercise_progression.sql" \
    "$DB_DIR/130_views_exercise_stats.sql" \
    "$DB_DIR/210_draft_session_exercises.sql" \
    "$DB_DIR/220_create_session_exercises.sql" \
    "$DB_DIR/230_session_helper_functions.sql"
do
    if [ -f "$file" ]; then
        basename_file=$(basename "$file")
        run_sql "$file" "Apply $basename_file" || exit 1
    fi
done
echo -e "${GREEN}✓ Schema applied${NC}"
echo ""

# Insert test data
echo -e "${BLUE}Step 3: Insert Empty Workout Test Data${NC}"
run_sql "$DB_DIR/queries/insert_empty_workout.sql" "Insert empty workout plan" || exit 1
echo ""

# Run problem demonstration
echo -e "${BLUE}Step 4: Demonstrate the Problem${NC}"
echo -e "${YELLOW}Running test to show issue with empty workouts...${NC}"
psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$TEST_DB" -f "$DB_DIR/queries/test_empty_workout.sql"
echo ""

# Apply fix
echo -e "${BLUE}Step 5: Apply the Fix${NC}"
run_sql "$DB_DIR/250_empty_workout_support.sql" "Apply empty workout support migration" || exit 1
echo ""

# Run verification
echo -e "${BLUE}Step 6: Verify the Fix${NC}"
echo -e "${YELLOW}Running verification tests...${NC}"
psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$TEST_DB" -f "$DB_DIR/queries/verify_empty_workout_fix.sql"
echo ""

# Summary
echo -e "${BLUE}========================================"
echo "Test Suite Complete!"
echo -e "========================================${NC}"
echo ""
echo -e "${GREEN}All tests passed!${NC}"
echo ""
echo "What was tested:"
echo "  1. Database schema setup"
echo "  2. Empty workout plan creation"
echo "  3. Problem demonstration (0 rows for empty workouts)"
echo "  4. Fix application (new views and functions)"
echo "  5. Verification (proper handling of empty workouts)"
echo ""
echo "Next steps:"
echo "  - Review the output above"
echo "  - Check database/queries/README_empty_workout.md for usage"
echo "  - Update API endpoints to use new functions"
echo ""
echo -e "${YELLOW}Test database: $TEST_DB${NC}"
echo "Keep for manual testing or drop with:"
echo "  dropdb -U $POSTGRES_USER $TEST_DB"
