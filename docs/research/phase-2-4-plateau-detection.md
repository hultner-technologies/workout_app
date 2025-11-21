# Phase 2.4: Plateau Detection & Progress Tracking Research

**Research Date:** 2025-11-21
**Focus:** Statistical methods for detecting training plateaus and providing actionable recommendations
**Time Investment:** 60 minutes

---

## Executive Summary

Training plateaus occur when progress stagnates despite consistent effort, requiring systematic detection and evidence-based intervention. This document outlines statistical methods, detection criteria, and actionable recommendations for implementing plateau detection in the workout app analytics system.

**Key Findings:**
- **Optimal detection window:** 4-6 weeks for intermediates, 6-8 weeks for advanced lifters
- **Target progression rate:** 2-5% volume increase week-over-week for sustained growth
- **Primary metrics:** Combined volume + weight trends (not isolated metrics)
- **Statistical approach:** Moving averages with regression analysis and Mann-Kendall trend testing
- **Deload timing:** After 4-8 weeks of progressive training, or when performance declines 2+ consecutive weeks

---

## 1. Statistical Methods

### 1.1 Moving Averages for Trend Smoothing

Moving averages smooth short-term fluctuations to reveal underlying trends, essential for noisy workout data.

#### Simple Moving Average (SMA)
```
SMA(n) = (x₁ + x₂ + ... + xₙ) / n
```
- **Use case:** Weekly volume trends over 3-4 week windows
- **Advantage:** Simple, intuitive, reduces noise
- **Limitation:** Equal weight to all data points, lags behind recent changes

#### Exponential Weighted Moving Average (EWMA)
```
EWMA(t) = α × x(t) + (1 - α) × EWMA(t-1)

Where:
  α = smoothing factor (typically 0.2-0.3 for workout data)
  x(t) = current value
  EWMA(t-1) = previous EWMA value
```
- **Use case:** More responsive to recent performance changes
- **Advantage:** Weights recent data more heavily, faster adaptation
- **Recommended α:** 0.25 for strength training (balances responsiveness with stability)

### 1.2 Linear Regression for Trend Detection

Regression analysis fits a line to performance data to quantify progress rate and predict future performance.

#### Simple Linear Regression
```
y = β₀ + β₁x + ε

Where:
  y = performance metric (volume, weight, etc.)
  x = time (weeks)
  β₀ = intercept (baseline performance)
  β₁ = slope (rate of progress per week)
  ε = error term
```

#### Regression Slope Interpretation
```
β₁ > 0: Positive trend (progress)
β₁ ≈ 0: Plateau (stagnation)
β₁ < 0: Negative trend (regression)
```

#### Trend Strength (R²)
```
R² = 1 - (SS_residual / SS_total)

Where R² indicates:
  0.0-0.3: Weak trend (high variability)
  0.3-0.7: Moderate trend
  0.7-1.0: Strong trend (consistent progress)
```

**Application:**
- Calculate β₁ over 4-6 week rolling windows
- β₁ close to zero with R² > 0.5 indicates genuine plateau
- Low R² suggests high variability, not necessarily plateau

### 1.3 Mann-Kendall Test (Non-Parametric Trend Test)

The Mann-Kendall test detects monotonic trends without assuming normal distribution or linearity.

#### Test Statistic
```
S = Σ Σ sign(x_j - x_i)    for all i < j

sign(θ) = {
   1  if θ > 0
   0  if θ = 0
  -1  if θ < 0
}

Variance: Var(S) = [n(n-1)(2n+5)] / 18

Z-statistic: Z = {
  (S-1) / √Var(S)  if S > 0
   0               if S = 0
  (S+1) / √Var(S)  if S < 0
}
```

#### Interpretation
- **p < 0.05:** Significant trend detected
- **p ≥ 0.05:** No significant trend (potential plateau)

**Advantages:**
- Robust to outliers and non-normal distributions
- No assumptions about data linearity
- Handles missing data well

**Limitations:**
- Assumes independence (no autocorrelation)
- Less powerful than parametric tests when assumptions are met

### 1.4 Statistical Significance and False Positives

#### Type I Error Prevention
```
α = 0.05 (5% false positive rate)

For multiple muscle groups:
  Bonferroni correction: α_adjusted = α / n_tests

  Example: Testing 6 muscle groups
    α_adjusted = 0.05 / 6 = 0.0083
```

#### Confidence Intervals
```
CI = β₁ ± (t_critical × SE_β₁)

Where:
  t_critical = t-value for desired confidence level (95% → 1.96)
  SE_β₁ = standard error of slope
```

**False Positive Prevention Strategies:**
1. **Minimum time window:** Require 4+ weeks of data before plateau detection
2. **Confirmation period:** Flag as "potential plateau" until 2 consecutive assessments confirm
3. **Context awareness:** Exclude periods with known disruptions (deloads, illness, etc.)
4. **Multiple metrics:** Require concordance between volume AND weight/reps trends

---

## 2. Plateau Detection Criteria

### 2.1 Primary Criteria

#### Volume Stagnation
```
Plateau if:
  1. 4-week moving average slope ≈ 0 (|β₁| < threshold)
  2. Week-over-week change < 2% for 3+ consecutive weeks
  3. No volume increase > 5% in 4-week window

Threshold calculation:
  For intermediates: |β₁| < 0.02 (2% per week)
  For advanced: |β₁| < 0.01 (1% per week)
```

**Evidence Base:** The 3-week stagnation threshold is based on practical training guidelines (Legion Athletics 2024) and research showing plateaus often appear after 3-4 weeks of routine exercise with neural adaptations occurring within 3-week periods (Tinto et al. 2022, DOI: 10.3390/sports10020019).

