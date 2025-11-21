# Phase 2.2: Advanced Set Type Volume Calculations

**Research Date:** 2025-11-21
**Focus:** Volume calculation methodologies for advanced set types and muscle group distribution analytics

---

## Executive Summary

This document provides research-backed formulas and methodologies for calculating effective training volume across different set types (regular, warm-up, drop-set, myo-rep, pyramid-set, super-set, AMRAP) and implementing muscle group volume distribution analytics.

**Key Findings:**
- Drop-sets produce equivalent hypertrophy to traditional sets when volume-equated, but with 2-3x higher fatigue (RPE 7.7 vs 5.3)
- Myo-reps deliver similar muscle growth to 3 traditional sets in 70% less time with 30% fewer total reps
- Supersets maintain training adaptations while reducing session duration, but require extended recovery between sessions
- Warm-up sets should be excluded when ≤60% of working set weight or ≤50-60% of 1RM
- Effective reps for hypertrophy occur primarily within 0-5 RIR (reps in reserve)

---

## 1. Advanced Set Type Volume Calculations

### 1.1 Regular Sets

**Definition:** Traditional resistance training sets with standard rest periods (1-5 minutes).

**Volume Calculation:**
```
Volume = Sets × Reps × Weight
Effective Volume = Sets × Effective_Reps × Weight
```

**Effective Reps Calculation:**
- Based on proximity to failure (RIR - Reps in Reserve)
- 0-5 RIR: All reps counted as effective
- 6+ RIR: Reduced effectiveness for hypertrophy

**Research Basis:**
- Muscle hypertrophy decreases linearly as sets terminate further from failure
- Anything beyond 4-5 RIR produces significantly less hypertrophy
- Strength gains remain similar across wide RIR ranges, but hypertrophy is RIR-dependent

**Implementation Recommendations:**
```sql
-- Count all reps for regular sets
effective_volume = sets * reps * weight_grams

-- Optional: Apply RIR adjustment if tracked
rir_multiplier = CASE
    WHEN rir BETWEEN 0 AND 3 THEN 1.0
    WHEN rir = 4 THEN 0.9
    WHEN rir = 5 THEN 0.8
    WHEN rir >= 6 THEN 0.6
END
```

---

### 1.2 Warm-Up Sets

**Definition:** Preparatory sets performed before working sets to increase muscle temperature, practice movement patterns, and prepare the nervous system.

**Volume Calculation:**
```
Effective Volume = 0 (excluded from training volume calculations)
```

**Exclusion Thresholds:**

**Method 1: Percentage of Working Set Weight**
- ≤50%: Always exclude
- 51-60%: Generally exclude
- 61-70%: Consider including at reduced weighting (0.3-0.5x)
- >70%: Include in volume calculations

**Method 2: Percentage of 1RM**
- ≤50% 1RM: Exclude
- 51-60% 1RM: Exclude
- 61-70% 1RM: May include at reduced weight
- >70% 1RM: Include

**Common Warm-Up Protocols:**
1. **Progressive Protocol:** 30% 1RM × 8, 40% × 6, 50% × 4, 60% × 2, 70% × 1, 80% × 1
2. **Working Set Based:** 50% working weight × 5, 70% × 4, 90% × 2
3. **General Training:** 50% 1RM × 6-10 reps

**Research Basis:**
- Warm-up sets explicitly excluded from volume calculations in literature
- Progressive protocols with decreasing reps minimize volume-induced fatigue
- Concern focuses on sets too close to working weight, not lighter preparation sets

**Implementation Recommendations:**
```sql
-- Exclude warm-up sets from volume calculations
CASE
    WHEN set_type = 'warm-up' THEN 0
    WHEN weight_grams < (working_weight * 0.60) THEN 0  -- Conservative exclusion
    ELSE weight_grams * reps
END

-- Alternative: Include heavy warm-ups with reduced weighting
CASE
    WHEN set_type = 'warm-up' AND weight_grams < (working_weight * 0.60) THEN 0
    WHEN set_type = 'warm-up' AND weight_grams >= (working_weight * 0.60) THEN weight_grams * reps * 0.4
    ELSE weight_grams * reps
END
```

---

### 1.3 Drop-Sets

**Definition:** Sets where weight is reduced (typically 20-30%) immediately after reaching failure, continuing with minimal rest until failure again, potentially repeated multiple times.

**Volume Calculation:**
```
Total Volume = Σ(reps_each_drop × weight_each_drop)
Fatigue-Adjusted Volume = Total_Volume × Fatigue_Multiplier
Fatigue_Multiplier = 1.0  -- No adjustment needed if comparing volume-equated studies
```

**Volume Equivalence:**
- When volume-equated: Drop-sets = Traditional sets for hypertrophy outcomes
- 1 drop-set ≈ 2-3 traditional sets in practical time efficiency
- However, fatigue cost is 2-3x higher

**Fatigue Metrics (2025 Research):**
- RPE: 7.7 ± 1.5 (drop-sets) vs 5.3 ± 1.4 (traditional sets)
- Larger immediate post-exercise strength/power decrease
- Time efficiency: 50-66% reduction in training duration
- Recovery time: Extended compared to traditional training

**Research Basis:**
- 2025 systematic review and meta-analysis: No significant hypertrophy differences when volume equated
- Drop-sets require training to failure to be effective
- Similar muscle strength, endurance, and hypertrophy outcomes to traditional and pre-exhaustion methods

