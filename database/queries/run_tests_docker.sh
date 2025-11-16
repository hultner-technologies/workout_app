#!/bin/bash
# Test runner using Docker PostgreSQL
# This script spins up a temporary PostgreSQL container and runs all tests

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONTAINER_NAME="workout_app_test_db"
POSTGRES_PASSWORD="test_password"
POSTGRES_USER="postgres"
POSTGRES_DB="workout_app_test"
POSTGRES_PORT="5433"  # Use non-standard port to avoid conflicts

echo -e "${BLUE}========================================"
echo "Empty Workout Fix - Test Suite (Docker)"
echo -e "========================================${NC}"
echo ""

# Check if docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found${NC}"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Clean up any existing container
echo -e "${BLUE}Step 1: Cleanup${NC}"
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Removing existing container..."
    docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1 || true
fi
echo -e "${GREEN}✓ Cleanup complete${NC}"
echo ""

# Start PostgreSQL container
echo -e "${BLUE}Step 2: Starting PostgreSQL Container${NC}"
echo "Container: $CONTAINER_NAME"
echo "Port: $POSTGRES_PORT"
echo ""

docker run --name "$CONTAINER_NAME" \
    -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    -e POSTGRES_USER="$POSTGRES_USER" \
    -e POSTGRES_DB="$POSTGRES_DB" \
    -p "$POSTGRES_PORT:5432" \
    -d postgres:16-alpine

echo -e "${GREEN}✓ Container started${NC}"
echo ""

# Wait for PostgreSQL to be ready
echo -e "${BLUE}Step 3: Waiting for PostgreSQL to be ready${NC}"
echo -n "Waiting"
for i in {1..30}; do
    if docker exec "$CONTAINER_NAME" pg_isready -U "$POSTGRES_USER" > /dev/null 2>&1; then
        # pg_isready passed, but wait a moment for database to be fully initialized
        sleep 2
        # Verify database can actually execute queries
        if docker exec "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT 1;" > /dev/null 2>&1; then
            echo ""
            echo -e "${GREEN}✓ PostgreSQL is ready${NC}"
            break
        fi
    fi
    echo -n "."
    sleep 1
    if [ $i -eq 30 ]; then
        echo ""
        echo -e "${RED}✗ PostgreSQL failed to start${NC}"
        docker logs "$CONTAINER_NAME"
        docker rm -f "$CONTAINER_NAME"
        exit 1
    fi
done
echo ""

# Function to run SQL in container
run_sql() {
    local file=$1
    local description=$2
    echo -e "${YELLOW}Running: ${description}${NC}"
    if docker exec -i "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$file" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Success${NC}"
    else
        echo -e "${RED}✗ Failed${NC}"
        return 1
    fi
}

# Apply schema
echo -e "${BLUE}Step 4: Apply Database Schema${NC}"
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
    "$DB_DIR/230_session_helper_functions.sql" \
    "$DB_DIR/250_empty_workout_support.sql" \
    "$DB_DIR/260_rls_policies.sql"
do
    if [ -f "$file" ]; then
        basename_file=$(basename "$file")
        run_sql "$file" "Apply $basename_file" || exit 1
    fi
done
echo -e "${GREEN}✓ Schema applied${NC}"
echo ""

# Insert test data
echo -e "${BLUE}Step 5: Insert Empty Workout Test Data${NC}"
run_sql "$DB_DIR/queries/insert_empty_workout.sql" "Insert empty workout plan" || exit 1
echo ""

# Run problem demonstration
echo -e "${BLUE}Step 6: Demonstrate the Problem${NC}"
echo -e "${YELLOW}Running test to show issue with empty workouts...${NC}"
TEST_OUTPUT=$(docker exec -i "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$DB_DIR/queries/test_empty_workout.sql" 2>&1)
echo "$TEST_OUTPUT"

# Check for errors
if echo "$TEST_OUTPUT" | grep -i "^ERROR:" > /dev/null; then
    echo -e "${RED}✗ test_empty_workout.sql failed with errors${NC}"
    exit 1
fi
echo -e "${GREEN}✓ test_empty_workout.sql completed${NC}"
echo ""

# Run verification
echo -e "${BLUE}Step 7: Verify the Fix${NC}"
echo -e "${YELLOW}Running verification tests...${NC}"
TEST_OUTPUT=$(docker exec -i "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$DB_DIR/queries/verify_empty_workout_fix.sql" 2>&1)
echo "$TEST_OUTPUT"

# Check for errors
if echo "$TEST_OUTPUT" | grep -i "^ERROR:" > /dev/null; then
    echo -e "${RED}✗ verify_empty_workout_fix.sql failed with errors${NC}"
    exit 1
fi
echo -e "${GREEN}✓ verify_empty_workout_fix.sql completed${NC}"
echo ""

# Run security tests
echo -e "${BLUE}Step 8: Test Row Level Security${NC}"
echo -e "${YELLOW}Running RLS security tests...${NC}"
TEST_OUTPUT=$(docker exec -i "$CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$DB_DIR/queries/test_rls_security.sql" 2>&1)
echo "$TEST_OUTPUT"

# Check for errors
if echo "$TEST_OUTPUT" | grep -i "^ERROR:" > /dev/null; then
    echo -e "${RED}✗ test_rls_security.sql failed with errors${NC}"
    exit 1
fi
echo -e "${GREEN}✓ test_rls_security.sql completed${NC}"
echo ""


# Summary
echo -e "${BLUE}========================================"
echo "Test Suite Complete!"
echo -e "========================================${NC}"
echo ""
echo -e "${GREEN}All tests passed!${NC}"
echo ""
echo "What was tested:"
echo "  1. Database schema setup (with RLS policies)"
echo "  2. Empty workout plan creation"
echo "  3. Problem demonstration (0 rows for empty workouts)"
echo "  4. Fix application (new views and functions)"
echo "  5. Verification (proper handling of empty workouts)"
echo "  6. Row Level Security (RLS) policies"
echo "  7. Function security (SECURITY INVOKER)"
echo "  8. Data isolation between users"
echo ""
echo "Documentation:"
echo "  - database/queries/README.md - Usage guide & API reference"
echo "  - database/queries/SECURITY_MODEL.md - Security & RLS guide"
echo ""

# Ask about cleanup
echo ""
echo -e "${YELLOW}Docker container is still running${NC}"
read -p "Stop and remove container? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Stopping container..."
    docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1
    echo -e "${GREEN}✓ Container removed${NC}"
else
    echo ""
    echo "Container details:"
    echo "  Name: $CONTAINER_NAME"
    echo "  Port: localhost:$POSTGRES_PORT"
    echo "  User: $POSTGRES_USER"
    echo "  Password: $POSTGRES_PASSWORD"
    echo "  Database: $POSTGRES_DB"
    echo ""
    echo "Connect with:"
    echo "  psql -h localhost -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB"
    echo ""
    echo "Stop with:"
    echo "  docker rm -f $CONTAINER_NAME"
fi

# Exit with success - tests passed!
exit 0