#### Weight/Intensity Stagnation
```
Plateau if:
  1. Maximum weight unchanged for 4+ weeks
  2. Average weight per set shows no improvement (< 1% increase)
  3. Regression slope β₁ ≈ 0 with R² > 0.4
```

#### Combined Metrics (Recommended)
```
Plateau Score = w₁ × volume_stagnation + w₂ × weight_stagnation

Where:
  w₁ = 0.6 (volume weight)
  w₂ = 0.4 (intensity weight)

Score > 0.7 → Likely plateau
Score 0.4-0.7 → Monitor closely
Score < 0.4 → Progressing normally
```

### 2.2 Time Windows by Training Age

| Training Age | Plateau Window | Progression Rate | Sensitivity |
|--------------|----------------|------------------|-------------|
| Beginner (0-6 months) | 6-8 weeks | 5-10% per week | Low (avoid false alarms) |
| Intermediate (6-24 months) | 4-6 weeks | 2-5% per week | Medium |
| Advanced (24+ months) | 8-12 weeks | 0.5-2% per week | High (subtle changes matter) |

**Rationale:**
- Beginners progress rapidly; temporary stalls often self-resolve
- Intermediates show consistent but slower progress; 4-6 weeks sufficient for assessment (NASM 2024)
- Advanced lifters progress very slowly; longer windows needed to distinguish noise from plateau (Rippetoe 2015)
- Training age classification based on rate of progress is more accurate than time-based categorization alone (Starting Strength methodology)

### 2.3 Contextual Factors (Exclusions)

Exclude from plateau detection:
1. **Deload weeks:** Intentional volume reduction (flag in database)
2. **Injury recovery:** First 2-4 weeks after return
3. **Program changes:** First 2 weeks of new program (adaptation period)
4. **Life stress indicators:** User-reported or inferred from training consistency drop

```sql
-- Contextual exclusion logic
WHERE NOT EXISTS (
  SELECT 1 FROM session_flags sf
  WHERE sf.session_id = ps.id
    AND sf.flag_type IN ('deload', 'injury_recovery', 'program_change')
    AND sf.date BETWEEN current_date - INTERVAL '4 weeks' AND current_date
)
```

---

## 3. Actionable Recommendations

### 3.1 When to Deload

**Indicators:**
- 2+ consecutive weeks of performance decline (volume OR weight)
- Plateau score > 0.7 with subjective fatigue indicators
- 4-8 weeks of continuous progressive overload

**Deload Protocol:**
```
Volume reduction: 40-60% of normal
Intensity: Maintain or slight reduction (80-90% of normal weights)
Duration: 1 week
Frequency: Every 4-8 weeks depending on training age and intensity
```

**Evidence:**
- **Ogasawara et al. (2013):** Periodic training group (with three-week deload after six weeks) achieved same muscle hypertrophy and strength as continuous training over 24 weeks, **despite completing 20-25% fewer workouts** (DOI: 10.1007/s00421-012-2511-9)
- **International Delphi consensus (2023):** Most athletes benefit from deload after 4-8 weeks of progressive training (DOI: 10.1186/s40798-023-00617-z)

### 3.2 When to Change Program

**Indicators:**
- Plateau persists despite 1-2 deload weeks
- Volume stagnation > 6 weeks (intermediates) or > 12 weeks (advanced)
- Diminishing returns: Effort increasing but results flat
- R² < 0.3 (high variability, program may not suit lifter)

**Recommendations:**
1. **Exercise variation:** Change 30-50% of exercises, keep core lifts
2. **Rep range shift:** Move from hypertrophy (8-12) to strength (3-6) or vice versa
3. **Volume redistribution:** Adjust sets per muscle group
4. **Periodization change:** Linear → undulating or block periodization

### 3.3 When to Adjust Volume

**Increase volume if:**
- Consistent progress for 3+ weeks
- Recovery indicators good (sleep, soreness)
- Volume below maintenance threshold (< 10 sets/muscle/week)

**Decrease volume if:**
- Performance declining despite adequate recovery
- Fatigue accumulation (elevated resting HR, poor sleep)
- Volume exceeds recommended maximums (> 20 sets/muscle/week)

**Volume Adjustment Guidelines:**
```
Increase: +2-4 sets per muscle per week (gradual)
Decrease: -20-40% for recovery week
Never: Jump from 10 → 20 sets suddenly
```

**Evidence Base:** The 10-20 sets per muscle per week recommendation is supported by Schoenfeld et al.'s 2017 meta-analysis (DOI: 10.1080/02640414.2016.1210197) showing volumes over 9 sets have larger effects on muscle mass, and Baz-Valle et al.'s 2022 systematic review (DOI: 10.2478/hukin-2022-000017) identifying 12-20 weekly sets as optimal for trained individuals. Volumes beyond ~20 sets reach rapidly diminishing returns (Stronger By Science 2023).

### 3.4 When to Modify Exercise Selection

**Indicators:**
- Specific exercise plateaued while others progress
- Joint pain or discomfort on specific movement
- Biomechanical inefficiency (video analysis if available)

**Recommendation Matrix:**

| Issue | Solution |
|-------|----------|
| Squat plateau | Add variations: front squat, pause squat, box squat |
| Bench plateau | Add variations: close-grip, incline, floor press |
| Deadlift plateau | Add variations: deficit pulls, rack pulls, RDLs |
| Isolation plateau | Change angle, grip, or equipment |

---

## 4. Advanced Metrics

### 4.1 Week-over-Week Volume Delta