**Implementation Recommendations:**
```sql
-- Count full volume for drop-sets
effective_volume = SUM(reps * weight_grams) -- Sum across all drops

-- Track fatigue separately for recovery recommendations
recovery_cost_multiplier = 1.5  -- 50% longer recovery recommended

-- Optional: Flag sessions with high drop-set volume
drop_set_volume_ratio = drop_set_volume / total_session_volume
recommend_extra_recovery = drop_set_volume_ratio > 0.3  -- >30% of volume from drop-sets
```

---

### 1.4 Myo-Reps (Rest-Pause Training)

**Definition:** An activation set near failure (12-30 reps) followed by multiple mini-sets (3-5 reps) with short rest periods (20-30 seconds) until target reps cannot be completed.

**Volume Calculation:**
```
Total Reps = Activation_Set_Reps + Σ(Mini_Set_Reps)
Effective Volume = Total_Reps × Weight
Time Efficiency = ~70% reduction vs traditional training
```

**Effective Reps Concept:**
- Traditional sets (8-12 reps): Only last 2-3 reps are "effective" (high motor unit recruitment)
- Myo-reps: ALL mini-set reps are "effective" after activation set maintains high motor unit recruitment

**Volume Equivalence (2025 Research):**
- 1 myo-rep set ≈ 3 traditional sets for hypertrophy
- 30% fewer total reps performed
- 70% less time required
- Similar muscle growth outcomes

**Example Comparison:**
```
Traditional: 3 sets × 10 reps = 30 reps (6 minutes, 9 effective reps)
Myo-reps: 1 activation set (15 reps) + 2 mini-sets (5+5 reps) = 25 reps (2 minutes, 18 effective reps)
```

**Research Basis:**
- Recent studies show equivalent muscle growth with significantly reduced time and rep volume
- Effective rep theory: Short rest periods maintain high motor unit activation
- Rest-pause training may be more effective for hypertrophy than strength

**Implementation Recommendations:**
```sql
-- For database storage, treat as single compound set
INSERT INTO sets (set_type, activation_reps, mini_set_reps, mini_set_count, ...)

-- Calculate volume normally
total_reps = activation_reps + (mini_set_count * mini_set_reps)
effective_volume = total_reps * weight_grams

-- Track efficiency metrics
time_efficiency_gain = 0.70  -- 70% time reduction
effective_reps_ratio = (mini_set_count * mini_set_reps + 3) / total_reps
-- Assumes ~3 effective reps in activation set

-- Volume equivalence for set counting
myo_rep_set_equivalent = 3.0  -- 1 myo-rep set ≈ 3 traditional sets
```

---

### 1.5 Pyramid Sets

**Definition:** Progressive variation in weight and reps across sets, either ascending (lighter to heavier), descending (heavier to lighter), or combined (up then down).

**Volume Calculation:**
```
Total Volume = Σ(sets × reps × weight)
-- No special adjustment needed; count actual volume performed
```

**Types and Volume Patterns:**

**1. Ascending Pyramid (Standard):**
```
Set 1: 12 reps @ 135 lbs
Set 2: 10 reps @ 155 lbs
Set 3: 8 reps @ 175 lbs
Set 4: 6 reps @ 195 lbs
```
- Covers multiple training adaptations: endurance, hypertrophy, strength
- Earlier sets may function as extended warm-up
- Peak intensity in final sets when partially fatigued

**2. Descending/Reverse Pyramid (RPT):**
```
Set 1: 6 reps @ 195 lbs (heaviest when fresh)
Set 2: 8 reps @ 175 lbs
Set 3: 10 reps @ 155 lbs
Set 4: 12 reps @ 135 lbs
```
- Maximum effort when freshest
- Allows higher intensity on primary working sets
- Subsequent sets provide additional volume while fatigued

**3. Full Pyramid (Triangle):**
```
Ascend then descend through rep/weight ranges
```

**Progressive Overload Applications:**
1. **Volume Progression:** Increase total sets (e.g., 3-set to 5-set to 7-set pyramid)
2. **Weight Progression:** Increase weight at each step of pyramid
3. **Increment Progression:** Increase weight jumps between sets
4. **Peak Weight:** Increase the top weight while maintaining structure

**Research Basis:**
- Covers multiple training outcomes: strength, hypertrophy, endurance
- Requires structured approach prioritizing progressive overload and recovery
- Training volume easily calculated by summing all sets × reps × weight

**Implementation Recommendations:**
```sql
-- Count all pyramid sets normally
effective_volume = SUM(reps * weight_grams)

-- Track pyramid structure for pattern analysis
pyramid_type = CASE
    WHEN weight increases across sets THEN 'ascending'
    WHEN weight decreases across sets THEN 'descending'
    WHEN weight increases then decreases THEN 'full'
END

-- Optional: Consider excluding lightest sets if they're really warm-up
-- E.g., first set if <60% of peak pyramid weight
CASE
    WHEN weight_grams < (max_set_weight * 0.60) AND set_number = 1 THEN 0
    ELSE reps * weight_grams
END
```

---

### 1.6 Super-Sets

**Definition:** Two exercises performed back-to-back with minimal or no rest between them.

**Types:**
1. **Agonist-Antagonist:** Opposing muscle groups (e.g., bicep curl + tricep extension)
2. **Same Muscle Group:** Same primary mover (e.g., bench press + chest fly)
3. **Upper-Lower:** Different body regions (e.g., bench press + leg curl)
4. **Compound-Isolation:** Compound movement followed by isolation (e.g., squat + leg extension)

