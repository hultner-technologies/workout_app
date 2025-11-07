# Fix Test Data and Validation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix critical test infrastructure issues preventing proper validation of empty workout support feature.

**Architecture:** Replace invalid test UUIDs with valid hex values, add proper error detection to test runner, and update outdated documentation references.

**Tech Stack:** PostgreSQL 16, Bash scripting, SQL test scripts, Docker

---

## Background

The code review identified critical issues:
1. Test data uses invalid UUIDs (e.g., 's1111111...' where 's' is not valid hex)
2. Test runner reports "All tests passed!" despite SQL errors
3. RLS policy comments reference deprecated function names

These issues create false confidence in untested code and must be fixed before merge.

---

## Task 1: Fix Invalid UUIDs in insert_empty_workout.sql

**Files:**
- Modify: `database/queries/insert_empty_workout.sql:8,25`

**Step 1: Read current file to verify invalid UUIDs**

Run: `cat database/queries/insert_empty_workout.sql | grep -E "'[a-z][0-9a-f]{7}-'"`
Expected: Shows lines with 'e1111111...' and 's1111111...'

**Step 2: Replace invalid UUIDs with valid hex values**

Edit `database/queries/insert_empty_workout.sql`:

```sql
-- Line 8: Change 'e1111111...' to '11111111...'
INSERT INTO plan (plan_id, name, description)
VALUES (
    '11111111-1111-1111-1111-111111111111'::uuid,
    'Empty Workout',
    'A blank workout template for users to customize with their own exercises'
)

-- Line 25: Change 's1111111...' to 'a1111111...'
VALUES (
    'a1111111-1111-1111-1111-111111111111'::uuid,
    '11111111-1111-1111-1111-111111111111'::uuid,
    'Custom Workout',
    'Add your own exercises to this session',
    0.8
)
```

**Step 3: Verify UUIDs are valid hex**

Run: `grep -E "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}" database/queries/insert_empty_workout.sql`
Expected: Shows the fixed UUID lines (only hex digits 0-9, a-f)

**Step 4: Test SQL file syntax**

Run: `psql -d workout_app_test -f database/queries/insert_empty_workout.sql`
Expected: No "invalid input syntax for type uuid" errors

**Step 5: Commit**

```bash
git add database/queries/insert_empty_workout.sql
git commit -m "fix: replace invalid UUIDs in insert_empty_workout.sql test data"
```

---

## Task 2: Fix Invalid UUIDs in test_empty_workout.sql

**Files:**
- Modify: `database/queries/test_empty_workout.sql:13,19,25,38,50,64,76`

**Step 1: Create UUID mapping for consistency**

Document the UUID mapping:
```
OLD → NEW (valid hex)
'e1111111...' → '11111111-1111-1111-1111-111111111111' (plan)
's1111111...' → 'a1111111-1111-1111-1111-111111111111' (session_schedule)
'u1111111...' → 'b1111111-1111-1111-1111-111111111111' (app_user)
'p1111111...' → 'c1111111-1111-1111-1111-111111111111' (performed_session)
```

**Step 2: Replace all invalid UUIDs in test file**

Edit `database/queries/test_empty_workout.sql`:

```sql
-- Line 13: plan_id
WHERE plan_id = '11111111-1111-1111-1111-111111111111'::uuid;

-- Line 19: session_schedule_id
WHERE session_schedule_id = 'a1111111-1111-1111-1111-111111111111'::uuid;

-- Line 25: session_schedule_id
WHERE session_schedule_id = 'a1111111-1111-1111-1111-111111111111'::uuid;

-- Line 32: session_schedule_id
WHERE session_schedule_id = 'a1111111-1111-1111-1111-111111111111'::uuid;

-- Line 38: app_user_id
VALUES ('b1111111-1111-1111-1111-111111111111'::uuid, 'Test User')

-- Line 50: performed_session_id, session_schedule_id, app_user_id
VALUES (
    'c1111111-1111-1111-1111-111111111111'::uuid,
    'a1111111-1111-1111-1111-111111111111'::uuid,
    'b1111111-1111-1111-1111-111111111111'::uuid,
    NOW()
)

-- Line 64: performed_session_id
FROM draft_session_exercises('c1111111-1111-1111-1111-111111111111'::uuid);

-- Line 76: performed_session_id
WHERE ps.performed_session_id = 'c1111111-1111-1111-1111-111111111111'::uuid;
```