**Calculation:**
```sql
WITH weekly_volume AS (
  SELECT
    exercise_id,
    muscle_group,
    date_trunc('week', performed_at) as week,
    SUM(reps * weight_grams / 1000.0 * sets) as total_volume_kg
  FROM performed_sets
  GROUP BY exercise_id, muscle_group, week
)
SELECT
  *,
  LAG(total_volume_kg) OVER (PARTITION BY exercise_id ORDER BY week) as prev_week_volume,
  ((total_volume_kg - LAG(total_volume_kg) OVER (PARTITION BY exercise_id ORDER BY week))
    / NULLIF(LAG(total_volume_kg) OVER (PARTITION BY exercise_id ORDER BY week), 0)) * 100
    as wow_change_pct
FROM weekly_volume;
```

**Target Ranges:**
- Beginners: 5-10% increase
- Intermediates: 2-5% increase
- Advanced: 0.5-2% increase

**Plateau Signal:**
- WoW change < 2% for 3+ consecutive weeks (intermediates)
- WoW change oscillating around 0% with no trend

### 4.2 Rate of Progress (Velocity)

**First Derivative of Volume:**
```
Velocity(t) = [Volume(t) - Volume(t-1)] / Δt

Acceleration(t) = [Velocity(t) - Velocity(t-1)] / Δt
```

**Interpretation:**
- **Velocity > 0, Acceleration > 0:** Accelerating progress (rare, usually beginners)
- **Velocity > 0, Acceleration ≈ 0:** Steady progress (ideal for intermediates)
- **Velocity ≈ 0, Acceleration ≈ 0:** Plateau
- **Velocity < 0, Acceleration < 0:** Regression (overtraining or injury)

**SQL Implementation:**
```sql
WITH weekly_metrics AS (
  SELECT
    week,
    total_volume,
    total_volume - LAG(total_volume, 1) OVER (ORDER BY week) as velocity,
    (total_volume - LAG(total_volume, 1) OVER (ORDER BY week)) -
    (LAG(total_volume, 1) OVER (ORDER BY week) - LAG(total_volume, 2) OVER (ORDER BY week))
      as acceleration
  FROM weekly_volume
)
SELECT * FROM weekly_metrics;
```

### 4.3 Training Age Consideration

**Training Age Estimation:**
```sql
-- Estimate training age from account history and progression rate
WITH user_metrics AS (
  SELECT
    user_id,
    MIN(performed_at) as first_session_date,
    AVG(weekly_volume_change_pct) OVER (ORDER BY week ROWS BETWEEN 12 PRECEDING AND CURRENT ROW)
      as avg_12wk_progress
  FROM user_sessions
)
SELECT
  user_id,
  EXTRACT(EPOCH FROM (current_date - first_session_date)) / 2592000 as months_training,
  CASE
    WHEN avg_12wk_progress > 4 THEN 'beginner'
    WHEN avg_12wk_progress BETWEEN 1 AND 4 THEN 'intermediate'
    ELSE 'advanced'
  END as estimated_training_age
FROM user_metrics;
```

**Dynamic Threshold Adjustment:**
```sql
-- Adjust plateau detection threshold based on training age
SELECT
  *,
  CASE training_age
    WHEN 'beginner' THEN 0.05  -- 5% threshold
    WHEN 'intermediate' THEN 0.02  -- 2% threshold
    WHEN 'advanced' THEN 0.01  -- 1% threshold
  END as plateau_threshold
FROM user_training_age;
```

### 4.4 Diminishing Returns Detection

**Concept:** As training age increases, more effort yields smaller gains.

**Efficiency Ratio:**
```
Efficiency = Progress_Rate / Training_Volume

Example:
  Beginner: 5% progress with 12 sets/week = 0.42% per set
  Advanced: 1% progress with 18 sets/week = 0.056% per set
```

**Detection Algorithm:**
```sql
WITH efficiency_metrics AS (
  SELECT
    user_id,
    week,
    volume_change_pct / NULLIF(total_sets, 0) as efficiency_ratio,
    AVG(volume_change_pct / NULLIF(total_sets, 0)) OVER (
      PARTITION BY user_id
      ORDER BY week
      ROWS BETWEEN 8 PRECEDING AND CURRENT ROW
    ) as rolling_8wk_efficiency
  FROM weekly_performance
)
SELECT
  *,
  CASE
    WHEN efficiency_ratio < 0.5 * rolling_8wk_efficiency THEN 'diminishing_returns'
    ELSE 'normal'
  END as efficiency_status
FROM efficiency_metrics;
```

**Interpretation:**
- Efficiency < 50% of rolling average → Consider volume reduction or program change
- Consistent efficiency decline → Natural training age progression (expected)

---

## 5. SQL Implementation Approach

### 5.1 Core Window Functions

#### Moving Average (4-week)
```sql
SELECT
  user_id,
  exercise_id,
  week,
  total_volume,
  AVG(total_volume) OVER (
    PARTITION BY user_id, exercise_id
    ORDER BY week
    ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
  ) as ma_4week,
  STDDEV(total_volume) OVER (
    PARTITION BY user_id, exercise_id
    ORDER BY week
    ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
  ) as volatility_4week
FROM weekly_exercise_volume;
```

#### Exponential Weighted Moving Average
```sql
-- Recursive CTE for EWMA calculation
WITH RECURSIVE ewma_calc AS (
  -- Base case: first row
  SELECT
    user_id,
    exercise_id,
    week,
    total_volume,
    total_volume as ewma,
    1 as row_num
  FROM weekly_exercise_volume
  WHERE week = (SELECT MIN(week) FROM weekly_exercise_volume)

  UNION ALL

  -- Recursive case: subsequent rows
  SELECT
    w.user_id,
    w.exercise_id,
    w.week,
    w.total_volume,
    0.25 * w.total_volume + 0.75 * e.ewma as ewma,
    e.row_num + 1
  FROM weekly_exercise_volume w
  JOIN ewma_calc e ON w.user_id = e.user_id
    AND w.exercise_id = e.exercise_id
    AND w.week = e.week + INTERVAL '1 week'
)
SELECT * FROM ewma_calc;
```