**Volume Calculation:**
```
Total Volume = Exercise_A_Volume + Exercise_B_Volume
-- Count each exercise's volume separately toward respective muscle groups
```

**Volume Considerations (2025 Research):**
- **Agonist-Antagonist supersets:** Best for maintaining training volume
- **Same muscle group supersets:** Compromise volume load capability
- Higher internal loads, more severe muscle damage, increased perceived exertion
- Time-efficient alternative: ≈50% reduction in session duration
- No compromise to chronic adaptations in maximal strength, strength endurance, or hypertrophy

**Fatigue and Recovery:**
- Higher RPE and fatigue vs traditional training
- Requires potentially extended recovery times between sessions
- Muscle damage markers elevated

**Research Basis:**
- February 2025 systematic review and meta-analysis
- No compromise to training volume, muscle activation, or chronic adaptations when programmed appropriately
- Internal load (heart rate, RPE, blood lactate) significantly higher

**Implementation Recommendations:**
```sql
-- Track as linked sets with superset_group_id
CREATE TABLE sets (
    id UUID,
    superset_group_id UUID,  -- Links paired exercises
    exercise_id UUID,
    ...
);

-- Calculate volume for each exercise normally
effective_volume_exercise_a = SUM(reps * weight_grams) WHERE exercise = A
effective_volume_exercise_b = SUM(reps * weight_grams) WHERE exercise = B

-- Volume distribution to muscle groups handled per-exercise
-- (See Section 2: Muscle Group Considerations)

-- Track superset type for analytics
superset_type = CASE
    WHEN muscle_groups_overlap = 'antagonist' THEN 'agonist-antagonist'
    WHEN muscle_groups_overlap = 'same' THEN 'same-muscle'
    WHEN body_region_differs THEN 'upper-lower'
END

-- Recovery recommendations
recovery_multiplier = 1.2  -- 20% longer recovery vs traditional
-- Higher for same-muscle supersets
CASE
    WHEN superset_type = 'same-muscle' THEN 1.4
    ELSE 1.2
END
```

---

### 1.7 AMRAP (As Many Reps As Possible) Sets

**Definition:** Sets performed for maximum repetitions at a given weight, typically not to absolute failure but to technical failure or near-failure (1-2 RIR).

**Volume Calculation:**
```
Volume = Reps_Achieved × Weight
-- Count actual reps performed; no special adjustment
```

**Hypertrophy Considerations:**
- Total volume is primary driver of hypertrophy
- AMRAP sets enable higher total volume with meaningful weight
- Training to failure increases growth factor responses beneficial for hypertrophy
- Moderate loads (60-70% 1RM) targeting 10-15 reps optimal for hypertrophy

**Strength vs. Hypertrophy:**
- May favor muscular endurance and hypertrophy over maximum strength
- Often programmed as autoregulation: adjusts training based on daily readiness

**Practical Programming:**
- **Technical Failure vs. Absolute Failure:** Stopping at technical failure (form breakdown) recommended for main lifts
- **Buffer Recommendation:** Programs like 5/3/1 and Juggernaut advocate keeping 1-2 reps in reserve
- **Frequency:** Often used for final set of exercise (e.g., "3×5 + 1×AMRAP")

**Research Basis:**
- High volume resistance exercises build muscle through time under tension
- Training to failure vs. leaving buffer involves trade-off between stimulus and fatigue
- Total volume quantification valid method for hypertrophy training

**Implementation Recommendations:**
```sql
-- Count actual volume achieved
effective_volume = reps * weight_grams

-- Track as performance indicator
amrap_performance = reps  -- Compare across sessions for progress tracking

-- Optional: Estimate RIR based on performance patterns
estimated_rir = CASE
    WHEN reps >= (expected_reps + 3) THEN 3  -- Stopped early
    WHEN reps >= (expected_reps + 1) THEN 1  -- Small buffer
    WHEN reps = expected_reps THEN 0  -- True AMRAP to failure
END

-- Volume counting for program totals
-- No adjustment needed; actual volume = effective volume
```

---

## 2. Muscle Group Considerations

### 2.1 Primary vs. Secondary Muscle Activation

**Definitions:**
- **Primary Muscles:** Muscles that control the movement; intended target of the exercise
- **Secondary Muscles:** Muscles that assist primary muscles to complete the exercise
- **Stabilizer Muscles:** Muscles that stabilize joints during movement

**Activation Measurement:**
- Measured via EMG (electromyography) as percentage of Maximum Voluntary Isometric Contraction (%MVIC)
- Research normalizes EMG response against maximum isometric contraction values for each muscle

**Activation Thresholds for Training Adaptation:**
- **>60% MVIC:** More conducive to developing muscular strength
- **41-60% MVIC:** High activation; beneficial for muscle endurance
- **<40% MVIC:** Moderate to low activation

**Volume Distribution Example:**
```
Barbell Bench Press (individual variation example):
- Pectoralis Major: 40% of load distribution
- Triceps Brachii: 40% of load distribution
- Anterior Deltoid: 20% of load distribution
```

---

### 2.2 Exercise-Specific Muscle Activation Profiles

**Research-Based High Activation Exercises (>60% MVIC):**

