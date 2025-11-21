# Phase 2.3: 1RM Estimation & Relative Intensity Tracking

**Research Date:** 2025-11-21
**Duration:** 45 minutes
**Status:** Complete

## Executive Summary

This document provides research-backed guidance for implementing 1RM (one-repetition maximum) estimation and relative intensity tracking in the workout app. Key findings:

- **Best Formula:** Epley for 3-5 reps, Mayhew for 6-10+ reps
- **Reliability Threshold:** Formulas accurate up to 10 reps; unreliable beyond 15 reps
- **Currently Using:** Brzycki (good choice, slightly conservative)
- **Hypertrophy Zone:** 60-85% 1RM (broader than traditionally thought: ≥30% to near-failure)
- **Strength Zone:** 85-100% 1RM (trained athletes), 60-85% 1RM (beginners)

## 1RM Estimation Formulas

### Formula Equations

All formulas use:
- **W** = Weight lifted (in kg or lbs)
- **R** = Number of repetitions completed
- **e** = Euler's number (≈2.71828)

#### 1. Epley (1985)
```
1RM = W × (1 + 0.0333 × R)
```
- **Characteristics:** Linear relationship, simple calculation
- **Best For:** 3-5 reps, most commonly used
- **Tendency:** Slightly optimistic

#### 2. Brzycki (1993) - Currently Used
```
1RM = W × (36 / (37 - R))

# Alternative form:
1RM = W / (1.0278 - 0.0278 × R)
```
- **Characteristics:** Non-linear, conservative estimates
- **Best For:** 5-10 reps, broad applicability
- **Tendency:** Conservative (safer for programming)

#### 3. Mayhew et al. (1992)
```
1RM = (100 × W) / (52.2 + 41.9 × e^(-0.055 × R))
```
- **Characteristics:** Exponential relationship, most scientifically validated
- **Best For:** 6-20 reps, best overall accuracy
- **Tendency:** Lowest average error across rep ranges

#### 4. Lombardi (1989)
```
1RM = W × R^0.10
```
- **Characteristics:** Power function, simple calculation
- **Best For:** Lower rep ranges (1-5)
- **Tendency:** Optimistic estimates

#### 5. O'Conner et al. (1989)
```
1RM = W × (1 + 0.025 × R)
```
- **Characteristics:** Linear relationship, very conservative
- **Best For:** Lower reps, beginners
- **Tendency:** Most conservative

#### 6. Wathan (1994)
```
1RM = (100 × W) / (48.8 + 53.8 × e^(-0.075 × R))
```
- **Characteristics:** Exponential, similar to Mayhew
- **Best For:** 6-12 reps
- **Tendency:** Conservative

## Formula Accuracy Comparison

### Accuracy by Rep Range

| Rep Range | Most Accurate Formula | Average Error | Notes |
|-----------|----------------------|---------------|-------|
| **1-3 reps** | Epley | ±2.7 kg (1.3%) | Direct test preferred |
| **3-5 reps** | Epley, Lombardi | ±3-5 kg (2-3%) | Optimal estimation range |
| **5-7 reps** | Brzycki, Epley | ±3-5 kg (2-4%) | Excellent accuracy |
| **6-10 reps** | Mayhew, Brzycki | ±5-8 kg (3-5%) | Good accuracy, practical |
| **10-15 reps** | Mayhew, Brzycki | ±8-15 kg (5-10%) | Declining accuracy |
| **15+ reps** | All formulas poor | ±15-30 kg (10-20%+) | **Unreliable - avoid** |

### Research Findings

**Key Study (Multiple Regression Analysis):**
> "More accurate 1RM prediction occurred when using a 5RM load versus 10 and 20RM loads. Relative accuracy, similarity, and average error improved significantly when repetitions to fatigue (RTF) ≤ 10."

**Comparative Rankings:**
1. **Mayhew** - Lowest average error (-0.5%), best for 6+ reps
2. **Epley** - Most accurate at 3RM (+2.7kg, 1.3% error)
3. **Brzycki** - Most accurate at 5RM (-3.1kg, 1.5% error)
4. **Wathan** - Similar to Mayhew, conservative
5. **Lombardi** - Best at 3RM when averaged across lifts
6. **O'Conner** - Most conservative, good for beginners