#### Linear Regression (Slope Calculation)
```sql
WITH regression_data AS (
  SELECT
    user_id,
    exercise_id,
    week,
    ROW_NUMBER() OVER (PARTITION BY user_id, exercise_id ORDER BY week) as x,
    total_volume as y
  FROM weekly_exercise_volume
  WHERE week >= current_date - INTERVAL '6 weeks'
),
regression_stats AS (
  SELECT
    user_id,
    exercise_id,
    COUNT(*) as n,
    AVG(x) as x_mean,
    AVG(y) as y_mean,
    SUM((x - AVG(x) OVER (PARTITION BY user_id, exercise_id)) *
        (y - AVG(y) OVER (PARTITION BY user_id, exercise_id))) as covariance,
    SUM(POWER(x - AVG(x) OVER (PARTITION BY user_id, exercise_id), 2)) as variance_x
  FROM regression_data
  GROUP BY user_id, exercise_id
)
SELECT
  user_id,
  exercise_id,
  covariance / NULLIF(variance_x, 0) as slope,
  y_mean - (covariance / NULLIF(variance_x, 0)) * x_mean as intercept,
  -- R² calculation
  1 - (SUM(POWER(y - (y_mean + slope * (x - x_mean)), 2)) /
       SUM(POWER(y - y_mean, 2))) as r_squared
FROM regression_stats;
```

### 5.2 Plateau Detection Query

```sql
WITH weekly_metrics AS (
  -- Calculate weekly volume and basic stats
  SELECT
    ps.user_id,
    e.muscle_group,
    DATE_TRUNC('week', ps.performed_at) as week,
    SUM(pset.reps * pset.weight_grams / 1000.0) as total_volume_kg,
    AVG(pset.weight_grams / 1000.0) as avg_weight_kg,
    MAX(pset.weight_grams / 1000.0) as max_weight_kg,
    COUNT(DISTINCT ps.id) as session_count
  FROM performed_sessions ps
  JOIN performed_sets pset ON ps.id = pset.performed_session_id
  JOIN exercises e ON pset.exercise_id = e.id
  WHERE ps.performed_at >= current_date - INTERVAL '12 weeks'
    AND NOT EXISTS (
      -- Exclude deload/injury/program change periods
      SELECT 1 FROM session_flags sf
      WHERE sf.session_id = ps.id
        AND sf.flag_type IN ('deload', 'injury_recovery', 'program_change')
    )
  GROUP BY ps.user_id, e.muscle_group, week
),
trend_analysis AS (
  SELECT
    user_id,
    muscle_group,
    week,
    total_volume_kg,
    -- Moving averages
    AVG(total_volume_kg) OVER w4 as ma_4week,
    AVG(total_volume_kg) OVER w6 as ma_6week,
    -- Week-over-week change
    LAG(total_volume_kg, 1) OVER (PARTITION BY user_id, muscle_group ORDER BY week) as prev_week,
    ((total_volume_kg - LAG(total_volume_kg, 1) OVER (PARTITION BY user_id, muscle_group ORDER BY week))
      / NULLIF(LAG(total_volume_kg, 1) OVER (PARTITION BY user_id, muscle_group ORDER BY week), 0)) * 100
      as wow_change_pct,
    -- Linear regression slope (simplified - use separate CTE for full calculation)
    REGR_SLOPE(total_volume_kg, EXTRACT(EPOCH FROM week)) OVER w6 as trend_slope,
    REGR_R2(total_volume_kg, EXTRACT(EPOCH FROM week)) OVER w6 as trend_r2
  FROM weekly_metrics
  WINDOW
    w4 AS (PARTITION BY user_id, muscle_group ORDER BY week ROWS BETWEEN 3 PRECEDING AND CURRENT ROW),
    w6 AS (PARTITION BY user_id, muscle_group ORDER BY week ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
),
plateau_scoring AS (
  SELECT
    user_id,
    muscle_group,
    week,
    total_volume_kg,
    ma_4week,
    wow_change_pct,
    trend_slope,
    trend_r2,
    -- Volume stagnation score (0-1)
    CASE
      WHEN ABS(trend_slope) < 0.02 AND trend_r2 > 0.4 THEN 1.0
      WHEN ABS(wow_change_pct) < 2 THEN 0.7
      ELSE 0.0
    END as volume_stagnation_score,
    -- Plateau likelihood
    CASE
      WHEN ABS(trend_slope) < 0.02 AND trend_r2 > 0.4 THEN 'high'
      WHEN ABS(wow_change_pct) < 2 THEN 'medium'
      ELSE 'low'
    END as plateau_likelihood
  FROM trend_analysis
  WHERE week = DATE_TRUNC('week', current_date)  -- Current week only
)
SELECT
  user_id,
  muscle_group,
  plateau_likelihood,
  volume_stagnation_score,
  total_volume_kg,
  ma_4week,
  wow_change_pct,
  trend_slope,
  -- Recommendation
  CASE
    WHEN plateau_likelihood = 'high' THEN 'Consider deload or program modification'
    WHEN plateau_likelihood = 'medium' THEN 'Monitor closely for 1-2 more weeks'
    ELSE 'Progressing normally'
  END as recommendation
FROM plateau_scoring
ORDER BY volume_stagnation_score DESC;
```