**Gluteus Maximus:**
- Step-up variations
- Hex bar deadlift
- Barbell hip thrust variations
- Belt squat
- Split squat variations
- Lunge variations

**Major Compound Movements:**

**Barbell Squat:**
- Primary: Quadriceps (vastus lateralis, vastus medialis, rectus femoris)
- Secondary: Gluteus maximus, adductor magnus
- Note: Does NOT appreciably train hamstrings
- Muscle groups: Quads, glutes, adductors, core

**Deadlift:**
- Primary: Erector spinae, gluteus maximus, hamstrings
- Secondary: Quadriceps, latissimus dorsi, trapezius, forearms, core
- True full-body movement

**Bench Press:**
- Primary: Pectoralis major (clavicular and sternal heads)
- Secondary: Anterior deltoid, triceps brachii
- Stabilizers: Rotator cuff muscles, core

**Important Principle:**
> "Just because the primary goal of doing the bench press is to build pecs, doesn't mean the front delts and triceps don't experience mechanical tension."

This means compound exercises contribute meaningful volume to multiple muscle groups simultaneously.

---

### 2.3 Volume Counting Methods for Muscle Groups

**Three Methodologies (2025 Meta-Regression Research):**

**1. Direct Sets:**
```
Only count sets where the target muscle is the likely primary force generator
Example: Bench press → Chest (direct), NOT counted for triceps
```

**2. Total Sets:**
```
Count all sets where target muscle is primary OR synergist, weighted equally
Example: Bench press → Chest (1.0), Triceps (1.0), Anterior Deltoid (1.0)
```

**3. Fractional Sets (RECOMMENDED):**
```
Count sets where target muscle is primary as 1.0
Count sets where target muscle is synergist as 0.5
Example: Bench press → Chest (1.0), Triceps (0.5), Anterior Deltoid (0.5)
```

**Research Finding:**
> "To quantify the dose-response relationship, it is paramount to distinguish between 'fractional' and 'direct' set counting methods."

**Volume Thresholds (per muscle group, per week):**
- **Minimum Effective Dose:** 4 sets/week for hypertrophy
- **Optimal Range:** 12-20 sets/week
- **Diminishing Returns:** >20 sets/week
- **Per-Session Optimal:** ~2-11 sets for hypertrophy (point of undetectable outcome superiority)

---

### 2.4 Compound vs. Isolation Exercise Ratios

**Compound Exercise Benefits:**
- Train multiple muscle groups simultaneously
- Higher total muscle activation
- Greater metabolic demand
- More functional strength transfer
- Time-efficient

**Volume Distribution Considerations:**

**Problem:** Arms and shoulders receive volume from multiple exercises
```
Example Weekly Shoulder Volume:
- 4 sets bench press (secondary: anterior delt)
- 4 sets overhead press (primary: all delts)
- 3 sets lateral raises (primary: lateral delt)
- 2 sets rear delt flies (primary: posterior delt)

Total shoulder volume from primaries: 9 sets
Total shoulder volume including secondaries: 13 sets
```

**Recommendation:**
Count both primary and secondary contributions (fractional method) to avoid overtraining smaller muscle groups that are heavily involved in multiple movements.

**Isolation Work Necessity:**
- Addresses specific muscle weaknesses
- Ensures balanced development
- Lower fatigue cost than compounds
- Targets muscles underdeveloped by compounds alone

**Practical Split Recommendations:**
```
Push Day Example:
- Compound exercises: 60-70% of volume (bench press, overhead press)
- Isolation exercises: 30-40% of volume (lateral raises, tricep extensions, chest flies)

This ensures primary muscles get direct volume while managing fatigue on heavily-worked secondaries.
```

---

### 2.5 Muscle Imbalance Detection Algorithms

**Current State:**
> "There is currently no literature available that examines primary, secondary, and stabilization musculature over a broad spectrum of muscle/exercise combinations simultaneously."

**However, emerging approaches exist:**

**1. AI-Driven MRI Analysis:**
- Creates 3D "digital twin" of athlete's musculature
- Machine learning analytics for muscle volume assessment
- Detects left-to-right asymmetries
- Identifies muscle fat infiltration
- Assesses morphological features

**2. EMG-Based Machine Learning:**
- Myographic signals detect subtle muscle function changes
- AI analysis makes complex signal analysis feasible
- Neural network models trained with 10^6 samples achieve <0.5% kinematic errors

**3. Training Volume-Based Detection (Practical Approach):**

**Bilateral Imbalance Detection:**
```sql
-- Compare unilateral exercise volume
LEFT vs RIGHT single-leg press volume over 4 weeks
Threshold: >15% discrepancy = flag for attention
```

**Muscle Group Imbalance Detection:**
```sql
-- Check push/pull ratio
push_volume = SUM(volume) WHERE muscle_group IN ('chest', 'triceps', 'front_delt')
pull_volume = SUM(volume) WHERE muscle_group IN ('back', 'biceps', 'rear_delt')
push_pull_ratio = push_volume / pull_volume

Healthy Range: 0.8 - 1.2
Flag if: ratio < 0.7 OR ratio > 1.3
```

**Quad-Hamstring Balance:**
```sql
quad_volume = SUM(volume) WHERE primary_muscle IN ('vastus_lateralis', 'rectus_femoris', 'vastus_medialis')
hamstring_volume = SUM(volume) WHERE primary_muscle IN ('biceps_femoris', 'semitendinosus', 'semimembranosus')

quad_ham_ratio = quad_volume / hamstring_volume

Healthy Range: 1.0 - 1.5 (quads slightly higher is normal)
Flag if: ratio > 2.0 (excessive quad dominance)
```

