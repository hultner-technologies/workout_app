# Empty Workout Support - Database Migrations

## Overview

This adds support for empty workout templates (session schedules with 0 exercises) and provides a clean JSON aggregation interface for retrieving workout data.

## Problem

When a session schedule has no exercises, queries returned 0 rows, making it impossible to distinguish between:
- Session doesn't exist (0 rows)
- Session exists but has no exercises (0 rows)

## Solution

New functions use LEFT JOINs and JSON aggregation to:
- Always return 1 row for existing sessions (or 0 if truly doesn't exist)
- Return empty `exercises` array for empty workouts
- Provide clean structure: session metadata at top level, exercises nested

## API Response Format

### Empty Workout
```json
{
  "performed_session_id": "...",
  "session_name": "Empty Workout",
  "has_exercises": false,
  "exercise_count": 0,
  "exercises": []
}
```

### Workout with Exercises
```json
{
  "performed_session_id": "...",
  "session_name": "Push Day",
  "has_exercises": true,
  "exercise_count": 3,
  "exercises": [
    {"exercise_id": "...", "name": "Bench Press", "reps": [...], "weight": 50000},
    {"exercise_id": "...", "name": "Squat", ...},
    {"exercise_id": "...", "name": "Deadlift", ...}
  ]
}
```

## Installation

Apply migrations in order:

```bash
psql -d workout_app <<EOF
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
```

Or use Docker test runner:
```bash
./database/queries/run_tests_docker.sh
```

## Functions

### `draft_session_exercises_v2(uuid)` ⭐ NEW

Returns session with exercises as JSON array. **Use this for new code!**

**Usage:**
```sql
SELECT * FROM draft_session_exercises_v2('performed-session-id');
```

**Returns:**
- 1 row with session metadata + exercises array
- 0 rows if session doesn't exist
- Supports empty workouts with `has_exercises: false`

### `draft_session_exercises(uuid)` (Legacy)

Original function that returns multiple rows with flat structure. Kept for backward compatibility.

**Returns:**
- Multiple rows (one per exercise)
- 0 rows for empty workouts (ambiguous)

### `performed_session_details(uuid)`

Quick metadata check without exercises.

**Usage:**
```sql
SELECT * FROM performed_session_details('performed-session-id');
```

### `session_schedule_with_exercises` view

For fetching workout templates.

**Usage:**
```sql
SELECT * FROM session_schedule_with_exercises WHERE session_schedule_id = '...';
```

## API Usage

### Python / FastAPI

```python
result = await db.fetch_one(
    "SELECT * FROM draft_session_exercises_v2($1)",
    session_id
)

if not result:
    raise HTTPException(404, "Session not found")

return result  # Already in perfect format!
```

### TypeScript / Supabase

```typescript
const { data } = await supabase
  .rpc('draft_session_exercises_v2', { performed_session_id_: sessionId })
  .single(); // Always returns 1 row!

if (!data) throw new Error('Session not found');

console.log(`${data.exercise_count} exercises`);
data.exercises.forEach(ex => console.log(`- ${ex.name}`));
```

## Testing

```bash
# With Docker
./database/queries/run_tests_docker.sh

# Or manually
psql -d workout_app -f database/queries/test_empty_workout.sql
psql -d workout_app -f database/queries/verify_empty_workout_fix.sql
psql -d workout_app -f database/queries/test_rls_security.sql
```

## Security

All functions use `SECURITY INVOKER` and respect RLS policies.

See: [SECURITY_MODEL.md](./SECURITY_MODEL.md)

## Files

- **250_empty_workout_support.sql** - Main migration
- **260_rls_policies.sql** - RLS security policies
- **test_empty_workout.sql** - Problem demonstration
- **verify_empty_workout_fix.sql** - Solution verification
- **test_rls_security.sql** - Security tests
- **SECURITY_MODEL.md** - Complete security guide

## Migration Checklist

- [ ] Run tests: `./run_tests_docker.sh`
- [ ] Apply migrations to production
- [ ] Update API to use `draft_session_exercises_v2()`
- [ ] Use `.single()` in Supabase (always 1 row)
- [ ] Check `has_exercises` boolean
- [ ] Access exercises via `result.exercises`