### 5.3 Recommendation Engine Query

```sql
WITH plateau_detection AS (
  -- Reuse plateau detection logic from above
  SELECT * FROM plateau_scoring
),
user_context AS (
  SELECT
    user_id,
    -- Estimate training age
    EXTRACT(EPOCH FROM (current_date - MIN(performed_at))) / 2592000 as months_training,
    -- Recent deload history
    MAX(CASE WHEN sf.flag_type = 'deload' THEN sf.date ELSE NULL END) as last_deload_date,
    -- Weeks since last deload
    EXTRACT(EPOCH FROM (current_date - MAX(CASE WHEN sf.flag_type = 'deload' THEN sf.date END)))
      / 604800 as weeks_since_deload
  FROM performed_sessions ps
  LEFT JOIN session_flags sf ON ps.id = sf.session_id
  GROUP BY user_id
)
SELECT
  pd.user_id,
  pd.muscle_group,
  pd.plateau_likelihood,
  uc.weeks_since_deload,
  -- Smart recommendations
  CASE
    WHEN pd.plateau_likelihood = 'high' AND uc.weeks_since_deload > 6 THEN
      'DELOAD: Schedule 1-week deload (40-60% volume reduction)'
    WHEN pd.plateau_likelihood = 'high' AND uc.weeks_since_deload <= 6 THEN
      'PROGRAM CHANGE: Consider exercise variations or rep range modification'
    WHEN pd.plateau_likelihood = 'medium' AND uc.weeks_since_deload > 4 THEN
      'PREVENTIVE DELOAD: Consider light week to prevent plateau'
    WHEN pd.plateau_likelihood = 'medium' THEN
      'MONITOR: Track for 1-2 more weeks, maintain current program'
    ELSE
      'CONTINUE: Progressing well, maintain current approach'
  END as detailed_recommendation,
  -- Specific action items
  ARRAY[
    CASE WHEN pd.plateau_likelihood IN ('high', 'medium')
      THEN 'Review exercise selection for this muscle group' END,
    CASE WHEN uc.weeks_since_deload > 6
      THEN 'Deload recommended based on training duration' END,
    CASE WHEN pd.wow_change_pct < 0
      THEN 'Performance declining - check recovery and nutrition' END
  ]::text[] as action_items
FROM plateau_detection pd
JOIN user_context uc ON pd.user_id = uc.user_id
WHERE pd.plateau_likelihood != 'low';
```

---

## 6. Algorithm Design

### 6.1 Core Plateau Detection Algorithm

```
ALGORITHM: DetectPlateau(user_id, muscle_group, time_window)

INPUT:
  - user_id: User identifier
  - muscle_group: Target muscle group to analyze
  - time_window: Analysis period (default: 6 weeks)

OUTPUT:
  - plateau_status: {progressing, potential_plateau, confirmed_plateau}
  - confidence_score: 0.0-1.0
  - recommendations: Array of action items

STEPS:

1. DATA COLLECTION
   - Fetch weekly volume data for past time_window weeks
   - Exclude contextual periods (deloads, injuries, program changes)
   - Validate minimum data points (require >= 4 weeks)

2. CALCULATE MOVING AVERAGES
   - ma_4week = SimpleMovingAverage(volume, 4)
   - ewma = ExponentialWeightedMA(volume, α=0.25)

3. TREND ANALYSIS
   - slope, r_squared = LinearRegression(volume, weeks)
   - wow_changes = CalculateWeekOverWeekChanges(volume)
   - mk_p_value = MannKendallTest(volume)

4. SCORING
   volume_score = 0

   IF |slope| < threshold_by_training_age AND r_squared > 0.4:
     volume_score += 0.4

   IF COUNT(wow_changes < 2%) >= 3:
     volume_score += 0.3

   IF mk_p_value > 0.05:  // No significant trend
     volume_score += 0.3

5. CLASSIFICATION
   IF volume_score >= 0.7:
     plateau_status = confirmed_plateau
   ELSE IF volume_score >= 0.4:
     plateau_status = potential_plateau
   ELSE:
     plateau_status = progressing

6. RECOMMENDATIONS
   recommendations = GenerateRecommendations(
     plateau_status,
     weeks_since_deload,
     training_age,
     volume_score
   )

7. RETURN
   RETURN {
     status: plateau_status,
     confidence: volume_score,
     recommendations: recommendations,
     metrics: {slope, r_squared, ma_4week, wow_avg}
   }
```

### 6.2 Recommendation Generation Algorithm

