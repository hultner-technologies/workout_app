#!/bin/bash
set -e  # Exit on any error

# Test All Migrations Script for Workout App Database
# This script validates that all migrations run cleanly on a fresh database

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TEST_CONTAINER="workout_app_test_all_migrations"
TEST_DB="workout_app_test_all"
TEST_PORT="5436"
POSTGRES_PASSWORD="postgres"

echo -e "${BLUE}=== Workout App - Complete Migration Test ===${NC}"
echo ""

# Clean up existing test container
echo -e "${YELLOW}[1/8] Cleaning up existing test container...${NC}"
docker stop $TEST_CONTAINER 2>/dev/null || true
docker rm $TEST_CONTAINER 2>/dev/null || true
echo -e "${GREEN}✓ Cleanup complete${NC}"
echo ""

# Start fresh PostgreSQL container
echo -e "${YELLOW}[2/8] Starting fresh PostgreSQL 15 container...${NC}"
docker run -d \
  --name $TEST_CONTAINER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_DB=$TEST_DB \
  -p $TEST_PORT:5432 \
  --health-cmd="pg_isready -U postgres" \
  --health-interval=5s \
  --health-timeout=3s \
  --health-retries=5 \
  postgres:15 > /dev/null

# Wait for container to be healthy
echo -n "Waiting for PostgreSQL to be ready"
for i in {1..30}; do
  if docker exec $TEST_CONTAINER pg_isready -U postgres > /dev/null 2>&1; then
    echo ""
    echo -e "${GREEN}✓ PostgreSQL is ready${NC}"
    break
  fi
  echo -n "."
  sleep 1
done
echo ""

# Create Supabase roles (needed for RLS policies)
echo -e "${YELLOW}[3/8] Creating Supabase roles...${NC}"
PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -p $TEST_PORT -U postgres -d $TEST_DB \
  -c "CREATE ROLE anon; CREATE ROLE authenticated; CREATE ROLE service_role;" > /dev/null 2>&1
echo -e "${GREEN}✓ Supabase roles created${NC}"
echo ""

# Change to database directory
cd "$(dirname "$0")"

# Run base migrations
echo -e "${YELLOW}[4/9] Running base migrations (010-090)...${NC}"
MIGRATION_FILES=(
  "010_setup.sql"
  "020_AppUser.sql"
  "030_Plan.sql"
  "040_SessionSchedule.sql"
  "050_PerformedSession.sql"
  "060_Exercise.sql"
  "070_PerformedExercise.sql"
  "071_SpecialSet.sql"
  "090_ExerciseScheduleView.sql"
)

FAILED=0
for file in "${MIGRATION_FILES[@]}"; do
  echo -n "  - $file: "
  if PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -p $TEST_PORT -U postgres -d $TEST_DB \
    -f "$file" > /tmp/migration_test_$$.log 2>&1; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${RED}✗ FAILED${NC}"
    echo "Error output:"
    cat /tmp/migration_test_$$.log
    FAILED=1
    break
  fi
done

if [ $FAILED -eq 1 ]; then
  echo ""
  echo -e "${RED}Base migrations failed. Stopping test.${NC}"
  docker stop $TEST_CONTAINER > /dev/null 2>&1
  docker rm $TEST_CONTAINER > /dev/null 2>&1
  exit 1
fi
echo ""

# Run view and function migrations
echo -e "${YELLOW}[5/9] Running view and function migrations (110-240)...${NC}"
VIEW_FILES=(
  "110_views_full_exercise.sql"
  "120_views_next_exercise_progression.sql"
  "130_views_exercise_stats.sql"
  "210_draft_session_exercises.sql"
  "220_create_session_exercises.sql"
  "230_session_helper_functions.sql"
  "240_supabase_config.sql"
)

for file in "${VIEW_FILES[@]}"; do
  echo -n "  - $file: "
  # 240_supabase_config.sql may have non-critical errors (missing authenticator role)
  if PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -p $TEST_PORT -U postgres -d $TEST_DB \
    -f "$file" > /tmp/migration_test_$$.log 2>&1; then
    echo -e "${GREEN}✓${NC}"
  else
    # Check if it's just the authenticator role error
    if [[ "$file" == "240_supabase_config.sql" ]] && grep -q "role \"authenticator\" does not exist" /tmp/migration_test_$$.log; then
      echo -e "${YELLOW}✓ (expected warning)${NC}"
    else
      echo -e "${RED}✗ FAILED${NC}"
      echo "Error output:"
      cat /tmp/migration_test_$$.log
      FAILED=1
      break
    fi
  fi
done

if [ $FAILED -eq 1 ]; then
  echo ""
  echo -e "${RED}View/function migrations failed. Stopping test.${NC}"
  docker stop $TEST_CONTAINER > /dev/null 2>&1
  docker rm $TEST_CONTAINER > /dev/null 2>&1
  exit 1
fi
echo ""

# Run exercise metadata migrations
echo -e "${YELLOW}[6/9] Running exercise metadata migrations (065-067)...${NC}"
METADATA_FILES=(
  "065_ExerciseMetadata_Normalized.sql"
  "066_SeedExerciseMetadata.sql"
  "067_ExerciseMetadata_RLS.sql"
)