**Formula Characteristics:**
- **Mayhew, Epley, Wathan** - Lowest average error across exercises
- **Brzycki, Wathan** - Conservative estimates (safer programming)
- **Lombardi, O'Conner** - More optimistic (15-20kg difference at high reps)
- **All formulas** - High error beyond 10 reps

### Formula Selection Guidelines

**Use Epley when:**
- Working with 3-5 rep sets
- Need simple, widely-recognized calculation
- Training experienced lifters

**Use Brzycki when (CURRENT):**
- Working with 5-10 rep sets
- Want conservative estimates
- Programming for safety
- Training general population

**Use Mayhew when:**
- Working with 6-15 rep sets
- Need best overall accuracy
- Willing to implement exponential formula

**Avoid estimation when:**
- Reps exceed 15
- Training rank beginners
- Precision is critical (test actual 1RM instead)

## Training Intensity Zones

### Percentage 1RM by Training Goal

| Zone | % 1RM | Reps | Sets | Purpose | Rest |
|------|-------|------|------|---------|------|
| **Max Strength** | 85-100% | 1-5 | 2-6 | Neural adaptation, max force | 3-5 min |
| **Functional Strength** | 80-85% | 5-6 | 3-5 | Strength + size | 2-3 min |
| **Hypertrophy** | 60-85% | 6-12 | 3-5 | Muscle growth | 1-2 min |
| **Hypertrophy (Extended)** | 30-85% | 6-30+ | 3-5 | Muscle growth (near failure) | 1-2 min |
| **Power** | 70-90% | 1-5 | 3-5 | Explosive movement | 3-5 min |
| **Power (Ballistic)** | 30-60% | 5-10 | 3-5 | Jump squats, throws | 2-3 min |
| **Muscular Endurance** | <60% | 15+ | 2-3 | Local endurance | 30-60s |

### Detailed Zone Analysis

#### 1. Maximum Strength (85-100% 1RM)
**Traditional View:**
- 85-100% 1RM for 1-5 reps
- 2-6 sets per exercise
- Focus on neural adaptation and recruitment

**Research Notes:**
- Trained athletes need ≥80% 1RM for max strength gains
- Beginners can gain strength at 60% 1RM
- Quality of reps > quantity
- Long rest periods essential (3-5 minutes)

#### 2. Hypertrophy (Muscle Growth)
**Traditional View:**
- 60-85% 1RM
- 8-12 reps ("hypertrophy zone")
- 3-5 sets per exercise

**Modern Research (2021 Meta-Analysis):**
> "Similar whole muscle growth can be achieved across a wide spectrum of loading ranges ≥ ~30% 1RM when sets are taken to or near failure."

**Key Insights:**
- Hypertrophy occurs across broad intensity range (30-85% 1RM)
- Critical factor: **proximity to failure** (0-3 RIR)
- 60-85% 1RM still optimal for time efficiency
- Higher loads (80-85%) build strength + size simultaneously
- Lower loads (30-60%) require more reps to failure

**Practical Application:**
- Primary hypertrophy: 70-85% 1RM, 6-12 reps
- Accessory work: 60-75% 1RM, 10-15 reps
- Deload/variation: 30-60% 1RM, 15-30 reps to near-failure

#### 3. Power Training (70-90% 1RM)
**Olympic Lifts:**
- 70-90% 1RM for peak power
- 1-3 reps, performed explosively
- 3-5 sets

**Ballistic Movements:**
- 30-60% 1RM (jump squats, medicine ball throws)
- 5-10 reps, max velocity
- Different loading for different power qualities

#### 4. Muscular Endurance (<60% 1RM)
- 15+ reps per set
- 2-3 sets
- Short rest (30-60 seconds)
- Sport-specific application

### Intensity Distribution Recommendations

