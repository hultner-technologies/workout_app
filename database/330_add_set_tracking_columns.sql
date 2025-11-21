-- database/330_add_set_tracking_columns.sql

-- Add columns to performed_exercise_set table
ALTER TABLE performed_exercise_set
  -- RIR tracking for effective volume calculations (optional - historical data won't have this)
  ADD COLUMN estimated_rir INTEGER,

  -- RPE tracking (Rate of Perceived Exertion, 1-10 scale, optional)
  ADD COLUMN rpe NUMERIC(3,1),

  -- Superset grouping (optional - links sets performed together)
  ADD COLUMN superset_group_id UUID,

  -- Calculated fields (auto-updated via trigger, nullable for historical data)
  ADD COLUMN effective_volume_kg NUMERIC(10,2),
  ADD COLUMN estimated_1rm_kg NUMERIC(10,2),
  ADD COLUMN relative_intensity NUMERIC(5,2);

-- Add comprehensive comments
COMMENT ON COLUMN performed_exercise_set.estimated_rir IS
  'Reps in reserve (0 = failure, 1-3 = optimal hypertrophy).
   NULLABLE - historical data will not have this field.
   When NULL, effective_volume_kg uses unadjusted volume.';

COMMENT ON COLUMN performed_exercise_set.rpe IS
  'Rate of perceived exertion (1-10 scale, often matches 10-RIR).
   NULLABLE - optional field for users who track RPE.';

COMMENT ON COLUMN performed_exercise_set.superset_group_id IS
  'Links sets performed as supersets. NULL for regular sets.';

COMMENT ON COLUMN performed_exercise_set.effective_volume_kg IS
  'Auto-calculated: volume adjusted for set type and RIR (if available).
   Falls back to standard volume calculation when RIR is NULL.';

COMMENT ON COLUMN performed_exercise_set.estimated_1rm_kg IS
  'Auto-calculated: 1RM estimate using adaptive formula (Epley/Brzycki/Mayhew).
   NULL for sets with >15 reps (unreliable estimation).';

COMMENT ON COLUMN performed_exercise_set.relative_intensity IS
  'Auto-calculated: % of estimated 1RM. NULL when 1RM estimation is unavailable.';
