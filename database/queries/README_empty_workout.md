# Empty Workout Fix

## Problem Description

When creating a "plan + schedule" without any exercises (empty workout template), the database queries return unexpected results that make it impossible to distinguish between two scenarios:

1. **Session does not exist**
2. **Session exists but has no exercises**

### Root Cause

The issue occurs because several views and functions use INNER JOINs with the `exercise` table:

- `full_exercise` view: Joins `exercise`, `base_exercise`, and `session_schedule`
- `draft_session_exercises()` function: Joins with `full_exercise` view

When a `session_schedule` has zero exercises, these INNER JOINs return **0 rows**, making it appear as if the session doesn't exist at all.

### Impact

- Empty workout templates become unusable
- API consumers cannot determine if a session exists
- Users cannot create blank workout templates to fill in later

## Solution

The fix provides three new database objects that handle empty workouts correctly:

### 1. `session_schedule_metadata` View

A helper view that shows ALL session schedules with their exercise counts.

```sql
SELECT * FROM session_schedule_metadata
WHERE session_schedule_id = 'your-uuid-here';
```

**Returns:**
- `session_schedule_id`: Session ID
- `name`: Session name
- `exercise_count`: Number of exercises (0 for empty)
- `is_empty`: Boolean flag (true if no exercises)
- Plan information

**Use case:** Checking if a session schedule exists and whether it has exercises.

### 2. `draft_session_exercises_v2()` Function

Enhanced version of `draft_session_exercises()` that returns session information even for empty workouts.

```sql
SELECT * FROM draft_session_exercises_v2('performed-session-uuid');
```

**Returns:**
- Exercise data (if any)
- Session metadata (always included)
- `has_exercises` flag
- `session_schedule_id` and `session_name`

**Use case:** Loading workout data for a performed session, including empty templates.

### 3. `performed_session_exists()` Function

Simple check to verify if a performed session exists and get its metadata.

```sql
SELECT * FROM performed_session_exists('performed-session-uuid');
```

**Returns 1 row if exists:**
- `exists`: true
- `exercise_count`: Number of exercises
- `is_empty`: Boolean flag
- Session and user information

**Returns 0 rows if session truly doesn't exist.**

**Use case:** Quick validation before loading session data.

## Installation

### Option 1: Quick Test (Development)

```bash
# Set up the database schema
psql -d workout_app -f database/010_setup.sql
psql -d workout_app -f database/020_AppUser.sql
psql -d workout_app -f database/030_Plan.sql
psql -d workout_app -f database/040_SessionSchedule.sql
psql -d workout_app -f database/050_PerformedSession.sql
psql -d workout_app -f database/060_Exercise.sql
# ... other schema files ...

# Insert the empty workout for testing
psql -d workout_app -f database/queries/insert_empty_workout.sql

# Apply the fix
psql -d workout_app -f database/queries/fix_empty_workout.sql

# Run tests
psql -d workout_app -f database/queries/test_empty_workout.sql
psql -d workout_app -f database/queries/verify_empty_workout_fix.sql
```

### Option 2: Production Deployment

The fix has been integrated into the main schema as migration `250_empty_workout_support.sql`.

```bash
# Apply the migration
psql -d workout_app -f database/250_empty_workout_support.sql
```

## Testing

### 1. Demonstrate the Problem

```bash
psql -d workout_app -f database/queries/test_empty_workout.sql
```

This shows how the old functions return 0 rows for empty workouts.

### 2. Verify the Fix

```bash
psql -d workout_app -f database/queries/verify_empty_workout_fix.sql
```

This demonstrates that the new functions properly handle empty workouts.

## Usage Examples

### Check if a session schedule is empty

```sql
-- Using the metadata view
SELECT name, exercise_count, is_empty
FROM session_schedule_metadata
WHERE session_schedule_id = 'your-uuid';

-- Result for empty workout:
-- name: "Empty Workout", exercise_count: 0, is_empty: true
```

### Load a performed session (empty or not)

```sql
-- New function handles both cases
SELECT * FROM draft_session_exercises_v2('performed-session-uuid');

-- If empty: returns 1 row with session info, has_exercises = false
-- If not empty: returns N rows (one per exercise), has_exercises = true
```

### Validate session exists before operations

```sql
-- Quick existence check
SELECT exists, is_empty
FROM performed_session_exists('performed-session-uuid');

-- Returns 0 rows = session doesn't exist
-- Returns 1 row = session exists (check is_empty flag)
```

## Migration Path

### For Existing Code

1. **Keep using original functions** for backward compatibility
2. **Use new functions** for features that need empty workout support
3. **Update API endpoints** to use `session_schedule_metadata` view

### Recommended API Changes

```python
# Before: Ambiguous result
exercises = db.query("SELECT * FROM draft_session_exercises(?)", session_id)
if not exercises:
    # Could mean: session doesn't exist OR session has no exercises
    # Unclear how to respond!

# After: Clear distinction
session_info = db.query("SELECT * FROM performed_session_exists(?)", session_id)
if not session_info:
    return 404  # Session doesn't exist

if session_info[0]['is_empty']:
    return 200, {"exercises": [], "message": "Empty workout template"}

exercises = db.query("SELECT * FROM draft_session_exercises_v2(?)", session_id)
return 200, {"exercises": exercises}
```

## Performance Impact

- **Minimal overhead**: New view uses LEFT JOIN and COUNT, cached by query planner
- **No table changes**: All changes are views/functions
- **Backward compatible**: Original functions unchanged

## Future Considerations

1. Consider renaming `draft_session_exercises_v2` to `draft_session_exercises` after migration
2. Add support for empty workouts in other views (if needed)
3. Update frontend to handle `is_empty` flag appropriately
4. Consider adding a UI indicator for empty workout templates