**Well-Rounded Program (Weekly Volume):**
- 60-70% strength work (primary lifts, 80-90% 1RM)
- 25-30% hypertrophy work (accessories, 65-80% 1RM)
- 5-10% power/technique work (60-75% 1RM, explosive)
- 5% deload/endurance (30-60% 1RM)

**Hypertrophy Focus:**
- 20-30% high intensity (80-85% 1RM, 6-8 reps)
- 50-60% moderate intensity (70-80% 1RM, 8-12 reps)
- 20-30% lower intensity (60-70% 1RM, 12-15 reps)

**Strength Focus:**
- 40-50% very high intensity (85-95% 1RM, 1-5 reps)
- 30-40% high intensity (80-85% 1RM, 5-6 reps)
- 20-30% moderate intensity (70-80% 1RM, 6-10 reps)

## Reliability Thresholds & Accuracy

### Test-Retest Reliability
- **1RM testing reliability:** 92% of studies show ICC ≥ 0.90 (excellent)
- **Consistent across:** Bench press, squat, deadlift, leg press
- **Day-to-day variation:** ±2-3% for trained lifters

### Formula Reliability Thresholds

**High Reliability (Use with confidence):**
- ≤5 reps: Excellent (<3% error)
- 6-10 reps: Good (3-5% error)

**Moderate Reliability (Use with caution):**
- 11-15 reps: Fair (5-10% error)
- Consider using lower bound of estimate

**Low Reliability (Avoid):**
- >15 reps: Poor (10-20%+ error)
- Do not use for programming or tracking

### Reps in Reserve (RIR) Accuracy
**Research Finding:**
> "Males and females can determine RIR accurately (within ~1 repetition) during leg and chest press exercises when sets are performed within 0–3 repetitions from failure."

**Practical Implications:**
- RIR accurate within 0-3 reps of failure
- Lifters need training to gauge RIR accurately
- More accurate on compound movements (squat, bench, deadlift)
- Less accurate on isolation exercises

### Factors Affecting Accuracy

**Improves Accuracy:**
- Lower rep ranges (1-10)
- Training experience (better at gauging effort)
- Compound movements
- Consistent technique
- Fresh state (early in workout)

**Reduces Accuracy:**
- High rep ranges (>10)
- Novice lifters
- Isolation exercises
- Fatigue (late in workout)
- Inconsistent tempo/form

## Application to Workout App

### Per-Set Relative Intensity Tracking

**Implementation Strategy:**
```sql
-- Calculate estimated 1RM per set
-- Use multiple formulas, store all estimates
-- Display intensity as % of estimated 1RM
-- Track intensity distribution over time
```

**Key Metrics to Track:**
1. **Estimated 1RM per set** (using Brzycki + Mayhew)
2. **Relative intensity** (% of estimated 1RM)
3. **Volume load** (sets × reps × weight)
4. **Intensity distribution** (% of volume in each zone)
5. **Progressive overload** (trend over time)

### Recommended Implementation

**Primary Formula: Brzycki (Current)**
- Conservative, safe for programming
- Good accuracy 5-10 reps
- Simple calculation

**Secondary Formula: Mayhew**
- Best overall accuracy
- Better for higher reps (10-15)
- More complex calculation

**Use Case: Adaptive Selection**
```
IF reps <= 5 THEN use Epley
ELSIF reps <= 10 THEN use Brzycki
ELSIF reps <= 15 THEN use Mayhew
ELSE mark as "unreliable estimate"
```

### Training Zone Classification

**Per-Set Classification:**
```sql
CASE
  WHEN relative_intensity >= 0.85 THEN 'Max Strength'
  WHEN relative_intensity >= 0.70 THEN 'Hypertrophy/Strength'
  WHEN relative_intensity >= 0.60 THEN 'Hypertrophy'
  WHEN relative_intensity >= 0.30 THEN 'Hypertrophy (Light)'
  ELSE 'Endurance'
END
```

**Session-Level Analysis:**
- Calculate % of total volume in each zone
- Track intensity distribution over mesocycle
- Identify periodization patterns

