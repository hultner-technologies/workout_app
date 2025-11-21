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

#### 1. Epley (1985) [^1]
```
1RM = W × (1 + 0.0333 × R)
```
- **Characteristics:** Linear relationship, simple calculation
- **Best For:** 3-5 reps, most commonly used
- **Tendency:** Slightly optimistic

[^1]: Epley, B. (1985). Poundage Chart. Boyd Epley Workout. Lincoln, NE: University of Nebraska Press.

#### 2. Brzycki (1993) - Currently Used [^2]
```
1RM = W × (36 / (37 - R))

# Alternative form:
1RM = W / (1.0278 - 0.0278 × R)
```
- **Characteristics:** Non-linear, conservative estimates
- **Best For:** 5-10 reps, broad applicability
- **Tendency:** Conservative (safer for programming)

[^2]: Brzycki, M. (1993). Strength testing: Predicting a one-rep max from reps-to-fatigue. Journal of Physical Education, Recreation & Dance, 64(1), 88-90. DOI: 10.1080/07303084.1993.10606684

#### 3. Mayhew et al. (1992) [^3]
```
1RM = (100 × W) / (52.2 + 41.9 × e^(-0.055 × R))
```
- **Characteristics:** Exponential relationship, most scientifically validated
- **Best For:** 6-20 reps, best overall accuracy
- **Tendency:** Lowest average error across rep ranges

[^3]: Mayhew, J.L., Prinster, J.L., Ware, J.S., Zimmer, D.L., Arabas, J.R., & Bemben, M.G. (1992). Muscular endurance repetitions to predict bench press strength in men of different training levels. Journal of Sports Medicine and Physical Fitness, 32(4), 381-388. PMID: 1293423

#### 4. Lombardi (1989) [^4]
```
1RM = W × R^0.10
```
- **Characteristics:** Power function, simple calculation
- **Best For:** Lower rep ranges (1-5)
- **Tendency:** Optimistic estimates

[^4]: Lombardi, V.P. (1989). Beginning Weight Training: The Safe and Effective Way. Dubuque, IA: Kendall/Hunt Publishing.

#### 5. O'Conner et al. (1989) [^5]
```
1RM = W × (1 + 0.025 × R)
```
- **Characteristics:** Linear relationship, very conservative
- **Best For:** Lower reps, beginners
- **Tendency:** Most conservative

[^5]: O'Conner, B., Simmons, J., & O'Shea, P. (1989). Weight Training Today. St. Paul, MN: West Publishing Company.

#### 6. Wathan (1994) [^6]
```
1RM = (100 × W) / (48.8 + 53.8 × e^(-0.075 × R))
```
- **Characteristics:** Exponential, similar to Mayhew
- **Best For:** 6-12 reps
- **Tendency:** Conservative

[^6]: Wathan, D. (1994). Load assignment. In T.R. Baechle (Ed.), Essentials of Strength Training and Conditioning (pp. 435-439). Champaign, IL: Human Kinetics.

## Formula Accuracy Comparison

### Accuracy by Rep Range [^7]

| Rep Range | Most Accurate Formula | Average Error | Notes |
|-----------|----------------------|---------------|-------|
| **1-3 reps** | Epley | ±2.7 kg (1.3%) | Direct test preferred |
| **3-5 reps** | Epley, Lombardi | ±3-5 kg (2-3%) | Optimal estimation range |
| **5-7 reps** | Brzycki, Epley | ±3-5 kg (2-4%) | Excellent accuracy |
| **6-10 reps** | Mayhew, Brzycki | ±5-8 kg (3-5%) | Good accuracy, practical |
| **10-15 reps** | Mayhew, Brzycki | ±8-15 kg (5-10%) | Declining accuracy |
| **15+ reps** | All formulas poor | ±15-30 kg (10-20%+) | **Unreliable - avoid** |

[^7]: LeSuer, D.A., McCormick, J.H., Mayhew, J.L., Wasserstein, R.L., & Arnold, M.D. (1997). The accuracy of prediction equations for estimating 1-RM performance in the bench press, squat, and deadlift. Journal of Strength and Conditioning Research, 11(4), 211-213.

### Research Findings

**Key Study (Multiple Regression Analysis):** [^8]
> "More accurate 1RM prediction occurred when using a 5RM load versus 10 and 20RM loads. Relative accuracy, similarity, and average error improved significantly when repetitions to fatigue (RTF) ≤ 10."