**Anterior-Posterior Shoulder Balance:**
```sql
anterior_delt_volume = SUM(volume) WHERE 'anterior_deltoid' IN muscle_groups
posterior_delt_volume = SUM(volume) WHERE 'posterior_deltoid' IN muscle_groups

anterior_posterior_ratio = anterior_delt_volume / posterior_delt_volume

Healthy Range: 1.0 - 1.5
Flag if: ratio > 2.0 (common imbalance from bench press emphasis)
```

---

## 3. Implementation Recommendations for Analytics

### 3.1 Database Schema Recommendations

**Sets Table Extensions:**
```sql
ALTER TABLE sets ADD COLUMN IF NOT EXISTS set_type TEXT CHECK (
    set_type IN ('regular', 'warm-up', 'drop-set', 'myo-rep', 'pyramid-set', 'super-set', 'amrap')
);

-- For myo-reps
ALTER TABLE sets ADD COLUMN activation_reps INTEGER;
ALTER TABLE sets ADD COLUMN mini_set_reps INTEGER;
ALTER TABLE sets ADD COLUMN mini_set_count INTEGER;

-- For supersets
ALTER TABLE sets ADD COLUMN superset_group_id UUID;

-- For all sets
ALTER TABLE sets ADD COLUMN estimated_rir INTEGER;  -- Reps in reserve
ALTER TABLE sets ADD COLUMN rpe NUMERIC(3,1);  -- Rate of perceived exertion (1-10)
```

**Exercise-Muscle Mapping Table:**
```sql
CREATE TABLE exercise_muscle_groups (
    exercise_id UUID REFERENCES exercises(id),
    muscle_group TEXT,
    contribution_type TEXT CHECK (contribution_type IN ('primary', 'secondary', 'stabilizer')),
    activation_percentage NUMERIC(3,2),  -- 0.00 to 1.00
    -- For volume counting
    volume_multiplier NUMERIC(3,2) DEFAULT 1.0,  -- 1.0 for primary, 0.5 for secondary
    PRIMARY KEY (exercise_id, muscle_group, contribution_type)
);

-- Example data
INSERT INTO exercise_muscle_groups VALUES
    ('bench_press_id', 'chest', 'primary', 0.40, 1.0),
    ('bench_press_id', 'triceps', 'secondary', 0.40, 0.5),
    ('bench_press_id', 'anterior_deltoid', 'secondary', 0.20, 0.5);
```

---

### 3.2 Volume Calculation Functions

**Main Volume Calculation Function:**
```sql
CREATE OR REPLACE FUNCTION calculate_effective_volume(
    p_set_id UUID
) RETURNS NUMERIC AS $$
DECLARE
    v_set_type TEXT;
    v_reps INTEGER;
    v_weight_grams INTEGER;
    v_rir INTEGER;
    v_activation_reps INTEGER;
    v_mini_set_reps INTEGER;
    v_mini_set_count INTEGER;
    v_working_weight INTEGER;
    v_total_reps INTEGER;
    v_base_volume NUMERIC;
    v_adjusted_volume NUMERIC;
BEGIN
    -- Fetch set details
    SELECT set_type, reps, weight_grams, estimated_rir,
           activation_reps, mini_set_reps, mini_set_count
    INTO v_set_type, v_reps, v_weight_grams, v_rir,
         v_activation_reps, v_mini_set_reps, v_mini_set_count
    FROM sets WHERE id = p_set_id;

    -- Warm-up exclusion
    IF v_set_type = 'warm-up' THEN
        -- Get working weight for this exercise in this session
        SELECT MAX(weight_grams) INTO v_working_weight
        FROM sets
        WHERE exercise_id = (SELECT exercise_id FROM sets WHERE id = p_set_id)
          AND session_id = (SELECT session_id FROM sets WHERE id = p_set_id)
          AND set_type != 'warm-up';

        -- Exclude if <60% of working weight
        IF v_weight_grams < (v_working_weight * 0.60) THEN
            RETURN 0;
        END IF;
    END IF;

    -- Calculate base volume by set type
    CASE v_set_type
        WHEN 'myo-rep' THEN
            v_total_reps := v_activation_reps + (v_mini_set_count * v_mini_set_reps);
            v_base_volume := v_total_reps * v_weight_grams;

        WHEN 'drop-set' THEN
            -- Sum reps × weight across all drops (requires set group tracking)
            SELECT SUM(reps * weight_grams) INTO v_base_volume
            FROM sets
            WHERE drop_set_group_id = (SELECT drop_set_group_id FROM sets WHERE id = p_set_id);

        ELSE
            -- Regular, pyramid, super-set, AMRAP: standard calculation
            v_base_volume := v_reps * v_weight_grams;
    END CASE;

    -- Optional: Apply RIR adjustment
    IF v_rir IS NOT NULL THEN
        v_adjusted_volume := v_base_volume * (
            CASE
                WHEN v_rir BETWEEN 0 AND 3 THEN 1.0
                WHEN v_rir = 4 THEN 0.9
                WHEN v_rir = 5 THEN 0.8
                WHEN v_rir >= 6 THEN 0.6
            END
        );
    ELSE
        v_adjusted_volume := v_base_volume;
    END IF;

    RETURN v_adjusted_volume;
END;
$$ LANGUAGE plpgsql;
```