**Step 3: Verify all UUIDs are valid**

Run: `grep -o "'[^']*'::uuid" database/queries/test_empty_workout.sql | sort -u`
Expected: All UUIDs contain only hex digits (0-9, a-f)

**Step 4: Test SQL file**

Run: `psql -d workout_app_test -f database/queries/test_empty_workout.sql 2>&1 | grep "ERROR"`
Expected: Exit code 1 (no errors found)

**Step 5: Commit**

```bash
git add database/queries/test_empty_workout.sql
git commit -m "fix: replace invalid UUIDs in test_empty_workout.sql"
```

---

## Task 3: Fix Invalid UUIDs in verify_empty_workout_fix.sql

**Files:**
- Modify: `database/queries/verify_empty_workout_fix.sql` (all UUID references)

**Step 1: Identify all UUID references in file**

Run: `grep -n "'[a-z][0-9]*-" database/queries/verify_empty_workout_fix.sql | head -20`
Expected: Shows lines with invalid UUIDs

**Step 2: Replace with consistent mapping**

Edit `database/queries/verify_empty_workout_fix.sql` using the same mapping:
- `'e1111111...'` → `'11111111-1111-1111-1111-111111111111'`
- `'s1111111...'` → `'a1111111-1111-1111-1111-111111111111'`
- `'u1111111...'` → `'b1111111-1111-1111-1111-111111111111'`
- `'p1111111...'` → `'c1111111-1111-1111-1111-111111111111'`
- Any `'x...'` or test UUIDs → valid hex alternatives

**Step 3: Verify consistency across test files**

Run:
```bash
echo "=== insert_empty_workout.sql UUIDs ==="
grep -o "'[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}'::uuid" database/queries/insert_empty_workout.sql | sort -u

echo "=== test_empty_workout.sql UUIDs ==="
grep -o "'[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}'::uuid" database/queries/test_empty_workout.sql | sort -u

echo "=== verify_empty_workout_fix.sql UUIDs ==="
grep -o "'[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}'::uuid" database/queries/verify_empty_workout_fix.sql | sort -u
```
Expected: Matching UUIDs across files for same entities

**Step 4: Test SQL file**

Run: `psql -d workout_app_test -f database/queries/verify_empty_workout_fix.sql 2>&1 | tee /tmp/verify_test.log && ! grep -i "ERROR" /tmp/verify_test.log`
Expected: Exit code 0 (no errors)

**Step 5: Commit**

```bash
git add database/queries/verify_empty_workout_fix.sql
git commit -m "fix: replace invalid UUIDs in verify_empty_workout_fix.sql"
```

---

## Task 4: Fix Invalid UUIDs in test_rls_security.sql

**Files:**
- Modify: `database/queries/test_rls_security.sql:28,39,56,64,66,93,103,111,139,149`

**Step 1: Define RLS test UUID mapping**

```
Alice user: '11111111-1111-1111-1111-111111111111'
Bob user:   '22222222-2222-2222-2222-222222222222'
Plan:       'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
Session:    'aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbbbbbb'
Alice PS:   'aaaaaaaa-1111-1111-1111-111111111111'
Bob PS:     'bbbbbbbb-2222-2222-2222-222222222222'
Alice PE:   'aaaaaaaa-1111-eeee-eeee-eeeeeeeeeeee'
Bob PE:     'bbbbbbbb-2222-eeee-eeee-eeeeeeeeeeee'
Empty PS:   'eeeeeeee-1111-1111-1111-111111111111'
```

**Step 2: Replace all invalid UUID references**

Edit `database/queries/test_rls_security.sql`:

Lines to change:
- Line 28, 39: Alice/Bob app_user_id (already valid '11111111...' and '22222222...')
- Line 56, 62: Plan and session schedule (change 'aaaaaaaa...' and 'ssssssss...')
- Line 66: session_schedule_id change to valid hex
- Line 93, 103, 111: performed_session UUIDs
- Line 139, 149: performed_exercise UUIDs
- Any 'empty-ps...' or 'empty111...' format UUIDs

**Step 3: Verify no invalid UUIDs remain**

Run: `grep -n "'[a-z][0-9]" database/queries/test_rls_security.sql`
Expected: Exit code 1 (no matches found)

**Step 4: Test RLS SQL file**

Run: `psql -d workout_app_test -f database/queries/test_rls_security.sql 2>&1 | grep -i "ERROR" | wc -l`
Expected: 0 (no errors)

**Step 5: Commit**

