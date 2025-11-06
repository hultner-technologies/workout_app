# Testing Instructions for Claude Code

## Quick Start (Recommended)

### Option 1: Docker (No PostgreSQL Installation Required)

**Prerequisites:**
- Docker installed (`docker --version`)

**Run Tests:**
```bash
cd database/queries
./run_tests_docker.sh
```

**What happens:**
1. Starts PostgreSQL 16 in Docker container
2. Applies all schema files in order
3. Runs 4 test suites:
   - Empty workout creation
   - Problem demonstration (old behavior)
   - Solution verification (new behavior)
   - RLS security tests
4. Shows you the actual responses
5. Asks if you want to keep container running

**Expected output:**
```
========================================
Test Suite Complete!
========================================

✓ All tests passed!

What was tested:
  1. Database schema setup (with RLS policies)
  2. Empty workout plan creation
  3. Problem demonstration (0 rows for empty workouts)
  4. Fix application (new views and functions)
  5. Verification (proper handling of empty workouts)
  6. Row Level Security (RLS) policies
  7. Function security (SECURITY INVOKER)
  8. Data isolation between users
```

---

## Option 2: Local PostgreSQL

### Prerequisites

**Check if PostgreSQL is installed:**
```bash
psql --version
# Should show: psql (PostgreSQL) 16.x
```

**If not installed:**
```bash
# macOS
brew install postgresql@16

# Ubuntu/Debian
sudo apt install postgresql-16

# Arch
sudo pacman -S postgresql
```

### Setup Test Database

**1. Start PostgreSQL:**
```bash
# macOS (Homebrew)
brew services start postgresql@16

# Linux
sudo systemctl start postgresql
```

**2. Create test database:**
```bash
createdb workout_app_test

# Or as postgres user
sudo -u postgres createdb workout_app_test
```

### Run Tests

**Automated (recommended):**
```bash
cd database/queries

# Set database connection (if needed)
export TEST_DB=workout_app_test
export POSTGRES_USER=your_username

./run_all_tests.sh
```

**Manual (step-by-step):**
```bash
# Apply schema
psql -d workout_app_test <<EOF
\i database/010_setup.sql
\i database/020_AppUser.sql
\i database/030_Plan.sql
\i database/040_SessionSchedule.sql
\i database/050_PerformedSession.sql
\i database/060_Exercise.sql
\i database/070_PerformedExercise.sql
\i database/071_SpecialSet.sql
\i database/090_ExerciseScheduleView.sql
\i database/110_views_full_exercise.sql
\i database/120_views_next_exercise_progression.sql
\i database/130_views_exercise_stats.sql
\i database/210_draft_session_exercises.sql
\i database/220_create_session_exercises.sql
\i database/230_session_helper_functions.sql
\i database/250_empty_workout_support.sql
\i database/260_rls_policies.sql
EOF

# Create test data
psql -d workout_app_test -f database/queries/insert_empty_workout.sql

# Run tests
psql -d workout_app_test -f database/queries/test_empty_workout.sql
psql -d workout_app_test -f database/queries/verify_empty_workout_fix.sql
psql -d workout_app_test -f database/queries/test_rls_security.sql
```

---

## What to Verify

### Test 1: Empty Workout Returns Correct Structure

**Run:**
```sql
SELECT
    jsonb_pretty(to_jsonb(result)) as response
FROM draft_session_exercises('empty-ps-1111-1111-111111111111'::uuid) as result;
```

**✅ Expected:**
```json
{
  "performed_session_id": "empty-ps-1111-1111-111111111111",
  "session_schedule_id": "empty111-1111-1111-1111-111111111111",
  "session_name": "Alice Empty Workout",
  "app_user_id": "11111111-1111-1111-1111-111111111111",
  "has_exercises": false,
  "exercise_count": 0,
  "exercises": []
}
```

**❌ FAIL if:**
- Returns 0 rows
- `exercises` is `null` instead of `[]`
- `has_exercises` is not `false`

### Test 2: Session with Exercises Returns JSON Array

**Run:**
```sql
SELECT
    session_name,
    has_exercises,
    exercise_count,
    jsonb_array_length(exercises) as array_length
FROM draft_session_exercises('p3333333-3333-3333-3333-333333333333'::uuid);
```

**✅ Expected:**
```
 session_name  | has_exercises | exercise_count | array_length
---------------+---------------+----------------+--------------
 Test Session  |     t         |              3 |            3
```

**❌ FAIL if:**
- Returns 0 rows
- Returns multiple rows
- `array_length` doesn't match `exercise_count`
- `has_exercises` is not `true`

### Test 3: Exercises Ordered by sort_order

**Run:**
```sql
SELECT
    jsonb_array_elements(exercises)->>'name' as name,
    (jsonb_array_elements(exercises)->>'sort_order')::int as sort_order
FROM draft_session_exercises('p3333333-3333-3333-3333-333333333333'::uuid);
```

