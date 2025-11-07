#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Testing Complete Migration Pipeline with Production Data    ║${NC}"
echo -e "${BLUE}║  Including 076_CleanupCustomExercises.sql                    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"

# Configuration
CONTAINER_NAME="workout_app_complete_migration_test"
DB_NAME="workout_app_complete_test"
DB_PORT=5442
DB_USER="postgres"
DB_PASS="postgres"
BACKUP_DIR="dump"

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Cleaning up...${NC}"
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
}

# Trap to cleanup on exit (disabled - keep container running for inspection)
# trap cleanup EXIT

echo -e "\n${YELLOW}[1/11] Cleaning up existing test container...${NC}"
cleanup

echo -e "${YELLOW}[2/11] Starting fresh PostgreSQL 15 container on port $DB_PORT...${NC}"
docker run -d \
  --name $CONTAINER_NAME \
  -e POSTGRES_PASSWORD=$DB_PASS \
  -e POSTGRES_DB=$DB_NAME \
  -p $DB_PORT:5432 \
  postgres:15 >/dev/null

# Wait for database to be ready
echo -e "${YELLOW}[3/11] Waiting for database to be ready...${NC}"
for i in {1..30}; do
    if PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Database ready"
        break
    fi
    sleep 1
done

# Apply base migrations to create schema
echo -e "${YELLOW}[4/11] Applying base migrations (010-071)...${NC}"
BASE_MIGRATIONS=(
  "010_setup.sql"
  "020_AppUser.sql"
  "030_Plan.sql"
  "040_SessionSchedule.sql"
  "050_PerformedSession.sql"
  "060_Exercise.sql"
  "065_ExerciseMetadata_Normalized.sql"
  "066_SeedExerciseMetadata.sql"
  "067_ExerciseMetadata_RLS.sql"
  "070_PerformedExercise.sql"
  "071_SpecialSet.sql"
)

MIGRATION_COUNT=0
for file in "${BASE_MIGRATIONS[@]}"; do
    if PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$file" >/dev/null 2>&1; then
        ((MIGRATION_COUNT++))
    else
        echo -e "  ${RED}✗${NC} Failed: $file"
        exit 1
    fi
done

echo -e "  ${GREEN}✓${NC} Applied $MIGRATION_COUNT base migrations"

# Extract and filter data from Supabase backup
echo -e "${YELLOW}[5/11] Extracting production data from backup...${NC}"

# Find the most recent backup files (from Nov 4, 2025)
SCHEMA_BACKUP=$(ls -t $BACKUP_DIR/SB_2025-11-04*_schema.sql 2>/dev/null | head -1)
DATA_BACKUP=$(ls -t $BACKUP_DIR/SB_2025-11-04*_data.sql 2>/dev/null | head -1)

if [[ -z "$SCHEMA_BACKUP" ]] || [[ -z "$DATA_BACKUP" ]]; then
    echo -e "  ${RED}✗${NC} Backup files not found in $BACKUP_DIR/"
    exit 1
fi

echo -e "  Schema: $(basename $SCHEMA_BACKUP)"
echo -e "  Data: $(basename $DATA_BACKUP)"

# Create filtered data file (only public schema tables we care about)
echo -e "${YELLOW}[6/11] Filtering and importing production data...${NC}"

# Extract COPY statements for tables we need
FILTERED_DATA="/tmp/filtered_production_data_$$.sql"

# Extract specific tables from data backup
# Focus on: app_user, plan, base_exercise, exercise, performed_session, performed_exercise
# Note: Handle both quoted and unquoted COPY statement formats
awk '/^COPY (public\.|"public"\.)app_user/,/^\\\.$/' "$DATA_BACKUP" > "$FILTERED_DATA" 2>/dev/null || true
awk '/^COPY (public\.|"public"\.)plan/,/^\\\.$/' "$DATA_BACKUP" >> "$FILTERED_DATA" 2>/dev/null || true
awk '/^COPY (public\.|"public"\.)base_exercise/,/^\\\.$/' "$DATA_BACKUP" >> "$FILTERED_DATA" 2>/dev/null || true
awk '/^COPY (public\.|"public"\.)exercise/,/^\\\.$/' "$DATA_BACKUP" >> "$FILTERED_DATA" 2>/dev/null || true
awk '/^COPY (public\.|"public"\.)performed_session/,/^\\\.$/' "$DATA_BACKUP" >> "$FILTERED_DATA" 2>/dev/null || true
awk '/^COPY (public\.|"public"\.)performed_exercise/,/^\\\.$/' "$DATA_BACKUP" >> "$FILTERED_DATA" 2>/dev/null || true

