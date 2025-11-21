# Exercise Stats V3 Analytics Specification

**Version:** 3.0.0
**Date:** 2025-11-21
**Status:** Design Complete, Ready for Implementation
**Research Basis:** [2025-11-21 Workout Analytics Research](../research/2025-11-21-workout-analytics-research.md)

---

## Table of Contents

1. [Overview](#overview)
2. [Database Schema Updates](#database-schema-updates)
3. [Core Views](#core-views)
4. [Advanced Analytics Views](#advanced-analytics-views)
5. [Helper Functions](#helper-functions)
6. [API Endpoints](#api-endpoints)
7. [Performance Optimizations](#performance-optimizations)
8. [Migration Strategy](#migration-strategy)
9. [Testing Requirements](#testing-requirements)

---

## Overview

### Goals

Build the "most data-focused workout app" with evidence-based analytics that provide:
- **Contextual insights** (not just raw numbers)
- **Actionable recommendations** (what to do, not just what happened)
- **Scientific backing** (MEV/MAV/MRV volume landmarks, plateau detection, muscle balance)
- **Advanced set type support** (drop-sets, myo-reps, supersets with proper volume calculations)

### Three-Tier Architecture

**Legacy Views (Deprecated)**
- `exercise_stats` - Original view using legacy weight/reps fields
- Maintained for backward compatibility only
- Add deprecation warnings

**V2 Views (Drop-In Replacements)**
- `exercise_stats_v2` - Uses sets table, maintains same schema as legacy
- `next_exercise_progression_v2` - Updated progression logic
- Goal: Zero API changes, seamless migration

**V3 Views (Advanced Analytics)**
- `weekly_exercise_volume` - Core volume tracking
- `weekly_muscle_volume` - Muscle-specific aggregates
- `volume_landmarks_status` - MEV/MAV/MRV classification
- `plateau_detection` - Statistical analysis
- `muscle_balance_ratios` - Push/pull, quad/hamstring ratios
- `exercise_selection_quality` - Compound/isolation, variety
- `training_intensity_distribution` - % 1RM zones, set types
- `mesocycle_tracking` - Accumulation/deload phase detection

---

## Database Schema Updates

### 1. Enhanced Set Tracking

```sql
-- Add columns to performed_exercise_set table
ALTER TABLE performed_exercise_set
  -- RIR tracking for effective volume calculations
  ADD COLUMN estimated_rir INTEGER CHECK (estimated_rir >= 0 AND estimated_rir <= 10),

  -- RPE tracking (Rate of Perceived Exertion, 1-10 scale)
  ADD COLUMN rpe NUMERIC(3,1) CHECK (rpe >= 1 AND rpe <= 10),

  -- Myo-rep specific tracking
  ADD COLUMN activation_reps INTEGER CHECK (activation_reps > 0),
  ADD COLUMN mini_set_reps INTEGER CHECK (mini_set_reps > 0),
  ADD COLUMN mini_set_count INTEGER CHECK (mini_set_count > 0),

  -- Superset grouping
  ADD COLUMN superset_group_id UUID,

  -- Calculated fields (auto-updated via trigger)
  ADD COLUMN effective_volume_kg NUMERIC(10,2),
  ADD COLUMN estimated_1rm_kg NUMERIC(10,2),
  ADD COLUMN relative_intensity NUMERIC(5,2) CHECK (relative_intensity >= 0 AND relative_intensity <= 100);

-- Add comments
COMMENT ON COLUMN performed_exercise_set.estimated_rir IS 'Reps in reserve (0 = failure, 1-3 = optimal hypertrophy)';
COMMENT ON COLUMN performed_exercise_set.rpe IS 'Rate of perceived exertion (1-10 scale, often matches 10-RIR)';
COMMENT ON COLUMN performed_exercise_set.activation_reps IS 'For myo-reps: initial activation set reps';
COMMENT ON COLUMN performed_exercise_set.mini_set_reps IS 'For myo-reps: reps per mini-set';
COMMENT ON COLUMN performed_exercise_set.mini_set_count IS 'For myo-reps: number of mini-sets';
COMMENT ON COLUMN performed_exercise_set.superset_group_id IS 'Links sets performed as supersets';
COMMENT ON COLUMN performed_exercise_set.effective_volume_kg IS 'Auto-calculated: volume adjusted for set type and RIR';
COMMENT ON COLUMN performed_exercise_set.estimated_1rm_kg IS 'Auto-calculated: 1RM estimate using adaptive formula';
COMMENT ON COLUMN performed_exercise_set.relative_intensity IS 'Auto-calculated: % of estimated 1RM';
```

### 2. Exercise Metadata Enhancements

```sql
-- Add activation percentage to muscle junction tables
ALTER TABLE base_exercise_primary_muscle
  ADD COLUMN activation_percentage INTEGER DEFAULT 100
    CHECK (activation_percentage >= 0 AND activation_percentage <= 100);

ALTER TABLE base_exercise_secondary_muscle
  ADD COLUMN activation_percentage INTEGER DEFAULT 50
    CHECK (activation_percentage >= 0 AND activation_percentage <= 100);

COMMENT ON COLUMN base_exercise_primary_muscle.activation_percentage IS
  'Percentage of volume attributed to this muscle (default 100% for primary)';
COMMENT ON COLUMN base_exercise_secondary_muscle.activation_percentage IS
  'Percentage of volume attributed to this muscle (default 50% for secondary)';
```

### 3. User Training Preferences

```sql
-- Add training preferences to app_user
ALTER TABLE app_user
  ADD COLUMN training_preferences JSONB DEFAULT '{
    "volume_landmarks": {
      "enabled": true,
      "custom_mev": null,
      "custom_mav": null,
      "custom_mrv": null
    },
    "plateau_detection": {
      "enabled": true,
      "sensitivity": "medium",
      "notification_threshold": 3
    },
    "estimated_training_age": "intermediate",
    "deload_frequency_weeks": 6,
    "mcp_data_sharing": {
      "performance_history": true,
      "body_metrics": false,
      "notes": false
    }
  }'::jsonb;

COMMENT ON COLUMN app_user.training_preferences IS
  'User preferences for analytics, plateau detection, and MCP data sharing';
```

---

## Core Views

### 1. Weekly Exercise Volume

**Purpose:** Primary aggregation of volume per exercise per week (materialized for performance)

```sql
CREATE MATERIALIZED VIEW weekly_exercise_volume AS
WITH weekly_sets AS (
  SELECT
    pe.user_id,
    pe.exercise_id,
    be.name AS exercise_name,
    be.mechanic AS exercise_mechanic,
    be.force AS exercise_force,
    DATE_TRUNC('week', ps.performed_at) AS week_start,
    pes.set_type,
    pes.weight,
    pes.reps,
    pes.estimated_rir,
    pes.effective_volume_kg,
    pes.estimated_1rm_kg,
    pes.relative_intensity,
    ps.performed_at,
    pe.performed_exercise_id,
    pes.performed_exercise_set_id
  FROM performed_exercise_set pes
  JOIN performed_exercise pe ON pes.performed_exercise_id = pe.performed_exercise_id
  JOIN performed_session ps ON pe.performed_session_id = ps.performed_session_id
  JOIN exercise e ON pe.exercise_id = e.exercise_id
  JOIN base_exercise be ON e.base_exercise_id = be.base_exercise_id
  WHERE ps.completed_at IS NOT NULL  -- Only completed sessions
    AND pes.set_type != 'warm-up'   -- Exclude warm-ups from working volume
)
SELECT
  user_id,
  exercise_id,
  exercise_name,
  exercise_mechanic,
  exercise_force,
  week_start,

  -- Volume metrics
  COUNT(*) FILTER (WHERE set_type != 'warm-up') AS working_sets,
  SUM(weight * reps) / 1000.0 AS total_volume_kg,
  SUM(effective_volume_kg) AS effective_volume_kg,

  -- Weight metrics
  MAX(weight) / 1000.0 AS max_weight_kg,
  AVG(weight) / 1000.0 AS avg_weight_kg,

  -- Reps metrics
  SUM(reps) AS total_reps,
  AVG(reps) AS avg_reps,

  -- Intensity metrics
  MAX(estimated_1rm_kg) AS estimated_1rm_kg,
  AVG(relative_intensity) AS avg_relative_intensity,

  -- Set type distribution
  COUNT(*) FILTER (WHERE set_type = 'regular') AS regular_sets,
  COUNT(*) FILTER (WHERE set_type = 'drop-set') AS dropset_sets,
  COUNT(*) FILTER (WHERE set_type = 'myo-rep') AS myorep_sets,
  COUNT(*) FILTER (WHERE set_type = 'super-set') AS superset_sets,
  COUNT(*) FILTER (WHERE set_type = 'amrap') AS amrap_sets,

  -- RIR distribution (effective sets only)
  AVG(estimated_rir) FILTER (WHERE estimated_rir IS NOT NULL) AS avg_rir,
  COUNT(*) FILTER (WHERE estimated_rir <= 3) AS hard_sets,  -- 0-3 RIR

  -- Temporal metadata
  MIN(performed_at) AS first_session_at,
  MAX(performed_at) AS last_session_at,
  COUNT(DISTINCT performed_exercise_id) AS session_count

FROM weekly_sets
GROUP BY user_id, exercise_id, exercise_name, exercise_mechanic, exercise_force, week_start;

-- Indexes for performance
CREATE INDEX idx_weekly_exercise_volume_user_week
  ON weekly_exercise_volume(user_id, week_start DESC);
CREATE INDEX idx_weekly_exercise_volume_exercise
  ON weekly_exercise_volume(exercise_id, week_start DESC);

-- Refresh strategy: After each completed session
CREATE UNIQUE INDEX idx_weekly_exercise_volume_unique
  ON weekly_exercise_volume(user_id, exercise_id, week_start);

COMMENT ON MATERIALIZED VIEW weekly_exercise_volume IS
  'Core volume tracking per exercise per week. Excludes warm-ups.
   Refresh after session completion for real-time accuracy.';
```

### 2. Weekly Muscle Volume

**Purpose:** Aggregate volume per muscle group using primary/secondary activation percentages

```sql
CREATE MATERIALIZED VIEW weekly_muscle_volume AS
WITH muscle_sets AS (
  SELECT
    wev.user_id,
    wev.week_start,
    mg.muscle_group_id,
    mg.name AS muscle_name,
    mg.body_part,

    -- Primary muscle volume (100% or custom activation_percentage)
    COALESCE(bepm.activation_percentage, 100) / 100.0 AS primary_activation_factor,
    wev.total_volume_kg AS exercise_volume_kg,
    wev.working_sets AS exercise_sets,
    wev.exercise_mechanic,
    wev.exercise_force,
    TRUE AS is_primary

  FROM weekly_exercise_volume wev
  JOIN exercise e ON wev.exercise_id = e.exercise_id
  JOIN base_exercise be ON e.base_exercise_id = be.base_exercise_id
  JOIN base_exercise_primary_muscle bepm ON be.base_exercise_id = bepm.base_exercise_id
  JOIN muscle_group mg ON bepm.muscle_group_id = mg.muscle_group_id

  UNION ALL

  SELECT
    wev.user_id,
    wev.week_start,
    mg.muscle_group_id,
    mg.name AS muscle_name,
    mg.body_part,

    -- Secondary muscle volume (50% or custom activation_percentage)
    COALESCE(besm.activation_percentage, 50) / 100.0 AS secondary_activation_factor,
    wev.total_volume_kg AS exercise_volume_kg,
    wev.working_sets AS exercise_sets,
    wev.exercise_mechanic,
    wev.exercise_force,
    FALSE AS is_primary

  FROM weekly_exercise_volume wev
  JOIN exercise e ON wev.exercise_id = e.exercise_id
  JOIN base_exercise be ON e.base_exercise_id = be.base_exercise_id
  JOIN base_exercise_secondary_muscle besm ON be.base_exercise_id = besm.base_exercise_id
  JOIN muscle_group mg ON besm.muscle_group_id = mg.muscle_group_id
)
SELECT
  user_id,
  week_start,
  muscle_group_id,
  muscle_name,
  body_part,

  -- Volume metrics (weighted by activation percentage)
  SUM(exercise_volume_kg * primary_activation_factor) AS total_volume_kg,
  SUM(exercise_sets * primary_activation_factor) AS total_sets,

  -- Primary vs secondary breakdown
  SUM(exercise_volume_kg * primary_activation_factor) FILTER (WHERE is_primary) AS primary_volume_kg,
  SUM(exercise_sets * primary_activation_factor) FILTER (WHERE is_primary) AS primary_sets,
  SUM(exercise_volume_kg * primary_activation_factor) FILTER (WHERE NOT is_primary) AS secondary_volume_kg,
  SUM(exercise_sets * primary_activation_factor) FILTER (WHERE NOT is_primary) AS secondary_sets,

  -- Exercise selection quality
  COUNT(DISTINCT exercise_mechanic) AS exercise_variety_score,
  SUM(exercise_sets) FILTER (WHERE exercise_mechanic = 'compound') AS compound_sets,
  SUM(exercise_sets) FILTER (WHERE exercise_mechanic = 'isolation') AS isolation_sets,

  -- Force type distribution
  SUM(exercise_sets) FILTER (WHERE exercise_force = 'push') AS push_sets,
  SUM(exercise_sets) FILTER (WHERE exercise_force = 'pull') AS pull_sets,
  SUM(exercise_sets) FILTER (WHERE exercise_force = 'static') AS static_sets

FROM muscle_sets
GROUP BY user_id, week_start, muscle_group_id, muscle_name, body_part;

CREATE INDEX idx_weekly_muscle_volume_user_week
  ON weekly_muscle_volume(user_id, week_start DESC);
CREATE INDEX idx_weekly_muscle_volume_muscle
  ON weekly_muscle_volume(muscle_group_id, week_start DESC);

COMMENT ON MATERIALIZED VIEW weekly_muscle_volume IS
  'Volume per muscle group per week. Uses activation_percentage from junction tables
   (default: primary=100%, secondary=50%). Refresh with weekly_exercise_volume.';
```

---

## Advanced Analytics Views

### 3. Volume Landmarks Status

**Purpose:** Classify current volume as MEV/MAV/MRV with actionable recommendations

```sql
CREATE OR REPLACE VIEW volume_landmarks_status AS
WITH volume_landmarks_config AS (
  -- Default volume landmarks (Mike Israetel/RP Strength)
  -- Can be overridden by user preferences
  SELECT
    muscle_name,
    COALESCE(user_pref.custom_mev, default_mev) AS mev,
    COALESCE(user_pref.custom_mav, default_mav) AS mav,
    COALESCE(user_pref.custom_mrv, default_mrv) AS mrv
  FROM (
    VALUES
      ('Chest', 6, 10, 22),
      ('Back', 10, 14, 25),
      ('Shoulders', 8, 12, 20),
      ('Biceps', 8, 12, 26),
      ('Triceps', 6, 10, 20),
      ('Quadriceps', 6, 12, 20),
      ('Hamstrings', 6, 10, 20),
      ('Glutes', 6, 12, 20),
      ('Calves', 8, 12, 25),
      ('Forearms', 6, 10, 20),
      ('Abs', 0, 12, 25),
      ('Traps', 0, 8, 20)
  ) AS defaults(muscle_name, default_mev, default_mav, default_mrv)
  LEFT JOIN LATERAL (
    SELECT
      (training_preferences->'volume_landmarks'->>'custom_mev')::INTEGER AS custom_mev,
      (training_preferences->'volume_landmarks'->>'custom_mav')::INTEGER AS custom_mav,
      (training_preferences->'volume_landmarks'->>'custom_mrv')::INTEGER AS custom_mrv
    FROM app_user
    -- User-specific overrides would be joined here
  ) user_pref ON TRUE
),
current_week_volume AS (
  SELECT
    user_id,
    muscle_name,
    total_sets,
    total_volume_kg,
    week_start
  FROM weekly_muscle_volume
  WHERE week_start = DATE_TRUNC('week', CURRENT_DATE)
)
SELECT
  cwv.user_id,
  cwv.muscle_name,
  cwv.total_sets,
  cwv.total_volume_kg,
  vlc.mev,
  vlc.mav,
  vlc.mrv,

  -- Classification
  CASE
    WHEN cwv.total_sets < vlc.mev THEN 'below_mev'
    WHEN cwv.total_sets < vlc.mav THEN 'maintenance'
    WHEN cwv.total_sets <= vlc.mrv THEN 'optimal'
    ELSE 'excessive'
  END AS volume_status,

  -- Progress toward next landmark
  CASE
    WHEN cwv.total_sets < vlc.mev THEN
      ROUND((cwv.total_sets::NUMERIC / vlc.mev) * 100, 1)
    WHEN cwv.total_sets < vlc.mav THEN
      ROUND(((cwv.total_sets - vlc.mev)::NUMERIC / (vlc.mav - vlc.mev)) * 100, 1)
    WHEN cwv.total_sets <= vlc.mrv THEN
      ROUND(((cwv.total_sets - vlc.mav)::NUMERIC / (vlc.mrv - vlc.mav)) * 100, 1)
    ELSE 100.0
  END AS progress_to_next_landmark_pct,

  -- Actionable recommendation
  CASE
    WHEN cwv.total_sets < vlc.mev * 0.5 THEN
      'Critical: Add ' || (vlc.mev - cwv.total_sets) || ' sets to reach MEV'
    WHEN cwv.total_sets < vlc.mev THEN
      'Below MEV: Add ' || (vlc.mev - cwv.total_sets) || ' sets for effective training'
    WHEN cwv.total_sets < vlc.mav THEN
      'Maintenance: Add ' || (vlc.mav - cwv.total_sets) || ' sets to reach optimal zone (MAV)'
    WHEN cwv.total_sets <= vlc.mrv * 0.9 THEN
      'Optimal (MAV): Volume in growth zone'
    WHEN cwv.total_sets <= vlc.mrv THEN
      'High (near MRV): Monitor recovery carefully'
    ELSE
      'Excessive (>MRV): Reduce volume or schedule deload'
  END AS recommendation

FROM current_week_volume cwv
JOIN volume_landmarks_config vlc ON cwv.muscle_name = vlc.muscle_name;

COMMENT ON VIEW volume_landmarks_status IS
  'Real-time volume landmark classification per muscle.
   MEV = Minimum Effective, MAV = Maximum Adaptive, MRV = Maximum Recoverable.
   Research: Mike Israetel/Renaissance Periodization.';
```

### 4. Plateau Detection

**Purpose:** Statistical analysis to detect training plateaus with multi-method scoring

```sql
CREATE OR REPLACE VIEW plateau_detection AS
WITH weekly_progression AS (
  SELECT
    user_id,
    exercise_id,
    exercise_name,
    week_start,
    total_volume_kg,
    max_weight_kg,
    estimated_1rm_kg,
    working_sets,

    -- Week-over-week changes
    LAG(total_volume_kg, 1) OVER (PARTITION BY user_id, exercise_id ORDER BY week_start) AS prev_week_volume,
    LAG(max_weight_kg, 1) OVER (PARTITION BY user_id, exercise_id ORDER BY week_start) AS prev_week_weight,
    LAG(estimated_1rm_kg, 1) OVER (PARTITION BY user_id, exercise_id ORDER BY week_start) AS prev_week_1rm,

    -- Moving averages (4-week window)
    AVG(total_volume_kg) OVER (
      PARTITION BY user_id, exercise_id
      ORDER BY week_start
      ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS ma_4week_volume,

    -- Linear regression over 6-week window
    REGR_SLOPE(total_volume_kg, EXTRACT(EPOCH FROM week_start)) OVER (
      PARTITION BY user_id, exercise_id
      ORDER BY week_start
      ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
    ) AS trend_slope_volume,

    REGR_R2(total_volume_kg, EXTRACT(EPOCH FROM week_start)) OVER (
      PARTITION BY user_id, exercise_id
      ORDER BY week_start
      ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
    ) AS trend_r2_volume,

    -- Row number for minimum data requirement
    ROW_NUMBER() OVER (PARTITION BY user_id, exercise_id ORDER BY week_start DESC) AS weeks_back

  FROM weekly_exercise_volume
  WHERE week_start >= CURRENT_DATE - INTERVAL '12 weeks'  -- Last 12 weeks only
),
plateau_analysis AS (
  SELECT
    user_id,
    exercise_id,
    exercise_name,
    week_start,
    total_volume_kg,
    max_weight_kg,
    estimated_1rm_kg,

    -- Week-over-week percentage changes
    ROUND(
      ((total_volume_kg - prev_week_volume) / NULLIF(prev_week_volume, 0)) * 100,
      2
    ) AS wow_volume_change_pct,

    ROUND(
      ((max_weight_kg - prev_week_weight) / NULLIF(prev_week_weight, 0)) * 100,
      2
    ) AS wow_weight_change_pct,

    -- Moving average
    ROUND(ma_4week_volume, 2) AS ma_4week_volume,

    -- Trend analysis
    ROUND(trend_slope_volume::NUMERIC, 6) AS trend_slope,
    ROUND(trend_r2_volume::NUMERIC, 3) AS trend_r2,

    -- Stagnation detection
    COUNT(*) FILTER (
      WHERE ABS((total_volume_kg - prev_week_volume) / NULLIF(prev_week_volume, 0)) < 0.02  -- <2% change
    ) OVER (
      PARTITION BY user_id, exercise_id
      ORDER BY week_start
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS stagnant_weeks_count,

    weeks_back

  FROM weekly_progression
  WHERE weeks_back <= 6  -- Focus on last 6 weeks
)
SELECT
  user_id,
  exercise_id,
  exercise_name,
  week_start,
  total_volume_kg,
  max_weight_kg,
  estimated_1rm_kg,
  wow_volume_change_pct,
  wow_weight_change_pct,
  ma_4week_volume,
  trend_slope,
  trend_r2,
  stagnant_weeks_count,

  -- Plateau score (0-1, higher = more likely plateau)
  ROUND(
    (
      -- Volume stagnation component (60% weight)
      CASE
        WHEN stagnant_weeks_count >= 3 THEN 0.6
        WHEN stagnant_weeks_count = 2 THEN 0.4
        WHEN stagnant_weeks_count = 1 THEN 0.2
        ELSE 0
      END
      +
      -- Trend component (40% weight)
      CASE
        WHEN ABS(trend_slope) < 0.02 AND trend_r2 > 0.4 THEN 0.4  -- Flat + consistent = plateau
        WHEN ABS(trend_slope) < 0.05 THEN 0.2  -- Slightly flat
        ELSE 0
      END
    ),
    2
  ) AS plateau_score,

  -- Classification
  CASE
    WHEN stagnant_weeks_count >= 3 AND ABS(trend_slope) < 0.02 THEN 'confirmed_plateau'
    WHEN stagnant_weeks_count >= 2 THEN 'potential_plateau'
    WHEN wow_volume_change_pct > 2 THEN 'progressing'
    ELSE 'normal_variance'
  END AS status,

  -- Actionable recommendation
  CASE
    WHEN stagnant_weeks_count >= 3 THEN
      'Confirmed plateau (3+ weeks). Recommend deload or program modification.'
    WHEN stagnant_weeks_count = 2 THEN
      'Potential plateau (2 weeks). Monitor closely; consider small volume increase.'
    WHEN wow_volume_change_pct < -5 THEN
      'Performance declining. Check recovery, stress, sleep, nutrition.'
    WHEN wow_volume_change_pct > 10 THEN
      'Rapid progression. Great! Ensure technique remains solid.'
    ELSE
      'Normal progress. Continue current programming.'
  END AS recommendation

FROM plateau_analysis
WHERE weeks_back = 1;  -- Only current week analysis

CREATE INDEX idx_plateau_detection_user_status
  ON plateau_detection(user_id, status)
  WHERE status IN ('confirmed_plateau', 'potential_plateau');

COMMENT ON VIEW plateau_detection IS
  'Multi-method plateau detection using moving averages, linear regression, and
   week-over-week analysis. Plateau confirmed after 3 weeks <2% change.
   Research: Stronger by Science, Renaissance Periodization.';
```

### 5. Muscle Balance Ratios

**Purpose:** Track push/pull, quad/hamstring, and other balance ratios with injury risk warnings

```sql
CREATE OR REPLACE VIEW muscle_balance_ratios AS
WITH current_week_muscle_volume AS (
  SELECT
    user_id,
    muscle_name,
    body_part,
    total_sets,
    total_volume_kg,
    push_sets,
    pull_sets,
    compound_sets,
    isolation_sets
  FROM weekly_muscle_volume
  WHERE week_start = DATE_TRUNC('week', CURRENT_DATE)
),
aggregated_ratios AS (
  SELECT
    user_id,

    -- Upper body push/pull
    SUM(total_sets) FILTER (WHERE body_part = 'chest' OR muscle_name IN ('Anterior Deltoid', 'Triceps')) AS upper_push_sets,
    SUM(total_sets) FILTER (WHERE body_part = 'back' OR muscle_name IN ('Posterior Deltoid', 'Biceps')) AS upper_pull_sets,
    SUM(total_volume_kg) FILTER (WHERE body_part = 'chest' OR muscle_name IN ('Anterior Deltoid', 'Triceps')) AS upper_push_volume,
    SUM(total_volume_kg) FILTER (WHERE body_part = 'back' OR muscle_name IN ('Posterior Deltoid', 'Biceps')) AS upper_pull_volume,

    -- Lower body anterior/posterior
    SUM(total_sets) FILTER (WHERE muscle_name = 'Quadriceps') AS quad_sets,
    SUM(total_sets) FILTER (WHERE muscle_name IN ('Hamstrings', 'Glutes')) AS posterior_sets,

    -- Specific muscle pairs
    SUM(total_sets) FILTER (WHERE muscle_name = 'Chest') AS chest_sets,
    SUM(total_sets) FILTER (WHERE body_part = 'back') AS back_sets,

    -- Total compound vs isolation
    SUM(compound_sets) AS total_compound_sets,
    SUM(isolation_sets) AS total_isolation_sets

  FROM current_week_muscle_volume
  GROUP BY user_id
)
SELECT
  user_id,

  -- Push/Pull Ratio
  ROUND(upper_push_sets::NUMERIC / NULLIF(upper_pull_sets, 0), 2) AS push_pull_ratio_sets,
  ROUND(upper_push_volume / NULLIF(upper_pull_volume, 0), 2) AS push_pull_ratio_volume,
  CASE
    WHEN upper_push_sets::NUMERIC / NULLIF(upper_pull_sets, 0) BETWEEN 0.8 AND 1.2 THEN 'balanced'
    WHEN upper_push_sets::NUMERIC / NULLIF(upper_pull_sets, 0) > 1.3 THEN 'push_dominant'
    WHEN upper_push_sets::NUMERIC / NULLIF(upper_pull_sets, 0) < 0.7 THEN 'pull_dominant'
    ELSE 'unknown'
  END AS push_pull_status,

  -- Quad/Hamstring Ratio
  ROUND(quad_sets::NUMERIC / NULLIF(posterior_sets, 0), 2) AS quad_hamstring_ratio,
  CASE
    WHEN quad_sets::NUMERIC / NULLIF(posterior_sets, 0) BETWEEN 0.6 AND 1.0 THEN 'balanced'
    WHEN quad_sets::NUMERIC / NULLIF(posterior_sets, 0) > 2.0 THEN 'high_injury_risk'
    WHEN quad_sets::NUMERIC / NULLIF(posterior_sets, 0) > 1.0 THEN 'quad_dominant'
    ELSE 'posterior_dominant'
  END AS quad_hamstring_status,

  -- Chest/Back Ratio
  ROUND(chest_sets::NUMERIC / NULLIF(back_sets, 0), 2) AS chest_back_ratio,
  CASE
    WHEN chest_sets::NUMERIC / NULLIF(back_sets, 0) BETWEEN 0.7 AND 1.3 THEN 'balanced'
    WHEN chest_sets::NUMERIC / NULLIF(back_sets, 0) > 1.5 THEN 'chest_dominant'
    WHEN chest_sets::NUMERIC / NULLIF(back_sets, 0) < 0.6 THEN 'back_dominant'
    ELSE 'unknown'
  END AS chest_back_status,

  -- Compound/Isolation Ratio
  ROUND(total_compound_sets::NUMERIC / NULLIF(total_isolation_sets, 0), 2) AS compound_isolation_ratio,

  -- Overall balance score (0-100, higher is better)
  ROUND(
    (
      CASE WHEN upper_push_sets::NUMERIC / NULLIF(upper_pull_sets, 0) BETWEEN 0.8 AND 1.2 THEN 33 ELSE 0 END +
      CASE WHEN quad_sets::NUMERIC / NULLIF(posterior_sets, 0) BETWEEN 0.6 AND 1.0 THEN 33 ELSE 0 END +
      CASE WHEN chest_sets::NUMERIC / NULLIF(back_sets, 0) BETWEEN 0.7 AND 1.3 THEN 34 ELSE 0 END
    )::NUMERIC,
    0
  ) AS balance_score,

  -- Actionable recommendations
  ARRAY_REMOVE(ARRAY[
    CASE
      WHEN upper_push_sets::NUMERIC / NULLIF(upper_pull_sets, 0) > 1.3
      THEN 'Add ' || ROUND(upper_push_sets - upper_pull_sets * 1.2) || ' pull sets to balance upper body (prevent shoulder impingement)'
    END,
    CASE
      WHEN upper_push_sets::NUMERIC / NULLIF(upper_pull_sets, 0) < 0.7
      THEN 'Add ' || ROUND(upper_pull_sets * 0.8 - upper_push_sets) || ' push sets to balance upper body'
    END,
    CASE
      WHEN quad_sets::NUMERIC / NULLIF(posterior_sets, 0) > 2.0
      THEN 'WARNING: High ACL injury risk. Add ' || ROUND(quad_sets / 2.0 - posterior_sets) || ' hamstring/glute sets'
    END,
    CASE
      WHEN quad_sets::NUMERIC / NULLIF(posterior_sets, 0) > 1.0 AND quad_sets::NUMERIC / NULLIF(posterior_sets, 0) <= 2.0
      THEN 'Quad-dominant. Add ' || ROUND(quad_sets - posterior_sets) || ' hamstring/glute sets'
    END,
    CASE
      WHEN chest_sets::NUMERIC / NULLIF(back_sets, 0) > 1.5
      THEN 'Chest-dominant (postural risk). Add ' || ROUND(chest_sets - back_sets * 1.3) || ' back sets'
    END
  ], NULL) AS recommendations

FROM aggregated_ratios;

COMMENT ON VIEW muscle_balance_ratios IS
  'Muscle balance tracking with injury risk warnings.
   Target ratios: Push/Pull 0.8-1.2, Quad/Ham 0.6-1.0, Chest/Back 0.7-1.3.
   Research: ACL injury prevention, shoulder impingement prevention.';
```

---

## Helper Functions

### 6. Calculate Effective Volume

**Purpose:** Auto-calculate effective volume based on set type and RIR

```sql
CREATE OR REPLACE FUNCTION calculate_effective_volume(
  p_set_type TEXT,
  p_weight INTEGER,      -- in grams
  p_reps INTEGER,
  p_estimated_rir INTEGER DEFAULT NULL,
  p_activation_reps INTEGER DEFAULT NULL,
  p_mini_set_reps INTEGER DEFAULT NULL,
  p_mini_set_count INTEGER DEFAULT NULL
) RETURNS NUMERIC AS $$
DECLARE
  v_base_volume NUMERIC;
  v_rir_multiplier NUMERIC := 1.0;
  v_effective_volume NUMERIC;
BEGIN
  -- Base volume calculation by set type
  CASE p_set_type
    WHEN 'regular', 'pyramid-set', 'super-set', 'amrap' THEN
      v_base_volume := (p_weight * p_reps) / 1000.0;  -- Convert grams to kg

    WHEN 'myo-rep' THEN
      -- Myo-rep: activation set + mini-sets
      IF p_activation_reps IS NULL OR p_mini_set_reps IS NULL OR p_mini_set_count IS NULL THEN
        RAISE EXCEPTION 'Myo-rep requires activation_reps, mini_set_reps, mini_set_count';
      END IF;
      v_base_volume := (p_weight * (p_activation_reps + (p_mini_set_count * p_mini_set_reps))) / 1000.0;

    WHEN 'drop-set' THEN
      -- Drop-set: count full volume (multiple weight decrements recorded as separate sets)
      v_base_volume := (p_weight * p_reps) / 1000.0;

    WHEN 'warm-up' THEN
      -- Warm-ups don't count toward effective volume
      RETURN 0;

    ELSE
      RAISE EXCEPTION 'Unknown set_type: %', p_set_type;
  END CASE;

  -- RIR adjustment (optional, based on research showing hypertrophy decreases with higher RIR)
  IF p_estimated_rir IS NOT NULL THEN
    v_rir_multiplier := CASE
      WHEN p_estimated_rir <= 3 THEN 1.0   -- Optimal
      WHEN p_estimated_rir = 4 THEN 0.9
      WHEN p_estimated_rir = 5 THEN 0.8
      ELSE 0.6                              -- 6+ RIR not recommended for hypertrophy
    END;
  END IF;

  v_effective_volume := v_base_volume * v_rir_multiplier;

  RETURN ROUND(v_effective_volume, 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION calculate_effective_volume IS
  'Calculate effective volume based on set type and RIR.
   Myo-reps include activation + mini-sets. Warm-ups return 0.
   RIR multipliers: 0-3=1.0x, 4=0.9x, 5=0.8x, 6+=0.6x.
   Research: 2025 meta-analysis on proximity-to-failure.';
```

### 7. Estimate 1RM (Adaptive Formula)

**Purpose:** Use rep-range optimized formulas for accurate 1RM estimation

```sql
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
    WHEN p_reps = 1 THEN
      v_1rm_kg := v_weight_kg;  -- Already 1RM

    WHEN p_reps BETWEEN 2 AND 5 THEN
      -- Epley formula (best for low reps)
      v_1rm_kg := v_weight_kg * (1 + 0.0333 * p_reps);

    WHEN p_reps BETWEEN 6 AND 10 THEN
      -- Brzycki formula (best for moderate reps) - CURRENT DEFAULT
      v_1rm_kg := v_weight_kg * (36.0 / (37 - p_reps));

    WHEN p_reps BETWEEN 11 AND 15 THEN
      -- Mayhew formula (best for higher reps)
      v_1rm_kg := (100 * v_weight_kg) / (52.2 + 41.9 * EXP(-0.055 * p_reps));

    WHEN p_reps > 15 THEN
      -- Unreliable for very high reps (10-20% error)
      -- Return NULL to indicate unreliability
      RETURN NULL;

    ELSE
      RAISE EXCEPTION 'Invalid reps value: %', p_reps;
  END CASE;

  RETURN ROUND(v_1rm_kg, 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION estimate_1rm_adaptive IS
  'Adaptive 1RM estimation using rep-range optimized formulas.
   1-5 reps: Epley (<3% error), 6-10 reps: Brzycki (3-5% error),
   11-15 reps: Mayhew (5-10% error), 15+ reps: NULL (unreliable).
   Research: Comparison of 1RM prediction formulas across rep ranges.';
```

### 8. Auto-Update Trigger

**Purpose:** Automatically calculate effective_volume_kg, estimated_1rm_kg, relative_intensity on insert/update

```sql
CREATE OR REPLACE FUNCTION update_set_calculations()
RETURNS TRIGGER AS $$
BEGIN
  -- Calculate effective volume
  NEW.effective_volume_kg := calculate_effective_volume(
    NEW.set_type,
    NEW.weight,
    NEW.reps,
    NEW.estimated_rir,
    NEW.activation_reps,
    NEW.mini_set_reps,
    NEW.mini_set_count
  );

  -- Calculate estimated 1RM
  NEW.estimated_1rm_kg := estimate_1rm_adaptive(NEW.weight, NEW.reps);

  -- Calculate relative intensity (% of 1RM)
  IF NEW.estimated_1rm_kg IS NOT NULL AND NEW.estimated_1rm_kg > 0 THEN
    NEW.relative_intensity := ROUND(
      ((NEW.weight / 1000.0) / NEW.estimated_1rm_kg) * 100,
      2
    );
  ELSE
    NEW.relative_intensity := NULL;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_set_calculations
  BEFORE INSERT OR UPDATE OF weight, reps, set_type, estimated_rir, activation_reps, mini_set_reps, mini_set_count
  ON performed_exercise_set
  FOR EACH ROW
  EXECUTE FUNCTION update_set_calculations();

COMMENT ON TRIGGER trigger_update_set_calculations ON performed_exercise_set IS
  'Auto-calculate effective_volume_kg, estimated_1rm_kg, relative_intensity on insert/update.
   Ensures derived metrics stay in sync with source data.';
```

---

## API Endpoints

### 9. Volume Landmarks Dashboard

**Endpoint:** `GET /api/v3/analytics/volume-landmarks`

**Response:**
```json
{
  "user_id": "uuid",
  "week_start": "2025-11-17",
  "muscle_groups": [
    {
      "muscle_name": "Chest",
      "current_sets": 14,
      "current_volume_kg": 3250.5,
      "volume_status": "optimal",
      "landmarks": {
        "mev": 6,
        "mav": 10,
        "mrv": 22
      },
      "progress_to_next_landmark_pct": 40.0,
      "recommendation": "Optimal (MAV): Volume in growth zone"
    }
  ]
}
```

### 10. Plateau Detection Report

**Endpoint:** `GET /api/v3/analytics/plateau-detection?exercise_id={uuid}`

**Response:**
```json
{
  "exercise_id": "uuid",
  "exercise_name": "Barbell Bench Press",
  "current_week": "2025-11-17",
  "status": "confirmed_plateau",
  "plateau_score": 0.8,
  "metrics": {
    "total_volume_kg": 2500.0,
    "max_weight_kg": 100.0,
    "estimated_1rm_kg": 115.0,
    "wow_volume_change_pct": 0.5,
    "wow_weight_change_pct": 0.0,
    "stagnant_weeks_count": 3,
    "trend_slope": 0.01,
    "trend_r2": 0.65
  },
  "recommendation": "Confirmed plateau (3+ weeks). Recommend deload or program modification."
}
```

### 11. Muscle Balance Check

**Endpoint:** `GET /api/v3/analytics/muscle-balance`

**Response:**
```json
{
  "user_id": "uuid",
  "week_start": "2025-11-17",
  "ratios": {
    "push_pull": {
      "ratio_sets": 1.4,
      "ratio_volume": 1.3,
      "status": "push_dominant",
      "recommendation": "Add 4 pull sets to balance upper body (prevent shoulder impingement)"
    },
    "quad_hamstring": {
      "ratio": 1.8,
      "status": "quad_dominant",
      "recommendation": "Quad-dominant. Add 8 hamstring/glute sets"
    },
    "chest_back": {
      "ratio": 1.1,
      "status": "balanced"
    }
  },
  "balance_score": 33,
  "overall_status": "needs_attention"
}
```

---

## Performance Optimizations

### 12. Materialized View Refresh Strategy

**Challenge:** Real-time analytics vs database performance

**Solution:** Incremental refresh after session completion

```sql
-- Refresh weekly views after session completion
CREATE OR REPLACE FUNCTION refresh_weekly_analytics()
RETURNS TRIGGER AS $$
BEGIN
  -- Only refresh if session was just completed (completed_at changed from NULL)
  IF NEW.completed_at IS NOT NULL AND OLD.completed_at IS NULL THEN
    -- Refresh materialized views (concurrent to avoid locking)
    REFRESH MATERIALIZED VIEW CONCURRENTLY weekly_exercise_volume;
    REFRESH MATERIALIZED VIEW CONCURRENTLY weekly_muscle_volume;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_refresh_weekly_analytics
  AFTER UPDATE OF completed_at ON performed_session
  FOR EACH ROW
  EXECUTE FUNCTION refresh_weekly_analytics();

COMMENT ON TRIGGER trigger_refresh_weekly_analytics ON performed_session IS
  'Incrementally refresh weekly analytics when session is completed.
   Uses CONCURRENTLY to avoid blocking reads.';
```

### 13. Indexes for Common Queries

```sql
-- V3 analytics indexes
CREATE INDEX idx_performed_exercise_set_user_date
  ON performed_exercise_set(user_id, created_at DESC)
  INCLUDE (weight, reps, set_type, effective_volume_kg);

CREATE INDEX idx_performed_session_user_completed
  ON performed_session(user_id, completed_at DESC)
  WHERE completed_at IS NOT NULL;

CREATE INDEX idx_weekly_exercise_volume_recent
  ON weekly_exercise_volume(user_id, exercise_id, week_start DESC)
  WHERE week_start >= CURRENT_DATE - INTERVAL '12 weeks';

-- Partial indexes for plateau detection
CREATE INDEX idx_plateau_detection_active
  ON plateau_detection(user_id, exercise_id)
  WHERE status IN ('confirmed_plateau', 'potential_plateau');

-- RLS-aware indexes (user_id first for tenant isolation)
CREATE INDEX idx_muscle_volume_user_muscle
  ON weekly_muscle_volume(user_id, muscle_group_id, week_start DESC);
```

### 14. Query Performance Targets

| Query Type | Target Latency | Strategy |
|------------|----------------|----------|
| Volume Landmarks | < 100ms | Materialized view + index on user_id |
| Plateau Detection | < 200ms | Materialized view + partial index on status |
| Muscle Balance | < 150ms | Aggregated materialized view |
| Weekly Volume | < 50ms | Materialized view with UNIQUE index |
| MCP Tool Calls | < 500ms | Redis cache + YAML format |

---

## Migration Strategy

### 15. Phased Rollout

**Phase 1: Schema Updates (Week 1)**
- Add columns to `performed_exercise_set`
- Add `training_preferences` to `app_user`
- Add `activation_percentage` to muscle junction tables
- Deploy triggers for auto-calculations
- **Risk:** Low (additive changes only)

**Phase 2: V2 Views (Week 2)**
- Deploy `exercise_stats_v2`, `next_exercise_progression_v2`
- Test backward compatibility
- Gradual API migration (feature flag)
- **Risk:** Low (separate views, no breaking changes)

**Phase 3: V3 Materialized Views (Week 3-4)**
- Deploy `weekly_exercise_volume`, `weekly_muscle_volume`
- Test refresh performance
- Monitor database load
- **Risk:** Medium (materialized views add storage, refresh overhead)

**Phase 4: V3 Analytics Views (Week 5-6)**
- Deploy `volume_landmarks_status`, `plateau_detection`, `muscle_balance_ratios`
- Test with real user data
- Tune thresholds based on feedback
- **Risk:** Medium (complex queries, may need optimization)

**Phase 5: API Integration (Week 7-8)**
- Deploy new V3 API endpoints
- Frontend integration
- User-facing analytics dashboard
- **Risk:** Low (backend ready, frontend iteration)

**Phase 6: MCP Integration (Week 9-14)**
- MCP server development (separate timeline)
- Tool/resource implementation
- Privacy controls
- **Risk:** Medium (new system, AI integration)

---

## Testing Requirements

### 16. Test Coverage

**Unit Tests:**
- ✅ `calculate_effective_volume()` - All set types, RIR multipliers
- ✅ `estimate_1rm_adaptive()` - All rep ranges, edge cases
- ✅ Trigger `update_set_calculations()` - Auto-calculations correctness

**Integration Tests:**
- ✅ View accuracy against known datasets
- ✅ Materialized view refresh performance (<5s for 10k users)
- ✅ RLS compliance (users can only see own data)
- ✅ API endpoint response times (<500ms p99)

**Data Validation Tests:**
- ✅ Volume landmarks classification accuracy
- ✅ Plateau detection false positive rate (<10%)
- ✅ Muscle balance ratio thresholds (validated against research)

**Performance Tests:**
- ✅ Concurrent materialized view refresh (no locking)
- ✅ Index selectivity (>90% efficiency)
- ✅ Query plan analysis for all views

---

## Success Criteria

### 17. Metrics

**Technical:**
- ✅ All V3 views return results in <500ms (p95)
- ✅ Materialized view refresh completes in <10s
- ✅ Zero data loss during migration
- ✅ 100% backward compatibility for V2 APIs

**Product:**
- ✅ Plateau detection accuracy >85% (validated against user feedback)
- ✅ Volume landmark recommendations actionable (measurable via user engagement)
- ✅ Muscle balance warnings reduce injury reports (tracked via user surveys)

**Business:**
- ✅ "Most data-focused workout app" positioning validated
- ✅ Unique features not available in Strong, Hevy, JEFIT
- ✅ Advanced users (intermediate/advanced lifters) adoption rate >60%

---

## Next Steps

1. ✅ Review specification with engineering team
2. ⏭️ Create database migration scripts (270-350 range)
3. ⏭️ Implement helper functions (`calculate_effective_volume`, `estimate_1rm_adaptive`)
4. ⏭️ Deploy materialized views (`weekly_exercise_volume`, `weekly_muscle_volume`)
5. ⏭️ Deploy analytics views (`volume_landmarks_status`, `plateau_detection`, `muscle_balance_ratios`)
6. ⏭️ Build API endpoints
7. ⏭️ Frontend integration
8. ⏭️ MCP server development (separate track)

---

**Specification Prepared By:** Claude (Sonnet 4.5)
**Research Foundation:** 7 Parallel Research Streams (6.5 hours)
**Date:** 2025-11-21
**Session ID:** 01DaXyTEoVLVrpagZHC7AHkB
**Ready for:** Engineering Implementation