**✅ Expected:**
```
     name     | sort_order
--------------+------------
 Bench Press  |          1
 Squat        |          2
 Deadlift     |          3
```

**❌ FAIL if:**
- Not ordered by `sort_order`
- Missing exercises

### Test 4: RLS Security (Critical!)

**Run:**
```sql
-- As superuser, can see all data
SELECT COUNT(*) as total_sessions
FROM performed_session;

-- Should show 2+ sessions (Alice's and Bob's)
```

**✅ Expected:**
```
 total_sessions
----------------
              2
(1 row)
```

**To test RLS properly in Supabase:**

See `database/queries/test_rls_security.sql` for manual RLS testing instructions with authenticated users.

### Test 5: Non-existent Session Returns 0 Rows

**Run:**
```sql
SELECT COUNT(*) as row_count
FROM draft_session_exercises('00000000-0000-0000-0000-000000000000'::uuid);
```

**✅ Expected:**
```
 row_count
-----------
         0
```

**❌ FAIL if:**
- Returns 1 row (should return nothing)

---

## Common Issues

### Issue: "function draft_session_exercises does not exist"

**Fix:**
```sql
-- Verify migration applied
\df draft_session_exercises

-- If not found, apply:
\i database/250_empty_workout_support.sql
```

### Issue: "relation full_exercise does not exist"

**Fix:**
```sql
-- Apply all schema files in order
\i database/110_views_full_exercise.sql
```

### Issue: Docker container won't start

**Fix:**
```bash
# Check if port 5433 is in use
lsof -i :5433

# Kill existing container
docker rm -f workout_app_test_db

# Try again
./run_tests_docker.sh
```

### Issue: "permission denied" on .sh files

**Fix:**
```bash
chmod +x database/queries/run_tests_docker.sh
chmod +x database/queries/run_all_tests.sh
```

---

## Success Criteria

Your tests are passing if:

- ✅ Empty workout returns 1 row with `exercises: []`
- ✅ Workout with exercises returns 1 row with nested array
- ✅ Non-existent session returns 0 rows
- ✅ Exercises ordered by `sort_order`
- ✅ `has_exercises` flag is accurate
- ✅ `exercise_count` matches array length
- ✅ JSON structure is valid
- ✅ No SQL errors in test output

---

## Quick Verification Commands

After running tests, verify with:

```sql
-- 1. Check functions exist
\df draft_session_exercises
\df performed_session_details

-- 2. Check views exist
\dv session_schedule_metadata
\dv session_schedule_with_exercises

-- 3. Test empty workout
SELECT has_exercises, exercise_count, exercises
FROM draft_session_exercises('empty-ps-1111-1111-111111111111'::uuid);

-- 4. Test metadata function
SELECT exists, is_empty, exercise_count
FROM performed_session_details('empty-ps-1111-1111-111111111111'::uuid);
```

**All should return data without errors.**

---

## Cleanup

### Docker
```bash
# Remove test container
docker rm -f workout_app_test_db

# Or let the script ask you
```

### Local PostgreSQL
```bash
# Drop test database
dropdb workout_app_test

# Or keep for manual testing
```

---

## Next Steps After Testing

Once all tests pass:

1. **Apply to production database:**
   ```bash
   psql -d workout_app_production -f database/250_empty_workout_support.sql
   psql -d workout_app_production -f database/260_rls_policies.sql
   ```

2. **Update API endpoints:**
   - Use `draft_session_exercises()` (no version suffix)
   - Use `.single()` in Supabase
   - Check `has_exercises` boolean

3. **Deploy and monitor:**
   - Watch for errors
   - Verify empty workouts work in UI
   - Test RLS with multiple users

---

## Files Reference

**Tests:**
- `database/queries/run_tests_docker.sh` - Automated Docker tests
- `database/queries/run_all_tests.sh` - Automated local tests
- `database/queries/test_empty_workout.sql` - Empty workout tests
- `database/queries/verify_empty_workout_fix.sql` - Verification
- `database/queries/test_rls_security.sql` - Security tests

**Documentation:**
- `database/MIGRATION_GUIDE.md` - Quick deployment guide
- `database/queries/README.md` - API reference
- `database/queries/SECURITY_MODEL.md` - Security details

---

## Help

If tests fail:
1. Check PostgreSQL version: `psql --version` (need 16+)
2. Review error messages in test output
3. Check schema files applied in order
4. Verify test data created: `SELECT * FROM session_schedule WHERE name = 'Empty Workout';`
5. Check this file for troubleshooting steps

If Docker tests fail:
1. Ensure Docker is running: `docker ps`
2. Check container logs: `docker logs workout_app_test_db`
3. Verify port 5433 is free: `lsof -i :5433`