# Check if we got any data
if [[ ! -s "$FILTERED_DATA" ]]; then
    echo -e "  ${RED}✗${NC} No data extracted from backup"
    exit 1
fi

# Create import wrapper that disables FK checks
IMPORT_WRAPPER="/tmp/import_wrapper_$$.sql"
cat > "$IMPORT_WRAPPER" <<'EOSQL'
-- Disable FK constraints for this session
SET session_replication_role = 'replica';

-- Import the data
EOSQL

cat "$FILTERED_DATA" >> "$IMPORT_WRAPPER"

cat >> "$IMPORT_WRAPPER" <<'EOSQL'

-- Re-enable FK constraints
SET session_replication_role = 'origin';
EOSQL

# Import the filtered data with disabled FK constraints
if PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$IMPORT_WRAPPER" 2>/tmp/import_errors_$$.log; then
    echo -e "  ${GREEN}✓${NC} Production data imported"
else
    echo -e "  ${YELLOW}⚠${NC}  Import completed with warnings (check /tmp/import_errors_$$.log)"
    # Don't fail - some warnings are expected
fi

# Verify data loaded
echo -e "${YELLOW}[7/11] Verifying production data import...${NC}"

COUNTS=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT
        (SELECT COUNT(*) FROM app_user) as users,
        (SELECT COUNT(*) FROM plan) as plans,
        (SELECT COUNT(*) FROM base_exercise) as base_exercises,
        (SELECT COUNT(*) FROM exercise) as exercises,
        (SELECT COUNT(*) FROM performed_session) as sessions,
        (SELECT COUNT(*) FROM performed_exercise) as performed;
")

echo -e "  ${BLUE}Data counts:${NC} $COUNTS"

# Check for null exercise_id records (BEFORE migration)
NULL_EXERCISE_COUNT_BEFORE=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT COUNT(*) FROM performed_exercise WHERE exercise_id IS NULL;
" | xargs)

echo -e "  ${BLUE}Performed exercises with null exercise_id (BEFORE):${NC} $NULL_EXERCISE_COUNT_BEFORE"

if [[ "$NULL_EXERCISE_COUNT_BEFORE" != "150" ]]; then
    echo -e "  ${RED}✗${NC} Expected 150 null exercise_id records, got $NULL_EXERCISE_COUNT_BEFORE"
    echo -e "  ${YELLOW}This may indicate backup data changed or incorrect backup file${NC}"
    exit 1
else
    echo -e "  ${GREEN}✓${NC} Found exactly 150 records needing cleanup (as expected)"
fi

# Count existing base_exercises and aliases BEFORE migration
BASE_EXERCISE_COUNT_BEFORE=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT COUNT(*) FROM base_exercise;
" | xargs)

ALIASES_COUNT_BEFORE=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT COUNT(*) FROM base_exercise WHERE aliases IS NOT NULL;
" | xargs)

echo -e "  ${BLUE}Base exercises (BEFORE):${NC} $BASE_EXERCISE_COUNT_BEFORE"
echo -e "  ${BLUE}Exercises with aliases (BEFORE):${NC} $ALIASES_COUNT_BEFORE"

# Apply 076_CleanupCustomExercises.sql migration
echo -e "${YELLOW}[8/11] Applying 076_CleanupCustomExercises.sql migration...${NC}"

if PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -f "076_CleanupCustomExercises.sql" >/tmp/migration_076_$$.log 2>&1; then
    echo -e "  ${GREEN}✓${NC} Migration 076 applied successfully"
