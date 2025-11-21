-- database/405_weekly_muscle_volume_view.sql

CREATE MATERIALIZED VIEW weekly_muscle_volume AS
-- Primary muscle volume (100% attribution)
SELECT
  wev.user_id,
  wev.week_start_date,
  pm.muscle_group,
  'primary'::TEXT AS muscle_role,
  1.0 AS activation_factor,  -- Fixed 100% for primary muscles

  -- Volume metrics
  wev.session_count,
  wev.total_sets,
  wev.effective_volume_kg,
  wev.effective_volume_kg * 1.0 AS attributed_volume_kg,  -- 100% attribution

  -- Intensity metrics
  wev.max_estimated_1rm_kg,
  wev.avg_relative_intensity,
  wev.avg_rir,

  -- Metadata
  wev.first_session_date,
  wev.last_session_date

FROM weekly_exercise_volume wev
  INNER JOIN base_exercise_primary_muscle pm ON wev.base_exercise_id = pm.exercise_id

UNION ALL

-- Secondary muscle volume (50% attribution)
SELECT
  wev.user_id,
  wev.week_start_date,
  sm.muscle_group,
  'secondary'::TEXT AS muscle_role,
  0.5 AS activation_factor,  -- Fixed 50% for secondary muscles

  -- Volume metrics
  wev.session_count,
  wev.total_sets,
  wev.effective_volume_kg,
  wev.effective_volume_kg * 0.5 AS attributed_volume_kg,  -- 50% attribution

  -- Intensity metrics
  wev.max_estimated_1rm_kg,
  wev.avg_relative_intensity,
  wev.avg_rir,

  -- Metadata
  wev.first_session_date,
  wev.last_session_date

FROM weekly_exercise_volume wev
  INNER JOIN base_exercise_secondary_muscle sm ON wev.base_exercise_id = sm.exercise_id;

-- Index for fast user+week lookups
CREATE INDEX idx_weekly_muscle_volume_user_week
  ON weekly_muscle_volume (user_id, week_start_date);

-- Index for muscle group analysis
CREATE INDEX idx_weekly_muscle_volume_muscle
  ON weekly_muscle_volume (muscle_group, week_start_date);

COMMENT ON MATERIALIZED VIEW weekly_muscle_volume IS
  'Weekly muscle group volume with research-backed activation factors.

   Expands weekly_exercise_volume into muscle-specific volumes using:
   - Primary muscles: 100% volume attribution (activation_factor = 1.0)
   - Secondary muscles: 50% volume attribution (activation_factor = 0.5)

   Based on Menno Henselmans research on muscle activation patterns.

   Used for:
   - Volume landmarks (MEV/MAV/MRV) per muscle
   - Muscle balance ratio analysis
   - Push/pull ratio tracking
   - Injury risk detection (e.g., Q/H ratio <0.6)';
