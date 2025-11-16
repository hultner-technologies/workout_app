# Empty Workout Support - Migration Guide

## What Was Changed

Fixed issue where session schedules with 0 exercises returned 0 rows, making it impossible to distinguish between "session doesn't exist" and "session exists but is empty".

## Solution

Added functions with JSON aggregation:
- **Always returns 1 row** (or 0 if truly doesn't exist)
- **Session metadata at top level**
- **Exercises as JSON array** (empty array for empty workouts)

## API Response

```json
{
  "performed_session_id": "...",
  "session_name": "Push Day",
  "has_exercises": true,
  "exercise_count": 3,
  "exercises": [
    {"exercise_id": "...", "name": "Bench Press", ...},
    {"exercise_id": "...", "name": "Squat", ...},
    {"exercise_id": "...", "name": "Deadlift", ...}
  ]
}
```

Empty workout:
```json
{
  "session_name": "Empty Workout",
  "has_exercises": false,
  "exercise_count": 0,
  "exercises": []
}
```

## Installation

### Production Deployment (Recommended)

Use transactions for safe deployment with automatic rollback on errors:

```sql
-- Connect to your database
psql -d workout_app

-- Start transaction
BEGIN;

-- Apply migrations
\i database/250_empty_workout_support.sql
\i database/260_rls_policies.sql

-- Verify functions exist
\df draft_session_exercises_v2
\df performed_session_details

-- Verify indexes exist
\di idx_performed_session_app_user_id
\di idx_performed_exercise_session_id

-- If everything looks good, commit
COMMIT;

-- If there are errors, rollback
-- ROLLBACK;
```

### Quick Install (Development)

```bash
psql -d workout_app -f database/250_empty_workout_support.sql
psql -d workout_app -f database/260_rls_policies.sql
```

### Rollback Procedure

If you need to rollback the migration:

```sql
-- Start transaction
BEGIN;

-- Remove RLS policies
DROP POLICY IF EXISTS "Allow read access for own performed_session" ON performed_session;
DROP POLICY IF EXISTS "Allow read access for anon performed_session" ON performed_session;
DROP POLICY IF EXISTS "Allow insert access for own performed_session" ON performed_session;
DROP POLICY IF EXISTS "Allow update access for own performed_session" ON performed_session;
DROP POLICY IF EXISTS "Allow delete access for own performed_session" ON performed_session;

DROP POLICY IF EXISTS "Allow read access for own performed_exercise" ON performed_exercise;
DROP POLICY IF EXISTS "Allow read access for anon performed_exercise" ON performed_exercise;
DROP POLICY IF EXISTS "Allow insert access for own performed_exercise" ON performed_exercise;
DROP POLICY IF EXISTS "Allow update access for own performed_exercise" ON performed_exercise;
DROP POLICY IF EXISTS "Allow delete access for own performed_exercise" ON performed_exercise;

-- Disable RLS
ALTER TABLE performed_session DISABLE ROW LEVEL SECURITY;
ALTER TABLE performed_exercise DISABLE ROW LEVEL SECURITY;

-- Remove indexes
DROP INDEX IF EXISTS idx_performed_session_app_user_id;
DROP INDEX IF EXISTS idx_performed_exercise_session_id;

-- Remove new functions (keeps original draft_session_exercises)
DROP FUNCTION IF EXISTS draft_session_exercises_v2(uuid);
DROP FUNCTION IF EXISTS performed_session_details(uuid);

-- Remove views
DROP VIEW IF EXISTS session_schedule_metadata;

-- Commit rollback
COMMIT;
```

## Functions

### `draft_session_exercises_v2(uuid)` ⭐ NEW
Main function - returns session with exercises JSON array.

**Breaking Change:** This is a **new function** with a different signature than the original `draft_session_exercises()`.

- **Old function** (still available): Returns multiple rows with flat structure
- **New function** (v2): Returns 1 row with JSON structure

**Migration path:** Update your API calls to use `draft_session_exercises_v2()` instead of `draft_session_exercises()`.

### `performed_session_details(uuid)`
Quick metadata check without exercises.

### `session_schedule_metadata` view
View showing session schedules with exercise counts (supports empty workouts).

## Usage

### Python
```python
# NEW: Use v2 function
result = await db.fetch_one(
    "SELECT * FROM draft_session_exercises_v2($1)",
    session_id
)
if not result:
    raise HTTPException(404)
return result
```

### TypeScript/Supabase
```typescript
// NEW: Use v2 function
const { data } = await supabase
  .rpc('draft_session_exercises_v2', { performed_session_id_: sessionId })
  .single();

if (!data) throw new Error('Not found');
console.log(`${data.exercise_count} exercises`);
```

### Backward Compatibility

The original `draft_session_exercises()` function is **still available** and unchanged.

If you have existing code using it, it will continue to work, but won't support empty workouts.

**Old function behavior:**
- Returns multiple rows (one per exercise)
- Returns 0 rows for empty workouts (cannot distinguish from "not found")
- Flat structure

**New v2 function behavior:**
- Returns 1 row with metadata + JSON exercises array
- Returns 1 row for empty workouts with `exercises: []`
- Can distinguish between "not found" (0 rows) and "empty" (1 row)

## Testing

```bash
./database/queries/run_tests_docker.sh
```

## Security

All functions use `SECURITY INVOKER` and respect RLS policies.

See: `database/queries/SECURITY_MODEL.md` for details.

## Files

**Migrations:**
- `database/250_empty_workout_support.sql` - Main functions
- `database/260_rls_policies.sql` - RLS security

**Tests:**
- `database/queries/test_empty_workout.sql`
- `database/queries/verify_empty_workout_fix.sql`
- `database/queries/test_rls_security.sql`

**Documentation:**
- `database/queries/README.md` - API reference
- `database/queries/SECURITY_MODEL.md` - Security guide