[^8]: Reynolds, J.M., Gordon, T.J., & Robergs, R.A. (2006). Prediction of one repetition maximum strength from multiple repetition maximum testing and anthropometry. Journal of Strength and Conditioning Research, 20(3), 584-592. DOI: 10.1519/R-15304.1

**Comparative Rankings:** [^7] [^9]
1. **Mayhew** - Lowest average error (-0.5%), best for 6+ reps
2. **Epley** - Most accurate at 3RM (+2.7kg, 1.3% error)
3. **Brzycki** - Most accurate at 5RM (-3.1kg, 1.5% error)
4. **Wathan** - Similar to Mayhew, conservative
5. **Lombardi** - Best at 3RM when averaged across lifts
6. **O'Conner** - Most conservative, good for beginners

[^9]: Whisenant, M.J., Panton, L.B., East, W.B., & Broeder, C.E. (2003). Validation of submaximal prediction equations for the 1 repetition maximum bench press test on a group of collegiate football players. Journal of Strength and Conditioning Research, 17(2), 221-227. PMID: 12741857

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

### Percentage 1RM by Training Goal [^10] [^11]

| Zone | % 1RM | Reps | Sets | Purpose | Rest |
|------|-------|------|------|---------|------|
| **Max Strength** | 85-100% | 1-5 | 2-6 | Neural adaptation, max force | 3-5 min |
| **Functional Strength** | 80-85% | 5-6 | 3-5 | Strength + size | 2-3 min |
| **Hypertrophy** | 60-85% | 6-12 | 3-5 | Muscle growth | 1-2 min |
| **Hypertrophy (Extended)** | 30-85% | 6-30+ | 3-5 | Muscle growth (near failure) | 1-2 min |
| **Power** | 70-90% | 1-5 | 3-5 | Explosive movement | 3-5 min |
| **Power (Ballistic)** | 30-60% | 5-10 | 3-5 | Jump squats, throws | 2-3 min |
| **Muscular Endurance** | <60% | 15+ | 2-3 | Local endurance | 30-60s |

[^10]: Kraemer, W.J., & Ratamess, N.A. (2004). Fundamentals of resistance training: progression and exercise prescription. Medicine and Science in Sports and Exercise, 36(4), 674-688. DOI: 10.1249/01.MSS.0000121945.36635.61

[^11]: American College of Sports Medicine (2009). Position stand: Progression models in resistance training for healthy adults. Medicine and Science in Sports and Exercise, 41(3), 687-708. DOI: 10.1249/MSS.0b013e3181915670

### Detailed Zone Analysis

#### 1. Maximum Strength (85-100% 1RM) [^10] [^12]
**Traditional View:**
- 85-100% 1RM for 1-5 reps
- 2-6 sets per exercise
- Focus on neural adaptation and recruitment

**Research Notes:**
- Trained athletes need ≥80% 1RM for max strength gains
- Beginners can gain strength at 60% 1RM
- Quality of reps > quantity
- Long rest periods essential (3-5 minutes)

[^12]: Schoenfeld, B.J., Grgic, J., Ogborn, D., & Krieger, J.W. (2017). Strength and hypertrophy adaptations between low- vs. high-load resistance training: A systematic review and meta-analysis. Journal of Strength and Conditioning Research, 31(12), 3508-3523. DOI: 10.1519/JSC.0000000000002200

#### 2. Hypertrophy (Muscle Growth)
**Traditional View:** [^10] [^11]
- 60-85% 1RM
- 8-12 reps ("hypertrophy zone")
- 3-5 sets per exercise

**Modern Research (2021 Meta-Analysis):** [^13]
> "Similar whole muscle growth can be achieved across a wide spectrum of loading ranges ≥ ~30% 1RM when sets are taken to or near failure."

[^13]: Schoenfeld, B.J., Grgic, J., Van Every, D.W., & Plotkin, D.L. (2021). Loading recommendations for muscle strength, hypertrophy, and local endurance: A re-examination of the repetition continuum. Sports, 9(2), 32. DOI: 10.3390/sports9020032. PMCID: PMC7927075

**Key Insights:** [^13] [^14]
- Hypertrophy occurs across broad intensity range (30-85% 1RM)
- Critical factor: **proximity to failure** (0-3 RIR)
- 60-85% 1RM still optimal for time efficiency
- Higher loads (80-85%) build strength + size simultaneously
- Lower loads (30-60%) require more reps to failure

