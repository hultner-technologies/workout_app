# Empty Workout Fix - Complete Summary

## Your Questions Answered

### 1. How does the SQL response from v2 look?

The `draft_session_exercises_v2()` function returns different responses based on the workout state:

#### ✅ Empty Workout (NEW Behavior)
```sql
SELECT * FROM draft_session_exercises_v2('empty-session-uuid');
```

**Returns 1 row:**
```json
{
  "exercise_id": null,
  "performed_session_id": "...",
  "name": null,
  "reps": null,
  "rest": null,
  "weight": null,
  "session_schedule_id": "s1111111-...",
  "session_name": "Empty Workout",
  "has_exercises": false  ← KEY FIELD
}
```

**Key Points:**
- Returns **1 row** (not 0!)
- `has_exercises = false` - indicates empty workout
- Exercise fields are `null`
- Session metadata is populated

#### ✅ Workout with Exercises
```json
[
  {
    "exercise_id": "e0001...",
    "name": "Bench Press",
    "reps": [10, 10, 10, 10, 10],
    "rest": ["00:01:00", "00:01:00", ...],
    "weight": 50000,
    "session_schedule_id": "s2222...",
    "session_name": "Push Day",
    "has_exercises": true  ← Always true when exercises exist
  },
  // ... more exercises
]
```

#### ✅ Non-existent Session
```json
[]  // Empty array - 0 rows
```

**Complete documentation:** `database/queries/RESPONSE_STRUCTURE.md`

### 2. Have you added proper ACL for Supabase?

**YES!** Comprehensive Row Level Security (RLS) policies added in `database/260_rls_policies.sql`.

#### Security Model

| Table | User Access | Anonymous Access |
|-------|-------------|------------------|
| `performed_session` | Own data only | Read all* |
| `performed_exercise` | Own data only | Read all* |
| `performed_exercise_set` | Own data only | None |
| `app_user` | Own profile only | None |
| `plan` | Read only | Read only |
| `session_schedule` | Read only | Read only |
| `exercise` | Read only | Read only |
| `base_exercise` | Read only | Read only |

*Anonymous read access can be disabled - see 260_rls_policies.sql lines 36-42 and 70-76

#### RLS Features

**✅ Multi-tenant isolation:**
- Users can only see their own workout sessions
- Alice cannot see Bob's exercises
- Enforced at database level

**✅ Security patterns:**
```sql
-- Users can only read their own sessions
CREATE POLICY "Allow read access for own performed_session"
    ON performed_session
    FOR SELECT
    TO authenticated
    USING (app_user_id = (SELECT auth.uid()));
```

**✅ Function security:**
- `draft_session_exercises_v2()` uses `SECURITY INVOKER`
- `performed_session_exists()` uses `SECURITY INVOKER`
- Both respect RLS policies automatically
- Views use `security_invoker=on`

**Complete documentation:** `database/queries/SECURITY_MODEL.md`

## What Was Fixed

### Problem
When creating a plan+schedule without exercises, queries returned **0 rows**, making it impossible to distinguish:
- ❌ Session doesn't exist (0 rows)
- ❌ Session exists but has no exercises (0 rows)

### Solution
Created new database objects that properly handle empty workouts:

1. **`session_schedule_metadata` view** - Shows all sessions with exercise counts
2. **`draft_session_exercises_v2()` function** - Returns session info even for empty workouts
3. **`performed_session_exists()` function** - Quick validation with `is_empty` flag
4. **Comprehensive RLS policies** - Multi-tenant data isolation

## Files Created

### Core Database Files
- `database/250_empty_workout_support.sql` - Empty workout fix (migration)
- `database/260_rls_policies.sql` - Row Level Security policies

### Test Files
- `database/queries/insert_empty_workout.sql` - Creates test empty workout
- `database/queries/test_empty_workout.sql` - Demonstrates the problem
- `database/queries/verify_empty_workout_fix.sql` - Verifies the fix works
- `database/queries/test_rls_security.sql` - Tests RLS data isolation

### Documentation
- `database/queries/README_empty_workout.md` - Usage guide
- `database/queries/RESPONSE_STRUCTURE.md` - API response format (answers Q1)
- `database/queries/SECURITY_MODEL.md` - RLS guide (answers Q2)
- `database/queries/SUMMARY.md` - This file

### Test Runners
- `database/queries/run_all_tests.sh` - Full test suite (requires PostgreSQL)
- `database/queries/run_tests_docker.sh` - Test with Docker (no install needed)

## How to Test

### Option 1: Docker (Easiest - No PostgreSQL needed)

```bash
cd database/queries
./run_tests_docker.sh
```

This will:
1. Start PostgreSQL 16 in Docker
2. Apply all schema files
3. Run empty workout tests
4. Run RLS security tests
5. Show complete results
6. Optionally clean up

### Option 2: Local PostgreSQL

```bash
cd database/queries
./run_all_tests.sh
```

Requires:
- PostgreSQL 16+ installed
- `psql` client available
- Permissions to create databases

### Option 3: Manual Testing

