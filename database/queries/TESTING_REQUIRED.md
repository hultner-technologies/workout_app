# Testing Required - Empty Workout Fix & V3 Interface

## ⚠️ Important: Database Testing Needed

I was unable to run these tests in the Claude Code environment due to:
- No Docker/Podman available
- No PostgreSQL instance running
- Permission restrictions

**YOU NEED TO RUN THE TESTS** to verify everything works correctly.

## Quick Test (Recommended)

If you have Docker installed:

```bash
cd database/queries
./run_tests_docker.sh
```

This will:
1. ✅ Spin up PostgreSQL 16 in Docker
2. ✅ Apply all migrations
3. ✅ Run all tests (empty workout + RLS + v3)
4. ✅ Show you the actual responses
5. ✅ Clean up automatically

**Expected duration:** ~2-3 minutes

## What Will Be Tested

### 1. Empty Workout Support
- Creating a session schedule with 0 exercises
- Verifying `draft_session_exercises_v3()` returns 1 row with `exercises: []`
- Checking `has_exercises = false` flag

### 2. Row Level Security
- Users can only see their own performed sessions
- Alice cannot access Bob's workouts
- Functions respect `auth.uid()`

### 3. V3 Interface (JSON Aggregation)
- Single row response with nested exercises array
- Session metadata at top level (no repetition)
- Exercises ordered by `sort_order`
- Performance comparison with v2

## Expected V3 Response

### Empty Workout
```json
{
  "performed_session_id": "...",
  "session_schedule_id": "...",
  "session_name": "Empty Workout",
  "app_user_id": "...",
  "started_at": "...",
  "completed_at": null,
  "has_exercises": false,
  "exercise_count": 0,
  "exercises": []  ← Empty array
}
```

### Workout with Exercises
```json
{
  "performed_session_id": "...",
  "session_schedule_id": "...",
  "session_name": "Push Day",
  "app_user_id": "...",
  "started_at": "...",
  "completed_at": "...",
  "has_exercises": true,
  "exercise_count": 3,
  "exercises": [
    {
      "exercise_id": "...",
      "name": "Bench Press",
      "reps": [10, 10, 10, 10, 10],
      "rest": ["00:01:00", "00:01:00", "00:01:00", "00:01:00", "00:01:00"],
      "weight": 50000,
      "sort_order": 1
    },
    {
      "exercise_id": "...",
      "name": "Overhead Press",
      ...
    },
    {
      "exercise_id": "...",
      "name": "Dips",
      ...
    }
  ]
}
```

## Manual Testing (If No Docker)

### Step 1: Apply Migrations

```bash
psql -d your_database <<EOF
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
\i database/270_improved_session_interface.sql
EOF
```

### Step 2: Create Test Data

```bash
psql -d your_database -f database/queries/insert_empty_workout.sql
```

### Step 3: Test Empty Workout

```sql
-- Should return 1 row with exercises = []
SELECT * FROM draft_session_exercises_v3('s1111111-1111-1111-1111-111111111111'::uuid);
```

### Step 4: Test JSON Structure

```sql
-- Pretty print the JSON response
SELECT
    session_name,
    has_exercises,
    exercise_count,
    jsonb_pretty(exercises) as exercises_json
FROM draft_session_exercises_v3('your-session-uuid');
```

### Step 5: Compare v2 vs v3

```sql
-- v2: Returns 3 rows (repeated session info)
SELECT * FROM draft_session_exercises_v2('your-session-uuid');

-- v3: Returns 1 row (nested exercises)
SELECT * FROM draft_session_exercises_v3('your-session-uuid');
```

## Critical Test Cases

### ✅ Test 1: Empty Workout Returns Correct Structure
```sql
SELECT
    has_exercises,
    exercise_count,
    jsonb_array_length(exercises) as array_length
FROM draft_session_exercises_v3('empty-workout-uuid');
```

**Expected:**
- `has_exercises = false`
- `exercise_count = 0`
- `array_length = 0` (empty array, not null!)

### ✅ Test 2: Exercises Ordered Correctly
```sql
SELECT
    jsonb_array_elements(exercises)->>'name' as name,
    (jsonb_array_elements(exercises)->>'sort_order')::int as sort_order
FROM draft_session_exercises_v3('your-session-uuid');
```

**Expected:** Exercises in ascending `sort_order`

### ✅ Test 3: RLS Isolation
```sql
-- As User A
SET LOCAL role TO authenticated;
SET LOCAL request.jwt.claim.sub TO 'user-a-uuid';

-- Can see own session
SELECT COUNT(*) FROM draft_session_exercises_v3('user-a-session-uuid');
-- Expected: 1

-- Cannot see User B's session
SELECT COUNT(*) FROM draft_session_exercises_v3('user-b-session-uuid');
-- Expected: 0 (RLS blocks access)
```

### ✅ Test 4: JSON Structure Valid
```sql
-- Verify exercises is a valid JSON array
SELECT
    jsonb_typeof(exercises) as exercises_type,
    jsonb_typeof(exercises->0) as first_exercise_type
FROM draft_session_exercises_v3('your-session-uuid');
```

**Expected:**
- `exercises_type = 'array'`
- `first_exercise_type = 'object'`

## What Could Go Wrong

### Issue: Function Not Found
```
ERROR:  function draft_session_exercises_v3(uuid) does not exist
```

**Fix:** Apply migration `270_improved_session_interface.sql`

### Issue: RLS Denies Access
```
(No rows returned when you expect data)
```

**Fix:** Check you're authenticated as the correct user or disable RLS for testing:
```sql
ALTER TABLE performed_session DISABLE ROW LEVEL SECURITY;
```

### Issue: exercises is NULL instead of []
```json
{
  "exercises": null  // ← WRONG
}
```

**Fix:** There's a bug in the function. Check the COALESCE and FILTER clauses.

### Issue: Exercises Not Ordered
```json
{
  "exercises": [
    {"name": "Dips", "sort_order": 3},
    {"name": "Bench Press", "sort_order": 1},  // ← Wrong order
    ...
  ]
}
```

**Fix:** Check the `ORDER BY` clause in jsonb_agg.

## Validation Checklist

Before deploying to production:

- [ ] Run `./run_tests_docker.sh` successfully
- [ ] Verify empty workout returns `exercises: []`
- [ ] Verify exercises are ordered by `sort_order`
- [ ] Test RLS with two different users
- [ ] Verify v3 returns 1 row (not multiple)
- [ ] Check JSON structure is valid
- [ ] Test with Supabase authenticated users
- [ ] Verify performance is acceptable
- [ ] Update API endpoints to use v3
- [ ] Update frontend to consume new structure

## Files to Review

1. **270_improved_session_interface.sql** - Function definitions
2. **RESPONSE_V3.md** - API documentation
3. **test_v3_interface.sql** - Comprehensive tests
4. **run_tests_docker.sh** - Automated test runner

## After Testing

Once tests pass:

1. **Document results** - Add test output to this file
2. **Update API** - Migrate from v2 to v3
3. **Deploy migrations** - Apply 270_improved_session_interface.sql to production
4. **Monitor** - Check for any issues in production

## Help

If tests fail:
1. Check PostgreSQL version (requires 16+)
2. Review error messages in test output
3. Run individual test files to isolate issues
4. Check RLS policies are applied correctly

For questions about the implementation:
- See `RESPONSE_V3.md` for API documentation
- See `270_improved_session_interface.sql` for function definitions
- See `SECURITY_MODEL.md` for RLS details
