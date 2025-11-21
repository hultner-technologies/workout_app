-- database/390_auto_update_calculated_fields.sql

CREATE OR REPLACE FUNCTION update_calculated_fields()
RETURNS TRIGGER AS $$
BEGIN
  -- Calculate effective volume
  NEW.effective_volume_kg := calculate_effective_volume(
    NEW.set_type,
    NEW.weight_g,
    NEW.reps,
    NEW.estimated_rir
  );

  -- Calculate estimated 1RM
  NEW.estimated_1rm_kg := estimate_1rm_adaptive(
    NEW.weight_g,
    NEW.reps
  );

  -- Calculate relative intensity (% of 1RM)
  IF NEW.estimated_1rm_kg IS NOT NULL AND NEW.estimated_1rm_kg > 0 THEN
    NEW.relative_intensity := ROUND(
      ((NEW.weight_g / 1000.0) / NEW.estimated_1rm_kg) * 100,
      2
    );
  ELSE
    NEW.relative_intensity := NULL;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_calculated_fields_trigger
  BEFORE INSERT OR UPDATE OF weight_g, reps, set_type, estimated_rir
  ON performed_exercise_set
  FOR EACH ROW
  EXECUTE FUNCTION update_calculated_fields();

COMMENT ON FUNCTION update_calculated_fields IS
  'Trigger function to auto-calculate effective_volume_kg, estimated_1rm_kg,
   and relative_intensity whenever a set is inserted or relevant fields updated.';