**Muscle Group Volume Distribution:**
```sql
CREATE OR REPLACE FUNCTION calculate_muscle_group_volume(
    p_session_id UUID,
    p_muscle_group TEXT
) RETURNS TABLE (
    muscle_group TEXT,
    direct_sets NUMERIC,
    total_sets NUMERIC,
    fractional_sets NUMERIC,
    total_volume_grams NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        emg.muscle_group,
        -- Direct sets: only primary muscles
        SUM(CASE WHEN emg.contribution_type = 'primary' THEN 1 ELSE 0 END) as direct_sets,
        -- Total sets: primary + secondary counted equally
        COUNT(*) as total_sets,
        -- Fractional sets: primary = 1.0, secondary = 0.5
        SUM(emg.volume_multiplier) as fractional_sets,
        -- Total volume
        SUM(calculate_effective_volume(s.id) * emg.volume_multiplier) as total_volume_grams
    FROM sets s
    JOIN exercise_muscle_groups emg ON s.exercise_id = emg.exercise_id
    WHERE s.session_id = p_session_id
      AND emg.muscle_group = p_muscle_group
      AND emg.contribution_type IN ('primary', 'secondary')  -- Exclude stabilizers from volume
    GROUP BY emg.muscle_group;
END;
$$ LANGUAGE plpgsql;
```

---

### 3.3 Analytics Queries

**Weekly Muscle Group Volume Report:**
```sql
WITH weekly_volumes AS (
    SELECT
        emg.muscle_group,
        DATE_TRUNC('week', ps.start_time) as week_start,
        SUM(calculate_effective_volume(s.id) * emg.volume_multiplier) / 1000.0 as volume_kg,
        SUM(emg.volume_multiplier) as fractional_sets
    FROM performed_sessions ps
    JOIN sets s ON ps.id = s.session_id
    JOIN exercise_muscle_groups emg ON s.exercise_id = emg.exercise_id
    WHERE ps.user_id = $1
      AND ps.start_time >= NOW() - INTERVAL '4 weeks'
      AND emg.contribution_type IN ('primary', 'secondary')
    GROUP BY emg.muscle_group, DATE_TRUNC('week', ps.start_time)
)
SELECT
    muscle_group,
    week_start,
    volume_kg,
    fractional_sets,
    CASE
        WHEN fractional_sets < 4 THEN 'Below minimum effective dose'
        WHEN fractional_sets BETWEEN 4 AND 11 THEN 'Maintenance volume'
        WHEN fractional_sets BETWEEN 12 AND 20 THEN 'Optimal hypertrophy range'
        WHEN fractional_sets > 20 THEN 'Diminishing returns / potential overtraining'
    END as volume_assessment
FROM weekly_volumes
ORDER BY muscle_group, week_start DESC;
```

**Muscle Imbalance Detection:**
```sql
WITH muscle_volumes AS (
    SELECT
        emg.muscle_group,
        SUM(calculate_effective_volume(s.id) * emg.volume_multiplier) as total_volume
    FROM performed_sessions ps
    JOIN sets s ON ps.id = s.session_id
    JOIN exercise_muscle_groups emg ON s.exercise_id = emg.exercise_id
    WHERE ps.user_id = $1
      AND ps.start_time >= NOW() - INTERVAL '4 weeks'
      AND emg.contribution_type IN ('primary', 'secondary')
    GROUP BY emg.muscle_group
),
ratios AS (
    SELECT
        -- Push/Pull ratio
        (SELECT total_volume FROM muscle_volumes WHERE muscle_group IN ('chest', 'triceps', 'anterior_deltoid')) as push_volume,
        (SELECT total_volume FROM muscle_volumes WHERE muscle_group IN ('back', 'biceps', 'posterior_deltoid')) as pull_volume,
        -- Quad/Hamstring ratio
        (SELECT total_volume FROM muscle_volumes WHERE muscle_group = 'quadriceps') as quad_volume,
        (SELECT total_volume FROM muscle_volumes WHERE muscle_group = 'hamstrings') as hamstring_volume
)
SELECT
    'Push/Pull' as imbalance_check,
    push_volume / NULLIF(pull_volume, 0) as ratio,
    CASE
        WHEN push_volume / NULLIF(pull_volume, 0) BETWEEN 0.8 AND 1.2 THEN 'Balanced'
        WHEN push_volume / NULLIF(pull_volume, 0) > 1.3 THEN 'Push-dominant (reduce push or increase pull volume)'
        WHEN push_volume / NULLIF(pull_volume, 0) < 0.7 THEN 'Pull-dominant (reduce pull or increase push volume)'
    END as assessment
FROM ratios
UNION ALL
SELECT
    'Quad/Hamstring' as imbalance_check,
    quad_volume / NULLIF(hamstring_volume, 0) as ratio,
    CASE
        WHEN quad_volume / NULLIF(hamstring_volume, 0) BETWEEN 1.0 AND 1.5 THEN 'Balanced'
        WHEN quad_volume / NULLIF(hamstring_volume, 0) > 2.0 THEN 'Quad-dominant (increase hamstring work to prevent injury)'
        WHEN quad_volume / NULLIF(hamstring_volume, 0) < 1.0 THEN 'Hamstring-dominant (unusual, verify data)'
    END as assessment
FROM ratios;
```

