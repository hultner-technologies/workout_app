-- database/385_estimate_1rm_adaptive.sql

CREATE OR REPLACE FUNCTION estimate_1rm_adaptive(
  p_weight INTEGER,  -- in grams
  p_reps INTEGER
) RETURNS NUMERIC AS $$
DECLARE
  v_weight_kg NUMERIC := p_weight / 1000.0;
  v_1rm_kg NUMERIC;
BEGIN
  -- Adaptive formula selection based on rep range
  CASE
    WHEN p_reps <= 0 OR p_reps > 15 THEN
      -- Invalid or unreliable range
      RETURN NULL;

    WHEN p_reps = 1 THEN
      -- Already 1RM
      v_1rm_kg := v_weight_kg;

    WHEN p_reps BETWEEN 2 AND 5 THEN
      -- Epley formula (best for low reps, <3% error)
      -- 1RM = weight × (1 + 0.0333 × reps)
      v_1rm_kg := v_weight_kg * (1 + 0.0333 * p_reps);

    WHEN p_reps BETWEEN 6 AND 10 THEN
      -- Brzycki formula (best for moderate reps, 3-5% error)
      -- 1RM = weight × (36 / (37 - reps))
      v_1rm_kg := v_weight_kg * (36.0 / (37 - p_reps));

    WHEN p_reps BETWEEN 11 AND 15 THEN
      -- Mayhew formula (best for higher reps, 5-10% error)
      -- 1RM = (100 × weight) / (52.2 + 41.9 × e^(-0.055 × reps))
      v_1rm_kg := (100 * v_weight_kg) / (52.2 + 41.9 * EXP(-0.055 * p_reps));

  END CASE;

  RETURN ROUND(v_1rm_kg, 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION estimate_1rm_adaptive IS
  'Estimate 1RM using rep-range optimized formulas.

   Parameters:
   - p_weight: Weight lifted in grams
   - p_reps: Number of reps performed

   Returns: Estimated 1RM in kg, or NULL if unreliable

   Formula selection by rep range:
   - 1 rep: Actual weight is 1RM
   - 2-5 reps: Epley formula (error <3%)
     1RM = weight × (1 + 0.0333 × reps)
   - 6-10 reps: Brzycki formula (error 3-5%)
     1RM = weight × (36 / (37 - reps))
   - 11-15 reps: Mayhew formula (error 5-10%)
     1RM = (100 × weight) / (52.2 + 41.9 × e^(-0.055 × reps))
   - >15 reps: NULL (error >10%, unreliable)

   Research:
   - Epley (1985)
   - Brzycki (1993) - DOI: 10.1080/07303084.1993.10606684
   - Mayhew et al. (1992) - PMID: 1293423
   - LeSuer et al. (1997) - Accuracy comparison study';