**Exercise-Level Analysis:**
- Estimated 1RM per exercise (rolling average of set estimates)
- Track 1RM progress over time
- Flag when to test actual 1RM

### Data Quality Flags

**Flag sets for review when:**
- Reps > 15 (unreliable estimate)
- Reps = 1 (direct test, not estimate)
- Estimated 1RM decreases >10% between sets
- Relative intensity >100% (impossible, data error)

### Muscle Group Considerations

**Important Note:** All formulas developed primarily on:
- Bench press
- Squat
- Deadlift

**Potential Issues:**
- Isolation exercises may have different rep-RM relationships
- Small muscle groups fatigue differently
- Unilateral exercises may need adjustment

**Recommendation:**
- Apply formulas to all exercises
- Flag isolation exercises
- Future: Consider exercise-specific calibration

## SQL Implementation Notes

### Database Schema Additions

**Option 1: Computed Columns (Recommended)**
```sql
-- Add computed columns to exercise_sets table
ALTER TABLE exercise_sets
ADD COLUMN estimated_1rm_brzycki DECIMAL(6,2)
  GENERATED ALWAYS AS (
    CASE
      WHEN reps >= 37 THEN NULL  -- formula breaks down
      WHEN reps = 1 THEN weight_grams / 1000.0
      ELSE (weight_grams / 1000.0) * (36.0 / (37.0 - reps))
    END
  ) STORED;

ADD COLUMN estimated_1rm_mayhew DECIMAL(6,2)
  GENERATED ALWAYS AS (
    CASE
      WHEN reps = 1 THEN weight_grams / 1000.0
      ELSE (100.0 * weight_grams / 1000.0) /
           (52.2 + 41.9 * EXP(-0.055 * reps))
    END
  ) STORED;

ADD COLUMN estimated_1rm_epley DECIMAL(6,2)
  GENERATED ALWAYS AS (
    (weight_grams / 1000.0) * (1 + 0.0333 * reps)
  ) STORED;

-- Primary estimate: adaptive selection
ADD COLUMN estimated_1rm DECIMAL(6,2)
  GENERATED ALWAYS AS (
    CASE
      WHEN reps = 1 THEN weight_grams / 1000.0
      WHEN reps <= 5 THEN estimated_1rm_epley
      WHEN reps <= 10 THEN estimated_1rm_brzycki
      WHEN reps <= 15 THEN estimated_1rm_mayhew
      ELSE NULL  -- unreliable
    END
  ) STORED;
```

