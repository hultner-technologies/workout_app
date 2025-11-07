#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Restoring Supabase Production Backup (Data Cleanup)         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"

# Configuration
CONTAINER_NAME="workout_app_production_restore"
DB_NAME="workout_app_production"
DB_PORT=5441
DB_USER="postgres"
DB_PASS="postgres"
BACKUP_DIR="dump"

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Cleaning up...${NC}"
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
}

# Trap to cleanup on exit (disabled - keep container running)
# trap cleanup EXIT

echo -e "\n${YELLOW}[1/7] Cleaning up existing container...${NC}"
cleanup

echo -e "${YELLOW}[2/7] Starting fresh PostgreSQL 15 container...${NC}"
docker run -d \
  --name $CONTAINER_NAME \
  -e POSTGRES_PASSWORD=$DB_PASS \
  -e POSTGRES_DB=$DB_NAME \
  -p $DB_PORT:5432 \
  postgres:15 >/dev/null

# Wait for database to be ready
echo -e "${YELLOW}[3/7] Waiting for database to be ready...${NC}"
for i in {1..30}; do
    if PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Database ready"
        break
    fi
    sleep 1
done

# Apply base migrations to create schema (same as test script)
echo -e "${YELLOW}[4/7] Applying base migrations (010-071)...${NC}"
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
echo -e "${YELLOW}[5/7] Extracting production data from backup...${NC}"

# Find the most recent backup files
SCHEMA_BACKUP=$(ls -t $BACKUP_DIR/SB_*_schema.sql 2>/dev/null | head -1)
DATA_BACKUP=$(ls -t $BACKUP_DIR/SB_*_data.sql 2>/dev/null | head -1)

if [[ -z "$SCHEMA_BACKUP" ]] || [[ -z "$DATA_BACKUP" ]]; then
    echo -e "  ${RED}✗${NC} Backup files not found in $BACKUP_DIR/"
    exit 1
fi

echo -e "  Schema: $(basename $SCHEMA_BACKUP)"
echo -e "  Data: $(basename $DATA_BACKUP)"

# Create filtered data file (only public schema tables we care about)
echo -e "${YELLOW}[6/7] Filtering and importing production data...${NC}"

# Extract COPY statements for tables we need
FILTERED_DATA="/tmp/filtered_production_data_$$.sql"

# Extract specific tables from data backup
# Focus on: app_user, plan, base_exercise, exercise, performed_session, performed_exercise
# Note: Supabase uses quoted schema/table names
awk '/^COPY "public"\."app_user"/,/^\\\.$/' "$DATA_BACKUP" > "$FILTERED_DATA" 2>/dev/null || true
awk '/^COPY "public"\."plan"/,/^\\\.$/' "$DATA_BACKUP" >> "$FILTERED_DATA" 2>/dev/null || true
awk '/^COPY "public"\."base_exercise"/,/^\\\.$/' "$DATA_BACKUP" >> "$FILTERED_DATA" 2>/dev/null || true
awk '/^COPY "public"\."exercise"/,/^\\\.$/' "$DATA_BACKUP" >> "$FILTERED_DATA" 2>/dev/null || true
awk '/^COPY "public"\."performed_session"/,/^\\\.$/' "$DATA_BACKUP" >> "$FILTERED_DATA" 2>/dev/null || true
awk '/^COPY "public"\."performed_exercise"/,/^\\\.$/' "$DATA_BACKUP" >> "$FILTERED_DATA" 2>/dev/null || true

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
echo -e "${YELLOW}[7/7] Verifying data import...${NC}"

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

# Check for null exercise_id records
NULL_EXERCISE_COUNT=$(PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
    SELECT COUNT(*) FROM performed_exercise WHERE exercise_id IS NULL;
")

echo -e "  ${BLUE}Performed exercises with null exercise_id:${NC} $NULL_EXERCISE_COUNT"

if [[ "$NULL_EXERCISE_COUNT" -gt "0" ]]; then
    echo -e "  ${GREEN}✓${NC} Found $NULL_EXERCISE_COUNT records needing cleanup"
else
    echo -e "  ${YELLOW}⚠${NC}  No null exercise_id records found"
fi

# Summary
echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Production Backup Restoration Complete!                  ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo -e ""
echo -e "${BLUE}Database connection:${NC}"
echo -e "  PGPASSWORD=$DB_PASS psql -h localhost -p $DB_PORT -U $DB_USER -d $DB_NAME"
echo -e ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Analyze null exercise_id records"
echo -e "  2. Match to existing base_exercises"
echo -e "  3. Create new base_exercises for unmatched"
echo -e "  4. Generate migration SQL"
echo -e ""
echo -e "${YELLOW}Container will remain running for analysis${NC}"
echo -e "${YELLOW}To cleanup: docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME${NC}"