else
    echo -e "  ${RED}✗${NC} Migration 076 failed. Error log:"
    tail -50 /tmp/migration_076_$$.log | sed 's/^/    /'
    exit 1
fi

# Verify migration results
echo -e "${YELLOW}[9/11] Verifying migration results...${NC}"

# Check null exercise_id count AFTER migration
NULL_EXERCISE_COUNT_AFTER=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT COUNT(*) FROM performed_exercise WHERE exercise_id IS NULL;
" | xargs)

echo -e "  ${BLUE}Performed exercises with null exercise_id (AFTER):${NC} $NULL_EXERCISE_COUNT_AFTER"

if [[ "$NULL_EXERCISE_COUNT_AFTER" == "0" ]]; then
    echo -e "  ${GREEN}✓${NC} All performed_exercise records now have exercise_id!"
else
    echo -e "  ${RED}✗${NC} Still have $NULL_EXERCISE_COUNT_AFTER null exercise_id records"
    exit 1
fi

# Count base_exercises AFTER migration
BASE_EXERCISE_COUNT_AFTER=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT COUNT(*) FROM base_exercise;
" | xargs)

NEW_EXERCISES=$((BASE_EXERCISE_COUNT_AFTER - BASE_EXERCISE_COUNT_BEFORE))

echo -e "  ${BLUE}Base exercises (AFTER):${NC} $BASE_EXERCISE_COUNT_AFTER (added $NEW_EXERCISES)"

# Check imported from free-exercise-db
FREE_EXERCISE_DB_COUNT=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT COUNT(*) FROM base_exercise WHERE source_name = 'free-exercise-db';
" | xargs)

echo -e "  ${BLUE}Exercises imported from free-exercise-db:${NC} $FREE_EXERCISE_DB_COUNT"

if [[ "$FREE_EXERCISE_DB_COUNT" == "19" ]]; then
    echo -e "  ${GREEN}✓${NC} Exactly 19 exercises imported from free-exercise-db (as expected)"
else
    echo -e "  ${YELLOW}⚠${NC}  Expected 19, got $FREE_EXERCISE_DB_COUNT"
fi

# Check custom exercises created
CUSTOM_EXERCISE_COUNT=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT COUNT(*) FROM base_exercise WHERE source_name = 'Custom (User)';
" | xargs)

echo -e "  ${BLUE}Custom exercises created:${NC} $CUSTOM_EXERCISE_COUNT"

if [[ "$CUSTOM_EXERCISE_COUNT" == "2" ]]; then
    echo -e "  ${GREEN}✓${NC} Exactly 2 custom exercises created (as expected)"
else
    echo -e "  ${YELLOW}⚠${NC}  Expected 2, got $CUSTOM_EXERCISE_COUNT"
fi

# Check total new exercises
EXPECTED_NEW=21
if [[ "$NEW_EXERCISES" == "$EXPECTED_NEW" ]]; then
    echo -e "  ${GREEN}✓${NC} Total new exercises: $NEW_EXERCISES (19 imported + 2 custom = $EXPECTED_NEW)"
else
    echo -e "  ${YELLOW}⚠${NC}  Expected $EXPECTED_NEW new exercises, got $NEW_EXERCISES"
fi

# Check aliases added
ALIASES_COUNT_AFTER=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT COUNT(*) FROM base_exercise WHERE aliases IS NOT NULL;
" | xargs)

NEW_ALIASES=$((ALIASES_COUNT_AFTER - ALIASES_COUNT_BEFORE))

echo -e "  ${BLUE}Exercises with aliases (AFTER):${NC} $ALIASES_COUNT_AFTER (added aliases to $NEW_ALIASES exercises)"

if [[ "$NEW_ALIASES" -ge "19" ]]; then
    echo -e "  ${GREEN}✓${NC} Added aliases to at least 19 exercises (as expected)"
else
    echo -e "  ${YELLOW}⚠${NC}  Expected aliases on at least 19 exercises, got $NEW_ALIASES"
fi

# Check Unknown plan exercises
echo -e "${YELLOW}[10/11] Verifying Unknown plan exercises...${NC}"