```bash
git add database/queries/test_rls_security.sql
git commit -m "fix: replace invalid UUIDs in test_rls_security.sql"
```

---

## Task 5: Add Error Detection to Test Runner

**Files:**
- Modify: `database/queries/run_tests_docker.sh:100-180` (approximate line range)

**Step 1: Read current test runner implementation**

Run: `grep -A 5 "psql.*test_empty_workout.sql" database/queries/run_tests_docker.sh`
Expected: Shows current test execution without error checking

**Step 2: Create test for error detection**

Write test to verify error checking works:

```bash
# In /tmp/test_error_detection.sh
#!/bin/bash
set -e

# Test that we can detect SQL errors
OUTPUT=$(echo "SELECT 'invalid'::uuid;" | psql -d workout_app_test 2>&1 || true)
if echo "$OUTPUT" | grep -q "ERROR"; then
    echo "✓ Error detection works"
    exit 0
else
    echo "✗ Error detection failed"
    exit 1
fi
```

Run: `bash /tmp/test_error_detection.sh`
Expected: "✓ Error detection works"

**Step 3: Add error checking after each test file execution**

Edit `database/queries/run_tests_docker.sh`:

Find the section that runs test files (around line 120-180) and add error checking:

```bash
# After applying schema files
echo ""
echo -e "${BLUE}Step 6: Run empty workout test${NC}"
echo -e "${YELLOW}Running test_empty_workout.sql...${NC}"
TEST_OUTPUT=$(psql -h localhost -p 5433 -U postgres -d workout_app_test \
    -f ../test_empty_workout.sql 2>&1)
echo "$TEST_OUTPUT"

# Check for errors
if echo "$TEST_OUTPUT" | grep -i "^ERROR:" > /dev/null; then
    echo -e "${RED}✗ test_empty_workout.sql failed with errors${NC}"
    exit 1
fi
echo -e "${GREEN}✓ test_empty_workout.sql completed${NC}"

# Repeat for verify_empty_workout_fix.sql
echo ""
echo -e "${BLUE}Step 7: Verify the fix${NC}"
echo -e "${YELLOW}Running verify_empty_workout_fix.sql...${NC}"
TEST_OUTPUT=$(psql -h localhost -p 5433 -U postgres -d workout_app_test \
    -f ../verify_empty_workout_fix.sql 2>&1)
echo "$TEST_OUTPUT"

if echo "$TEST_OUTPUT" | grep -i "^ERROR:" > /dev/null; then
    echo -e "${RED}✗ verify_empty_workout_fix.sql failed with errors${NC}"
    exit 1
fi
echo -e "${GREEN}✓ verify_empty_workout_fix.sql completed${NC}"

# Repeat for test_rls_security.sql
echo ""
echo -e "${BLUE}Step 8: Test Row Level Security${NC}"
echo -e "${YELLOW}Running RLS security tests...${NC}"
TEST_OUTPUT=$(psql -h localhost -p 5433 -U postgres -d workout_app_test \
    -f ../test_rls_security.sql 2>&1)
echo "$TEST_OUTPUT"

if echo "$TEST_OUTPUT" | grep -i "^ERROR:" > /dev/null; then
    echo -e "${RED}✗ test_rls_security.sql failed with errors${NC}"
    exit 1
fi
echo -e "${GREEN}✓ test_rls_security.sql completed${NC}"
```

**Step 4: Test error detection with intentional error**

Run:
```bash
# Create test with intentional error
echo "SELECT 'invalid'::uuid;" > /tmp/test_fail.sql

# Run modified test runner with bad test
cd database/queries
./run_tests_docker.sh
```
Expected: Script exits with code 1 and shows error message

**Step 5: Commit**

```bash
git add database/queries/run_tests_docker.sh
git commit -m "fix: add SQL error detection to test runner

- Capture test output to variable
- Check for ERROR: prefix in output
- Exit with code 1 if errors detected
- Prevents false positive 'All tests passed' messages"
```

---

## Task 6: Update RLS Policy Comments

**Files:**
- Modify: `database/260_rls_policies.sql:340-348`

**Step 1: Identify outdated function references**

Run: `grep -n "draft_session_exercises_v2\|performed_session_exists" database/260_rls_policies.sql`
Expected: Shows lines 340 and 345 with outdated function names

**Step 2: Check actual function names in migration**

