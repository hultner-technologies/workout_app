# Exercise Sets Schema Refactor Migration

**Date**: 2025-11-21
**Status**: Ready for deployment
**Impact**: High - Updates core exercise tracking data model

## Overview

This migration completes the transition from the legacy `performed_exercise` single-weight data model to the modern `performed_exercise_set` table that supports advanced set types and per-set tracking.

## Background

### Historical Context (2019-2024)
- **Legacy model**: Stored a single weight with an array of reps per exercise
- **Limitations**:
  - Could not support drop-sets (varying weight per set)
  - Could not support pyramid sets
  - Could not track individual set notes or timing
  - Could not differentiate set types (warm-up vs. working sets)

### New Model (2024-Present)
- **Current model**: Separate `performed_exercise_set` table with per-set tracking
- **Capabilities**:
  - Per-set weight, reps, rest intervals
  - Set types: regular, warm-up, drop-set, pyramid-set, myo-rep, super-set, AMRAP
  - Individual set notes and timing
  - Nested sets for complex training protocols

### The Problem
While new workouts (since 2024) use `performed_exercise_set`, historical data (2019-2024) only existed in the legacy fields. Additionally:
- Views aggregating stats still used deprecated fields
- Python stats scripts read deprecated data directly
- No clear deprecation warnings prevented new code from using legacy fields

## Migration Components

### 1. Data Backfill (270_backfill_exercise_sets.sql)

**What it does**:
- Backfills all historical performed exercises to `performed_exercise_set` table
- Only processes completed exercises with valid weight data
- Skips exercises that already have sets (prevents duplicates)

**Logic**:
- Creates one `performed_exercise_set` row per element in the `reps` array
- All sets marked as type 'regular'
- Weight is uniform across sets (legacy limitation)
- Exercise duration divided evenly across sets for timing
- Rest intervals preserved or set to default if not customized

**Performance**:
- Processes exercises chronologically
- Logs progress every 1000 exercises
- Creates indexes for efficient querying

### 2. View Updates

#### exercise_stats (280_update_exercise_stats_view.sql)
**Before**: Read `pe.weight`, `pe.reps` directly
**After**: Aggregates from `performed_exercise_set`:
- `weight`: MAX weight from all sets
- `reps`: ARRAY_AGG of reps ordered by set order
- `brzycki_1_rm_max`: Calculated from max reps across sets
- `volume_kg`: SUM of (weight × reps) for each set / 1000

**Impact**: Provides accurate historical and current stats

#### next_exercise_progression (290_update_next_exercise_progression_view.sql)
**Before**: Used `pe.weight`, `pe.reps` for progression logic
**After**: Aggregates from `performed_exercise_set`:
- Checks MIN(reps) from sets against progression limit
- Uses MAX(weight) from sets for recommendations

**Note**: View has known bug, not used in production. Updated for consistency.

### 3. Function Updates

#### draft_session_exercises (300_update_draft_session_exercises.sql)
**Critical**: This function is used by the mobile app!

**Before**: Used `pe.weight`, `pe.reps` for workout templates
**After**: Aggregates from `performed_exercise_set`:
- Determines success by checking MIN(reps) from sets
- Recommends weight based on MAX(weight) from previous sets
- Adds SECURITY INVOKER for RLS compliance

#### draft_session_exercises_v2 (310_update_draft_session_exercises_v2.sql)
**Critical**: This function is used by the mobile app!

**Before**: Used `pe.weight`, `pe.reps`
**After**: Same updates as v1, returns JSON format

### 4. Python Scripts (notebooks/stats.py)

**Before**:
```python
df = pd.read_sql("select * from performed_exercise", engine)
```

**After**:
```python
# Uses exercise_stats view which aggregates from performed_exercise_set
df = pd.read_sql("select * from exercise_stats", engine)
```

### 5. Deprecation Warnings