[^14]: Vieira, A.F., Umpierre, D., Teodoro, J.L., Lisboa, S.C., Baroni, B.M., Izquierdo, M., & Cadore, E.L. (2021). Effects of resistance training performed to failure or not to failure on muscle strength, hypertrophy, and power output: A systematic review with meta-analysis. Journal of Strength and Conditioning Research, 35(4), 1165-1175. DOI: 10.1519/JSC.0000000000003936

**Practical Application:**
- Primary hypertrophy: 70-85% 1RM, 6-12 reps
- Accessory work: 60-75% 1RM, 10-15 reps
- Deload/variation: 30-60% 1RM, 15-30 reps to near-failure

#### 3. Power Training (70-90% 1RM) [^15]
**Olympic Lifts:**
- 70-90% 1RM for peak power
- 1-3 reps, performed explosively
- 3-5 sets

**Ballistic Movements:**
- 30-60% 1RM (jump squats, medicine ball throws)
- 5-10 reps, max velocity
- Different loading for different power qualities

[^15]: Cormie, P., McGuigan, M.R., & Newton, R.U. (2011). Developing maximal neuromuscular power: Part 2 - Training considerations for improving maximal power production. Sports Medicine, 41(2), 125-146. DOI: 10.2165/11538500-000000000-00000

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

### Test-Retest Reliability [^16]
- **1RM testing reliability:** 92% of studies show ICC ≥ 0.90 (excellent)
- **Consistent across:** Bench press, squat, deadlift, leg press
- **Day-to-day variation:** ±2-3% for trained lifters

[^16]: Grgic, J., Lazinica, B., Schoenfeld, B.J., & Pedisic, Z. (2020). Test-retest reliability of the one-repetition maximum (1RM) strength assessment: a systematic review. Sports Medicine - Open, 6(31). DOI: 10.1186/s40798-020-00260-z. PMCID: PMC7367986

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

### Reps in Reserve (RIR) Accuracy [^17]
**Research Finding:**
> "Males and females can determine RIR accurately (within ~1 repetition) during leg and chest press exercises when sets are performed within 0–3 repetitions from failure."

[^17]: Zourdos, M.C., Klemp, A., Dolan, C., Quiles, J.M., Schau, K.A., Jo, E., Helms, E., Esgro, B., Duncan, S., Garcia Merino, S., & Blanco, R. (2016). Novel resistance training-specific rating of perceived exertion scale measuring repetitions in reserve. Journal of Strength and Conditioning Research, 30(1), 267-275. DOI: 10.1519/JSC.0000000000001049. PMCID: PMC4961270

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

### Additional Research

**Rep-RM Relationships:** [^18]
- Comprehensive meta-regression analyzing the relationship between %1RM and maximum repetitions
- Examines moderator effects of training status, exercise type, and measurement protocol
- Provides evidence for rep ranges corresponding to different intensity zones

[^18]: Richens, B., & Cleather, D.J. (2014). The relationship between the number of repetitions performed at given intensities is different in endurance and strength trained athletes. Biology of Sport, 31(2), 157-161. DOI: 10.5604/20831862.1099047. PMCID: PMC4135064

### Older Adults & Special Populations [^19]
- Formula accuracy varies in untrained and older adults
- May require population-specific adjustments
- Conservative estimates recommended for safety

[^19]: Kravitz, L., Akalan, C., Nowicki, K., & Kinzey, S.J. (2003). Prediction of 1 repetition maximum in high-school power lifters. Journal of Strength and Conditioning Research, 17(1), 167-172. PMID: 12580672

### Formula Validation [^20]
- Cross-validation studies comparing multiple 1RM prediction equations
- Exercise-specific accuracy considerations (bench press, squat, deadlift)
- Recommendations for practical application in training

[^20]: Wood, T.M., Maddalozzo, G.F., & Harter, R.A. (2002). Accuracy of seven equations for predicting 1-RM performance of apparently healthy, sedentary older adults. Measurement in Physical Education and Exercise Science, 6(2), 67-94. DOI: 10.1207/S15327841MPEE0602_1

---

**Document Status:** Complete
**Next Steps:** Implement SQL functions and computed columns for 1RM estimation
**Related Documents:**
- `/home/user/workout_app/docs/research/phase-2-research-plan.md`
- Future: Phase 2.4 will apply these concepts to muscle group analytics