Run: `grep "CREATE OR REPLACE FUNCTION" database/250_empty_workout_support.sql | grep -E "draft_session_exercises|performed_session_details"`
Expected: Shows `draft_session_exercises(uuid)` and `performed_session_details(uuid)`

**Step 3: Update comments to match actual functions**

Edit `database/260_rls_policies.sql` lines 340-348:

```sql
-- =============================================================================
-- SECURITY NOTES FOR FUNCTIONS
-- =============================================================================

-- draft_session_exercises() uses:
--   - SECURITY INVOKER (explicitly set)
--   - LANGUAGE SQL
--   - Queries performed_session table which has RLS
--   - Will automatically filter to only the user's own sessions
--
-- performed_session_details() uses:
--   - SECURITY INVOKER (explicitly set)
--   - LANGUAGE SQL
--   - Queries performed_session table which has RLS
--   - Will automatically filter to only the user's own sessions
--
-- session_schedule_with_exercises view uses:
--   - security_invoker=on
--   - Queries public tables (plan, session_schedule, exercise)
--   - Respects RLS on underlying tables
--
-- Both functions are secure because they:
-- 1. Use SECURITY INVOKER (explicitly set in function definitions)
-- 2. Query tables with RLS enabled
-- 3. Respect the authenticated user's permissions

COMMENT ON FUNCTION draft_session_exercises(uuid) IS
    'Secure function that respects RLS policies. '
    'Uses SECURITY INVOKER to run with caller permissions. '
    'Automatically filters to only sessions owned by auth.uid().';

COMMENT ON FUNCTION performed_session_details(uuid) IS
    'Secure function that respects RLS policies. '
    'Uses SECURITY INVOKER to run with caller permissions. '
    'Automatically filters to only sessions owned by auth.uid().';
```

**Step 4: Verify no references to old function names**

Run: `grep -i "draft_session_exercises_v[0-9]\|performed_session_exists" database/260_rls_policies.sql`
Expected: Exit code 1 (no matches)

**Step 5: Commit**

```bash
git add database/260_rls_policies.sql
git commit -m "docs: update RLS comments to reference current function names

- draft_session_exercises_v2 → draft_session_exercises
- performed_session_exists → performed_session_details
- Add comment for session_schedule_with_exercises view"
```

---

## Task 7: Run Full Test Suite and Verify

**Files:**
- No file changes, verification only

**Step 1: Clean up any existing test containers**

Run: `docker rm -f workout_app_test_db 2>/dev/null || true`
Expected: Container removed or "No such container" message

**Step 2: Run complete test suite**

Run: `cd database/queries && ./run_tests_docker.sh`
Expected:
- All schema files apply without errors
- All test files execute without "ERROR:" lines
- Output shows "✓" markers for each test
- Final message: "All tests passed!"

**Step 3: Verify test data was actually inserted**

Run:
```bash
docker exec -it workout_app_test_db psql -U postgres -d workout_app_test -c "SELECT COUNT(*) FROM plan WHERE plan_id = '11111111-1111-1111-1111-111111111111'::uuid;"
```
Expected: count = 1 (data actually inserted)

**Step 4: Verify error detection works**

Create intentional error and verify it's caught:
```bash
# Add invalid SQL to test file temporarily
echo "SELECT 'INVALID'::uuid;" >> database/queries/test_empty_workout.sql
cd database/queries && ./run_tests_docker.sh
# Should exit with error

# Restore file
git checkout database/queries/test_empty_workout.sql
```
Expected: Script exits with code 1, shows error message

**Step 5: Verify RLS policies are working**

Run RLS-specific checks:
```bash
# Check that RLS is enabled on critical tables
docker exec -it workout_app_test_db psql -U postgres -d workout_app_test -c "
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('performed_session', 'performed_exercise', 'app_user')
ORDER BY tablename;"
```
Expected: All tables show `rowsecurity = true`

Check RLS policies exist:
```bash
docker exec -it workout_app_test_db psql -U postgres -d workout_app_test -c "
SELECT schemaname, tablename, policyname, cmd
FROM pg_policies
WHERE tablename IN ('performed_session', 'performed_exercise')
ORDER BY tablename, policyname;"
```
Expected: Multiple policies per table (SELECT, INSERT, UPDATE, DELETE)

Verify test data isolation:
```bash
# Should see test data for both users
docker exec -it workout_app_test_db psql -U postgres -d workout_app_test -c "
SELECT app_user_id, COUNT(*) as session_count
FROM performed_session
GROUP BY app_user_id
ORDER BY app_user_id;"
```
Expected: At least 2 different app_user_ids with sessions