**Set Type Distribution Analysis:**
```sql
SELECT
    set_type,
    COUNT(*) as total_sets,
    SUM(calculate_effective_volume(id)) / 1000.0 as total_volume_kg,
    AVG(rpe) as avg_rpe,
    -- Time efficiency estimate
    CASE set_type
        WHEN 'myo-rep' THEN '~70% time savings vs traditional'
        WHEN 'drop-set' THEN '~50% time savings vs traditional'
        WHEN 'super-set' THEN '~50% time savings vs traditional'
        ELSE 'Standard duration'
    END as time_efficiency,
    -- Recovery cost
    CASE set_type
        WHEN 'drop-set' THEN 1.5
        WHEN 'super-set' THEN 1.2
        ELSE 1.0
    END as recovery_multiplier
FROM sets s
JOIN performed_sessions ps ON s.session_id = ps.id
WHERE ps.user_id = $1
  AND ps.start_time >= NOW() - INTERVAL '4 weeks'
GROUP BY set_type
ORDER BY total_volume_kg DESC;
```

---

### 3.4 Practical Recommendations Summary

**Volume Calculation Priority:**
1. **Exclude warm-up sets** <60% of working weight or <60% 1RM
2. **Count all working sets** for regular, pyramid, AMRAP, drop-set, myo-rep types
3. **Use fractional counting** for muscle group distribution (1.0 primary, 0.5 secondary)
4. **Track fatigue separately** for drop-sets and supersets (higher recovery cost)

**Set Type Recommendations by Goal:**

**Time Efficiency:**
- 1st Choice: Myo-reps (70% time reduction)
- 2nd Choice: Drop-sets or Supersets (50% time reduction)
- Note: Higher fatigue cost requires longer inter-session recovery

**Maximum Hypertrophy (Time Not Constrained):**
- Traditional sets with 0-3 RIR
- 12-20 sets per muscle group per week
- Focus on compounds + targeted isolation work

**Balanced Program:**
- 70% traditional sets
- 20% supersets (time efficiency on accessory work)
- 10% myo-reps or drop-sets (final sets for time-efficient intensity)

**Recovery Management:**
- Monitor drop-set and super-set volume as % of total weekly volume
- If >30% of weekly volume from high-fatigue techniques: extend recovery time 20-50%
- Use RPE tracking: sessions >8 RPE require proportionally more recovery

**Muscle Group Balance:**
- Calculate weekly volumes using fractional set method
- Flag imbalances: Push/Pull ratio outside 0.8-1.2, Quad/Ham ratio >2.0
- Address imbalances gradually: +10-20% volume to lagging groups over 4-6 weeks

---

## 4. References and Research Sources

### Primary Research (2025)

1. **Superset Training Meta-Analysis** (February 2025)
   - Systematic review and meta-analysis on superset versus traditional resistance training
   - PubMed ID: 39903375
   - Key Finding: Supersets reduce session duration without compromising training adaptations

2. **Volume-Equated Drop Set Research** (2025)
   - Study on equated volume load between traditional, pre-exhaustion, and drop sets
   - Sport Sciences for Health, DOI: 10.1007/s11332-024-01281-x
   - Key Finding: Similar improvements in strength, endurance, and hypertrophy across methods

3. **Proximity to Failure Dose-Response** (2025)
   - Meta-regression exploring estimated resistance training proximity to failure
   - PubMed ID: 38970765
   - Key Finding: Linear relationship between proximity to failure and hypertrophy

4. **Fractional Set Counting Methods** (2025)
   - Meta-regression on per-session volume effects on hypertrophy and strength
   - SportRxiv preprint
   - Key Finding: Critical to distinguish fractional vs. direct set counting methods

### Systematic Reviews and Meta-Analyses

5. **Drop Sets and Hypertrophy** (2023)
   - Systematic review and meta-analysis: Effects of drop sets on skeletal muscle hypertrophy
   - PMC: PMC10390395
   - Key Finding: No significant difference when volume equated

6. **Total Number of Sets for Hypertrophy** (2018)
   - Systematic review on sets as training volume quantification method
   - PubMed ID: 30063555
   - Key Finding: Set counting is valid hypertrophy volume metric

7. **Gluteus Maximus Activation** (2020)
   - Systematic review of gluteus maximus activation during common exercises
   - PMC: PMC7039033
   - Key Finding: >60% MVIC exercises identified

### Training Methodology Sources

8. **3D Muscle Journey** - Rest-pause/myo-reps and long rest periods
9. **RP Strength** - Progressing for hypertrophy strategies
10. **StrengthLog** - Pyramid training for building muscle and strength
11. **Mennohenselmans.com** - How to count training volume and design training splits
12. **Legion Athletics** - Myo-reps explained: building muscle in less time

### Specialized Topics

13. **EMG and Muscle Activation Measurement**
    - Core muscle activation studies (PMC: PMC5384053, PMC5294946)
    - Variations in latissimus dorsi activation (PMC: PMC449729)

14. **Warm-up Protocols**
    - VBT Coach 1RM warmup calculator methodology
    - StrengthLog 1RM warmup guidelines
    - GPS Human Performance warmup protocols

---

## 5. Implementation Roadmap

### Phase 1: Core Volume Calculations (Week 1-2)
- [ ] Implement `calculate_effective_volume()` function
- [ ] Add set_type field and constraints to sets table
- [ ] Create warm-up set exclusion logic (<60% working weight)
- [ ] Test volume calculations across all set types