```bash
# Apply schema
psql -d your_db -f database/010_setup.sql
# ... apply all files in order ...
psql -d your_db -f database/250_empty_workout_support.sql
psql -d your_db -f database/260_rls_policies.sql

# Test
psql -d your_db -f database/queries/test_empty_workout.sql
psql -d your_db -f database/queries/verify_empty_workout_fix.sql
```

## API Migration Guide

### Before (Ambiguous)
```python
exercises = db.query("SELECT * FROM draft_session_exercises(?)", session_id)
if not exercises:
    # Problem: Does session exist? Or is it empty?
    return 404  # Wrong response for empty workouts!
```

### After (Clear)
```python
# Check existence first
session_info = db.query("SELECT * FROM performed_session_exists(?)", session_id)
if not session_info:
    return {"error": "Session not found"}, 404

# Handle empty workout
if session_info[0]['is_empty']:
    return {
        "session_id": session_id,
        "session_name": session_info[0]['session_name'],
        "exercises": [],
        "is_empty_template": True
    }, 200

# Load exercises
exercises = db.query("SELECT * FROM draft_session_exercises_v2(?)", session_id)
return {
    "session_id": session_id,
    "exercises": exercises,
    "is_empty_template": False
}, 200
```

### Supabase Example
```typescript
// Check if session exists and is empty
const { data: sessionInfo } = await supabase
  .rpc('performed_session_exists', { performed_session_id_: sessionId });

if (!sessionInfo || sessionInfo.length === 0) {
  throw new Error('Session not found');
}

const isEmpty = sessionInfo[0].is_empty;

// Load exercises (respects RLS automatically)
const { data: exercises } = await supabase
  .rpc('draft_session_exercises_v2', { performed_session_id_: sessionId });

return {
  sessionId,
  sessionName: exercises[0]?.session_name,
  exercises: isEmpty ? [] : exercises,
  isEmptyTemplate: isEmpty
};
```

## Security Testing in Supabase

1. **Create test users** in Supabase Auth:
   - Alice: `11111111-1111-1111-1111-111111111111`
   - Bob: `22222222-2222-2222-2222-222222222222`

2. **Set user context** in SQL Editor:
   ```sql
   SET LOCAL role TO authenticated;
   SET LOCAL request.jwt.claim.sub TO '11111111-1111-1111-1111-111111111111';
   ```

3. **Test isolation:**
   ```sql
   -- As Alice, should only see own sessions
   SELECT * FROM performed_session;

   -- As Alice, cannot see Bob's session
   SELECT * FROM performed_session
   WHERE app_user_id = '22222222-2222-2222-2222-222222222222';
   -- Returns 0 rows (RLS working!)
   ```

See `database/queries/test_rls_security.sql` for complete test suite.

## Performance Impact

**Minimal overhead:**
- Views use LEFT JOIN (slightly slower than INNER JOIN)
- RLS adds WHERE clause to queries (use indexes)
- Functions run with user permissions (no privilege escalation)

**Recommended indexes:**
```sql
CREATE INDEX idx_performed_session_user ON performed_session(app_user_id);
CREATE INDEX idx_performed_exercise_session ON performed_exercise(performed_session_id);
CREATE INDEX idx_exercise_schedule ON exercise(session_schedule_id);
```

## Migration Checklist

- [x] Empty workout support added (250_empty_workout_support.sql)
- [x] RLS policies added (260_rls_policies.sql)
- [x] Functions use SECURITY INVOKER
- [x] Views use security_invoker=on
- [x] Tests created and documented
- [x] Response structure documented
- [x] Security model documented
- [ ] Apply migrations to production database
- [ ] Update API endpoints to use v2 functions
- [ ] Test with real Supabase authenticated users
- [ ] Add indexes for performance
- [ ] Update frontend to handle `has_exercises` flag

## Next Steps

1. **Review the documentation:**
   - `RESPONSE_STRUCTURE.md` - Understand v2 response format
   - `SECURITY_MODEL.md` - Understand RLS policies

2. **Run tests:**
   ```bash
   ./database/queries/run_tests_docker.sh
   ```

3. **Apply to your database:**
   ```bash
   psql -d your_db -f database/250_empty_workout_support.sql
   psql -d your_db -f database/260_rls_policies.sql
   ```

4. **Update API endpoints:**
   - Use `draft_session_exercises_v2()` instead of v1
   - Check `has_exercises` field
   - Use `performed_session_exists()` for validation

5. **Test in Supabase:**
   - Create test users
   - Verify RLS isolation
   - Test empty workout creation

## Git Status

Branch: `claude/add-plan-schedule-011CUrWuCo8pBUqKMCXdp6Pb`

Commits:
1. `dd48897` - feat: Add support for empty workout templates
2. `3d25be9` - feat: Add comprehensive RLS policies and security documentation
3. `1eccefa` - feat: Add Docker-based test runner

All changes pushed to remote.

## Support

For questions:
- Empty workout usage → `README_empty_workout.md`
- Response structure → `RESPONSE_STRUCTURE.md`
- Security/RLS → `SECURITY_MODEL.md`
- Testing → Run `run_tests_docker.sh` or `run_all_tests.sh`
