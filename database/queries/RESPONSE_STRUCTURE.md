# Response Structure for draft_session_exercises_v2

## Function Signature

```sql
draft_session_exercises_v2(performed_session_id uuid)
```

## Return Type

```sql
RETURNS TABLE (
    exercise_id uuid,
    performed_session_id uuid,
    name text,
    reps int[],
    rest interval[],
    weight int,
    session_schedule_id uuid,
    session_name text,
    has_exercises boolean
)
```

## Example Responses

### Case 1: Empty Workout (0 exercises)

**SQL Query:**
```sql
SELECT * FROM draft_session_exercises_v2('p1111111-1111-1111-1111-111111111111'::uuid);
```

**Response:**
```json
[
  {
    "exercise_id": null,
    "performed_session_id": "p1111111-1111-1111-1111-111111111111",
    "name": null,
    "reps": null,
    "rest": null,
    "weight": null,
    "session_schedule_id": "s1111111-1111-1111-1111-111111111111",
    "session_name": "Empty Workout",
    "has_exercises": false
  }
]
```

**Characteristics:**
- Returns **1 row** even with no exercises
- `has_exercises = false` indicates empty workout
- `exercise_id`, `name`, `reps`, `rest`, `weight` are `null`
- `session_schedule_id` and `session_name` always populated
- Clear distinction from "session doesn't exist" (0 rows)

### Case 2: Workout with 3 Exercises

**SQL Query:**
```sql
SELECT * FROM draft_session_exercises_v2('p2222222-2222-2222-2222-222222222222'::uuid);
```

**Response:**
```json
[
  {
    "exercise_id": "e0000001-0000-0000-0000-000000000001",
    "performed_session_id": "p2222222-2222-2222-2222-222222222222",
    "name": "Bench Press",
    "reps": [10, 10, 10, 10, 10],
    "rest": ["00:01:00", "00:01:00", "00:01:00", "00:01:00", "00:01:00"],
    "weight": 50000,
    "session_schedule_id": "s2222222-2222-2222-2222-222222222222",
    "session_name": "Push Day",
    "has_exercises": true
  },
  {
    "exercise_id": "e0000001-0000-0000-0000-000000000002",
    "performed_session_id": "p2222222-2222-2222-2222-222222222222",
    "name": "Overhead Press",
    "reps": [8, 8, 8, 8, 8],
    "rest": ["00:01:30", "00:01:30", "00:01:30", "00:01:30", "00:01:30"],
    "weight": 35000,
    "session_schedule_id": "s2222222-2222-2222-2222-222222222222",
    "session_name": "Push Day",
    "has_exercises": true
  },
  {
    "exercise_id": "e0000001-0000-0000-0000-000000000003",
    "performed_session_id": "p2222222-2222-2222-2222-222222222222",
    "name": "Dips",
    "reps": [12, 12, 12, 12, 12],
    "rest": ["00:01:00", "00:01:00", "00:01:00", "00:01:00", "00:01:00"],
    "weight": 0,
    "session_schedule_id": "s2222222-2222-2222-2222-222222222222",
    "session_name": "Push Day",
    "has_exercises": true
  }
]
```

**Characteristics:**
- Returns **N rows** (one per exercise)
- `has_exercises = true` on all rows
- All exercise fields populated
- Weight is in grams (50000 = 50kg)
- Rest intervals in PostgreSQL interval format

### Case 3: Non-existent Session

**SQL Query:**
```sql
SELECT * FROM draft_session_exercises_v2('00000000-0000-0000-0000-000000000000'::uuid);
```

**Response:**
```json
[]
```

**Characteristics:**
- Returns **0 rows** (empty array)
- Clear indication that session doesn't exist
- Distinct from empty workout case

## Comparison with Original Function

### Original `draft_session_exercises()`

| Scenario | Rows Returned | Can Distinguish? |
|----------|---------------|------------------|
| Non-existent session | 0 | ❌ No |
| Empty workout | 0 | ❌ No |
| 3 exercises | 3 | ✅ Yes |

**Problem:** Cannot distinguish between "doesn't exist" and "exists but empty"

### New `draft_session_exercises_v2()`

| Scenario | Rows Returned | Can Distinguish? |
|----------|---------------|------------------|
| Non-existent session | 0 | ✅ Yes (0 rows) |
| Empty workout | 1 (with nulls) | ✅ Yes (has_exercises=false) |
| 3 exercises | 3 | ✅ Yes (has_exercises=true) |

**Solution:** Clear distinction between all three cases

## API Usage Examples

### Python (FastAPI)

```python
from typing import Optional, List
from pydantic import BaseModel

class Exercise(BaseModel):
    exercise_id: Optional[uuid.UUID]
    performed_session_id: uuid.UUID
    name: Optional[str]
    reps: Optional[List[int]]
    rest: Optional[List[str]]
    weight: Optional[int]
    session_schedule_id: uuid.UUID
    session_name: str
    has_exercises: bool

@app.get("/performed-session/{session_id}/exercises")
async def get_session_exercises(session_id: uuid.UUID):
    result = await db.fetch_all(
        "SELECT * FROM draft_session_exercises_v2($1)",
        session_id
    )

    if not result:
        raise HTTPException(status_code=404, detail="Session not found")

    # Check if empty workout
    if result[0]['has_exercises'] is False:
        return {
            "session_id": session_id,
            "session_name": result[0]['session_name'],
            "exercises": [],
            "is_empty_template": True
        }

    # Return exercises
    return {
        "session_id": session_id,
        "session_name": result[0]['session_name'],
        "exercises": [dict(row) for row in result],
        "is_empty_template": False
    }
```

### TypeScript (Supabase Client)

```typescript
interface DraftExercise {
  exercise_id: string | null;
  performed_session_id: string;
  name: string | null;
  reps: number[] | null;
  rest: string[] | null;
  weight: number | null;
  session_schedule_id: string;
  session_name: string;
  has_exercises: boolean;
}

async function getSessionExercises(sessionId: string) {
  const { data, error } = await supabase
    .rpc('draft_session_exercises_v2', { performed_session_id_: sessionId });

  if (error) throw error;

  if (!data || data.length === 0) {
    throw new Error('Session not found');
  }

  const isEmptyWorkout = !data[0].has_exercises;

  return {
    sessionId,
    sessionName: data[0].session_name,
    exercises: isEmptyWorkout ? [] : data,
    isEmptyTemplate: isEmptyWorkout
  };
}
```

### JavaScript (Direct SQL)

```javascript
async function getSessionExercises(sessionId) {
  const result = await pool.query(
    'SELECT * FROM draft_session_exercises_v2($1)',
    [sessionId]
  );

  if (result.rows.length === 0) {
    return { error: 'Session not found', status: 404 };
  }

  const isEmptyWorkout = !result.rows[0].has_exercises;

  return {
    sessionId,
    sessionName: result.rows[0].session_name,
    exercises: isEmptyWorkout ? [] : result.rows,
    isEmptyTemplate: isEmptyWorkout,
    status: 200
  };
}
```

## Key Points

1. **Always check `has_exercises` field** to determine if workout is empty
2. **Empty workouts return 1 row** with exercise fields as `null`
3. **Non-existent sessions return 0 rows** (truly doesn't exist)
4. **Weight is in grams** (divide by 1000 for kg)
5. **Rest intervals** use PostgreSQL interval format (e.g., "00:01:00")
6. **Session metadata** always included (session_schedule_id, session_name)
