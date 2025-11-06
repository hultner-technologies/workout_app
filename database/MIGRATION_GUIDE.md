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

```bash
psql -d workout_app -f database/250_empty_workout_support.sql
psql -d workout_app -f database/260_rls_policies.sql
```

## Functions

### `draft_session_exercises(uuid)`
Main function - returns session with exercises JSON array.

### `performed_session_details(uuid)`
Quick metadata check without exercises.

### `session_schedule_with_exercises` view
For fetching workout templates.

## Usage

### Python
```python
result = await db.fetch_one(
    "SELECT * FROM draft_session_exercises($1)",
    session_id
)
if not result:
    raise HTTPException(404)
return result
```

### TypeScript/Supabase
```typescript
const { data } = await supabase
  .rpc('draft_session_exercises', { performed_session_id_: sessionId })
  .single();

if (!data) throw new Error('Not found');
console.log(`${data.exercise_count} exercises`);
```

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
