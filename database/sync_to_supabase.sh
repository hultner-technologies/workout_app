#!/bin/bash
# Sync database migrations to Supabase local environment
#
# This script copies SQL files from database/ to supabase/migrations/
# with proper timestamp-based naming that Supabase expects.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DB_DIR="$SCRIPT_DIR"
SUPABASE_MIGRATIONS_DIR="$PROJECT_ROOT/supabase/migrations"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Syncing migrations to Supabase...${NC}"
echo ""

# Create migrations directory if it doesn't exist
mkdir -p "$SUPABASE_MIGRATIONS_DIR"

# Base timestamp for migrations (2024-01-01 00:00:00)
# Each migration gets incremented by 1 minute
BASE_TIMESTAMP=20240101000000

# Counter for timestamp increments
counter=0

# Find all SQL files in database/ (excluding subdirectories like queries/)
for sql_file in "$DB_DIR"/*.sql; do
    if [ -f "$sql_file" ]; then
        # Get filename without path
        filename=$(basename "$sql_file")

        # Skip if it's a test or utility file
        if [[ "$filename" =~ ^(test_|restore_|seed_) ]]; then
            echo -e "${YELLOW}Skipping: $filename${NC}"
            continue
        fi

        # Extract the number prefix if it exists (e.g., 010 from 010_setup.sql)
        if [[ "$filename" =~ ^([0-9]+)_(.+)\.sql$ ]]; then
            number="${BASH_REMATCH[1]}"
            name="${BASH_REMATCH[2]}"
        else
            # No number prefix, use filename as-is
            name="${filename%.sql}"
        fi

        # Calculate timestamp (increment counter by 1 minute for each file)
        timestamp=$((BASE_TIMESTAMP + counter))
        counter=$((counter + 1))

        # Format: YYYYMMDDHHMMSS_name.sql
        new_filename="${timestamp}_${name}.sql"
        target_file="$SUPABASE_MIGRATIONS_DIR/$new_filename"

        # Copy file
        cp "$sql_file" "$target_file"
        echo -e "${GREEN}✓${NC} $filename → $new_filename"
    fi
done

echo ""
echo -e "${GREEN}Migration sync complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Start Supabase: supabase start"
echo "  2. Reset database: supabase db reset"
echo ""