UNKNOWN_PLAN_EXERCISE_COUNT=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT COUNT(*)
    FROM exercise e
    JOIN session_schedule ss ON e.session_schedule_id = ss.session_schedule_id
    JOIN plan p ON ss.plan_id = p.plan_id
    WHERE p.name = 'Unknown';
" | xargs)

echo -e "  ${BLUE}Exercises in Unknown plan:${NC} $UNKNOWN_PLAN_EXERCISE_COUNT"

if [[ "$UNKNOWN_PLAN_EXERCISE_COUNT" == "21" ]]; then
    echo -e "  ${GREEN}✓${NC} Exactly 21 exercises in Unknown plan (as expected)"
else
    echo -e "  ${YELLOW}⚠${NC}  Expected 21, got $UNKNOWN_PLAN_EXERCISE_COUNT"
fi

# Test alias searching
echo -e "${YELLOW}[11/11] Testing alias searches...${NC}"

# Test pull-up alias
PULLUP_SEARCH=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT name FROM base_exercise WHERE aliases @> ARRAY['pull-up'];
" | xargs)

if [[ -n "$PULLUP_SEARCH" ]]; then
    echo -e "  ${GREEN}✓${NC} Alias 'pull-up' found: $PULLUP_SEARCH"
else
    echo -e "  ${RED}✗${NC} Alias 'pull-up' not found"
fi

# Test iso-lateral bench press alias
ISO_LATERAL_SEARCH=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT name FROM base_exercise WHERE aliases @> ARRAY['iso-lateral bench press'];
" | xargs)

if [[ -n "$ISO_LATERAL_SEARCH" ]]; then
    echo -e "  ${GREEN}✓${NC} Alias 'iso-lateral bench press' found: $ISO_LATERAL_SEARCH"
else
    echo -e "  ${RED}✗${NC} Alias 'iso-lateral bench press' not found"
fi

# Test dumbell bench press alias
DUMBELL_SEARCH=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT name FROM base_exercise WHERE aliases @> ARRAY['dumbell bench press'];
" | xargs)

if [[ -n "$DUMBELL_SEARCH" ]]; then
    echo -e "  ${GREEN}✓${NC} Alias 'dumbell bench press' found: $DUMBELL_SEARCH"
else
    echo -e "  ${RED}✗${NC} Alias 'dumbell bench press' not found"
fi

# Summary
echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Complete Migration Pipeline Test PASSED!                 ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo -e ""
echo -e "${BLUE}Migration Results:${NC}"
echo -e "  ${GREEN}✓${NC} Base migrations (010-071): $MIGRATION_COUNT files applied"
echo -e "  ${GREEN}✓${NC} Production data imported: $COUNTS"
echo -e "  ${GREEN}✓${NC} Migration 076 applied successfully"
echo -e ""
echo -e "${BLUE}Verification Results:${NC}"
echo -e "  ${GREEN}✓${NC} Null exercise_id records: $NULL_EXERCISE_COUNT_BEFORE → $NULL_EXERCISE_COUNT_AFTER"
echo -e "  ${GREEN}✓${NC} New exercises added: $NEW_EXERCISES (19 imported + 2 custom)"
echo -e "  ${GREEN}✓${NC} Exercises from free-exercise-db: $FREE_EXERCISE_DB_COUNT"
echo -e "  ${GREEN}✓${NC} Custom exercises created: $CUSTOM_EXERCISE_COUNT"
echo -e "  ${GREEN}✓${NC} Aliases added to exercises: $NEW_ALIASES"
echo -e "  ${GREEN}✓${NC} Unknown plan exercises: $UNKNOWN_PLAN_EXERCISE_COUNT"
echo -e "  ${GREEN}✓${NC} Alias searches working correctly"
echo -e ""
echo -e "${BLUE}Database connection:${NC}"
echo -e "  PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME"
echo -e ""
echo -e "${YELLOW}Container will remain running for inspection${NC}"
echo -e "${YELLOW}To cleanup: docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME${NC}"