```
ALGORITHM: GenerateRecommendations(plateau_status, weeks_since_deload, training_age, score)

STEPS:

1. INITIALIZE
   recommendations = []
   priority_level = 'low'

2. DELOAD CHECK
   IF weeks_since_deload > 8:
     recommendations.add("URGENT: Deload overdue (reduce volume 40-60%)")
     priority_level = 'high'
   ELSE IF weeks_since_deload > 6 AND plateau_status != 'progressing':
     recommendations.add("Consider deload week")
     priority_level = 'medium'

3. PLATEAU-SPECIFIC RECOMMENDATIONS
   IF plateau_status == 'confirmed_plateau':

     IF weeks_since_deload > 6:
       recommendations.add("Primary: Schedule deload week")
     ELSE:
       recommendations.add("Primary: Modify program")
       recommendations.add("  - Change 30-50% of exercises")
       recommendations.add("  - Adjust rep ranges")
       recommendations.add("  - Consider volume redistribution")

     recommendations.add("Monitor: Track recovery markers")
     priority_level = 'high'

   ELSE IF plateau_status == 'potential_plateau':
     recommendations.add("Monitor closely for 1-2 weeks")
     recommendations.add("Prepare contingency: Plan exercise variations")

     IF training_age == 'advanced':
       recommendations.add("Consider: Intensity variation techniques")

     priority_level = 'medium'

4. TRAINING AGE ADJUSTMENTS
   IF training_age == 'beginner':
     recommendations.add("Note: Beginners experience natural fluctuations")
     recommendations.add("Focus: Maintain consistency and form")

   ELSE IF training_age == 'advanced':
     recommendations.add("Note: Advanced lifters progress slowly")
     recommendations.add("Consider: Periodization strategy review")

5. VOLUME RECOMMENDATIONS
   recent_avg_volume = GetRecentAverageVolume(4)
   recommended_min = GetMinEffectiveVolume(muscle_group)
   recommended_max = GetMaxRecoverableVolume(muscle_group)

   IF recent_avg_volume < recommended_min:
     recommendations.add("Increase: Volume below minimum threshold")
   ELSE IF recent_avg_volume > recommended_max:
     recommendations.add("Decrease: Volume exceeds recovery capacity")

6. RETURN
   RETURN {
     recommendations: recommendations,
     priority: priority_level,
     next_assessment_date: current_date + (2 weeks)
   }
```

### 6.3 Efficiency Monitoring Algorithm

```
ALGORITHM: MonitorEfficiency(user_id)

PURPOSE: Detect diminishing returns and optimize training volume

STEPS:

1. CALCULATE EFFICIENCY RATIO
   FOR each muscle_group:
     efficiency = progress_rate / total_volume
     rolling_avg_efficiency = AVG(efficiency, last_8_weeks)

2. DETECT DIMINISHING RETURNS
   IF current_efficiency < 0.5 * rolling_avg_efficiency:
     status = 'diminishing_returns'

     recommendations.add("Volume may be excessive")
     recommendations.add("Consider: Reduce volume by 20-30%")
     recommendations.add("OR: Redistribute volume across exercises")

   ELSE IF current_efficiency < 0.7 * rolling_avg_efficiency:
     status = 'efficiency_declining'

     recommendations.add("Monitor: Efficiency trending down")
     recommendations.add("Prepare: Volume adjustment may be needed")

3. TRAINING AGE EXPECTATIONS
   expected_efficiency = GetExpectedEfficiency(training_age)

   IF current_efficiency < expected_efficiency:
     recommendations.add("Below expected: Review program design")
   ELSE IF current_efficiency >= expected_efficiency:
     recommendations.add("On track: Efficiency normal for training age")

4. RETURN
   RETURN {
     efficiency_ratio: current_efficiency,
     status: status,
     recommendations: recommendations
   }
```

---

## 7. Implementation Roadmap

### Phase 1: Foundation (Week 1-2)
- [ ] Implement weekly volume aggregation tables
- [ ] Create window function queries for moving averages
- [ ] Build basic regression slope calculations
- [ ] Add session flags table (deload, injury, program_change)

### Phase 2: Core Detection (Week 3-4)
- [ ] Implement plateau detection scoring algorithm
- [ ] Create training age estimation logic
- [ ] Build WoW change tracking
- [ ] Add contextual exclusion filters

### Phase 3: Recommendations (Week 5-6)
- [ ] Develop recommendation engine
- [ ] Implement deload tracking and suggestions
- [ ] Create program modification recommendations
- [ ] Build efficiency monitoring

### Phase 4: Validation & Refinement (Week 7-8)
- [ ] Test with historical data
- [ ] Validate false positive rates
- [ ] Tune thresholds based on user feedback
- [ ] A/B test recommendation effectiveness

---

## 8. Key Metrics Dashboard

Recommended dashboard metrics for plateau monitoring:

```
User Plateau Overview:
├── Current Status: {Progressing | Potential Plateau | Confirmed Plateau}
├── Confidence Score: 0.0-1.0
├── Weeks Since Last Deload: N weeks
├── Estimated Training Age: {Beginner | Intermediate | Advanced}
│
├── Volume Trends (4-week)
│   ├── Current Volume: X kg
│   ├── 4-week MA: Y kg
│   ├── Trend Slope: β₁
│   └── WoW Avg Change: ±Z%
│
├── Performance Metrics
│   ├── R² (Trend Strength): 0.0-1.0
│   ├── Efficiency Ratio: X% per set
│   └── Velocity: ±Y kg/week
│
└── Recommendations
    ├── Primary Action: [text]
    ├── Priority Level: {Low | Medium | High | Urgent}
    └── Next Assessment: [date]
```

---

## 9. Testing & Validation

### 9.1 Test Scenarios

**Scenario 1: True Plateau (Intermediate Lifter)**
```
Input: 6 weeks of flat volume (±1%), no deloads
Expected: confirmed_plateau, deload recommendation
```

**Scenario 2: Natural Fluctuation (Beginner)**
```
Input: 2 weeks flat, then +5% week 3
Expected: progressing, no alarm
```

**Scenario 3: Deload Period**
```
Input: Week 1-4 progress, Week 5 deload (-50%), Week 6 recovery
Expected: Exclude week 5, assess based on weeks 1-4, 6
```

**Scenario 4: Advanced Slow Progress**
```
Input: +0.5% per week over 8 weeks, consistent
Expected: progressing (adjusted for training age)
```

### 9.2 Validation Metrics

Track algorithm performance:
- **Sensitivity:** % of true plateaus correctly identified
- **Specificity:** % of non-plateaus correctly classified
- **False Positive Rate:** Target < 10%
- **User Satisfaction:** Post-recommendation survey scores

