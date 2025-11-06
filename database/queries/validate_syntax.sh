#!/bin/bash
# Syntax validation for SQL files
# This validates SQL syntax without requiring a running database

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "SQL Syntax Validation"
echo "========================================"
echo ""

DB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Files to validate
FILES=(
    "$DB_DIR/250_empty_workout_support.sql"
    "$DB_DIR/260_rls_policies.sql"
    "$DB_DIR/270_improved_session_interface.sql"
    "$DB_DIR/queries/insert_empty_workout.sql"
    "$DB_DIR/queries/test_empty_workout.sql"
    "$DB_DIR/queries/verify_empty_workout_fix.sql"
    "$DB_DIR/queries/test_rls_security.sql"
    "$DB_DIR/queries/test_v3_interface.sql"
)

validate_count=0
error_count=0

for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗ File not found: $(basename "$file")${NC}"
        ((error_count++))
        continue
    fi

    # Basic SQL syntax checks
    basename_file=$(basename "$file")
    echo -n "Checking $basename_file... "

    # Check for common syntax errors
    errors=""

    # Check for unmatched quotes
    if ! awk 'BEGIN{q=0} {for(i=1;i<=length($0);i++){c=substr($0,i,1);if(c=="\"\""){q=!q}}} END{exit q}' "$file" 2>/dev/null; then
        errors="$errors\n  - Unmatched quotes"
    fi

    # Check for basic SQL keywords presence (CREATE, SELECT, etc.)
    if ! grep -qi "CREATE\|SELECT\|INSERT\|ALTER" "$file"; then
        errors="$errors\n  - No SQL commands found"
    fi

    # Check for common typos
    if grep -qi "FORM " "$file"; then  # Common typo: FORM instead of FROM
        errors="$errors\n  - Possible typo: 'FORM' instead of 'FROM'"
    fi

    # Check for unmatched parentheses (basic check)
    open_paren=$(grep -o "(" "$file" | wc -l)
    close_paren=$(grep -o ")" "$file" | wc -l)
    if [ "$open_paren" -ne "$close_paren" ]; then
        errors="$errors\n  - Unmatched parentheses (open: $open_paren, close: $close_paren)"
    fi

    if [ -z "$errors" ]; then
        echo -e "${GREEN}✓${NC}"
        ((validate_count++))
    else
        echo -e "${RED}✗${NC}"
        echo -e "$errors"
        ((error_count++))
    fi
done

echo ""
echo "========================================"
if [ $error_count -eq 0 ]; then
    echo -e "${GREEN}✓ All files passed basic validation${NC}"
    echo "Files validated: $validate_count"
else
    echo -e "${YELLOW}⚠ Some files have potential issues${NC}"
    echo "Passed: $validate_count"
    echo "Errors: $error_count"
fi
echo "========================================"
echo ""
echo -e "${YELLOW}NOTE: This is basic syntax validation only.${NC}"
echo "For comprehensive testing, run:"
echo "  ./run_tests_docker.sh  (requires Docker)"
echo ""
echo "Or on an existing PostgreSQL instance:"
echo "  ./run_all_tests.sh"
echo ""