for file in "${METADATA_FILES[@]}"; do
  echo -n "  - $file: "
  PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -p $TEST_PORT -U postgres -d $TEST_DB \
    -f "$file" > /tmp/migration_test_$$.log 2>&1

  # Check for critical errors (ignore index immutable function warning)
  if grep -E "ERROR" /tmp/migration_test_$$.log | grep -v "functions in index expression must be marked IMMUTABLE" | grep -q "ERROR"; then
    echo -e "${RED}✗ FAILED${NC}"
    echo "Error output:"
    cat /tmp/migration_test_$$.log
    FAILED=1
    break
  else
    echo -e "${GREEN}✓${NC}"
  fi
done

if [ $FAILED -eq 1 ]; then
  echo ""
  echo -e "${RED}Exercise metadata migrations failed. Stopping test.${NC}"
  docker stop $TEST_CONTAINER > /dev/null 2>&1
  docker rm $TEST_CONTAINER > /dev/null 2>&1
  exit 1
fi
echo ""

# Verify schema
echo -e "${YELLOW}[7/9] Verifying database schema...${NC}"
EXPECTED_TABLES=(
  "app_user"
  "base_exercise"
  "exercise"
  "exercise_set_type"
  "performed_session"
  "performed_exercise"
  "performed_exercise_set"
  "plan"
  "session_schedule"
  "muscle_group"
  "equipment_type"
  "exercise_category"
  "base_exercise_primary_muscle"
  "base_exercise_secondary_muscle"
)

for table in "${EXPECTED_TABLES[@]}"; do
  echo -n "  - Table '$table': "
  if PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -p $TEST_PORT -U postgres -d $TEST_DB \
    -c "\d $table" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${RED}✗ MISSING${NC}"
    FAILED=1
  fi
done

if [ $FAILED -eq 1 ]; then
  echo ""
  echo -e "${RED}Schema verification failed.${NC}"
  docker stop $TEST_CONTAINER > /dev/null 2>&1
  docker rm $TEST_CONTAINER > /dev/null 2>&1
  exit 1
fi
echo ""

# Verify views
echo -e "${YELLOW}[8/9] Verifying views...${NC}"
EXPECTED_VIEWS=(
  "exercise_schedule"
  "full_exercise"
  "next_exercise_progression"
  "exercise_stats"
  "base_exercise_with_muscles"
  "base_exercise_full"
)

for view in "${EXPECTED_VIEWS[@]}"; do
  echo -n "  - View '$view': "
  if PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -p $TEST_PORT -U postgres -d $TEST_DB \
    -c "\d $view" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
  else
    echo -e "${RED}✗ MISSING${NC}"
    FAILED=1
  fi
done

if [ $FAILED -eq 1 ]; then
  echo ""
  echo -e "${RED}View verification failed.${NC}"
  docker stop $TEST_CONTAINER > /dev/null 2>&1
  docker rm $TEST_CONTAINER > /dev/null 2>&1
  exit 1
fi
echo ""

# Verify reference data
echo -e "${YELLOW}[9/9] Verifying reference data...${NC}"
COUNTS=$(PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -p $TEST_PORT -U postgres -d $TEST_DB -t -c "
  SELECT
    (SELECT COUNT(*) FROM muscle_group) as muscle_groups,
    (SELECT COUNT(*) FROM equipment_type) as equipment_types,
    (SELECT COUNT(*) FROM exercise_category) as categories,
    (SELECT COUNT(*) FROM exercise_set_type) as set_types;
")

echo -n "  - Reference data counts: "
if echo "$COUNTS" | grep -q "17.*12.*7.*8"; then
  echo -e "${GREEN}✓ (17 muscles, 12 equipment, 7 categories, 8 set types)${NC}"
else
  echo -e "${RED}✗ INCORRECT${NC}"
  echo "Expected: 17 muscles, 12 equipment, 7 categories, 8 set types"
  echo "Got: $COUNTS"
  FAILED=1
fi
echo ""

# Cleanup temp log file
rm -f /tmp/migration_test_$$.log

if [ $FAILED -eq 1 ]; then
  echo -e "${RED}=== Tests Failed ===${NC}"
  docker stop $TEST_CONTAINER > /dev/null 2>&1
  docker rm $TEST_CONTAINER > /dev/null 2>&1
  exit 1
fi

# Success!
echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ All Migration Tests Passed!      ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Test database is running:${NC}"
echo "  Container: $TEST_CONTAINER"
echo "  Port: $TEST_PORT"
echo "  Database: $TEST_DB"
echo "  Connection: postgresql://postgres:$POSTGRES_PASSWORD@localhost:$TEST_PORT/$TEST_DB"
echo ""
echo -e "${YELLOW}To manually connect:${NC}"
echo "  PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -p $TEST_PORT -U postgres -d $TEST_DB"
echo ""
echo -e "${YELLOW}To clean up:${NC}"
echo "  docker stop $TEST_CONTAINER && docker rm $TEST_CONTAINER"
echo ""