**Option 2: PostgreSQL Functions**
```sql
-- Brzycki formula function
CREATE OR REPLACE FUNCTION calculate_1rm_brzycki(
  weight_kg DECIMAL,
  reps INTEGER
) RETURNS DECIMAL AS $$
BEGIN
  IF reps = 1 THEN
    RETURN weight_kg;
  ELSIF reps >= 37 THEN
    RETURN NULL;  -- formula invalid
  ELSE
    RETURN weight_kg * (36.0 / (37.0 - reps));
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Mayhew formula function
CREATE OR REPLACE FUNCTION calculate_1rm_mayhew(
  weight_kg DECIMAL,
  reps INTEGER
) RETURNS DECIMAL AS $$
BEGIN
  IF reps = 1 THEN
    RETURN weight_kg;
  ELSE
    RETURN (100.0 * weight_kg) / (52.2 + 41.9 * EXP(-0.055 * reps));
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Adaptive 1RM estimation
CREATE OR REPLACE FUNCTION calculate_1rm(
  weight_kg DECIMAL,
  reps INTEGER
) RETURNS DECIMAL AS $$
BEGIN
  IF reps = 1 THEN
    RETURN weight_kg;
  ELSIF reps <= 5 THEN
    -- Epley formula
    RETURN weight_kg * (1 + 0.0333 * reps);
  ELSIF reps <= 10 THEN
    -- Brzycki formula
    RETURN calculate_1rm_brzycki(weight_kg, reps);
  ELSIF reps <= 15 THEN
    -- Mayhew formula
    RETURN calculate_1rm_mayhew(weight_kg, reps);
  ELSE
    RETURN NULL;  -- unreliable estimate
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

**Option 3: View for Analysis**
```sql
-- Create view with all 1RM estimates and relative intensity
CREATE OR REPLACE VIEW exercise_sets_with_intensity AS
SELECT
  es.*,

  -- 1RM estimates (all formulas)
  calculate_1rm_brzycki(es.weight_grams / 1000.0, es.reps) as est_1rm_brzycki,
  calculate_1rm_mayhew(es.weight_grams / 1000.0, es.reps) as est_1rm_mayhew,
  calculate_1rm_epley(es.weight_grams / 1000.0, es.reps) as est_1rm_epley,

  -- Primary estimate (adaptive)
  calculate_1rm(es.weight_grams / 1000.0, es.reps) as estimated_1rm,

  -- Relative intensity (% of estimated 1RM)
  (es.weight_grams / 1000.0) /
    NULLIF(calculate_1rm(es.weight_grams / 1000.0, es.reps), 0) as relative_intensity,

  -- Training zone classification
  CASE
    WHEN (es.weight_grams / 1000.0) /
         NULLIF(calculate_1rm(es.weight_grams / 1000.0, es.reps), 0) >= 0.85
    THEN 'Max Strength'
    WHEN (es.weight_grams / 1000.0) /
         NULLIF(calculate_1rm(es.weight_grams / 1000.0, es.reps), 0) >= 0.70
    THEN 'Hypertrophy/Strength'
    WHEN (es.weight_grams / 1000.0) /
         NULLIF(calculate_1rm(es.weight_grams / 1000.0, es.reps), 0) >= 0.60
    THEN 'Hypertrophy'
    WHEN (es.weight_grams / 1000.0) /
         NULLIF(calculate_1rm(es.weight_grams / 1000.0, es.reps), 0) >= 0.30
    THEN 'Hypertrophy (Light)'
    ELSE 'Endurance'
  END as training_zone,

  -- Data quality flags
  CASE
    WHEN es.reps > 15 THEN 'unreliable_estimate'
    WHEN es.reps = 1 THEN 'actual_test'
    ELSE 'valid'
  END as estimate_quality

FROM exercise_sets es;
```

### Aggregate Queries for Analytics

**Exercise-Level 1RM Tracking:**
```sql
-- Rolling estimated 1RM per exercise
SELECT
  e.exercise_name,
  ps.performed_at::date as session_date,
  AVG(calculate_1rm(es.weight_grams / 1000.0, es.reps)) as avg_estimated_1rm,
  MAX(calculate_1rm(es.weight_grams / 1000.0, es.reps)) as max_estimated_1rm,
  COUNT(*) as num_sets
FROM exercise_sets es
JOIN performed_sessions ps ON es.performed_session_id = ps.id
JOIN exercises e ON es.exercise_id = e.id
WHERE es.reps <= 15  -- only reliable estimates
GROUP BY e.exercise_name, ps.performed_at::date
ORDER BY e.exercise_name, ps.performed_at;
```

**Intensity Distribution per Session:**
```sql
-- Volume distribution across training zones
SELECT
  ps.id as session_id,
  ps.performed_at,
  SUM(CASE WHEN relative_intensity >= 0.85 THEN volume_load ELSE 0 END) as strength_volume,
  SUM(CASE WHEN relative_intensity BETWEEN 0.70 AND 0.85 THEN volume_load ELSE 0 END) as hypertrophy_strength_volume,
  SUM(CASE WHEN relative_intensity BETWEEN 0.60 AND 0.70 THEN volume_load ELSE 0 END) as hypertrophy_volume,
  SUM(CASE WHEN relative_intensity < 0.60 THEN volume_load ELSE 0 END) as endurance_volume,
  SUM(volume_load) as total_volume