---

## 10. References & Evidence Base

**Citation Note:** All citations include DOIs and/or URLs for verification. DOIs provide permanent identifiers for academic papers. URLs were tested as of 2025-11-21; some may require institutional access or may be temporarily unavailable due to server issues.

### Statistical Methods

#### Moving Averages
- **Hyndman, R.J., & Athanasopoulos, G.** (2021). *Forecasting: Principles and Practice* (3rd ed). OTexts.
  - URL: https://otexts.com/fpp2/moving-averages.html
  - Application: Simple and exponential weighted moving averages for time series smoothing
  - Note: General forecasting methodology adapted for fitness data applications

- **Statistics By Jim** - Moving Average Smoothing for Data Preparation
  - URL: https://statisticsbyjim.com/time-series/moving-averages-smoothing/
  - Application: Practical guidance on smoothing techniques for noisy data

#### Mann-Kendall Test
- **Real Statistics Using Excel** - Mann-Kendall Test for Time Series Trend Detection
  - URL: https://real-statistics.com/time-series-analysis/time-series-miscellaneous/mann-kendall-test/
  - Application: Non-parametric trend detection without normality assumptions

- **Serinaldi, F., Chebana, F., & Kilsby, C.G.** (2020). Dissecting innovative trend analysis. *Frontiers in Earth Science*, 8:14.
  - DOI: 10.3389/feart.2020.00014
  - URL: https://www.frontiersin.org/articles/10.3389/feart.2020.00014/full
  - Findings: Re-evaluation of Mann-Kendall test power for time series with autocorrelation

- **Gocic, M. & Trajkovic, S.** (2024). Seasonally adjusted periodic time series for Mann-Kendall trend test. *Hydrological Sciences Journal*.
  - DOI: 10.1016/j.ejrh.2024.103061
  - URL: https://www.sciencedirect.com/science/article/pii/S1474706524003061
  - Findings: Enhanced reliability for time series with less than 30 data points

#### Linear Regression in Sports Performance
- **Number Analytics** (2024). 7 Surprising Stats Where Linear Regression Shapes Sports Data Analysis.
  - URL: https://www.numberanalytics.com/blog/surprising-stats-linear-regression-sports-data-analysis
  - Application: Linear regression for player development and progress tracking over time

- **Thrane, C.** (2023). Understanding statistics through sports: Linear regression. *Medium*.
  - URL: https://medium.com/@christerthrane/understanding-statistics-through-sports-linear-regression-b8ee4355d5b7
  - Application: Practical applications of regression analysis in athletic performance

### Training Science

#### Progressive Overload and Volume Progression
- **McMaster, D.T., Gill, N., Cronin, J., & McGuigan, M.** (2014). Progression of volume load and muscular adaptation during resistance exercise. *International Journal of Sports Medicine*, 35(5):370-377.
  - DOI: 10.1055/s-0033-1353140
  - URL: https://pmc.ncbi.nlm.nih.gov/articles/PMC4215195/
  - Findings: Systematic volume progression strategies for intermediate lifters

- **Plotkin, D., Coleman, M., Van Every, D., et al.** (2022). Progressive overload without progressing load? The effects of load or repetition progression on muscular adaptations. *PeerJ*, 10:e14142.
  - DOI: 10.7717/peerj.14142
  - URL: https://peerj.com/articles/14142/
  - Findings: Both load and repetition progressions viable for muscular adaptations

#### Deload Research
- **Ogasawara, R., Yasuda, T., Ishii, N., & Abe, T.** (2013). Comparison of muscle hypertrophy following 6-month of continuous and periodic strength training. *European Journal of Applied Physiology*, 113(4):975-985.
  - DOI: 10.1007/s00421-012-2511-9
  - **KEY FINDING:** No differences in strength and muscle CSA between continuous training and periodic group (with three-week cessation after six weeks) over 24 weeks, **despite periodic group completing 20-25% fewer workouts**
  - Application: Evidence for strategic deload implementation

- **Coleman, M., Burke, R., Augustin, F., et al.** (2024). Gaining more from doing less? The effects of a one-week deload period during supervised resistance training on muscular adaptations. *PeerJ*, 12:e16777.
  - DOI: 10.7717/peerj.16777
  - URL: https://peerj.com/articles/16777/
  - Findings: First controlled study on deloads; examined 9-week high-volume RT program with mid-point deload

- **Cleveland Clinic Health** (2024). Why You Should Have a Deload Week.
  - URL: https://health.clevelandclinic.org/deload-week
  - Application: Clinical perspective on deload benefits and implementation

- **Androulakis-Korakakis, P., Michalopoulos, N., Fisher, J.P., et al.** (2023). Integrating deloading into strength and physique sports training programmes: An international Delphi consensus approach. *Sports Medicine - Open*, 9:73.
  - DOI: 10.1186/s40798-023-00617-z
  - URL: https://pmc.ncbi.nlm.nih.gov/articles/PMC10511399/
  - Findings: International expert consensus on deload timing (4-8 weeks) and protocols

#### Training Age Classification
- **Rippetoe, M.** (2015). Intermediate and Advanced Training: A Few Ideas. *Starting Strength*.
  - URL: https://startingstrength.com/article/intermediate-and-advanced-training-a-few-ideas
  - **Classification by recovery time:** Novice (48-72 hours), Intermediate (1 week), Advanced (monthly cycles)
  - Application: Training age based on rate of progress rather than time training

- **Full Stack Body** (2024). Training Age: Beginner, Intermediate, Advanced.
  - URL: https://www.fullstackbody.com/articles/training-age/
  - **Time-based classification:** Beginner (6-12 months), Intermediate (1-3 years), Advanced (3+ years)
  - Application: Practical progression rate expectations by training age

