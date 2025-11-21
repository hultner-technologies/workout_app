-- database/400_weekly_exercise_volume_view.sql

CREATE MATERIALIZED VIEW weekly_exercise_volume AS
SELECT
  u.user_id,
  DATE_TRUNC('week', ps.completed_at)::DATE AS week_start_date,
  be.exercise_id AS base_exercise_id,
  be.name AS exercise_name,

  -- Volume metrics
  COUNT(DISTINCT ps.session_id) AS session_count,
  COUNT(pes.set_id) AS total_sets,
  SUM(pes.effective_volume_kg) AS effective_volume_kg,

  -- Intensity metrics
  MAX(pes.estimated_1rm_kg) AS max_estimated_1rm_kg,
  AVG(pes.relative_intensity) AS avg_relative_intensity,

  -- RIR tracking (when available)
  AVG(pes.estimated_rir) FILTER (WHERE pes.estimated_rir IS NOT NULL) AS avg_rir,

  -- Metadata
  MIN(ps.completed_at) AS first_session_date,
  MAX(ps.completed_at) AS last_session_date

FROM app_user u
  INNER JOIN performed_session ps ON u.user_id = ps.user_id
  INNER JOIN performed_exercise pe ON ps.session_id = pe.session_id
  INNER JOIN base_exercise be ON pe.base_exercise_id = be.exercise_id
  INNER JOIN performed_exercise_set pes ON pe.exercise_id = pes.exercise_id

WHERE ps.completed_at IS NOT NULL
  AND pes.set_type != 'warm-up'  -- Exclude warm-up sets

GROUP BY
  u.user_id,
  DATE_TRUNC('week', ps.completed_at)::DATE,
  be.exercise_id,
  be.name;

-- Index for fast user+week lookups
CREATE INDEX idx_weekly_exercise_volume_user_week
  ON weekly_exercise_volume (user_id, week_start_date);

-- Index for exercise lookups
CREATE INDEX idx_weekly_exercise_volume_exercise
  ON weekly_exercise_volume (base_exercise_id, week_start_date);

COMMENT ON MATERIALIZED VIEW weekly_exercise_volume IS
  'Weekly aggregation of exercise volume and intensity metrics per user.

   Aggregates all working sets (excludes warm-ups) by:
   - user_id
   - week_start_date (Monday, ISO 8601)
   - base_exercise_id

   Provides:
   - session_count: Number of sessions exercise was performed
   - total_sets: Count of working sets
   - effective_volume_kg: Sum of RIR-adjusted volume
   - max_estimated_1rm_kg: Highest 1RM estimate for the week
   - avg_relative_intensity: Average % of 1RM
   - avg_rir: Average reps in reserve (when tracked)

   Updated via refresh trigger when new sessions completed.';
