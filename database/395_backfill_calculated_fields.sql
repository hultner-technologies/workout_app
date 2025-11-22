-- database/395_backfill_calculated_fields.sql

-- Backfill calculated fields for all existing performed_exercise_set rows
-- This ensures historical data works with the new analytics views

-- The trigger (390) handles new/updated rows automatically, but we need to
-- populate existing rows that were created before the trigger existed

UPDATE performed_exercise_set
SET
  -- Calculate effective volume (handles NULL RIR gracefully with 1.0x multiplier)
  effective_volume_kg = calculate_effective_volume(
    set_type,
    weight_g,
    reps,
    estimated_rir  -- NULL for historical data, uses 1.0x multiplier
  ),

  -- Calculate estimated 1RM
  estimated_1rm_kg = estimate_1rm_adaptive(
    weight_g,
    reps
  ),

  -- Calculate relative intensity (% of 1RM)
  relative_intensity = CASE
    WHEN estimate_1rm_adaptive(weight_g, reps) IS NOT NULL
         AND estimate_1rm_adaptive(weight_g, reps) > 0
    THEN ROUND(
      ((weight_g / 1000.0) / estimate_1rm_adaptive(weight_g, reps)) * 100,
      2
    )
    ELSE NULL
  END

WHERE effective_volume_kg IS NULL  -- Only update rows that haven't been calculated yet
   OR estimated_1rm_kg IS NULL
   OR relative_intensity IS NULL;

-- Log how many rows were updated
DO $$
DECLARE
  updated_count INTEGER;
BEGIN
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE 'Backfilled calculated fields for % existing sets', updated_count;
END $$;

COMMENT ON TABLE performed_exercise_set IS
  'Exercise sets performed during workout sessions.

   Calculated fields (effective_volume_kg, estimated_1rm_kg, relative_intensity)
   are auto-updated via trigger for new/updated rows. Historical data was
   backfilled in migration 395 to ensure complete analytics coverage.';