- **Bony to Beastly** (2023). Are You a Beginner, Intermediate, or Advanced Lifter?
  - URL: https://bonytobeastly.com/beginner-intermediate-advanced-lifter/
  - Application: Multi-factor classification considering time, strength standards, and adaptation rates

#### Volume Recommendations
- **Schoenfeld, B.J., Ogborn, D., & Krieger, J.W.** (2017). Dose-response relationship between weekly resistance training volume and increases in muscle mass: A systematic review and meta-analysis. *Journal of Sports Sciences*, 35(11):1073-1082.
  - DOI: 10.1080/02640414.2016.1210197
  - **KEY FINDING:** Graded dose-response relationship; volumes over 9 sets per week had larger effect on muscle mass; each additional set = 0.37% increase in gains
  - Application: Evidence base for 10-20 sets per muscle per week recommendation

- **Baz-Valle, E., Balsalobre-Fernández, C., Alix-Fages, C., & Santos-Concejero, J.** (2022). A systematic review of the effects of different resistance training volumes on muscle hypertrophy. *Journal of Human Kinetics*, 81:199-210.
  - DOI: 10.2478/hukin-2022-000017
  - URL: https://pmc.ncbi.nlm.nih.gov/articles/PMC8884877/
  - **KEY FINDING:** 12-20 weekly sets per muscle group optimal for hypertrophy in young, trained men
  - Application: Defines "sweet spot" Maximum Adaptive Volume (MAV)

- **Stronger By Science** (2023). When does training volume reach the point of diminishing returns?
  - URL: https://www.strongerbyscience.com/research-spotlight-volume-returns/
  - Findings: ~20 sets per muscle per week is approximate point of rapidly diminishing returns for trained lifters

### Plateau Detection

#### Detection Windows and Periodization
- **NASM (National Academy of Sports Medicine)** (2024). Periodization Training Simplified: A Strategic Guide.
  - URL: https://blog.nasm.org/periodization-training-simplified
  - **Recommendation:** Phase shifts every 4-6 weeks for general fitness clients
  - Application: Evidence-based assessment intervals for progress monitoring

- **Stone, M.H., Hornsby, W.G., Haff, G.G., et al.** (2021). Periodization and block periodization in sports: Emphasis on strength-power training. *Strength and Conditioning Journal*, 43(2):42-52.
  - URL: https://pmc.ncbi.nlm.nih.gov/articles/PMC7706636/
  - Findings: Block periodization with 2-6 week phases per performance area

- **Apel, J.M., Lacey, R.M., & Kell, R.T.** (2011). A comparison of traditional and weekly undulating periodized strength training programs with total volume and intensity equated. *Journal of Strength and Conditioning Research*, 25(3):694-703.
  - Findings: Non-periodized programs may stagnate after 6 weeks; minimal gains (1.5%) weeks 6-12

#### Stagnation Criteria and Thresholds
- **Legion Athletics** (2024). 6 Proven Ways to Break Through Weightlifting Plateaus.
  - URL: https://legionathletics.com/weightlifting-plateau/
  - **Definition:** Plateau = stuck at same weight/reps on compound exercises for **at least 3 weeks**
  - Application: Practical threshold for distinguishing true plateaus from normal fluctuations

- **Tinto, A., Campanella, M., Fasano, A., et al.** (2022). A subject-tailored variability-based platform for overcoming the plateau effect in sports training: A narrative review. *Sports*, 10(2):19.
  - DOI: 10.3390/sports10020019
  - URL: https://pmc.ncbi.nlm.nih.gov/articles/PMC8834821/
  - Findings: Plateaus often appear after 3-4 weeks of routine exercise; neural adaptations occur within 3-week periods

#### Diminishing Returns
- **Weightology** (2024). Set Volume for Muscle Size: The Ultimate Evidence Based Bible.
  - URL: https://weightology.net/the-members-area/evidence-based-guides/set-volume-for-muscle-size-the-ultimate-evidence-based-bible/
  - Analysis: Comprehensive review of volume-response relationship and diminishing returns

### Additional Resources

#### Time Series Analysis General
- **Bruce, P., Bruce, A., & Gedeck, P.** (2020). *Practical Statistics for Data Scientists* (2nd ed). O'Reilly Media.
  - Application: Regression analysis and statistical testing fundamentals

- **Machine Learning Mastery** - Moving Average Smoothing for Time Series Forecasting in Python
  - URL: https://machinelearningmastery.com/moving-average-smoothing-for-time-series-forecasting-python/
  - Application: Implementation guidance for moving average techniques

---

## 11. Conclusion

Effective plateau detection requires a multi-faceted approach combining:

1. **Robust statistical methods** (moving averages, regression, Mann-Kendall)
2. **Context-aware criteria** (training age, deload history, life factors)
3. **Actionable recommendations** (deload, program change, volume adjustment)
4. **Continuous monitoring** (WoW changes, efficiency ratios, velocity metrics)

**Key Success Factors:**
- Balance sensitivity with false positive prevention
- Adjust thresholds based on training age
- Provide specific, actionable guidance
- Track and validate recommendation effectiveness

**Next Steps:**
1. Implement core SQL queries and window functions
2. Build plateau detection scoring in database views
3. Create recommendation engine with priority levels
4. Test with historical data and validate thresholds
5. Develop user-facing dashboard with clear metrics
6. Iterate based on user feedback and outcomes

---

**Document Version:** 1.0
**Last Updated:** 2025-11-21
**Status:** Research Complete - Ready for Implementation
