-- database/380_calculate_effective_volume.sql

CREATE OR REPLACE FUNCTION calculate_effective_volume(
  p_set_type TEXT,
  p_weight INTEGER,      -- in grams
  p_reps INTEGER,
  p_estimated_rir INTEGER DEFAULT NULL  -- Nullable - historical data won't have this
) RETURNS NUMERIC AS $$
DECLARE
  v_base_volume NUMERIC;
  v_rir_multiplier NUMERIC := 1.0;
  v_effective_volume NUMERIC;
BEGIN
  -- Base volume calculation: weight × reps for all set types
  -- (Myo-reps are handled via parent/child set relationships, not special calculation)
  CASE p_set_type
    WHEN 'regular', 'pyramid-set', 'super-set', 'amrap', 'drop-set', 'myo-rep' THEN
      v_base_volume := (p_weight * p_reps) / 1000.0;  -- Convert grams to kg

    WHEN 'warm-up' THEN
      -- Warm-ups don't count toward effective volume
      RETURN 0;

    ELSE
      -- Default to standard volume calculation for unknown set types
      v_base_volume := (p_weight * p_reps) / 1000.0;
  END CASE;

  -- RIR adjustment (optional, only when data is available)
  -- Based on research showing hypertrophy decreases linearly with higher RIR
  IF p_estimated_rir IS NOT NULL THEN
    v_rir_multiplier := CASE
      WHEN p_estimated_rir <= 3 THEN 1.0   -- Optimal (0-3 RIR)
      WHEN p_estimated_rir = 4 THEN 0.9    -- Good
      WHEN p_estimated_rir = 5 THEN 0.8    -- Fair
      ELSE 0.6                              -- 6+ RIR not recommended for hypertrophy
    END;
  END IF;
  -- Note: When RIR is NULL (historical data), multiplier stays 1.0 (unadjusted)

  v_effective_volume := v_base_volume * v_rir_multiplier;

  RETURN ROUND(v_effective_volume, 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION calculate_effective_volume IS
  'Calculate effective volume based on set type and RIR (when available).

   Parameters:
   - p_set_type: Type of set (regular, warm-up, drop-set, myo-rep, etc.)
   - p_weight: Weight in grams
   - p_reps: Number of reps performed
   - p_estimated_rir: Reps in reserve (NULL for historical data)

   Returns: Effective volume in kg

   Volume calculation:
   - Base: weight × reps / 1000 (converts grams to kg)
   - Warm-ups: Always return 0 (excluded from working volume)
   - RIR adjustment (when not NULL):
     * 0-3 RIR: 1.0x (optimal)
     * 4 RIR: 0.9x (good)
     * 5 RIR: 0.8x (fair)
     * 6+ RIR: 0.6x (not recommended for hypertrophy)
   - NULL RIR: 1.0x (unadjusted, for historical data)

   Research: Robinson et al. 2024 (proximity-to-failure dose-response)';