### Phase 2: Muscle Group Distribution (Week 3-4)
- [ ] Create `exercise_muscle_groups` mapping table
- [ ] Populate primary/secondary muscle data for top 50 exercises
- [ ] Implement `calculate_muscle_group_volume()` function
- [ ] Create weekly volume report query

### Phase 3: Imbalance Detection (Week 5-6)
- [ ] Implement push/pull ratio calculation
- [ ] Implement quad/hamstring ratio calculation
- [ ] Create anterior/posterior shoulder balance check
- [ ] Build imbalance alert system

### Phase 4: Advanced Set Type Support (Week 7-8)
- [ ] Add myo-rep fields (activation_reps, mini_set_reps, mini_set_count)
- [ ] Add superset tracking (superset_group_id)
- [ ] Add drop-set grouping (drop_set_group_id)
- [ ] Implement set type-specific volume calculations

### Phase 5: Analytics and Reporting (Week 9-10)
- [ ] Build set type distribution analysis
- [ ] Create recovery cost calculator
- [ ] Implement volume trend visualizations
- [ ] Build muscle group balance dashboard

### Phase 6: Testing and Validation (Week 11-12)
- [ ] Unit tests for volume calculation functions
- [ ] Integration tests with real workout data
- [ ] Validate muscle group distributions against research
- [ ] User acceptance testing

---

## Appendix A: Quick Reference Tables

### Set Type Volume Calculation Summary

| Set Type | Volume Formula | Special Considerations | Fatigue Cost |
|----------|---------------|----------------------|--------------|
| Regular | `reps × weight` | Apply RIR adjustment if tracked | 1.0x |
| Warm-up | `0` (excluded) | Exclude if <60% working weight | N/A |
| Drop-set | `Σ(reps × weight)` per drop | Sum all drops in set | 1.5x |
| Myo-rep | `(activation_reps + Σmini_reps) × weight` | All mini-set reps are "effective" | 1.2x |
| Pyramid | `Σ(reps × weight)` per set | May exclude lightest set if <60% peak | 1.0x |
| Super-set | Count each exercise separately | Higher RPE; track muscle group overlap | 1.2-1.4x |
| AMRAP | `reps_achieved × weight` | Actual reps = effective reps | 1.1x |

### RIR (Reps in Reserve) Adjustment Multipliers

| RIR | Hypertrophy Effectiveness | Multiplier | Use Case |
|-----|-------------------------|-----------|----------|
| 0 (failure) | Maximum | 1.0 | Final sets, intensification blocks |
| 1-2 | Very High | 1.0 | Most working sets |
| 3 | High | 1.0 | Early accumulation phase |
| 4 | Moderate | 0.9 | Deload, fatigue management |
| 5 | Low-Moderate | 0.8 | High-injury-risk movements |
| 6+ | Low | 0.6 | Not recommended for hypertrophy |

### Muscle Activation Thresholds

| %MVIC | Activation Level | Training Outcome |
|-------|-----------------|------------------|
| >60% | Very High | Muscular strength |
| 41-60% | High | Muscular endurance |
| 21-40% | Moderate | Limited hypertrophy |
| <20% | Low | Minimal training effect |

### Weekly Volume Guidelines (per muscle group)

| Sets/Week | Volume Category | Expected Outcome |
|-----------|----------------|------------------|
| 0-3 | Below MED | Minimal/no adaptation |
| 4-8 | Maintenance | Maintain current size/strength |
| 9-11 | Lower Optimal | Moderate progress |
| 12-20 | Optimal | Maximum progress |
| 21-25 | High (advanced) | Diminishing returns |
| >25 | Excessive | Overtraining risk |

*MED = Minimum Effective Dose*

### Volume Distribution: Fractional Set Counting

| Muscle Role | Volume Multiplier | Example |
|------------|-------------------|---------|
| Primary | 1.0 | Bench press → Chest (1.0) |
| Secondary | 0.5 | Bench press → Triceps (0.5) |
| Stabilizer | 0.0 (exclude) | Bench press → Core (0.0) |

### Imbalance Detection Thresholds

| Ratio | Healthy Range | Flag Threshold | Concern |
|-------|--------------|----------------|---------|
| Push/Pull | 0.8 - 1.2 | <0.7 or >1.3 | Muscle imbalance, posture issues |
| Quad/Hamstring | 1.0 - 1.5 | >2.0 | Injury risk (ACL, hamstring tears) |
| Anterior/Posterior Delt | 1.0 - 1.5 | >2.0 | Shoulder impingement risk |
| Left/Right (bilateral) | 0.9 - 1.1 | >1.15 | Unilateral weakness |

---

## Document Metadata

**Version:** 1.0
**Last Updated:** 2025-11-21
**Research Duration:** 60 minutes
**Primary Researcher:** Claude (Sonnet 4.5)
**Review Status:** Initial Draft
**Next Review:** 2025-12-21 (or upon new research publication)

**Related Documents:**
- `/home/user/workout_app/docs/research/phase-2-research-plan.md` - Overall Phase 2 analytics planning
- `/home/user/workout_app/docs/research/2025-11-21-quick-research-findings.md` - Initial volume calculation research
- `/home/user/workout_app/docs/sets-migration-and-analytics.md` - Migration design document

**Implementation Status:** 📋 Research Complete → Ready for Development Planning