#### Schema Comments (320_deprecate_legacy_fields.sql)
- Table-level comments warning about deprecated fields
- Column-level comments on `weight`, `reps`, `sets`, `rest`
- Guidance comments on `performed_exercise_set` table

#### Source Code (070_PerformedExercise.sql)
- Inline comments marking deprecated section
- Clear warning blocks in schema definition
- Historical context explaining the change

## Deployment Order

**IMPORTANT**: These must be applied in order!

1. `270_backfill_exercise_sets.sql` - Backfill historical data
2. `280_update_exercise_stats_view.sql` - Update stats view
3. `290_update_next_exercise_progression_view.sql` - Update progression view
4. `300_update_draft_session_exercises.sql` - Update draft function v1
5. `310_update_draft_session_exercises_v2.sql` - Update draft function v2
6. `320_deprecate_legacy_fields.sql` - Add deprecation comments

## Testing Checklist

- [ ] Backfill completes without errors
- [ ] All completed exercises have corresponding sets
- [ ] `exercise_stats` view returns expected data
- [ ] Historical and recent exercises show correct stats
- [ ] `draft_session_exercises()` returns sensible workout templates
- [ ] `draft_session_exercises_v2()` returns correct JSON
- [ ] Python stats script generates graphs successfully
- [ ] Mobile app can create and view workouts
- [ ] 1RM calculations are accurate
- [ ] Volume calculations match expected values

## Verification Queries

### Check backfill completeness
```sql
-- Should return 0 if all completed exercises have sets
SELECT COUNT(*)
FROM performed_exercise pe
WHERE pe.completed_at IS NOT NULL
  AND pe.weight IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM performed_exercise_set pes
    WHERE pes.performed_exercise_id = pe.performed_exercise_id
  );
```

### Compare old vs new 1RM calculations
```sql
-- Compare legacy calculation with new calculation
SELECT
  name,
  date,
  -- Legacy calculation
  ROUND(weight * (36.0/(37.0-(SELECT MAX(r) FROM unnest(reps) r)))) as old_1rm,
  -- New calculation
  brzycki_1_rm_max as new_1rm
FROM exercise_stats
WHERE completed_at > '2025-01-01'
ORDER BY name, date DESC
LIMIT 20;
```

### Check set type distribution
```sql
-- Should be mostly 'regular' after backfill
SELECT exercise_set_type, COUNT(*)
FROM performed_exercise_set
GROUP BY exercise_set_type
ORDER BY COUNT(*) DESC;
```

## Rollback Plan

If issues are discovered:

1. **Views/Functions**: Can be rolled back independently by redeploying previous versions
2. **Backfill**: Cannot be easily rolled back - sets would need to be deleted
3. **Application code**: Update functions first, backfill last to minimize risk

**Recommended approach**: Test thoroughly in staging before production deployment.

## Future Work

After this migration is stable:

1. **Remove legacy fields**: In a future major version, consider removing `weight`, `reps`, `sets`, `rest` columns entirely
2. **Update mobile app**: Ensure app writes to `performed_exercise_set` directly (may already be doing this)
3. **Performance optimization**: Monitor query performance on aggregations
4. **Additional set types**: Consider adding more specialized set types as needed

## Related Files

- `database/070_PerformedExercise.sql` - Legacy table definition (updated with warnings)
- `database/071_SpecialSet.sql` - New table definitions
- `database/130_views_exercise_stats.sql` - Original stats view (replaced)
- `database/120_views_next_exercise_progression.sql` - Original progression view (replaced)
- `database/210_draft_session_exercises.sql` - Original draft function (replaced)
- `database/250_empty_workout_support.sql` - Original v2 function (replaced)
- `notebooks/stats.py` - Stats generation script (updated)

## Questions?

Contact: [Your team's contact info]

---

**Migration prepared by**: Claude (AI Assistant)
**Reviewed by**: [To be filled in]
**Deployed by**: [To be filled in]
**Deployment date**: [To be filled in]