FROM (
  SELECT
    es.performed_session_id,
    ps.performed_at,
    (es.weight_grams / 1000.0) /
      NULLIF(calculate_1rm(es.weight_grams / 1000.0, es.reps), 0) as relative_intensity,
    es.reps * (es.weight_grams / 1000.0) as volume_load
  FROM exercise_sets es
  JOIN performed_sessions ps ON es.performed_session_id = ps.id
  WHERE es.reps <= 15
) subquery
JOIN performed_sessions ps ON ps.id = subquery.performed_session_id
GROUP BY ps.id, ps.performed_at
ORDER BY ps.performed_at;
```

### Performance Considerations

**Indexing:**
```sql
-- Index for time-series queries
CREATE INDEX idx_performed_sessions_date
  ON performed_sessions(performed_at DESC);

-- Index for exercise-specific queries
CREATE INDEX idx_exercise_sets_exercise_id
  ON exercise_sets(exercise_id);

-- Composite index for analytics
CREATE INDEX idx_exercise_sets_analysis
  ON exercise_sets(exercise_id, performed_session_id, reps)
  WHERE reps <= 15;
```

**Recommendation:** Use computed columns for frequently accessed values, functions for ad-hoc calculations, and materialized views for complex analytics.

## Recommendations Summary

### Formula Selection
✅ **Keep Brzycki** as primary formula (current implementation)
✅ **Add Mayhew** as secondary for 10-15 rep sets
✅ **Add Epley** for very low rep sets (1-5 reps)
✅ **Implement adaptive selection** based on rep range

### Intensity Zones
✅ Use traditional zones (85%+ strength, 60-85% hypertrophy)
✅ Note that hypertrophy can occur 30-85% with near-failure training
✅ Track zone distribution to analyze training emphasis

### Data Quality
✅ Flag sets with >15 reps as "unreliable estimate"
✅ Calculate 1RM separately for each set (captures within-session fatigue)
✅ Use rolling averages for exercise-level 1RM tracking

### Analytics Features
✅ Per-exercise estimated 1RM over time (progress tracking)
✅ Session intensity distribution (periodization analysis)
✅ Volume load by intensity zone (training emphasis)
✅ Muscle group intensity patterns (future phase)

## References

### Primary Research Sources

1. **Accuracy Studies:**
   - "Accuracy of Seven Equations for Predicting 1RM Performance of Apparently Healthy, Sedentary Older Adults" - Multiple formula comparison study
   - "Prediction of one repetition maximum strength from multiple repetition maximum testing" - Rep range accuracy analysis

2. **Hypertrophy Research:**
   - "Loading Recommendations for Muscle Strength, Hypertrophy, and Local Endurance: A Re-Examination of the Repetition Continuum" (2021) - PMC7927075 - Modern view on hypertrophy training

3. **Reliability Studies:**
   - "Test–Retest Reliability of the One-Repetition Maximum (1RM) Strength Assessment: a Systematic Review" - PMC7367986 - Meta-analysis of 1RM reliability

4. **RIR Research:**
   - "Application of the Repetitions in Reserve-Based Rating of Perceived Exertion Scale for Resistance Training" - PMC4961270 - RIR accuracy within 0-3 reps to failure

5. **Rep-RM Relationships:**
   - "Maximal Number of Repetitions at Percentages of the One Repetition Maximum: A Meta-Regression and Moderator Analysis" - PMC10933212 - Comprehensive analysis of %1RM and rep relationships

### Formula Origins

- **Brzycki** (1993): "Strength testing: Predicting a one-rep max from reps-to-fatigue"
- **Epley** (1985): Boyd Epley, Strength Coach, University of Nebraska
- **Lombardi** (1989): "Beginning Weight Training"
- **Mayhew et al.** (1992): Journal of Applied Sport Science Research
- **O'Conner et al.** (1989): "Weight training: A scientific approach"
- **Wathan** (1994): "Load assignment by repetition number"

---

**Document Status:** Complete
**Next Steps:** Implement SQL functions and computed columns for 1RM estimation
**Related Documents:**
- `/home/user/workout_app/docs/research/phase-2-research-plan.md`
- Future: Phase 2.4 will apply these concepts to muscle group analytics