**Step 6: Document test results**

Run: `cd database/queries && ./run_tests_docker.sh 2>&1 | tee /tmp/test_results.log`

Verify log contains:
- No "ERROR:" lines (except in comments/echo statements)
- "✓" markers for all test phases
- Actual query results (not empty)
- RLS security test output
- Final success message

Expected: Clean test run with verified data insertion and RLS verification

**Step 7: Commit verification documentation**

```bash
git add docs/plans/2025-11-07-fix-test-data-and-validation.md
git commit -m "docs: add implementation plan for test infrastructure fixes"
```

---

## Task 8: Update Documentation with UUID Mapping

**Files:**
- Modify: `database/TESTING_INSTRUCTIONS.md` (add UUID reference section)

**Step 1: Add UUID reference section**

Edit `database/TESTING_INSTRUCTIONS.md` after line 50 (in Quick Start section):

```markdown
### Test Data UUIDs

The test suite uses these consistent UUIDs:

**Empty Workout Test:**
- Plan: `11111111-1111-1111-1111-111111111111`
- Session Schedule: `a1111111-1111-1111-1111-111111111111`
- App User: `b1111111-1111-1111-1111-111111111111`
- Performed Session: `c1111111-1111-1111-1111-111111111111`

**RLS Security Test:**
- Alice User: `11111111-1111-1111-1111-111111111111`
- Bob User: `22222222-2222-2222-2222-222222222222`
- Test Plan: `aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa`
- Test Session: `aaaaaaaa-aaaa-aaaa-aaaa-bbbbbbbbbbbb`

**Note:** All UUIDs use valid hexadecimal characters (0-9, a-f) only.
```

**Step 2: Update error troubleshooting section**

Add to "Common Issues" section (around line 256):

```markdown
### Issue: "invalid input syntax for type uuid"

**Cause:** UUID contains invalid characters (must be 0-9 or a-f)

**Fix:**
```bash
# Check for invalid UUIDs in test files
grep -n "'[^0-9a-f-]" database/queries/*.sql

# Valid UUID format: [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}
```

### Issue: "All tests passed" but data not inserted

**Cause:** Test runner not detecting SQL errors

**Fix:**
```bash
# Verify error detection works
echo "SELECT 'invalid'::uuid;" | psql -d workout_app_test
# Should show ERROR

# Check test runner has error detection
grep "grep -i.*ERROR" database/queries/run_tests_docker.sh
```
```

**Step 3: Verify documentation accuracy**

Run through Quick Start instructions manually:
```bash
cd database/queries
./run_tests_docker.sh
```
Expected: All instructions work as documented

**Step 4: Commit documentation updates**

```bash
git add database/TESTING_INSTRUCTIONS.md
git commit -m "docs: add UUID reference and error troubleshooting

- Document test data UUID mapping for reference
- Add troubleshooting for invalid UUID errors
- Add troubleshooting for false positive test results"
```

---

## Verification Checklist

After completing all tasks, verify:

- [ ] All test files use valid hexadecimal UUIDs (0-9, a-f only)
- [ ] Test runner detects and reports SQL errors
- [ ] Test runner exits with code 1 on errors
- [ ] Full test suite runs without errors
- [ ] Test data is actually inserted (not just schema applied)
- [ ] RLS policy comments reference current function names
- [ ] Documentation includes UUID reference
- [ ] All commits follow conventional commit format

Run: `cd database/queries && ./run_tests_docker.sh && echo "✓ ALL CHECKS PASSED"`
Expected: Complete test run with success message

---

## Skills Referenced

- **@superpowers:verification-before-completion** - Run verification commands before claiming success
- **@superpowers:test-driven-development** - Verify tests fail before fixing (error detection test)

---

## Notes for Engineer

**UUID Format:** PostgreSQL UUIDs must contain only hexadecimal digits (0-9, a-f). Characters like 's', 'u', 'p', 'e', 'x' are NOT valid hexadecimal and cause "invalid input syntax" errors.

**Error Detection:** Bash scripts need explicit error checking. PostgreSQL errors don't automatically fail the script unless you check for them.

**Test Verification:** Always verify test data is actually inserted, not just that the script completes. Use `SELECT COUNT(*)` queries to confirm.

**Commit Frequency:** Commit after each task (every 5-15 minutes). Small commits make it easy to revert if something breaks.
